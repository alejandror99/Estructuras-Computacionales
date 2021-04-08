// STM32L4 Nucleo - Assembly template
// Turns on an LED attached to GPIOA Pin 5
// We need to enable the clock for GPIOA and set up pin 5 as output.

// Start with enabling thumb 32 mode since Cortex-M4 do not work with arm mode
// Unified syntax is used to enable good of the both words...

// Make sure to run arm-none-eabi-objdump.exe -d prj1.elf to check if
// the assembler used proper instructions. (Like ADDS)

.thumb
.syntax unified

// Register Addresses
// You can find the base addresses for all peripherals from Memory Map section
// RM0351 on page 78. Then the offsets can be found on their relevant sections.

// Constants
.equ     PRESCALER,      1999

// 	 RCC   base address is 0x40021000
//   AHB2ENR register offset is 0x4C
.equ     RCC_AHB2ENR,   0x4002104C // RCC AHB2 peripheral clock reg

// 	 RCC   base address is 0x40021000
//   APB2ENR register offset is 0x58
.equ	 RCC_APB1ENR1,   0x40021058 // RCC APB1 peripheral clock reg

// 	 GPIOA base address is 0x48000000
//   MODER register offset is 0x00
//   ODR   register offset is 0x14
.equ     GPIOA_MODER,   0x48000000 // GPIOA port mode register
.equ     GPIOA_ODR,     0x48000014 // GPIOA output data register

// 	 TIM2  base address is 0x40000000
//   PSC   register offset is 0x28
//   ARR   register offset is 0x2C
//   DIER  register offset is 0x0C
//   CR1   register offset is 0x00
//   SR    register offset is 0x10
//   CNT   register offset is 0x24
.equ     TIM2_PSC,   0x40000028 // TIM2 prescaler register
.equ     TIM2_ARR,   0x4000002C // TIM2 auto-reload register
.equ     TIM2_DIER,  0x4000000C // TIM2 interrupt enable register
.equ     TIM2_CR1,   0x40000000 // TIM2 control 1 register
.equ     TIM2_SR,    0x40000010 // TIM2 status register
.equ     TIM2_CNT,   0x40000024 // TIM2 counter register

.equ     NVIC_IPR7,    0xE000E41C
.equ     NVIC_ISER0,   0xE000E100


