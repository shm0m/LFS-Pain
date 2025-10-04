cmake_minimum_required(VERSION 3.16)

enable_language(ASM_NASM)
set(CMAKE_ASM_NASM_OBJECT_FORMAT elf32)

project(myos C ASM_NASM)

# 32-bit freestanding build
set(CMAKE_C_FLAGS "-m32 -ffreestanding -O2 -fno-builtin -fno-stack-protector -nostdlib -fno-pic -no-pie")

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
  kernel/irq.c
)

set_target_properties(kernel PROPERTIES
  LINK_FLAGS "-T ${CMAKE_SOURCE_DIR}/linker.ld -nostdlib -Wl,-m,elf_i386,--build-id=none -no-pie"
)


add_custom_command(TARGET kernel POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O binary kernel kernel.bin
  COMMAND ${CMAKE_COMMAND} -E make_directory iso/boot/grub
  COMMAND ${CMAKE_COMMAND} -E copy kernel iso/boot/kernel.elf
  COMMAND ${CMAKE_COMMAND} -E echo "set timeout=0" > grub.tmp
  COMMAND ${CMAKE_COMMAND} -E echo "menuentry 'myOS' { multiboot /boot/kernel.elf }" >> grub.tmp
  COMMAND ${CMAKE_COMMAND} -E copy grub.tmp iso/boot/grub/grub.cfg
  COMMAND grub-mkrescue -o myos.iso iso
)
