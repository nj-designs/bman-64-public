#importonce

#import "vic-io.asm"

.segment ZPCommon "ZP Common"
.namespace zp {
.zp {

tmp_ptr_1:
        .word $0000

colour_1:
byte_1: .byte $00

last_tile_idx:
byte_2: .byte $00

col_cnt:
byte_3: .byte $00

screen_ptr_1: // General screen pointer 1
word_1: .word $0000

colour_ram_ptr_1:
  .word $0000


char_array: // 4 bye array of chars
dword_1: .dword $00000000

tile_lookup_ptr:
word_4: .word $0000

screen_tile_row_addr_low_ptr:
  .word $0000
screen_tile_row_addr_hi_ptr:
  .word $0000

}
}
