1700 #include "param.h"
1701 #include "types.h"
1702 #include "defs.h"
1703 #include "x86.h"
1704 #include "memlayout.h"
1705 #include "mmu.h"
1706 #include "proc.h"
1707 #include "elf.h"
1708 
1709 extern char data[];  // defined by kernel.ld
1710 pde_t *kpgdir;  // for use in scheduler()
1711 
1712 // Set up CPU's kernel segment descriptors.
1713 // Run once on entry on each CPU.
1714 void
1715 seginit(void)
1716 {
1717   struct cpu *c;
1718 
1719   // Map "logical" addresses to virtual addresses using identity map.
1720   // Cannot share a CODE descriptor for both kernel and user
1721   // because it would have to have DPL_USR, but the CPU forbids
1722   // an interrupt from CPL=0 to DPL=3.
1723   c = &cpus[cpunum()];
1724   c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
1725   c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
1726   c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
1727   c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
1728 
1729   // Map cpu and proc -- these are private per cpu.
1730   c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
1731 
1732   lgdt(c->gdt, sizeof(c->gdt));
1733   loadgs(SEG_KCPU << 3);
1734 
1735   // Initialize cpu-local storage.
1736   cpu = c;
1737   proc = 0;
1738 }
1739 
1740 
1741 
1742 
1743 
1744 
1745 
1746 
1747 
1748 
1749 
1750 // Return the address of the PTE in page table pgdir
1751 // that corresponds to virtual address va.  If alloc!=0,
1752 // create any required page table pages (and maps to the physical address).
1753 static pte_t *
1754 walkpgdir(pde_t *pgdir, const void *va, int alloc)
1755 {
1756   pde_t *pde;
1757   pte_t *pgtab;
1758 
1759   pde = &pgdir[PDX(va)];
1760   if(*pde & PTE_P){
1761     pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
1762   } else {
1763     if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
1764       return 0;
1765     // Make sure all those PTE_P bits are zero.
1766     memset(pgtab, 0, PGSIZE);
1767     // The permissions here are overly generous, but they can
1768     // be further restricted by the permissions in the page table
1769     // entries, if necessary.
1770     *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
1771   }
1772   return &pgtab[PTX(va)];
1773 }
1774 
1775 // Create PTEs for virtual addresses starting at va that refer to
1776 // physical addresses starting at pa. va and size might not
1777 // be page-aligned.
1778 static int
1779 mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
1780 {
1781   char *a, *last;
1782   pte_t *pte;
1783 
1784   a = (char*)PGROUNDDOWN((uint)va);
1785   last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
1786   for(;;){
1787     // Allocs a page for the 2nd level page table (page table entry table) if it
1788     // is not alloced yet.
1789     if((pte = walkpgdir(pgdir, a, 1 /* alloc */)) == 0)
1790       return -1;
1791     if(*pte & PTE_P)
1792       panic("remap");
1793     *pte = pa | perm | PTE_P;
1794     if(a == last)
1795       break;
1796     a += PGSIZE;
1797     pa += PGSIZE;
1798   }
1799   return 0;
1800 }
1801 
1802 // There is one page table per process, plus one that's used when
1803 // a CPU is not running any process (kpgdir). The kernel uses the
1804 // current process's page table during system calls and interrupts;
1805 // page protection bits prevent user code from using the kernel's
1806 // mappings.
1807 //
1808 // setupkvm() and exec() set up every page table like this:
1809 //
1810 //   0..KERNBASE: user memory (text+data+stack+heap), mapped to
1811 //                phys memory allocated by the kernel
1812 //   KERNBASE..KERNBASE+EXTMEM: mapped to 0..EXTMEM (for I/O space)
1813 //   KERNBASE+EXTMEM..data: mapped to EXTMEM..V2P(data)
1814 //                for the kernel's instructions and r/o data
1815 //   data..KERNBASE+PHYSTOP: mapped to V2P(data)..PHYSTOP,
1816 //                                  rw data + free physical memory
1817 //   0xfe000000..0: mapped direct (devices such as ioapic)
1818 //
1819 // The kernel allocates physical memory for its heap and for user memory
1820 // between V2P(end) and the end of physical memory (PHYSTOP)
1821 // (directly addressable from end..P2V(PHYSTOP)).
1822 
1823 // This table defines the kernel's mappings, which are present in
1824 // every process's page table.
1825 static struct kmap {
1826   void *virt;
1827   uint phys_start;
1828   uint phys_end;
1829   int perm;
1830 } kmap[] = {
1831  { (void*)KERNBASE, 0,             EXTMEM,    PTE_W}, // I/O space
1832  { (void*)KERNLINK, V2P(KERNLINK), V2P(data), 0},     // kern text+rodata
1833  { (void*)data,     V2P(data),     PHYSTOP,   PTE_W}, // kern data+memory
1834  { (void*)DEVSPACE, DEVSPACE,      0,         PTE_W}, // more devices
1835 };
1836 
1837 
1838 
1839 
1840 
1841 
1842 
1843 
1844 
1845 
1846 
1847 
1848 
1849 
1850 // Set up kernel part of a page table.
1851 pde_t*
1852 setupkvm(void)
1853 {
1854   pde_t *pgdir;
1855   struct kmap *k;
1856 
1857   // Gets a free page from the kernel memory allocator's free page. Uses the
1858   // page as the first-level page table (page directory entry table).
1859   if((pgdir = (pde_t*)kalloc()) == 0)
1860     return 0;
1861   memset(pgdir, 0, PGSIZE);
1862   if (P2V(PHYSTOP) > (void*)DEVSPACE)
1863     panic("PHYSTOP too high");
1864 
1865   // Set up kernel part of a page table.
1866   for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
1867     // Creates the entries in the page table. Allocs a page for the 2nd level
1868     // page table (page table entry table) if it is not alloced yet.
1869     if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
1870                 (uint)k->phys_start, k->perm) < 0)
1871       return 0;
1872   return pgdir;
1873 }
1874 
1875 // Allocate one page table for the machine for the kernel address
1876 // space for scheduler processes.
1877 void
1878 kvmalloc(void)
1879 {
1880   kpgdir = setupkvm();
1881   switchkvm();
1882 }
1883 
1884 // Switch h/w page table register to the kernel-only page table,
1885 // for when no process is running.
1886 void
1887 switchkvm(void)
1888 {
1889   lcr3(V2P(kpgdir));   // switch to the kernel page table
1890 }
1891 
1892 
1893 
1894 
1895 
1896 
1897 
1898 
1899 
1900 // Switch TSS and h/w page table to correspond to process p.
1901 void
1902 switchuvm(struct proc *p)
1903 {
1904   if(p == 0)
1905     panic("switchuvm: no process");
1906   if(p->kstack == 0)
1907     panic("switchuvm: no kstack");
1908   if(p->pgdir == 0)
1909     panic("switchuvm: no pgdir");
1910 
1911   pushcli();
1912   cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
1913   cpu->gdt[SEG_TSS].s = 0;
1914   cpu->ts.ss0 = SEG_KDATA << 3;
1915   cpu->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
1916   // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
1917   // forbids I/O instructions (e.g., inb and outb) from user space
1918   cpu->ts.iomb = (ushort) 0xFFFF;
1919   ltr(SEG_TSS << 3);
1920   lcr3(V2P(p->pgdir));  // switch to process's address space
1921   popcli();
1922 }
1923 
1924 // Load the initcode into address 0 of pgdir.
1925 // sz must be less than a page.
1926 void
1927 inituvm(pde_t *pgdir, char *init, uint sz)
1928 {
1929   char *mem;
1930 
1931   if(sz >= PGSIZE)
1932     panic("inituvm: more than a page");
1933   mem = kalloc();
1934   memset(mem, 0, PGSIZE);
1935   mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
1936   memmove(mem, init, sz);
1937 }
1938 
1939 
1940 
1941 
1942 
1943 
1944 
1945 
1946 
1947 
1948 
1949 
1950 // Load a program segment into pgdir.  addr must be page-aligned
1951 // and the pages from addr to addr+sz must already be mapped.
1952 int
1953 loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
1954 {
1955   uint i, pa, n;
1956   pte_t *pte;
1957 
1958   if((uint) addr % PGSIZE != 0)
1959     panic("loaduvm: addr must be page aligned");
1960   for(i = 0; i < sz; i += PGSIZE){
1961     if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
1962       panic("loaduvm: address should exist");
1963     pa = PTE_ADDR(*pte);
1964     if(sz - i < PGSIZE)
1965       n = sz - i;
1966     else
1967       n = PGSIZE;
1968     if(readi(ip, P2V(pa), offset+i, n) != n)
1969       return -1;
1970   }
1971   return 0;
1972 }
1973 
1974 // Allocate page tables and physical memory to grow process from oldsz to
1975 // newsz, which need not be page aligned.  Returns new size or 0 on error.
1976 int
1977 allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
1978 {
1979   char *mem;
1980   uint a;
1981 
1982   if(newsz >= KERNBASE)
1983     return 0;
1984   if(newsz < oldsz)
1985     return oldsz;
1986 
1987   a = PGROUNDUP(oldsz);
1988   for(; a < newsz; a += PGSIZE){
1989     mem = kalloc();
1990     if(mem == 0){
1991       cprintf("allocuvm out of memory\n");
1992       deallocuvm(pgdir, newsz, oldsz);
1993       return 0;
1994     }
1995     memset(mem, 0, PGSIZE);
1996     if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
1997       cprintf("allocuvm out of memory (2)\n");
1998       deallocuvm(pgdir, newsz, oldsz);
1999       kfree(mem);
2000       return 0;
2001     }
2002   }
2003   return newsz;
2004 }
2005 
2006 // Deallocate user pages to bring the process size from oldsz to
2007 // newsz.  oldsz and newsz need not be page-aligned, nor does newsz
2008 // need to be less than oldsz.  oldsz can be larger than the actual
2009 // process size.  Returns the new process size.
2010 int
2011 deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
2012 {
2013   pte_t *pte;
2014   uint a, pa;
2015 
2016   if(newsz >= oldsz)
2017     return oldsz;
2018 
2019   a = PGROUNDUP(newsz);
2020   for(; a  < oldsz; a += PGSIZE){
2021     pte = walkpgdir(pgdir, (char*)a, 0);
2022     if(!pte)
2023       a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
2024     else if((*pte & PTE_P) != 0){
2025       pa = PTE_ADDR(*pte);
2026       if(pa == 0)
2027         panic("kfree");
2028       char *v = P2V(pa);
2029       kfree(v);
2030       *pte = 0;
2031     }
2032   }
2033   return newsz;
2034 }
2035 
2036 
2037 
2038 
2039 
2040 
2041 
2042 
2043 
2044 
2045 
2046 
2047 
2048 
2049 
2050 // Free a page table and all the physical memory pages
2051 // in the user part.
2052 void
2053 freevm(pde_t *pgdir)
2054 {
2055   uint i;
2056 
2057   if(pgdir == 0)
2058     panic("freevm: no pgdir");
2059   deallocuvm(pgdir, KERNBASE, 0);
2060   for(i = 0; i < NPDENTRIES; i++){
2061     if(pgdir[i] & PTE_P){
2062       char * v = P2V(PTE_ADDR(pgdir[i]));
2063       kfree(v);
2064     }
2065   }
2066   kfree((char*)pgdir);
2067 }
2068 
2069 // Clear PTE_U on a page. Used to create an inaccessible
2070 // page beneath the user stack.
2071 void
2072 clearpteu(pde_t *pgdir, char *uva)
2073 {
2074   pte_t *pte;
2075 
2076   pte = walkpgdir(pgdir, uva, 0);
2077   if(pte == 0)
2078     panic("clearpteu");
2079   *pte &= ~PTE_U;
2080 }
2081 
2082 // Given a parent process's page table, create a copy
2083 // of it for a child.
2084 pde_t*
2085 copyuvm(pde_t *pgdir, uint sz)
2086 {
2087   pde_t *d;
2088   pte_t *pte;
2089   uint pa, i, flags;
2090   char *mem;
2091 
2092   if((d = setupkvm()) == 0)
2093     return 0;
2094   for(i = 0; i < sz; i += PGSIZE){
2095     if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
2096       panic("copyuvm: pte should exist");
2097     if(!(*pte & PTE_P))
2098       panic("copyuvm: page not present");
2099     pa = PTE_ADDR(*pte);
2100     flags = PTE_FLAGS(*pte);
2101     if((mem = kalloc()) == 0)
2102       goto bad;
2103     memmove(mem, (char*)P2V(pa), PGSIZE);
2104     if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
2105       goto bad;
2106   }
2107   return d;
2108 
2109 bad:
2110   freevm(d);
2111   return 0;
2112 }
2113 
2114 
2115 
2116 
2117 
2118 
2119 
2120 
2121 
2122 
2123 
2124 
2125 
2126 
2127 
2128 
2129 
2130 
2131 
2132 
2133 
2134 
2135 
2136 
2137 
2138 
2139 
2140 
2141 
2142 
2143 
2144 
2145 
2146 
2147 
2148 
2149 
2150 // Map user virtual address to kernel address.
2151 char*
2152 uva2ka(pde_t *pgdir, char *uva)
2153 {
2154   pte_t *pte;
2155 
2156   pte = walkpgdir(pgdir, uva, 0);
2157   if((*pte & PTE_P) == 0)
2158     return 0;
2159   if((*pte & PTE_U) == 0)
2160     return 0;
2161   return (char*)P2V(PTE_ADDR(*pte));
2162 }
2163 
2164 // Copy len bytes from p to user address va in page table pgdir.
2165 // Most useful when pgdir is not the current page table.
2166 // uva2ka ensures this only works for PTE_U pages.
2167 int
2168 copyout(pde_t *pgdir, uint va, void *p, uint len)
2169 {
2170   char *buf, *pa0;
2171   uint n, va0;
2172 
2173   buf = (char*)p;
2174   while(len > 0){
2175     va0 = (uint)PGROUNDDOWN(va);
2176     pa0 = uva2ka(pgdir, (char*)va0);
2177     if(pa0 == 0)
2178       return -1;
2179     n = PGSIZE - (va - va0);
2180     if(n > len)
2181       n = len;
2182     memmove(pa0 + (va - va0), buf, n);
2183     len -= n;
2184     buf += n;
2185     va = va0 + PGSIZE;
2186   }
2187   return 0;
2188 }
2189 
2190 
2191 
2192 
2193 
2194 
2195 
2196 
2197 
2198 
2199 
2200 // Blank page.
2201 
2202 
2203 
2204 
2205 
2206 
2207 
2208 
2209 
2210 
2211 
2212 
2213 
2214 
2215 
2216 
2217 
2218 
2219 
2220 
2221 
2222 
2223 
2224 
2225 
2226 
2227 
2228 
2229 
2230 
2231 
2232 
2233 
2234 
2235 
2236 
2237 
2238 
2239 
2240 
2241 
2242 
2243 
2244 
2245 
2246 
2247 
2248 
2249 
2250 // Blank page.
2251 
2252 
2253 
2254 
2255 
2256 
2257 
2258 
2259 
2260 
2261 
2262 
2263 
2264 
2265 
2266 
2267 
2268 
2269 
2270 
2271 
2272 
2273 
2274 
2275 
2276 
2277 
2278 
2279 
2280 
2281 
2282 
2283 
2284 
2285 
2286 
2287 
2288 
2289 
2290 
2291 
2292 
2293 
2294 
2295 
2296 
2297 
2298 
2299 
2300 // Blank page.
2301 
2302 
2303 
2304 
2305 
2306 
2307 
2308 
2309 
2310 
2311 
2312 
2313 
2314 
2315 
2316 
2317 
2318 
2319 
2320 
2321 
2322 
2323 
2324 
2325 
2326 
2327 
2328 
2329 
2330 
2331 
2332 
2333 
2334 
2335 
2336 
2337 
2338 
2339 
2340 
2341 
2342 
2343 
2344 
2345 
2346 
2347 
2348 
2349 
