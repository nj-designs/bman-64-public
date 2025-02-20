# Simple makefile to build/run C64 projects
GAME_NAME := bman-64

JRE ?= $(shell which java)
KA ?= $(CURDIR)/tools/KickAss.jar

ASSETS_DIR := assets
MAPS_DIR := maps
LEVELS_DIR := levels

ASSET_FILES := $(wildcard $(ASSETS_DIR)/*.asm)
MAP_FILES := $(shell find $(MAPS_DIR)/ -name "*.asm")
LEVEL_FILES := $(shell find $(LEVELS_DIR)/ -name "*.asm")

SRC_FILES += cia-io.asm
SRC_FILES += const.asm
SRC_FILES += cpu.asm
SRC_FILES += frame-counter.asm
SRC_FILES += macros.asm
SRC_FILES += main.asm
SRC_FILES += random.asm
SRC_FILES += sprites.asm
SRC_FILES += stack.asm
SRC_FILES += state-level-intro.asm
SRC_FILES += state-level-play.asm
SRC_FILES += state-title-screen.asm
SRC_FILES += utils.asm
SRC_FILES += vectors.asm
SRC_FILES += vic-io.asm
SRC_FILES += zp-common.asm

SRC_FILES += $(ASSET_FILES) $(MAP_FILES) $(LEVEL_FILES)

# Kick Assembler options
KA_OPTS := -showmem -symbolfile -bytedumpfile $(GAME_NAME).dump -vicesymbols :out_file=$(GAME_NAME).prg

VICE ?= $(shell which x64sc)
VICE_RUN_OPTS := +confirmonexit -silent
VICE_DEBUG_OPTS := +confirmonexit -moncommands vice64-mon.txt -keepmonopen -silent

# build rules from here on down
.PHONY: run clean run debug

all: $(GAME_NAME).prg

$(GAME_NAME).prg: $(SRC_FILES) $(GAME_NAME).asm
	@echo "Building $@"
	$(JRE) -jar $(KA) $(KA_OPTS) $(GAME_NAME).asm

run: $(GAME_NAME).prg
	$(VICE) $(VICE_RUN_OPTS) --autostart $<

debug: $(GAME_NAME).prg
	$(VICE) $(VICE_DEBUG_OPTS) --autostart $<

clean:
	@rm -fv $(GAME_NAME).dump $(GAME_NAME).prg $(GAME_NAME).info $(GAME_NAME).sym $(GAME_NAME).vs
