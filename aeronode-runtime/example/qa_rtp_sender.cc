/**
 * 
 * Copyright (c) 2018 南京航空航天大学 航空通信网络研究室
 * 
 * @file
 * @author   姜阳 (j824544269@gmail.com)
 * @date     2017-12
 * @brief    rtp发送端例程
 * @version  0.0.1
 * 
 * Last Modified:  2018-10-23
 * Modified By:    Jiang Yang (pokerpoke@qq.com)
 * 
 */
#include "aeronode/logger.h"
#include "aeronode/an-media/rtp_sender.h"
#include "aeronode/an-media/voice_capture.h"

using namespace std;
using namespace an::core;

int main()
{
    logger_init();

    RTPSender s("127.0.0.1", 13374);
    VoiceCapture c("default");

    // for (size_t i = 0; i < 10; i++)
    while (1)
    {
        // s.write((char *)"1234567890", 10);
        c.capture();
        s.write(c.output_buffer, c.output_buffer_size);
    }

    return 0;
}