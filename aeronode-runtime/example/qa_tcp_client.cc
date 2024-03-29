/**
 * 
 * Copyright (c) 2017 南京航空航天大学 航空通信网络研究室
 * 
 * @file
 * @author   姜阳 (j824544269@gmail.com)
 * @date     2017-12
 * @brief    
 * @version  0.0.1
 * 
 * Last Modified:  2018-07-03
 * Modified By:    姜阳 (j824544269@gmail.com)
 * 
 */
#include <iostream>
#include <string>

#include "aeronode/tcp_client.h"
#include "aeronode/logger.h"

using namespace an::core;
using namespace std;

int main()
{
    logger_init();

    std::string data("12321312312312\n");
    TCPClient s("127.0.0.1", 13374);

    for (int i = 0; i < 10; i++)
    {
        LOG(INFO) << "Sending packet " << i;
        s.write(data.c_str());
    }

    getchar();
    return 0;
}