#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>


void print_statdata ( const char *filename,  const struct stat  *statdata) {
    printf( "Mode:       %o \n", statdata->st_mode);
    printf( "Link count: %d \n", statdata->st_nlink);
    printf( "UID:        %d \n", statdata->st_uid);
    printf( "GID:        %d \n", statdata->st_gid);
    printf( "Size:       %d \n", statdata->st_size);
    printf( "Mod Time:   %d \n", statdata->st_mtime);
    printf( "Name:       %s \n", filename);
}


void do_stat_and_print (const char* dirname,  const char *filename ) {
struct stat statdata;
char filepathname[256];

    sprintf(filepathname, "%s/%s", dirname, filename);
    printf("Relative pathname for the file is: %s\n", filepathname);
    if ( ! stat( filepathname, &statdata) )  {
       print_statdata( filename,  &statdata );
    }
    else {
       fprintf (stderr, "Getting stat for %s", filepathname);
       perror( "Error in statdata while getting stat");
    }
}


int main (int argc,  char* argv[] ) {
DIR   *dpntr;
struct  dirent   *dentry;
char *dirname;
   if ( argc > 2 ) {
      printf ("Usage:  %s  [directory-name]\n", argv[0] );
      exit( 1 );
   }
   if ( argc ==  2 ) {
      dpntr =  opendir ( argv[1] );
      dirname = argv[1];
   }
   else {
      dpntr =  opendir ( "." );
      dirname = ".";
   }
   if ( dpntr ==  0 ) {
      fprintf (stderr, "Error in opening directory:  %s ", argv[1] );
      perror( "argv[0]");
   }

   dentry =   readdir ( dpntr );

   while ( dentry != 0 )  {
      printf( "*******\n");
      printf("Calling print for file %s\n",  dentry->d_name);
      do_stat_and_print( dirname,  dentry->d_name );
      dentry =   readdir ( dpntr );
   }
}
