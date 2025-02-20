#importonce

#import "macros.asm"

.filenamespace frame_counter

.segment Text0 "Frame Counter"
// Reset frame counter
init__a: {
        lda #0
        sta count + 0
        sta count + 1
        sta count + 2
        rts
}

// update the frame counter
// should be called once per frame
update: {
        :inc_24_bit(count)
        rts
}

.segment ZPCommon "Frame Counter"
.zp {
count:
        .byte $00, $00, $00
}
