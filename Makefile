CFLAGS=-Wall -Wextra -std=c11 -ggdb3 -fdiagnostics-color=auto --pedantic
LDFLAGS=-Wall -Wextra -ggdb3 -fdiagnostics-color=auto --pedantic
LIBS=sztokfiszlib.o sztokfisz.o
LD=gcc
ASM=nasm

LIBS=sztokfisz.o sztokfiszlib.o

all: test

sztokfisz.o: sztokfisz.asm
	$(ASM) -f elf64 -ggdb3 -F DWARF -o $@ $<

test: test.o $(LIBS)
	$(LD) $(LDFLAGS) -o $@ $^

clean:
	rm -f *.o *~ a.ppm

tests: test wejscie.in
	./test < wejscie.in

gdb: test wejscie.in
	gdb ./test

val: test wejscie.in
	valgrind -v --leak-check=full --track-origins=yes ./test < wejscie.in
