#importonce

.segment VICBank
*=VIC_BANK_BASE + $0000 "VICBank"

char_set_1:
.import binary "assets/map1-charset.bin"

.align 64
spr_font:
.import binary "assets/spr-set-font.bin"

.align 64
spr_game:
.import binary "assets/spr-set-game.bin"
