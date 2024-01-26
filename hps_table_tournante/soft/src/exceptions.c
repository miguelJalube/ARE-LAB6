/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : execptions.c
 * Author               : Anthony Convers
 * Date                 : 27.10.2022
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: defines exception vectors for the A9 processor
 *        provides code that sets the IRQ mode stack, and that dis/enables interrupts
 *        provides code that initializes the generic interrupt controller
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Engineer      Comments
 * 0.0    27.10.2022  ACS           Initial version.
 *
*****************************************************************************************/
#include <stdint.h>

#include "address_map_arm.h"
#include "int_defines.h"
#include "exceptions.h"

/* This file:
 * 1. defines exception vectors for the A9 processor
 * 2. provides code that sets the IRQ mode stack, and that dis/enables interrupts
 * 3. provides code that initializes the generic interrupt controller
*/
void fpga_ISR(void);

// Define the IRQ exception handler
void __attribute__ ((interrupt)) __cs3_isr_irq (void)
{

	// Read CPU Interface registers to determine which peripheral has caused an interrupt 
	uint32_t interrupt_ID = *((volatile uint32_t *)0xFFFEC10C);
	
	// Handle the interrupt if it comes from the fpga
	if (interrupt_ID == FPGA_IRQ0)
		fpga_ISR();
	else
		while(1);

	// Clear interrupt from the CPU Interface
	*((volatile uint32_t *)0xFFFEC110) = interrupt_ID;
    
	return;
} 

// Define the remaining exception handlers
void __attribute__ ((interrupt)) __cs3_reset (void)
{
    while(1);
}

void __attribute__ ((interrupt)) __cs3_isr_undef (void)
{
    while(1);
}

void __attribute__ ((interrupt)) __cs3_isr_swi (void)
{
    while(1);
}

void __attribute__ ((interrupt)) __cs3_isr_pabort (void)
{
    while(1);
}

void __attribute__ ((interrupt)) __cs3_isr_dabort (void)
{
    while(1);
}

void __attribute__ ((interrupt)) __cs3_isr_fiq (void)
{
    while(1);
}

/* 
 * Initialize the banked stack pointer register for IRQ mode
*/
void set_A9_IRQ_stack(void)
{
	uint32_t stack, mode;
	stack = A9_ONCHIP_END - 7;		// top of A9 onchip memory, aligned to 8 bytes
	/* change processor to IRQ mode with interrupts disabled */
	mode = INT_DISABLE | IRQ_MODE;
	asm("msr cpsr, %[ps]" : : [ps] "r" (mode));
	/* set banked stack pointer */
	asm("mov sp, %[ps]" : : [ps] "r" (stack));

	/* go back to SVC mode before executing subroutine return! */
	mode = INT_DISABLE | SVC_MODE;
	asm("msr cpsr, %[ps]" : : [ps] "r" (mode));
}

/* 
 * Turn on interrupts in the ARM processor
*/
void enable_A9_interrupts(void)
{
	uint32_t status = SVC_MODE | INT_ENABLE;
	asm("msr cpsr, %[ps]" : : [ps]"r"(status));
}

void config_interrupt(uint32_t n, uint32_t cpu_target){
	// Configure the Set-Enable Register
	// Offset is int(n°/32) * 4
	// Index is n mod 32
	uint32_t reg_offset, index, value, address;

	reg_offset = (n >> 3) & 0xfffffffc;
	index = n & 0x1f;
	value = 0x1 << index;
	address = ICDISER + reg_offset;
	*(volatile uint32_t *)address |= value;

	// Configure the Interrupt cpu target
	reg_offset = (n & 0xfffffffc);
	index = n & 0x3;
	address = ICDIPTR + reg_offset + index;
	*(volatile uint8_t *)address = (uint8_t)cpu_target;
}

/* 
 * Configure the Generic Interrupt Controller (GIC)
*/
void config_GIC(void)
{
	/***********
	 * TO DO
	 **********/
	// GIC int n° is 72 CPU0
	config_interrupt(FPGA_IRQ0, CPU_INTERFACE_0);

	// Set Interrupt Priority Mask Register (ICCPMR). Enable interrupts of all
	// priorities
	*((int *) ICCPMR) = 0xFFFF;

	// Set CPU Interface Control Register (ICCICR). Enable signaling of
	// interrupts
	*((int *) ICCICR) = 1;

	// Configure the Distributor Control Register (ICDDCR) to send pending
	// interrupts to CPUs
	*((int *) ICDDCR) = 1;

}
