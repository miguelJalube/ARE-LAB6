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

/**
 *  Bits       |        R |        W |
 * ------------|----------|----------|
 *  [31 .. 16] |        0 | not used |
 *  [15 ..  0] |  val_pos |  val_pos |
 * ------------|----------|----------|
 */
#define POSITION_OFFSET    0x18

/**
 *  Bits       |        R |        W |
 * ------------|----------|----------|
 *  [31 ..  4] |        0 | not used |
 *  [ 3 ..  2] |    speed |    speed |
 *         [1] |      dir |      dir |
 *         [0] |   en_pap |   en_pap |
 * ------------|----------|----------|
 */
#define TABLE_CMD_OFFSET    0x1C

/**
 *  Bits       |        R |        W |
 * ------------|----------|----------|
 *  [31 ..  2] |        0 | not used |
 *         [1] | not used | run_init |
 *         [0] | cal_busy |  run_cal |
 * ------------|----------|----------|
 */
#define TABLE_CAL_INIT_OFFSET    0x20

#define MOVEMENT_OFFSET 		 0x24
#define TABLE_MOVE_OFFSET		 0x28
#define IRQ_LIMIT_OFFSET         0x2c

#define MASK_BUTTON         0xf
#define MASK_SWITCH         0x3ff
#define MASK_LED            0x3ff

// Define bits usage
#define POS_BITS            0xffff
#define SPEED_BITS          0x0c
#define DIR_BITS            0x02
#define EN_PAP_BITS         0x01
#define INIT_BITS           0x02
#define CAL_BITS            0x01
#define DEPL_BITS			0xffff
#define MOVE_BITS			0x1
#define LIMIT_BITS			0x3
#define ACK_BIT				0x1

#define ITF_REG(_x_) *(volatile uint32_t *)(AXI_LW_HPS_FPGA_BASE_ADD + INTERFACE_OFFSET + _x_)

// ========================== DE1-SoC I/O ==========================

// get_constant function : Read the constant id value
// Return Value of the constant id
uint32_t get_constant(void);

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
void Seg7_write(int seg7_number, uint8_t value);

// Seg7_write_hex function : Write an Hexadecimal value to one 7-segments display (HEX0 or HEX1 or HEX2 or HEX3)
// Parameter : "seg7_number"= select the 7-segments number, from 0 to 3
// Parameter : "value"= Hexadecimal value to be display on the selected 7-segments, form 0x0 to 0xF
// Return : None
void Seg7_write_hex(int seg7_number, uint32_t value);

// ========================== TURNING TABLE INTERFACE ==========================

// Pos_read function : Reads the position of the disk
// Return : Current disk position value
uint32_t Pos_read();

// Pos_write function : Writes the position of the disk
// Parameter : "new_pos"= New position value to be applied to the disk
void Pos_write(uint32_t new_pos);

// Speed_read function : Reads the speed of the disk
// Return : Current disk speed value
uint32_t Speed_read();

// Speed_write function : Writes the speed of the disk
// Parameter : "new_speed"= New speed value to be applied to the disk
void Speed_write(uint32_t new_speed);

// Dir_read function : Reads the direction of the disk
// Return : Current disk direction value
uint32_t Dir_read();

// Dir_write function : Writes the direction of the disk
// Parameter : "new_dir"= New direction value to be applied to the disk
void Dir_write(uint32_t new_dir);

// En_pap_read function : Reads the step by step motor status
// Return : 1 for enable, 0 for disable
uint32_t En_pap_read();

// En_pap_write function : Writes the step by step motor status
// Parameter : "new_en_pap"= New step by step motor status value to be applied
void En_pap_write(uint32_t new_en_pap);

// busy_read function : Reads the calibration busy status
// Return : 1 for busy, 0 for not busy
uint32_t Busy_read();

// Run_cal_write function : Launch the cal_init mss
void Cal_write();

// Move_write function : write target position for auto move
// Parameter : depl => targeted position
void Move_write(uint32_t depl);

// Move_read function : read target position for auto move
// Return : get targeted position
uint32_t Move_read(void);

// Move_run function : launch the auto move mss
void Move_run();

// Move_busy_read function : read auto move status
// Return : 1 if interface is currently doing an auto move
uint32_t Move_busy_read(void);

// Limit_read function : read which limit has triggered
// Return : 0x2 => max limit 0x1 => min limit 0x0 => no limit
uint32_t Limit_read(void);

// Write_ack function : acknoledge irq
void Write_ack();

#endif
