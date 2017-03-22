3350 #include "mmu.h"
3351 
3352   # vectors.S sends all traps here.
3353 .globl alltraps
3354 alltraps:
3355   # Build trap frame.
3356   pushl %ds
3357   pushl %es
3358   pushl %fs
3359   pushl %gs
3360   pushal
3361 
3362   # Set up data and per-cpu segments.
3363   movw $(SEG_KDATA<<3), %ax
3364   movw %ax, %ds
3365   movw %ax, %es
3366   movw $(SEG_KCPU<<3), %ax
3367   movw %ax, %fs
3368   movw %ax, %gs
3369 
3370   # Call trap(tf), where tf=%esp
3371   pushl %esp
3372   call trap
3373   addl $4, %esp
3374 
3375   # Return falls through to trapret...
3376 .globl trapret
3377 trapret:
3378   popal
3379   popl %gs
3380   popl %fs
3381   popl %es
3382   popl %ds
3383   addl $0x8, %esp  # trapno and errcode
3384   iret
3385 
3386 
3387 
3388 
3389 
3390 
3391 
3392 
3393 
3394 
3395 
3396 
3397 
3398 
3399 
