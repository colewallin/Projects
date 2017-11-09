/***********************************************************************************************

 CSci 4061 Fall 2017
 Assignment# 3: Piper program for executing pipe commands

 Student name: Cole Wallin
 Student ID: 5117843

 walli234@umn.edu

 Operating system on which you tested your code: Linux
 CSELABS machine: csel-kh4250-04.cselabs.umn.edu, csel-kh4250-22.cselabs.umn.edu
***********************************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>

#define DEBUG

#define MAX_INPUT_LINE_LENGTH 2048 // Maximum length of the input pipeline command
                                   // such as "ls -l | sort -d +4 | cat "
#define MAX_CMDS_NUM   8           // maximum number of commands in a pipe list
                                   // In the above pipeline we have 3 commands
#define MAX_CMD_LENGTH 4096         // A command has no more than 4098  characters

FILE *logfp;

int num_cmds = 0;
char *cmds[MAX_CMDS_NUM];
int cmd_pids[MAX_CMDS_NUM];
int cmd_status[MAX_CMDS_NUM];
int fildes[2],pipe2[2];


/*******************************************************************************/
/*   The function parse_command_line will take a string such as
     ls -l | sort -d +4 | cat | wc
     given in the char array commandLine, and it will separate out each pipe
     command and store pointer to the command strings in array "cmds"
     For example:
     cmds[0]  will pooint to string "ls -l"
     cmds[1] will point to string "sort -d +4"
     cmds[2] will point to string "cat"
     cmds[3] will point to string "wc"

     This function will write to the LOGFILE above information.
*/
/*******************************************************************************/

int parse_command_line (char commandLine[MAX_INPUT_LINE_LENGTH], char* cmds[MAX_CMDS_NUM]){
  // for each entry in commandLine, put it into cmds
  int  num = 0;
  char delims[] = "|";
  char *result = NULL;
  result = strtok( commandLine, delims );

  // White space doesn't get removed. This doesn't matter for execvp.
  printf("Extracting commands from the pipeline...\n");
  fprintf(logfp, "************* PARSING RESULTS **************\n\n");
  while( result != NULL ) {
    cmds[num] = result;
    printf("Extracted : \"%s\"\n", result );
    fprintf(logfp, "Command %d info: %s \n", num, result);
    result = strtok( NULL, delims );
    num++;
  }
  fprintf(logfp, "Number of commands from the input: %d\n\n", num);
  return num;
}

/*******************************************************************************/
/*  parse_command takes command such as
    sort -d +4
    It parses a string such as above and puts command program name "sort" in
    argument array "cmd" and puts pointers to ll argument string to argvector
    It will return  argvector as follows
    command will be "sort"
    argvector[0] will be "sort"
    argvector[1] will be "-d"
    argvector[2] will be "+4"
/
/*******************************************************************************/

void parse_command(char input[MAX_CMD_LENGTH],
                   char command[MAX_CMD_LENGTH],
                   char *argvector[MAX_CMD_LENGTH]){

  // Copy input into a temporary variable so the cmds array can still be used later
  char temp[MAX_CMD_LENGTH];
  strcpy(temp, input);

  int i = 0;
  char* delim = " \t\n\0";
  argvector[i] = strtok(temp, delim);
  strcpy(command, argvector[i]);
  i++;
  while ((argvector[i] = strtok(NULL, delim)) != NULL){
    i++;
  }
}


/*******************************************************************************/
/*  The function print_info will print to the LOGFILE information about all    */
/*  processes  currently executing in the pipeline                             */
/*  This printing should be enabled/disabled with a DEBUG flag                 */
/*******************************************************************************/

void print_info(char* cmds[MAX_CMDS_NUM],
		int cmd_pids[MAX_CMDS_NUM],
		int cmd_stat[MAX_CMDS_NUM],
		int num_cmds) {

  // Print the global variables to the LOGFILE
  fprintf(logfp, "PID\t\t\tCOMMAND\t\tEXIT STATUS\n");
  for(int i = 0; i < num_cmds; i++) {
    fprintf(logfp, "%d\t\t%s\t\t\t\t\t%d\n", cmd_pids[i], cmds[i], cmd_stat[i]);
  }
  fprintf(logfp,"\n");
}



/*******************************************************************************/
/*     The create_command_process  function will create a child process        */
/*     for the i'th command                                                    */
/*     The list of all pipe commands in the array "cmds"                       */
/*     the argument cmd_pids contains PID of all preceding command             */
/*     processes in the pipleine.  This function will add at the               */
/*     i'th index the PID of the new child process.                            */
/*     Following ADDED on  10/27/2017                                          */
/*     This function  will  craete pipe object, execute fork call, and give   */
/*     appropriate directives to child process for pipe set up and             */
/*     command execution using exec call                                       */
/*******************************************************************************/


