#include "xgpio.h"
#include "IP_Central_DCC.h"
#include "xil_io.h"
#include "xparameters.h"
#include <stdint.h>
#include <unistd.h>
#include <stdio.h>


int main(){
    XGpio sw, buttons, led;
    uint32_t databt, datasw;
    uint8_t addr = 0x00;

    //Initaliation des composants
    XGpio_Initialize(&sw     ,XPAR_GPIO_BOUTONS_BASEADDR);
    XGpio_Initialize(&buttons,XPAR_GPIO_BOUTONS_BASEADDR);
    XGpio_Initialize(&led    ,XPAR_GPIO_LED_BASEADDR);
    XGpio_SetDataDirection(&sw     , 1, 1);
    XGpio_SetDataDirection(&buttons, 2, 1);
    XGpio_SetDataDirection(&led    , 1, 0);

    while(1){
        //Lecture du gpio des switch et buttons
        datasw = XGpio_DiscreteRead (&sw     , 1);
        databt = XGpio_DiscreteRead (&buttons, 2);
        if(databt){
            //Gérer les rebonds
            usleep(20000);

            //relecture
            databt = XGpio_DiscreteRead(&buttons, 2);

            // Bouton centrale
            if(databt & 2){
                //Incrémentation de addr
                addr++;
            }

            // Bouton droite
            if(databt & 4){
               //écriture sur le registre IP de IP_CENTRAL_DCC_0 à SLV_REG0
               IP_CENTRAL_DCC_mWriteReg(XPAR_IP_CENTRAL_DCC_0_BASEADDR, IP_CENTRAL_DCC_S00_AXI_SLV_REG0_OFFSET, (addr << 24) | (datasw & 0xFF));
            }

            // Bouton gauche
            if(databt & 1){
                //Décrémentation de addr
                addr--;
            }

            while(XGpio_DiscreteRead(&buttons, 2) != 0) {
            // Ne rien faire, on attend que le doigt se lève
            }

            // Petite pause pour gérer le rebond mécanique au moment de relâcher le bouton
            usleep(20000);
        }
        
        XGpio_DiscreteWrite(&led    , 1, addr);
        

    }
}