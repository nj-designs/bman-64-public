#importonce

.filenamespace maps

#import "map1/map1.asm"
#import "map2/map2.asm"

/**
  This macro will setup tile char array and colour for the tile
  is reg 'a'

  Needs zp.tile_lookup_ptr to be set

  uses y
*/
.macro _setup_tile__y() {
  clc
  rol
  rol
  tay                  // y = 4 * tile_idx

  lda (zp.tile_lookup_ptr), y
  sta zp.char_array
  iny
  lda (zp.tile_lookup_ptr), y
  sta zp.char_array + 1
  iny
  lda (zp.tile_lookup_ptr), y
  sta zp.char_array + 2
  iny
  lda (zp.tile_lookup_ptr), y
  sta zp.char_array + 3
}


.segment Text0 "Maps"
setup_tile__ay: {
        :_setup_tile__y()
        rts
}
/**
  draw_map

  map_ptr_1 : address of 20x12 tile indices

*/
draw_map__axy: {

        lda #$ff
        sta zp.last_tile_idx

        lda current_ptr
        sta _map_ptr
        lda current_ptr + 1
        sta _map_ptr + 1

        lda #<(SCREEN_BASE)
        sta zp.screen_ptr_1
        lda #>(SCREEN_BASE)
        sta zp.screen_ptr_1 + 1

        lda #<COLOUR_RAM_BASE
        sta zp.colour_ram_ptr_1
        lda #>COLOUR_RAM_BASE
        sta zp.colour_ram_ptr_1 + 1
        // TODO: Lookup colour from tile_attr table
        lda #(1 << 3) | WHITE
        sta zp.colour_1

        lda #20
        sta zp.col_cnt
loop:
        lda _map_ptr:$FFFF
        cmp #$FF
        beq done
        cmp zp.last_tile_idx
        beq skip_char_lookup
        sta zp.last_tile_idx // remember this tile
        _setup_tile__y()
skip_char_lookup:
        jsr draw_tile

        // Move to next tile
        clc
        lda _map_ptr
        adc #1
        sta _map_ptr
        lda _map_ptr + 1
        adc #0
        sta _map_ptr + 1

        // Move to next screen location
        clc
        dec zp.col_cnt
        bne same_row
        lda #20
        sta zp.col_cnt
        // Move one row down
        lda zp.screen_ptr_1
        adc #42
        sta zp.screen_ptr_1
        lda zp.screen_ptr_1 + 1
        adc #0
        sta zp.screen_ptr_1 + 1
        lda zp.colour_ram_ptr_1
        adc #42
        sta zp.colour_ram_ptr_1
        lda zp.colour_ram_ptr_1 + 1
        adc #0
        sta zp.colour_ram_ptr_1 + 1
        jmp loop

same_row:
        // screen
        lda zp.screen_ptr_1
        adc #2
        sta zp.screen_ptr_1
        lda zp.screen_ptr_1 + 1
        adc #0
        sta zp.screen_ptr_1 + 1
        // colour
        lda zp.colour_ram_ptr_1
        adc #2
        sta zp.colour_ram_ptr_1
        lda zp.colour_ram_ptr_1 + 1
        adc #0
        sta zp.colour_ram_ptr_1 + 1
        jmp loop

done:
  rts
}

/**
  draw_tile

  Draws a 2x2 tile to the screen

  Drawn with following offsets
  +0|+1
  +2|+3

  zp.screen_ptr_1 - screen address
  zp.colour_ram_ptr_1 - colour_ram address
  zp.char_array - array of 4 chars that make up tile
  zp.colour_1 - colour
*/
draw_tile: {
  txa
  pha
  tya
  pha

  ldx #0
  ldy #0

  // Top Left
  lda zp.char_array,x
  sta (zp.screen_ptr_1),y
  lda zp.colour_1
  sta (zp.colour_ram_ptr_1),y

  // Top Right
  inx
  iny
  lda zp.char_array,x
  sta (zp.screen_ptr_1),y
  lda zp.colour_1
  sta (zp.colour_ram_ptr_1),y


  // Bottom left
  inx
  tya
  clc
  adc #39
  tay
  lda zp.char_array,x
  sta (zp.screen_ptr_1),y
  lda zp.colour_1
  sta (zp.colour_ram_ptr_1),y

  // Bottom right
  inx
  iny
  lda zp.char_array,x
  sta (zp.screen_ptr_1),y
  lda zp.colour_1
  sta (zp.colour_ram_ptr_1),y

  pla
  tay
  pla
  tax

  rts
}

/**
  set zp.screen_ptr_1 to screen address and colour_ram_ptr_1 to colour ram address

  tile_x_pos = tile col (0-19)
  tile_y_pos = tile row (0-11)

*/
set_screen_ptrs_for_tile_pos__ay: {
  lda tile_x_pos
  clc
  rol        // Assuming col is <= 127, this will clear carry flag

  ldy tile_y_pos
  adc (zp.screen_tile_row_addr_low_ptr),y
  sta zp.screen_ptr_1
  lda (zp.screen_tile_row_addr_hi_ptr),y
  adc #0
  sta zp.screen_ptr_1 + 1

  // Assume carry will be zero from above
  lda zp.screen_ptr_1
  adc #<SCREEN_COLOUR_RAM_OFFSET
  sta zp.colour_ram_ptr_1
  lda zp.screen_ptr_1 + 1
  adc #>SCREEN_COLOUR_RAM_OFFSET
  sta zp.colour_ram_ptr_1 + 1

  rts
}

// Add a number of soft walls to map
add_soft_walls__axy: {
        ldy #(TILE_X_COUNT + 4) // player starts in 1,1 ensure can set a bomb
loop:
        lda (current_ptr),y
        cmp #$ff
        beq done
        cmp #1 //TODO(njohn): Add define for this tile
        beq next
        jsr random.get__ax // a = some random value
        cmp #(255/4) // ~25% chance of a soft wall
        bcs next
        lda #5
        sta (current_ptr),y
next:
        iny
        jmp loop
done:
        rts
}

// Clear map back to default. i.e just solid walls and empty tiles
clear_map__ay: {
        ldy #0
loop:
        lda (current_ptr),y
        cmp #$ff
        beq done
        cmp #1 //TODO(njohn): Add define for this tile
        beq next
        lda #0
        sta (current_ptr),y
next:
        iny
        jmp loop
done:
        rts

}

.segment ZPCommon "Maps"
.zp {
tile_x_pos:
        .byte $00
tile_y_pos:
        .byte $00
current_ptr: // Points to current map 20x12 array
        .word $0000
}
