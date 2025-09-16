#
# Makefile for example programs
#

# PostgreSQL paths for Postgres.app installation
PG_INCLUDE = /Applications/Postgres.app/Contents/Versions/17/include
PG_LIB = /Applications/Postgres.app/Contents/Versions/17/lib

# Compiler flags
CC = gcc
CFLAGS = -Wall -g -O2 -Wno-unused-but-set-variable -Wno-unused-function
CPPFLAGS = -I$(PG_INCLUDE)
LDFLAGS = -L$(PG_LIB) -lpq

# Programs to build
PROGS = testlibpq testlibpq2 testlibpq3 testlibpq4 testlo testlo64

# Default target
all: $(PROGS)

# Build rules
%: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $< -o $@ $(LDFLAGS)

# Clean target
clean distclean:
	rm -f $(PROGS) *.o
	rm -rf *.dSYM

# Phony targets
.PHONY: all clean distclean
