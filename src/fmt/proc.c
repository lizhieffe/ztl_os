2450 #include "types.h"
2451 #include "defs.h"
2452 #include "param.h"
2453 #include "memlayout.h"
2454 #include "mmu.h"
2455 #include "x86.h"
2456 #include "proc.h"
2457 #include "spinlock.h"
2458 
2459 struct {
2460   struct spinlock lock;
2461   struct proc proc[NPROC];
2462 } ptable;
2463 
2464 static struct proc *initproc;
2465 
2466 int nextpid = 1;
2467 extern void forkret(void);
2468 extern void trapret(void);
2469 
2470 static void wakeup1(void *chan);
2471 
2472 void
2473 pinit(void)
2474 {
2475   initlock(&ptable.lock, "ptable");
2476 }
2477 
2478 
2479 
2480 
2481 
2482 
2483 
2484 
2485 
2486 
2487 
2488 
2489 
2490 
2491 
2492 
2493 
2494 
2495 
2496 
2497 
2498 
2499 
2500 // Look in the process table for an UNUSED proc.
2501 // If found, change state to EMBRYO and initialize
2502 // state required to run in the kernel.
2503 // Otherwise return 0.
2504 static struct proc*
2505 allocproc(void)
2506 {
2507   struct proc *p;
2508   char *sp;
2509 
2510   acquire(&ptable.lock);
2511 
2512   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
2513     if(p->state == UNUSED)
2514       goto found;
2515 
2516   release(&ptable.lock);
2517   return 0;
2518 
2519 found:
2520   p->state = EMBRYO;
2521   p->pid = nextpid++;
2522 
2523   release(&ptable.lock);
2524 
2525   // Allocate kernel stack.
2526   if((p->kstack = kalloc()) == 0){
2527     p->state = UNUSED;
2528     return 0;
2529   }
2530   sp = p->kstack + KSTACKSIZE;
2531 
2532   // Leave room for trap frame.
2533   sp -= sizeof *p->tf;
2534   p->tf = (struct trapframe*)sp;
2535 
2536   // Set up new context to start executing at forkret,
2537   // which returns to trapret.
2538   sp -= 4;
2539   *(uint*)sp = (uint)trapret;
2540 
2541   sp -= sizeof *p->context;
2542   p->context = (struct context*)sp;
2543   memset(p->context, 0, sizeof *p->context);
2544   p->context->eip = (uint)forkret;
2545 
2546   return p;
2547 }
2548 
2549 
2550 // Set up first user process.
2551 void
2552 userinit(void)
2553 {
2554   struct proc *p;
2555   extern char _binary_initcode_start[], _binary_initcode_size[];
2556 
2557   p = allocproc();
2558 
2559   initproc = p;
2560   if((p->pgdir = setupkvm()) == 0)
2561     panic("userinit: out of memory?");
2562   inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
2563   p->sz = PGSIZE;
2564   memset(p->tf, 0, sizeof(*p->tf));
2565   p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
2566   p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
2567   p->tf->es = p->tf->ds;
2568   p->tf->ss = p->tf->ds;
2569   p->tf->eflags = FL_IF;
2570   p->tf->esp = PGSIZE;
2571   p->tf->eip = 0;  // beginning of initcode.S
2572 
2573   safestrcpy(p->name, "initcode", sizeof(p->name));
2574   p->cwd = namei("/");
2575 
2576   // this assignment to p->state lets other cores
2577   // run this process. the acquire forces the above
2578   // writes to be visible, and the lock is also needed
2579   // because the assignment might not be atomic.
2580   acquire(&ptable.lock);
2581 
2582   p->state = RUNNABLE;
2583 
2584   release(&ptable.lock);
2585 }
2586 
2587 
2588 
2589 
2590 
2591 
2592 
2593 
2594 
2595 
2596 
2597 
2598 
2599 
2600 // Grow current process's memory by n bytes.
2601 // Return 0 on success, -1 on failure.
2602 int
2603 growproc(int n)
2604 {
2605   uint sz;
2606 
2607   sz = proc->sz;
2608   if(n > 0){
2609     if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
2610       return -1;
2611   } else if(n < 0){
2612     if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
2613       return -1;
2614   }
2615   proc->sz = sz;
2616   switchuvm(proc);
2617   return 0;
2618 }
2619 
2620 // Create a new process copying p as the parent.
2621 // Sets up stack to return as if from system call.
2622 // Caller must set state of returned proc to RUNNABLE.
2623 int
2624 fork(void)
2625 {
2626   int i, pid;
2627   struct proc *np;
2628 
2629   // Allocate process.
2630   if((np = allocproc()) == 0){
2631     return -1;
2632   }
2633 
2634   // Copy process state from p.
2635   if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
2636     kfree(np->kstack);
2637     np->kstack = 0;
2638     np->state = UNUSED;
2639     return -1;
2640   }
2641   np->sz = proc->sz;
2642   np->parent = proc;
2643   *np->tf = *proc->tf;
2644 
2645   // Clear %eax so that fork returns 0 in the child.
2646   np->tf->eax = 0;
2647 
2648 
2649 
2650   for(i = 0; i < NOFILE; i++)
2651     if(proc->ofile[i])
2652       np->ofile[i] = filedup(proc->ofile[i]);
2653   np->cwd = idup(proc->cwd);
2654 
2655   safestrcpy(np->name, proc->name, sizeof(proc->name));
2656 
2657   pid = np->pid;
2658 
2659   acquire(&ptable.lock);
2660 
2661   np->state = RUNNABLE;
2662 
2663   release(&ptable.lock);
2664 
2665   return pid;
2666 }
2667 
2668 // Exit the current process.  Does not return.
2669 // An exited process remains in the zombie state
2670 // until its parent calls wait() to find out it exited.
2671 void
2672 exit(void)
2673 {
2674   struct proc *p;
2675   int fd;
2676 
2677   if(proc == initproc)
2678     panic("init exiting");
2679 
2680   // Close all open files.
2681   for(fd = 0; fd < NOFILE; fd++){
2682     if(proc->ofile[fd]){
2683       fileclose(proc->ofile[fd]);
2684       proc->ofile[fd] = 0;
2685     }
2686   }
2687 
2688   begin_op();
2689   iput(proc->cwd);
2690   end_op();
2691   proc->cwd = 0;
2692 
2693   acquire(&ptable.lock);
2694 
2695   // Parent might be sleeping in wait().
2696   wakeup1(proc->parent);
2697 
2698 
2699 
2700   // Pass abandoned children to init.
2701   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2702     if(p->parent == proc){
2703       p->parent = initproc;
2704       if(p->state == ZOMBIE)
2705         wakeup1(initproc);
2706     }
2707   }
2708 
2709   // Jump into the scheduler, never to return.
2710   proc->state = ZOMBIE;
2711   sched();
2712   panic("zombie exit");
2713 }
2714 
2715 // Wait for a child process to exit and return its pid.
2716 // Return -1 if this process has no children.
2717 int
2718 wait(void)
2719 {
2720   struct proc *p;
2721   int havekids, pid;
2722 
2723   acquire(&ptable.lock);
2724   for(;;){
2725     // Scan through table looking for exited children.
2726     havekids = 0;
2727     for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2728       if(p->parent != proc)
2729         continue;
2730       havekids = 1;
2731       if(p->state == ZOMBIE){
2732         // Found one.
2733         pid = p->pid;
2734         kfree(p->kstack);
2735         p->kstack = 0;
2736         freevm(p->pgdir);
2737         p->pid = 0;
2738         p->parent = 0;
2739         p->name[0] = 0;
2740         p->killed = 0;
2741         p->state = UNUSED;
2742         release(&ptable.lock);
2743         return pid;
2744       }
2745     }
2746 
2747 
2748 
2749 
2750     // No point waiting if we don't have any children.
2751     if(!havekids || proc->killed){
2752       release(&ptable.lock);
2753       return -1;
2754     }
2755 
2756     // Wait for children to exit.  (See wakeup1 call in proc_exit.)
2757     sleep(proc, &ptable.lock);  //DOC: wait-sleep
2758   }
2759 }
2760 
2761 
2762 
2763 
2764 
2765 
2766 
2767 
2768 
2769 
2770 
2771 
2772 
2773 
2774 
2775 
2776 
2777 
2778 
2779 
2780 
2781 
2782 
2783 
2784 
2785 
2786 
2787 
2788 
2789 
2790 
2791 
2792 
2793 
2794 
2795 
2796 
2797 
2798 
2799 
2800 // Per-CPU process scheduler.
2801 // Each CPU calls scheduler() after setting itself up.
2802 // Scheduler never returns.  It loops, doing:
2803 //  - choose a process to run
2804 //  - swtch to start running that process
2805 //  - eventually that process transfers control
2806 //      via swtch back to the scheduler.
2807 void
2808 scheduler(void)
2809 {
2810   struct proc *p;
2811 
2812   for(;;){
2813     // Enable interrupts on this processor.
2814     sti();
2815 
2816     // Loop over process table looking for process to run.
2817     acquire(&ptable.lock);
2818     for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2819       if(p->state != RUNNABLE)
2820         continue;
2821 
2822       // Switch to chosen process.  It is the process's job
2823       // to release ptable.lock and then reacquire it
2824       // before jumping back to us.
2825       proc = p;
2826       switchuvm(p);
2827       p->state = RUNNING;
2828       swtch(&cpu->scheduler, p->context);
2829       switchkvm();
2830 
2831       // Process is done running for now.
2832       // It should have changed its p->state before coming back.
2833       proc = 0;
2834     }
2835     release(&ptable.lock);
2836 
2837   }
2838 }
2839 
2840 
2841 
2842 
2843 
2844 
2845 
2846 
2847 
2848 
2849 
2850 // Enter scheduler.  Must hold only ptable.lock
2851 // and have changed proc->state. Saves and restores
2852 // intena because intena is a property of this
2853 // kernel thread, not this CPU. It should
2854 // be proc->intena and proc->ncli, but that would
2855 // break in the few places where a lock is held but
2856 // there's no process.
2857 void
2858 sched(void)
2859 {
2860   int intena;
2861 
2862   if(!holding(&ptable.lock))
2863     panic("sched ptable.lock");
2864   if(cpu->ncli != 1)
2865     panic("sched locks");
2866   if(proc->state == RUNNING)
2867     panic("sched running");
2868   if(readeflags()&FL_IF)
2869     panic("sched interruptible");
2870   intena = cpu->intena;
2871   swtch(&proc->context, cpu->scheduler);
2872   cpu->intena = intena;
2873 }
2874 
2875 // Give up the CPU for one scheduling round.
2876 void
2877 yield(void)
2878 {
2879   acquire(&ptable.lock);  //DOC: yieldlock
2880   proc->state = RUNNABLE;
2881   sched();
2882   release(&ptable.lock);
2883 }
2884 
2885 // A fork child's very first scheduling by scheduler()
2886 // will swtch here.  "Return" to user space.
2887 void
2888 forkret(void)
2889 {
2890   static int first = 1;
2891   // Still holding ptable.lock from scheduler.
2892   release(&ptable.lock);
2893 
2894   if (first) {
2895     // Some initialization functions must be run in the context
2896     // of a regular process (e.g., they call sleep), and thus cannot
2897     // be run from main().
2898     first = 0;
2899     iinit(ROOTDEV);
2900     initlog(ROOTDEV);
2901   }
2902 
2903   // Return to "caller", actually trapret (see allocproc).
2904 }
2905 
2906 // Atomically release lock and sleep on chan.
2907 // Reacquires lock when awakened.
2908 void
2909 sleep(void *chan, struct spinlock *lk)
2910 {
2911   if(proc == 0)
2912     panic("sleep");
2913 
2914   if(lk == 0)
2915     panic("sleep without lk");
2916 
2917   // Must acquire ptable.lock in order to
2918   // change p->state and then call sched.
2919   // Once we hold ptable.lock, we can be
2920   // guaranteed that we won't miss any wakeup
2921   // (wakeup runs with ptable.lock locked),
2922   // so it's okay to release lk.
2923   if(lk != &ptable.lock){  //DOC: sleeplock0
2924     acquire(&ptable.lock);  //DOC: sleeplock1
2925     release(lk);
2926   }
2927 
2928   // Go to sleep.
2929   proc->chan = chan;
2930   proc->state = SLEEPING;
2931   sched();
2932 
2933   // Tidy up.
2934   proc->chan = 0;
2935 
2936   // Reacquire original lock.
2937   if(lk != &ptable.lock){  //DOC: sleeplock2
2938     release(&ptable.lock);
2939     acquire(lk);
2940   }
2941 }
2942 
2943 
2944 
2945 
2946 
2947 
2948 
2949 
2950 // Wake up all processes sleeping on chan.
2951 // The ptable lock must be held.
2952 static void
2953 wakeup1(void *chan)
2954 {
2955   struct proc *p;
2956 
2957   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
2958     if(p->state == SLEEPING && p->chan == chan)
2959       p->state = RUNNABLE;
2960 }
2961 
2962 // Wake up all processes sleeping on chan.
2963 void
2964 wakeup(void *chan)
2965 {
2966   acquire(&ptable.lock);
2967   wakeup1(chan);
2968   release(&ptable.lock);
2969 }
2970 
2971 // Kill the process with the given pid.
2972 // Process won't exit until it returns
2973 // to user space (see trap in trap.c).
2974 int
2975 kill(int pid)
2976 {
2977   struct proc *p;
2978 
2979   acquire(&ptable.lock);
2980   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
2981     if(p->pid == pid){
2982       p->killed = 1;
2983       // Wake process from sleep if necessary.
2984       if(p->state == SLEEPING)
2985         p->state = RUNNABLE;
2986       release(&ptable.lock);
2987       return 0;
2988     }
2989   }
2990   release(&ptable.lock);
2991   return -1;
2992 }
2993 
2994 
2995 
2996 
2997 
2998 
2999 
3000 // Print a process listing to console.  For debugging.
3001 // Runs when user types ^P on console.
3002 // No lock to avoid wedging a stuck machine further.
3003 void
3004 procdump(void)
3005 {
3006   static char *states[] = {
3007   [UNUSED]    "unused",
3008   [EMBRYO]    "embryo",
3009   [SLEEPING]  "sleep ",
3010   [RUNNABLE]  "runble",
3011   [RUNNING]   "run   ",
3012   [ZOMBIE]    "zombie"
3013   };
3014   int i;
3015   struct proc *p;
3016   char *state;
3017   uint pc[10];
3018 
3019   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
3020     if(p->state == UNUSED)
3021       continue;
3022     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
3023       state = states[p->state];
3024     else
3025       state = "???";
3026     cprintf("%d %s %s", p->pid, state, p->name);
3027     if(p->state == SLEEPING){
3028       getcallerpcs((uint*)p->context->ebp+2, pc);
3029       for(i=0; i<10 && pc[i] != 0; i++)
3030         cprintf(" %p", pc[i]);
3031     }
3032     cprintf("\n");
3033   }
3034 }
3035 
3036 
3037 
3038 
3039 
3040 
3041 
3042 
3043 
3044 
3045 
3046 
3047 
3048 
3049 
