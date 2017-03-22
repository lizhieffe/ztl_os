9650 #include "asm.h"
9651 #include "memlayout.h"
9652 #include "mmu.h"
9653 
9654 # Start the first CPU: switch to 32-bit protected mode, jump into C.
9655 # The BIOS loads this code from the first sector of the hard disk into
9656 # memory at physical address 0x7c00 and starts executing in real mode
9657 # with %cs=0 %ip=7c00.
9658 
9659 .code16                       # Assemble for 16-bit mode
9660 .globl start
9661 start:                        # 0x7c00
9662   cli                         # BIOS enabled interrupts; disable
9663 
9664   # Zero data segment registers DS, ES, and SS.
9665   xorw    %ax,%ax             # Set %ax to zero
9666   movw    %ax,%ds             # -> Data Segment
9667   movw    %ax,%es             # -> Extra Segment
9668   movw    %ax,%ss             # -> Stack Segment
9669 
9670   # Physical address line A20 is tied to zero so that the first PCs
9671   # with 2 MB would run software that assumed 1 MB.  Undo that.
9672   # lizhi: this seta20.1 and seta20.2 is to enable a20. Before it is enabled,
9673   # the address bus is 20 bits and can only access 1MB memory. After it is
9674   # enabled, it is 32 bits and can access 4GB memory.
9675 seta20.1:
9676   inb     $0x64,%al               # Wait for not busy
9677   testb   $0x2,%al
9678   jnz     seta20.1
9679 
9680   movb    $0xd1,%al               # 0xd1 -> port 0x64
9681   outb    %al,$0x64
9682 
9683 seta20.2:
9684   inb     $0x64,%al               # Wait for not busy
9685   testb   $0x2,%al
9686   jnz     seta20.2
9687 
9688   movb    $0xdf,%al               # 0xdf -> port 0x60
9689   outb    %al,$0x60
9690 
9691   # Switch from real to protected mode.  Use a bootstrap GDT that makes
9692   # virtual addresses map directly to physical addresses so that the
9693   # effective memory map doesn't change during the transition.
9694   lgdt    gdtdesc
9695   movl    %cr0, %eax
9696   orl     $CR0_PE, %eax
9697   movl    %eax, %cr0
9698 
9699 
9700   # Complete the transition to 32-bit protected mode by using a long jmp
9701   # to reload %cs and %eip.  The segment descriptors are set up with no
9702   # translation, so that the mapping is still the identity mapping.
9703   #
9704   # Note to myself: SEG_KCODE is 1, SEG_KCODE<<3 is 8. Each entry in GDT is 8
9705   # bytes, and the second entry is code descriptor, so SEG_CODE<<3 is the
9706   # selector to the code descriptor. The ljmp will load the code descriptor to
9707   # cs register and $start32 to the ip register.
9708   ljmp    $(SEG_KCODE<<3), $start32
9709 
9710 .code32  # Tell assembler to generate 32-bit code now.
9711 start32:
9712   # Set up the protected-mode data segment registers
9713   movw    $(SEG_KDATA<<3), %ax    # Our data segment selector
9714   movw    %ax, %ds                # -> DS: Data Segment
9715   movw    %ax, %es                # -> ES: Extra Segment
9716   movw    %ax, %ss                # -> SS: Stack Segment
9717   movw    $0, %ax                 # Zero segments not ready for use
9718   movw    %ax, %fs                # -> FS
9719   movw    %ax, %gs                # -> GS
9720 
9721   # Set up the stack pointer and call into C.
9722   movl    $start, %esp
9723   call    bootmain
9724 
9725   # If bootmain returns (it shouldn't), trigger a Bochs
9726   # breakpoint if running under Bochs, then loop.
9727   movw    $0x8a00, %ax            # 0x8a00 -> port 0x8a00
9728   movw    %ax, %dx
9729   outw    %ax, %dx
9730   movw    $0x8ae0, %ax            # 0x8ae0 -> port 0x8a00
9731   outw    %ax, %dx
9732 spin:
9733   jmp     spin
9734 
9735 # Bootstrap GDT
9736 .p2align 2                                # force 4 byte alignment
9737 gdt:
9738   SEG_NULLASM                             # null seg
9739   SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)   # code seg
9740   SEG_ASM(STA_W, 0x0, 0xffffffff)         # data seg
9741 
9742 gdtdesc:
9743   .word   (gdtdesc - gdt - 1)             # sizeof(gdt) - 1
9744   .long   gdt                             # address gdt
9745 
9746 
9747 
9748 
9749 
