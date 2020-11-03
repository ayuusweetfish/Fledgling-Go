TOOLCHAIN_PREFIX ?= arm-none-eabi-

AS = $(TOOLCHAIN_PREFIX)as
OBJCOPY = $(TOOLCHAIN_PREFIX)objcopy

WINDOWS := 0
ifeq ($(OS), Windows_NT)
  WINDOWS := 1
endif

ifeq ($(WINDOWS), 1)
  rm_rf = del /S /Q $(subst /,\,$1)
else
  rm_rf = rm -rf $1
endif

# Verbosity. Change to empty string for verbose output
V := @

all: $(patsubst %.s, %.bin, $(wildcard *.s))

%.bin: %.s
	@ echo "  AS      $<"
	$(V) $(AS) $< -o $(<:%.s=%.o)
	$(V) $(OBJCOPY) -O binary $(<:%.s=%.o) $@
	$(V) $(call rm_rf, $(<:%.s=%.o))

clean:
	$(call rm_rf, $(wildcard *.bin))

.PHONY: all clean
