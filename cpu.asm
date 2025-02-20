#importonce

.filenamespace cpu


.segment ZPCPUPort "ZP Cpu Port"
.zp {
data_dir_reg:
        .byte $00 // $0000
port_reg:
        .byte $00 // $0001
}
