#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

#define BUFSIZE  256

void  main (int argc, char * argv[])  {
char  buffer[BUFSIZE];
ssize_t  count;
mode_t   perms;
int		 fdin,  fdout;

    perms   = 0740;

    if  ( argc !=3 ) {
        printf( "Incorrect use: Usage: %s  source-file-name  target-copy-name\n",  argv[0] );
        exit( 1 );
    }

    if  ( (fdin = open ( argv[1],  O_RDONLY))  == -1) {
        perror ( "Error in opening the input file:");
        exit (2);
    }
    /*    printf( "Input file opened with descriptor %d \n", fdin);  */

    if  ( (fdout = open (argv[2], (O_WRONLY | O_CREAT),  perms)) == -1 ) {
        perror ( "Error in creating the output file:");
        exit (2);
    }
    /*    printf( "Output file opened with descriptor %d \n", fdout);  */

    while ( (count=read(fdin, buffer, BUFSIZE)) > 0 ) {
          if ( write (fdout, buffer, count) != count )
             perror ("Error in writing" );
    }

    if ( count == -1 ) {
       perror ( "Error while reading the input file: ");
    }

    close(fdin);
    close(fdout);
}
