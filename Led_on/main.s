// STM32L4 Nucleo - Assembly template
// Turns on an LED attached to GPIOA Pin 5
// We need to enable the clock for GPIOA and set up pin 5 as output.

// Start with enabling thumb 32 mode since Cortex-M4 do not work with arm mode
// Unified syntax is used to enable good of the both words...

// Make sure to run arm-none-eabi-objdump.exe -d prj1.elf to check if
// the assembler used proper instructions. (Like ADDS)

.thumb
.syntax unified
//.arch armv7e-m

///////////////////////////////////////////////////////////////////////////////
// Definitions
///////////////////////////////////////////////////////////////////////////////
// Definitions section. Define all the registers and
// constants here for code readability.

// Register Addresses
// You can find the base addresses for all peripherals from Memory Map section
// RM0351 on page 78. Then the offsets can be found on their relevant sections.

// 	 RCC   base address is 0x40021000
//   AHB2ENR register offset is 0x4C
.equ     RCC_AHB2ENR,   0x4002104C // RCC AHB2 peripheral clock reg (page 251)

// 	 GPIOA base address is 0x48000000
//   MODER register offset is 0x00
//   ODR   register offset is 0x14
.equ     GPIOA_MODER,   0x48000000 // GPIOA port mode register (page 303)
.equ     GPIOA_ODR,     0x48000014 // GPIOA output data register (page 305)
// Start of text section
.section .text
///////////////////////////////////////////////////////////////////////////////
// Vectors
///////////////////////////////////////////////////////////////////////////////
// Vector table start
// Add all other processor specific exceptions/interrupts in order here
	.long    __StackTop                 // Top of the stack. from linker script
	.long    _start +1                  // reset location, +1 for thumb mode

///////////////////////////////////////////////////////////////////////////////
// Main code starts from here
///////////////////////////////////////////////////////////////////////////////

_start:
	// Enable GPIOA Peripheral Clock (bit 0 in AHB2ENR register)
	ldr r6, = RCC_AHB2ENR       // Load peripheral clock reg address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, 0x00000001          // Set bit 0 to enable GPIOA clock
	str r5, [r6]                // Store result in peripheral clock register

	// Make GPIOA Pin5 as output pin (bits 1:0 in MODER register)
	ldr r6, = GPIOA_MODER       // Load GPIOA MODER register address to r6
	ldr r5, [r6]                // Read its content to r5
	and r5, 0xABFFFFFF          // Clear bits 11, 10 for P5
	and r5, 0xFFFFF7FF          // Write 01 to bits 11, 10 for P5
	str r5, [r6]                // Store result in GPIOA MODER register


	ldr r6, = GPIOA_ODR         // Load GPIOA output data register
	ldr r5, = 0x0020                // Read its content to r5
	str r5, [r6]                // Store result in GPIOA output data register
	// Read GPIOC Pin13


loop:
	nop                         // No operation. Do nothing.
	b loop                      // Jump to loop

