// Sleeping locks

#include "defs.h"
#include "proc.h"
#include "sleeplock.h"

void initsleeplock(struct sleeplock* lock, char* name) {
  initlock(&lock->lock, name);
  lock->name = name;
  lock->locked = 0;
  lock->pid = 0;
}

void acquiresleep(struct sleeplock* lock) {
  acquire(&lock->lock);
  while (lock->locked) {
    sleep(lock, &lock->lock);
  }
  lock->locked = 1;
  lock->pid = proc->pid;
  release(&lock->lock);
}

void releasesleep(struct sleeplock* lock) {
  acquire(&lock->lock);
  lock->locked = 0;
  lock->pid = 0;
  wakeup(lock);
  release(&lock->lock);
}

// Return 0 when the |lock| is not hold by any process. Otherwise return 1.
int holdingsleep(struct sleeplock* lock) {
  int r;
  acquire(&lock->lock);
  r = lock->locked;
  release(&lock->lock);
  return r;
}
