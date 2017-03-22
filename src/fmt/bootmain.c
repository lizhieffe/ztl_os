9750 // Boot loader.
9751 //
9752 // Part of the boot block, along with bootasm.S, which calls bootmain().
9753 // bootasm.S has put the processor into protected 32-bit mode.
9754 // bootmain() loads an ELF kernel image from the disk starting at
9755 // sector 1 and then jumps to the kernel entry routine.
9756 
9757 #include "types.h"
9758 #include "elf.h"
9759 #include "x86.h"
9760 #include "memlayout.h"
9761 
9762 #define SECTSIZE  512
9763 
9764 void readseg(uchar*, uint, uint);
9765 
9766 void
9767 bootmain(void)
9768 {
9769   struct elfhdr *elf;
9770   struct proghdr *ph, *eph;
9771   void (*entry)(void);
9772   uchar* pa;
9773 
9774   elf = (struct elfhdr*)0x10000;  // scratch space
9775 
9776   // Read 1st page off disk.
9777   // note(lizhi): actually read from the second sector. In readseg(), the
9778   // sector is always +1 compare to the input.
9779   readseg((uchar*)elf, 4096, 0);
9780 
9781   // Is this an ELF executable?
9782   if(elf->magic != ELF_MAGIC)
9783     return;  // let bootasm.S handle error
9784 
9785   // Load each program segment (ignores ph flags).
9786   ph = (struct proghdr*)((uchar*)elf + elf->phoff);
9787   eph = ph + elf->phnum;
9788   for(; ph < eph; ph++){
9789     pa = (uchar*)ph->paddr;
9790     readseg(pa, ph->filesz, ph->off);
9791     if(ph->memsz > ph->filesz)
9792       stosb(pa + ph->filesz, 0, ph->memsz - ph->filesz);
9793   }
9794 
9795   // Call the entry point from the ELF header.
9796   // Does not return!
9797   entry = (void(*)(void))(elf->entry);
9798   entry();
9799 }
9800 void
9801 waitdisk(void)
9802 {
9803   // Wait for disk ready.
9804   while((inb(0x1F7) & 0xC0) != 0x40)
9805     ;
9806 }
9807 
9808 // Read a single sector at offset into dst.
9809 void
9810 readsect(void *dst, uint offset)
9811 {
9812   // Issue command.
9813   waitdisk();
9814   outb(0x1F2, 1);   // count = 1
9815   outb(0x1F3, offset);
9816   outb(0x1F4, offset >> 8);
9817   outb(0x1F5, offset >> 16);
9818   outb(0x1F6, (offset >> 24) | 0xE0);
9819   outb(0x1F7, 0x20);  // cmd 0x20 - read sectors
9820 
9821   // Read data.
9822   waitdisk();
9823   insl(0x1F0, dst, SECTSIZE/4);
9824 }
9825 
9826 // Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
9827 // Might copy more than asked.
9828 void
9829 readseg(uchar* pa, uint count, uint offset)
9830 {
9831   uchar* epa;
9832 
9833   epa = pa + count;
9834 
9835   // Round down to sector boundary.
9836   pa -= offset % SECTSIZE;
9837 
9838   // Translate from bytes to sectors; kernel starts at sector 1.
9839   offset = (offset / SECTSIZE) + 1;
9840 
9841   // If this is too slow, we could read lots of sectors at a time.
9842   // We'd write more to memory than asked, but it doesn't matter --
9843   // we load in increasing order.
9844   for(; pa < epa; pa += SECTSIZE, offset++)
9845     readsect(pa, offset);
9846 }
9847 
9848 
9849 
