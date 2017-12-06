/***********************************************************************************************

 CSci 4061 Fall 2017
 Assignment# 5:   Interprocess Communication using TCP/IP

 Student name: Cole Wallin
 Student ID: 5117843
 X500 id: walli234
 Operating system on which you tested your code: Linux
 CSELABS machine: csel-kh4250-06.cselabs.umn.edu


***********************************************************************************************/


/*

This thread should handle the request as following:
 The thread should open all the files listed in the configuration file in read mode.
 Based on the category specified by the client, the thread would pick up the next quote from the file that
contains quotes for that category, starting with the first quote in the beginning. Here “next” is to be
considered only with respect to that client.
 If the mentioned category does not have a matching file in the file database of the server, the server
should return an error message to the client.
 If the client asks for a list of available categories, the server should return the list of the categories read
from the configuration file.
 If the client sends “BYE”, the server thread should close the connection and terminate itself.
 After handling a request other than “BYE”, the thread should go back in a loop and wait for next request
from the client.
*/



/*
Requirements

 The quote_client provided to you should be able to talk to your quote_server and obtain
o A list of available categories
o Quote from a specified category or a random category if the client presses <ENTER>.
o If the client asks for a quote from the same category again, the server should return the next
quote from the file.
 Multiple instances of the quote_client should be able to talk to the server at the time.
*/


/*
Hints

Each server thread should open all the quote files in read mode on creation. After that you can have a
switch statement on the client request. Depending on the category you should get two lines from the
corresponding file using fgets(). This way if the client asks for the same category later, it will get the
next two lines, since fgets() advances the offset pointer every time it reads a line. If you ever reach the
end of some file (when fgets() returns zero), you can start again from the beginning of the file.
 If the client specifies no category (by simply pressing <ENTER>) then you should pick a random
category and do an fgets() on the corresponding file.
 Set attributes of server threads as PTHREAD_CREATE_DETACHED and
PTHREAD_SCOPE_SYSTEM
C Functions that can be used
 Sockets: socket() , bind() , accept() , listen() , close()
*/


/**********************************************************************
 * struct_server.c --- Demonstrate the core workings of a simple server
 *              - compile/run on linux
 *              - note that server does not exit on its own, you
 *                must kill it yourself.
 *              - Do NOT leave this running on itlabs machines
 *              - Note: some code borrowed from web, source unknown
 **********************************************************************/


#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>


#define DATA1 "Server says:"
#define DATA2 "All your base are belong to us..."
#define TRUE 1
#define SERVER_PORT 6005
#define BUFFER_SIZE 1024


/* prototypes */
void die(const char *);
void pdie(const char *);

void readConfig(char **, char **);
// void killServer( int signum );

char quotes[5][200] = {"We are what we repeatedly do. Excellence, therefore, is not an act but a habit. – Aristotle \n",
					"Do not wait to strike till the iron is hot; but make it hot by striking. – William B. Sprague \n",
					"Great spirits have always encountered violent opposition from mediocre minds. – Albert Einstein \n",
					"You must be the change you want to see in the world. - Gandhi \n",
					"The best way to cheer yourself up is to try to cheer somebody else up. – Mark Twain \n"};

void * threadhandler(void * new_sock);

char completeList[1000];

// struct request_type {
//   char req_command[16];
//   char params[1000];
// };

/**********************************************************************
 * main
 **********************************************************************/

