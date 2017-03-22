#include "syscall.h"
#include "traps.h"

// For assembly language file with extension .S, gcc will use a C preprocessor.
// In C, \ at the end of line means that "connect the next line to this line".
// For that reason, the macro becomes
//  #define SYSCALL(name)
//  .globl name;
//  name: movl $SYS_ ## name, %eax;
//  int $T_SYSCALL;
//  ret
// ## operator will concatenate the tokens in its left and right.
//
// Therefore, for example, SYSCALL(fork) will be expanded to
// .globl fork; fork: movl $SYS_fork, %eax; int $T_SYSCALL; ret
// This means:
// 1 make the identifire fork public
// 2 define a label fork (this will work as a function)
// 3 in this function
//  1) assign an immediate value SYS_fork to register %eax
//  2) generate an interrupt with code T_SYSCALL
//  3) return from this function

#define SYSCALL(name) \
  .globl name; \
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
SYSCALL(exit)
SYSCALL(wait)
SYSCALL(pipe)
SYSCALL(read)
SYSCALL(write)
SYSCALL(close)
SYSCALL(kill)
SYSCALL(exec)
SYSCALL(open)
SYSCALL(mknod)
SYSCALL(unlink)
SYSCALL(fstat)
SYSCALL(link)
SYSCALL(mkdir)
SYSCALL(chdir)
SYSCALL(dup)
SYSCALL(getpid)
SYSCALL(sbrk)
SYSCALL(sleep)
SYSCALL(uptime)
SYSCALL(date)
