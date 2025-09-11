BUILD=build
SRC=src
ISO=iso
KERNEL=$(BUILD)/kernel.elf
ISO_OUT=$(BUILD)/LFS-Pain.iso

all: run

$(BUILD):
	mkdir -p $(BUILD)

$(KERNEL): | $(BUILD)
	nasm -f elf32 $(SRC)/kernel.asm -o $(BUILD)/kernel.o
	ld -m elf_i386 -T $(SRC)/linker.ld -o $(KERNEL) $(BUILD)/kernel.o

iso: $(KERNEL)
	mkdir -p $(ISO)/boot
	cp $(KERNEL) $(ISO)/boot/kernel.elf
	grub-mkrescue -o $(ISO_OUT) $(ISO)

run: iso
	qemu-system-x86_64 -cdrom $(ISO_OUT)

clean:
	rm -rf $(BUILD)
	find $(ISO)/boot -type f -name 'kernel.elf' -delete
