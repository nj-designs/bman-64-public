#importonce

.filenamespace levels

#import "level1/level1.asm"
#import "level2/level2.asm"

.segment Text0 "Levels"
// reg.a = level init func to call
exec_level_init_sub__x: {
  asl
  tax
  lda init_table+1,x
  pha
  lda init_table,x
  pha
  rts
}

.segment Data0 "Levels"
init_table:
        .word level1.init - 1
        .word level2.init - 1
