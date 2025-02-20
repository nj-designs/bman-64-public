#importonce

.const ZP_SHARED_BASE=$0002
.const BSS_SHARED_BASE=$0200

// All game constants go here
.const VIC_BANK_BASE = $4000

.const SCREEN_BASE = (VIC_BANK_BASE + $3800)

.const SCREEN_COLOUR_RAM_OFFSET = $D800 - SCREEN_BASE

.const SPR_FONT_BASE_PTR = (spr_font - VIC_BANK_BASE) / 64
.const SPR_GAME_BASE_PTR = (spr_game - VIC_BANK_BASE) / 64

.const SCREEN_X_START = 24
.const SCREEN_Y_START = 50

.const TILE_X_COUNT = 20
.const TILE_Y_COUNT = 12

.const TILE_SIZE_IN_PIXELS = 16

// Enumerate all possible states
.enum {
  STATE_TILE_SCREEN,
  STATE_LEVEL_INTRO,
  STATE_LEVEL_PLAY,
  STATE_LEVEL_COMPLETE,
  STATE_GAME_OVER,

  STATE_INVALID = $FF
}

// Enumerate all possible state functions
.enum {
  RUN_STATE,
  ENTER_STATE,
  EXIT_STATE
}


// JOYSTICK_2 BIT POS
.enum {
        JOY2_UP = (1<<0),
        JOY2_DOWN = (1<<1),
        JOY2_LEFT = (1<<2),
        JOY2_RIGHT = (1<<3),
        JOY2_FIRE = (1<<4)
}