// Start of text section
.section .text
///////////////////////////////////////////////////////////////////////////////
// Vectors
///////////////////////////////////////////////////////////////////////////////
// Add all other processor specific exceptions/interrupts in order here
	.word    __StackTop                 // Top of the stack. from linker script
	.word    _main +1                  // reset location, +1 for thumb mode
	.word    NMI_Handler + 1
    .word    HardFault_Handler  + 1
    .word    MemManage_Handler + 1
    .word    BusFault_Handler + 1
    .word    UsageFault_Handler + 1
	.word	0
	.word   0
  	.word	0
  	.word	0
  	.word	SVC_Handler +1
  	.word	DebugMon_Handler +1
  	.word	0
  	.word	PendSV_Handler +1
  	.word	SysTick_Handler +1
  	.word	WWDG_IRQHandler +1               		/* Window Watchdog interrupt                                           */
  	.word	PVD_PVM_IRQHandler +1           		/* PVD through EXTI line detection                                     */
  	.word	TAMP_STAMP_IRQHandler +1        		/* Tamper and TimeStamp interrupts                                     */
  	.word	RTC_WKUP_IRQHandler +1          		/* RTC Tamper or TimeStamp /CSS on LSE through EXTI line 19 interrupts */
  	.word	FLASH_IRQHandler +1             		/* Flash global interrupt                                              */
  	.word	RCC_IRQHandler +1               		/* RCC global interrupt                                                */
  	.word	EXTI0_IRQHandler +1             		/* EXTI Line 0 interrupt                                               */
  	.word	EXTI1_IRQHandler +1            			/* EXTI Line 1 interrupt                                               */
  	.word	EXTI2_IRQHandler +1            			/* EXTI Line 2 interrupt                                               */
  	.word	EXTI3_IRQHandler +1            			/* EXTI Line 3 interrupt                                               */
  	.word	EXTI4_IRQHandler +1            			/* EXTI Line 4 interrupt                                               */
  	.word	DMA1_CH1_IRQHandler +1          		/* DMA1 Channel1 global interrupt                                      */
  	.word	DMA1_CH2_IRQHandler +1         			/* DMA1 Channel2 global interrupt                                      */
  	.word	DMA1_CH3_IRQHandler +1         			/* DMA1 Channel3 interrupt                                             */
  	.word	DMA1_CH4_IRQHandler +1         			/* DMA1 Channel4 interrupt                                             */
  	.word	DMA1_CH5_IRQHandler +1         			/* DMA1 Channel5 interrupt                                             */
  	.word	DMA1_CH6_IRQHandler +1         			/* DMA1 Channel6 interrupt                                             */
  	.word	DMA1_CH7_IRQHandler +1         			/* DMA1 Channel 7 interrupt                                            */
  	.word	ADC1_2_IRQHandler  +1          			/* ADC1 and ADC2 global interrupt                                      */
  	.word	CAN1_TX_IRQHandler +1          			/* CAN1 TX interrupts                                                  */
  	.word	CAN1_RX0_IRQHandler +1         			/* CAN1 RX0 interrupts                                                 */
  	.word	CAN1_RX1_IRQHandler +1         			/* CAN1 RX1 interrupts                                                 */
  	.word	CAN1_SCE_IRQHandler +1         			/* CAN1 SCE interrupt                                                  */
  	.word	EXTI9_5_IRQHandler  +1         			/* EXTI Line5 to Line9 interrupts                                      */
  	.word	TIM1_BRK_TIM15_IRQHandler +1   			/* TIM1 Break/TIM15 global interrupts                                  */
  	.word	TIM1_UP_TIM16_IRQHandler +1    			/* TIM1 Update/TIM16 global interrupts                                 */
  	.word	TIM1_TRG_COM_TIM17_IRQHandler +1		/* TIM1 Trigger and Commutation interrupts and TIM17 global interrupt  */
  	.word	TIM1_CC_IRQHandler +1          			/* TIM1 Capture Compare interrupt                                      */
  	.word	TIM2_IRQHandler +1             			/* TIM2 global interrupt                                               */
  	.word	TIM3_IRQHandler +1             			/* TIM3 global interrupt                                               */
  	.word	TIM4_IRQHandler +1              			/* TIM4 global interrupt                                               */
 	.word	I2C1_EV_IRQHandler +1           			/* I2C1 event interrupt                                                */
  	.word	I2C1_ER_IRQHandler +1          			/* I2C1 error interrupt                                                */
  	.word	I2C2_EV_IRQHandler +1          			/* I2C2 event interrupt                                                */
  	.word	I2C2_ER_IRQHandler +1          			/* I2C2 error interrupt                                                */
  	.word	SPI1_IRQHandler +1             			/* SPI1 global interrupt                                               */
  	.word	SPI2_IRQHandler +1             			/* SPI2 global interrupt                                               */
  	.word	USART1_IRQHandler +1           			/* USART1 global interrupt                                             */
  	.word	USART2_IRQHandler +1           			/* USART2 global interrupt                                             */
  	.word	USART3_IRQHandler +1           			/* USART3 global interrupt                                             */
  	.word	EXTI15_10_IRQHandler +1        			/* EXTI Lines 10 to 15 interrupts                                      */
  	.word	RTC_ALARM_IRQHandler +1        			/* RTC alarms through EXTI line 18 interrupts                          */
  	.word	DFSDM1_FLT3_IRQHandler +1      			/* DFSDM1_FLT3 global interrupt                                        */
  	.word	TIM8_BRK_IRQHandler +1         			/* TIM8 Break Interrupt                                                */
  	.word	TIM8_UP_IRQHandler +1          			/* TIM8 Update Interrupt                                               */
  	.word	TIM8_TRG_COM_IRQHandler +1     			/* TIM8 Trigger and Commutation Interrupt                              */
  	.word	TIM8_CC_IRQHandler +1          			/* TIM8 Capture Compare Interrupt                                      */
  	.word	ADC3_IRQHandler +1             			/* ADC3 global interrupt                                               */
  	.word	FMC_IRQHandler +1              			/* FMC global Interrupt                                                */
  	.word	SDMMC1_IRQHandler +1           			/* SDMMC global Interrupt                                              */
  	.word	TIM5_IRQHandler +1             			/* TIM5 global Interrupt                                               */
  	.word	SPI3_IRQHandler +1             			/* SPI3 global Interrupt                                               */
  	.word	UART4_IRQHandler +1            			/* UART4 global Interrupt                                              */
  	.word	UART5_IRQHandler +1            			/* UART5 global Interrupt                                              */
  	.word	TIM6_DACUNDER_IRQHandler +1    			/* TIM6 global and DAC1 and 2 underrun error interrupts                */
  	.word	TIM7_IRQHandler +1             			/* TIM7 global interrupt                                               */
  	.word	DMA2_CH1_IRQHandler +1         			/* DMA2 Channel 1 global Interrupt                                     */
  	.word	DMA2_CH2_IRQHandler +1         			/* DMA2 Channel 2 global Interrupt                                     */
  	.word	DMA2_CH3_IRQHandler +1         			/* DMA2 Channel 3 global Interrupt                                     */
  	.word	DMA2_CH4_IRQHandler +1         			/* DMA2 Channel 4 global Interrupt                                     */
  	.word	DMA2_CH5_IRQHandler +1         			/* DMA2 Channel 5 global Interrupt                                     */
  	.word	DFSDM1_FLT0_IRQHandler +1      			/* DFSDM1_FLT0 global interrupt                                        */
  	.word	DFSDM1_FLT1_IRQHandler +1      			/* DFSDM1_FLT1 global interrupt                                        */
  	.word	DFSDM1_FLT2_IRQHandler +1      			/* DFSDM1_FLT2 global interrupt                                        */
  	.word	COMP_IRQHandler +1             			/* COMP1 and COMP2 interrupts                                          */
  	.word	LPTIM1_IRQHandler +1           			/* LP TIM1 interrupt                                                   */
  	.word	LPTIM2_IRQHandler +1           			/* LP TIM2 interrupt                                                   */
  	.word	OTG_FS_IRQHandler +1           			/* USB OTG FS global Interrupt                                         */
  	.word	DMA2_CH6_IRQHandler +1         			/* DMA2 Channel 6 global Interrupt                                     */
  	.word	DMA2_CH7_IRQHandler +1         			/* DMA2 Channel 7 global Interrupt                                     */
  	.word	LPUART1_IRQHandler +1          			/* LPUART1 global interrupt                                            */
  	.word	QUADSPI_IRQHandler +1          			/* Quad SPI global interrupt                                           */
  	.word	I2C3_EV_IRQHandler +1          			/* I2C3 event interrupt                                                */
  	.word	I2C3_ER_IRQHandler +1          			/* I2C3 error interrupt                                                */
 	.word	SAI1_IRQHandler +1             			/* SAI1 global interrupt                                               */
 	.word	SAI2_IRQHandler +1             			/* SAI2 global interrupt                                               */
  	.word	SWPMI1_IRQHandler +1           			/* SWPMI1 global interrupt                                             */
  	.word	TSC_IRQHandler +1              			/* TSC global interrupt                                                */
  	.word	LCD_IRQHandler +1              			/* LCD global interrupt                                                */
  	.word	AES_IRQHandler +1              			/* AES global interrupt                                                */
  	.word	RNG_IRQHandler +1              			/* RNG and HASH global interrupt                                       */
  	.word	FPU_IRQHandler +1              			/* Floating point interrupt                                            */

