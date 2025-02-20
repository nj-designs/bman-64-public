#importonce

#import "const.asm"
#import "frame-counter.asm"
#import "macros.asm"
#import "random.asm"
#import "sprites.asm"

.filenamespace state_level_play

.const FIRST_ENEMY_DGO_NUM = 0
.const PLAYER_DGO_NUM = 7
.const MAX_ENEMY_COUNT = 7

.const DGO_COUNT = 8

.const PLAYER_SPR_PTR = SPR_GAME_BASE_PTR + 14
.const ENEMY_SPR_PTR = SPR_GAME_BASE_PTR + 90
.const BOMB_COUNT = 8

.const BOMB_INITIAL_TTL = 250


.const SHAKE_DELAY = 4

.enum {
        TILE_CHECK_MIDDLE=0,
        TILE_CHECK_LEFT=1,
        TILE_CHECK_RIGHT=2,
        TILE_CHECK_UP=3,
        TILE_CHECK_DOWN=4
}

.enum {
        DGO_DIRECTION_UP=0,
        DGO_DIRECTION_DOWN=1,
        DGO_DIRECTION_LEFT=2,
        DGO_DIRECTION_RIGHT=3
}

.segment Text0 "State Level Play"
enter: {

        jsr random.init__a
        //Create x screen pos lookup
        //use dgo_x_pos_delta as tmp working area
        ldx #SCREEN_X_START
        stx tmp_word
        ldx #0
        stx tmp_word + 1
x_pos_loop:
        clc
        lda tmp_word
        sta screen_x_pos_lsb_lookup_table,x
        adc #TILE_SIZE_IN_PIXELS
        sta tmp_word
        lda tmp_word + 1
        sta screen_x_pos_msb_lookup_table,x
        adc #0
        sta tmp_word + 1
        inx
        cpx #TILE_X_COUNT
        bne x_pos_loop

        //Create x screen pos lookup
        lda #SCREEN_Y_START
        ldx #0
        clc
y_pos_loop:
        sta screen_y_pos_lookup_table,x
        adc #TILE_SIZE_IN_PIXELS
        inx
        cpx #TILE_Y_COUNT
        bne y_pos_loop

        // Create tile row offset lookup table
        ldx #0
        txa
        clc
tile_row_loop:
        sta tile_row_offset_lookup_table,x
        adc #TILE_X_COUNT
        inx
        cpx #TILE_Y_COUNT
        bne tile_row_loop


        // Following works as we know it's in zp
        :set_zp_mem_block__ax(zp_segment_start, $00, zp_segment_end-zp_segment_start)
        // Table to look up enable bit for each sprite
        ldx #0
        txa
        sec
spr_enabled_loop:
        rol
        sta spr_enabled_lookup,x
        inx
        cpx #8
        bne spr_enabled_loop

        lda main.game_level
        jsr levels.exec_level_init_sub__x
        jsr maps.add_soft_walls__axy
        jsr maps.draw_map__axy

        lda #GREEN
        sta lower_colour

        // Draw "soft walls"

        /*
        lda #3
        sta maps.tile_x_pos
        lda #3
        sta maps.tile_y_pos
        jsr maps.set_screen_ptrs_for_tile_pos__ay
        lda #5
        jsr maps.setup_tile__ay
        jsr maps.draw_tile
        */


        ldx main.game_level
        // ldx #9 // Overide for testing
        inx // game level is zero based, i.e. 0 == level 1
        cpx #MAX_ENEMY_COUNT
        bcc cnt_ok
        ldx #MAX_ENEMY_COUNT
cnt_ok:
        stx enemy_count
        jsr init_enemy__axy

        // Sprite test
        lda #BLACK
        sta vic.spr_multicolour_0
        lda #WHITE
        sta vic.spr_multicolour_1
        lda #$ff
        sta vic.spr_multicolour
        sta vic.spr_enabled

        //dgo[0,1]
        lda #ENEMY_SPR_PTR
        sta dgo_spr_ptr + 0
        sta dgo_spr_ptr + 1
        sta dgo_spr_ptr + 2
        sta dgo_spr_ptr + 3
        sta dgo_spr_ptr + 4
        sta dgo_spr_ptr + 5
        sta dgo_spr_ptr + 6
        lda #GREEN
        sta dgo_spr_colour + 0
        sta dgo_spr_colour + 1
        sta dgo_spr_colour + 2
        sta dgo_spr_colour + 3
        sta dgo_spr_colour + 4
        sta dgo_spr_colour + 5
        sta dgo_spr_colour + 6

        //dgo7 Player
        lda #1
        sta dgo_map_x_pos + PLAYER_DGO_NUM
        lda #1
        sta dgo_map_y_pos + PLAYER_DGO_NUM
        lda #PLAYER_SPR_PTR
        sta dgo_spr_ptr + PLAYER_DGO_NUM
        lda #LIGHT_RED
        sta dgo_spr_colour + PLAYER_DGO_NUM

        jsr update_dgo_current_screen_pos_from_map__axy

        lda #3
        sta player_bomb_count

        .break
        sei
        //lda #255 // Raster line
        //sta $D012
        //set_int_vector(vector.irq, level_play_irq_handler)
        lda #0
        sta vic.raster_counter
        set_int_vector(vector.irq, top_irq_handler)

        cli

        rts
}

