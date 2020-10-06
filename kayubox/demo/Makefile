TOOLCHAIN_PREFIX ?= arm-none-eabi-

AS = $(TOOLCHAIN_PREFIX)as
CC = $(TOOLCHAIN_PREFIX)gcc
LD = $(TOOLCHAIN_PREFIX)ld
OBJCOPY = $(TOOLCHAIN_PREFIX)objcopy

# Verbosity. Change to empty string for verbose output
V := @

BUILD_DIR := build

ARCHFLAGS := -march=armv6 -mfpu=vfp -mfloat-abi=hard
ASFLAGS := $(ARCHFLAGS)
CCFLAGS := $(ARCHFLAGS) -mtune=arm1176jzf-s -c -std=c99 -O2
LDFLAGS := -T link.ld

SRCS := $(wildcard **.[sc])

OBJS := $(patsubst %.s, %.o, $(SRCS))
OBJS := $(patsubst %.c, %.o, $(OBJS))
OBJS := $(sort $(OBJS))
OBJS := $(addprefix $(BUILD_DIR)/, $(OBJS))

APP_ELF := $(BUILD_DIR)/a.out
APP_BIN := $(BUILD_DIR)/a.bin

all: $(APP_BIN)

$(BUILD_DIR)/%.o: %.s
	@ echo "  AS      $(notdir $<)"
	$(V) mkdir -p $(BUILD_DIR)/$(dir $<)
	$(V) $(AS) $< -o $@ $(ASFLAGS)

$(BUILD_DIR)/%.o: %.c
	@ echo "  CC      $(notdir $<)"
	$(V) mkdir -p $(BUILD_DIR)/$(dir $<)
	$(V) $(CC) $< -o $@ $(CCFLAGS)

$(APP_ELF): $(OBJS)
	@ echo "  LD      $@"
	$(V) $(LD) $(OBJS) -o $@ $(LDFLAGS)

$(APP_BIN): $(APP_ELF)
	@ echo "  OBJCOPY $@"
	$(V) $(OBJCOPY) -O binary $< $@

clean:
	$(RM) $(BUILD_DIR)

run: $(APP_BIN)
	echo "Not implemented"

.PHONY: all clean run
