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

int __auto_semihosting;

// Update pressed keys
void update_pressed(bool *pressed, size_t size){
    int i;
    for(i = 0; i< size; i++){
        pressed[i] = Key_read(i);
    }
}

int main(void){
    //set_A9_IRQ_stack();

    // Config gic
    //config_GIC();

    //enable_A9_interrupts();

    uart_init();

    // Display ID constant
    printf("Laboratoire: Commande Table tournante \n");
    printf("[main] ID : 				%#X\n", (unsigned)ID_ADDR);
    printf("[main] IT constant ID : 	%#X\n", get_constant());

    /* Set Default values on LEDS and hex display */
    Leds_set(0x0);

    Leds_set(0xFF);

    /* set our base mode based on switches */
    uint32_t switches;
    uint32_t keys_value, old_keys_value;

    // Which key is pressed
    bool pressed[N_KEYS] = {false, false, false, false};

    // Edge detection for keys
    bool pressed_edge[N_KEYS] = {false, false, false, false};
    
    // Main program loop
    while(1){
        // Update key pressed state 2
        update_pressed(pressed_edge, N_KEYS);

        switches = Switchs_read();

        if(!pressed[0] && pressed_edge[0]){
            #ifdef DEBUG
                printf("[main] KEY0 pressed\n");
            #endif
            
            if((switches && 0x001) != 0){
                // If SW0 = 1

            }else{
                // If SW0 = 0

            }
        }
        pressed[0] = pressed_edge[0];

        if(!pressed[1] && pressed_edge[1]){
            #ifdef DEBUG
                printf("[main] KEY1 pressed\n");
            #endif

            // Key 1 pressed
        
        }
        pressed[1] = pressed_edge[1];

        if(!pressed[2] && pressed_edge[2]){
            #ifdef DEBUG
                printf("[main] KEY2 pressed\n");
            #endif

            // Key 2 pressed

        }
        pressed[2] = pressed_edge[2];

        if(!pressed[3] && pressed_edge[3]){
            #ifdef DEBUG
                printf("[main] KEY3 pressed\n");
            #endif
            // Key 3 pressed
            
        }
        pressed[3] = pressed_edge[3];
    }
}
