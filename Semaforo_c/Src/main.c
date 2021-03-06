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

#include "stm32l476xx.h"
#include <stdio.h>
// create a led delay. Just a rough estimate
// for one second delay
int boton=1;
int con=0;
int t;
/*************************************************
* function declarations
*************************************************/
int main(void);
void GPIO_init(void);
void Ext_init(void);
void TIMER_init(void);
void semaforo(void);
/*************************************************
* external interrupt handler
*************************************************/
void TIM2_IRQHandler(void)
{

    // clear interrupt status
    if (TIM2->DIER & 0x01) {
        if (TIM2->SR & 0x01) {
            TIM2->SR &= ~(1U << 0);
        }
    }
		con +=1;
}
void EXTI15_10_IRQHandler(void)
{
	//Check if the interrupt came from exti13
	if(EXTI->PR1 & (1 <<13)) {
			boton=0;
		// Clear pending bit
		EXTI->PR1 = 0x00002000;
	}
}
int main(void)
{
	//Se inicializa las GPIO que se van a usar (Puerto A y C)
	GPIO_init();
	// Se configura la interrupción externa
	Ext_init();
	//Inicializamos el TIMER que marcara el tiempo de la secuencia
	TIMER_init();

	semaforo();
	while(1)
	{

	}

	__asm__("NOP"); // Assembly inline can be used if needed
	return 0;
}

void GPIO_init(void){
	RCC->AHB2ENR |= 0x00000005;
	// Enable GPIOA and GPIOC Peripheral Clock (bit 0 and 2 in AHB2ENR register)
	// Make GPIOA Pin5 as output pin (bits 1:0 in MODER register)
	GPIOA->MODER &= 0xABFFFFFF;		// Clear bits 11, 10 for P5
	GPIOA->MODER &= 0xFFFFF755;		// Write 01 to bits 11, 10 for P5
	GPIOA->ODR &=0x0000;
	// Make GPIOD Pin13 as input pin (bits 27:26 in MODER register)
	GPIOC->MODER &= 0xFFFFFFFF;		// Clear bits 27, 26 for P13
	GPIOC->MODER &= 0xF3FFFFFF;		// Write 00 to bits 27, 26 for P13
}
void Ext_init(void){
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
}
void TIMER_init(void){
    // enable TIM2 clock (bit0)
    RCC->APB1ENR1 |= (1<<0);
    TIM2->PSC = 7999;
    TIM2->ARR = 400;
    // Update Interrupt Enable
    TIM2->DIER |= (1 << 0);
    NVIC_SetPriority(TIM2_IRQn, 2); // Priority level 2
    // enable TIM2 IRQ from NVIC
    NVIC_EnableIRQ(TIM2_IRQn);
    // Enable Timer 2 module (CEN, bit0)
    TIM2->CR1 |= (1 << 0);
}
void semaforo(void){
	enum states {STATE0, STATE1, STATE2, STATE3} current_state;
	int lock=0;
	current_state = STATE0; //set the initial state

	while(1){
		switch(current_state){
			case STATE0:
				if (lock==0){
					t=con;
					lock=1;
					GPIOA->ODR &= 0x00;
					GPIOA->ODR |= (1 << 2);
				}
				if(con>=(t+10)){
						current_state = STATE1;
						lock=0;
				}else{
						current_state = STATE0;

						}
				break;
			case STATE1:
				if (lock==0){
					t=con;
					lock=1;
					GPIOA->ODR |= (1 << 1);
				}
				if(con>=(t+2)){
						current_state = STATE2;
						lock=0;
				}else{
						current_state = STATE1;

			}
				break;
			case STATE2:
				if (lock==0){
					boton=1;
					t=con;
					lock=1;
					GPIOA->ODR &= 0x00;
					GPIOA->ODR |= (1 << 0);
				}
				if(con>=(t+14)){
						current_state = STATE3;
						lock=0;
				}else if(boton==0){
					current_state = STATE3;
					boton=1;
					lock=0;
				}else{
						current_state = STATE2;

			}
				break;
			case STATE3:
				if (lock==0){
					t=con;
					lock=1;
					GPIOA->ODR &= 0x00;
					GPIOA->ODR |= (1 << 1);
				}
				if(con>=(t+3)){
						current_state = STATE0;
						lock=0;
				}else{
						current_state = STATE3;

			}
				break;
		}// switch(current_state)
	} //while(true)


}
