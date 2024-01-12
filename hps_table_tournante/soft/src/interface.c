#include "interface.h"

// Swicths_init function : Initialize all Switchs in PIO core (SW9 to SW0)
void Switchs_init(void){
    PIO0_REG(DIRECTION) &= ~SWITCHS_BITS;
}

// Leds_init function : Initialize all Leds in PIO core (LED9 to LED0)
void Leds_init(void){
    // Direction offset 4 set to 1
    PIO0_REG(DIRECTION) |= LEDS_BITS;
}


// Keys_init function : Initialize all Keys in PIO core (KEY3 to KEY0)
void Keys_init(void){
    // Direction offset 4 set to 0
    PIO0_REG(DIRECTION) &= ~KEYS_BITS;
}

// Segs7_init function : Initialize all 7-segments display in PIO core (HEX3 to HEX0)
void Segs7_init(void){
    // Direction offset 4 set to 0
    PIO1_REG(DIRECTION) |= SEG7_BITS;
}

uint32_t Switchs_read(void){
    // Read data register and mask with SWITCHS_BITS
    uint32_t value = PIO0_REG(DATA) & SWITCHS_BITS;
    return value;
}

void Leds_write(uint32_t value){
    #ifdef DEBUG_PIO
    printf("value : %#X\n", value);
    #endif
    // Write led data register and mask with LEDS_BITS
    PIO0_REG(DATA) = LEDS_BITS & (value << LEDS_OFFSET);
}
void Leds_set(uint32_t maskleds){
    #ifdef DEBUG_PIO
    printf("Value to set : %#X\n", ((maskleds << LEDS_OFFSET) & LEDS_BITS));
    #endif

    // Write led data register and mask with LEDS_BITS but keep the other values
    PIO0_REG(DATA) |= ((maskleds << LEDS_OFFSET) & LEDS_BITS);
}

void Leds_clear(uint32_t maskleds){
    #ifdef DEBUG_PIO
    printf("Bits to clear : %#X\n", (~(maskleds << 10) & LEDS_BITS));
    #endif

    // Set to 0 the bits to clear according to maskleds
    PIO0_REG(DATA) &= (~(maskleds << LEDS_OFFSET) & LEDS_BITS);
}

void Leds_toggle(uint32_t maskleds){
    #ifdef DEBUG_PIO
    printf("Bits to toggle : %#X\n", (maskleds << LEDS_OFFSET));
    #endif

    // Toggle the bits according to maskleds
    PIO0_REG(DATA) ^= (maskleds << 10);
}

bool Key_read(int key_number){
    if(key_number < 0 || key_number > 3){
        printf("Error : Key_read : key_number must be between 0 and 3\n");
        return;
    }
    // Read data register and mask with KEYS_BITS
    uint32_t value = (PIO0_REG(DATA) & KEYS_BITS) >> KEY_OFFSET;

    // Shift the mask to the key_number position
    uint32_t mask = 1 << key_number;

    // Return true if the key is pressed
    return !(bool)(value & mask);
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

void Seg7_write(int seg7_number, uint32_t value){
    if ((seg7_number < 0) || (seg7_number > 3)) {
        printf("Error : Seg7_write_hex : seg7_number must be between 0 and 3\n");
        return;
    }
    // Mask the 7-segments display to write
	uint32_t hex_mask = SEG7_BITS_HEX << (seg7_number * 7);

    // Get the value to write and mask it
	uint32_t res = ~(value << (seg7_number * 7)) & hex_mask;

    // Set to 0 the 7-segments display to write
	uint32_t current = PIO1_REG(DATA) & ~hex_mask;

    #ifdef DEBUG_PIO
    printf("Res or current : %#X\n", res | current);
    #endif

    // Write the value to the 7-segments display keeping the other values in the register
	PIO1_REG(DATA) = res | current;
}

void Seg7_write_hex(int seg7_number, uint32_t value){
    Seg7_write(seg7_number, seg7_val(value));
}