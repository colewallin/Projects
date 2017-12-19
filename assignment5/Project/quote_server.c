/***********************************************************************************************

 CSci 4061 Fall 2017
 Assignment# 5:   Interprocess Communication using TCP/IP

 Student name: Cole Wallin
 Student ID: 5117843
 X500 id: walli234
 Operating system on which you tested your code: Linux
 CSELABS machine: csel-kh4250-06.cselabs.umn.edu


***********************************************************************************************/


#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>


#define TRUE 1
#define SERVER_PORT 6789
#define BUFFER_SIZE 1024


/* prototypes */
void die(const char *);
void pdie(const char *);

void readConfig(char **, char **, char *);

void * threadhandler(void * new_sock);

struct socket_context
{
    int sock_fd;
    char configFileName[BUFFER_SIZE];
};
typedef struct socket_context client_sock_context;


/**********************************************************************
 * main
 **********************************************************************/

int main(int argc, char *argv[]) {
  int sock;                    /* fd for main socket */
  int msgsock;                 /* fd from accept return */
	int *new_sock;							 /* To keep track of the new clients. */
  struct sockaddr_in server;   /* socket struct for server connection */
  struct sockaddr_in client;   /* socket struct for client connection */
  int clientLen;               /* returned length of client from accept() */


  /* Make sure proper number of input arguments*/
  if (argc == 1) {
    printf("Usage: %s configFileName\n", argv[0]);
    exit(1);
  }


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

  /* Loop, waiting for client connections. */
  /* This is an interactive server. */
  while (TRUE) {
		/* Wait until a client conencts to the server.*/
    clientLen = sizeof(client);
    if ((msgsock = accept(sock, (struct sockaddr *) &client, &clientLen)) == -1) {
      pdie("Accept");
    }
		else {
			/* Create a thread to handle the I/O */
			pthread_t tid;
			pthread_attr_t attr;
			// new_sock = malloc(sizeof *new_sock);
			// *new_sock = msgsock;
      client_sock_context* client_sock = (client_sock_context*) malloc(sizeof(client_sock_context));
      client_sock->sock_fd = msgsock;
      strcpy(client_sock->configFileName, argv[1]);

			pthread_attr_init(&attr);
			pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
			pthread_attr_setscope(&attr, PTHREAD_SCOPE_SYSTEM);
			if (pthread_create(&tid, &attr, threadhandler, client_sock) != 0)
      {
        perror("pthread_create");
        exit(1);
      }
    }   /* else */
  }
	/* Close the socket*/
	close(msgsock);
  exit(0);

}

/**********************************************************************
 * threadhandler --- Handle the I/O interaction with the client
 **********************************************************************/

