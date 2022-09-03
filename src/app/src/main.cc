#include "main.hh"
#include "ble/meta.hh"
#include "ble/userapp.hh"
#include "periph/spi.hh"

#include "fds.h"
#include "task.h"
#include "ble_dfu.h"
#include "app_error_weak.h"
#include "nrf_log.h"
#include "nrf_pwr_mgmt.h"
#include "nrf_sdm.h"
#include "nrf_log_ctrl.h"
#include "nrf_log_default_backends.h"
#include "nrf_drv_clock.h"
#include "nrf_dfu_ble_svci_bond_sharing.h"
#include "nrf_svci_async_function.h"
#include "nrf_svci_async_handler.h"

static uint8_t m_heap[configTOTAL_HEAP_SIZE] __attribute__((aligned(8)));

int main()
{
    const HeapRegion_t heap_regions[] = {
        { m_heap, configTOTAL_HEAP_SIZE },
        { nullptr, 0 }
    };
    vPortDefineHeapRegions(heap_regions);

    ret_code_t ret;

    meta::init();

    /* general system setup: log, clock, power mgmt, etc */
    ret = NRF_LOG_INIT(time::ticks);
    APP_ERROR_CHECK(ret);
    NRF_LOG_DEFAULT_BACKENDS_INIT();

    ret = nrf_pwr_mgmt_init();
    APP_ERROR_CHECK(ret);

    ret = nrf_drv_clock_init();
    APP_ERROR_CHECK(ret);

    nrf_drv_clock_lfclk_request(NULL);

    ret = ble_dfu_buttonless_async_svci_init();
    APP_ERROR_CHECK(ret);

    ret = task::init();
    APP_ERROR_CHECK(ret);

    ret = log::init_thread();
    APP_ERROR_CHECK(ret);

    ret = cfg::init();
    APP_ERROR_CHECK(ret);


    /* userapp runtime setup */
    ret = userapp::init();
    APP_ERROR_CHECK(ret);

    ret = userapp::init_thread();
    APP_ERROR_CHECK(ret);


    /* BLE setup: advertising, services */
    ret = ble::init_thread(false);  // TODO: button for bond erase
    APP_ERROR_CHECK(ret);

    ret = ble::init();
    APP_ERROR_CHECK(ret);

    ret = meta::service().init();
    APP_ERROR_CHECK(ret);

    ret = userapp::service().init();
    APP_ERROR_CHECK(ret);

    ret = dfu::init_ble_service();
    APP_ERROR_CHECK(ret);

    static const char adv_text[] = "hello";
    ble::set_advertising_data((void const*)adv_text, sizeof(adv_text)-1);

    /* launch DMX task */
    auto dmx_thread = launch_dmx();

    /* launch tasks for each LED channel */
    launch_led0(dmx_thread);

    vTaskStartScheduler();

    unreachable();
}

void app_error_fault_handler(uint32_t id, uint32_t pc, uint32_t info)
{
    __disable_irq();
    NRF_LOG_FINAL_FLUSH();

#ifndef DEBUG
    NRF_LOG_ERROR("Fatal error");
#else
    switch (id)
    {
#if defined(SOFTDEVICE_PRESENT) && SOFTDEVICE_PRESENT
        case NRF_FAULT_ID_SD_ASSERT:
            NRF_LOG_ERROR("SOFTDEVICE: ASSERTION FAILED");
            break;
        case NRF_FAULT_ID_APP_MEMACC:
            NRF_LOG_ERROR("SOFTDEVICE: INVALID MEMORY ACCESS");
            break;
#endif
        case NRF_FAULT_ID_SDK_ASSERT:
        {
            assert_info_t * p_info = (assert_info_t *)info;
            NRF_LOG_ERROR("ASSERTION FAILED at %s:%u",
                          p_info->p_file_name,
                          p_info->line_num);
            break;
        }
        case NRF_FAULT_ID_SDK_ERROR:
        {
            error_info_t * p_info = (error_info_t *)info;
            NRF_LOG_ERROR("ERROR %u [%s] at %s:%u\r\nPC at: 0x%08x",
                          p_info->err_code,
                          nrf_strerror_get(p_info->err_code),
                          p_info->p_file_name,
                          p_info->line_num,
                          pc);
             NRF_LOG_ERROR("End of error report");
            break;
        }
        default:
            NRF_LOG_ERROR("UNKNOWN FAULT at 0x%08X", pc);
            break;
    }
    #endif

    NRF_BREAKPOINT_COND;
    // On assert, the system can only recover with a reset.

#ifndef DEBUG
    NRF_LOG_WARNING("System reset");
    NVIC_SystemReset();
#else
    app_error_save_and_stop(id, pc, info);
#endif // DEBUG
}

extern "C" void __cxa_pure_virtual()
{
    APP_ERROR_HANDLER(ERROR_PURE_VIRTUAL);
}

extern "C" void vApplicationMallocFailedHook(void)
{
    APP_ERROR_HANDLER(NRF_ERROR_NO_MEM);
}
