/* CLIENT PROGRAM   client .c   	                                                        */
/* Compilation Instruction:                                                             */

/*                      gcc -o client client.c  -lsocket -lnsl 				*/

/* This program is for the client process, which will create one   TCP stream  socket. */
/* A client process sends message 'I am happy" to the server's  port. */
/* If server is running on atto.cs.umn.edu and connected to port */
/* 4002, then the following execution of this  client program will send a message to this        */
/* port of the  server process.					        */

/*                      client atto.cs.umn.edu  4002					*/

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <strings.h>
#include <stdio.h>
#include <stdlib.h>

void main(int argc, char * argv[])
{
   int i , n, sock; 
   struct sockaddr_in server; 
   struct hostent   *hp,   *gethostbyname();
   char c , message[512]; 
  
   if ( argc != 3) { 
     fprintf(stderr, "Incorrect number of argument\n");
     fprintf(stderr, "Usage--   client   marchineName, PortNumber \n");
   }
   
   /* create a socket using which to send a message  */
   sock = socket(AF_INET, SOCK_STREAM, 0);
   
   /*  Create socket for sending a message.						*/

   if ( sock < 0 ) { 
      fprintf(stderr, "getting socket fail\n");
      exit(0);
   }else 
     fprintf(stderr,"Sender process created socket\n\n");

   /*  Initialize the host name and port number to which connection is to be made.		*/ 
   server.sin_family = AF_INET; 
   hp = gethostbyname(argv[1]);
   printf("host name : %s\n\n",hp->h_name);

   bcopy(hp->h_addr, &(server.sin_addr.s_addr), hp->h_length); 
   server.sin_port = htons(atoi(argv[2]));
 
  /* Try to connect to the server process.						*/  
   if ( connect(sock, (struct sockaddr *)&server, sizeof(server)) < 0 ) { 
       close(sock); 
       perror("Error in connecting a stream socket");
   }

  strcpy(message, "I am happy\n");

  if ( write(sock, message, strlen(message)) <0)   /* send message by writing to the scoket sock */
    fprintf(stderr,"Error in Writing on steam socket");

  close(sock);    /* close socket -- that closes the connection and deallocates the socket.  */
   

}