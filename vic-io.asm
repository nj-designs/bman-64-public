#importonce

// VIC II registers
.segment IO
*=$D000 "VIC IO"
.namespace vic {
          // Based on https://www.c64-wiki.com/wiki/Page_208-211
        x_coord_spr_0: .byte $00 // $D000
        y_coord_spr_0: .byte $00 // $D001
        x_coord_spr_1: .byte $00 // $D002
        y_coord_spr_1: .byte $00 // $D003
        x_coord_spr_2: .byte $00 // $D004
        y_coord_spr_2: .byte $00 // $D005
        x_coord_spr_3: .byte $00 // $D006
        y_coord_spr_3: .byte $00 // $D007
        x_coord_spr_4: .byte $00 // $D008
        y_coord_spr_4: .byte $00 // $D009
        x_coord_spr_5: .byte $00 // $D00A
        y_coord_spr_5: .byte $00 // $D00B
        x_coord_spr_6: .byte $00 // $D00C
        y_coord_spr_6: .byte $00 // $D00D
        x_coord_spr_7: .byte $00 // $D00E
        y_coord_spr_7: .byte $00 // $D00F
        msb_x_coords: .byte $00 // $D010
        ctrl_reg_1:    .byte $00 // $D011
        raster_counter: .byte $00 // $D012
        light_pen_x:  .byte $00 // $D013
        light_pen_y:  .byte $00 // $D014
        spr_enabled: .byte $00 // $D015
        ctrl_reg_2:    .byte $00 // $D016
        spr_y_expansion: .byte $00 // $D017
        memory_pointers: .byte $00 // $D018
        interrupt_register: .byte $00 // $D019
        interrupt_enabled: .byte $00 // $D01A
        spr_data_priority: .byte $00 // $D01B
        spr_multicolour: .byte $00 // $D01C
        spr_x_expansion: .byte $00 // $D01D
        spr_spr_collision: .byte $00 // $D01E
        spr_data_collision: .byte $00 // $D01F
        border_colour: .byte $00 // $D020
        background_colour_0: .byte $00 // $D021
        background_colour_1: .byte $00 // $D022
        background_colour_2: .byte $00 // $D023
        background_colour_3: .byte $00 // $D024
        spr_multicolour_0: .byte $00 // $D025
        spr_multicolour_1: .byte $00 // $D026
        spr_0_colour: .byte $00 // $D027
        spr_1_colour: .byte $00 // $D028
        spr_2_colour: .byte $00 // $D029
        spr_3_colour: .byte $00 // $D02A
        spr_4_colour: .byte $00 // $D02B
        spr_5_colour: .byte $00 // $D02C
        spr_6_colour: .byte $00 // $D02D
        spr_7_colour: .byte $00 // $D02E
}

// spr_enabled
.enum { M7E=(1<<7) }

.const CHARSET_OFFSET_0_0000 = (%000 << 1) // + $0000 (0)
.const CHARSET_OFFSET_1_0800 = (%001 << 1) // + $0800 (2048)

.const SCREEN_OFFSET_0_0000  = (%0000 << 4)  // + $0000 (0)
.const SCREEN_OFFSET_14_3800 = (%1110 << 4) // + $3800 ()
.const SCREEN_OFFSET_15_3C00 = (%1111 << 4) // + $3C00 ()

.const COLOUR_RAM_BASE = $D800

.const NUM_HW_SPRITES = 8
