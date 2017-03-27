#include "param.h"
#include "proc.h"

// Declared in proc.h
struct cpu cpus[NCPU];
int ncpu;

int ismp;
uchar ioapicid;
