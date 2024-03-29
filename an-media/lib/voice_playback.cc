/**
 * 
 * Copyright (c) 2018 NUAA AeroLab
 * 
 * @file
 * @author   Jiang Yang (pokerpoke@qq.com)
 * @date     2018-10
 * @brief    
 * @version  0.0.1
 * 
 * Last Modified:  2018-10-26
 * Modified By:    Jiang Yang (pokerpoke@qq.com)
 * 
 */
/*******************************************************************************
 * 
 * Copyright (c) 2018 南京航空航天大学 航空通信网络研究室
 * 
 * @author   姜阳 (j824544269@gmail.com)
 * @date     2017-11
 * @brief    音频回放
 * @version  0.0.1
 * 
 * Last Modified:  2018-01-08
 * Modified By:    姜阳 (j824544269@gmail.com)
 * 
 ******************************************************************************/
#include "aeronode/logger.h"
#include "voice_playback.h"

namespace an
{
namespace media
{
/** 
 * @brief 音频回放构造函数，设定相关参数
 * 
 * @param	dev 设备名称，可以传入default
 * 
 */
VoicePlayback::VoicePlayback(const std::string &dev) : VoiceBase(dev)
{
    if (!DEVICE_OPENED)
        open_device();
    if (!PARAMS_SETED)
        set_params();

    int err;

    silence_frames = 256;
    silence = (char *)calloc(silence_frames * 4, sizeof(char));
    if ((err = snd_pcm_format_set_silence(format, silence, silence_frames * 2)) < 0)
        LOG(INFO) << "Set silence failed.";
    snd_pcm_writei(handle, silence, silence_frames);
    snd_pcm_writei(handle, silence, silence_frames);
}

/** 
 * @brief 音频回放析构函数，分配输出缓存空间
 * 
 */
VoicePlayback::~VoicePlayback()
{
    free(silence);
}

/** 
 * @brief 打开设备
 * 
 * @retval	0	成功
 * @retval	-1	失败
 * 
 */
int VoicePlayback::open_device()
{
    if ((err = snd_pcm_open(&handle,
                            device,
                            SND_PCM_STREAM_PLAYBACK,
                            0)) < 0)
    {
        LOG(ERROR) << "Playback device open error.";
        DEVICE_OPENED = false;
        return -1;
    }
    else
    {
        LOG(INFO) << "Playback device \"" << device << "\" open success.";
        DEVICE_OPENED = true;
    }

    return 0;
}

/** 
 * @brief 音频回放
 * 
 * 音频回放，将buffer中的音频信息播放出来
 * 
 * @param[in]   *input_buffer	输入缓存
 * @param[in]	input_buffer_size	输入缓存大小
 * @retval  0	success
 * @todo	添加出错时的返回值，写入次数限制，避免死循环
 * 
 */
int VoicePlayback::playback(const char *_input_buffer,
                            const long input_buffer_size) const
{
    // snd_pcm_writei(handle, silence, 32);
    int err = 0;
    char *input_buffer = const_cast<char *>(_input_buffer);
    long r = input_buffer_size / bits_per_frame * 8;

    while (r > 0)
    {
        snd_pcm_wait(handle, 100);
        do
        {
            err = snd_pcm_writei(handle,
                                 input_buffer,
                                 frames);
            // Underrun happened
            if (err == -EPIPE)
            {
                LOG(WARN) << "PCM underrun happened.";
                snd_pcm_prepare(handle);
                continue;
            }
        } while (err < 0);
        r -= err;
        input_buffer += err * bits_per_frame / 8;
#ifdef ENABLE_DEBUG
        LOG(INFO) << "Write buffer success.";
#endif
    }
    return 0;
}
} // namespace media
} // namespace an