#  Assignment 5 makefile

CC = gcc
DEBUG = -g
THREAD = -pthread

all: quote_server quote_client

quote_server : quote_server.c
	$(CC) $(DEBUG) -w $(THREAD) quote_server.c -o quote_server

quote_client : quote_client.c
	$(CC) $(DEBUG) -w quote_client.c -o quote_client

clean:
	rm -rf quote_server quote_client
