#pragma once

#include "prelude.hh"
#include "ble.hh"
#include "bootloader.hh"
#include "cfg.hh"
#include "color.hh"
#include "led.hh"
#include "log.hh"
#include "meta.hh"
#include "task.hh"
#include "time.hh"
#include "userapp.hh"

#ifdef __cplusplus
extern "C" {
#endif

int main(void);

void launch_led0(void);

void launch_dmx(void);

#ifdef __cplusplus
}
#endif