run: {
        // Sync up with frame
        lda sync
        beq run
        lda #0
        sta sync

        ldx #100
loop:
        dex
        bne loop

        lda #RED
        sta vic.border_colour

        jsr process_player__axy
        jsr process_enemy__axy

        jsr check_player_hit__axy

        lda #LIGHT_GREEN
        sta vic.border_colour

        rts
}

exit: {
  rts
}

// At rast=0
top_irq_handler: {
        pha
        txa
        pha
        lda #BLACK
        sta vic.border_colour


        lda #GREEN
        sta vic.background_colour_0

        jsr frame_counter.update

        lda #51
        sta vic.raster_counter
        set_int_vector(vector.irq, play_area_irq_handler)

        jsr animate_dgo_table__axy

        // jsr check_screen_shake__axy

        inc $d019

        lda #LIGHT_GREEN
        sta vic.border_colour
        pla
        tax
        pla

        rti
}

// At rast=51
play_area_irq_handler: {
        pha
        txa
        pha
        lda #BLACK
        sta vic.border_colour

        lda #$f9
        sta vic.raster_counter
        set_int_vector(vector.irq, border_irq_handler)

        jsr update_sprite_table1__axy
        jsr sprites.table1_prog_sprite_regs__ax

        inc $d019

        lda #LIGHT_GREEN
        sta vic.border_colour

        sta sync // Trigger main loop

        pla
        tax
        pla

        rti
}

// At rast=$f9
border_irq_handler: {
        pha
        txa
        pha
        lda #BLACK
        sta vic.border_colour

        lda #0
        sta vic.raster_counter
        set_int_vector(vector.irq, top_irq_handler)

        // Screen rows = 24
        lda vic.ctrl_reg_1
        and #%11110111
        sta vic.ctrl_reg_1

        ldx #60
        loop:
        dex
        bne loop

        // Screen rows = 25
        lda vic.ctrl_reg_1
        ora #%00001000
        sta vic.ctrl_reg_1

        jsr update_bombs__axy

        inc $d019

        lda #LIGHT_GREEN
        lda lower_colour
        sta vic.border_colour
        pla
        tax
        pla

        rti
}

