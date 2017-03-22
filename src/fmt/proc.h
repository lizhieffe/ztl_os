2350 // Per-CPU state
2351 struct cpu {
2352   uchar apicid;                // Local APIC ID
2353   struct context *scheduler;   // swtch() here to enter scheduler
2354   struct taskstate ts;         // Used by x86 to find stack for interrupt
2355   struct segdesc gdt[NSEGS];   // x86 global descriptor table
2356   volatile uint started;       // Has the CPU started?
2357   int ncli;                    // Depth of pushcli nesting.
2358   int intena;                  // Were interrupts enabled before pushcli?
2359 
2360   // Cpu-local storage variables; see below
2361   struct cpu *cpu;
2362   struct proc *proc;           // The currently-running process.
2363 };
2364 
2365 extern struct cpu cpus[NCPU];
2366 extern int ncpu;
2367 
2368 // Per-CPU variables, holding pointers to the
2369 // current cpu and to the current process.
2370 // The asm suffix tells gcc to use "%gs:0" to refer to cpu
2371 // and "%gs:4" to refer to proc.  seginit sets up the
2372 // %gs segment register so that %gs refers to the memory
2373 // holding those two variables in the local cpu's struct cpu.
2374 // This is similar to how thread-local variables are implemented
2375 // in thread libraries such as Linux pthreads.
2376 extern struct cpu *cpu asm("%gs:0");       // &cpus[cpunum()]
2377 extern struct proc *proc asm("%gs:4");     // cpus[cpunum()].proc
2378 
2379 
2380 // Saved registers for kernel context switches.
2381 // Don't need to save all the segment registers (%cs, etc),
2382 // because they are constant across kernel contexts.
2383 // Don't need to save %eax, %ecx, %edx, because the
2384 // x86 convention is that the caller has saved them.
2385 // Contexts are stored at the bottom of the stack they
2386 // describe; the stack pointer is the address of the context.
2387 // The layout of the context matches the layout of the stack in swtch.S
2388 // at the "Switch stacks" comment. Switch doesn't save eip explicitly,
2389 // but it is on the stack and allocproc() manipulates it.
2390 struct context {
2391   uint edi;
2392   uint esi;
2393   uint ebx;
2394   uint ebp;
2395   uint eip;
2396 };
2397 
2398 
2399 
2400 enum procstate { UNUSED, EMBRYO, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };
2401 
2402 // Per-process state
2403 struct proc {
2404   uint sz;                     // Size of process memory (bytes)
2405   pde_t* pgdir;                // Page table
2406   char *kstack;                // Bottom of kernel stack for this process
2407   enum procstate state;        // Process state
2408   int pid;                     // Process ID
2409   struct proc *parent;         // Parent process
2410   struct trapframe *tf;        // Trap frame for current syscall
2411   struct context *context;     // swtch() here to run process
2412   void *chan;                  // If non-zero, sleeping on chan
2413   int killed;                  // If non-zero, have been killed
2414   struct file *ofile[NOFILE];  // Open files
2415   struct inode *cwd;           // Current directory
2416   char name[16];               // Process name (debugging)
2417 };
2418 
2419 // Process memory is laid out contiguously, low addresses first:
2420 //   text
2421 //   original data and bss
2422 //   fixed-size stack
2423 //   expandable heap
2424 
2425 
2426 
2427 
2428 
2429 
2430 
2431 
2432 
2433 
2434 
2435 
2436 
2437 
2438 
2439 
2440 
2441 
2442 
2443 
2444 
2445 
2446 
2447 
2448 
2449 
