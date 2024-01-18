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
#define HEX_03_OFFSET       0x10
#define HEX_45_OFFSET       0x14
#define RESERVED1_OFFSET    0x18
#define RESERVED2_OFFSET    0x1C
#define RESERVED3_OFFSET    0x20

#define MASK_BUTTON         0xf
#define MASK_SWITCH         0x3ff
#define MASK_LED            0x3ff

#define ITF_REG(_x_) *(volatile uint32_t *)(AXI_LW_HPS_FPGA_BASE_ADD + INTERFACE_OFFSET + _x_)

//=================================


// Define bits usage
#define SWITCHS_BITS        0x000003FF
#define LEDS_BITS           0x000FFC00
#define KEYS_BITS           0x00F00000
#define SEG7_BITS           0x0FFFFFFF
#define SEG7_BITS_HEX       0x7F

#define SWITCHS_OFFSET      0
#define LEDS_OFFSET         10
#define KEY_OFFSET          20
#define INT_MASK_OFFSET     2
#define EDGE_CAPT_OFFSET    3

#define HEX0_OFFSET         0
#define HEX1_OFFSET         7
#define HEX2_OFFSET         14
#define HEX3_OFFSET         28

//***********************************//
//****** Global usage function ******//

// Switchs_read function : Read the switchs value
// Parameter : None
// Return : Value of all Switchs (SW9 to SW0)
uint32_t Switchs_read(void);

// Leds_write function : Write a value to all Leds (LED9 to LED0)
// Parameter : "value"= data to be applied to all Leds
// Return : None
void Leds_write(uint32_t value);

// Leds_set function : Set to ON some or all Leds (LED9 to LED0)
// Parameter : "maskleds"= Leds selected to apply a set (maximum 0x3FF)
// Return : None
void Leds_set(uint32_t maskleds);

// Leds_clear function : Clear to OFF some or all Leds (LED9 to LED0)
// Parameter : "maskleds"= Leds selected to apply a clear (maximum 0x3FF)
// Return : None
void Leds_clear(uint32_t maskleds);

// Leds_toggle function : Toggle the curent value of some or all Leds (LED9 to LED0)
// Parameter : "maskleds"= Leds selected to apply a toggle (maximum 0x3FF)
// Return : None
void Leds_toggle(uint32_t maskleds);

// Key_read function : Read one Key status, pressed or not (KEY0 or KEY1 or KEY2 or KEY3)
// Parameter : "key_number"= select the key number to read, from 0 to 3
// Return : True(1) if key is pressed, and False(0) if key is not pressed
bool Key_read(int key_number);

// Seg7_write function : Write digit segment value to one 7-segments display (HEX0 or HEX1 or HEX2 or HEX3)
// Parameter : "seg7_number"= select the 7-segments number, from 0 to 3
// Parameter : "value"= digit segment value to be applied on the selected 7-segments (maximum 0x7F to switch ON all segments)
// Return : None
void Seg7_write(int seg7_number, uint32_t value);

// Seg7_write_hex function : Write an Hexadecimal value to one 7-segments display (HEX0 or HEX1 or HEX2 or HEX3)
// Parameter : "seg7_number"= select the 7-segments number, from 0 to 3
// Parameter : "value"= Hexadecimal value to be display on the selected 7-segments, form 0x0 to 0xF
// Return : None
void Seg7_write_hex(int seg7_number, uint32_t value);

