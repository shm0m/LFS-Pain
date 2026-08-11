# GRUB-Pain

A GRUB written from scratch, which hands over to a real Linux kernel. The point is to prove that it works.

The bootloader starts in Real Mode, switches the CPU to Protected Mode, sets up physical memory, then passes control to an authentic Linux kernel — no existing bootloader involved at any step.

## Demo

https://github.com/user-attachments/assets/ead4596f-9346-4171-952d-075466c48215

## Boot sequence

1. BIOS loads the bootloader from the first sector
2. Real Mode → Protected Mode switch (GDT set up, segment registers reloaded)
3. Physical memory allocation
4. Handover to the Linux kernel

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/shm0m/GRUB-Pain.git
   ```

2. Run the ISO with qemu:
   ```bash
   qemu-system-x86_64 -cdrom iso/painos.iso -m 512
   ```

## Built with

C, x86 assembly, GNU Make, QEMU

## Authors

Shaima DEROUICH  
Andy ANDRIAMANGA  
Matéo DEROUBAIX

Contributions are welcome — fork the repository and submit a pull request.
