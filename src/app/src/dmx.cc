#define NRF_LOG_MODULE_NAME dmx
#include "main.hh"
#include "dmx.hh"
#include "periph/uarte.hh"
#include "ble/led.hh"
NRF_LOG_MODULE_REGISTER();

void launch_dmx()
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

    thread.set_frame_buf(transport.frame_buf());

    thread.set_on_new_chan_values(nullptr, [](uint8_t const *vals, size_t chan, size_t len, void *context) {
        unused(chan);
        unused(context);

        constexpr auto max_delay = MINIMUM_REFRESH_RATE_MSEC / MAX_LED_CHANNELS;
        static_assert(max_delay > 0);

        ret_code_t ret;

        ret = led::service_0().set_dmx(vals, len, pdMS_TO_TICKS(max_delay));
        if (ret != NRF_SUCCESS) {
            NRF_LOG_WARNING("service_0::set_dmx returned %u", ret);
        }
#if MAX_LED_CHANNELS >= 2
        ret = led::service_1().set_dmx(vals, len, pdMS_TO_TICKS(max_delay));
        if (ret != NRF_SUCCESS) {
            NRF_LOG_WARNING("service_1::set_dmx returned %u", ret);
        }
#endif
#if MAX_LED_CHANNELS >= 3
        ret = led::service_2().set_dmx(vals, len, pdMS_TO_TICKS(max_delay));
        if (ret != NRF_SUCCESS) {
            NRF_LOG_WARNING("service_2::set_dmx returned %u", ret);
        }
#endif
#if MAX_LED_CHANNELS >= 4
        ret = led::service_3().set_dmx(vals, len, pdMS_TO_TICKS(max_delay));
        if (ret != NRF_SUCCESS) {
            NRF_LOG_WARNING("service_3::set_dmx returned %u", ret);
        }
#endif
    });
}