// Assumes tile_check_array is valid for player's dgo
move_player__axy: {
        lda cia1.pra
        cmp #%01111111
        beq done
        eor #%01111111
        sta joy2
        // Check fire
        lda #JOY2_FIRE
        and joy2
        beq check_left
        ldy njohn_last_fire_state
        beq do_bomb
        jmp done
do_bomb:
        jsr check_bomb_drop__axy
        inc njohn_last_fire_state
        jmp check_left_no_reset
check_left:
        lda #0
        sta njohn_last_fire_state
check_left_no_reset:
        lda #JOY2_LEFT
        and joy2
        beq check_right
        // can we move left
        ldx tile_check_array + TILE_CHECK_LEFT
        bne done
        lda #-TILE_SIZE_IN_PIXELS
        sta dgo_x_pos_delta + PLAYER_DGO_NUM
        dec dgo_map_x_pos + PLAYER_DGO_NUM
        jmp done
check_right:
        lda #JOY2_RIGHT
        and joy2
        beq check_up
        // can we move right
        ldx tile_check_array + TILE_CHECK_RIGHT
        bne done
        lda #TILE_SIZE_IN_PIXELS
        sta dgo_x_pos_delta + PLAYER_DGO_NUM
        inc dgo_map_x_pos + PLAYER_DGO_NUM
        jmp done
check_up:
        lda #JOY2_UP
        and joy2
        beq check_down
        // can we move up
        ldx tile_check_array + TILE_CHECK_UP
        bne done
        lda #-TILE_SIZE_IN_PIXELS
        sta dgo_y_pos_delta + PLAYER_DGO_NUM
        dec dgo_map_y_pos + PLAYER_DGO_NUM
        jmp done
check_down:
        lda #JOY2_DOWN
        and joy2
        beq done
        // can we move down
        ldx tile_check_array + TILE_CHECK_DOWN
        bne done
        lda #TILE_SIZE_IN_PIXELS
        sta dgo_y_pos_delta + PLAYER_DGO_NUM
        inc dgo_map_y_pos + PLAYER_DGO_NUM
done:
        rts
}

/*
move_player__axy3: {
        lda #JOY2_LEFT
        bit cia1.pra
        bne check_right
        // can we move left
        ldx tile_check_array + TILE_CHECK_LEFT
        bne done
        lda #-TILE_SIZE_IN_PIXELS
        sta dgo_x_pos_delta + PLAYER_DGO_NUM
        dec dgo_map_x_pos + PLAYER_DGO_NUM
        jmp done
check_right:
        lda #JOY2_RIGHT
        bit cia1.pra
        bne check_up
        // can we move right
        ldx tile_check_array + TILE_CHECK_RIGHT
        bne done
        lda #TILE_SIZE_IN_PIXELS
        sta dgo_x_pos_delta + PLAYER_DGO_NUM
        inc dgo_map_x_pos + PLAYER_DGO_NUM
        jmp done
check_up:
        lda #JOY2_UP
        bit cia1.pra
        bne check_down
        // can we move up
        ldx tile_check_array + TILE_CHECK_UP
        bne done
        lda #-TILE_SIZE_IN_PIXELS
        sta dgo_y_pos_delta + PLAYER_DGO_NUM
        dec dgo_map_y_pos + PLAYER_DGO_NUM
        jmp done
check_down:
        lda #JOY2_DOWN
        bit cia1.pra
        bne check_fire
        // can we move down
        ldx tile_check_array + TILE_CHECK_DOWN
        bne done
        lda #TILE_SIZE_IN_PIXELS
        sta dgo_y_pos_delta + PLAYER_DGO_NUM
        inc dgo_map_y_pos + PLAYER_DGO_NUM
        jmp done
check_fire:
        lda #JOY2_FIRE
        bit cia1.pra
        bne done
        jsr check_bomb_drop__axy
done:
        rts
}
*/
check_bomb_drop__axy: {
        // Look for an inactive bomb
        ldx #$ff
loop:
        inx
        cpx player_bomb_count
        beq done
        lda bomb_ttl, x
        bne loop
        // x == index of an inactive bomb, capture player posistion
        lda dgo_map_x_pos + PLAYER_DGO_NUM
        sta bomb_map_x_pos, x
        lda dgo_map_y_pos + PLAYER_DGO_NUM
        sta bomb_map_y_pos, x
        lda #BOMB_INITIAL_TTL
        sta bomb_ttl, x
done:
        rts
}

