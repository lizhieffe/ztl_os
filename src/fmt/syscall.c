3600 #include "types.h"
3601 #include "defs.h"
3602 #include "param.h"
3603 #include "memlayout.h"
3604 #include "mmu.h"
3605 #include "proc.h"
3606 #include "x86.h"
3607 #include "syscall.h"
3608 
3609 // User code makes a system call with INT T_SYSCALL.
3610 // System call number in %eax.
3611 // Arguments on the stack, from the user call to the C
3612 // library system call function. The saved user %esp points
3613 // to a saved program counter, and then the first argument.
3614 
3615 // Fetch the int at addr from the current process.
3616 int
3617 fetchint(uint addr, int *ip)
3618 {
3619   if(addr >= proc->sz || addr+4 > proc->sz)
3620     return -1;
3621   *ip = *(int*)(addr);
3622   return 0;
3623 }
3624 
3625 // Fetch the nul-terminated string at addr from the current process.
3626 // Doesn't actually copy the string - just sets *pp to point at it.
3627 // Returns length of string, not including nul.
3628 int
3629 fetchstr(uint addr, char **pp)
3630 {
3631   char *s, *ep;
3632 
3633   if(addr >= proc->sz)
3634     return -1;
3635   *pp = (char*)addr;
3636   ep = (char*)proc->sz;
3637   for(s = *pp; s < ep; s++)
3638     if(*s == 0)
3639       return s - *pp;
3640   return -1;
3641 }
3642 
3643 // Fetch the nth 32-bit system call argument.
3644 int
3645 argint(int n, int *ip)
3646 {
3647   return fetchint(proc->tf->esp + 4 + 4*n, ip);
3648 }
3649 
3650 // Fetch the nth word-sized system call argument as a pointer
3651 // to a block of memory of size bytes.  Check that the pointer
3652 // lies within the process address space.
3653 int
3654 argptr(int n, char **pp, int size)
3655 {
3656   int i;
3657 
3658   if(argint(n, &i) < 0)
3659     return -1;
3660   if(size < 0 || (uint)i >= proc->sz || (uint)i+size > proc->sz)
3661     return -1;
3662   *pp = (char*)i;
3663   return 0;
3664 }
3665 
3666 // Fetch the nth word-sized system call argument as a string pointer.
3667 // Check that the pointer is valid and the string is nul-terminated.
3668 // (There is no shared writable memory, so the string can't change
3669 // between this check and being used by the kernel.)
3670 int
3671 argstr(int n, char **pp)
3672 {
3673   int addr;
3674   if(argint(n, &addr) < 0)
3675     return -1;
3676   return fetchstr(addr, pp);
3677 }
3678 
3679 extern int sys_chdir(void);
3680 extern int sys_close(void);
3681 extern int sys_dup(void);
3682 extern int sys_exec(void);
3683 extern int sys_exit(void);
3684 extern int sys_fork(void);
3685 extern int sys_fstat(void);
3686 extern int sys_getpid(void);
3687 extern int sys_kill(void);
3688 extern int sys_link(void);
3689 extern int sys_mkdir(void);
3690 extern int sys_mknod(void);
3691 extern int sys_open(void);
3692 extern int sys_pipe(void);
3693 extern int sys_read(void);
3694 extern int sys_sbrk(void);
3695 extern int sys_sleep(void);
3696 extern int sys_unlink(void);
3697 extern int sys_wait(void);
3698 extern int sys_write(void);
3699 extern int sys_uptime(void);
3700 extern int sys_date(void);
3701 
3702 static int (*syscalls[])(void) = {
3703 [SYS_fork]    sys_fork,
3704 [SYS_exit]    sys_exit,
3705 [SYS_wait]    sys_wait,
3706 [SYS_pipe]    sys_pipe,
3707 [SYS_read]    sys_read,
3708 [SYS_kill]    sys_kill,
3709 [SYS_exec]    sys_exec,
3710 [SYS_fstat]   sys_fstat,
3711 [SYS_chdir]   sys_chdir,
3712 [SYS_dup]     sys_dup,
3713 [SYS_getpid]  sys_getpid,
3714 [SYS_sbrk]    sys_sbrk,
3715 [SYS_sleep]   sys_sleep,
3716 [SYS_uptime]  sys_uptime,
3717 [SYS_open]    sys_open,
3718 [SYS_write]   sys_write,
3719 [SYS_mknod]   sys_mknod,
3720 [SYS_unlink]  sys_unlink,
3721 [SYS_link]    sys_link,
3722 [SYS_mkdir]   sys_mkdir,
3723 [SYS_close]   sys_close,
3724 [SYS_date]  sys_date,
3725 };
3726 
3727 char * get_syscall_name(int num) {
3728   switch (num) {
3729     case SYS_fork:
3730       return "fork";
3731     case SYS_exit:
3732       return "exit";
3733     case SYS_wait:
3734       return "wait";
3735     case SYS_pipe:
3736       return "pipe";
3737     case SYS_read:
3738       return "read";
3739     case SYS_kill:
3740       return "kill";
3741     case SYS_exec:
3742       return "exec";
3743     case SYS_fstat:
3744       return "fstat";
3745     case SYS_chdir:
3746       return "chdir";
3747     case SYS_dup:
3748       return "dup";
3749     case SYS_getpid:
3750       return "getpid";
3751     case SYS_sbrk:
3752       return "sbrk";
3753     case SYS_sleep:
3754       return "sleep";
3755     case SYS_uptime:
3756       return "uptime";
3757     case SYS_open:
3758       return "open";
3759     case SYS_write:
3760       return "write";
3761     case SYS_mknod:
3762       return "mknod";
3763     case SYS_unlink:
3764       return "unlink";
3765     case SYS_link:
3766       return "link";
3767     case SYS_mkdir:
3768       return "mkdir";
3769     case SYS_close:
3770       return "close";
3771     case SYS_date:
3772       return "date";
3773     default:
3774       return "unknown";
3775   }
3776 }
3777 
3778 void
3779 syscall(void)
3780 {
3781   int num;
3782 
3783   num = proc->tf->eax;
3784   if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
3785     proc->tf->eax = syscalls[num]();
3786     // lizhi: HW3. Since this is annoying, disable it.
3787     // cprintf("%s->%d\n", get_syscall_name(num), proc->tf->eax);
3788   } else {
3789     cprintf("%d %s: unknown sys call %d\n",
3790             proc->pid, proc->name, num);
3791     proc->tf->eax = -1;
3792   }
3793 }
3794 
3795 
3796 
3797 
3798 
3799 
