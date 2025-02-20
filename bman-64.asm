.cpu _6502

#import "const.asm"

// Define segments
// Only segments listed in .file below are included in file image. This shold be all code, data and graphics etc. No BSS stuff
.segmentdef ZPCPUPort [start=$0000, max=$0001]
.segmentdef ZPUnion   [start=ZP_SHARED_BASE, allowOverlap] //Per state usage
.segmentdef ZPCommon  [startAfter="ZPUnion", max=$00FF]
.segmentdef Stack     [start=$0100, max=$01FF]
.segmentdef BSSUnion  [start=BSS_SHARED_BASE, allowOverlap] //Per state usage
.segmentdef BSSCommon [startAfter="BSSUnion", max=$0800]
.segmentdef Basic     [start=$0801]
.segmentdef Start     [startAfter="Basic"]
.segmentdef Text0     [startAfter="Start"]
.segmentdef Data0     [startAfter="Text0",max=VIC_BANK_BASE-1]
.segmentdef VICBank   [start=VIC_BANK_BASE, max=VIC_BANK_BASE+$3fff]
.segmentdef Text1     [start=VIC_BANK_BASE+$4000]
.segmentdef Data1     [startAfter="Text1",max=$cfff]
.segmentdef IO        [start=$d000, max=$Dfff]
.segmentdef Text2     [start=$e000]
.segmentdef Data2     [startAfter="Text2",max=$fff9]
.segmentdef Vectors   [start=$FFFA, max=$FFFF]

// Start up
.segment Basic
*= $0801 "Upstart"
BasicUpstart(main.start)

// Import required source files
#import "main.asm"
#import "state-title-screen.asm"
#import "state-level-intro.asm"
#import "state-level-play.asm"
#import "cpu.asm"
#import "levels/levels.asm"
#import "maps/maps.asm"
#import "sprites.asm"
#import "vic-bank.asm"
#import "vic-io.asm"
#import "zp-common.asm"
#import "stack.asm"

// Generate output
.file [name=cmdLineVars.get("out_file"), segments="Basic,Start,Text0,Data0,VICBank"]

// Add exta text & data segments to .file if required
