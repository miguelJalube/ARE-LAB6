/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : hps_interface.c
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
 * 0.1    18.0.2024   MJAL          Adaptation for lab6
 *
*****************************************************************************************/

#include "hps_interface.h"

//#define DEBUG_ITF 1

// ========================== DE1-SoC I/O ==========================

uint32_t get_constant(void){
    return ITF_REG(CONSTANT_ID_OFFSET);
}

uint32_t Switchs_read(void){
    // Read data register and mask with SWITCHS_BITS
    return ITF_REG(SWITCHS_OFFSET);
}

void Leds_write(uint32_t value){
    #ifdef DEBUG_ITF
    printf("value : %#X\n", value);
    #endif
    // Write led data register and mask with LEDS_BITS
    ITF_REG(LEDS_OFFSET) = value;
}
void Leds_set(uint32_t maskleds){
    #ifdef DEBUG_ITF
    printf("Value to set : %#X\n", ((maskleds << LEDS_OFFSET) & MASK_LED));
    #endif

    // Write led data register and mask with LEDS_BITS but keep the other values
    ITF_REG(LEDS_OFFSET) |= maskleds;
}

void Leds_clear(uint32_t maskleds){
    #ifdef DEBUG_ITF
    printf("Bits to clear : %#X\n", (~(maskleds << 10) & MASK_LED));
    #endif

    // Set to 0 the bits to clear according to maskleds
    ITF_REG(LEDS_OFFSET) &= ~(maskleds);
}

void Leds_toggle(uint32_t maskleds){
    #ifdef DEBUG_ITF
    printf("Bits to toggle : %#X\n", (maskleds << LEDS_OFFSET));
    #endif

    // Toggle the bits according to maskleds
    ITF_REG(LEDS_OFFSET) ^= (maskleds);
}

bool Key_read(int key_number){
    if(key_number < 0 || key_number > 3){
        printf("Error : Key_read : key_number must be between 0 and 3\n");
        return;
    }

    // Return true if the key is pressed
    return !(bool)(ITF_REG(BUTTON_OFFSET) & (1 << key_number));
}

uint32_t seg7_val(uint32_t val){
    uint32_t res = 0x00;
    switch(val){
        case 0:
            res = 0x3F;
            break;
        case 1:
            res = 0x06;
            break;
        case 2:
            res = 0x5B;
            break;
        case 3:
            res = 0x4F;
            break;
        case 4:
            res = 0x66;
            break;
        case 5:
            res = 0x6D;
            break;
        case 6:
            res = 0x7D;
            break;
        case 7:
            res = 0x07;
            break;
        case 8:
            res = 0x7F;
            break;
        case 9:
            res = 0x6F;
            break;
        case 10:
            res = 0x77;
            break;
        case 11:
            res = 0x7C;
            break;
        case 12:
            res = 0x39;
            break;
        case 13:
            res = 0x5E;
            break;
        case 14:
            res = 0x79;
            break;
        case 15:
            res = 0x71;
            break;

        return res;
    }
}

void Seg7_write(int seg7_number, uint8_t value){
    if ((seg7_number < 0) || (seg7_number > 5)) {
        printf("Error : Seg7_write_hex : seg7_number must be between 0 and 5\n");
        return;
    }

    // bits 27 - 21 : HEX3
    // bits 20 - 14 : HEX2
    // bits 13 - 7  : HEX1
    // bits 6  - 0  : HEX0
    uint32_t offset = 0x00;

    if(seg7_number < 4){
        offset = HEX_03_OFFSET;
    }else{
        offset = HEX_45_OFFSET;
        seg7_number -= 4;
    }

    // Mask to write the 7-segments display
    uint32_t hex_mask = 0x7F << (seg7_number * 7); 

    // Get the value to write and mask it
    uint32_t res = value << (seg7_number * 7);

    // Set to 0 the 7-segments display to write
	uint32_t current = ITF_REG(offset) | hex_mask;

    #ifdef DEBUG_ITF
    printf("Res or current : %#X\n", res | current);
    #endif

    // Write the value to the 7-segments display keeping the other values in the register
	ITF_REG(offset) = current & ~res;
}

void Seg7_write_hex(int seg7_number, uint32_t value){
    Seg7_write(seg7_number, seg7_val(value));
}


// ========================== TURNING TABLE INTERFACE ==========================

uint32_t Pos_read(){
    // Read data register and mask with POS_BITS
    uint32_t value = (ITF_REG(POSITION_OFFSET) & POS_BITS);
    return value;
}

void Pos_write(uint32_t value){
    // Write data register and mask with POS_BITS
    ITF_REG(POSITION_OFFSET) = (value & POS_BITS);
}

uint32_t Speed_read(){
    // Read data register and mask with SPEED_BITS
    uint32_t value = (ITF_REG(TABLE_CMD_OFFSET) & SPEED_BITS) >> 2;
    return value;
}

void Speed_write(uint32_t value){
    // Write data register and mask with SPEED_BITS
	ITF_REG(TABLE_CMD_OFFSET) &= ~SPEED_BITS;
    ITF_REG(TABLE_CMD_OFFSET) |= ((value << 2) & SPEED_BITS);
}

uint32_t Dir_read(){
    // Read data register and mask with DIR_BITS
    uint32_t value = (ITF_REG(TABLE_CMD_OFFSET) & DIR_BITS) >> 1;
    return value;
}

void Dir_write(uint32_t value){
    // Write data register and mask with DIR_BITS
	ITF_REG(TABLE_CMD_OFFSET) &= ~DIR_BITS;
    ITF_REG(TABLE_CMD_OFFSET) |= ((value << 1) & DIR_BITS);
}

uint32_t En_pap_read(){
    // Read data register and mask with EN_PAP_BITS
    uint32_t value = (ITF_REG(TABLE_CMD_OFFSET) & EN_PAP_BITS);
    return value;
}

void En_pap_write(uint32_t value){
    // Write data register and mask with EN_PAP_BITS
	ITF_REG(TABLE_CMD_OFFSET) &= ~EN_PAP_BITS;
    ITF_REG(TABLE_CMD_OFFSET) |= (value & EN_PAP_BITS);
}

uint32_t Busy_read(){
    // Read data register and mask with CAL_BUSY_BITS
    uint32_t value = (ITF_REG(TABLE_CAL_INIT_OFFSET) & CAL_BITS);
    return value;
}

void Cal_write(){
    // Write data register and mask with RUN_CAL_BITS
	ITF_REG(TABLE_CAL_INIT_OFFSET) |= CAL_BITS;
    ITF_REG(TABLE_CAL_INIT_OFFSET) &= ~CAL_BITS;
}

void Move_write(uint32_t depl){
	ITF_REG(MOVEMENT_OFFSET) = (depl & DEPL_BITS);
}

uint32_t Move_read(void){
	return (ITF_REG(MOVEMENT_OFFSET) & DEPL_BITS);
}

void Move_run(){
	ITF_REG(TABLE_MOVE_OFFSET) |= MOVE_BITS;
	ITF_REG(TABLE_MOVE_OFFSET) &= ~MOVE_BITS;
}

uint32_t Move_busy_read(void){
	return (ITF_REG(TABLE_MOVE_OFFSET) & MOVE_BITS);
}

uint32_t Limit_read(void){
	return (ITF_REG(IRQ_LIMIT_OFFSET) & LIMIT_BITS);
}

void Write_ack(){
	ITF_REG(IRQ_LIMIT_OFFSET) |= ACK_BIT;
	ITF_REG(IRQ_LIMIT_OFFSET) &= ~ACK_BIT;
}

