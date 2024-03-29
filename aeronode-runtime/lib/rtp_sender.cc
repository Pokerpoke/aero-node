/**
 * 
 * Copyright (c) 2017-2018 南京航空航天大学 航空通信网络研究室
 * 
 * @file
 * @author   姜阳 (j824544269@gmail.com)
 * @date     2017-11
 * @brief    RTP发送类
 * @version  0.0.1
 * 
 * Last Modified:  2018-10-24
 * Modified By:    Jiang Yang (pokerpoke@qq.com)
 * 
 */
#include "rtp_sender.h"
#include "logger.h"

namespace an
{
namespace core
{
RTPSender::RTPSender(const std::string ip,
                     const int port)
{
    dest_ip = ip;
    dest_port = port;
    // time_stamp = 44100.0;
    time_stamp = 8000.0;
    payload_type = 0;
    // host_port = 13372;
    mark = false;

    init();
}

int RTPSender::init()
{
    uint32_t t_dest_ip;
    t_dest_ip = inet_addr(dest_ip.c_str());
    if (t_dest_ip == INADDR_NONE)
    {
        LOG(ERROR) << "Bad IP address specified";
        return -1;
    }
    t_dest_ip = ntohl(t_dest_ip);

    sessionparams.SetOwnTimestampUnit(1.0 / time_stamp);
    sessionparams.SetAcceptOwnPackets(true);

    // transparams.SetPortbase(host_port);

    if ((err = session.Create(sessionparams, &transparams)) < 0)
    {
        LOG(ERROR) << jrtplib::RTPGetErrorString(err);
        return -1;
    }

    jrtplib::RTPIPv4Address addr(t_dest_ip, dest_port);
    if ((err = session.AddDestination(addr)) < 0)
    {
        LOG(ERROR) << jrtplib::RTPGetErrorString(err);
        return -1;
    }

    session.SetDefaultPayloadType(payload_type);
    session.SetDefaultMark(mark);
    session.SetDefaultTimestampIncrement(time_stamp);

    return 0;
}

int RTPSender::write(const char *input_buffer,
                     const int input_buffer_size)
{
    // int r = input_buffer_size;
    // if (r < MTU)
    // {
    if ((err = session.SendPacket((char *)input_buffer, input_buffer_size)) < 0)
    {
        LOG(ERROR) << jrtplib::RTPGetErrorString(err);
        return -1;
    }
    // }
    // else
    // {
    //     while (r > 0)
    //     {
    //         err = session.SendPacket((char *)input_buffer + (input_buffer_size - r), 1200);
    //         r -= 1200;
    //         LOG(INFO) << r;
    //     }
    // }

    return 0;
}

RTPSender::~RTPSender()
{
    session.BYEDestroy(jrtplib::RTPTime(10, 0), 0, 0);
}
} // namespace core
} // namespace an