#include <sys/types.h>
#include <sys/time.h>
#include <err.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(void)
{
    int value = 0;
    struct timeval tmo;
    fd_set readfds;

    printf("Enter a non-zero number: ");
    fflush(stdout);

    /* wait only 5 seconds for user input */
    FD_ZERO(&readfds);
    FD_SET(0, &readfds);
    tmo.tv_sec = 5;
    tmo.tv_usec = 0;

    switch (select(1, &readfds, NULL, NULL, &tmo)) {
    case -1:
        err(1, "select");
        break;
    case 0:
        printf("User did not give any input\n");
        return (1);
    }

    printf("Data being put in standard input stream\n");
    scanf("%d", &value);
    printf("User input a number %d \n", value);
    return (0);
}
