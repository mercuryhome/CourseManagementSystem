#
# Makefile for example programs
#

# PostgreSQL configuration using pg_config
PG_CONFIG = pg_config
PG_CFLAGS = $(shell $(PG_CONFIG) --cflags) -I$(shell $(PG_CONFIG) --includedir)
PG_LDFLAGS = $(shell $(PG_CONFIG) --ldflags) -L$(shell $(PG_CONFIG) --libdir)
PG_LIBS = -lpq $(shell $(PG_CONFIG) --libs)

# Compiler flags
CC = gcc
CFLAGS = $(PG_CFLAGS) -g -O2 -Wno-unused-but-set-variable -Wno-unused-function
CPPFLAGS = 
LDFLAGS = $(PG_LDFLAGS) $(PG_LIBS)

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
