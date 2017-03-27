#ifndef ZTL_OS_SPINLOCK
#define ZTL_OS_SPINLOCK

// Mutual exclusion lock.
struct spinlock {
  uint locked;

  // For debugging:
  char* name;       // name of lock
  struct cpu* cpu;  // The cpu holding the lock.
  uint pcs[10];     // The call stack (an array of program counters) that locked
                    // the lock.
};

#endif  // ZTL_OS_SPINLOCK
