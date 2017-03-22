3100 // Physical memory allocator, intended to allocate
3101 // memory for user processes, kernel stacks, page table pages,
3102 // and pipe buffers. Allocates 4096-byte pages.
3103 
3104 #include "types.h"
3105 #include "defs.h"
3106 #include "param.h"
3107 #include "memlayout.h"
3108 #include "mmu.h"
3109 #include "spinlock.h"
3110 
3111 void freerange(void *vstart, void *vend);
3112 extern char end[]; // first address after kernel loaded from ELF file
3113 
3114 // The kernel's physical memory allocator uses a *free list* of physical memory
3115 // pages that are available for allocation. Each free page's list element is a
3116 // `struct run`. The `run` structure is saved in the corresponding free page
3117 // itself since there is nothing else stored there.
3118 struct run {
3119   struct run *next;
3120 };
3121 
3122 struct {
3123   struct spinlock lock;
3124   int use_lock;
3125   struct run *freelist;
3126 } kmem;
3127 
3128 // Cleans up the memory in the given range and adds them in the memory
3129 // allocator's free list.
3130 //
3131 // Initialization happens in two phases.
3132 // 1. main() calls kinit1() while still using entrypgdir to place just
3133 // the pages mapped by entrypgdir on free list.
3134 // 2. main() calls kinit2() with the rest of the physical pages
3135 // after installing a full page table that maps them on all cores.
3136 void
3137 kinit1(void *vstart, void *vend)
3138 {
3139   initlock(&kmem.lock, "kmem");
3140   kmem.use_lock = 0;
3141   freerange(vstart, vend);
3142 }
3143 
3144 void
3145 kinit2(void *vstart, void *vend)
3146 {
3147   freerange(vstart, vend);
3148   kmem.use_lock = 1;
3149 }
3150 void
3151 freerange(void *vstart, void *vend)
3152 {
3153   char *p;
3154   p = (char*)PGROUNDUP((uint)vstart);
3155   for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
3156     kfree(p);
3157 }
3158 
3159 
3160 // Free the page of physical memory pointed at by v,
3161 // which normally should have been returned by a
3162 // call to kalloc().  (The exception is when
3163 // initializing the allocator; see kinit above.)
3164 void
3165 kfree(char *v)
3166 {
3167   struct run *r;
3168 
3169   if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
3170     panic("kfree");
3171 
3172   // Fill with junk to catch dangling refs.
3173   memset(v, 1, PGSIZE);
3174 
3175   if(kmem.use_lock)
3176     acquire(&kmem.lock);
3177   r = (struct run*)v;
3178   r->next = kmem.freelist;
3179   kmem.freelist = r;
3180   if(kmem.use_lock)
3181     release(&kmem.lock);
3182 }
3183 
3184 // Allocate one 4096-byte page of physical memory. (by checking the kernel
3185 // memory allocator's "free list".
3186 // Returns a pointer that the kernel can use.
3187 // Returns 0 if the memory cannot be allocated.
3188 char*
3189 kalloc(void)
3190 {
3191   struct run *r;
3192 
3193   if(kmem.use_lock)
3194     acquire(&kmem.lock);
3195   r = kmem.freelist;
3196   if(r)
3197     kmem.freelist = r->next;
3198   if(kmem.use_lock)
3199     release(&kmem.lock);
3200   return (char*)r;
3201 }
3202 
3203 
3204 
3205 
3206 
3207 
3208 
3209 
3210 
3211 
3212 
3213 
3214 
3215 
3216 
3217 
3218 
3219 
3220 
3221 
3222 
3223 
3224 
3225 
3226 
3227 
3228 
3229 
3230 
3231 
3232 
3233 
3234 
3235 
3236 
3237 
3238 
3239 
3240 
3241 
3242 
3243 
3244 
3245 
3246 
3247 
3248 
3249 
