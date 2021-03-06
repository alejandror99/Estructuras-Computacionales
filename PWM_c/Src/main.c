/**
 ******************************************************************************
 * @file           : main.c
 * @author         : Auto-generated by STM32CubeIDE
 * @brief          : Main program body
 ******************************************************************************
 * @attention
 *
 * <h2><center>&copy; Copyright (c) 2019 STMicroelectronics.
 * All rights reserved.</center></h2>
 *
 * This software component is licensed by ST under BSD 3-Clause license,
 * the "License"; You may not use this file except in compliance with the
 * License. You may obtain a copy of the License at:
 *                        opensource.org/licenses/BSD-3-Clause
 *
 ******************************************************************************
 */

/*************************************************
* Libraries include
*************************************************/
#include "stm32l476xx.h"
#include <stdbool.h>
/*************************************************
* definition variables
*************************************************/
#define PWMCOUNT 100

bool up = true;
/*************************************************
* function prototyping
*************************************************/

/*************************************************
* external interrupt handler
*************************************************/
void EXTI15_10_IRQHandler(void)
{
	// Check if the interrupt came from exti0
	if (EXTI->PR1 & (1 << 13)) {

		if(up) {
			TIM2->CCR1 += 10;
		} else {
			TIM2->CCR1 -= 10;
		}

		if(TIM2->CCR1 == 100) {
			up = false;
		} else if(TIM2->CCR1 == 0) {
			up = true;
		}
	}

	// Clear pending bit
	EXTI->PR1 = 0x00002000;
}

/*************************************************
* Main
*************************************************/
int main(void)
{
	// enable GPIOA clock
	RCC->AHB2ENR = 0x5;
	// Make GPIOA Pin5 as Alternate pin (bits 1:0 in MODER register)
	GPIOA->MODER &= 0xFFFFFBFF;
	GPIOC->MODER &= 0xF3FFFFFF;
	// Choose Timer2 as Alternative Function for pin 5 LED
	GPIOA->AFR[0] |= (1 << 20);
	// enable TIM2 clock
	RCC->APB1ENR1 |= (1 << 0);

	// fCK_PSC / (PSC[15:0] + 1)
	// 4 MHz / n + 1 =  timer clock speed
	TIM2->PSC = 0; //TIM Clock 4MHz

	// set total count
	TIM2->ARR = PWMCOUNT; // ARR = F_timer/F_PWM
	// set duty cycle on channel 1
	TIM2->CCR1 = 0;

	// enable channel 1 in capture/compare register
	// set oc1 mode as pwm (0b110 or 0x6 in bits 6-4)
	TIM2->CCMR1 |= (0x6 << 4);
	// enable oc1 preload bit 3
	TIM2->CCMR1 |= (1 << 3);
	// enable capture/compare ch1 output
	TIM2->CCER |= (1 << 0);

	// enable SYSCFG clock
	RCC->APB2ENR |= 0x1;
	// Writing a 0b0010 to pin13 location ties PC13 to EXT4
	SYSCFG->EXTICR[3] |= 0x20; // Write 0002 to map PC13 to EXTI4
	// Choose either rising edge trigger (RTSR1) or falling edge trigger (FTSR1)
	EXTI->RTSR1 |= 0x2000;   // Enable rising edge trigger on EXTI4
	// Mask the used external interrupt numbers.
	EXTI->IMR1 |= 0x2000;    // Mask EXTI4
	// Set Priority for each interrupt request
	NVIC->IP[EXTI15_10_IRQn] = 0x10; // Priority level 1
	// enable EXT0 IRQ from NVIC
	NVIC_EnableIRQ(EXTI15_10_IRQn);

	// Enable Timer 2 module (CEN, bit0)
	TIM2->CR1 |= (1 << 0);

	while(1)
	{

	}

	__asm__("NOP"); // Assembly inline can be used if needed
	return 0;
}
