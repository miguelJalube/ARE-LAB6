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
 *
*****************************************************************************************/

#include "hps_interface.h"

static uint32_t nbr_offsets[4] = {NBRA_OFFSET, NBRB_OFFSET, NBRC_OFFSET, NBRD_OFFSET};

// ===================================== INTERFACE I/O ACCESS =====================================

uint32_t get_constant(void){
    return ITF_REG(CONSTANT_ID_OFFSET);
}

// ======================================== DE1 I/O ACCESS ========================================

uint32_t get_buttons(void){
    return ITF_REG(BUTTON_OFFSET) & MASK_BUTTON;
}


uint32_t get_switchs(void){
    return (ITF_REG(SWITCHS_OFFSET) & MASK_SWITCH);
}


uint32_t get_leds(void){
    return (ITF_REG(LEDS_OFFSET) & MASK_LED);
}


void set_leds(uint32_t maskled){
    ITF_REG(LEDS_OFFSET) = maskled & MASK_LED;
}

// ======================================== GEN I/O ACCESS ========================================


uint32_t get_status(void){
    return ITF_REG(STATUS_OFFSET) & MASK_STATUS;
}


void set_new_nbr(void){
    ITF_REG(STATUS_OFFSET) |= MASK_NEW_NBR;
    ITF_REG(STATUS_OFFSET) &= ~MASK_NEW_NBR;
}


void set_init_nbr(bool state){
    if(state){
        ITF_REG(STATUS_OFFSET) |= MASK_INIT_NBR;
    }else{
        ITF_REG(STATUS_OFFSET) &= ~MASK_INIT_NBR;
    }
}


bool get_mode_gen(void){
    return ITF_REG(GEN_CTRL_OFFSET) & MASK_MODE_GEN;
}


uint32_t get_delay_gen(void){
    return (ITF_REG(GEN_CTRL_OFFSET) & MASK_DELAY_GEN);
}


void set_mode_gen(bool mode){
    if(mode){
        ITF_REG(GEN_CTRL_OFFSET) |= MASK_MODE_GEN;
    }else{
        ITF_REG(GEN_CTRL_OFFSET) &= ~MASK_MODE_GEN;
    }
}


void set_delay_gen(uint32_t delay){
	uint32_t reg_val = (ITF_REG(GEN_CTRL_OFFSET) & ~MASK_DELAY_GEN) | (delay & MASK_DELAY_GEN);
    ITF_REG(GEN_CTRL_OFFSET) = reg_val;
}


uint32_t get_nbr(uint32_t code_nbr){
    return ITF_REG(nbr_offsets[code_nbr]);
}

void set_reliable(bool state){
	if(state){
		ITF_REG(RELIABLE_OFFSET) |= RELIABLE_BIT;
	}else{
		ITF_REG(RELIABLE_OFFSET) &= ~RELIABLE_BIT;
	}
}

bool get_reliable(void){
	return ITF_REG(RELIABLE_OFFSET) & RELIABLE_BIT;
}

void set_capture(bool state){
	if(state){
		ITF_REG(CAPTURE_OFFSET) |= MASK_CAPTURE;
	}else{
		ITF_REG(CAPTURE_OFFSET) &= ~MASK_CAPTURE;
	}
}

bool get_capture(void){
	return ITF_REG(CAPTURE_OFFSET) & MASK_CAPTURE;
}
