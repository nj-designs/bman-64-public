#importonce

#import "frame-counter.asm"

.filenamespace random


.segment Text0 "Random"
// init random module based on a made up seed
init__a: {
        lda #$55
        sta value + 0
        lda #$87
        sta value + 1
        lda #$EF
        sta value + 2
        lda #$00
        sta value + 3
        rts
}

// Gets next random value.
// Returns in A (X will have previous value)
// Based on https://elite.bbcelite.com/cassette/main/subroutine/dornd.html
get__ax: {
        clc

        lda value
        rol
        tax
        adc value + 2
        sta value
        stx value + 2

        lda value + 1
        tax
        adc value + 3
        sta value + 1
        stx value + 3

        rts
}

.segment ZPCommon "Random"
.zp {
value:
       .dword $00000000
}
