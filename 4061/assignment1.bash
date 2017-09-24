#!/bin/bash

#---------------------------------------------------------------------
# CSci 4061 Fall 2017
# Assignment# 1
# This work must be done individually.
# Student name:
# Student:
# x500 id:
# Operating system on which you tested your code: Linux, Unix, MacOS
# CSELABS machine: <machine you tested on eg: xyz.cselabs.umn.edu>
#---------------------------------------------------------------------


echo " "

######################
# Directives for usage

 if [[ $argv == 0 ]]
  then
    output="Process argument missing \n"
    echo -e $output
  else
    output="SELECT THE FUNCTION YOU WANT TO EXECUTE: \n"
    echo -e $output
    output="1. Search for files"
    echo -e $output
    output="2. Calculate total length"
    echo -e $output
    output="3. Find zero length files"
    echo -e $output
    output="4. Create backup files"
    echo -e $output
    output="5. Exit"
    echo -e $output
  fi

  echo -e "\nEnter option "
  read option

#  echo $option

  case "$option" in

  1)  echo "Searchng for files"
      echo "Enter directory name:"
      read dir
      echo "Enter file name:"
      read filename
      # Make sure the directory name is valid
      if [ -d $dir ]
      then
        # Format the output
        find "$dir" \( -name $filename -printf '%M %n %u %g %s %Cb %Cd %Ck:%CM %f\n' -o -type d -name $filename \)
	    else
        echo "That is not a valid directory"
        exit 0
	    fi

	    ;;
	2)  echo "Calculating total of the size of all files in the directory tree"
	    echo "Enter directory name:"
	    read dir
	    #Make the directory name is valid
	    if [ -d $dir ]
	    then
        sum=0
        list=$(find $dir -type f)
        for file in $list;
		      do
            let sum=$sum+$(stat -c%s $file)
            #echo $sum
        done
        echo "The files in the given directory contain $sum bytes worth of memory"
	    else
        echo "That is not a valid directory"
        exit 0
	    fi
	    ;;

  3)  echo "Finding zero length files"
      echo "Enter directory name:"
      read dir
      if [ -d $dir ]
	    then
        sum=0
        # Find the files
        list=$(find $dir -maxdepth 1 -type f)
        for file in $list;
		      do
            #If its length is zero, print out its filename
            if [ $(stat -c%s $file) -eq 0 ]
            then
              echo " "
              echo "$file is a zero-byte file"
            fi
          done
        echo "The files in the given directory contain $sum bytes worth of memory"
	    else
        echo "That is not a valid directory"
        exit 0
	    fi
	    ;;

	 4) echo  "Creating backup files"
      echo "Enter directory name:"
      read dir
      echo "Enter a filename:"
      read filename
      if [ -d $dir ]
      then
        #FILES
        echo " "
        list=$(find $dir -mindepth 1 -name $filename -type f)
        echo "**** Files ****"
        echo $list
        #Check throught the whole directory.
        for file in $list;
          do
            # Searching for a backup
            backup=$(find $dir -mindepth 1 -wholename $file.bak )
            if [ $backup ]
            then # Found one
              echo "There is a .bak file for $file"
              #Check if the backup and the master are different
              if [[ $(diff -rq $file $backup | wc -c) -ne 0 ]]
              then
                echo "The current file has been updated since the last backup."
                #set the .bak to .bak-MM-DD-YYYY
                mv $backup $backup-$(date +%m-%d-%Y)
                echo "Timestamping the old backup with -$(date +%m-%d-%Y) and creating a new one."
                #Make a copy of the matched file with .bak at the end
                cp -R $file $file.bak
              else
                echo "There is no difference between $file and its backup. Do nothing"
              fi
            else
              #No back up, making one.
              echo "There was no backup found for $file. Making one."
              cp -R $file $file.bak
            fi
          done

          #DIRECTORIES
          echo " "
          list=$(find $dir -mindepth 1 -name $filename -type d)
          echo "**** Directories ****"
          echo $list
          #Check through the whole directory.
          for file in $list;
            do
              # Searching for a backup
              backup=$(find $dir -mindepth 1 -wholename $file.bak )
              echo $backup
              if [ $backup ]
              then # Found one
                echo "There is a .bak file for $file"
                #Check if the backup and the master are different
                if [[ $(diff -rq $file $backup | wc -c) -ne 0 ]]
                then
                  echo "The current file has been updated since the last backup."
                  #set the .bak to .bak-MM-DD-YYYY
                  mv $backup $backup-$(date +%m-%d-%Y)
                  echo "Timestamping the old backup with -$(date +%m-%d-%Y) and creating a new one."
                  #Make a copy of the matched file with .bak at the end
                  cp -R $file $file.bak
                else
                  echo "There is no difference between $file and its backup. Do nothing"
                fi
              else
                #No back up, making one.
                echo "There was no backup found for $file. Making one."
                cp -R $file $file.bak
              fi
            done

	    else
        echo "That is not a valid directory"
        exit 0
	    fi
	    ;;

	5) echo "Exiting the program. Thanks"
	  exit
	  ;;
   esac
