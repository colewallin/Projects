/*                          Introduction to Operating Systems
                            CSCI 4061
This program demonstrates the use of lstat system call to display file type
of entries in a directory"*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#define NAMESIZE 256

int main(int argc, char *argv[])
{
    /* Declarations */
    char *dirname;
    struct stat statbuf;
    DIR *dp;
    struct dirent *direntry;
    int totalsum = 0;
    dirname = (char*)malloc(NAMESIZE*sizeof(char));
    /* End of declarations */

    if(argc < 2)       /*If the user does not enter any directory name*/
    {
	printf("No directory name specified. Executing the function in the current directory.\n");
	dirname = getcwd(dirname,NAMESIZE);
    }
    else              /* If the user enters a directory name */
    {
	dirname = getcwd(dirname,NAMESIZE);
        strcat(dirname,"/");
        strcat(dirname,argv[1]);

    }
    /* Check if the directory entered exists or not*/
    stat(dirname,&statbuf);
    if(!(S_ISDIR(statbuf.st_mode))){
        printf("The directory name is not valid. Directory does not exist\n");
        exit(0);
    }

    if((dp=opendir(dirname))==NULL){
        perror("Error while opening the directory");
        exit(0);
    }
    /* Loop through the directory structure */
    chdir(dirname); //previously missing
    while( (direntry = readdir(dp)) != NULL )
    {

      /*************************/
      lstat(direntry->d_name,&statbuf);

      if (S_ISDIR(statbuf.st_mode)) {
	printf("Dir: %s\n",direntry->d_name);
      }
      if (S_ISREG(statbuf.st_mode)) {
	printf("Reg: %s\n",direntry->d_name);
      }
      if (S_ISLNK(statbuf.st_mode)) {
	printf("Lnk: %s\n",direntry->d_name);
      }
      /*************************/

    }


}
