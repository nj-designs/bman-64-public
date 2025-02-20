#importonce

#import "vic-io.asm"

.filenamespace sprites


.segment Text0 "Sprites"
table1_prog_sprite_regs__ax: {

        // X pos low byte
        lda table1_x_pos_lsb + 0
        sta vic.x_coord_spr_0
        lda table1_x_pos_lsb + 1
        sta vic.x_coord_spr_1
        lda table1_x_pos_lsb + 2
        sta vic.x_coord_spr_2
        lda table1_x_pos_lsb + 3
        sta vic.x_coord_spr_3
        lda table1_x_pos_lsb + 4
        sta vic.x_coord_spr_4
        lda table1_x_pos_lsb + 5
        sta vic.x_coord_spr_5
        lda table1_x_pos_lsb + 6
        sta vic.x_coord_spr_6
        lda table1_x_pos_lsb + 7
        sta vic.x_coord_spr_7

        // x pos msb
        ldx #0
        lda table1_x_pos_msb + 0 // Spr 0
        beq !next+
        lda #(1<<0)
        tax
        !next:
        lda table1_x_pos_msb + 1 // Spr 1
        beq !next+
        txa
        ora #(1<<1)
        tax
        !next:
        lda table1_x_pos_msb + 2 // Spr 2
        beq !next+
        txa
        ora #(1<<2)
        tax
        !next:
        lda table1_x_pos_msb + 3 // Spr 3
        beq !next+
        txa
        ora #(1<<3)
        tax
        !next:
        lda table1_x_pos_msb + 4 // Spr 4
        beq !next+
        txa
        ora #(1<<4)
        tax
        !next:
        lda table1_x_pos_msb + 5 // Spr 5
        beq !next+
        txa
        ora #(1<<5)
        tax
        !next:
        lda table1_x_pos_msb + 6 // Spr 6
        beq !next+
        txa
        ora #(1<<6)
        tax
        !next:
        lda table1_x_pos_msb + 7 // Spr 7
        beq !next+
        txa
        ora #(1<<7)
        tax
        !next:
        stx vic.msb_x_coords


        // Y pos
        lda table1_y_pos + 0
        sta vic.y_coord_spr_0
        lda table1_y_pos + 1
        sta vic.y_coord_spr_1
        lda table1_y_pos + 2
        sta vic.y_coord_spr_2
        lda table1_y_pos + 3
        sta vic.y_coord_spr_3
        lda table1_y_pos + 4
        sta vic.y_coord_spr_4
        lda table1_y_pos + 5
        sta vic.y_coord_spr_5
        lda table1_y_pos + 6
        sta vic.y_coord_spr_6
        lda table1_y_pos + 7
        sta vic.y_coord_spr_7

        // Colour
        lda table1_colour + 0
        sta vic.spr_0_colour
        lda table1_colour + 1
        sta vic.spr_1_colour
        lda table1_colour + 2
        sta vic.spr_2_colour
        lda table1_colour + 3
        sta vic.spr_3_colour
        lda table1_colour + 4
        sta vic.spr_4_colour
        lda table1_colour + 5
        sta vic.spr_5_colour
        lda table1_colour + 6
        sta vic.spr_6_colour
        lda table1_colour + 7
        sta vic.spr_7_colour

        // Spr ptr
        lda table1_ptr + 0
        sta SCREEN_BASE + $03f8 + 0
        lda table1_ptr + 1
        sta SCREEN_BASE + $03f8 + 1
        lda table1_ptr + 2
        sta SCREEN_BASE + $03f8 + 2
        lda table1_ptr + 3
        sta SCREEN_BASE + $03f8 + 3
        lda table1_ptr + 4
        sta SCREEN_BASE + $03f8 + 4
        lda table1_ptr + 5
        sta SCREEN_BASE + $03f8 + 5
        lda table1_ptr + 6
        sta SCREEN_BASE + $03f8 + 6
        lda table1_ptr + 7
        sta SCREEN_BASE + $03f8 + 7

        lda table1_enabled
        sta vic.spr_enabled
        rts
}

.segment ZPCommon "Sprites"
.zp {
table1_x_pos_lsb:
        .fill NUM_HW_SPRITES,$00
table1_x_pos_msb:
        .fill NUM_HW_SPRITES,$00
table1_y_pos:
        .fill NUM_HW_SPRITES,$00
table1_colour:
        .fill NUM_HW_SPRITES,$00
table1_ptr:
        .fill NUM_HW_SPRITES,$00
table1_enabled:
        .byte $00
}