int main(void) {

  int i=0;
  for(  i=0; i<5; i++){
	  strcat(completeList, quotes[i]);
  }

	printf("here1\n");


  int sock;                    /* fd for main socket */
  int msgsock;                 /* fd from accept return */
	int *new_sock;							 /* To keep track of the new clients. */
  struct sockaddr_in server;   /* socket struct for server connection */
  struct sockaddr_in client;   /* socket struct for client connection */
  int clientLen;               /* returned length of client from accept() */


  /* Open a socket */
  if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0){
    pdie("Opening stream socket");
  }

  /* Fill out inetaddr struct */
  server.sin_family = AF_INET;
  server.sin_addr.s_addr = INADDR_ANY;
  server.sin_port = htons(SERVER_PORT);

  /* Bind */
  if (bind(sock, (struct sockaddr *) &server, sizeof(server))){
    pdie("Binding stream socket");
  }

  printf("Server: Socket has port %hu\n", ntohs(server.sin_port));

  /* Listen w/ max queue of 5 */
  listen(sock, 5);

	printf("here2\n");
  /* Loop, waiting for client connections. */
  /* This is an interactive server. */
  while (TRUE) {
    clientLen = sizeof(client);
		// Wait until a client conencts to the server.
		printf("here3\n");
    if ((msgsock = accept(sock, (struct sockaddr *) &client, &clientLen)) == -1) {
      pdie("Accept");
    }
		else {
			// Create a thread.
			// DO the do-while loop if you are the child.
			// else get back into the while loop
			pthread_t tid;
			pthread_attr_t attr;
			new_sock = malloc(sizeof *new_sock);
			*new_sock = msgsock;
			printf("new_sock is: %d\n", *new_sock);

			pthread_attr_init(&attr);
			pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
			pthread_attr_setscope(&attr, PTHREAD_SCOPE_SYSTEM);
			if (pthread_create(&tid, &attr, threadhandler, (void*) new_sock) != 0)
      {
        perror("pthread_create");
        exit(1);
      }
			printf("here5\n");
    }   /* else */

		/* Close the socket*/
    close(msgsock);
  }

  exit(0);

}

/**********************************************************************
 * threadhandler --- Handle the I/O interaction with the client
 **********************************************************************/

void * threadhandler(void * new_sock) {
	int socket_fd = *(int*)new_sock;
	printf("socket_fd is: %d\n", socket_fd);
	FILE *Einstein_fp;
	FILE *Twain_fp;
	FILE *Computers_fp;

	int rval;                    /* return value from read() */
	char req[BUFFER_SIZE];   /* String sent to server */
	char response[BUFFER_SIZE];  /* String rec'd from server */


	// Allocate space for 3 pointers to strings
	char **Categories = (char**)malloc(3*sizeof(char*));
	char **file_names = (char**)malloc(3*sizeof(char*));

  // Allocate 50 bytes for each string, which is more than enough for the strings
  for(int i = 0; i < 3; i++){
		Categories[i] = (char*)malloc(50*sizeof(char));
		file_names[i] = (char*)malloc(50*sizeof(char));
  }

	// Read the values in the config file.
	readConfig(Categories, file_names);

	for(int i = 0; i < 3; i++){
		printf("FileName: %s\n", file_names[i]);
  }

	if (!(Einstein_fp=fopen(file_names[0], "r"))) {
		printf("--%s--\n", file_names[0]);
		pdie("Opening einstein.txt file");
	}
	if (!(Twain_fp=fopen(file_names[1], "r"))) {
		printf("--%s--\n", file_names[1]);
		pdie("Opening twain.txt file");
	}
	if (!(Computers_fp=fopen(file_names[2], "r"))) {
		printf("--%s--\n", file_names[2]);
		pdie("Opening computers.txt file");
	}

	char * line1 = malloc(1024);
	char * line2 = malloc(1024);

	do {
		/* Read from client until it's closed the connection. */
		printf("here recieve\n");
		if ((rval = recv(socket_fd, &req, sizeof(req),0)) < 0) {
			pdie("Reading stream message");
		}
		if (rval == 0) {
			/* Client has closed the connection */
			fprintf(stderr, "Server: Ending connection\n");
		}
		else {
			printf("Server: Message receiced\n");
			printf("---Request Command: %s\n", req);

			/* Write back to client. */

			if (strncmp(req, "GET: LIST\n", 10) == 0) {
				/* List the categories from the config file. */
				strcpy(response, "CATEGORIES:\n");
				for (int i=0; i < 3; i++) {
					strcat(response, Categories[i]);
					strcat(response, "\n");
				}
			}
			else if (strncmp(req, "GET: QUOTE CAT: ANY\n", 20) == 0) {
				printf("The client requested any quote\n");
				strcpy(response, "NEED TO IMPLEMENT RANDOM QUOTE");
			}
			else if (strncmp(req, "GET: QUOTE CAT: Computers\n", 26) == 0) {
				printf("The client requested a quote about Computers\n");
				strcpy(response, "Computer Quote:\n");
				if (!fgets(line1, 1024, Computers_fp)) {
					rewind(Computers_fp);
					fgets(line1, 1024, Computers_fp);
				}
				printf("line1: %s\n", line1);
				strcat(response, line1);
				fgets(line2, 1024, Computers_fp);
				printf("line2: %s\n", line2);
				strcat(response, line2);

			}
			else if (strncmp(req, "GET: QUOTE CAT: Twain\n", 22) == 0) {
				printf("The client requested a quote by Twain\n");
				strcpy(response, "Twain Quote:\n");
				if (!fgets(line1, 1024, Twain_fp)) {
					rewind(Twain_fp);
					fgets(line1, 1024, Twain_fp);
				}
				printf("line1: %s\n", line1);
				strcat(response, line1);
				fgets(line2, 1024, Twain_fp);
				printf("line2: %s\n", line2);
				strcat(response, line2);
			}
			else if (strncmp(req, "GET: QUOTE CAT: Einstein\n", 25) == 0) {
				printf("The client requested a quote by Einstein\n");
				strcpy(response, "Eisnstein Quote:\n");
				if (!fgets(line1, 1024, Einstein_fp)) {
					rewind(Einstein_fp);
					fgets(line1, 1024, Einstein_fp);
				}
				printf("line1: %s\n", line1);
				strcat(response, line1);
				fgets(line2, 1024, Einstein_fp);
				printf("line2: %s\n", line2);
				strcat(response, line2);
			}
			else {
				strcpy(response, "ERROR: the input category does not match the ones listed.\n");
			}
			printf("here recieve\n");
			if (send(socket_fd, &response, sizeof(response),0) < 0){
				pdie("Writing on stream socket");
			}
		}
	} while (rval != 0);
	free(new_sock);
	close(socket_fd);
	fclose(Einstein_fp);
	fclose(Twain_fp);
	fclose(Computers_fp);
}

