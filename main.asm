#importonce

#import "cpu.asm"
#import "frame-counter.asm"
#import "macros.asm"
#import "cia-io.asm"
#import "utils.asm"
#import "state-title-screen.asm"
#import "state-level-intro.asm"
#import "state-level-play.asm"
#import "vic-io.asm"
#import "vectors.asm"

.filenamespace main

.segment Start
*= $0810 "Start"
start: {
        sei
        ldx #$FF
        txs
        cld

        jsr frame_counter.init__a


        // Setup tile screen lookup ptr
        lda #<screen_tile_row_addr_table.lo
        sta zp.screen_tile_row_addr_low_ptr
        lda #>screen_tile_row_addr_table.lo
        sta zp.screen_tile_row_addr_low_ptr + 1
        lda #<screen_tile_row_addr_table.hi
        sta zp.screen_tile_row_addr_hi_ptr
        lda #>screen_tile_row_addr_table.hi
        sta zp.screen_tile_row_addr_hi_ptr + 1

        // Switch out kernel & BASIC roms
        lda cpu.port_reg
        and #%11111000
        ora #%00000101
        sta cpu.port_reg

        lda #%01111111
        sta cia1.icr
        and vic.ctrl_reg_1
        sta vic.ctrl_reg_1

        //sta $DC0D
        //sta $DC0D

        lda #$00
        jsr utils.clear_screen__x

        lda #%00000001
        sta vic.interrupt_enabled

        lda #LIGHT_RED
        sta vic.border_colour
        lda #GREEN
        sta vic.background_colour_0

        // Setup initial handlers
        set_int_vector(vector.nmi, nmi_handler)
        set_int_vector(vector.reset, reset_handler)
        set_int_vector(vector.irq, irq_handler)

        // Vic bank at $4000 - $7FFF
        lda cia2.ddra
        ora #%00000011
        sta cia2.ddra
        lda cia2.pra
        and #%11111100
        ora #%00000010
        sta cia2.pra

        lda vic.ctrl_reg_1
        and #%10011111
        sta vic.ctrl_reg_1
        lda vic.ctrl_reg_2
        ora #%00010000
        sta vic.ctrl_reg_2

        lda #BLACK
        sta vic.background_colour_1


        lda #GRAY
        sta vic.background_colour_2

        // Screen @ +$3800 & Charset @ +$0000
        lda #CHARSET_OFFSET_0_0000 | SCREEN_OFFSET_14_3800
        sta vic.memory_pointers

        lda #$1b
        sta vic.ctrl_reg_1

        // Clear last byte of VIC bank (needed for open top + bottom borders)
        lda #$00
        sta VIC_BANK_BASE + $3fff

        lda #<tile_lookup
        sta zp.tile_lookup_ptr
        lda #>tile_lookup
        sta zp.tile_lookup_ptr + 1

        /*
        lda #3
        sta zp.col
        lda #3
        sta zp.row
        jsr set_screen_ptrs_for_tile_pos
        lda #5
        _setup_tile__y()
        jsr draw_tile
        */

        lda #STATE_TILE_SCREEN
        sta current_state
        lda #STATE_TILE_SCREEN
        sta next_state

        // Kick start sm
        jsr call_state_enter_sub__ax

        game_loop:
        lda current_state
        cmp next_state
        beq no_state_change
        jsr call_state_exit_sub__ax
        lda next_state
        sta current_state
        jsr call_state_enter_sub__ax
        no_state_change:
        jsr call_state_run_sub__ax
        jmp game_loop
}

nmi_handler: {
        rti
}

reset_handler: {
        rti
}

irq_handler: {
        rti
}

// call current state's enter sub
call_state_enter_sub__ax: {
  lda current_state
  asl
  tax
  lda state_enter_table+1,x
  pha
  lda state_enter_table,x
  pha
  rts
}

// call current state's exit sub
call_state_exit_sub__ax: {
  lda current_state
  asl
  tax
  lda state_exit_table+1,x
  pha
  lda state_exit_table,x
  pha
  rts
}

// call current state's run sub
call_state_run_sub__ax: {
  lda current_state
  asl
  tax
  lda state_run_table+1,x
  pha
  lda state_run_table,x
  pha
  rts
}

.segment BSSCommon "Main"
current_state:
        .byte $00
next_state:
        .byte $00

// Current game level, 0 based. 0 = level 1
game_level:
        .byte $00

.segment Data0 "Main"
// State tables
//------------
state_run_table:
        .word state_title_screen.run - 1
        .word state_level_intro.run - 1
        .word state_level_play.run - 1

state_enter_table:
        .word state_title_screen.enter - 1
        .word state_level_intro.enter - 1
        .word state_level_play.enter - 1

state_exit_table:
        .word state_title_screen.exit - 1
        .word state_level_intro.exit - 1
        .word state_level_play.exit - 1


// Lookup table for abs screen address for each row of tiles
screen_tile_row_addr_table:
        .lohifill 12, SCREEN_BASE + (i * 80)

// Used labels in file for now
// (TODO) - Fix this!!
#import "assets/bman-64-tileset.asm"
