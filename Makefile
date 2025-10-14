# Noms des fichiers ASM
KERNEL_ASM=kernel.asm
KEYBOARD_ASM=keyboard.asm
IDT_ASM=idt.asm
LINKER=linker.ld

# Nom du binaire final
KERNEL_BIN=kernel.bin
ISO_DIR=iso
ISO_FILE=painos.iso

# Compile le kernel
$(KERNEL_BIN): $(KERNEL_ASM) $(KEYBOARD_ASM) $(IDT_ASM) $(LINKER)
	nasm -f elf32 $(KERNEL_ASM) -o kernel.o
	nasm -f elf32 $(KEYBOARD_ASM) -o keyboard.o
	nasm -f elf32 $(IDT_ASM) -o idt.o
	ld -m elf_i386 -T $(LINKER) -o $(KERNEL_BIN) kernel.o keyboard.o idt.o

# Crée le dossier ISO et grub.cfg
$(ISO_DIR)/boot/grub/grub.cfg:
	mkdir -p $(ISO_DIR)/boot/grub
	echo 'set timeout=5' > $(ISO_DIR)/boot/grub/grub.cfg
	echo 'set default=0' >> $(ISO_DIR)/boot/grub/grub.cfg
	echo 'menuentry "PainOS" { multiboot /boot/kernel.bin }' >> $(ISO_DIR)/boot/grub/grub.cfg

# Génère l'ISO
$(ISO_FILE): $(KERNEL_BIN) $(ISO_DIR)/boot/grub/grub.cfg
	cp $(KERNEL_BIN) $(ISO_DIR)/boot/
	grub-mkrescue -o $(ISO_FILE) $(ISO_DIR)

# Lance QEMU
run: $(ISO_FILE)
	qemu-system-i386 -cdrom $(ISO_FILE)

# Tout compiler
all: $(ISO_FILE)
