3400 #include "types.h"
3401 #include "defs.h"
3402 #include "param.h"
3403 #include "memlayout.h"
3404 #include "mmu.h"
3405 #include "proc.h"
3406 #include "x86.h"
3407 #include "traps.h"
3408 #include "spinlock.h"
3409 
3410 // Interrupt descriptor table (shared by all CPUs).
3411 struct gatedesc idt[256];
3412 extern uint vectors[];  // in vectors.S: array of 256 entry pointers
3413 struct spinlock tickslock;
3414 uint ticks;
3415 
3416 void
3417 tvinit(void)
3418 {
3419   int i;
3420 
3421   for(i = 0; i < 256; i++)
3422     SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
3423 
3424   // It specifies that the gate is of type ‘‘trap’’ by passing a value of 1 as
3425   // second argument. Trap gates don’t clear the IF flag, allowing other
3426   // interrupts during the system call handler
3427   //
3428   // It also sets the system call gate privilege to DPL_USER, which allows a
3429   // user program to generate the trap with an explicit int instruction. xv6
3430   // doesn’t allow processes to raise other interrupts (e.g., device interrupts)
3431   // with int; if they try, they will encounter a general protection exception,
3432   // which goes to vector 13
3433   SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
3434 
3435   initlock(&tickslock, "time");
3436 }
3437 
3438 void
3439 idtinit(void)
3440 {
3441   lidt(idt, sizeof(idt));
3442 }
3443 
3444 
3445 
3446 
3447 
3448 
3449 
3450 void
3451 trap(struct trapframe *tf)
3452 {
3453   if(tf->trapno == T_SYSCALL){
3454     if(proc->killed)
3455       exit();
3456     proc->tf = tf;
3457     syscall();
3458     if(proc->killed)
3459       exit();
3460     return;
3461   }
3462 
3463   switch(tf->trapno){
3464   case T_IRQ0 + IRQ_TIMER:
3465     if(cpunum() == 0){
3466       acquire(&tickslock);
3467       ticks++;
3468       wakeup(&ticks);
3469       release(&tickslock);
3470     }
3471     lapiceoi();
3472     break;
3473   case T_IRQ0 + IRQ_IDE:
3474     ideintr();
3475     lapiceoi();
3476     break;
3477   case T_IRQ0 + IRQ_IDE+1:
3478     // Bochs generates spurious IDE1 interrupts.
3479     break;
3480   case T_IRQ0 + IRQ_KBD:
3481     kbdintr();
3482     lapiceoi();
3483     break;
3484   case T_IRQ0 + IRQ_COM1:
3485     uartintr();
3486     lapiceoi();
3487     break;
3488   case T_IRQ0 + 7:
3489   case T_IRQ0 + IRQ_SPURIOUS:
3490     cprintf("cpu%d: spurious interrupt at %x:%x\n",
3491             cpunum(), tf->cs, tf->eip);
3492     lapiceoi();
3493     break;
3494 
3495 
3496 
3497 
3498 
3499 
3500   default:
3501     if(proc == 0 || (tf->cs&3) == 0){
3502       // In kernel, it must be our mistake.
3503       cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
3504               tf->trapno, cpunum(), tf->eip, rcr2());
3505       panic("trap");
3506     }
3507     // In user space, assume process misbehaved.
3508     cprintf("pid %d %s: trap %d err %d on cpu %d "
3509             "eip 0x%x addr 0x%x--kill proc\n",
3510             proc->pid, proc->name, tf->trapno, tf->err, cpunum(), tf->eip,
3511             rcr2());
3512     proc->killed = 1;
3513   }
3514 
3515   // Force process exit if it has been killed and is in user space.
3516   // (If it is still executing in the kernel, let it keep running
3517   // until it gets to the regular system call return.)
3518   if(proc && proc->killed && (tf->cs&3) == DPL_USER)
3519     exit();
3520 
3521   // Force process to give up CPU on clock tick.
3522   // If interrupts were on while locks held, would need to check nlock.
3523   if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
3524     yield();
3525 
3526   // Check if the process has been killed since we yielded
3527   if(proc && proc->killed && (tf->cs&3) == DPL_USER)
3528     exit();
3529 }
3530 
3531 
3532 
3533 
3534 
3535 
3536 
3537 
3538 
3539 
3540 
3541 
3542 
3543 
3544 
3545 
3546 
3547 
3548 
3549 
