CSci 4061 Fall 2017
Assignment# 5:   Interprocess Communication using TCP/IP
Made by: Cole Wallin

Objective: This program utilizes the POSIX thread and socket libraries to
set up a multi-threaded server. As each new client connects with the server, the
server will spawn a new thread to handle the interactions with the client.


Operation:
To start up the server, the user simply needs to run the following-
  1. make
  2. ./quote_server config.txt

To get a client connected to the server, the user must open another terminal and
run the following commands-
  1. ./quote_client localhost 6789

The client can then interact with the server by following the instructions
being communicated through the terminal.


Limitations:
- The server automatically connects to port 6789 so the client has no choice but
  to connect to that port as well

- The config.txt file for the server is hard coded into the server code. If you
  wanted to add more files with quotes in them to the config file, you would
  also need to change the server code to be able to handle this.