/**********************************************************************
 * readConfig --- Read the config file and open the listed files.
 **********************************************************************/

void readConfig(char **Categories, char **file_names) {
  /* Open the files from the context file. */
	// Categories = (char *) malloc(100);
  FILE *ptr_config_file;
  char f1[1024], f2[1024], f3[1024];

  // Open the file
  ptr_config_file = fopen("config.txt", "r");

  // Read the three lines
  fgets(f1, 1024, ptr_config_file);
  fgets(f2, 1024, ptr_config_file);
  fgets(f3, 1024, ptr_config_file);

	// Get rid of the new line characters
	char *newline = strchr(f1, '\n');
	if (newline) {
		*newline = 0;
	}
	newline = strchr(f2, '\n');
	if (newline) {
		*newline = 0;
	}
	newline = strchr(f3, '\n');
	if (newline) {
		*newline = 0;
	}

	// printf("f1 is %s\n", f1);
	// printf("f2 is %s\n", f2);
	// printf("f3 is %s\n", f3);

  char * pch;
	/*
	STRTOK ISNT REMOVING THE NEWLINE CHAR
	*/
  pch = strtok (f1," :");
  int i = 0;
	printf("pch : %s\n", pch);
  while (pch != NULL)
  {
    if (i == 0) strcpy(Categories[0], pch);
    if (i == 1) strcpy(file_names[0], pch);
    // printf ("%s\n",pch);
    pch = strtok (NULL, " :");
    i++;
  }
  i = 0;
  pch = strtok (f2," :");
  while (pch != NULL)
  {
    if (i == 0) strcpy(Categories[1], pch);
    if (i == 1) strcpy(file_names[1], pch);
    // printf ("%s\n",pch);
    pch = strtok (NULL, " :");
    i++;
  }
  i = 0;
  pch = strtok (f3," :");
  while (pch != NULL)
  {
    if (i == 0) strcpy(Categories[2], pch);
    if (i == 1) strcpy(file_names[2], pch);
    // printf ("%s\n",pch);
    pch = strtok (NULL, " :");
    i++;
  }

  for (int i = 0; i<3; i++) {
    printf("%s -- %s\n", Categories[i], file_names[i]);
  }
	fclose(ptr_config_file);
}


// /*  SET UP SIGNAL HANDLER  TO HANDLE CNTRL-C                         */
// signal(SIGINT, killServer);

// void killServer( int signum ) {
//   printf("You pressed control-C\n");
// 	printf("Closing the socket.\n");
// 	/* Close the socket*/
// 	close(msgsock);
// }

/**********************************************************************
 * pdie --- Call perror() to figure out what's going on and die.
 **********************************************************************/

void pdie(const char *mesg) {
	printf("Called pdie\n");
  perror(mesg);
  exit(1);
}


/**********************************************************************
 * die --- Print a message and die.
 **********************************************************************/

void die(const char *mesg) {
	printf("Called die\n");
  fputs(mesg, stderr);
  fputc('\n', stderr);
  exit(1);
}
