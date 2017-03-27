#include "defs.h"
#include "param.h"
#include "proc.h"
#include "mmu.h"
#include "spinlock.h"
#include "x86.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

// Enter scheduler. Must hold only ptable.lock and have changed proc->state.
// Saves and restores intena because intena is a property of this kernel thread,
// not this CPU. It should be proc->intena and proc->ncli, but that would break
// in the few places where a lock is held but there is no process.
void sched(void) {
  int intena;

  // TODO(lizhi): don't fully understand this part.
  if (!holding(&ptable.lock)) {
    panic("sched ptable.lock");
  }
  if (cpu->ncli != 1) {
    panic("sched locks");
  }
  if (proc->state == RUNNING) {
    panic("sched running");
  }
  if (readeflags()&FL_IF) {
    panic("sched interruptible");
  }
  intena = cpu->intena;
  // TODO(lizhi): add swtch.
  cpu->intena = intena;
}

// TODO(lizhi): what is chan??
//
// Atomically release |lock| and sleep on chan. Reacquires lock when awakened.
void sleep(void* chan, struct spinlock* lock) {
  if (proc == 0) {
    panic("sleep");
  }
  if (lock == 0) {
    panic("sleep without lock");
  }

  // Must acquire ptable.lock in order to change p->state and then call sched.
  // Once we hold ptable.lock, we can be guaranteed that we won't miss any
  // wakeup (wakeup runs with ptable.lock locked), so it is okay to release
  // |lock|.
  if (lock != &ptable.lock) {
    acquire(&ptable.lock);
    release(lock);
  }

  // Go to sleep.
  proc->chan = chan;
  proc->state = SLEEPING;
  sched();

  // Tidy up.
  proc->chan = 0;

  // Reacquire original lock.
  if (lock != &ptable.lock) {
    release(&ptable.lock);
    acquire(lock);
  }
}

//PAGEBREAK!
// wake up all processes sleeping on chan. The ptable lock must be hold!
static void wakeup1(void* chan) {
  struct proc* p;
  for (p = ptable.proc; p < &ptable.proc[NPROC]; ++p) {
    if (p->state == SLEEPING && p->chan == chan) {
      p->state = RUNNABLE;
    }
  }
}

// TODO(lizhi): what is chan??
//
// wake up all processes sleeping on chan.
void wakeup(void* chan) {
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

//PAGEBREAK: 36
// Print a process listing to console. For debugging.
// Runs when user types ^P on concole.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
  static char* states[] = {
    [UNUSED]    "unused",
    [EMBRYO]    "embyro",
    [SLEEPING]  "sleeping",
    [RUNNABLE]  "runnable",
    [RUNNING]   "running",
    [ZOMBIE]    "zombie"
  };
  // int i;
  struct proc* p;
  char* state;
  // uint pc[10];

  for (p = ptable.proc; p < &ptable.proc[NPROC]; ++p) {
    if (p->state == UNUSED) {
      continue;
    }
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state]) {
      state = states[p->state];
    } else {
      state = "????? something is wrong";
    }

    cprintf("%d %s %s", p->pid, state, p->name);
    if (p->state == SLEEPING) {
      // TODO(lizhi): print stack trace.
    }
    cprintf("\n");
  }
}
