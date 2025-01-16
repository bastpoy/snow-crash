#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	(void)argc;
	(void)argv;
	int salut = 10;
	char *argument = malloc(10000);
	// if(env != NULL)
	// 	printf("%s\n", env);
	// if (getenv("LD_PRELOAD") != NULL)
	// printf("%s\n", getenv("LD_PRELOAD"));
	int fd = open("/proc/self/maps", 0); 
	if(fd < 0)
	{
		printf("error opening %s\n", strerror(errno));
		return (1);
	}
	if(read(fd, argument, 10000) < 0)
	{
		printf("error reading\n");
		return(errno);
	}
	printf("%s\n", argument);
	return (0);
}
