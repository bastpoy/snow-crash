#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
// #include <sys/types.h>
// #include <sys/stat.h>
// #include <fcntl.h>
#include <dlfcn.h>

typedef int (*open_type)(const char *pathname, int flags);

static open_type real_open = NULL; 

int open(const char *pathname, int flags)
{
	if(!real_open)
	{
		real_open = (open_type)dlsym(RTLD_NEXT, "open");
	}

	int fd = real_open(pathname, flags);
	system("getflag");
	printf("testing\n");
	return (fd);
}

6634 6b6d 6d36 707c 3d82 7f70 826e 8382 4442 8344 757b 7f8c 89oa

6633 696a 6931 6a75 3579 7565 7661 7573 3431 7131 6166 6975 71
0-1  2 -3 4 -5 6-7  8-9  1011 1213 1415 1617 1819 2021 2223 2425
f3   ij   i1   ju   5y   ue   va   us   41   q1   af   iu   q
f3iji1ju5yuevaus41q1afiuq
