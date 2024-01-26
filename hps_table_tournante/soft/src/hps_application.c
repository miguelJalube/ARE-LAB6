/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : hps_application.c
 * Author               : 
 * Date                 : 
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: Conception d'une interface pour la commande de la table tournante avec la carte DE1-SoC
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 * 
 *
*****************************************************************************************/
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include "axi_lw.h"
#include "exceptions.h"
#include "hps_interface.h"
#include "uart_controller.h"

#define DEBUG 1

#define ID_ADDR             AXI_LW_REG(0)
#define N_HEX               6
#define N_KEYS              4
#define SWITCH_CAL_INIT		0x1
#define SWITCH_MOVE			0x2
#define SWITCH_DIR			0x4
#define SWITCH_SPEED		0x18
#define SWITCH_AUTO_DEPL    0x1e0
#define ARROW_POS			30000

int __auto_semihosting;

static const char message[] = "[KEY0] => Init or calibration sequence\r\n[KEY1] => Enable motor (Auto or manual)\r\n[KEY2] => Show initial position\r\n[KEY3] => not used\r\n[SW0] => 0 for calibration, 1 for initialisation\r\n[SW1] => 0 for manual, 1 for automatic\r\n[SW2] => 0 clockwise, 1 counter-clockwise\r\n[SW3-4] => speed value : 00 for min speed, 11 for max speed\r\n[SW5-8] => step number for automatic mode\r\n[SW9] => not used\r\n[LED0] => calibration done\r\n[LED1] => auto-move in progress\r\n[LED2] => manual-move in progress\r\n[LED3] => limit exceeded\r\n[LED4-6] => not used\r\n[LED7] => IRQ\r\n[7SEG] => Limits\r\n";

void fpga_ISR(void){
	Leds_toggle(1 << 7);
	uint32_t limit = Limit_read();
	// Reset en_pap register the motor is stopped by the interface
	En_pap_write(0);
	// Calculate destination pos
	uint16_t current_pos = Pos_read();
	uint16_t current_dir = (limit == 0x2 ? 1 : 0);
	uint16_t target_pos = current_pos + (current_dir ? -1000 : 1000);
	Move_write(target_pos);
	// Set table for automatic move until arrow pos is reached
	Speed_write(2);
	Dir_write(current_dir);
	Leds_set(1 << 3);
	if(!current_dir){
		uart_send_msg("Minimum reached\n\r");
		Seg7_write(5, 0x48);
	}
	else{
		uart_send_msg("Max reached\n\r");
		Seg7_write(5, 0x41);
	}

	// Launch auto move
	Move_run();
	// Ack
	Write_ack();
}

// Update pressed keys
void update_pressed(bool *pressed, size_t size){
    int i;
    for(i = 0; i< size; i++){
        pressed[i] = Key_read(i);
    }
}

void display_pos(uint32_t pos){
	uint32_t rest;
	for(int i = 0; i < N_HEX - 1; ++i){
		rest = pos % 10;
		pos /= 10;

		Seg7_write_hex(i, rest);
	}
}

void display_current_pos(){
	display_pos(Pos_read());
}

