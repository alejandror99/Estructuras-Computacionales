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
.equ     PRESCALER,      4

// 	 RCC   base address is 0x40021000
//   AHB2ENR register offset is 0x4C
.equ     RCC_AHB2ENR,   0x4002104C // RCC AHB2 peripheral clock reg

// 	 RCC   base address is 0x40021000
//   APB2ENR register offset is 0x58
.equ	 RCC_APB1ENR1,   0x40021058 // RCC APB1 peripheral clock reg

// 	 GPIOA base address is 0x48000000
//   MODER register offset is 0x00
//   AFRL  register offset is 0x20
.equ     GPIOA_MODER,   0x48000000 // GPIOA port mode register
.equ     GPIOA_AFRL,    0x48000020 // GPIOA alternate data register

// 	 TIM2  base address is 0x40000000
//   PSC   register offset is 0x28
//   ARR   register offset is 0x2C
//   CR1   register offset is 0x00
//   CCMR1 register offset is 0x18
//   CCR1  register offset is 0x34
//   CCER  register offset is 0x20
.equ     TIM2_PSC,   0x40000028 // TIM2 prescaler register
.equ     TIM2_ARR,   0x4000002C // TIM2 auto-reload register
.equ     TIM2_CR1,   0x40000000 // TIM2 control 1 register
.equ     TIM2_CCMR1, 0x40000018 // TIM2 capture/compare mode register
.equ     TIM2_CCR1,  0x40000034 // TIM2 capture/compare register
.equ     TIM2_CCER,  0x40000020 // TIM2 capture/compare enable register

// Start of text section
.section .text
///////////////////////////////////////////////////////////////////////////////
// Vectors
///////////////////////////////////////////////////////////////////////////////
// Vector table start
// Add all other processor specific exceptions/interrupts in order here
	.long    __StackTop                 // Top of the stack. from linker script
	.long    _main +1                  // reset location, +1 for thumb mode

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
	and r5, 0xFFFFFBFF          // Write 10 to bits 11, 10 for P5
	str r5, [r6]                // Store result in GPIOA MODER register

	// Make GPIOA Pin5 as alternate pin (bits 1:0 in AFRL register)
	ldr r6, = GPIOA_AFRL        // Load GPIOA AFRL register address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x00100000          // Write 0001 to bits 23, 22, 21, 20 for P5
	str r5, [r6]                // Store result in GPIOA AFRL register

	// Enable TIMER2 Controller Clock (bit 0 in APB1ENR1 register)
	ldr r6, = RCC_APB1ENR1      // Load peripheral clock reg address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x1                 // Set bit 0 to enable APB1ENR1 clock
	str r5, [r6]                // Store result in peripheral clock register

	// Make TIMER2 prescaler register (bits 15:0 in PSC register)
	ldr r6, = TIM2_PSC          // Load TIM2 PSC register address to r6
	ldr r5, = PRESCALER         // load 4 constant to r5 register
	          					// fCK_PSC / (PSC[15:0] + 1) = 4 MHz / n + 1 =  timer clock speed
	str r5, [r6]                // Store result in TIM2 PSC register

	// Make TIMER2 auto-reload register (bits 31:0 in ARR register)
	ldr r6, = TIM2_ARR          // Load TIM2 ARR register address to r6
	ldr r5, [r6]                // Read its content to r5
	and r5, 0x50             	// Write 80 ARR = IN_interrpt/T_timer
	str r5, [r6]                // Store result in TIM2 ARR register

	// Make TIMER2 capture/compare register (bits 31:0 in CCR1 register)
	ldr r6, = TIM2_CCR1         // Load TIM2 CCR1 register address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x8             	// Set duty cycle
	str r5, [r6]                // Store result in TIM2 CCR1 register

	// Make TIMER2 capture/compare mode register (bits 31:0 in CCMR1 register)
	ldr r6, = TIM2_CCMR1        // Load TIM2 CCMR1 register address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x68             	// Set PWM mode
	str r5, [r6]                // Store result in TIM2 CCMR1 register

	// Make TIMER2 capture/compare enable register (bits 15:0 in CCER register)
	ldr r6, = TIM2_CCER         // Load TIM2 CCER register address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x1             	// enable output
	str r5, [r6]                // Store result in TIM2 CCER register

	// Make TIMER2 enable register (bits 15:0 in CR1 register)
	ldr r6, = TIM2_CR1          // Load TIM2 CR1 register address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x1             	// Set bit 0 to enable timer
	str r5, [r6]                // Store result in TIM2 CR1 register

loop:
	b loop                      // Jump to loop
