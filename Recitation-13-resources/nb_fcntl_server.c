/* A SERVER PROGRAM   server.c  							*/
/* Compilation Instruction:  								*/

/*			gcc -o server  server.c -lsocket -lnsl			*/

/* This program is for the server process, which will create two TCP stream  sockets. */
/* It prints the port numbers of its socket. A client process sends messages to  */
/* this server by using  this port number and the domain name of the machine */
/* on which the server process is executing.							*/
/* The server waits for messages on its socket. When a message arrives,	*/
/* it accepts the connection, reads the message and then 	*/
/* prints it on the standard output.              					*/




#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>

#define TRUE 1
#define FALSE 0


// void set_fl ( int  fd,  int flags ) {
// 	// Write your code here
// }


void  main(int argc,  char*  argv[] )
{
   int i, ready, sock,  length, dopt;
   struct sockaddr_in servaddr;
   /* This server process will receive connection requests on this socket*/
   int msgsock ;
   char buf[512] ;
   int rval ;
   int length1 ;


   /* CREATE SOCKET 				   			*/

   sock  = socket(AF_INET, SOCK_STREAM,0);

   if ( sock < 0 ) {
        perror("Problem in creat socket");
        exit(0);
   }

  /* Initialize a socket address structure to be passed to the  bind function to
     request binding of a port to this socket.
  */
  servaddr.sin_addr.s_addr = INADDR_ANY;  /* Choose any of the IP addresses of this host */
  servaddr.sin_port = 0 ;                 /* Choose any available port                   */
  servaddr.sin_family = AF_INET;

  /* Bind socket to a port */
  if ( bind(sock,  (struct sockaddr *)&servaddr, sizeof(servaddr))) {
       perror ( "Binding stream socket");
       exit(0);
  }

  length = sizeof(servaddr);

  /* get the port number assigned to this socket */
  if ( getsockname(sock,  (struct sockaddr *)&servaddr, &length)) {
       perror("Getting socket's port number");
       exit(0);
  }

  fprintf(stderr, "Socket is connected to port  %5d\n\n", ntohs(servaddr.sin_port));


  /* Initialize socket fo receiving messages.						*/

  listen(sock, 5);
  /*  ready to accept connection to sock, up to 5 requests can be kept buffered */


  /* set "sock" into non-blocking mode */
  // Write code to set "sock" into non-blocking mode
  int retval = fcntl( sock, F_SETFL, fcntl(sock, F_GETFL) | O_NONBLOCK);
  printf("Ret from fcntl: %d\n", retval);

  /* Continuously wait for receiving connections requests. */
  while (1) {

      if ( (msgsock=accept(sock, 0, 0)) == -1) {
         // Write code to sleep for 5 seconds and continue if EWOULDBLOCK error exist
         if (errno == EWOULDBLOCK) {
           printf("errno == EWOULDBLOCK \n");
         }
         perror("Error was");
         sleep(5);
      }

      for ( i = 0; i < 512; i++)
          buf[i] = ' ';  /* clear buf array  with spaces  */

      /* read from msgsock into buf */
      if ( (rval = read(msgsock, buf,512)) < 0 )
           perror("while reading from socket");

      write(1, buf, rval);
      /* close socket -- connection is closed and socket is deallocated. */
      close(msgsock);
  }
}