update_bombs__axy: {
        ldx #0
loop:
        ldy bomb_ttl, x
        beq next // Bomb is inactive, move on to next
        dey      // dec TTL
        cpy #BOMB_INITIAL_TTL-1
        bne not_new
        sty bomb_ttl, x
        lda bomb_map_x_pos, x
        sta maps.tile_x_pos
        lda bomb_map_y_pos, x
        sta maps.tile_y_pos
        jsr maps.set_screen_ptrs_for_tile_pos__ay
        lda #3
        jsr maps.setup_tile__ay
        jsr maps.draw_tile
        jmp next
not_new:
        cpy #1
        bne still_active
        lda bomb_map_x_pos, x
        sta maps.tile_x_pos
        lda bomb_map_y_pos, x
        sta maps.tile_y_pos
        jsr maps.set_screen_ptrs_for_tile_pos__ay
        lda #0
        jsr maps.setup_tile__ay
        jsr maps.draw_tile
/*
        txa
        pha
        jsr start_screen_shake__xy
        pla
        tax
*/
        ldy #0
still_active:
        sty bomb_ttl, x
next:
        inx
        cpx player_bomb_count
        bne loop
done:
        rts
}

// Updates sprites.table1 from the dgo
update_sprite_table1__axy: {
        ldx #0
        txa
loop:
        ldy dgo_map_x_pos, x
        beq next
        ora spr_enabled_lookup, x
        // x pos word
        ldy dgo_current_screen_x_pos_lsb,x
        sty sprites.table1_x_pos_lsb, x
        ldy dgo_current_screen_x_pos_msb,x
        sty sprites.table1_x_pos_msb, x
        // y pos byte
        ldy dgo_screen_y_pos,x
        sty sprites.table1_y_pos,x
        // colour byte
        ldy dgo_spr_colour,x
        sty sprites.table1_colour,x
        // ptr byte
        ldy dgo_spr_ptr,x
        sty sprites.table1_ptr,x
next:
        inx
        cpx #DGO_COUNT
        bne loop
        sta sprites.table1_enabled
        rts
}

animate_dgo_table__axy: {
        ldx #0
loop:
        ldy dgo_x_pos_delta,x
        beq check_y_delta
        bmi neg_x_movement
// pos_x_movement
        clc
        lda dgo_current_screen_x_pos_lsb,x
        adc #1
        sta dgo_current_screen_x_pos_lsb,x
        lda dgo_current_screen_x_pos_msb,x
        adc #0
        sta dgo_current_screen_x_pos_msb,x
        dey
        sty dgo_x_pos_delta,x
        jmp loop_end // No diagonal movement
neg_x_movement:
        sec
        lda dgo_current_screen_x_pos_lsb,x
        sbc #1
        sta dgo_current_screen_x_pos_lsb,x
        lda dgo_current_screen_x_pos_msb,x
        sbc #0
        sta dgo_current_screen_x_pos_msb,x
        tya
        clc
        adc #1
        sta dgo_x_pos_delta,x
        jmp loop_end // No diagonal movement
check_y_delta:
        ldy dgo_y_pos_delta,x
        beq loop_end
        bmi neg_y_movement
// pos_y_movement
        inc dgo_screen_y_pos,x
        dey
        sty dgo_y_pos_delta,x
        jmp loop_end
neg_y_movement:
        dec dgo_screen_y_pos,x
        tya
        clc
        adc #1
        sta dgo_y_pos_delta,x
loop_end:
        inx
        cpx #DGO_COUNT
        bne loop

        rts
}

update_dgo_current_screen_pos_from_map__axy: {
        ldx #0
loop:
        ldy dgo_map_x_pos,x
        lda screen_x_pos_lsb_lookup_table,y
        sta dgo_current_screen_x_pos_lsb,x
        lda screen_x_pos_msb_lookup_table,y
        sta dgo_current_screen_x_pos_msb,x

        ldy dgo_map_y_pos,x
        lda screen_y_pos_lookup_table,y
        sta dgo_screen_y_pos,x

        inx
        cpx #DGO_COUNT
        bne loop

        rts
}

