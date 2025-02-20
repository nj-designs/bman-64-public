#importonce

// CIA1 registers
.segment IO
*=$dc00 "CIA1"
.namespace cia1 {
        pra:       .byte $00 //$DC00
        prb:       .byte $00 //$DC01
        ddra:      .byte $00 //$DC02
        ddrb:      .byte $00 //$DC03
        ta_lo:     .byte $00 //$DC04
        ta_hi:     .byte $00 //$DC05
        tb_lo:     .byte $00 //$DC06
        tb_hi:     .byte $00 //$DC07
        tod_10ths: .byte $00 //$DC08
        tod_sec:   .byte $00 //$DC09
        tod_min:   .byte $00 //$DC0A
        tod_hr:    .byte $00 //$DC0B
        sdr:       .byte $00 //$DC0C
        icr:       .byte $00 //$DC0D
        cra:       .byte $00 //$DC0E
        crb:       .byte $00 //$DC0F
}

// CIA2 registers
.segment IO
*=$dd00 "CIA2"
.namespace cia2 {
        pra:       .byte $00 //$DD00
        prb:       .byte $00 //$DD01
        ddra:      .byte $00 //$DD02
        ddrb:      .byte $00 //$DD03
        ta_lo:     .byte $00 //$DD04
        ta_hi:     .byte $00 //$DD05
        tb_lo:     .byte $00 //$DD06
        tb_hi:     .byte $00 //$DD07
        tod_10ths: .byte $00 //$DD08
        tod_sec:   .byte $00 //$DD09
        tod_min:   .byte $00 //$DD0A
        tod_hr:    .byte $00 //$DD0B
        sdr:       .byte $00 //$DD0C
        icr:       .byte $00 //$DD0D
        cra:       .byte $00 //$DD0E
        crb:       .byte $00 //$DD0F
}
