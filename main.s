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

.equ     RCC_AHB2ENR,   0x4002104C
.equ     GPIOA_MODER,   0x48000000
.equ     GPIOA_ODR,     0x48000014
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

ldr r1, =RCC_AHB2ENR
ldr r0, [r1]
orr r0, 0x00000001 // Put here the value obtained
str r0, [r1]			 // Set GPIOAEN bit in RCC_APB2ENR to 1 to enable GPIOA

ldr r0, =GPIOA_MODER // Pseudo instruction
ldr r1, [r0] // Not a pseudo instruction
and r1,0xFFFFF7FF //r1 = r1 + r2
str r1, [r0] //; Save rl to memory

ldr r1, =GPIOA_ODR
ldr r0, [r1]
orr r0, 0xFFFFFFFF // Put here the value obtained
str r0, [r1]			 // Set ODR in GPIOA_ODR to 1 to set PA5 high


