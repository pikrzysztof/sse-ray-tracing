CFLAGS=-Wall -Wextra -std=c11 --pedantic
LDFLAGS=-Wall -Wextra --pedantic
LIBS=sztokfiszlib.o sztokfisz.o
LD=gcc
ASM=nasm

LIBS=sztokfisz.o sztokfiszlib.o

all: test

sztokfisz.o: sztokfisz.asm
	$(ASM) -f elf64 -o $@ $<

test: test.o $(LIBS)
	$(LD) $(LDFLAGS) -o $@ $^

clean:
	rm -f *.o *~ a.ppm test
