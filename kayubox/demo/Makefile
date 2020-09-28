TOOLCHAIN_PREFIX ?= arm-none-eabi-

AS = $(TOOLCHAIN_PREFIX)as
LD = $(TOOLCHAIN_PREFIX)ld
OBJCOPY = $(TOOLCHAIN_PREFIX)objcopy

# Verbosity. Change to empty string for verbose output
V := @

BUILD_DIR := build

ASFLAGS := -march=armv6 -mfpu=vfp -mfloat-abi=hard
LDFLAGS := --entry 0

SRCS := $(wildcard **.s)

OBJS := $(patsubst %.s, %.o, $(SRCS))
OBJS := $(sort $(OBJS))
OBJS := $(addprefix $(BUILD_DIR)/, $(OBJS))

APP_ELF := $(BUILD_DIR)/a.out
APP_BIN := $(BUILD_DIR)/a.bin

all: $(APP_BIN)

$(BUILD_DIR)/%.o: %.s
	@ printf "  %-7s %s\n" AS $(notdir $<)
	$(V) mkdir -p $(BUILD_DIR)/$(dir $<)
	$(V) $(AS) $< -o $@ $(ASFLAGS)

$(APP_ELF): $(OBJS)
	@ printf "  %-7s %s\n" LD $@
	$(V) $(LD) $(OBJS) -o $@ $(LDFLAGS)

$(APP_BIN): $(APP_ELF)
	@ printf "  %-7s %s\n" OBJCOPY $@
	$(V) $(OBJCOPY) -O binary $< $@

clean:
	rm -rf $(BUILD_DIR)

run: $(APP_BIN)
	echo "Not implemented"

.PHONY: all clean run
