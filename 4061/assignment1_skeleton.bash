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

 if [ $argv == 0 ]
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
	    #here you should implement for search files
	    # Begin Code
	    
	    #End Code
	    ;;
	2)  echo "Calculating total of the size of all files in the directory tree"
	    #here you should implement the code to calculate the size of all files in a folder
	    # Begin Code
	    
	    #End Code
	    ;;
	    
	3) echo "Finding zero length files"
	    #here you should implement the code to find empty files
	    # Begin Code
	    
	    #End Code
	    ;;
	    
	 4) echo  "Creating backup files"
	    #here you should implement the backup code  
	    # Begin Code
	    
	    #End Code
	    ;;
	    
	5) echo "Exiting the program. Thanks"
	  exit
	  ;;
   esac
  
  
  
  
