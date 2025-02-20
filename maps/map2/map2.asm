#importonce

.filenamespace map2

.segment Text0 "Map2"
init:
        lda #<map_data
        sta maps.current_ptr
        lda #>map_data
        sta maps.current_ptr + 1
        rts

.segment Data0 "Map2"
map_data:
        .import binary "bman-64 - (8bpc, 20x12) [00,01] SubMap.bin"
        .byte $ff // Map termination