void * threadhandler(void * arg) {
	// int socket_fd = *(int*)new_sock;
	// printf("socket_fd is: %d\n", socket_fd);

  client_sock_context *client_sock;
  client_sock =(client_sock_context*)arg;

	// file_pointers[0] -> Einstein_fp;
	// file_pointers[1] -> *Twain_fp;
	// file_pointers[2] -> *Computers_fp;
	FILE *file_pointers[3];

	int rval;                    /* return value from read() */
	char req[BUFFER_SIZE];       /* String sent to server */
	char response[BUFFER_SIZE];  /* String rec'd from server */

  /* The lines of each quote */
	char * line1 = malloc(1024);
	char * line2 = malloc(1024);


	// Allocate space for 3 pointers to strings for the categories and their filenames
	char **Categories = (char**)malloc(3*sizeof(char*));
	char **file_names = (char**)malloc(3*sizeof(char*));

  // Allocate 50 bytes for each string, which is more than enough for the strings
  for(int i = 0; i < 3; i++){
		Categories[i] = (char*)malloc(50*sizeof(char));
		file_names[i] = (char*)malloc(50*sizeof(char));
  }

	/* Read the values in the config file. */
	readConfig(Categories, file_names, client_sock->configFileName);

	for(int i = 0; i < 3; i++){
		printf("FileName: %s\n", file_names[i]);
  }

	if (!(file_pointers[0]=fopen(file_names[0], "r"))) {
		printf("--%s--\n", file_names[0]);
		pdie("Opening einstein.txt file");
	}
	if (!(file_pointers[1]=fopen(file_names[1], "r"))) {
		printf("--%s--\n", file_names[1]);
		pdie("Opening twain.txt file");
	}
	if (!(file_pointers[2]=fopen(file_names[2], "r"))) {
		printf("--%s--\n", file_names[2]);
		pdie("Opening computers.txt file");
	}

	do {
		/* Read from client until it's closed the connection. */
		if ((rval = recv(client_sock->sock_fd, &req, sizeof(req),0)) < 0) {
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
				strcpy(response, "Random Quote:\n");
				int i = rand() % 3;
				if (!fgets(line1, 1024, file_pointers[i])) {
					rewind(file_pointers[i]);
					fgets(line1, 1024, file_pointers[i]);
				}
				printf("line1: %s\n", line1);
				strcat(response, line1);
				fgets(line2, 1024, file_pointers[i]);
				printf("line2: %s\n", line2);
				strcat(response, line2);
			}
			else if (strncmp(req, "GET: QUOTE CAT: Computers\n", 26) == 0) {
				printf("The client requested a quote about Computers\n");
				strcpy(response, "Computer Quote:\n");
				if (!fgets(line1, 1024, file_pointers[2])) {
					rewind(file_pointers[2]);
					fgets(line1, 1024, file_pointers[2]);
				}
				printf("line1: %s\n", line1);
				strcat(response, line1);
				fgets(line2, 1024, file_pointers[2]);
				printf("line2: %s\n", line2);
				strcat(response, line2);

			}
			else if (strncmp(req, "GET: QUOTE CAT: Twain\n", 22) == 0) {
				printf("The client requested a quote by Twain\n");
				strcpy(response, "Twain Quote:\n");
				if (!fgets(line1, 1024, file_pointers[1])) {
					rewind(file_pointers[1]);
					fgets(line1, 1024, file_pointers[1]);
				}
				printf("line1: %s\n", line1);
				strcat(response, line1);
				fgets(line2, 1024, file_pointers[1]);
				printf("line2: %s\n", line2);
				strcat(response, line2);
			}
			else if (strncmp(req, "GET: QUOTE CAT: Einstein\n", 25) == 0) {
				printf("The client requested a quote by Einstein\n");
				strcpy(response, "Einstein Quote:\n");
				if (!fgets(line1, 1024, file_pointers[0])) {
					rewind(file_pointers[0]);
					fgets(line1, 1024, file_pointers[0]);
				}
				printf("line1: %s\n", line1);
				strcat(response, line1);
				fgets(line2, 1024, file_pointers[0]);
				printf("line2: %s\n", line2);
				strcat(response, line2);
			}
			else {
				strcpy(response, "ERROR: The input category does not match the ones listed.\n");
			}
			if (send(client_sock->sock_fd, &response, sizeof(response),0) < 0){
				pdie("Writing on stream socket");
			}
		}
	} while (rval != 0);
	free(client_sock);
	close(client_sock->sock_fd);
	fclose(file_pointers[0]);
	fclose(file_pointers[1]);
	fclose(file_pointers[2]);
}

/**********************************************************************
 * readConfig --- Read the config file and open the listed files.
 **********************************************************************/

void readConfig(char **Categories, char **file_names, char * config) {
  /* Open the files from the context file. */
  FILE *ptr_config_file;
  char f1[1024], f2[1024], f3[1024];

  // Open the file
  ptr_config_file = fopen(config, "r");

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

  /* Get the filenames and category names on their own */
  char * pch;
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

  // for (int i = 0; i<3; i++) {
  //   printf("%s -- %s\n", Categories[i], file_names[i]);
  // }
	fclose(ptr_config_file);
}

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
