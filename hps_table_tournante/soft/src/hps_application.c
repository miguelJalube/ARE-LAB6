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

#define ID_ADDR             AXI_LW_REG(0)
#define N_HEX               4

int __auto_semihosting;

int main(void){
    //set_A9_IRQ_stack();

    // Config gic
    //config_GIC();

    //enable_A9_interrupts();

    // Display ID constant
    printf("Laboratoire: Commande Table tournante \n");
    printf("[main] ID : %#X\n", (unsigned)ID_ADDR);
    printf("IT constant ID : %#X\n", get_constant());
    
    // TO BE COMPLETE

}
