#include "defs.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"
#include "types.h"
#include "x86.h"

void initlock(struct spinlock* lock, char* name) {
  lock->locked = 0;
  lock->name = name;
  lock->cpu = 0;
}

// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void acquire(struct spinlock* lock) {
  // Disable interrupt to avoid deadlock.
  pushcli();
  if (holding(lock)) {
    panic("acquire");
  }

  while (xchg(&lock->locked, 1) != 0)
    ;

  // tell the C compiler and the processor to not move loads or stores past this
  // point, to ensure that the critical section's memory references happen after
  // the lock is acquired.
  __sync_synchronize();

  // Record info about the lock acquisition for debugging.
  lock->cpu = cpu;
  getcallerpcs(&lock, lock->pcs);
}

void release(struct spinlock* lock) {
  if (!holding(lock)) {
    panic("release");
  }

  lock->pcs[0] = 0;
  lock->cpu = 0;

  // tell the C compiler and the processor to not move loads or stores past this
  // point, to ensure that the critical section's memory references happen after
  // the lock is acquired.
  __sync_synchronize();

  // TODO(lizhi): why???
  // 
  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lock->locked) : );
  
  popcli();
}

void getcallerpcs(void* v, uint pcs[]) {
  uint* ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++) {
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
      ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}

// check whether this cpu is holding the lock.
int holding(struct spinlock* lock) {
  return lock->locked && lock->cpu == cpu;
}

// pushcli/popcli are like cli/sti excpet that they are matched: it takes two
// popcli to undo two pushcli. Also, if interrupts are off, then pushcli,
// popcli leaves them off.
void pushcli(void) {
  int eflags = readeflags();
  cli();
  if (cpu->ncli == 0) {
    cpu->intena = eflags & FL_IF;
  }
  cpu->ncli++;
}

void popcli(void) {
  if ((readeflags() & FL_IF)) {
    panic("popcli - interruptible");
  }
  if (--cpu->ncli < 0) {
    panic("popcli");
  }
  if (cpu->ncli == 0) {
    sti();
  }
}
