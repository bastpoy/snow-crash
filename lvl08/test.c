#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[])
{
	char* needle = "token";
	char *buffer = strstr(argv[1], needle);

	if (buffer == NULL)
	{
		printf("not same\n");
		printf ("%s %s", argv[1], needle);
		return(0);
	}
	printf("%s %s\n", argv[1], "token");
}