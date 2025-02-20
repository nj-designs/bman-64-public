#importonce

.macro set_int_vector(vector, handler) {
  lda #<handler
  sta vector
  lda #>handler
  sta vector + 1
}

.macro set_spr_ptr__a(spr_num, ptr) {
  lda #ptr
  sta SCREEN_BASE + $03f8 + spr_num
}

.macro set_zp_mem_block__ax(zp_addr, val, len) {
.errorif (zp_addr + len > 255), "Error, zero page wrap around!!"
  lda #val
  ldx #len
set_loop:
  sta.zp zp_addr-1,x
  dex
  bne set_loop
}

.macro inc_24_bit(counter) {
        inc counter + 0
        bne idone
        inc counter + 1
        bne idone
        inc counter + 2
idone:
}
