3950 // The block used by xv6 for its file system.
3951 //
3952 // The block size that an operating system uses for its file system maybe
3953 // different than the sector size that a disk uses, but typically the block size
3954 // is a multiple of the sector size. Xv6’s block size is identical to the disk’s
3955 // sector size.
3956 struct buf {
3957   // The flags track the relationship between memory and disk: the B_VALID flag
3958   // means that data has been read in, and the B_DIRTY flag means that data
3959   // needs to be written out. The B_BUSY flag is a lock bit; it indicates that
3960   // some process is using the buffer and other processes must not. When a
3961   // buffer has the B_BUSY flag set, we say the buffer is locked.
3962   int flags;
3963   // The dev and sector fields give the device and sector number and the data
3964   // field is an in-memory copy of the disk sector.
3965   // Disk hardware traditionally presents the data on the disk as a numbered
3966   // sequence of 512-byte blocks (also called sectors).
3967   uint dev;
3968   uint blockno;
3969   struct sleeplock lock;
3970   uint refcnt;
3971   struct buf *prev; // LRU cache list
3972   struct buf *next;
3973   struct buf *qnext; // disk queue
3974   uchar data[BSIZE];
3975 };
3976 #define B_VALID 0x2  // buffer has been read from disk
3977 #define B_DIRTY 0x4  // buffer needs to be written to disk
3978 
3979 
3980 
3981 
3982 
3983 
3984 
3985 
3986 
3987 
3988 
3989 
3990 
3991 
3992 
3993 
3994 
3995 
3996 
3997 
3998 
3999 
