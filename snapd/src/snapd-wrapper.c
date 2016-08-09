#include <unistd.h>
#include <sys/cdefs.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <pthread.h>  /* for pthread_once() */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <sys/un.h>

#define SOCK_PATH "/run/snapd.socket"

int main(int argc, char **argv) {
	char buf[10];
	int fd = socket(AF_UNIX, SOCK_STREAM, 0);
	struct sockaddr_un address = {
		.sun_family = AF_UNIX,
		.sun_path = SOCK_PATH
	};

	unlink(SOCK_PATH);
	bind(fd, (struct sockaddr *)&address, sizeof(address));
	listen(fd, 0);

	printf("fd %d\n", fd);

	setenv("LISTEN_FDS", "1", 1);

	snprintf(buf, 10, "%i", getpid());
	setenv("LISTEN_PID", buf, 1);

	execv(argv[1], argv + 1);
}
