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

#define ID_ADDR             AXI_LW_REG(0)
#define N_HEX               4

int __auto_semihosting;

int main(void){
    set_A9_IRQ_stack();

    // Config gic
    config_GIC();

    enable_A9_interrupts();

    // Initialize leds, switches, keys and 7-segments
    Leds_init();
    Switchs_init();
    Keys_init();
    Segs7_init();

    // Turn off al leds
    Leds_clear(0x3ff);

    // Seg7 0 to 3 display 0
    for (size_t i = 0; i < N_HEX; i++)
    {
        Seg7_write_hex(i, 0);
    }

    // Display ID constant
    printf("[main] ID : %#X\n", (unsigned)ID_ADDR);

    printf("Laboratoire: Commande Table tournante \n");
    
    // TO BE COMPLETE

}