///////////////////////////////////////////////////////////////////////////////
// Main code starts from here
///////////////////////////////////////////////////////////////////////////////
_main:
  	// Enable GPIOA and GPIOC Peripheral Clock (bit 0 and 2 in AHB2ENR register)
	ldr r6, = RCC_AHB2ENR       // Load peripheral clock reg address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x1		            // Set bit 0 to enable GPIOA clock
	str r5, [r6]                // Store result in peripheral clock register

	// Make GPIOA Pin5 as output pin (bits 1:0 in MODER register)
	ldr r6, = GPIOA_MODER       // Load GPIOA MODER register address to r6
	ldr r5, [r6]                // Read its content to r5
	and r5, 0xFFFFF7FF          // Write 01 to bits 11, 10 for P5
	str r5, [r6]                // Store result in GPIOA MODER register

	// Enable TIMER2 Controller Clock (bit 0 in APB1ENR1 register)
	ldr r6, = RCC_APB1ENR1      // Load peripheral clock reg address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x1                 // Set bit 0 to enable APB1ENR1 clock
	str r5, [r6]                // Store result in peripheral clock register

	// Make TIMER2 prescaler register (bits 15:0 in PSC register)
	ldr r6, = TIM2_PSC          // Load TIM2 PSC register address to r6
	ldr r5, = 0x3E7             // load 999 constant to r5 register
	          					// fCK_PSC / (PSC[15:0] + 1) = 4 MHz / n + 1 =  timer clock speed
	str r5, [r6]                // Store result in TIM2 PSC register

	// Make TIMER2 auto-reload register (bits 31:0 in ARR register)
	ldr r6, = TIM2_ARR          // Load TIM2 ARR register address to r6
	ldr r5, [r6]                // Read its content to r5
	and r5, 0xFA0             	// Write 4000 ARR = IN_interrpt/T_timer
	str r5, [r6]                // Store result in TIM2 ARR register

	// Make TIMER2 interrupt enable register (bits 31:0 in DIER register)
	ldr r6, = TIM2_DIER         // Load TIM2 DIER register address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x1             	// Set bit 0 to update interrupt enable
	str r5, [r6]                // Store result in TIM2 DIER register

	ldr r6, = NVIC_ISER0
	ldr r5, [r6]
	orr r5, 0x10000000
	str r5, [r6]

	ldr r6, = NVIC_IPR7
	ldr r5, [r6]
	orr r5, 0x10
	str r5, [r6]

	// Make TIMER2 enable register (bits 15:0 in CR1 register)
	ldr r6, = TIM2_CR1          // Load TIM2 CR1 register address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x1             	// Set bit 0 to enable timer
	str r5, [r6]                // Store result in TIM2 CR1 register

	CPSIE i						// Enable Global Interrupt

