3800 #include "types.h"
3801 #include "x86.h"
3802 #include "defs.h"
3803 #include "date.h"
3804 #include "param.h"
3805 #include "memlayout.h"
3806 #include "mmu.h"
3807 #include "proc.h"
3808 
3809 int
3810 sys_fork(void)
3811 {
3812   return fork();
3813 }
3814 
3815 int
3816 sys_exit(void)
3817 {
3818   exit();
3819   return 0;  // not reached
3820 }
3821 
3822 int
3823 sys_wait(void)
3824 {
3825   return wait();
3826 }
3827 
3828 int
3829 sys_kill(void)
3830 {
3831   int pid;
3832 
3833   if(argint(0, &pid) < 0)
3834     return -1;
3835   return kill(pid);
3836 }
3837 
3838 int
3839 sys_getpid(void)
3840 {
3841   return proc->pid;
3842 }
3843 
3844 
3845 
3846 
3847 
3848 
3849 
3850 int
3851 sys_sbrk(void)
3852 {
3853   int addr;
3854   int n;
3855 
3856   if(argint(0, &n) < 0)
3857     return -1;
3858   addr = proc->sz;
3859   // Lazy allocation is enabled in trap.c.
3860   // if(growproc(n) < 0)
3861   //   return -1;
3862   return addr;
3863 }
3864 
3865 int
3866 sys_sleep(void)
3867 {
3868   int n;
3869   uint ticks0;
3870 
3871   if(argint(0, &n) < 0)
3872     return -1;
3873   acquire(&tickslock);
3874   ticks0 = ticks;
3875   while(ticks - ticks0 < n){
3876     if(proc->killed){
3877       release(&tickslock);
3878       return -1;
3879     }
3880     sleep(&ticks, &tickslock);
3881   }
3882   release(&tickslock);
3883   return 0;
3884 }
3885 
3886 // return how many clock tick interrupts have occurred
3887 // since start.
3888 int
3889 sys_uptime(void)
3890 {
3891   uint xticks;
3892 
3893   acquire(&tickslock);
3894   xticks = ticks;
3895   release(&tickslock);
3896   return xticks;
3897 }
3898 
3899 
3900 int
3901 sys_date(void)
3902 {
3903   struct rtcdate *r;
3904 
3905   if(argptr(0, (char **)&r, sizeof(struct rtcdate)) < 0)
3906     return -1;
3907   cmostime(r);
3908   return 0;
3909 }
3910 
3911 
3912 
3913 
3914 
3915 
3916 
3917 
3918 
3919 
3920 
3921 
3922 
3923 
3924 
3925 
3926 
3927 
3928 
3929 
3930 
3931 
3932 
3933 
3934 
3935 
3936 
3937 
3938 
3939 
3940 
3941 
3942 
3943 
3944 
3945 
3946 
3947 
3948 
3949 
