#include <iostream>

#include "udp_send_file_client.h"

using namespace an::transfer::udp;

int main()
{
	const char *dest_ip = "127.0.0.1";
	int dest_port = 13374;

	// const char *file_name = "./an-transfer/example/test.txt";
	const char *file_name = "test.txt";

	send_file s(dest_ip, dest_port);

	s.send(file_name);

	getchar();
	return 0;
}