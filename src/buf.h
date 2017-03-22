// The block used by xv6 for its file system.
// 
// The block size that an operating system uses for its file system maybe
// different than the sector size that a disk uses, but typically the block size
// is a multiple of the sector size. Xv6’s block size is identical to the disk’s
// sector size. 
struct buf {
  // The flags track the relationship between memory and disk: the B_VALID flag
  // means that data has been read in, and the B_DIRTY flag means that data
  // needs to be written out. The B_BUSY flag is a lock bit; it indicates that
  // some process is using the buffer and other processes must not. When a
  // buffer has the B_BUSY flag set, we say the buffer is locked.
  int flags;
  // The dev and sector fields give the device and sector number and the data
  // field is an in-memory copy of the disk sector. 
  // Disk hardware traditionally presents the data on the disk as a numbered
  // sequence of 512-byte blocks (also called sectors).
  uint dev;
  uint blockno;
  struct sleeplock lock;
  uint refcnt;
  struct buf *prev; // LRU cache list
  struct buf *next;
  struct buf *qnext; // disk queue
  uchar data[BSIZE];
};
#define B_VALID 0x2  // buffer has been read from disk
#define B_DIRTY 0x4  // buffer needs to be written to disk

