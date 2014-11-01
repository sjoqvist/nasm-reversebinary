TARGET=reversebinary

.PHONY: all clean

all: $(TARGET)

reversebinary.o: reversebinary.asm
	nasm -f elf32 -w+all -o reversebinary.o reversebinary.asm

$(TARGET): reversebinary.o
	ld -s -m elf_i386 -o $(TARGET) reversebinary.o

clean:
	$(RM) $(TARGET) reversebinary.o
