EXEC2= ../../bin/lola
CFLAGS          = ${INCLUDE}
LIBS    = -lm

#LIBS = -lm -lc

CC = gcc

OBJECTS2 = main.o \
	chain.o\
	common.o\
	ozco_canny.o\
	segment.o \
	thresh.o 


shell: $(OBJECTS2) 
	$(CC) -o $(EXEC2) $(OBJECTS2) $(LIBS)

$(OBJECTS): header.h

clean:
	rm *.o
