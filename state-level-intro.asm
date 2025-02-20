#importonce

#import "const.asm"

.filenamespace state_level_intro

.segment Text0 "State Level Intro"

enter:
        rts
run:
        lda #STATE_LEVEL_PLAY
        sta main.next_state
        rts

exit:
        rts

.segment ZPUnion
*=ZP_SHARED_BASE "State Level Intro"
.zp {
level_stuff:
        .dword $00000000
}