// Populate 5 tiles in and around dgo
// Usefull collision detection a movement checks
// IN: x: dgo#
// OUT:
// STOMPS: ay
populate_tile_check_array__ay: {
        ldy dgo_map_y_pos,x
        lda tile_row_offset_lookup_table,y
        clc
        adc dgo_map_x_pos,x
        tay

        // mpx+0, mpy+0
        lda (maps.current_ptr),y
        sta tile_check_array + 0
        // mpx-1, mpy+0
        dey
        lda (maps.current_ptr),y
        sta tile_check_array + 1
        // mpx+1, mpy+0
        iny
        iny
        lda (maps.current_ptr),y
        sta tile_check_array + 2

        // mapx+0, mpy-1
        tya
        sec
        sbc #TILE_X_COUNT+1
        tay
        lda (maps.current_ptr),y
        sta tile_check_array + 3

        // mapx+0, mpy+1
        tya
        clc
        adc #TILE_X_COUNT * 2
        tay
        lda (maps.current_ptr),y
        sta tile_check_array + 4

        rts
}

// main player related loop code
process_player__axy: {
        lda dgo_x_pos_delta + PLAYER_DGO_NUM
        ora dgo_y_pos_delta + PLAYER_DGO_NUM
        bne not_idle
        ldx #PLAYER_DGO_NUM
        jsr populate_tile_check_array__ay
        jsr move_player__axy
not_idle:
        rts
}

// Process enemy movement
// IN:
// OUT:
// STOMPS: axy
process_enemy__axy: {
        ldx #FIRST_ENEMY_DGO_NUM
loop:
        lda dgo_map_x_pos, x
        beq next // 0 == disabled
        lda dgo_x_pos_delta, x
        ora dgo_y_pos_delta, x
        bne next // !0 == still moving
        jsr populate_tile_check_array__ay //x == DGO number
        lda dgo_direction, x
        cmp #DGO_DIRECTION_UP
        bne check_moving_down
        // Moving up
        ldy tile_check_array + TILE_CHECK_UP
        bne blocked
        lda #-TILE_SIZE_IN_PIXELS
        sta dgo_y_pos_delta, x
        dec dgo_map_y_pos, x
        jmp next
check_moving_down:
        cmp #DGO_DIRECTION_DOWN
        bne check_moving_left
        ldy tile_check_array + TILE_CHECK_DOWN
        bne blocked
        lda #TILE_SIZE_IN_PIXELS
        sta dgo_y_pos_delta, x
        inc dgo_map_y_pos, x
        jmp next
check_moving_left:
        cmp #DGO_DIRECTION_LEFT
        bne check_moving_right
        ldy tile_check_array + TILE_CHECK_LEFT
        bne blocked
        lda #-TILE_SIZE_IN_PIXELS
        sta dgo_x_pos_delta, x
        dec dgo_map_x_pos, x
        jmp next
check_moving_right:
        cmp #DGO_DIRECTION_RIGHT
        bne next
        ldy tile_check_array + TILE_CHECK_RIGHT
        bne blocked
        lda #TILE_SIZE_IN_PIXELS
        sta dgo_x_pos_delta, x
        inc dgo_map_x_pos, x
        jmp next
blocked:
        //Chose a new direction
        stx tmp_word
        jsr random.get__ax
        ldx tmp_word
        and #$03
        sta dgo_direction, x
next:
        inx
        cpx enemy_count
        bne loop
        rts
}

check_player_hit__axy: {
        lda #GREEN
        sta lower_colour
        ldx #FIRST_ENEMY_DGO_NUM
loop:
        // Check y axis
        sec
        lda dgo_screen_y_pos + PLAYER_DGO_NUM
        sbc dgo_screen_y_pos, x
        bpl y_ok
        eor #$ff
        adc #1
y_ok:
        cmp #16
        bcs not_hit

        // Check x axis
        sec
        lda dgo_current_screen_x_pos_lsb + PLAYER_DGO_NUM
        sbc dgo_current_screen_x_pos_lsb , x
        sta tmp_word
        lda dgo_current_screen_x_pos_msb + PLAYER_DGO_NUM
        sbc dgo_current_screen_x_pos_msb , x
        sta tmp_word + 1
        bpl x_ok
        eor #$ff
        sta tmp_word + 1
        lda tmp_word
        eor #$ff
        clc
        adc #1
        sta tmp_word
        lda tmp_word + 1
        adc #0
        sta tmp_word + 1
x_ok:
        bne not_hit
        lda tmp_word
        cmp #16
        bcs not_hit

        lda #BLUE
        sta lower_colour

not_hit:
        inx
        cpx enemy_count
        bne loop

        rts
}

