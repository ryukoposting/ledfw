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
#include "dmx.hh"
#include "userapp.hh"

#ifdef __cplusplus
extern "C" {
#endif

int main(void);

dmx::thread *launch_dmx(void);

led::thread *launch_led0(dmx::thread *dmx_thread);

#ifdef __cplusplus
}
#endif