loop:
	b loop

_dummy:
NMI_Handler:
HardFault_Handler:
MemManage_Handler:
BusFault_Handler:
UsageFault_Handler:
        add r0, 1
        add r1, 1
        b _dummy
SVC_Handler:
DebugMon_Handler:
PendSV_Handler:
SysTick_Handler:
WWDG_IRQHandler:               		/* Window Watchdog interrupt                                           */
PVD_PVM_IRQHandler:           		/* PVD through EXTI line detection                                     */
TAMP_STAMP_IRQHandler:        		/* Tamper and TimeStamp interrupts                                     */
RTC_WKUP_IRQHandler:          		/* RTC Tamper or TimeStamp /CSS on LSE through EXTI line 19 interrupts */
FLASH_IRQHandler:             		/* Flash global interrupt                                              */
RCC_IRQHandler:               		/* RCC global interrupt                                                */
EXTI0_IRQHandler:             		/* EXTI Line 0 interrupt                                               */
EXTI1_IRQHandler:            		/* EXTI Line 1 interrupt                                               */
EXTI2_IRQHandler:            		/* EXTI Line 2 interrupt                                               */
EXTI3_IRQHandler:            		/* EXTI Line 3 interrupt                                               */
EXTI4_IRQHandler:            		/* EXTI Line 4 interrupt                                               */
DMA1_CH1_IRQHandler:          		/* DMA1 Channel1 global interrupt                                      */
DMA1_CH2_IRQHandler:         		/* DMA1 Channel2 global interrupt                                      */
DMA1_CH3_IRQHandler:         		/* DMA1 Channel3 interrupt                                             */
DMA1_CH4_IRQHandler:         		/* DMA1 Channel4 interrupt                                             */
DMA1_CH5_IRQHandler:         		/* DMA1 Channel5 interrupt                                             */
DMA1_CH6_IRQHandler:         		/* DMA1 Channel6 interrupt                                             */
DMA1_CH7_IRQHandler:         		/* DMA1 Channel 7 interrupt                                            */
ADC1_2_IRQHandler:          		/* ADC1 and ADC2 global interrupt                                      */
CAN1_TX_IRQHandler:          		/* CAN1 TX interrupts                                                  */
CAN1_RX0_IRQHandler:         		/* CAN1 RX0 interrupts                                                 */
CAN1_RX1_IRQHandler:         		/* CAN1 RX1 interrupts                                                 */
CAN1_SCE_IRQHandler:         		/* CAN1 SCE interrupt                                                  */
EXTI9_5_IRQHandler:         		/* EXTI Line5 to Line9 interrupts                                      */
TIM1_BRK_TIM15_IRQHandler:   		/* TIM1 Break/TIM15 global interrupts                                  */
TIM1_UP_TIM16_IRQHandler:    		/* TIM1 Update/TIM16 global interrupts                                 */
TIM1_TRG_COM_TIM17_IRQHandler:		/* TIM1 Trigger and Commutation interrupts and TIM17 global interrupt  */
TIM1_CC_IRQHandler:          		/* TIM1 Capture Compare interrupt                                      */
TIM2_IRQHandler:             		/* TIM2 global interrupt                                               */

	ldr r6, = TIM2_CNT
	ldr r5, [r6]
	cmp r5, 0x7D0
	beq	int
	ldr r6, = GPIOA_ODR         	// Load GPIOA output data register
	ldr r5, [r6]                	// Read its content to r5
	and r5, 0x0000              	// write 1 to pin 5
	str r5, [r6]                	// Store result in GPIOA output data register
	bx lr