init_enemy__axy: {
        ldx #FIRST_ENEMY_DGO_NUM
        // Start somewhere in lower right quadrant
        lda enemy_count
        cmp #7
        bcc !next+
        jsr posisition_enemy_quad_1__ay
        inx
        jsr posisition_enemy_quad_1__ay
        inx
        jsr posisition_enemy_quad_1__ay
        inx
        jsr posisition_enemy_quad_2__ay
        inx
        jsr posisition_enemy_quad_2__ay
        inx
        jsr posisition_enemy_quad_3__ay
        inx
        jsr posisition_enemy_quad_3__ay
        jmp done
!next:
        cmp #6
        bne !next+
        jsr posisition_enemy_quad_1__ay
        inx
        jsr posisition_enemy_quad_1__ay
        inx
        jsr posisition_enemy_quad_2__ay
        inx
        jsr posisition_enemy_quad_2__ay
        inx
        jsr posisition_enemy_quad_3__ay
        inx
        jsr posisition_enemy_quad_3__ay
        jmp done
!next:
        cmp #5
        bne !next+
        jsr posisition_enemy_quad_1__ay
        inx
        jsr posisition_enemy_quad_1__ay
        inx
        jsr posisition_enemy_quad_2__ay
        inx
        jsr posisition_enemy_quad_2__ay
        inx
        jsr posisition_enemy_quad_3__ay
        jmp done
!next:
        cmp #4
        bne !next+
        jsr posisition_enemy_quad_1__ay
        inx
        jsr posisition_enemy_quad_1__ay
        inx
        jsr posisition_enemy_quad_2__ay
        inx
        jsr posisition_enemy_quad_3__ay
        jmp done
!next:
        cmp #3
        bne !next+
        jsr posisition_enemy_quad_1__ay
        inx
        jsr posisition_enemy_quad_2__ay
        inx
        jsr posisition_enemy_quad_3__ay
        jmp done
!next:
        cmp #2
        bne !next+
        jsr posisition_enemy_quad_1__ay
        inx
        jsr posisition_enemy_quad_2__ay
        jmp done
!next:
        jsr posisition_enemy_quad_1__ay
done:
        lda #0
        sta quad_def_x1
        sta quad_def_x2
        sta quad_def_y1
        sta quad_def_y2
        rts
}

//x = enemy number
posisition_enemy_quad_1__ay: {
        lda #TILE_X_COUNT/2
        sta quad_def_x1
        lda #TILE_X_COUNT
        sta quad_def_x2
        lda #TILE_Y_COUNT/2
        sta quad_def_y1
        lda #TILE_Y_COUNT
        sta quad_def_y2
        jmp posistion_enemy__ay
}

posisition_enemy_quad_2__ay: {
        lda #TILE_X_COUNT/2
        sta quad_def_x1
        lda #TILE_X_COUNT
        sta quad_def_x2
        lda #1
        sta quad_def_y1
        lda #TILE_Y_COUNT/2
        sta quad_def_y2
        jmp posistion_enemy__ay
}

posisition_enemy_quad_3__ay:{
        lda #1
        sta quad_def_x1
        lda #TILE_X_COUNT/2
        sta quad_def_x2
        lda #TILE_Y_COUNT/2
        sta quad_def_y1
        lda #TILE_Y_COUNT
        sta quad_def_y2
        jmp posistion_enemy__ay
}