void create_command_process (char cmds[MAX_CMD_LENGTH],   // Command line to be processed
                             int cmd_pids[MAX_CMDS_NUM],  // PIDs of preceding pipeline processes
                                                          // Insert PID of new command processs
		                         int i)                       // commmand line number being processed
{
  int statid;
  int valexit,  valsignal, valstop, valcont;
  char just_cmd[MAX_CMD_LENGTH];
  char *argvec[MAX_CMD_LENGTH];


  parse_command(cmds, just_cmd, argvec);  // put command in just_cmd and all arguments in argvec

  if(cmd_pids[i]=fork()){ /*  Parent process */
    /* ..Close the unwanted pipe descriptors.. */
    close(fildes[0]);
    close(fildes[1]);

    /* .. Log the process that has just been created .. */
    fprintf(logfp, "%d\t\t\t\t\t%s\n", cmd_pids[i], cmds);
  }
  else { /* Newly created child process */
    if(fildes[0] != -1){
      /* .. indicates that standard input comes from a file .. */
      dup2(fildes[0],0);
    }
    if(pipe2[1] != -1){
      /* ..indicates that standard output redirect to a pipe.. */
      dup2(pipe2[1],STDOUT_FILENO);
    }

    close(fildes[0]);
    close(fildes[1]);
    close(pipe2[0]);
    close(pipe2[1]);

    /* ..Execute the command given to the child process.. */
    if(execvp(just_cmd,argvec)){
      exit(1);
    }
  }

  /* ..Reassign the file descriptors.. */
  fildes[0] = pipe2[0];
  fildes[1] = pipe2[1];

  pipe2[0]=-1;
  pipe2[1]=-1;
}



/********************************************************************************/
/*   The function waitPipelineTermination waits for all of the pipeline         */
/*   processes to terminate.                                                    */
/********************************************************************************/

void waitPipelineTermination () {
  int finishCount = 0;
  int signalInterrupt = 0;  // keep track of any iinterrupt due to signal
  int fatalError = 0;
  int statid = 0 ;
  int status = 0 ;
  int i;

  while (finishCount < num_cmds ) {
    //printf("\nwaiting for pipeline termination...");
    fprintf(logfp, "waiting...");

    //statid is the ID of the completed process.
    if((statid=wait(&status))==-1){
      perror("Wait terminated:");
      signalInterrupt = 1;
      break;
    }

    /* .. Logging the which processes are finished .. */
    fprintf(logfp, "Process id %d finished\n", statid);
    fprintf(logfp, "Process id %d finished with exit status %d\n", statid, status);


    if (signalInterrupt) {
      continue;
    }
    for (i=0; i<num_cmds; i++) {
      if (cmd_pids[i]==statid)  {
        cmd_status[i] = status;
        finishCount++;   // Only count those processes that belong to the pipeline
      }
    }

    /* ..Something went wrong with the process execution.. */
    if ( WEXITSTATUS(status) != 0 ) {
      fatalError = 1;
      printf("Terminating pipeline becuase process %d failed to execute\n", statid);
      break;
    }
  }

  if ( fatalError ) {
    for (i=0; i<num_cmds; i++) {
      printf("Terminating process %d \n", cmd_pids[i] );
      kill(cmd_pids[i], 9);
    }
  }
}

/********************************************************************************/
/*  This is the signal handler function. It should be called on CNTRL-C signal  */
/*  if any pipeline of processes currently exists.  It will kill all processes  */
/*  in the pipeline, and the piper program will go back to the beginning of the */
/*  control loop, asking for the next pipe command input.                       */
/********************************************************************************/

void killPipeline( int signum ) {
  printf("You pressed control-C\n");
  for (int i=0; i<num_cmds; i++) {
    // For error checking
    //printf("Process %d status: %d \n", cmd_pids[i], cmd_status[i] );

    // Kill each of the child processes.
    kill(cmd_pids[i], 9);
  }
}

/********************************************************************************/

int main(int ac, char *av[]){

  int i,  pipcount;

  //check usage
  if (ac > 1){
    printf("\nIncorrect use of parameters\n");
    printf("USAGE: %s \n", av[0]);
    exit(1);
  }

  /* Open a fp to the logfile for appending*/
  logfp =  fopen("LOGFILE", "a");


  while (1) {
     fprintf(logfp, "--------------------------------------------\n");
     signal(SIGINT, SIG_DFL );
     pipcount = 0;

     /*  Get input command file anme form the user */
     char pipeCommand[MAX_INPUT_LINE_LENGTH];

     fflush(stdout); // Flushes the output buffer of a stream
     printf("Give a list of pipe commands: ");

     /* Reads a line from stdin and stores it to the input string. Stops at \n
        or end of file
     */
     gets(pipeCommand);
     char* terminator = "quit";
     printf("You entered : %s\n", pipeCommand);
     if ( strcmp(pipeCommand, terminator) == 0  ) {
        fflush(logfp);
        fclose(logfp);
        printf("Goodbye!\n");
        exit(0);
     }


    /*  num_cmds indicates the number of commands in the pipeline        */
    num_cmds = parse_command_line( pipeCommand, cmds);

    /*  SET UP SIGNAL HANDLER  TO HANDLE CNTRL-C                         */
    signal(SIGINT, killPipeline);


    fildes[0]=-1;
    fildes[1]=-1;
    pipe2[0] = -1;
    pipe2[1] = -1;

    /* Set up the log file to list the commands*/
    fprintf(logfp, "************ CREATED PROCESSES *************\n");
    fprintf(logfp, "PID\t\t\t\t\t\tCOMMAND\n");

    for(i=0;i<num_cmds;i++){
      if(pipcount < num_cmds-1) { // Don't need to pipe the last command
         pipe(pipe2);
         pipcount++;
      }
         /*  CREATE A NEW PROCCES EXECUTTE THE i'TH COMMAND    */
         create_command_process (cmds[i], cmd_pids, i);
    }

    fprintf(logfp, "\n************* DURING EXECUTION *************\n");
    waitPipelineTermination();

    fprintf(logfp, "\n******** AFTER PIPELINE COMPLETION *********\n");
    print_info(cmds, cmd_pids, cmd_status, num_cmds);

  }
} //end main

/*************************************************/
