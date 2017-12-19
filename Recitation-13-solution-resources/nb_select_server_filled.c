/* RECEIVER PROGRAM   receiver.c  							*/
/* Compilation Instruction:  								*/
/*			gcc -0 receiver receiver.c -lsocket -lnsl			*/
/* This program is for the receiver process, which will create two TCP stream  sockets. */
/* It prints the port numbers for these two socket. A sender process sends messages to  */
/* this receiver by using  one of these port numbers and the domain name of the machine */
/* the receiver process is executing.							*/ 
/* The receiver waits for messages on any of these two sockets. When a message arrives	*/
/* on any of these two sockets, it accepts the connection, reads the message and then 	*/
/* prints it on the standard output.              					*/



#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>

void handle_connection (int sock) {
int msgsock, rval;
int i;
char buf[512] ; 
    msgsock = accept(sock,0,0);
    for ( i = 0 ; i < 512 ; i++) buf[i] = ' ' ;   /* clear buf array  with spaces  */

    if ( (rval = read(msgsock, buf , 512)) < 0) {   /* read from msgsock into buf    */
         perror("while reading from socket");
          return;
     }
    write(1,buf,rval);
    close(msgsock) ;  /* close socket -- connection is closed and socket is deallocated. */
}


void main( int argc,  char*  argv[] )
{
   int i, ready, sock1, sock2, length; 
   /* This receiver process will receive connection requests on these two sockets */ 
   int msgsock ; 

   fd_set fdin;
   struct timeval TO ; 

   struct sockaddr_in server, server2;  

   /* CREATE FIRST SOCKET 				   			*/
   sock1  = socket(AF_INET, SOCK_STREAM,0); 

   if ( sock1 < 0 ) { 
      perror("Problem in creating the first socket");
       exit(0); 
    } 

   server.sin_addr.s_addr = INADDR_ANY ; 
   server.sin_port = 0 ; 
   server.sin_family = AF_INET;
   if ( bind(sock1,(struct sockaddr *)&server, sizeof(server))) {   /* Bind socket to a port */ 
      perror ( "Binding stream socket");
      exit(0);
   }

   length = sizeof(server); 
   if ( getsockname(sock1,(struct sockaddr *)&server, &length)) {  /* get the port number assigned to this socket */ 
        perror("Getting socket's port number");
        exit(0);
   }

   fprintf(stderr, "Socket 1 is connected to port%5d\n\n", ntohs(server.sin_port)); 

   /* CREATE SECOND SOCKET 				 			*/
   sock2 = socket(AF_INET, SOCK_STREAM, 0);
 
   if ( sock2 < 0 ) {
      perror("problem in creating the second  socket");
      exit(0);
   } 

   server2.sin_addr.s_addr = INADDR_ANY; 
   server2.sin_port = 0 ; 
   server2.sin_family = AF_INET;
   if ( bind(sock2, (struct sockaddr * )&server2,sizeof(server2))){ /* bind second socket to a port */
        perror("Binding stream socket");
        exit(0);
   }

   length = sizeof(server2);
   if ( getsockname(sock2,(struct sockaddr *)&server2,&length)){  /* get the port number for socket2 */
      perror("getting socket's port number");
      exit(0);
    }

    fprintf(stderr,"Socket 2  is connected to port %5d\n", ntohs(server2.sin_port));

    /* Initialize socket fo receiving messages.						*/
    /*  ready to accept connection to sock1, up to 3 requests can be kept buffered */
    listen(sock1,3);     
    listen(sock2,3);     

    /* Continuously wait for receiving messages on either of the two sockets.		*/
    while (1) { 
        FD_ZERO( &fdin );
        FD_SET( sock1, &fdin);
        FD_SET( sock2, &fdin);
        TO.tv_sec = 10 ; 
        TO.tv_usec = 0 ; 
  
        select(32, (fd_set *)&fdin, 0, 0, &TO);  /* Block to receive call on either sock1 or sock2 */
                       /* timeout and continue after 10 seconds if no connection requests */

        if (FD_ISSET(sock1, &fdin )) {   /* check if connection requests for sock1  */ 
             printf("\nMessage on the first socket\n");

             /* accept connection on sock1. This will return a new socket indentifier, stored 
             in msgsock for the connection. All I/O for that connection is through msgsock.  */
              handle_connection(sock1);
              FD_CLR(sock1, &fdin);
         }
         else if (FD_ISSET(sock2, &fdin)) {    /* check if connection requests for sock2  */
              printf("\nMessage on the second socket\n");
              /* accept connection on sock2. This will return a new socket indentifier, stored 
              in msgsock for the connection. All I/O for that connection is through msgsock.  */

              handle_connection(sock2);
              FD_CLR(sock2,  &fdin);
             } 
            else  /* Select call completed due to timeout and there is no connection on any socket */
                  printf("\nTimeout occured\n"); 
      };

}  