// Posistion enemy in x to a random location within
// a quad defined in quad_def
posistion_enemy__ay: {
choose_x_again:
        stx tmp_word
        jsr random.get__ax
        ldx tmp_word
        cmp quad_def_x1
        bcc choose_x_again
        cmp quad_def_x2
        bcs choose_x_again
        sta dgo_map_x_pos, x
choose_y_again:
        stx tmp_word
        jsr random.get__ax
        ldx tmp_word
        cmp quad_def_y1
        bcc choose_y_again
        cmp quad_def_y2
        bcs choose_y_again
        sta dgo_map_y_pos, x
        jsr populate_tile_check_array__ay //x == DGO number
        lda tile_check_array + TILE_CHECK_MIDDLE
        bne choose_x_again
        rts
}

/*
start_screen_shake__xy: {
        lda screen_shake_counter
        bne shake_in_progress
        ldx #SHAKE_DELAY
        stx screen_shake_delay
shake_in_progress:
        clc
        adc #2
        sta screen_shake_counter
        rts
}

check_screen_shake__axy: {
        ldy screen_shake_counter
        beq exit
        ldx screen_shake_delay
        dex
        beq shake_delay_complete
        stx screen_shake_delay
        rts
shake_delay_complete:
        lda vic.ctrl_reg_2
        and #%00000111
        eor #%00000111
        sta tmp_word //tmp_word is new x screen value
        dey
        bne still_shaking
        lda #0
        sta tmp_word
still_shaking:
        ldx #SHAKE_DELAY
        stx screen_shake_delay
        lda vic.ctrl_reg_2
        and #%11111000
        ora tmp_word
        sta vic.ctrl_reg_2
        sty screen_shake_counter
exit:
        rts
}
*/

.segment ZPUnion
*=ZP_SHARED_BASE "State Level Play"
zp_segment_start:
.zp {
enemy_count:
        .byte $00

tmp_word:
        .word $0000
joy2:
        .byte $00
sync:
        .byte $00

dgo_x_pos_delta:
        .fill DGO_COUNT, $00
dgo_y_pos_delta:
        .fill DGO_COUNT, $00
// map_x_pos = 0: dgo disabled
dgo_map_x_pos:
        .fill DGO_COUNT, $00
dgo_map_y_pos:
        .fill DGO_COUNT, $00
dgo_current_screen_x_pos_lsb:
        .fill DGO_COUNT, $00
dgo_current_screen_x_pos_msb:
        .fill DGO_COUNT, $00
dgo_screen_y_pos:
        .fill DGO_COUNT, $00
dgo_spr_ptr:
        .fill DGO_COUNT, $00
dgo_spr_colour:
        .fill DGO_COUNT, $00
quad_def:
dgo_direction:
        .fill DGO_COUNT, $00
tile_check_array:
        .fill 5, $00
lower_colour:
        .byte $00

bomb_map_x_pos:
        .fill BOMB_COUNT, $00
bomb_map_y_pos:
        .fill BOMB_COUNT, $00
bomb_ttl:
        .fill BOMB_COUNT, $00

/*
// If > 0, screen will be shaking. Bomb explosions will increase
screen_shake_counter:
        .byte $00
screen_shake_delay:
        .byte $00
*/

// How many bombs the player has
// Can get incremented when bomb explodes or power-ups
player_bomb_count:
        .byte $00
njohn_last_fire_state:
        .byte $00
// Reuse dgo_direction during enemy pos init
.label quad_def_x1 = quad_def + 0
.label quad_def_y1 = quad_def + 1
.label quad_def_x2 = quad_def + 2
.label quad_def_y2 = quad_def + 3
}
zp_segment_end:


.segment BSSUnion
*=BSS_SHARED_BASE "State Level Play"
bss_segment_start:
screen_x_pos_lsb_lookup_table:
        .fill 20, $00
screen_x_pos_msb_lookup_table:
        .fill 20, $00
screen_y_pos_lookup_table:
        .fill 12, $00
tile_row_offset_lookup_table:
        .fill 20, $00
spr_enabled_lookup:
        .fill 8, $00
bss_segment_end:
