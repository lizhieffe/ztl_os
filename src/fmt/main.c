1300 #include "types.h"
1301 #include "defs.h"
1302 #include "param.h"
1303 #include "memlayout.h"
1304 #include "mmu.h"
1305 #include "proc.h"
1306 #include "x86.h"
1307 
1308 static void startothers(void);
1309 static void mpmain(void)  __attribute__((noreturn));
1310 extern pde_t *kpgdir;
1311 extern char end[]; // first address after kernel loaded from ELF file
1312 
1313 // Bootstrap processor starts running C code here.
1314 // Allocate a real stack and switch to it, first
1315 // doing some setup required for memory allocator to work.
1316 int
1317 main(void)
1318 {
1319   // Cleans up the memory in the given range and adds them in the memory
1320   // allocator's free list.
1321   kinit1(end, P2V(4*1024*1024)); // phys page allocator
1322 
1323   // Allocate one page table for the machine for the kernel address space for
1324   // scheduler processes. Adds the kernel memory space mapping into the table
1325   // table.
1326   kvmalloc();      // kernel page table
1327 
1328   mpinit();        // detect other processors
1329   lapicinit();     // interrupt controller
1330   seginit();       // segment descriptors
1331   cprintf("\ncpu%d: starting xv6\n\n", cpunum());
1332   picinit();       // another interrupt controller
1333   ioapicinit();    // another interrupt controller
1334   consoleinit();   // console hardware
1335   uartinit();      // serial port
1336   pinit();         // process table
1337 
1338   // Sets up the IDT. Note here it doesn't load the IDT table to the processor.
1339   // It is done in idtinit().
1340   tvinit();        // trap vectors
1341 
1342   binit();         // buffer cache
1343   fileinit();      // file table
1344   ideinit();       // disk
1345   if(!ismp)
1346     timerinit();   // uniprocessor timer
1347   startothers();   // start other processors
1348   kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
1349   userinit();      // first user process
1350   mpmain();        // finish this processor's setup
1351 }
1352 
1353 // Other CPUs jump here from entryother.S.
1354 static void
1355 mpenter(void)
1356 {
1357   switchkvm();
1358   seginit();
1359   lapicinit();
1360   mpmain();
1361 }
1362 
1363 // Common CPU setup code.
1364 static void
1365 mpmain(void)
1366 {
1367   cprintf("cpu%d: starting\n", cpunum());
1368   idtinit();       // load idt register
1369   xchg(&cpu->started, 1); // tell startothers() we're up
1370   scheduler();     // start running processes
1371 }
1372 
1373 pde_t entrypgdir[];  // For entry.S
1374 
1375 // Start the non-boot (AP) processors.
1376 static void
1377 startothers(void)
1378 {
1379   extern uchar _binary_entryother_start[], _binary_entryother_size[];
1380   uchar *code;
1381   struct cpu *c;
1382   char *stack;
1383 
1384   // Write entry code to unused memory at 0x7000.
1385   // The linker has placed the image of entryother.S in
1386   // _binary_entryother_start.
1387   code = P2V(0x7000);
1388   memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
1389 
1390   for(c = cpus; c < cpus+ncpu; c++){
1391     if(c == cpus+cpunum())  // We've started already.
1392       continue;
1393 
1394     // Tell entryother.S what stack to use, where to enter, and what
1395     // pgdir to use. We cannot use kpgdir yet, because the AP processor
1396     // is running in low  memory, so we use entrypgdir for the APs too.
1397     stack = kalloc();
1398     *(void**)(code-4) = stack + KSTACKSIZE;
1399     *(void**)(code-8) = mpenter;
1400     *(int**)(code-12) = (void *) V2P(entrypgdir);
1401 
1402     lapicstartap(c->apicid, V2P(code));
1403 
1404     // wait for cpu to finish mpmain()
1405     while(c->started == 0)
1406       ;
1407   }
1408 }
1409 
1410 // The boot page table used in entry.S and entryother.S.
1411 // Page directories (and page tables) must start on page boundaries,
1412 // hence the __aligned__ attribute.
1413 // PTE_PS in a page directory entry enables 4Mbyte pages.
1414 
1415 __attribute__((__aligned__(PGSIZE)))
1416 pde_t entrypgdir[NPDENTRIES] = {
1417   // Map VA's [0, 4MB) to PA's [0, 4MB)
1418   [0] = (0) | PTE_P | PTE_W | PTE_PS,
1419   // Map VA's [KERNBASE, KERNBASE+4MB) to PA's [0, 4MB)
1420   [KERNBASE>>PDXSHIFT] = (0) | PTE_P | PTE_W | PTE_PS,
1421 };
1422 
1423 
1424 
1425 
1426 
1427 
1428 
1429 
1430 
1431 
1432 
1433 
1434 
1435 
1436 
1437 
1438 
1439 
1440 
1441 
1442 
1443 
1444 
1445 
1446 
1447 
1448 
1449 
1450 // Blank page.
1451 
1452 
1453 
1454 
1455 
1456 
1457 
1458 
1459 
1460 
1461 
1462 
1463 
1464 
1465 
1466 
1467 
1468 
1469 
1470 
1471 
1472 
1473 
1474 
1475 
1476 
1477 
1478 
1479 
1480 
1481 
1482 
1483 
1484 
1485 
1486 
1487 
1488 
1489 
1490 
1491 
1492 
1493 
1494 
1495 
1496 
1497 
1498 
1499 
