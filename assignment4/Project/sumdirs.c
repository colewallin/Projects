/***********************************************************************************************

 CSci 4061 Fall 2017
 Assignment# 4:   Concurrent Programming with POSIX Threads

 Student name: Cole Wallin
 Student ID: 5117843
 X500 id: walli234
 Operating system on which you tested your code: Linux
 CSELABS machine: csel-kh4250-38.cselabs.umn.edu


***********************************************************************************************/


/*
Sum all the files in a directory and all of its sub directories
- If there is a sub directory, a new thread must be created.
- Print intermediate totals for each of the directories in the hierarchy
- No hard or soft links
*/


/*
Organization
1. Get a directory path
2. Loop through the contents of the directory
3. If its a file, get its size and add it to the thread Sum
4. If it is a directory, recursively enter the directory


Example Output:
DEBUG: dir/dir1/ 40
DEBUG: dir/dir2/ 0
DEBUG: dir/dir3/dir31/ 4000
DEBUG: dir/dir3/ 4400
DEBUG: dir/ 4449
Total size: 4449

*/

#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <dirent.h>
#include <errno.h>
#include <pthread.h>
#define NAMESIZE 256

void * get_file_sizes(void *input) {

  // Cast the input to be of the right type
  char * input_dir_name = input;

	//Variable initialization
	DIR *dp;
	struct dirent *direntry;
	struct stat statbuf;
  int sum = 0;
  pthread_t temp;

	// Check if the directory entered exists or not
	if(stat(input_dir_name, &statbuf) == -1) {
    printf("There is an error with stat when called with %s\n", input_dir_name);
    exit(0);
  }
	if(!(S_ISDIR(statbuf.st_mode))){
		printf("The directory name is not valid. Directory does not exist\n");
		exit(0);
	}

	//Open the directory
	if ((dp=opendir(input_dir_name)) == NULL) {
		perror("Erro while opneing the directory");
		exit(0);
	}

	//Loop through the files in the directory
	while ((direntry = readdir(dp)) != NULL)  {
		char tmp[256];
		strcpy(tmp, input_dir_name);
		strcat(tmp, "/");
		strcat(tmp, direntry->d_name);
		if(stat(tmp, &statbuf) == -1) {
			printf("There is an error with stat when called with %s\n", tmp);
			exit(0);
		}

		//Check if it is a directory
		if (S_ISDIR(statbuf.st_mode)) {
			char path[1024];
			//Ignore the parent and current directories
			if ((strcmp(direntry->d_name, ".") == 0) || (strcmp(direntry->d_name, "..") == 0)) {
				continue;
			}
			sprintf(path, "%s/%s", input_dir_name, direntry->d_name);

			//recursively enter the directory
      if (pthread_create(&temp, NULL, get_file_sizes, path) != 0)
      {
        perror("pthread_create");
        exit(1);
      }
      void *thread_return_value;

      if (pthread_join(temp, &thread_return_value) != 0) {
        perror("pthread_join");
        exit(1);
      }
			sum += (int)thread_return_value;
		}
		else {
			//It is a file. Add its size to the sum total.
			sum += (int)statbuf.st_size;
		}
	}
	closedir(dp);
  printf("DEBUG: %s %d\n", input_dir_name, sum);
  return (void *) sum;
}

//Global variable
int totalsize = 0;

int main(int argc, char *argv[])
{
  pthread_t tid;
	char *input_dir_name, *dirpath;
	struct stat statbuf;

	input_dir_name = (char *) malloc(NAMESIZE * sizeof(char));
	dirpath = (char *) malloc(NAMESIZE * sizeof(char));
	printf("\nFINDING THE SUM OF ALL THE FILE SIZES:\n");
	printf("Enter a directory name in the current directory: ");
	scanf("%s", input_dir_name);


  if (pthread_create(&tid, NULL, get_file_sizes, input_dir_name) != 0)
  {
    perror("pthread_create");
    exit(1);
  }

  void *thread_return_value;
  if (pthread_join(tid, &thread_return_value) != 0) {
    perror("pthread_join");
    exit(1);
  }

  // totalsize = get_file_sizes(input_dir_name);
  printf("\nTotal size: %d bytes\n", (int)thread_return_value);


	free(input_dir_name);
	free(dirpath);
	return 0;
}
