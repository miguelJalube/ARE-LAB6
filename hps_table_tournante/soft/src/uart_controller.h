/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : uart_controller.h
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

#define UART0_ADDR          0xFFC02000

// Rx Buffer, Tx Holding, and Divisor Latch Low
#define RBR_THR_DLL_OFFSET  0x00

// Interrupt Enable Register and Divisor Latch High
#define IER_DLH_OFFSET      0x04

// Interrupt Identy Register and FIFO Control Register
#define IIR_FCR_OFFSET      0x08

// Line Control Register
#define LCR_OFFSET          0x0C

// Modem Control Register
#define MCR_OFFSET          0x10

// TX/RX STATUS
#define LSR_OFFSET          0x14


#define UART0_BAUDRATE      9600
#define CLK_FREQ            100000000
#define DIVISOR_BITS        16
#define UART0_DIVISOR       (CLK_FREQ / (UART0_BAUDRATE * DIVISOR_BITS))
#define UART0_DATABITS      8
#define UART0_ENPARTIY      0
#define UART0_FIFO          1

// ACCESS MACROS
#define UART0_REG(_x_)   *(volatile uint32_t *)(UART0_ADDR + _x_) // _x_ is an offset with respect to the base address

/**
 * @brief initialize the uart controller
 * @return 0 if success, -1 if error
*/
int uart_init();

/**
 * @brief send an 8 bit data to PC
 * @param data the data to send
*/
void uart_send(uint8_t data);
