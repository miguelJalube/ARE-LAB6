/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : uart_controller.c
 * Author               : Miguel Jalube, Bastien Pillonel
 * Date                 : 12.01.2024
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: functions for the uart controller
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Engineer      Comments
 * 0.0    12.01.2024  MJ            Initial version.
 *
*****************************************************************************************/

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include "uart_controller.h"

int uart_init(){
    uint32_t lcr = 0x00;
    uint32_t fcr = 0x00;
    uint32_t mcr = 0x00;

    // Set baudrate to 9600
    lcr |= 0x80;

    // Set data bits to 8
    lcr |= 0x03;
    
    // Enable FIFO
    fcr |= 0x01;

    // Enable baurate divisor latch regs
    UART0_REG(LCR_OFFSET) = lcr;

    // Set baudrate divisor
    UART0_REG(RBR_THR_DLL_OFFSET) = (uint32_t)UART0_DIVISOR & 0xFF;
    UART0_REG(IER_DLH_OFFSET) = ((uint32_t)UART0_DIVISOR >> 8) & 0xFF;

    UART0_REG(IIR_FCR_OFFSET) = fcr;

    // Disbles auto flow control
    UART0_REG(MCR_OFFSET) = mcr;

    // Disable baudrate divisor latch regs
    lcr &= ~0x80;
    UART0_REG(LCR_OFFSET) = lcr;
}

int uart_send(char * string, size_t size){
    for (size_t i = 0; i < size; i++)
    {
        // Wait until THR is empty
        UART0_REG(RBR_THR_DLL_OFFSET) = string[i] & 0xFF;
    }
    return 0;
}

int uart_receive(char **string, size_t size){
    return 0;
}