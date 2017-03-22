6750 #include "types.h"
6751 #include "param.h"
6752 #include "memlayout.h"
6753 #include "mmu.h"
6754 #include "proc.h"
6755 #include "defs.h"
6756 #include "x86.h"
6757 #include "elf.h"
6758 
6759 int
6760 exec(char *path, char **argv)
6761 {
6762   char *s, *last;
6763   int i, off;
6764   uint argc, sz, sp, ustack[3+MAXARG+1];
6765   struct elfhdr elf;
6766   struct inode *ip;
6767   struct proghdr ph;
6768   pde_t *pgdir, *oldpgdir;
6769 
6770   begin_op();
6771 
6772   // Opens the named binary path.
6773   if((ip = namei(path)) == 0){
6774     end_op();
6775     return -1;
6776   }
6777   ilock(ip);
6778   pgdir = 0;
6779 
6780   // Check ELF header
6781   if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
6782     goto bad;
6783   if(elf.magic != ELF_MAGIC)
6784     goto bad;
6785 
6786   if((pgdir = setupkvm()) == 0)
6787     goto bad;
6788 
6789   // Load program into memory.
6790   sz = 0;
6791   // Iteratively reads different program header, each describing a segment or
6792   // other info that the system needs to prepare the program's execution.
6793   for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
6794     if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
6795       goto bad;
6796     if(ph.type != ELF_PROG_LOAD)
6797       continue;
6798     if(ph.memsz < ph.filesz)
6799       goto bad;
6800     if(ph.vaddr + ph.memsz < ph.vaddr)
6801       goto bad;
6802     if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
6803       goto bad;
6804     if(ph.vaddr % PGSIZE != 0)
6805       goto bad;
6806     if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
6807       goto bad;
6808   }
6809   iunlockput(ip);
6810   end_op();
6811   ip = 0;
6812 
6813   // Allocate two pages at the next page boundary.
6814   // Make the first inaccessible.  Use the second as the user stack.
6815   sz = PGROUNDUP(sz);
6816   if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
6817     goto bad;
6818   clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
6819   sp = sz;
6820 
6821   // Push argument strings, prepare rest of stack in ustack.
6822   for(argc = 0; argv[argc]; argc++) {
6823     if(argc >= MAXARG)
6824       goto bad;
6825     sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
6826     if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
6827       goto bad;
6828     ustack[3+argc] = sp;
6829   }
6830   ustack[3+argc] = 0;
6831 
6832   ustack[0] = 0xffffffff;  // fake return PC
6833   ustack[1] = argc;
6834   ustack[2] = sp - (argc+1)*4;  // argv pointer
6835 
6836   sp -= (3+argc+1) * 4;
6837   if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
6838     goto bad;
6839 
6840   // Save program name for debugging.
6841   for(last=s=path; *s; s++)
6842     if(*s == '/')
6843       last = s+1;
6844   safestrcpy(proc->name, last, sizeof(proc->name));
6845 
6846 
6847 
6848 
6849 
6850   // Commit to the user image.
6851   oldpgdir = proc->pgdir;
6852   proc->pgdir = pgdir;
6853   proc->sz = sz;
6854   proc->tf->eip = elf.entry;  // main
6855   proc->tf->esp = sp;
6856   switchuvm(proc);
6857   freevm(oldpgdir);
6858   return 0;
6859 
6860  bad:
6861   if(pgdir)
6862     freevm(pgdir);
6863   if(ip){
6864     iunlockput(ip);
6865     end_op();
6866   }
6867   return -1;
6868 }
6869 
6870 
6871 
6872 
6873 
6874 
6875 
6876 
6877 
6878 
6879 
6880 
6881 
6882 
6883 
6884 
6885 
6886 
6887 
6888 
6889 
6890 
6891 
6892 
6893 
6894 
6895 
6896 
6897 
6898 
6899 
