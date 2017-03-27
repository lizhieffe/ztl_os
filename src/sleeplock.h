// Long-term lock for processes

#include "spinlock.h"
#include "types.h"

struct sleeplock {
  uint locked;

  // spinlock protecting this sleep lock
  struct spinlock lock;
  
  // for debugging
  char* name;
  int pid;
};