int main(void){
    // Variable declaration
    uint32_t switches;

    uint16_t current_pos = 0;
    uint16_t current_dir = 0;
    uint16_t target_pos = 0;
    uint16_t init_pos = 0;
    uint32_t auto_steps = 0;
    uint32_t cnt_auto = 0;

    bool pressed[N_KEYS] = {false, false, false, false};
    bool pressed_edge[N_KEYS] = {false, false, false, false};

    // Initialize irq
    set_A9_IRQ_stack();

    // Config gic
    config_GIC();

    enable_A9_interrupts();

    // Initialize uart
    uart_init();

    // Init turning table
	Speed_write(0);
	Dir_write(0);
	En_pap_write(0);
	Pos_write(35000);

	// Set Default values on LEDS and hex display
	Leds_clear(MASK_LED);

	for(int i = 0; i < N_HEX; ++i){
		Seg7_write(i, 0);
	}

    // Display ID constant
    printf("Laboratoire: Commande Table tournante \n");
    printf("[main] ID : 				%#X\n", (unsigned)ID_ADDR);
    printf("[main] IT constant ID : 	%#X\n", get_constant());

    uart_send_msg(message);

    // Main program loop
    while(1){
    	// Default actions when system in idle state
        update_pressed(pressed_edge, N_KEYS);
        switches = Switchs_read();
        display_current_pos();


        // ========================== CAL & INIT ==========================
        if(!pressed[0] && pressed_edge[0]){
            #ifdef DEBUG
                printf("[main] KEY0 pressed\n");
            #endif
            
            // Begin calibration sequence
            if(!(switches & SWITCH_CAL_INIT)){
                // Write msg to uart
                uart_send_msg("Starting calibration sequence\n\r");

            	// Preset before launching the calibration unitl idx is reached
                Pos_write(ARROW_POS);
                display_current_pos();
                Speed_write(0);
                Dir_write(1);

                // Let the disc turn until it reaches idx
                Cal_write();
                while(Busy_read()){
                	display_current_pos();
                }

                // Save position as init_pos
                init_pos = Pos_read();

                // Calculate destination pos
                Move_write(ARROW_POS);

                // Set table for automatic move until arrow pos is reached
                Speed_write((Switchs_read() & SWITCH_SPEED) >> 3);
                Dir_write(0);

                // Launch automatic move
                Move_run();
                while(Move_busy_read()){
                	display_current_pos();
                }

                Leds_set(1 << 0);
                // Write msg to uart
                uart_send_msg("Ending calibration sequence\n\r");
            }

            // Begin initialisation sequence
            else{
                // Write msg to uart
                uart_send_msg("Starting initialisation sequence\n\r");

            	// Preset before launching the initialisation unitl idx is reached
            	Speed_write(0);
            	Dir_write(1);

            	// Let the disc go to the idx
            	Init_write();
            	while(Busy_read()){
            		display_current_pos();
            	}

            	// Set the position to init_pos previously saved
            	Pos_write(init_pos);

            	// Calculate destination pos
            	Move_write(ARROW_POS);


                // Set table for automatic move until arrow pos is reached
            	Speed_write((Switchs_read() & SWITCH_SPEED) >> 3);
            	Dir_write(0);

            	// Launch auto move
            	Move_run();
            	while(Move_busy_read()){
            		display_current_pos();
            	}
                // Write msg to uart
                uart_send_msg("Ending calibration sequence\n\r");
            }
        }
        pressed[0] = pressed_edge[0];

        // ========================== MOVEMENT ==========================
        if(!pressed[1] && pressed_edge[1]){
            #ifdef DEBUG
                printf("[main] KEY1 pressed\n");
            #endif

            // Manual depl
            if(!(switches & SWITCH_MOVE)){
            	Dir_write((switches & SWITCH_DIR) >> 2);
            	Speed_write((switches & SWITCH_SPEED) >> 3);
            	En_pap_write(1);
            	Leds_set(1 << 2);
            	while(!pressed[1] && pressed_edge[1]){
            		update_pressed(pressed_edge, N_KEYS);
            		display_current_pos();
            	}
            	Seg7_write(5, 0);
            	Leds_clear(1 << 2);
            	Leds_clear(1 << 3);
            	En_pap_write(0);
            }
            // Automatic depl
            else{
                
                uart_send_msg("Starting automatic deplacement\n\r");
            	 // Calculate destination pos
            	current_pos = Pos_read();
            	current_dir = (switches & SWITCH_DIR) >> 2;
            	auto_steps = ((switches & SWITCH_AUTO_DEPL) >> 5) * 1000;
            	target_pos = current_pos + (current_dir ? -auto_steps : auto_steps);
            	printf("Target pos = %u\n", target_pos);
				Move_write(target_pos);

				// Set table for automatic move until arrow pos is reached
				Dir_write((switches & SWITCH_DIR) >> 2);
				Speed_write((switches & SWITCH_SPEED) >> 3);

				// Launch automatic move
				Move_run();
				Leds_set(1 << 1);
				while(Move_busy_read()){
					display_current_pos();
					cnt_auto++;
					if(cnt_auto == 1000){
						cnt_auto = 0;
						uart_send_msg("1000 step !\n\r");
					}
				}
				Seg7_write(5, 0);
				Leds_clear(1 << 3);
				Leds_clear(1 << 1);
            }
        
        }
        pressed[1] = pressed_edge[1];
        if(!pressed[2] && pressed_edge[2]){
            #ifdef DEBUG
                printf("[main] KEY2 pressed\n");
            #endif
        }
        display_pos(init_pos);
        char format[] = "Initial position : %d\n\r";
        char buffer[30];
        sprintf(buffer, format, init_pos);
        uart_send_msg(buffer);
    }
}
