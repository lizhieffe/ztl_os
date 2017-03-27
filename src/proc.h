#include "param.h"
#include "types.h"

// per-CPU state
struct cpu {
  // Local APIC ID
  uchar apicid;
  // // swtch() here to enter scheduler.
  // struct context* scheduler;
  // // Used by x86 to find stack for interrupt.
  // struct taskstate ts;
  // Depth of pushcli nesting.
  int ncli;
  // Were interrupts enabled before pushcli?
  // calculated by eflatgs & FL_IF. E.g., pushcli().
  int intena;
};

// Defined in mp.c
extern struct cpu cpus[NCPU];
extern int ncpu;

// TODO(lizhi): make sure understand this.
//
// Per-CPU variables, holding pointers to the
// current cpu and to the current process.
// The asm suffix tells gcc to use "%gs:0" to refer to cpu
// and "%gs:4" to refer to proc.  seginit sets up the
// %gs segment register so that %gs refers to the memory
// holding those two variables in the local cpu's struct cpu.
// This is similar to how thread-local variables are implemented
// in thread libraries such as Linux pthreads.
extern struct cpu *cpu asm("%gs:0");       // &cpus[cpunum()]
extern struct proc *proc asm("%gs:4");     // cpus[cpunum()].proc
 
enum procstate {
  UNUSED,
  EMBRYO,
  SLEEPING,
  RUNNABLE,
  RUNNING,
  ZOMBIE
};

// per-process state
struct proc {
  enum procstate state;
  // Process ID
  int pid;
  // if non-zero, sleeping on chan
  void* chan;
  // if non-zero, have been killed.
  int killed;
  // current directory
  struct inode *cwd;
  // Process name (debugging)
  char name[16];
};
