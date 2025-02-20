#importonce

#import "const.asm"

.filenamespace state_title_screen

.segment Text0 "State Title Screen"

enter:
  rts

run:
  lda #STATE_LEVEL_INTRO
  sta main.next_state
  rts

exit:
  lda #0
  sta main.game_level
  rts

.segment ZPUnion
*=ZP_SHARED_BASE "State Title Screen"

.zp {
level_stuff:
        .dword $00000000
}
