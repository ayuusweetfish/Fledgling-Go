TOOLCHAIN_PREFIX ?= arm-none-eabi-

AS = $(TOOLCHAIN_PREFIX)as
CC = $(TOOLCHAIN_PREFIX)gcc
LD = $(TOOLCHAIN_PREFIX)ld
OBJCOPY = $(TOOLCHAIN_PREFIX)objcopy
READELF = $(TOOLCHAIN_PREFIX)readelf

WINDOWS := 0
ifeq ($(OS), Windows_NT)
  WINDOWS := 1
endif

ifeq ($(WINDOWS), 1)
  rm_rf = del /S /Q $(subst /,\,$1)
  mkdir = if not exist $(subst /,\,$1) mkdir $(subst /,\,$1)
else
  rm_rf = rm -rf $1
  mkdir = mkdir -p $1
endif

# Verbosity. Change to empty string for verbose output
V := @

BUILD_DIR := build

ARCHFLAGS := -march=armv6 -mfpu=vfp -mfloat-abi=hard
ASFLAGS := $(ARCHFLAGS) -g
CCFLAGS := $(ARCHFLAGS) -mtune=arm1176jzf-s -c -std=c99 -O2 -g -I../..
LDFLAGS := $(ARCHFLAGS) -Wl,-T,link.ld -lm -nostartfiles

SRCS := $(wildcard *.s) $(wildcard **/*.s) $(wildcard kx/*.c)

OBJS := $(patsubst %.s, %.o, $(SRCS))
OBJS := $(patsubst %.c, %.o, $(OBJS))
OBJS := $(sort $(OBJS))
OBJS := $(addprefix $(BUILD_DIR)/, $(OBJS))

APP_ELF := $(BUILD_DIR)/a.out
APP_BIN := $(BUILD_DIR)/a.bin
APP_MAP := $(APP_BIN).map

all: $(APP_BIN) $(APP_MAP)

$(BUILD_DIR)/%.o: %.s
	@ echo "  AS      $<"
	$(V) $(call mkdir, $(BUILD_DIR)/$(dir $<))
	$(V) $(AS) $< -o $@ $(ASFLAGS)

$(BUILD_DIR)/%.o: %.c
	@ echo "  CC      $<"
	$(V) $(call mkdir, $(BUILD_DIR)/$(dir $<))
	$(V) $(CC) $< -o $@ $(CCFLAGS)

$(APP_ELF): $(OBJS)
	@ echo "  LD      $@"
	$(V) $(CC) $(OBJS) -o $@ $(LDFLAGS)

$(APP_BIN): $(APP_ELF)
	@ echo "  OBJCOPY $@"
	$(V) $(OBJCOPY) -O binary $< $@

$(APP_MAP): $(APP_ELF)
	@ echo "  READELF $@"
	$(V) $(READELF) --debug-dump=decodedline $< > $@

clean:
	$(call rm_rf, $(BUILD_DIR))

run: $(APP_BIN)
	echo "Not implemented"

.PHONY: all clean run
