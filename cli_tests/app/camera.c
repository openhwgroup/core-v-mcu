
#define __CAMERA_C__

#include <FreeRTOS.h>
#include <queue.h>
#include <drivers/include/camera.h>
#include <app/include/i2c_task.h>


unsigned char camera_isAwaked = 0;

void himaxRegWrite(uint8_t cam, unsigned int addr, unsigned char value){
        i2c_16write8(cam,addr,value);
}

unsigned char himaxRegRead(uint8_t cam, unsigned int addr){
        return i2c_16read16(cam,addr);
}

void himaxBoot(uint8_t cam) {
    unsigned int i;
    for(i=0; i<(sizeof(himaxRegInit)/sizeof(reg_cfg_t)); i++){
        himaxRegWrite(cam,himaxRegInit[i].addr, himaxRegInit[i].data);
    }
}
/*
static void _himaxMode(rt_camera_t *cam, unsigned char mode){
    himaxRegWrite(cam, MODE_SELECT, mode);
}

static void _himaxWakeUP (rt_camera_t *cam){
    if (!camera_isAwaked){
        _himaxMode(cam, HIMAX_Streaming);
        camera_isAwaked = 1;
    }
}

void _himaxReset(rt_camera_t *cam){
    himaxRegWrite(cam, SW_RESET, HIMAX_RESET);
    vTaskDelay(1); // delay 20 us  (1 tick = 1mS)
    //    while (himaxRegRead(cam, MODE_SELECT) != HIMAX_Standby){
    //        himaxRegWrite(cam, SW_RESET, HIMAX_RESET);
    //        rt_time_wait_us(50);
    // }
}

void _himaxStandby(rt_camera_t *cam){
    _himaxMode(cam, HIMAX_Standby);
}

void himaxGrayScale(rt_camera_t *cam, unsigned char value){
    himaxRegWrite(cam, BLC_CFG, ENABLE);
    himaxRegWrite(cam, BLC_TGT, value);
    himaxRegWrite(cam, BLI_EN, ENABLE);
    himaxRegWrite(cam, BLC2_TGT, value);
}

void himaxFrameRate(rt_camera_t *cam){
    himaxRegWrite(cam, FRAME_LEN_LINES_H, 0x02);
    himaxRegWrite(cam, FRAME_LEN_LINES_L, 0x1C);
    himaxRegWrite(cam, LINE_LEN_PCK_H, 0x01);
    himaxRegWrite(cam, LINE_LEN_PCK_L, 0x72);
}

static void _himaxParamInit(rt_camera_t *dev_cam, rt_cam_conf_t *cam_conf){
    cam_conf->cpiCfg = UDMA_CHANNEL_CFG_SIZE_16;
    memcpy(&dev_cam->conf, cam_conf, sizeof(rt_cam_conf_t));
}

// TODO: For each case, should add the configuration of camera if necessary.
static void _himaxConfig(rt_cam_conf_t *cam){
    plpUdmaCamCustom_u _cpi;
    _cpi.raw = 0;
    switch (cam->resolution){
        case QQVGA:
            break;
        case QVGA:
        default:
            _cpi.cfg_size.row_length = ((QVGA_W+4)/2-1);
    }
    hal_cpi_size_set(0, _cpi.raw);

    _cpi.raw = 0;

    switch (cam->format){
        case HIMAX_MONO_COLOR:
        case HIMAX_RAW_BAYER:
            _cpi.cfg_glob.format = BYPASS_BIGEND;
            break;
        default:
            rt_warning("[CAM Himax] No this format, set the format as default: RAW_BAYER\n");
            _cpi.cfg_glob.format = BYPASS_BIGEND;
            break;
    }
    _cpi.cfg_glob.framedrop_enable = cam->frameDrop_en & MASK_1BIT;
    _cpi.cfg_glob.framedrop_value = cam->frameDrop_value & MASK_6BITS;
    _cpi.cfg_glob.frameslice_enable = cam->slice_en & MASK_1BIT;
    _cpi.cfg_glob.shift = cam->shift & MASK_4BITS;
    _cpi.cfg_glob.enable = DISABLE;

    hal_cpi_glob_set(0, _cpi.raw);
}

void __rt_himax_close(rt_camera_t *dev_cam, rt_event_t *event){
    int irq = rt_irq_disable();
    _camera_stop();
    if (is_i2c_active())
        rt_i2c_close(dev_cam->i2c, NULL);
    rt_free(RT_ALLOC_FC_DATA, (void*)dev_cam, sizeof(rt_camera_t));
    plp_udma_cg_set(plp_udma_cg_get() & ~(1<<ARCHI_UDMA_CAM_ID(0)));
    if (event) __rt_event_enqueue(event);
    rt_irq_restore(irq);
}

void __rt_himax_control(rt_camera_t *dev_cam, rt_cam_cmd_e cmd, void *_arg){
    rt_trace(RT_TRACE_DEV_CTRL, "[CAM] Control command (cmd: %d)\n", cmd);
    unsigned int *arg = (unsigned int *)_arg;
    int irq = rt_irq_disable();
    switch (cmd){
        case CMD_RESOL:
            dev_cam->conf.resolution = *arg;
            break;
        case CMD_FORMAT:
            dev_cam->conf.format = *arg;
            break;
        case CMD_FPS:
            dev_cam->conf.fps = *arg;
            break;
        case CMD_SLICE:
            {
                rt_img_slice_t *slicer = (rt_img_slice_t *) arg;
                _camera_extract(&dev_cam->conf, slicer);
            }
            break;
        case CMD_SHIFT:
            _camera_normlize(&dev_cam->conf, arg);
            break;
        case CMD_FRAMEDROP:
            _camera_drop_frame(&dev_cam->conf, arg);
            break;
        case CMD_INIT:
            _himaxWakeUP(dev_cam);
            _himaxConfig(&dev_cam->conf);
            break;
        case CMD_START:
	  _himaxWakeUP(dev_cam);
            _camera_start();
            break;
        case CMD_PAUSE:
            _camera_stop();
            break;
        case CMD_STOP:
            _himaxStandby(dev_cam);
            _camera_stop();
            camera_isAwaked = 0;
            break;
        default:
            rt_warning("[CAM] This Command %d is not disponible for Himax camera\n", cmd);
            break;
    }
    rt_irq_restore(irq);
}

static void __rt_camera_conf_init(rt_camera_t *dev, rt_cam_conf_t* cam){
    _himaxParamInit(dev, cam);
}

rt_camera_t* __rt_himax_open(int channel, rt_cam_conf_t* cam, rt_event_t*event){

    rt_trace(RT_TRACE_DEV_CTRL, "[CAM] Opening Himax camera\n");
    printf("[CAM] Opening Himax camera\n");
    rt_camera_t *camera = NULL;

    camera = rt_alloc(RT_ALLOC_FC_DATA, sizeof(rt_camera_t));
    printf("Alloc worked camera = %08x\n", (unsigned int)camera);
    if (camera == NULL) return NULL;

    camera->channel = channel;

    __rt_camera_conf_init(camera, cam);
    /*
    if (is_i2c_active())
    {

        rt_i2c_conf_init(&camera->i2c_conf);
        camera->i2c_conf.cs = 0x48;
        camera->i2c_conf.id = cam->control_id;

        if (camera->i2c_conf.id == -1)
        {
#if PULP_CHIP_FAMILY == CHIP_GAP
          camera->i2c_conf.id = 1;
#else
          camera->i2c_conf.id = 0;
#endif
        }
        camera->i2c_conf.max_baudrate = 200000;

        camera->i2c = rt_i2c_open(NULL, &camera->i2c_conf, NULL);
        if (camera->i2c == NULL) printf ("Filed to open I2C\n");
        // the I2C of Himax freq: 400kHz max.

   }
    *
    printf("udma setup\n");
    plp_udma_cg_set(plp_udma_cg_get() | (1<<ARCHI_UDMA_CAM_ID(0)));   // Activate CAM channel

    soc_eu_fcEventMask_setEvent(UDMA_EVENT_ID(ARCHI_UDMA_CAM_ID(0)));
    printf("himax reset\n");
    _himaxReset(camera);
        printf("himax boot\n");
    _himaxBoot(camera);

    if (event) __rt_event_enqueue(event);
    return camera;
}

void __rt_himax_capture(rt_camera_t *dev_cam, void *buffer, size_t bufferlen, rt_event_t *event)
{
    rt_trace(RT_TRACE_CAM, "[CAM HIMAX] Capture (buffer: %p, size: 0x%x)\n", buffer, bufferlen);

    int irq = rt_irq_disable();

    rt_event_t *call_event = __rt_wait_event_prepare(event);

    rt_periph_copy_init(&call_event->implem.copy, 0);

    rt_periph_copy(&call_event->implem.copy, UDMA_CHANNEL_ID(dev_cam->channel) + 0, (unsigned int) buffer, bufferlen, dev_cam->conf.cpiCfg, call_event);

    __rt_wait_event_check(event, call_event);

    rt_irq_restore(irq);
}

rt_cam_dev_t himax_desc = {
    .open      = &__rt_himax_open,
    .close     = &__rt_himax_close,
    .control   = &__rt_himax_control,
    .capture   = &__rt_himax_capture
};

RT_FC_BOOT_CODE void __attribute__((constructor)) __rt_himax_init()
{
  camera_isAwaked = 0;
}
*/
