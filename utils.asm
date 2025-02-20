#importonce

.filenamespace utils

.segment Text0 "Utils"
// Clear SCREEN to value in a
clear_screen__x: {
  ldx #250
loop:
  sta SCREEN_BASE +   0 - 1, x
  sta SCREEN_BASE + 250 - 1, x
  sta SCREEN_BASE + 500 - 1, x
  sta SCREEN_BASE + 750 - 1, x
  dex
  bne loop
  rts
}