int:
	ldr r6, = GPIOA_ODR         	// Load GPIOA output data register
	ldr r5, [r6]                	// Read its content to r5
	orr r5, 0x0020              	// write 1 to pin 5
	str r5, [r6]                	// Store result in GPIOA output data register

	ldr r7, = TIM2_SR
	ldr r8, [r7]
	and r8, 0xFE
	str r8, [r7]					//Clear any pending event on SR

	bx lr

TIM3_IRQHandler:             		/* TIM3 global interrupt                                               */
TIM4_IRQHandler:              		/* TIM4 global interrupt                                               */
I2C1_EV_IRQHandler:           		/* I2C1 event interrupt                                                */
I2C1_ER_IRQHandler:          		/* I2C1 error interrupt                                                */
I2C2_EV_IRQHandler:          		/* I2C2 event interrupt                                                */
I2C2_ER_IRQHandler:          		/* I2C2 error interrupt                                                */
SPI1_IRQHandler:             		/* SPI1 global interrupt                                               */
SPI2_IRQHandler:             		/* SPI2 global interrupt                                               */
USART1_IRQHandler:           		/* USART1 global interrupt                                             */
USART2_IRQHandler:           		/* USART2 global interrupt                                             */
USART3_IRQHandler:           		/* USART3 global interrupt                                             */
EXTI15_10_IRQHandler:        		/* EXTI Lines 10 to 15 interrupts  									   */
RTC_ALARM_IRQHandler:        		/* RTC alarms through EXTI line 18 interrupts                          */
DFSDM1_FLT3_IRQHandler:      		/* DFSDM1_FLT3 global interrupt                                        */
TIM8_BRK_IRQHandler:         		/* TIM8 Break Interrupt                                                */
TIM8_UP_IRQHandler:          		/* TIM8 Update Interrupt                                               */
TIM8_TRG_COM_IRQHandler:     		/* TIM8 Trigger and Commutation Interrupt                              */
TIM8_CC_IRQHandler:          		/* TIM8 Capture Compare Interrupt                                      */
ADC3_IRQHandler:             		/* ADC3 global interrupt                                               */
FMC_IRQHandler:              		/* FMC global Interrupt                                                */
SDMMC1_IRQHandler:           		/* SDMMC global Interrupt                                              */
TIM5_IRQHandler:             		/* TIM5 global Interrupt                                               */
SPI3_IRQHandler:             		/* SPI3 global Interrupt                                               */
UART4_IRQHandler:            		/* UART4 global Interrupt                                              */
UART5_IRQHandler:            		/* UART5 global Interrupt                                              */
TIM6_DACUNDER_IRQHandler:    		/* TIM6 global and DAC1 and 2 underrun error interrupts                */
TIM7_IRQHandler:             		/* TIM7 global interrupt                                               */
DMA2_CH1_IRQHandler:         		/* DMA2 Channel 1 global Interrupt                                     */
DMA2_CH2_IRQHandler:         		/* DMA2 Channel 2 global Interrupt                                     */
DMA2_CH3_IRQHandler:         		/* DMA2 Channel 3 global Interrupt                                     */
DMA2_CH4_IRQHandler:         		/* DMA2 Channel 4 global Interrupt                                     */
DMA2_CH5_IRQHandler:         		/* DMA2 Channel 5 global Interrupt                                     */
DFSDM1_FLT0_IRQHandler:      		/* DFSDM1_FLT0 global interrupt                                        */
DFSDM1_FLT1_IRQHandler:      		/* DFSDM1_FLT1 global interrupt                                        */
DFSDM1_FLT2_IRQHandler:      		/* DFSDM1_FLT2 global interrupt                                        */
COMP_IRQHandler:             		/* COMP1 and COMP2 interrupts                                          */
LPTIM1_IRQHandler:           		/* LP TIM1 interrupt                                                   */
LPTIM2_IRQHandler:           		/* LP TIM2 interrupt                                                   */
OTG_FS_IRQHandler:           		/* USB OTG FS global Interrupt                                         */
DMA2_CH6_IRQHandler:         		/* DMA2 Channel 6 global Interrupt                                     */
DMA2_CH7_IRQHandler:         		/* DMA2 Channel 7 global Interrupt                                     */
LPUART1_IRQHandler:          		/* LPUART1 global interrupt                                            */
QUADSPI_IRQHandler:          		/* Quad SPI global interrupt                                           */
I2C3_EV_IRQHandler:          		/* I2C3 event interrupt                                                */
I2C3_ER_IRQHandler:          		/* I2C3 error interrupt                                                */
SAI1_IRQHandler:             		/* SAI1 global interrupt                                               */
SAI2_IRQHandler:             		/* SAI2 global interrupt                                               */
SWPMI1_IRQHandler:           		/* SWPMI1 global interrupt                                             */
TSC_IRQHandler:              		/* TSC global interrupt                                                */
LCD_IRQHandler:              		/* LCD global interrupt                                                */
AES_IRQHandler:              		/* AES global interrupt                                                */
RNG_IRQHandler:              		/* RNG and HASH global interrupt                                       */
FPU_IRQHandler:						/* Floating point interrupt                                            */
