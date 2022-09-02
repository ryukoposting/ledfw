#define NRF_LOG_MODULE_NAME dmx
#include "main.hh"
#include "dmx.hh"
#include "ble/dmx.hh"
#include "periph/uarte.hh"
#include "ble/led.hh"
NRF_LOG_MODULE_REGISTER();

dmx::thread *launch_dmx()
{
    static auto transport = uarte::transport(uarte::id::UARTE1);
    static auto thread = dmx::thread();

    ret_code_t ret;

    auto uart_init = uarte::uarte_init {
        .baud = uarte::BAUD_250K,
        .rx = 31,
        .two_stop_bits = true
    };

    ret = transport.init(uart_init);
    APP_ERROR_CHECK(ret);

    ret = thread.init();
    APP_ERROR_CHECK(ret);

    ret = dmx::service().init(&thread);
    APP_ERROR_CHECK(ret);

    thread.set_frame_buf(transport.frame_buf());

    return &thread;
}
