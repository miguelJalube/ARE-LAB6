/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : execptions.h
 * Author               : Miguel Jalube, Bastien Pillonel
 * Date                 : 12.01.2024
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: defines prototypes for the IRQ exception handlers
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Engineer      Comments
 * 0.0    24.11.2023  MJ           Initial version.
 * 1.0    12.01.2024  MJ           Version for lab6.
 *
*****************************************************************************************/
#define FPGA_IRQ0 	72

#define CPU_INTERFACE_0		0x1

#define ICCPMR 				0xFFFEC104
#define ICCICR				0xFFFEC100
#define ICDDCR				0xFFFED000
#define ICDISER				0xfffed100
#define ICDIPTR				0xFFFED800

// Define the IRQ exception handler
void __attribute__ ((interrupt)) __cs3_isr_irq (void);

// Define the remaining exception handlers
void __attribute__ ((interrupt)) __cs3_reset (void);

void __attribute__ ((interrupt)) __cs3_isr_undef (void);

void __attribute__ ((interrupt)) __cs3_isr_swi (void);

void __attribute__ ((interrupt)) __cs3_isr_pabort (void);

void __attribute__ ((interrupt)) __cs3_isr_dabort (void);

void __attribute__ ((interrupt)) __cs3_isr_fiq (void);

/* 
 * Initialize the banked stack pointer register for IRQ mode
*/
void set_A9_IRQ_stack(void);

/* 
 * Turn on interrupts in the ARM processor
*/
void enable_A9_interrupts(void);

/* 
 * Configure the Generic Interrupt Controller (GIC)
*/
void config_GIC(void);

void config_interrupt(uint32_t n, uint32_t cpu_target);

void hps_timer_ISR(void);
