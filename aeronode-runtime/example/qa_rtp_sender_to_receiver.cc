/**
 * 
 * Copyright (c) 2017 南京航空航天大学 航空通信网络研究室
 * 
 * @file
 * @author   姜阳 (j824544269@gmail.com)
 * @date     2017-12
 * @brief    rtp发送至本地例程
 * @version  0.0.1
 * 
 * Last Modified:  2018-04-24
 * Modified By:    姜阳 (j824544269@gmail.com)
 * 
 */
#include "aeronode/logger.h"
#include "aeronode/voice_capture.h"
#include "aeronode/voice_playback.h"
#include "aeronode/rtp_receiver.h"
#include "aeronode/rtp_sender.h"
#include <thread>
#include <pthread.h>
#include <mutex>
#include <functional>
#include <condition_variable>

using namespace std;

an::core::VoiceCapture c("default");
an::core::VoicePlayback p("default");

class RTPReceiver : public an::core::RTPReceiver
{
  public:
	RTPReceiver(int port) : an::core::RTPReceiver(port)
	{
	}

  private:
	void payload_process();
};
void RTPReceiver::payload_process()
{
	p.playback(output_buffer, output_buffer_size);
}

class RTPSender : public an::core::RTPSender
{
  public:
	RTPSender(const std::string ip, const int port) : an::core::RTPSender(ip, port)
	{
	}
};

int main(int argc, char **argv)
{
	logger_init();
	RTPReceiver r(8338);
	RTPSender s("127.0.0.1", 8338);
	thread rt([&] { r.start_listen(); });
	thread st([&] {
		while (1)
		{
			c.capture();
			s.write(c.output_buffer, c.output_buffer_size);
		}
	});

	if (rt.joinable())
		rt.join();
	if (st.joinable())
		st.join();

	return 0;
}