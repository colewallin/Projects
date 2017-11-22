CSci 4061 Fall 2017
Assignment# 4:   Concurrent Programming with POSIX Threads
Made by: Cole Wallin

Objective: This program utilizes the POSIX thread library to calculate the size
of all the files in a directory tree.

Operation: Upon running this project, the user will be asked for a directory
path. This path must be relative to the current directory. The program will
then recursively traverse the directory tree and print out the total size of
all the files in the directory. Additionally, it will also print out the sizes
of each sub directory.

Limitations:
- Cannot handle hard or soft links.
