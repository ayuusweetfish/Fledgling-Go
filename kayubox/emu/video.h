#ifndef kayubox_emu__video_h
#define kayubox_emu__video_h

#include <stdbool.h>
#include <stdint.h>

void video_init();
bool video_running();
void video_flush();
void video_poll_events();

void video_test();

#endif
