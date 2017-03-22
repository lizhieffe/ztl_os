8950 #include "syscall.h"
8951 #include "traps.h"
8952 
8953 // For assembly language file with extension .S, gcc will use a C preprocessor.
8954 // In C, \ at the end of line means that "connect the next line to this line".
8955 // For that reason, the macro becomes
8956 //  #define SYSCALL(name)
8957 //  .globl name;
8958 //  name: movl $SYS_ ## name, %eax;
8959 //  int $T_SYSCALL;
8960 //  ret
8961 // ## operator will concatenate the tokens in its left and right.
8962 //
8963 // Therefore, for example, SYSCALL(fork) will be expanded to
8964 // .globl fork; fork: movl $SYS_fork, %eax; int $T_SYSCALL; ret
8965 // This means:
8966 // 1 make the identifire fork public
8967 // 2 define a label fork (this will work as a function)
8968 // 3 in this function
8969 //  1) assign an immediate value SYS_fork to register %eax
8970 //  2) generate an interrupt with code T_SYSCALL
8971 //  3) return from this function
8972 
8973 #define SYSCALL(name) \
8974   .globl name; \
8975   name: \
8976     movl $SYS_ ## name, %eax; \
8977     int $T_SYSCALL; \
8978     ret
8979 
8980 SYSCALL(fork)
8981 SYSCALL(exit)
8982 SYSCALL(wait)
8983 SYSCALL(pipe)
8984 SYSCALL(read)
8985 SYSCALL(write)
8986 SYSCALL(close)
8987 SYSCALL(kill)
8988 SYSCALL(exec)
8989 SYSCALL(open)
8990 SYSCALL(mknod)
8991 SYSCALL(unlink)
8992 SYSCALL(fstat)
8993 SYSCALL(link)
8994 SYSCALL(mkdir)
8995 SYSCALL(chdir)
8996 SYSCALL(dup)
8997 SYSCALL(getpid)
8998 SYSCALL(sbrk)
8999 SYSCALL(sleep)
9000 SYSCALL(uptime)
9001 SYSCALL(date)
9002 
9003 
9004 
9005 
9006 
9007 
9008 
9009 
9010 
9011 
9012 
9013 
9014 
9015 
9016 
9017 
9018 
9019 
9020 
9021 
9022 
9023 
9024 
9025 
9026 
9027 
9028 
9029 
9030 
9031 
9032 
9033 
9034 
9035 
9036 
9037 
9038 
9039 
9040 
9041 
9042 
9043 
9044 
9045 
9046 
9047 
9048 
9049 
