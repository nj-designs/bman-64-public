#importonce

.filenamespace vector

.segment Vectors "Vectors"
nmi:
        .word $0000 // $FFFA
reset:
        .word $0000 // $FFFC
irq:
        .word $0000 // $FFFE
