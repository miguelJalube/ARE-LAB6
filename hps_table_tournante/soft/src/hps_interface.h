/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : hps_interface.h
 * Author               : Bastien Pillonel
 * Date                 : 27.07.2022
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: Header file for bus AXI lightweight HPS to FPGA defines definition
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 * 0.0    1.11.2023   BPIL          Initial version.
 *
*****************************************************************************************/
#ifndef HPS_INTERFACE
#define HPS_INTERFACE

#include "axi_lw.h"
#include <stdbool.h>

#define INTERFACE_OFFSET    0x10000

#define CONSTANT_ID_OFFSET  0x0
#define BUTTON_OFFSET       0x4
#define SWITCHS_OFFSET      0x8
#define LEDS_OFFSET         0xC

#define SPEED_MASK 		0x3
#define SPEED_POS		8

#define MODE_BITS		0x80
#define RELIABLE_BIT	0x1

#define STATUS_OFFSET       0x10
#define GEN_CTRL_OFFSET     0x14
#define RELIABLE_OFFSET      0x18
#define CAPTURE_OFFSET       0x1C
#define NBRA_OFFSET         0x20
#define NBRB_OFFSET         0x24
#define NBRC_OFFSET         0x28
#define NBRD_OFFSET         0x2c
#define NBR_CODE_POS		22
#define NBR_CODE_MASK		0x3

#define MASK_BUTTON         0xf
#define MASK_SWITCH         0x3ff
#define MASK_LED            0x3ff
#define MASK_STATUS         0x3
#define MASK_NEW_NBR        0x10
#define MASK_INIT_NBR       0x1
#define MASK_MODE_GEN       0x10
#define MASK_DELAY_GEN      0x3
#define MASK_VAL_NBR        0x3fffff
#define MASK_CODE_NBR       0xc00000
#define MASK_CAPTURE		0x1

#define MASK_RELIABLE_PRESENCE  (1 << 1)
#define MASK_CAPTURE_STATUS     (1 << 0)

#define MODE_MANU		0
#define MODE_AUTO		1

#define NBR_A_CODE 		0b00
#define NBR_B_CODE 		0b01
#define NBR_C_CODE 		0b10
#define NBR_D_CODE 		0b11

#define ITF_REG(_x_) *(volatile uint32_t *)(AXI_LW_HPS_FPGA_BASE_ADD + INTERFACE_OFFSET + _x_)

// ===================================== INTERFACE I/O ACCESS =====================================
/**
* @brief Read the constant id value
* @return Value of the constant id
*/
uint32_t get_constant(void);

// ======================================== DE1 I/O ACCESS ========================================
/**
* @brief Read the key button value
* @return Value of the key buttons
*/
uint32_t get_buttons(void);

/**
* @brief Get the switch value
* @return Value of the de1 switch 
*/
uint32_t get_switchs(void);

/**
* @brief Get the leds values
* @return Value of the de1 leds
*/
uint32_t get_leds(void);

/**
* @brief Set the de1 leds state
* @param maskled Value write on the DE1 leds
*/
void set_leds(uint32_t maskled);

// ======================================== GEN I/O ACCESS ========================================

/**
* @brief Get the status value
* @return Value of the status
*/
uint32_t get_status(void);

/**
* @brief Set a pulse signal to indicate we want to generate a new number
*/
void set_new_nbr(void);

/**
* @brief Set the initialization state of the number
* @param state The initialization state
*/
void set_init_nbr(bool state);

/**
* @brief Get the generation mode state
* @return The generation mode state
*/
bool get_mode_gen(void);

/**
* @brief Get the delay for number generation
* @return The delay value
*/
uint32_t get_delay_gen(void);

/**
* @brief Set the generation mode state
* @param mode The generation mode state to set
*/
void set_mode_gen(bool mode);

/**
* @brief Set the delay for number generation
* @param delay The delay value to set
*/
void set_delay_gen(uint32_t delay);

/**
* @brief Get the number corresponding to the given code
* @param code_nbr The code for the number
* @return The number corresponding to the code
*/
uint32_t get_nbr(uint32_t code_nbr);

/**
* @brief Set the interface on reliable mode or not
* @param True => reliable, False => not reliable
*/
void set_reliable(bool state);

/**
* @brief Get the interface state (reliable or not)
* @param True => reliable, False => not reliable
*/
bool get_reliable(void);

/**
* @brief Set the interface on reliable mode or not
* @param True => reliable, False => not reliable
*/
void set_capture(bool state);

/**
* @brief Get the interface capture state
* @param True => reliable, False => not reliable
*/
bool get_capture(void);

#endif
