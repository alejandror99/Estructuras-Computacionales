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
.equ     DELAY,      800000

// 	 RCC   base address is 0x40021000
//   AHB2ENR register offset is 0x4C
.equ     RCC_AHB2ENR,   0x4002104C // RCC AHB2 peripheral clock reg

// 	 RCC   base address is 0x40021000
//   CCIPR register offset is 0x88
.equ	 RCC_CCIPR,   0x40021088 // RCC CCIPR peripheral independent clock reg

// 	 GPIOA base address is 0x48000000
//   MODER register offset is 0x00
//   ASCR  register offset is 0x2C
.equ     GPIOA_MODER,   0x48000000 // GPIOA port mode register
.equ     GPIOA_ASCR,    0x4800002C // GPIOA analog switch data register

// 	 ADC1  base address is 0x50040000
//   CR    register offset is 0x08
//   SQR1  register offset is 0x30
//   SMPR1 register offset is 0x14
//   ISR   register offset is 0x00
//   DR    register offset is 0x40
.equ     ADC1_CR,     0x50040008 // ADC1 control register
.equ     ADC1_SQR1,   0x50040030 // ADC1 regular sequence register
.equ     ADC1_SMPR1,  0x50040014 // ADC1 sample time register
.equ     ADC1_ISR,    0x50040000 // ADC1 interrupt and status register
.equ     ADC1_DR,     0x50040040 // ADC1 regular data register

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
  	// Enable GPIOA & ADC Peripheral Clock (bit 0 & 13 in AHB2ENR register)
	ldr r6, = RCC_AHB2ENR       // Load peripheral clock reg address to r6
	ldr r5, = 0x2001            // Set bit 0 to enable GPIOA clock and bit 13 ADC clock enable
	str r5, [r6]                // Store result in peripheral clock register

	// Enable ADC Clock (bit 29 & 28 in CCIPR register)
	ldr r6, = RCC_CCIPR         // Load peripheral clock reg address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x30000000          // Set bit 29 & 28 to enable system clock as ADC clock
	str r5, [r6]                // Store result in peripheral clock register

	// Make GPIOA Pin1 as analog pin (bits 3:2 in MODER register)
	ldr r6, = GPIOA_MODER       // Load GPIOA MODER register address to r6
	ldr r5, [r6]                // Read its content to r5
	and r5, 0xFFFFFFFF          // Write 11 to bits 3, 2 for P1
	str r5, [r6]                // Store result in GPIOA MODER register

	// Make GPIOA Pin1 as analog switch pin (bits 3:2 in ASCR register)
	ldr r6, = GPIOA_ASCR        // Load GPIOA ASCR register address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x00000002          // Write 10 to bit 1 for P1
	str r5, [r6]                // Store result in GPIOA ASCR register

	// Enable ADC1 voltage regulator (bit 28 in CR register)
	ldr r6, = ADC1_CR           // Load peripheral clock reg address to r6
	ldr r5, = 0x10000000         // Set bit 1 to enable ADVREGEN
	str r5, [r6]                // Store result in peripheral clock register

	// Set regular secuence chanel ADC1 (bit 10:6 in SQ1 register)
	ldr r6, = ADC1_SQR1         // Load peripheral clock reg address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x180               // Set bit 8:7 to enable CH6
	str r5, [r6]                // Store result in peripheral clock register

	// Set sample time ADC1 CH6 (bit 20:18 in SMP6 register)
	ldr r6, = ADC1_SMPR1        // Load peripheral clock reg address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x001C0000          // Set 640.5 ADC clock cycles
	str r5, [r6]                // Store result in peripheral clock register

	// Enable ADC (bit 0 in ADEN register)
	ldr r6, = ADC1_CR           // Load peripheral clock reg address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x1                 // Set bit 1 to enable ADC
	str r5, [r6]                // Store result in peripheral clock register

	// wait time while ADC initialize
	ldr r4, = DELAY			    // Load 800000 ticks to r4
delay1:
	sub r4, r4, #1				// Subtract data content in r4 less 1
	cmp r4, #0					// Compare data content in r4 is 0
 	bne delay1					// branch instruction: jump to lazo 1 if r4 is different to 0 else go to next instruction


loop:

	// ADC START
	ldr r6, = ADC1_CR           // Load reg address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x4                 // Set bit 1 to enable ADSTART
	str r5, [r6]                // Store result in peripheral clock register

	// ADC wait end of conversion
eoc:
	ldr r6, = ADC1_ISR          // Load reg address to r6
	ldr r5, [r6]                // Read its content to r5
	and r5, 0x4
	cmp r5, #4                  // Compare data content in r4 is 4
	bne eoc                     // brach while conversion finish

	ldr r6, = ADC1_DR           // Load reg address to r6
	ldr r5, [r6]                // Read its content to r5

	// ADC wait end of sequence is cleared
eos:
	ldr r6, = ADC1_ISR          // Load reg address to r6
	ldr r5, [r6]                // Read its content to r5
	and r5, 0x8
	cmp r5, #8                  // Compare data content in r4 is 8
	bne eos                     // brach while conversion finish

	// set sequence bit
	ldr r6, = ADC1_ISR          // Load reg address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x8                 // Set bit 3 to enable EOS
	str r5, [r6]                // Store result in register

	b loop                      // Jump to loop
