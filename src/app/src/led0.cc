#include "main.hh"
#include "periph/spi.hh"
#include "ble/led.hh"

#define transcoder_t spi::transcode_8mhz

void launch_led0()
{
    static uint8_t raw_bytes_0[(transcoder_t::bytes_per_led * MAX_LEDS_PER_THREAD) + (transcoder_t::bytes_per_reset * 2)] = {};
    static uint8_t raw_bytes_1[(transcoder_t::bytes_per_led * MAX_LEDS_PER_THREAD) + (transcoder_t::bytes_per_reset * 2)] = {};
    static auto buf_0 = buffer(raw_bytes_0, sizeof(raw_bytes_0));
    static auto buf_1 = buffer(raw_bytes_1, sizeof(raw_bytes_1));
    static auto transcode0 = transcoder_t(buf_0);
    static auto transcode1 = transcoder_t(buf_1);
    static auto transport = spi::transport(spi::SPI0);
    static auto thread = led::thread(&transcode0, &transcode1, &transport); /* thread block must be statically allocated */
    static auto renderer = led::service_0();

    ret_code_t ret;

    ret = led::service_0().init();
    APP_ERROR_CHECK(ret);

    auto spi_init = spi::spi_init {
        .frequency = spi::FREQ_8M,
        .mosi = 29,
        .sck = 28,
    };

    ret = transport.init(spi_init);
    APP_ERROR_CHECK(ret);

    ret = thread.init("LED0");
    APP_ERROR_CHECK(ret);

    thread.set_renderer(&renderer);
}
