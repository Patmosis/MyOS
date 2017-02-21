# MyOS
First trial of a bootable program

* **Author**

  - ZAMBAUX Gauthier

* **Build**

  * *Assemble program as a pure binary file*
   - `nasm -f bin -o myOS.bin myOS.asm`

  * *Create floppy disk image*
   - `dd status=noxfer conv=notrunc if=myOS.bin of=myOS.flp`

* **Execute on a virtual machine**

  * *Launch floppy disk image on a virtual machine (qemu)*
   - `qemu-system-i386 -fda myOS.flp`

* **Boot program**

  * *Make ISO image*
   - `mkisofs -o myOS.iso -b myOS.flp ./`

  * *Burn ISO on floppy disk, CD or USB drive and boot*

* **Description**

	* *This project aims at developping a very basic Operating System using the x86 assembly language, NASM and BIOS interrupts.*

	* *Tutorial used to start this project can be found [here](http://mikeos.sourceforge.net/write-your-own-os.html)*
