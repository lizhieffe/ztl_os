#include "defs.h"
#include "memlayout.h"
#include "mmu.h"
#include "types.h"

// TODO(lizhi): how??
extern char data[];  // defined by kernel.ld
pde_t* kpgdir;  // for use in scheduler()

// Return the address of the PTE in page table pgdir that corresponds to
// virtual address va. If alloc != 0, create any required page table pages.
static pte_t* walkpgdir(pde_t* pgdir, const void* va, int alloc) {
  pde_t* pde = &pgdir[PDX(va)];
  pte_t* pgtab;

  if (*pde & PTE_P) {
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if (!alloc || (pgtab = (pte_t*)kalloc()) == 0) {
      return 0;
    }
    memset(pgtab, 0, PGSIZE);
    // The permissions here are overly generous, but they can be further
    // restricted by the permissions in the page table entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
}

// Create PTEs for virtual addresses starting at |va| that refer to physical
// addresses starting at |pa|. |va| and |size| might not be page-aligned. Return
// 0 when succeeds, otherwise return -1;
static int mappages(pde_t* pgdir, void* va, uint size, uint pa, int perm) {
  pte_t* pte;

  char* a = (char*)PGROUNDDOWN((uint)va);
  char* last = (char*)PGROUNDDOWN((uint)pa + size - 1);
  for (;;) {
    if ((pte = walkpgdir(pgdir, a, 1)) == 0) {
      return -1;
    }
    if (*pte & PTE_P) {
      panic("remap");
    }
    *pte = pa | perm | PTE_P;
    if (a == last) {
      break;
    }
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}

// There is one page table per process, plus one that's used when
// a CPU is not running any process (kpgdir). The kernel uses the
// current process's page table during system calls and interrupts;
// page protection bits prevent user code from using the kernel's
// mappings.
//
// setupkvm() and exec() set up every page table like this:
//
//   0..KERNBASE: user memory (text+data+stack+heap), mapped to
//                phys memory allocated by the kernel
//   KERNBASE..KERNBASE+EXTMEM: mapped to 0..EXTMEM (for I/O space)
//   KERNBASE+EXTMEM..data: mapped to EXTMEM..V2P(data)
//                for the kernel's instructions and r/o data
//   data..KERNBASE+PHYSTOP: mapped to V2P(data)..PHYSTOP,
//                                  rw data + free physical memory
//   0xfe000000..0: mapped direct (devices such as ioapic)
//
// The kernel allocates physical memory for its heap and for user memory
// between V2P(end) and the end of physical memory (PHYSTOP)
// (directly addressable from end..P2V(PHYSTOP)).

// This table defins the kernel's mapping, which are present in every process'
// page table.
static struct kmap {
  void* virt;
  uint phys_start;
  uint phys_end;
  int perm;
} kmap[] = {
  { (void*)KERNBASE, 0,             EXTMEM,    PTE_W}, // I/O space
  { (void*)KERNLINK, V2P(KERNLINK), V2P(data), 0},     // kern text+rodata
  { (void*)data,     V2P(data),     PHYSTOP,   PTE_W}, // kern data+memory
  { (void*)DEVSPACE, DEVSPACE,      0,         PTE_W}, // more devices
};

// Set up kernel part of virtual memory (a page table). Return 0 when fails.
// Return the address of the created page directory.
pde_t* setupkvm(void) {
  pde_t* pgdir;
  struct kmap* k;
  
  // allocate one 4096-byte page from the kmem freelist.
  if ((pgdir = (pde_t*)kalloc()) == 0) {
    return 0;
  }
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE) {
    panic("PHYSTOP too high");
  }
  for (k = kmap; k < &kmap[NELEM(kmap)]; k++) {
    if (mappages(pgdir, k->virt, k->phys_end - k->phys_start, k->phys_start,
                 k->perm) < 0) {
      return 0;
    }
  }
  return pgdir;
}

// Allocate one page table for the machine for the kernel address space for
// scheduler processes.
void kvmalloc(void) {
  kpgdir = setupkvm();
}

//PAGEBREAK!
// Blank page.
//PAGEBREAK!
// Blank page.
//PAGEBREAK!
// Blank page.

