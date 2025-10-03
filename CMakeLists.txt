cmake_minimum_required(VERSION 3.16)

# ⚡️ Active NASM et force le format 32 bits
enable_language(ASM_NASM)
set(CMAKE_ASM_NASM_OBJECT_FORMAT elf32)

project(myos C ASM_NASM)


set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32 -ffreestanding -O2 -fno-builtin -fno-stack-protector -nostdlib")


add_executable(kernel
  boot/boot.asm
  boot/isr_stubs.asm
  kernel/kmain.c
  kernel/vga.c
  kernel/idt.c
  kernel/isr.c
  kernel/pic.c
  kernel/pit.c
  kernel/keyboard.c
  kernel/mmu.c
  kernel/kmalloc.c
  kernel/shell.c
)


set_target_properties(kernel PROPERTIES
  LINK_FLAGS "-T ${CMAKE_SOURCE_DIR}/linker.ld -nostdlib -Wl,-m,elf_i386,--build-id=none"
)


add_custom_command(TARGET kernel POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O binary kernel kernel.bin
  COMMAND mkdir -p iso/boot/grub
  COMMAND cp kernel iso/boot/kernel.elf
  COMMAND bash -c \"echo -e 'set timeout=0\\nmenuentry \\\"myOS\\\" { multiboot /boot/kernel.elf }' > iso/boot/grub/grub.cfg\"
  COMMAND grub-mkrescue -o myos.iso iso
)
