CC := gcc
CMAKE := cmake
STRIP := strip

# Verbosity
# Change to empty string for verbose output
V := @

ifdef DEBUG
OPT_FLAGS := -g -Og
else
OPT_FLAGS := -O2
endif

MAKE_FLAGS := -j4
C_OPTIONS := -std=c99 -Wall $(OPT_FLAGS)
INCLUDES := -I. -I./ext/unicorn/include -I./ext/glfw/include

DIST_DIR := dist

ifeq ($(CROSS_WIN), 1)
  CC := x86_64-w64-mingw32-gcc
  STRIP := x86_64-w64-mingw32-strip
  BUILD_DIR := build_win
  STATIC_LIBS := ext/build_win/libunicorn.a ext/build_win/glfw/src/libglfw3.a
else
  BUILD_DIR := build
  STATIC_LIBS := ext/build/libunicorn.a ext/build/glfw/src/libglfw3.a
endif

STATIC_LIB_TARGETS := $(patsubst %.a, %.a.target, $(STATIC_LIBS))

UNAME := $(shell uname)

ifeq ($(CROSS_WIN), 1)
  LDFLAGS := -lm -lopengl32 -lgdi32 -static -lpthread
else
  ifeq ($(UNAME), Darwin)
    C_OPTIONS += -D_DARWIN_C_SOURCE
    LDFLAGS := -framework Cocoa -framework OpenGL -framework IOKit
  endif
  ifeq ($(UNAME), Linux)
    C_OPTIONS += -D_XOPEN_SOURCE=700 -D_BSD_SOURCE -D_GNU_SOURCE
    LDFLAGS := -lGL -lX11 -lm -ldl
  endif
endif

SRCS := $(wildcard *.c)

OBJS := $(patsubst %.c, %.o, $(SRCS))
OBJS := $(sort $(OBJS))
OBJS := $(addprefix $(BUILD_DIR)/, $(OBJS))
EMU_EXEC := $(BUILD_DIR)/emu

ifeq ($(CROSS_WIN), 1)
  EMU_EXEC := $(EMU_EXEC).exe
endif

CFLAGS := $(C_OPTIONS) $(INCLUDES)

exec: $(EMU_EXEC)
libs: $(STATIC_LIB_TARGETS)
all:
	$(V) $(MAKE) libs
	$(V) $(MAKE) exec

dist: exec
	$(V) mkdir -p $(DIST_DIR)
	$(V) cp $(EMU_EXEC) $(DIST_DIR)
	@ printf "  %-7s %s\n" STRIP $(DIST_DIR)/$(notdir $(EMU_EXEC))
	$(V) $(STRIP) $(DIST_DIR)/$(notdir $(EMU_EXEC))

ext/build/libunicorn.a.target: CMD=$(MAKE) -C ext/unicorn unicorn UNICORN_DEBUG=no UNICORN_ARCHS=arm UNICORN_STATIC=yes UNICORN_SHARED=no $(MAKE_FLAGS)
ext/build/libunicorn.a.target:
	@ printf "  %-7s %s\n" MAKE $@
	$(V) $(CMD) || ($(MAKE) -C ext/unicorn clean && $(CMD))
	$(V) mkdir -p $(dir $@) && cp ext/unicorn/libunicorn.a $(basename $@)

ext/build_win/libunicorn.a.target: CMD=$(MAKE) -C ext/unicorn unicorn UNICORN_DEBUG=no UNICORN_ARCHS=arm UNICORN_STATIC=yes UNICORN_SHARED=no CROSS=x86_64-w64-mingw32 UNAME_S=MINGW $(MAKE_FLAGS)
ext/build_win/libunicorn.a.target:
	@ printf "  %-7s %s\n" MAKE $@
	$(V) $(CMD) || ($(MAKE) -C ext/unicorn clean && $(CMD))
	$(V) mkdir -p $(dir $@) && cp ext/unicorn/unicorn.a $(basename $@)

ext/build/glfw/src/libglfw3.a.target:
	@ printf "  %-7s %s\n" CMAKE $@
	$(V) mkdir -p ext/build/glfw
	$(V) cd ext/build/glfw && $(CMAKE) ../../glfw -DBUILD_SHARED_LIBS=OFF -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF -DGLFW_BUILD_DOCS=OFF
	$(V) $(MAKE) -C ext/build/glfw glfw $(MAKE_FLAGS)

ext/build_win/glfw/src/libglfw3.a.target:
	@ printf "  %-7s %s\n" CMAKE $@
	$(V) mkdir -p ext/build_win/glfw
	$(V) cd ext/build_win/glfw && $(CMAKE) ../../glfw -DBUILD_SHARED_LIBS=OFF -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF -DGLFW_BUILD_DOCS=OFF -DCMAKE_TOOLCHAIN_FILE=CMake/x86_64-w64-mingw32.cmake
	$(V) $(MAKE) -C ext/build_win/glfw glfw $(MAKE_FLAGS)

$(BUILD_DIR)/%.o: FLATDIR = $(subst ./, , $(firstword $(subst /, , $(dir $<)))/)
$(BUILD_DIR)/%.o: %.c
	@ printf "  %-7s %-16s %s\n" CC $(FLATDIR)$(notdir $<) "$(C_OPTIONS)"
	$(V) mkdir -p $(BUILD_DIR)/$(dir $<)
	$(V) $(CC) -c $< -o $@ $(CFLAGS)

$(EMU_EXEC): $(OBJS) $(STATIC_LIBS)
	@ printf "  %-7s %s\n" LD $@
	$(V) $(CC) $^ -o $@ $(LDFLAGS)

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(DIST_DIR)

clean_libs:
	cd ext/unicorn && make clean
	rm -rf ext/build ext/build_win

clean_all: clean_libs
	rm -rf build build_win

.PHONY: clean all exec dist libs $(STATIC_LIB_TARGETS)
