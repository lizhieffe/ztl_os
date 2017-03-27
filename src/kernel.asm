
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax # physical address
80100015:	b8 00 40 10 00       	mov    $0x104000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  #
  # TODO(lizhi): what is stack's value?
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc c0 61 10 80       	mov    $0x801061c0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 20 29 10 80       	mov    $0x80102920,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	53                   	push   %ebx

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100044:	bb f4 61 10 80       	mov    $0x801061f4,%ebx
  struct buf head;
} bcache;

void
binit(void)
{
80100049:	83 ec 14             	sub    $0x14,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010004c:	c7 44 24 04 04 37 10 	movl   $0x80103704,0x4(%esp)
80100053:	80 
80100054:	c7 04 24 c0 61 10 80 	movl   $0x801061c0,(%esp)
8010005b:	e8 40 30 00 00       	call   801030a0 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
80100060:	ba bc a8 10 80       	mov    $0x8010a8bc,%edx

  initlock(&bcache.lock, "bcache");

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100065:	c7 05 0c a9 10 80 bc 	movl   $0x8010a8bc,0x8010a90c
8010006c:	a8 10 80 
  bcache.head.next = &bcache.head;
8010006f:	c7 05 10 a9 10 80 bc 	movl   $0x8010a8bc,0x8010a910
80100076:	a8 10 80 
80100079:	eb 09                	jmp    80100084 <binit+0x44>
8010007b:	90                   	nop
8010007c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100080:	89 da                	mov    %ebx,%edx
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100082:	89 c3                	mov    %eax,%ebx
80100084:	8d 43 0c             	lea    0xc(%ebx),%eax
    b->next = bcache.head.next;
80100087:	89 53 54             	mov    %edx,0x54(%ebx)
    b->prev = &bcache.head;
8010008a:	c7 43 50 bc a8 10 80 	movl   $0x8010a8bc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100091:	89 04 24             	mov    %eax,(%esp)
80100094:	c7 44 24 04 0b 37 10 	movl   $0x8010370b,0x4(%esp)
8010009b:	80 
8010009c:	e8 ef 2e 00 00       	call   80102f90 <initsleeplock>
    bcache.head.next->prev = b;
801000a1:	a1 10 a9 10 80       	mov    0x8010a910,%eax
801000a6:	89 58 50             	mov    %ebx,0x50(%eax)

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000a9:	8d 83 5c 02 00 00    	lea    0x25c(%ebx),%eax
801000af:	3d bc a8 10 80       	cmp    $0x8010a8bc,%eax
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
801000b4:	89 1d 10 a9 10 80    	mov    %ebx,0x8010a910

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000ba:	75 c4                	jne    80100080 <binit+0x40>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000bc:	83 c4 14             	add    $0x14,%esp
801000bf:	5b                   	pop    %ebx
801000c0:	5d                   	pop    %ebp
801000c1:	c3                   	ret    
801000c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801000c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801000d0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801000d0:	55                   	push   %ebp
801000d1:	89 e5                	mov    %esp,%ebp
801000d3:	57                   	push   %edi
801000d4:	56                   	push   %esi
801000d5:	53                   	push   %ebx
801000d6:	83 ec 1c             	sub    $0x1c,%esp
801000d9:	8b 75 08             	mov    0x8(%ebp),%esi
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *b;

  acquire(&bcache.lock);
801000dc:	c7 04 24 c0 61 10 80 	movl   $0x801061c0,(%esp)
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801000e3:	8b 7d 0c             	mov    0xc(%ebp),%edi
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *b;

  acquire(&bcache.lock);
801000e6:	e8 35 30 00 00       	call   80103120 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000eb:	8b 1d 10 a9 10 80    	mov    0x8010a910,%ebx
801000f1:	81 fb bc a8 10 80    	cmp    $0x8010a8bc,%ebx
801000f7:	75 12                	jne    8010010b <bread+0x3b>
801000f9:	eb 25                	jmp    80100120 <bread+0x50>
801000fb:	90                   	nop
801000fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100100:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100103:	81 fb bc a8 10 80    	cmp    $0x8010a8bc,%ebx
80100109:	74 15                	je     80100120 <bread+0x50>
    if(b->dev == dev && b->blockno == blockno){
8010010b:	3b 73 04             	cmp    0x4(%ebx),%esi
8010010e:	75 f0                	jne    80100100 <bread+0x30>
80100110:	3b 7b 08             	cmp    0x8(%ebx),%edi
80100113:	75 eb                	jne    80100100 <bread+0x30>
      b->refcnt++;
80100115:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
80100119:	eb 3f                	jmp    8010015a <bread+0x8a>
8010011b:	90                   	nop
8010011c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }

  // Not cached; recycle some unused buffer and clean buffer
  // "clean" because B_DIRTY and not locked means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100120:	8b 1d 0c a9 10 80    	mov    0x8010a90c,%ebx
80100126:	81 fb bc a8 10 80    	cmp    $0x8010a8bc,%ebx
8010012c:	75 0d                	jne    8010013b <bread+0x6b>
8010012e:	eb 58                	jmp    80100188 <bread+0xb8>
80100130:	8b 5b 50             	mov    0x50(%ebx),%ebx
80100133:	81 fb bc a8 10 80    	cmp    $0x8010a8bc,%ebx
80100139:	74 4d                	je     80100188 <bread+0xb8>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010013e:	85 c0                	test   %eax,%eax
80100140:	75 ee                	jne    80100130 <bread+0x60>
80100142:	f6 03 04             	testb  $0x4,(%ebx)
80100145:	75 e9                	jne    80100130 <bread+0x60>
      b->dev = dev;
80100147:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
8010014a:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
8010014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
80100153:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
8010015a:	c7 04 24 c0 61 10 80 	movl   $0x801061c0,(%esp)
80100161:	e8 ca 30 00 00       	call   80103230 <release>
      acquiresleep(&b->lock);
80100166:	8d 43 0c             	lea    0xc(%ebx),%eax
80100169:	89 04 24             	mov    %eax,(%esp)
8010016c:	e8 5f 2e 00 00       	call   80102fd0 <acquiresleep>
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  if(!(b->flags & B_VALID)) {
80100171:	f6 03 02             	testb  $0x2,(%ebx)
80100174:	75 08                	jne    8010017e <bread+0xae>
    iderw(b);
80100176:	89 1c 24             	mov    %ebx,(%esp)
80100179:	e8 02 1c 00 00       	call   80101d80 <iderw>
  }
  return b;
}
8010017e:	83 c4 1c             	add    $0x1c,%esp
80100181:	89 d8                	mov    %ebx,%eax
80100183:	5b                   	pop    %ebx
80100184:	5e                   	pop    %esi
80100185:	5f                   	pop    %edi
80100186:	5d                   	pop    %ebp
80100187:	c3                   	ret    
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100188:	c7 04 24 12 37 10 80 	movl   $0x80103712,(%esp)
8010018f:	e8 cc 01 00 00       	call   80100360 <panic>
80100194:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010019a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801001a0 <bwrite>:
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001a0:	55                   	push   %ebp
801001a1:	89 e5                	mov    %esp,%ebp
801001a3:	53                   	push   %ebx
801001a4:	83 ec 14             	sub    $0x14,%esp
801001a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001aa:	8d 43 0c             	lea    0xc(%ebx),%eax
801001ad:	89 04 24             	mov    %eax,(%esp)
801001b0:	e8 bb 2e 00 00       	call   80103070 <holdingsleep>
801001b5:	85 c0                	test   %eax,%eax
801001b7:	74 10                	je     801001c9 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b9:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001bc:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801001bf:	83 c4 14             	add    $0x14,%esp
801001c2:	5b                   	pop    %ebx
801001c3:	5d                   	pop    %ebp
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
  b->flags |= B_DIRTY;
  iderw(b);
801001c4:	e9 b7 1b 00 00       	jmp    80101d80 <iderw>
// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
801001c9:	c7 04 24 23 37 10 80 	movl   $0x80103723,(%esp)
801001d0:	e8 8b 01 00 00       	call   80100360 <panic>
801001d5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801001d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801001e0 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001e0:	55                   	push   %ebp
801001e1:	89 e5                	mov    %esp,%ebp
801001e3:	56                   	push   %esi
801001e4:	53                   	push   %ebx
801001e5:	83 ec 10             	sub    $0x10,%esp
801001e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001eb:	8d 73 0c             	lea    0xc(%ebx),%esi
801001ee:	89 34 24             	mov    %esi,(%esp)
801001f1:	e8 7a 2e 00 00       	call   80103070 <holdingsleep>
801001f6:	85 c0                	test   %eax,%eax
801001f8:	74 5b                	je     80100255 <brelse+0x75>
    panic("brelse");

  releasesleep(&b->lock);
801001fa:	89 34 24             	mov    %esi,(%esp)
801001fd:	e8 2e 2e 00 00       	call   80103030 <releasesleep>

  acquire(&bcache.lock);
80100202:	c7 04 24 c0 61 10 80 	movl   $0x801061c0,(%esp)
80100209:	e8 12 2f 00 00       	call   80103120 <acquire>
  b->refcnt--;
  if (b->refcnt == 0) {
8010020e:	83 6b 4c 01          	subl   $0x1,0x4c(%ebx)
80100212:	75 2f                	jne    80100243 <brelse+0x63>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100214:	8b 43 54             	mov    0x54(%ebx),%eax
80100217:	8b 53 50             	mov    0x50(%ebx),%edx
8010021a:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010021d:	8b 43 50             	mov    0x50(%ebx),%eax
80100220:	8b 53 54             	mov    0x54(%ebx),%edx
80100223:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100226:	a1 10 a9 10 80       	mov    0x8010a910,%eax
    b->prev = &bcache.head;
8010022b:	c7 43 50 bc a8 10 80 	movl   $0x8010a8bc,0x50(%ebx)
  b->refcnt--;
  if (b->refcnt == 0) {
    // no one is waiting for it.
    b->next->prev = b->prev;
    b->prev->next = b->next;
    b->next = bcache.head.next;
80100232:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
    bcache.head.next->prev = b;
80100235:	a1 10 a9 10 80       	mov    0x8010a910,%eax
8010023a:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023d:	89 1d 10 a9 10 80    	mov    %ebx,0x8010a910
  }
  
  release(&bcache.lock);
80100243:	c7 45 08 c0 61 10 80 	movl   $0x801061c0,0x8(%ebp)
}
8010024a:	83 c4 10             	add    $0x10,%esp
8010024d:	5b                   	pop    %ebx
8010024e:	5e                   	pop    %esi
8010024f:	5d                   	pop    %ebp
    b->prev = &bcache.head;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
  
  release(&bcache.lock);
80100250:	e9 db 2f 00 00       	jmp    80103230 <release>
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("brelse");
80100255:	c7 04 24 2a 37 10 80 	movl   $0x8010372a,(%esp)
8010025c:	e8 ff 00 00 00       	call   80100360 <panic>
80100261:	66 90                	xchg   %ax,%ax
80100263:	66 90                	xchg   %ax,%ax
80100265:	66 90                	xchg   %ax,%ax
80100267:	66 90                	xchg   %ax,%ax
80100269:	66 90                	xchg   %ax,%ax
8010026b:	66 90                	xchg   %ax,%ax
8010026d:	66 90                	xchg   %ax,%ax
8010026f:	90                   	nop

80100270 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100270:	55                   	push   %ebp
80100271:	89 e5                	mov    %esp,%ebp
80100273:	57                   	push   %edi
80100274:	56                   	push   %esi
80100275:	53                   	push   %ebx
80100276:	83 ec 1c             	sub    $0x1c,%esp
80100279:	8b 7d 08             	mov    0x8(%ebp),%edi
8010027c:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
8010027f:	89 3c 24             	mov    %edi,(%esp)
80100282:	e8 69 11 00 00       	call   801013f0 <iunlock>
  target = n;
  acquire(&cons.lock);
80100287:	c7 04 24 20 51 10 80 	movl   $0x80105120,(%esp)
8010028e:	e8 8d 2e 00 00       	call   80103120 <acquire>
  while(n > 0){
80100293:	8b 55 10             	mov    0x10(%ebp),%edx
80100296:	85 d2                	test   %edx,%edx
80100298:	0f 8e bc 00 00 00    	jle    8010035a <consoleread+0xea>
8010029e:	8b 5d 10             	mov    0x10(%ebp),%ebx
801002a1:	eb 26                	jmp    801002c9 <consoleread+0x59>
801002a3:	90                   	nop
801002a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while(input.r == input.w){
      if(proc->killed){
801002a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801002ae:	8b 40 0c             	mov    0xc(%eax),%eax
801002b1:	85 c0                	test   %eax,%eax
801002b3:	75 73                	jne    80100328 <consoleread+0xb8>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b5:	c7 44 24 04 20 51 10 	movl   $0x80105120,0x4(%esp)
801002bc:	80 
801002bd:	c7 04 24 a0 ab 10 80 	movl   $0x8010aba0,(%esp)
801002c4:	e8 37 2b 00 00       	call   80102e00 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
801002c9:	a1 a0 ab 10 80       	mov    0x8010aba0,%eax
801002ce:	3b 05 a4 ab 10 80    	cmp    0x8010aba4,%eax
801002d4:	74 d2                	je     801002a8 <consoleread+0x38>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801002d6:	8d 50 01             	lea    0x1(%eax),%edx
801002d9:	89 15 a0 ab 10 80    	mov    %edx,0x8010aba0
801002df:	89 c2                	mov    %eax,%edx
801002e1:	83 e2 7f             	and    $0x7f,%edx
801002e4:	0f b6 8a 20 ab 10 80 	movzbl -0x7fef54e0(%edx),%ecx
801002eb:	0f be d1             	movsbl %cl,%edx
    if(c == C('D')){  // EOF
801002ee:	83 fa 04             	cmp    $0x4,%edx
801002f1:	74 56                	je     80100349 <consoleread+0xd9>
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
801002f3:	83 c6 01             	add    $0x1,%esi
    --n;
801002f6:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
801002f9:	83 fa 0a             	cmp    $0xa,%edx
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
801002fc:	88 4e ff             	mov    %cl,-0x1(%esi)
    --n;
    if(c == '\n')
801002ff:	74 52                	je     80100353 <consoleread+0xe3>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100301:	85 db                	test   %ebx,%ebx
80100303:	75 c4                	jne    801002c9 <consoleread+0x59>
80100305:	8b 45 10             	mov    0x10(%ebp),%eax
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100308:	c7 04 24 20 51 10 80 	movl   $0x80105120,(%esp)
8010030f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100312:	e8 19 2f 00 00       	call   80103230 <release>
  ilock(ip);
80100317:	89 3c 24             	mov    %edi,(%esp)
8010031a:	e8 01 10 00 00       	call   80101320 <ilock>
8010031f:	8b 45 e4             	mov    -0x1c(%ebp),%eax

  return target - n;
80100322:	eb 1d                	jmp    80100341 <consoleread+0xd1>
80100324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
      if(proc->killed){
        release(&cons.lock);
80100328:	c7 04 24 20 51 10 80 	movl   $0x80105120,(%esp)
8010032f:	e8 fc 2e 00 00       	call   80103230 <release>
        ilock(ip);
80100334:	89 3c 24             	mov    %edi,(%esp)
80100337:	e8 e4 0f 00 00       	call   80101320 <ilock>
        return -1;
8010033c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
80100341:	83 c4 1c             	add    $0x1c,%esp
80100344:	5b                   	pop    %ebx
80100345:	5e                   	pop    %esi
80100346:	5f                   	pop    %edi
80100347:	5d                   	pop    %ebp
80100348:	c3                   	ret    
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
    if(c == C('D')){  // EOF
      if(n < target){
80100349:	39 5d 10             	cmp    %ebx,0x10(%ebp)
8010034c:	76 05                	jbe    80100353 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
8010034e:	a3 a0 ab 10 80       	mov    %eax,0x8010aba0
80100353:	8b 45 10             	mov    0x10(%ebp),%eax
80100356:	29 d8                	sub    %ebx,%eax
80100358:	eb ae                	jmp    80100308 <consoleread+0x98>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
8010035a:	31 c0                	xor    %eax,%eax
8010035c:	eb aa                	jmp    80100308 <consoleread+0x98>
8010035e:	66 90                	xchg   %ax,%ax

80100360 <panic>:
    release(&cons.lock);
}

void
panic(char *s)
{
80100360:	55                   	push   %ebp
80100361:	89 e5                	mov    %esp,%ebp
80100363:	56                   	push   %esi
80100364:	53                   	push   %ebx
80100365:	83 ec 40             	sub    $0x40,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100368:	fa                   	cli    
  int i;
  uint pcs[10];

  cli();
  cons.locking = 0;
  cprintf("cpu with apicid %d: panic: ", cpu->apicid);
80100369:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
8010036f:	8d 5d d0             	lea    -0x30(%ebp),%ebx
{
  int i;
  uint pcs[10];

  cli();
  cons.locking = 0;
80100372:	c7 05 54 51 10 80 00 	movl   $0x0,0x80105154
80100379:	00 00 00 
8010037c:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("cpu with apicid %d: panic: ", cpu->apicid);
8010037f:	0f b6 00             	movzbl (%eax),%eax
80100382:	c7 04 24 31 37 10 80 	movl   $0x80103731,(%esp)
80100389:	89 44 24 04          	mov    %eax,0x4(%esp)
8010038d:	e8 be 02 00 00       	call   80100650 <cprintf>
  cprintf(s);
80100392:	8b 45 08             	mov    0x8(%ebp),%eax
80100395:	89 04 24             	mov    %eax,(%esp)
80100398:	e8 b3 02 00 00       	call   80100650 <cprintf>
  cprintf("\n");
8010039d:	c7 04 24 e0 3a 10 80 	movl   $0x80103ae0,(%esp)
801003a4:	e8 a7 02 00 00       	call   80100650 <cprintf>
  getcallerpcs(&s, pcs);
801003a9:	8d 45 08             	lea    0x8(%ebp),%eax
801003ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801003b0:	89 04 24             	mov    %eax,(%esp)
801003b3:	e8 08 2d 00 00       	call   801030c0 <getcallerpcs>
  for(i=0; i<10; i++)
    cprintf(" %p", pcs[i]);
801003b8:	8b 03                	mov    (%ebx),%eax
801003ba:	83 c3 04             	add    $0x4,%ebx
801003bd:	c7 04 24 4d 37 10 80 	movl   $0x8010374d,(%esp)
801003c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801003c8:	e8 83 02 00 00       	call   80100650 <cprintf>
  cons.locking = 0;
  cprintf("cpu with apicid %d: panic: ", cpu->apicid);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801003cd:	39 f3                	cmp    %esi,%ebx
801003cf:	75 e7                	jne    801003b8 <panic+0x58>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801003d1:	c7 05 58 51 10 80 01 	movl   $0x1,0x80105158
801003d8:	00 00 00 
801003db:	eb fe                	jmp    801003db <panic+0x7b>
801003dd:	8d 76 00             	lea    0x0(%esi),%esi

801003e0 <consputc>:
}

void
consputc(int c)
{
  if(panicked){
801003e0:	8b 15 58 51 10 80    	mov    0x80105158,%edx
801003e6:	85 d2                	test   %edx,%edx
801003e8:	74 06                	je     801003f0 <consputc+0x10>
801003ea:	fa                   	cli    
801003eb:	eb fe                	jmp    801003eb <consputc+0xb>
801003ed:	8d 76 00             	lea    0x0(%esi),%esi
  crt[pos] = ' ' | 0x0700;
}

void
consputc(int c)
{
801003f0:	55                   	push   %ebp
801003f1:	89 e5                	mov    %esp,%ebp
801003f3:	57                   	push   %edi
801003f4:	56                   	push   %esi
801003f5:	53                   	push   %ebx
801003f6:	89 c3                	mov    %eax,%ebx
801003f8:	83 ec 1c             	sub    $0x1c,%esp
    cli();
    for(;;)
      ;
  }

  if(c == BACKSPACE){
801003fb:	3d 00 01 00 00       	cmp    $0x100,%eax
80100400:	0f 84 ac 00 00 00    	je     801004b2 <consputc+0xd2>
    // Moves the cursor backward, but doesn't erase what's there.
    uartputc('\b');
    uartputc(' ');
    uartputc('\b');
  } else {
    uartputc(c);
80100406:	89 04 24             	mov    %eax,(%esp)
80100409:	e8 72 30 00 00       	call   80103480 <uartputc>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010040e:	bf d4 03 00 00       	mov    $0x3d4,%edi
80100413:	b8 0e 00 00 00       	mov    $0xe,%eax
80100418:	89 fa                	mov    %edi,%edx
8010041a:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010041b:	be d5 03 00 00       	mov    $0x3d5,%esi
80100420:	89 f2                	mov    %esi,%edx
80100422:	ec                   	in     (%dx),%al
{
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
  pos = inb(CRTPORT+1) << 8;
80100423:	0f b6 c8             	movzbl %al,%ecx
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100426:	89 fa                	mov    %edi,%edx
80100428:	c1 e1 08             	shl    $0x8,%ecx
8010042b:	b8 0f 00 00 00       	mov    $0xf,%eax
80100430:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100431:	89 f2                	mov    %esi,%edx
80100433:	ec                   	in     (%dx),%al
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);
80100434:	0f b6 c0             	movzbl %al,%eax
80100437:	09 c1                	or     %eax,%ecx

  if(c == '\n')
80100439:	83 fb 0a             	cmp    $0xa,%ebx
8010043c:	0f 84 0d 01 00 00    	je     8010054f <consputc+0x16f>
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
80100442:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
80100448:	0f 84 e8 00 00 00    	je     80100536 <consputc+0x156>
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010044e:	0f b6 db             	movzbl %bl,%ebx
80100451:	80 cf 07             	or     $0x7,%bh
80100454:	8d 79 01             	lea    0x1(%ecx),%edi
80100457:	66 89 9c 09 00 80 0b 	mov    %bx,-0x7ff48000(%ecx,%ecx,1)
8010045e:	80 

  if(pos < 0 || pos > 25*80)
8010045f:	81 ff d0 07 00 00    	cmp    $0x7d0,%edi
80100465:	0f 87 bf 00 00 00    	ja     8010052a <consputc+0x14a>
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
8010046b:	81 ff 7f 07 00 00    	cmp    $0x77f,%edi
80100471:	7f 68                	jg     801004db <consputc+0xfb>
80100473:	89 f8                	mov    %edi,%eax
80100475:	89 fb                	mov    %edi,%ebx
80100477:	c1 e8 08             	shr    $0x8,%eax
8010047a:	89 c6                	mov    %eax,%esi
8010047c:	8d 8c 3f 00 80 0b 80 	lea    -0x7ff48000(%edi,%edi,1),%ecx
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100483:	bf d4 03 00 00       	mov    $0x3d4,%edi
80100488:	b8 0e 00 00 00       	mov    $0xe,%eax
8010048d:	89 fa                	mov    %edi,%edx
8010048f:	ee                   	out    %al,(%dx)
80100490:	89 f0                	mov    %esi,%eax
80100492:	b2 d5                	mov    $0xd5,%dl
80100494:	ee                   	out    %al,(%dx)
80100495:	b8 0f 00 00 00       	mov    $0xf,%eax
8010049a:	89 fa                	mov    %edi,%edx
8010049c:	ee                   	out    %al,(%dx)
8010049d:	89 d8                	mov    %ebx,%eax
8010049f:	b2 d5                	mov    $0xd5,%dl
801004a1:	ee                   	out    %al,(%dx)

  outb(CRTPORT, 14);
  outb(CRTPORT+1, pos>>8);
  outb(CRTPORT, 15);
  outb(CRTPORT+1, pos);
  crt[pos] = ' ' | 0x0700;
801004a2:	b8 20 07 00 00       	mov    $0x720,%eax
801004a7:	66 89 01             	mov    %ax,(%ecx)
    uartputc('\b');
  } else {
    uartputc(c);
  }
  cgaputc(c);
}
801004aa:	83 c4 1c             	add    $0x1c,%esp
801004ad:	5b                   	pop    %ebx
801004ae:	5e                   	pop    %esi
801004af:	5f                   	pop    %edi
801004b0:	5d                   	pop    %ebp
801004b1:	c3                   	ret    
      ;
  }

  if(c == BACKSPACE){
    // Moves the cursor backward, but doesn't erase what's there.
    uartputc('\b');
801004b2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801004b9:	e8 c2 2f 00 00       	call   80103480 <uartputc>
    uartputc(' ');
801004be:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004c5:	e8 b6 2f 00 00       	call   80103480 <uartputc>
    uartputc('\b');
801004ca:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801004d1:	e8 aa 2f 00 00       	call   80103480 <uartputc>
801004d6:	e9 33 ff ff ff       	jmp    8010040e <consputc+0x2e>

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004db:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801004e2:	00 
    pos -= 80;
801004e3:	8d 5f b0             	lea    -0x50(%edi),%ebx

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004e6:	c7 44 24 04 a0 80 0b 	movl   $0x800b80a0,0x4(%esp)
801004ed:	80 
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004ee:	8d b4 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%esi

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004f5:	c7 04 24 00 80 0b 80 	movl   $0x800b8000,(%esp)
801004fc:	e8 1f 2e 00 00       	call   80103320 <memmove>
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100501:	b8 d0 07 00 00       	mov    $0x7d0,%eax
80100506:	29 f8                	sub    %edi,%eax
80100508:	01 c0                	add    %eax,%eax
8010050a:	89 34 24             	mov    %esi,(%esp)
8010050d:	89 44 24 08          	mov    %eax,0x8(%esp)
80100511:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100518:	00 
80100519:	e8 62 2d 00 00       	call   80103280 <memset>
8010051e:	89 f1                	mov    %esi,%ecx
80100520:	be 07 00 00 00       	mov    $0x7,%esi
80100525:	e9 59 ff ff ff       	jmp    80100483 <consputc+0xa3>
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");
8010052a:	c7 04 24 51 37 10 80 	movl   $0x80103751,(%esp)
80100531:	e8 2a fe ff ff       	call   80100360 <panic>
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
    if(pos > 0) --pos;
80100536:	85 c9                	test   %ecx,%ecx
80100538:	8d 79 ff             	lea    -0x1(%ecx),%edi
8010053b:	0f 85 1e ff ff ff    	jne    8010045f <consputc+0x7f>
80100541:	b9 00 80 0b 80       	mov    $0x800b8000,%ecx
80100546:	31 db                	xor    %ebx,%ebx
80100548:	31 f6                	xor    %esi,%esi
8010054a:	e9 34 ff ff ff       	jmp    80100483 <consputc+0xa3>
  pos = inb(CRTPORT+1) << 8;
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
8010054f:	89 c8                	mov    %ecx,%eax
80100551:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100556:	f7 ea                	imul   %edx
80100558:	c1 ea 05             	shr    $0x5,%edx
8010055b:	8d 04 92             	lea    (%edx,%edx,4),%eax
8010055e:	c1 e0 04             	shl    $0x4,%eax
80100561:	8d 78 50             	lea    0x50(%eax),%edi
80100564:	e9 f6 fe ff ff       	jmp    8010045f <consputc+0x7f>
80100569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100570 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100570:	55                   	push   %ebp
80100571:	89 e5                	mov    %esp,%ebp
80100573:	57                   	push   %edi
80100574:	56                   	push   %esi
80100575:	89 d6                	mov    %edx,%esi
80100577:	53                   	push   %ebx
80100578:	83 ec 1c             	sub    $0x1c,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010057b:	85 c9                	test   %ecx,%ecx
8010057d:	74 61                	je     801005e0 <printint+0x70>
8010057f:	85 c0                	test   %eax,%eax
80100581:	79 5d                	jns    801005e0 <printint+0x70>
    x = -xx;
80100583:	f7 d8                	neg    %eax
80100585:	bf 01 00 00 00       	mov    $0x1,%edi
  else
    x = xx;

  i = 0;
8010058a:	31 c9                	xor    %ecx,%ecx
8010058c:	eb 04                	jmp    80100592 <printint+0x22>
8010058e:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
80100590:	89 d9                	mov    %ebx,%ecx
80100592:	31 d2                	xor    %edx,%edx
80100594:	f7 f6                	div    %esi
80100596:	8d 59 01             	lea    0x1(%ecx),%ebx
80100599:	0f b6 92 7c 37 10 80 	movzbl -0x7fefc884(%edx),%edx
  }while((x /= base) != 0);
801005a0:	85 c0                	test   %eax,%eax
  else
    x = xx;

  i = 0;
  do{
    buf[i++] = digits[x % base];
801005a2:	88 54 1d d7          	mov    %dl,-0x29(%ebp,%ebx,1)
  }while((x /= base) != 0);
801005a6:	75 e8                	jne    80100590 <printint+0x20>

  if(sign)
801005a8:	85 ff                	test   %edi,%edi
  else
    x = xx;

  i = 0;
  do{
    buf[i++] = digits[x % base];
801005aa:	89 d8                	mov    %ebx,%eax
  }while((x /= base) != 0);

  if(sign)
801005ac:	74 08                	je     801005b6 <printint+0x46>
    buf[i++] = '-';
801005ae:	8d 59 02             	lea    0x2(%ecx),%ebx
801005b1:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)

  while(--i >= 0)
801005b6:	83 eb 01             	sub    $0x1,%ebx
801005b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    consputc(buf[i]);
801005c0:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801005c5:	83 eb 01             	sub    $0x1,%ebx
    consputc(buf[i]);
801005c8:	e8 13 fe ff ff       	call   801003e0 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801005cd:	83 fb ff             	cmp    $0xffffffff,%ebx
801005d0:	75 ee                	jne    801005c0 <printint+0x50>
    consputc(buf[i]);
}
801005d2:	83 c4 1c             	add    $0x1c,%esp
801005d5:	5b                   	pop    %ebx
801005d6:	5e                   	pop    %esi
801005d7:	5f                   	pop    %edi
801005d8:	5d                   	pop    %ebp
801005d9:	c3                   	ret    
801005da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  uint x;

  if(sign && (sign = xx < 0))
    x = -xx;
  else
    x = xx;
801005e0:	31 ff                	xor    %edi,%edi
801005e2:	eb a6                	jmp    8010058a <printint+0x1a>
801005e4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801005ea:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801005f0 <consolewrite>:
  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005f0:	55                   	push   %ebp
801005f1:	89 e5                	mov    %esp,%ebp
801005f3:	57                   	push   %edi
801005f4:	56                   	push   %esi
801005f5:	53                   	push   %ebx
801005f6:	83 ec 1c             	sub    $0x1c,%esp
  int i;

  iunlock(ip);
801005f9:	8b 45 08             	mov    0x8(%ebp),%eax
  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005fc:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005ff:	89 04 24             	mov    %eax,(%esp)
80100602:	e8 e9 0d 00 00       	call   801013f0 <iunlock>
  acquire(&cons.lock);
80100607:	c7 04 24 20 51 10 80 	movl   $0x80105120,(%esp)
8010060e:	e8 0d 2b 00 00       	call   80103120 <acquire>
80100613:	8b 7d 0c             	mov    0xc(%ebp),%edi
  for(i = 0; i < n; i++)
80100616:	85 f6                	test   %esi,%esi
80100618:	8d 1c 37             	lea    (%edi,%esi,1),%ebx
8010061b:	7e 12                	jle    8010062f <consolewrite+0x3f>
8010061d:	8d 76 00             	lea    0x0(%esi),%esi
    consputc(buf[i] & 0xff);
80100620:	0f b6 07             	movzbl (%edi),%eax
80100623:	83 c7 01             	add    $0x1,%edi
80100626:	e8 b5 fd ff ff       	call   801003e0 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
8010062b:	39 df                	cmp    %ebx,%edi
8010062d:	75 f1                	jne    80100620 <consolewrite+0x30>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
8010062f:	c7 04 24 20 51 10 80 	movl   $0x80105120,(%esp)
80100636:	e8 f5 2b 00 00       	call   80103230 <release>
  ilock(ip);
8010063b:	8b 45 08             	mov    0x8(%ebp),%eax
8010063e:	89 04 24             	mov    %eax,(%esp)
80100641:	e8 da 0c 00 00       	call   80101320 <ilock>

  return n;
}
80100646:	83 c4 1c             	add    $0x1c,%esp
80100649:	89 f0                	mov    %esi,%eax
8010064b:	5b                   	pop    %ebx
8010064c:	5e                   	pop    %esi
8010064d:	5f                   	pop    %edi
8010064e:	5d                   	pop    %ebp
8010064f:	c3                   	ret    

80100650 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100650:	55                   	push   %ebp
80100651:	89 e5                	mov    %esp,%ebp
80100653:	57                   	push   %edi
80100654:	56                   	push   %esi
80100655:	53                   	push   %ebx
80100656:	83 ec 1c             	sub    $0x1c,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100659:	a1 54 51 10 80       	mov    0x80105154,%eax
  if(locking)
8010065e:	85 c0                	test   %eax,%eax
{
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100660:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(locking)
80100663:	0f 85 27 01 00 00    	jne    80100790 <cprintf+0x140>
    acquire(&cons.lock);

  if (fmt == 0)
80100669:	8b 45 08             	mov    0x8(%ebp),%eax
8010066c:	85 c0                	test   %eax,%eax
8010066e:	89 c1                	mov    %eax,%ecx
80100670:	0f 84 2b 01 00 00    	je     801007a1 <cprintf+0x151>
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100676:	0f b6 00             	movzbl (%eax),%eax
80100679:	31 db                	xor    %ebx,%ebx
8010067b:	89 cf                	mov    %ecx,%edi
8010067d:	8d 75 0c             	lea    0xc(%ebp),%esi
80100680:	85 c0                	test   %eax,%eax
80100682:	75 4c                	jne    801006d0 <cprintf+0x80>
80100684:	eb 5f                	jmp    801006e5 <cprintf+0x95>
80100686:	66 90                	xchg   %ax,%ax
    if(c != '%'){
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
80100688:	83 c3 01             	add    $0x1,%ebx
8010068b:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
    if(c == 0)
8010068f:	85 d2                	test   %edx,%edx
80100691:	74 52                	je     801006e5 <cprintf+0x95>
      break;
    switch(c){
80100693:	83 fa 70             	cmp    $0x70,%edx
80100696:	74 72                	je     8010070a <cprintf+0xba>
80100698:	7f 66                	jg     80100700 <cprintf+0xb0>
8010069a:	83 fa 25             	cmp    $0x25,%edx
8010069d:	8d 76 00             	lea    0x0(%esi),%esi
801006a0:	0f 84 a2 00 00 00    	je     80100748 <cprintf+0xf8>
801006a6:	83 fa 64             	cmp    $0x64,%edx
801006a9:	75 7d                	jne    80100728 <cprintf+0xd8>
    case 'd':
      printint(*argp++, 10, 1);
801006ab:	8d 46 04             	lea    0x4(%esi),%eax
801006ae:	b9 01 00 00 00       	mov    $0x1,%ecx
801006b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801006b6:	8b 06                	mov    (%esi),%eax
801006b8:	ba 0a 00 00 00       	mov    $0xa,%edx
801006bd:	e8 ae fe ff ff       	call   80100570 <printint>
801006c2:	8b 75 e4             	mov    -0x1c(%ebp),%esi

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006c5:	83 c3 01             	add    $0x1,%ebx
801006c8:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801006cc:	85 c0                	test   %eax,%eax
801006ce:	74 15                	je     801006e5 <cprintf+0x95>
    if(c != '%'){
801006d0:	83 f8 25             	cmp    $0x25,%eax
801006d3:	74 b3                	je     80100688 <cprintf+0x38>
      consputc('%');
      break;
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
      consputc(c);
801006d5:	e8 06 fd ff ff       	call   801003e0 <consputc>

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006da:	83 c3 01             	add    $0x1,%ebx
801006dd:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801006e1:	85 c0                	test   %eax,%eax
801006e3:	75 eb                	jne    801006d0 <cprintf+0x80>
      consputc(c);
      break;
    }
  }

  if(locking)
801006e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801006e8:	85 c0                	test   %eax,%eax
801006ea:	74 0c                	je     801006f8 <cprintf+0xa8>
    release(&cons.lock);
801006ec:	c7 04 24 20 51 10 80 	movl   $0x80105120,(%esp)
801006f3:	e8 38 2b 00 00       	call   80103230 <release>
}
801006f8:	83 c4 1c             	add    $0x1c,%esp
801006fb:	5b                   	pop    %ebx
801006fc:	5e                   	pop    %esi
801006fd:	5f                   	pop    %edi
801006fe:	5d                   	pop    %ebp
801006ff:	c3                   	ret    
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
80100700:	83 fa 73             	cmp    $0x73,%edx
80100703:	74 53                	je     80100758 <cprintf+0x108>
80100705:	83 fa 78             	cmp    $0x78,%edx
80100708:	75 1e                	jne    80100728 <cprintf+0xd8>
    case 'd':
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010070a:	8d 46 04             	lea    0x4(%esi),%eax
8010070d:	31 c9                	xor    %ecx,%ecx
8010070f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100712:	8b 06                	mov    (%esi),%eax
80100714:	ba 10 00 00 00       	mov    $0x10,%edx
80100719:	e8 52 fe ff ff       	call   80100570 <printint>
8010071e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
      break;
80100721:	eb a2                	jmp    801006c5 <cprintf+0x75>
80100723:	90                   	nop
80100724:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    case '%':
      consputc('%');
      break;
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100728:	b8 25 00 00 00       	mov    $0x25,%eax
8010072d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80100730:	e8 ab fc ff ff       	call   801003e0 <consputc>
      consputc(c);
80100735:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80100738:	89 d0                	mov    %edx,%eax
8010073a:	e8 a1 fc ff ff       	call   801003e0 <consputc>
8010073f:	eb 99                	jmp    801006da <cprintf+0x8a>
80100741:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
      break;
    case '%':
      consputc('%');
80100748:	b8 25 00 00 00       	mov    $0x25,%eax
8010074d:	e8 8e fc ff ff       	call   801003e0 <consputc>
      break;
80100752:	e9 6e ff ff ff       	jmp    801006c5 <cprintf+0x75>
80100757:	90                   	nop
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
80100758:	8d 46 04             	lea    0x4(%esi),%eax
8010075b:	8b 36                	mov    (%esi),%esi
8010075d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        s = "(null)";
80100760:	b8 64 37 10 80       	mov    $0x80103764,%eax
80100765:	85 f6                	test   %esi,%esi
80100767:	0f 44 f0             	cmove  %eax,%esi
      for(; *s; s++)
8010076a:	0f be 06             	movsbl (%esi),%eax
8010076d:	84 c0                	test   %al,%al
8010076f:	74 16                	je     80100787 <cprintf+0x137>
80100771:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100778:	83 c6 01             	add    $0x1,%esi
        consputc(*s);
8010077b:	e8 60 fc ff ff       	call   801003e0 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
80100780:	0f be 06             	movsbl (%esi),%eax
80100783:	84 c0                	test   %al,%al
80100785:	75 f1                	jne    80100778 <cprintf+0x128>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
80100787:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010078a:	e9 36 ff ff ff       	jmp    801006c5 <cprintf+0x75>
8010078f:	90                   	nop
  uint *argp;
  char *s;

  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);
80100790:	c7 04 24 20 51 10 80 	movl   $0x80105120,(%esp)
80100797:	e8 84 29 00 00       	call   80103120 <acquire>
8010079c:	e9 c8 fe ff ff       	jmp    80100669 <cprintf+0x19>

  if (fmt == 0)
    panic("null fmt");
801007a1:	c7 04 24 6b 37 10 80 	movl   $0x8010376b,(%esp)
801007a8:	e8 b3 fb ff ff       	call   80100360 <panic>
801007ad:	8d 76 00             	lea    0x0(%esi),%esi

801007b0 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007b0:	55                   	push   %ebp
801007b1:	89 e5                	mov    %esp,%ebp
801007b3:	57                   	push   %edi
801007b4:	56                   	push   %esi
  int c, doprocdump = 0;
801007b5:	31 f6                	xor    %esi,%esi

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007b7:	53                   	push   %ebx
801007b8:	83 ec 1c             	sub    $0x1c,%esp
801007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int c, doprocdump = 0;

  acquire(&cons.lock);
801007be:	c7 04 24 20 51 10 80 	movl   $0x80105120,(%esp)
801007c5:	e8 56 29 00 00       	call   80103120 <acquire>
801007ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  while((c = getc()) >= 0){
801007d0:	ff d3                	call   *%ebx
801007d2:	85 c0                	test   %eax,%eax
801007d4:	89 c7                	mov    %eax,%edi
801007d6:	78 48                	js     80100820 <consoleintr+0x70>
    switch(c){
801007d8:	83 ff 10             	cmp    $0x10,%edi
801007db:	0f 84 2f 01 00 00    	je     80100910 <consoleintr+0x160>
801007e1:	7e 5d                	jle    80100840 <consoleintr+0x90>
801007e3:	83 ff 15             	cmp    $0x15,%edi
801007e6:	0f 84 d4 00 00 00    	je     801008c0 <consoleintr+0x110>
801007ec:	83 ff 7f             	cmp    $0x7f,%edi
801007ef:	90                   	nop
801007f0:	75 53                	jne    80100845 <consoleintr+0x95>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801007f2:	a1 a8 ab 10 80       	mov    0x8010aba8,%eax
801007f7:	3b 05 a4 ab 10 80    	cmp    0x8010aba4,%eax
801007fd:	74 d1                	je     801007d0 <consoleintr+0x20>
        input.e--;
801007ff:	83 e8 01             	sub    $0x1,%eax
80100802:	a3 a8 ab 10 80       	mov    %eax,0x8010aba8
        consputc(BACKSPACE);
80100807:	b8 00 01 00 00       	mov    $0x100,%eax
8010080c:	e8 cf fb ff ff       	call   801003e0 <consputc>
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100811:	ff d3                	call   *%ebx
80100813:	85 c0                	test   %eax,%eax
80100815:	89 c7                	mov    %eax,%edi
80100817:	79 bf                	jns    801007d8 <consoleintr+0x28>
80100819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100820:	c7 04 24 20 51 10 80 	movl   $0x80105120,(%esp)
80100827:	e8 04 2a 00 00       	call   80103230 <release>
  if(doprocdump) {
8010082c:	85 f6                	test   %esi,%esi
8010082e:	0f 85 ec 00 00 00    	jne    80100920 <consoleintr+0x170>
    procdump();  // now call procdump() wo. cons.lock held
  }
}
80100834:	83 c4 1c             	add    $0x1c,%esp
80100837:	5b                   	pop    %ebx
80100838:	5e                   	pop    %esi
80100839:	5f                   	pop    %edi
8010083a:	5d                   	pop    %ebp
8010083b:	c3                   	ret    
8010083c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
    switch(c){
80100840:	83 ff 08             	cmp    $0x8,%edi
80100843:	74 ad                	je     801007f2 <consoleintr+0x42>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100845:	85 ff                	test   %edi,%edi
80100847:	74 87                	je     801007d0 <consoleintr+0x20>
80100849:	a1 a8 ab 10 80       	mov    0x8010aba8,%eax
8010084e:	89 c2                	mov    %eax,%edx
80100850:	2b 15 a0 ab 10 80    	sub    0x8010aba0,%edx
80100856:	83 fa 7f             	cmp    $0x7f,%edx
80100859:	0f 87 71 ff ff ff    	ja     801007d0 <consoleintr+0x20>
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
8010085f:	8d 50 01             	lea    0x1(%eax),%edx
80100862:	83 e0 7f             	and    $0x7f,%eax
        consputc(BACKSPACE);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
80100865:	83 ff 0d             	cmp    $0xd,%edi
        input.buf[input.e++ % INPUT_BUF] = c;
80100868:	89 15 a8 ab 10 80    	mov    %edx,0x8010aba8
        consputc(BACKSPACE);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
8010086e:	0f 84 b8 00 00 00    	je     8010092c <consoleintr+0x17c>
        input.buf[input.e++ % INPUT_BUF] = c;
80100874:	89 f9                	mov    %edi,%ecx
80100876:	88 88 20 ab 10 80    	mov    %cl,-0x7fef54e0(%eax)
        consputc(c);
8010087c:	89 f8                	mov    %edi,%eax
8010087e:	e8 5d fb ff ff       	call   801003e0 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100883:	83 ff 04             	cmp    $0x4,%edi
80100886:	a1 a8 ab 10 80       	mov    0x8010aba8,%eax
8010088b:	74 19                	je     801008a6 <consoleintr+0xf6>
8010088d:	83 ff 0a             	cmp    $0xa,%edi
80100890:	74 14                	je     801008a6 <consoleintr+0xf6>
80100892:	8b 0d a0 ab 10 80    	mov    0x8010aba0,%ecx
80100898:	8d 91 80 00 00 00    	lea    0x80(%ecx),%edx
8010089e:	39 d0                	cmp    %edx,%eax
801008a0:	0f 85 2a ff ff ff    	jne    801007d0 <consoleintr+0x20>
          input.w = input.e;
          wakeup(&input.r);
801008a6:	c7 04 24 a0 ab 10 80 	movl   $0x8010aba0,(%esp)
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
        consputc(c);
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
          input.w = input.e;
801008ad:	a3 a4 ab 10 80       	mov    %eax,0x8010aba4
          wakeup(&input.r);
801008b2:	e8 09 26 00 00       	call   80102ec0 <wakeup>
801008b7:	e9 14 ff ff ff       	jmp    801007d0 <consoleintr+0x20>
801008bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008c0:	a1 a8 ab 10 80       	mov    0x8010aba8,%eax
801008c5:	3b 05 a4 ab 10 80    	cmp    0x8010aba4,%eax
801008cb:	75 2b                	jne    801008f8 <consoleintr+0x148>
801008cd:	e9 fe fe ff ff       	jmp    801007d0 <consoleintr+0x20>
801008d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008d8:	a3 a8 ab 10 80       	mov    %eax,0x8010aba8
        consputc(BACKSPACE);
801008dd:	b8 00 01 00 00       	mov    $0x100,%eax
801008e2:	e8 f9 fa ff ff       	call   801003e0 <consputc>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008e7:	a1 a8 ab 10 80       	mov    0x8010aba8,%eax
801008ec:	3b 05 a4 ab 10 80    	cmp    0x8010aba4,%eax
801008f2:	0f 84 d8 fe ff ff    	je     801007d0 <consoleintr+0x20>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008f8:	83 e8 01             	sub    $0x1,%eax
801008fb:	89 c2                	mov    %eax,%edx
801008fd:	83 e2 7f             	and    $0x7f,%edx
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100900:	80 ba 20 ab 10 80 0a 	cmpb   $0xa,-0x7fef54e0(%edx)
80100907:	75 cf                	jne    801008d8 <consoleintr+0x128>
80100909:	e9 c2 fe ff ff       	jmp    801007d0 <consoleintr+0x20>
8010090e:	66 90                	xchg   %ax,%ax
  acquire(&cons.lock);
  while((c = getc()) >= 0){
    switch(c){
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100910:	be 01 00 00 00       	mov    $0x1,%esi
80100915:	e9 b6 fe ff ff       	jmp    801007d0 <consoleintr+0x20>
8010091a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }
  release(&cons.lock);
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
  }
}
80100920:	83 c4 1c             	add    $0x1c,%esp
80100923:	5b                   	pop    %ebx
80100924:	5e                   	pop    %esi
80100925:	5f                   	pop    %edi
80100926:	5d                   	pop    %ebp
      break;
    }
  }
  release(&cons.lock);
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
80100927:	e9 f4 25 00 00       	jmp    80102f20 <procdump>
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
8010092c:	c6 80 20 ab 10 80 0a 	movb   $0xa,-0x7fef54e0(%eax)
        consputc(c);
80100933:	b8 0a 00 00 00       	mov    $0xa,%eax
80100938:	e8 a3 fa ff ff       	call   801003e0 <consputc>
8010093d:	a1 a8 ab 10 80       	mov    0x8010aba8,%eax
80100942:	e9 5f ff ff ff       	jmp    801008a6 <consoleintr+0xf6>
80100947:	89 f6                	mov    %esi,%esi
80100949:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100950 <consoleinit>:
  return n;
}

void
consoleinit(void)
{
80100950:	55                   	push   %ebp
80100951:	89 e5                	mov    %esp,%ebp
80100953:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100956:	c7 44 24 04 74 37 10 	movl   $0x80103774,0x4(%esp)
8010095d:	80 
8010095e:	c7 04 24 20 51 10 80 	movl   $0x80105120,(%esp)
80100965:	e8 36 27 00 00       	call   801030a0 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  picenable(IRQ_KBD);
8010096a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
void
consoleinit(void)
{
  initlock(&cons.lock, "console");

  devsw[CONSOLE].write = consolewrite;
80100971:	c7 05 6c b5 10 80 f0 	movl   $0x801005f0,0x8010b56c
80100978:	05 10 80 
  devsw[CONSOLE].read = consoleread;
8010097b:	c7 05 68 b5 10 80 70 	movl   $0x80100270,0x8010b568
80100982:	02 10 80 
  cons.locking = 1;
80100985:	c7 05 54 51 10 80 01 	movl   $0x1,0x80105154
8010098c:	00 00 00 

  picenable(IRQ_KBD);
8010098f:	e8 bc 1f 00 00       	call   80102950 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100994:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010099b:	00 
8010099c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801009a3:	e8 68 15 00 00       	call   80101f10 <ioapicenable>
}
801009a8:	c9                   	leave  
801009a9:	c3                   	ret    
801009aa:	66 90                	xchg   %ax,%ax
801009ac:	66 90                	xchg   %ax,%ax
801009ae:	66 90                	xchg   %ax,%ax

801009b0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801009b0:	55                   	push   %ebp
801009b1:	89 e5                	mov    %esp,%ebp
801009b3:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
801009b6:	c7 44 24 04 8d 37 10 	movl   $0x8010378d,0x4(%esp)
801009bd:	80 
801009be:	c7 04 24 c0 ab 10 80 	movl   $0x8010abc0,(%esp)
801009c5:	e8 d6 26 00 00       	call   801030a0 <initlock>
}
801009ca:	c9                   	leave  
801009cb:	c3                   	ret    
801009cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801009d0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801009d0:	55                   	push   %ebp
801009d1:	89 e5                	mov    %esp,%ebp
801009d3:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801009d4:	bb f4 ab 10 80       	mov    $0x8010abf4,%ebx
}

// Allocate a file structure.
struct file*
filealloc(void)
{
801009d9:	83 ec 14             	sub    $0x14,%esp
  struct file *f;

  acquire(&ftable.lock);
801009dc:	c7 04 24 c0 ab 10 80 	movl   $0x8010abc0,(%esp)
801009e3:	e8 38 27 00 00       	call   80103120 <acquire>
801009e8:	eb 11                	jmp    801009fb <filealloc+0x2b>
801009ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801009f0:	83 c3 18             	add    $0x18,%ebx
801009f3:	81 fb 54 b5 10 80    	cmp    $0x8010b554,%ebx
801009f9:	74 25                	je     80100a20 <filealloc+0x50>
    if(f->ref == 0){
801009fb:	8b 43 04             	mov    0x4(%ebx),%eax
801009fe:	85 c0                	test   %eax,%eax
80100a00:	75 ee                	jne    801009f0 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80100a02:	c7 04 24 c0 ab 10 80 	movl   $0x8010abc0,(%esp)
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
      f->ref = 1;
80100a09:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100a10:	e8 1b 28 00 00       	call   80103230 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100a15:	83 c4 14             	add    $0x14,%esp
  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
      f->ref = 1;
      release(&ftable.lock);
      return f;
80100a18:	89 d8                	mov    %ebx,%eax
    }
  }
  release(&ftable.lock);
  return 0;
}
80100a1a:	5b                   	pop    %ebx
80100a1b:	5d                   	pop    %ebp
80100a1c:	c3                   	ret    
80100a1d:	8d 76 00             	lea    0x0(%esi),%esi
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100a20:	c7 04 24 c0 ab 10 80 	movl   $0x8010abc0,(%esp)
80100a27:	e8 04 28 00 00       	call   80103230 <release>
  return 0;
}
80100a2c:	83 c4 14             	add    $0x14,%esp
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
80100a2f:	31 c0                	xor    %eax,%eax
}
80100a31:	5b                   	pop    %ebx
80100a32:	5d                   	pop    %ebp
80100a33:	c3                   	ret    
80100a34:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100a3a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80100a40 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100a40:	55                   	push   %ebp
80100a41:	89 e5                	mov    %esp,%ebp
80100a43:	53                   	push   %ebx
80100a44:	83 ec 14             	sub    $0x14,%esp
80100a47:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100a4a:	c7 04 24 c0 ab 10 80 	movl   $0x8010abc0,(%esp)
80100a51:	e8 ca 26 00 00       	call   80103120 <acquire>
  if(f->ref < 1)
80100a56:	8b 43 04             	mov    0x4(%ebx),%eax
80100a59:	85 c0                	test   %eax,%eax
80100a5b:	7e 1a                	jle    80100a77 <filedup+0x37>
    panic("filedup");
  f->ref++;
80100a5d:	83 c0 01             	add    $0x1,%eax
80100a60:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100a63:	c7 04 24 c0 ab 10 80 	movl   $0x8010abc0,(%esp)
80100a6a:	e8 c1 27 00 00       	call   80103230 <release>
  return f;
}
80100a6f:	83 c4 14             	add    $0x14,%esp
80100a72:	89 d8                	mov    %ebx,%eax
80100a74:	5b                   	pop    %ebx
80100a75:	5d                   	pop    %ebp
80100a76:	c3                   	ret    
struct file*
filedup(struct file *f)
{
  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("filedup");
80100a77:	c7 04 24 94 37 10 80 	movl   $0x80103794,(%esp)
80100a7e:	e8 dd f8 ff ff       	call   80100360 <panic>
80100a83:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100a89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100a90 <fileclose>:
}

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100a90:	55                   	push   %ebp
80100a91:	89 e5                	mov    %esp,%ebp
80100a93:	57                   	push   %edi
80100a94:	56                   	push   %esi
80100a95:	53                   	push   %ebx
80100a96:	83 ec 1c             	sub    $0x1c,%esp
80100a99:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct file ff;

  acquire(&ftable.lock);
80100a9c:	c7 04 24 c0 ab 10 80 	movl   $0x8010abc0,(%esp)
80100aa3:	e8 78 26 00 00       	call   80103120 <acquire>
  if(f->ref < 1)
80100aa8:	8b 57 04             	mov    0x4(%edi),%edx
80100aab:	85 d2                	test   %edx,%edx
80100aad:	0f 8e 89 00 00 00    	jle    80100b3c <fileclose+0xac>
    panic("fileclose");
  if(--f->ref > 0){
80100ab3:	83 ea 01             	sub    $0x1,%edx
80100ab6:	85 d2                	test   %edx,%edx
80100ab8:	89 57 04             	mov    %edx,0x4(%edi)
80100abb:	74 13                	je     80100ad0 <fileclose+0x40>
    release(&ftable.lock);
80100abd:	c7 45 08 c0 ab 10 80 	movl   $0x8010abc0,0x8(%ebp)
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100ac4:	83 c4 1c             	add    $0x1c,%esp
80100ac7:	5b                   	pop    %ebx
80100ac8:	5e                   	pop    %esi
80100ac9:	5f                   	pop    %edi
80100aca:	5d                   	pop    %ebp

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
80100acb:	e9 60 27 00 00       	jmp    80103230 <release>
    return;
  }
  ff = *f;
80100ad0:	0f b6 47 09          	movzbl 0x9(%edi),%eax
80100ad4:	8b 37                	mov    (%edi),%esi
80100ad6:	8b 5f 0c             	mov    0xc(%edi),%ebx
  f->ref = 0;
  f->type = FD_NONE;
80100ad9:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100adf:	88 45 e7             	mov    %al,-0x19(%ebp)
80100ae2:	8b 47 10             	mov    0x10(%edi),%eax
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80100ae5:	c7 04 24 c0 ab 10 80 	movl   $0x8010abc0,(%esp)
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100aec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80100aef:	e8 3c 27 00 00       	call   80103230 <release>

  if(ff.type == FD_PIPE)
80100af4:	83 fe 01             	cmp    $0x1,%esi
80100af7:	74 0f                	je     80100b08 <fileclose+0x78>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100af9:	83 fe 02             	cmp    $0x2,%esi
80100afc:	74 22                	je     80100b20 <fileclose+0x90>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100afe:	83 c4 1c             	add    $0x1c,%esp
80100b01:	5b                   	pop    %ebx
80100b02:	5e                   	pop    %esi
80100b03:	5f                   	pop    %edi
80100b04:	5d                   	pop    %ebp
80100b05:	c3                   	ret    
80100b06:	66 90                	xchg   %ax,%ax
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);

  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
80100b08:	0f be 75 e7          	movsbl -0x19(%ebp),%esi
80100b0c:	89 1c 24             	mov    %ebx,(%esp)
80100b0f:	89 74 24 04          	mov    %esi,0x4(%esp)
80100b13:	e8 e8 1f 00 00       	call   80102b00 <pipeclose>
80100b18:	eb e4                	jmp    80100afe <fileclose+0x6e>
80100b1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  else if(ff.type == FD_INODE){
    begin_op();
80100b20:	e8 8b 1b 00 00       	call   801026b0 <begin_op>
    iput(ff.ip);
80100b25:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100b28:	89 04 24             	mov    %eax,(%esp)
80100b2b:	e8 00 09 00 00       	call   80101430 <iput>
    end_op();
  }
}
80100b30:	83 c4 1c             	add    $0x1c,%esp
80100b33:	5b                   	pop    %ebx
80100b34:	5e                   	pop    %esi
80100b35:	5f                   	pop    %edi
80100b36:	5d                   	pop    %ebp
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
80100b37:	e9 e4 1b 00 00       	jmp    80102720 <end_op>
{
  struct file ff;

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
80100b3c:	c7 04 24 9c 37 10 80 	movl   $0x8010379c,(%esp)
80100b43:	e8 18 f8 ff ff       	call   80100360 <panic>
80100b48:	90                   	nop
80100b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100b50 <filestat>:
}

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100b50:	55                   	push   %ebp
80100b51:	89 e5                	mov    %esp,%ebp
80100b53:	53                   	push   %ebx
80100b54:	83 ec 14             	sub    $0x14,%esp
80100b57:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100b5a:	83 3b 02             	cmpl   $0x2,(%ebx)
80100b5d:	75 31                	jne    80100b90 <filestat+0x40>
    ilock(f->ip);
80100b5f:	8b 43 10             	mov    0x10(%ebx),%eax
80100b62:	89 04 24             	mov    %eax,(%esp)
80100b65:	e8 b6 07 00 00       	call   80101320 <ilock>
    stati(f->ip, st);
80100b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b71:	8b 43 10             	mov    0x10(%ebx),%eax
80100b74:	89 04 24             	mov    %eax,(%esp)
80100b77:	e8 04 0a 00 00       	call   80101580 <stati>
    iunlock(f->ip);
80100b7c:	8b 43 10             	mov    0x10(%ebx),%eax
80100b7f:	89 04 24             	mov    %eax,(%esp)
80100b82:	e8 69 08 00 00       	call   801013f0 <iunlock>
    return 0;
  }
  return -1;
}
80100b87:	83 c4 14             	add    $0x14,%esp
{
  if(f->type == FD_INODE){
    ilock(f->ip);
    stati(f->ip, st);
    iunlock(f->ip);
    return 0;
80100b8a:	31 c0                	xor    %eax,%eax
  }
  return -1;
}
80100b8c:	5b                   	pop    %ebx
80100b8d:	5d                   	pop    %ebp
80100b8e:	c3                   	ret    
80100b8f:	90                   	nop
80100b90:	83 c4 14             	add    $0x14,%esp
    ilock(f->ip);
    stati(f->ip, st);
    iunlock(f->ip);
    return 0;
  }
  return -1;
80100b93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100b98:	5b                   	pop    %ebx
80100b99:	5d                   	pop    %ebp
80100b9a:	c3                   	ret    
80100b9b:	90                   	nop
80100b9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100ba0 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100ba0:	55                   	push   %ebp
80100ba1:	89 e5                	mov    %esp,%ebp
80100ba3:	57                   	push   %edi
80100ba4:	56                   	push   %esi
80100ba5:	53                   	push   %ebx
80100ba6:	83 ec 1c             	sub    $0x1c,%esp
80100ba9:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100bac:	8b 75 0c             	mov    0xc(%ebp),%esi
80100baf:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80100bb2:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100bb6:	74 68                	je     80100c20 <fileread+0x80>
    return -1;
  if(f->type == FD_PIPE)
80100bb8:	8b 03                	mov    (%ebx),%eax
80100bba:	83 f8 01             	cmp    $0x1,%eax
80100bbd:	74 49                	je     80100c08 <fileread+0x68>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100bbf:	83 f8 02             	cmp    $0x2,%eax
80100bc2:	75 63                	jne    80100c27 <fileread+0x87>
    ilock(f->ip);
80100bc4:	8b 43 10             	mov    0x10(%ebx),%eax
80100bc7:	89 04 24             	mov    %eax,(%esp)
80100bca:	e8 51 07 00 00       	call   80101320 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100bcf:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80100bd3:	8b 43 14             	mov    0x14(%ebx),%eax
80100bd6:	89 74 24 04          	mov    %esi,0x4(%esp)
80100bda:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bde:	8b 43 10             	mov    0x10(%ebx),%eax
80100be1:	89 04 24             	mov    %eax,(%esp)
80100be4:	e8 c7 09 00 00       	call   801015b0 <readi>
80100be9:	85 c0                	test   %eax,%eax
80100beb:	89 c6                	mov    %eax,%esi
80100bed:	7e 03                	jle    80100bf2 <fileread+0x52>
      f->off += r;
80100bef:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100bf2:	8b 43 10             	mov    0x10(%ebx),%eax
80100bf5:	89 04 24             	mov    %eax,(%esp)
80100bf8:	e8 f3 07 00 00       	call   801013f0 <iunlock>
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
    ilock(f->ip);
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100bfd:	89 f0                	mov    %esi,%eax
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
80100bff:	83 c4 1c             	add    $0x1c,%esp
80100c02:	5b                   	pop    %ebx
80100c03:	5e                   	pop    %esi
80100c04:	5f                   	pop    %edi
80100c05:	5d                   	pop    %ebp
80100c06:	c3                   	ret    
80100c07:	90                   	nop
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
80100c08:	8b 43 0c             	mov    0xc(%ebx),%eax
80100c0b:	89 45 08             	mov    %eax,0x8(%ebp)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
80100c0e:	83 c4 1c             	add    $0x1c,%esp
80100c11:	5b                   	pop    %ebx
80100c12:	5e                   	pop    %esi
80100c13:	5f                   	pop    %edi
80100c14:	5d                   	pop    %ebp
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
80100c15:	e9 96 20 00 00       	jmp    80102cb0 <piperead>
80100c1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
fileread(struct file *f, char *addr, int n)
{
  int r;

  if(f->readable == 0)
    return -1;
80100c20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c25:	eb d8                	jmp    80100bff <fileread+0x5f>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
80100c27:	c7 04 24 a6 37 10 80 	movl   $0x801037a6,(%esp)
80100c2e:	e8 2d f7 ff ff       	call   80100360 <panic>
80100c33:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100c39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100c40 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100c40:	55                   	push   %ebp
80100c41:	89 e5                	mov    %esp,%ebp
80100c43:	57                   	push   %edi
80100c44:	56                   	push   %esi
80100c45:	53                   	push   %ebx
80100c46:	83 ec 2c             	sub    $0x2c,%esp
80100c49:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c4c:	8b 7d 08             	mov    0x8(%ebp),%edi
80100c4f:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100c52:	8b 45 10             	mov    0x10(%ebp),%eax
  int r;

  if(f->writable == 0)
80100c55:	80 7f 09 00          	cmpb   $0x0,0x9(%edi)

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100c59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int r;

  if(f->writable == 0)
80100c5c:	0f 84 ae 00 00 00    	je     80100d10 <filewrite+0xd0>
    return -1;
  if(f->type == FD_PIPE)
80100c62:	8b 07                	mov    (%edi),%eax
80100c64:	83 f8 01             	cmp    $0x1,%eax
80100c67:	0f 84 c2 00 00 00    	je     80100d2f <filewrite+0xef>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100c6d:	83 f8 02             	cmp    $0x2,%eax
80100c70:	0f 85 d7 00 00 00    	jne    80100d4d <filewrite+0x10d>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80100c76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100c79:	31 db                	xor    %ebx,%ebx
80100c7b:	85 c0                	test   %eax,%eax
80100c7d:	7f 31                	jg     80100cb0 <filewrite+0x70>
80100c7f:	e9 9c 00 00 00       	jmp    80100d20 <filewrite+0xe0>
80100c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
      iunlock(f->ip);
80100c88:	8b 4f 10             	mov    0x10(%edi),%ecx
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80100c8b:	01 47 14             	add    %eax,0x14(%edi)
80100c8e:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
80100c91:	89 0c 24             	mov    %ecx,(%esp)
80100c94:	e8 57 07 00 00       	call   801013f0 <iunlock>
      end_op();
80100c99:	e8 82 1a 00 00       	call   80102720 <end_op>
80100c9e:	8b 45 e0             	mov    -0x20(%ebp),%eax

      if(r < 0)
        break;
      if(r != n1)
80100ca1:	39 f0                	cmp    %esi,%eax
80100ca3:	0f 85 98 00 00 00    	jne    80100d41 <filewrite+0x101>
        panic("short filewrite");
      i += r;
80100ca9:	01 c3                	add    %eax,%ebx
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80100cab:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
80100cae:	7e 70                	jle    80100d20 <filewrite+0xe0>
      int n1 = n - i;
80100cb0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80100cb3:	b8 00 1a 00 00       	mov    $0x1a00,%eax
80100cb8:	29 de                	sub    %ebx,%esi
80100cba:	81 fe 00 1a 00 00    	cmp    $0x1a00,%esi
80100cc0:	0f 4f f0             	cmovg  %eax,%esi
      if(n1 > max)
        n1 = max;

      begin_op();
80100cc3:	e8 e8 19 00 00       	call   801026b0 <begin_op>
      ilock(f->ip);
80100cc8:	8b 47 10             	mov    0x10(%edi),%eax
80100ccb:	89 04 24             	mov    %eax,(%esp)
80100cce:	e8 4d 06 00 00       	call   80101320 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100cd3:	89 74 24 0c          	mov    %esi,0xc(%esp)
80100cd7:	8b 47 14             	mov    0x14(%edi),%eax
80100cda:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cde:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ce1:	01 d8                	add    %ebx,%eax
80100ce3:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ce7:	8b 47 10             	mov    0x10(%edi),%eax
80100cea:	89 04 24             	mov    %eax,(%esp)
80100ced:	e8 be 09 00 00       	call   801016b0 <writei>
80100cf2:	85 c0                	test   %eax,%eax
80100cf4:	7f 92                	jg     80100c88 <filewrite+0x48>
        f->off += r;
      iunlock(f->ip);
80100cf6:	8b 4f 10             	mov    0x10(%edi),%ecx
80100cf9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cfc:	89 0c 24             	mov    %ecx,(%esp)
80100cff:	e8 ec 06 00 00       	call   801013f0 <iunlock>
      end_op();
80100d04:	e8 17 1a 00 00       	call   80102720 <end_op>

      if(r < 0)
80100d09:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d0c:	85 c0                	test   %eax,%eax
80100d0e:	74 91                	je     80100ca1 <filewrite+0x61>
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
}
80100d10:	83 c4 2c             	add    $0x2c,%esp
filewrite(struct file *f, char *addr, int n)
{
  int r;

  if(f->writable == 0)
    return -1;
80100d13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
}
80100d18:	5b                   	pop    %ebx
80100d19:	5e                   	pop    %esi
80100d1a:	5f                   	pop    %edi
80100d1b:	5d                   	pop    %ebp
80100d1c:	c3                   	ret    
80100d1d:	8d 76 00             	lea    0x0(%esi),%esi
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80100d20:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100d23:	89 d8                	mov    %ebx,%eax
80100d25:	75 e9                	jne    80100d10 <filewrite+0xd0>
  }
  panic("filewrite");
}
80100d27:	83 c4 2c             	add    $0x2c,%esp
80100d2a:	5b                   	pop    %ebx
80100d2b:	5e                   	pop    %esi
80100d2c:	5f                   	pop    %edi
80100d2d:	5d                   	pop    %ebp
80100d2e:	c3                   	ret    
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
80100d2f:	8b 47 0c             	mov    0xc(%edi),%eax
80100d32:	89 45 08             	mov    %eax,0x8(%ebp)
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
}
80100d35:	83 c4 2c             	add    $0x2c,%esp
80100d38:	5b                   	pop    %ebx
80100d39:	5e                   	pop    %esi
80100d3a:	5f                   	pop    %edi
80100d3b:	5d                   	pop    %ebp
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
80100d3c:	e9 4f 1e 00 00       	jmp    80102b90 <pipewrite>
      end_op();

      if(r < 0)
        break;
      if(r != n1)
        panic("short filewrite");
80100d41:	c7 04 24 af 37 10 80 	movl   $0x801037af,(%esp)
80100d48:	e8 13 f6 ff ff       	call   80100360 <panic>
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
80100d4d:	c7 04 24 b5 37 10 80 	movl   $0x801037b5,(%esp)
80100d54:	e8 07 f6 ff ff       	call   80100360 <panic>
80100d59:	66 90                	xchg   %ax,%ax
80100d5b:	66 90                	xchg   %ax,%ax
80100d5d:	66 90                	xchg   %ax,%ax
80100d5f:	90                   	nop

80100d60 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80100d60:	55                   	push   %ebp
80100d61:	89 e5                	mov    %esp,%ebp
80100d63:	57                   	push   %edi
80100d64:	56                   	push   %esi
80100d65:	53                   	push   %ebx
80100d66:	83 ec 2c             	sub    $0x2c,%esp
80100d69:	89 45 d8             	mov    %eax,-0x28(%ebp)
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80100d6c:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
80100d71:	85 c0                	test   %eax,%eax
80100d73:	0f 84 8c 00 00 00    	je     80100e05 <balloc+0xa5>
80100d79:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80100d80:	8b 75 dc             	mov    -0x24(%ebp),%esi
80100d83:	89 f0                	mov    %esi,%eax
80100d85:	c1 f8 0c             	sar    $0xc,%eax
80100d88:	03 05 d8 b5 10 80    	add    0x8010b5d8,%eax
80100d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d92:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100d95:	89 04 24             	mov    %eax,(%esp)
80100d98:	e8 33 f3 ff ff       	call   801000d0 <bread>
80100d9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100da0:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
80100da5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80100da8:	31 c0                	xor    %eax,%eax
80100daa:	eb 33                	jmp    80100ddf <balloc+0x7f>
80100dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      m = 1 << (bi % 8);
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80100db0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80100db3:	89 c2                	mov    %eax,%edx

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
      m = 1 << (bi % 8);
80100db5:	89 c1                	mov    %eax,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80100db7:	c1 fa 03             	sar    $0x3,%edx

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
      m = 1 << (bi % 8);
80100dba:	83 e1 07             	and    $0x7,%ecx
80100dbd:	bf 01 00 00 00       	mov    $0x1,%edi
80100dc2:	d3 e7                	shl    %cl,%edi
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80100dc4:	0f b6 5c 13 5c       	movzbl 0x5c(%ebx,%edx,1),%ebx

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
      m = 1 << (bi % 8);
80100dc9:	89 f9                	mov    %edi,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80100dcb:	0f b6 fb             	movzbl %bl,%edi
80100dce:	85 cf                	test   %ecx,%edi
80100dd0:	74 46                	je     80100e18 <balloc+0xb8>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80100dd2:	83 c0 01             	add    $0x1,%eax
80100dd5:	83 c6 01             	add    $0x1,%esi
80100dd8:	3d 00 10 00 00       	cmp    $0x1000,%eax
80100ddd:	74 05                	je     80100de4 <balloc+0x84>
80100ddf:	3b 75 e0             	cmp    -0x20(%ebp),%esi
80100de2:	72 cc                	jb     80100db0 <balloc+0x50>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80100de4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de7:	89 04 24             	mov    %eax,(%esp)
80100dea:	e8 f1 f3 ff ff       	call   801001e0 <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80100def:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
80100df6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100df9:	3b 05 c0 b5 10 80    	cmp    0x8010b5c0,%eax
80100dff:	0f 82 7b ff ff ff    	jb     80100d80 <balloc+0x20>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80100e05:	c7 04 24 bf 37 10 80 	movl   $0x801037bf,(%esp)
80100e0c:	e8 4f f5 ff ff       	call   80100360 <panic>
80100e11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
      m = 1 << (bi % 8);
      if((bp->data[bi/8] & m) == 0){  // Is block free?
        bp->data[bi/8] |= m;  // Mark block in use.
80100e18:	09 d9                	or     %ebx,%ecx
80100e1a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80100e1d:	88 4c 13 5c          	mov    %cl,0x5c(%ebx,%edx,1)
        log_write(bp);
80100e21:	89 1c 24             	mov    %ebx,(%esp)
80100e24:	e8 27 1a 00 00       	call   80102850 <log_write>
        brelse(bp);
80100e29:	89 1c 24             	mov    %ebx,(%esp)
80100e2c:	e8 af f3 ff ff       	call   801001e0 <brelse>
static void
bzero(int dev, int bno)
{
  struct buf *bp;

  bp = bread(dev, bno);
80100e31:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e34:	89 74 24 04          	mov    %esi,0x4(%esp)
80100e38:	89 04 24             	mov    %eax,(%esp)
80100e3b:	e8 90 f2 ff ff       	call   801000d0 <bread>
  memset(bp->data, 0, BSIZE);
80100e40:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80100e47:	00 
80100e48:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100e4f:	00 
static void
bzero(int dev, int bno)
{
  struct buf *bp;

  bp = bread(dev, bno);
80100e50:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100e52:	8d 40 5c             	lea    0x5c(%eax),%eax
80100e55:	89 04 24             	mov    %eax,(%esp)
80100e58:	e8 23 24 00 00       	call   80103280 <memset>
  log_write(bp);
80100e5d:	89 1c 24             	mov    %ebx,(%esp)
80100e60:	e8 eb 19 00 00       	call   80102850 <log_write>
  brelse(bp);
80100e65:	89 1c 24             	mov    %ebx,(%esp)
80100e68:	e8 73 f3 ff ff       	call   801001e0 <brelse>
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
80100e6d:	83 c4 2c             	add    $0x2c,%esp
80100e70:	89 f0                	mov    %esi,%eax
80100e72:	5b                   	pop    %ebx
80100e73:	5e                   	pop    %esi
80100e74:	5f                   	pop    %edi
80100e75:	5d                   	pop    %ebp
80100e76:	c3                   	ret    
80100e77:	89 f6                	mov    %esi,%esi
80100e79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100e80 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80100e80:	55                   	push   %ebp
80100e81:	89 e5                	mov    %esp,%ebp
80100e83:	57                   	push   %edi
80100e84:	89 c7                	mov    %eax,%edi
80100e86:	56                   	push   %esi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
80100e87:	31 f6                	xor    %esi,%esi
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80100e89:	53                   	push   %ebx

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80100e8a:	bb 14 b6 10 80       	mov    $0x8010b614,%ebx
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80100e8f:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80100e92:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80100e99:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  struct inode *ip, *empty;

  acquire(&icache.lock);
80100e9c:	e8 7f 22 00 00       	call   80103120 <acquire>

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80100ea1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80100ea4:	eb 14                	jmp    80100eba <iget+0x3a>
80100ea6:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80100ea8:	85 f6                	test   %esi,%esi
80100eaa:	74 3c                	je     80100ee8 <iget+0x68>

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80100eac:	81 c3 90 00 00 00    	add    $0x90,%ebx
80100eb2:	81 fb 34 d2 10 80    	cmp    $0x8010d234,%ebx
80100eb8:	74 46                	je     80100f00 <iget+0x80>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80100eba:	8b 4b 08             	mov    0x8(%ebx),%ecx
80100ebd:	85 c9                	test   %ecx,%ecx
80100ebf:	7e e7                	jle    80100ea8 <iget+0x28>
80100ec1:	39 3b                	cmp    %edi,(%ebx)
80100ec3:	75 e3                	jne    80100ea8 <iget+0x28>
80100ec5:	39 53 04             	cmp    %edx,0x4(%ebx)
80100ec8:	75 de                	jne    80100ea8 <iget+0x28>
      ip->ref++;
80100eca:	83 c1 01             	add    $0x1,%ecx
      release(&icache.lock);
      return ip;
80100ecd:	89 de                	mov    %ebx,%esi
  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
80100ecf:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
80100ed6:	89 4b 08             	mov    %ecx,0x8(%ebx)
      release(&icache.lock);
80100ed9:	e8 52 23 00 00       	call   80103230 <release>
  ip->ref = 1;
  ip->flags = 0;
  release(&icache.lock);

  return ip;
}
80100ede:	83 c4 1c             	add    $0x1c,%esp
80100ee1:	89 f0                	mov    %esi,%eax
80100ee3:	5b                   	pop    %ebx
80100ee4:	5e                   	pop    %esi
80100ee5:	5f                   	pop    %edi
80100ee6:	5d                   	pop    %ebp
80100ee7:	c3                   	ret    
80100ee8:	85 c9                	test   %ecx,%ecx
80100eea:	0f 44 f3             	cmove  %ebx,%esi

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80100eed:	81 c3 90 00 00 00    	add    $0x90,%ebx
80100ef3:	81 fb 34 d2 10 80    	cmp    $0x8010d234,%ebx
80100ef9:	75 bf                	jne    80100eba <iget+0x3a>
80100efb:	90                   	nop
80100efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80100f00:	85 f6                	test   %esi,%esi
80100f02:	74 29                	je     80100f2d <iget+0xad>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
80100f04:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
80100f06:	89 56 04             	mov    %edx,0x4(%esi)
  ip->ref = 1;
80100f09:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->flags = 0;
80100f10:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
80100f17:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100f1e:	e8 0d 23 00 00       	call   80103230 <release>

  return ip;
}
80100f23:	83 c4 1c             	add    $0x1c,%esp
80100f26:	89 f0                	mov    %esi,%eax
80100f28:	5b                   	pop    %ebx
80100f29:	5e                   	pop    %esi
80100f2a:	5f                   	pop    %edi
80100f2b:	5d                   	pop    %ebp
80100f2c:	c3                   	ret    
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
    panic("iget: no inodes");
80100f2d:	c7 04 24 d5 37 10 80 	movl   $0x801037d5,(%esp)
80100f34:	e8 27 f4 ff ff       	call   80100360 <panic>
80100f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100f40 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80100f40:	55                   	push   %ebp
80100f41:	89 e5                	mov    %esp,%ebp
80100f43:	57                   	push   %edi
80100f44:	56                   	push   %esi
80100f45:	53                   	push   %ebx
80100f46:	89 c3                	mov    %eax,%ebx
80100f48:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80100f4b:	83 fa 0b             	cmp    $0xb,%edx
80100f4e:	77 18                	ja     80100f68 <bmap+0x28>
80100f50:	8d 34 90             	lea    (%eax,%edx,4),%esi
    if((addr = ip->addrs[bn]) == 0)
80100f53:	8b 46 5c             	mov    0x5c(%esi),%eax
80100f56:	85 c0                	test   %eax,%eax
80100f58:	74 66                	je     80100fc0 <bmap+0x80>
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
}
80100f5a:	83 c4 1c             	add    $0x1c,%esp
80100f5d:	5b                   	pop    %ebx
80100f5e:	5e                   	pop    %esi
80100f5f:	5f                   	pop    %edi
80100f60:	5d                   	pop    %ebp
80100f61:	c3                   	ret    
80100f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
80100f68:	8d 72 f4             	lea    -0xc(%edx),%esi

  if(bn < NINDIRECT){
80100f6b:	83 fe 7f             	cmp    $0x7f,%esi
80100f6e:	77 77                	ja     80100fe7 <bmap+0xa7>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80100f70:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80100f76:	85 c0                	test   %eax,%eax
80100f78:	74 5e                	je     80100fd8 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
80100f7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f7e:	8b 03                	mov    (%ebx),%eax
80100f80:	89 04 24             	mov    %eax,(%esp)
80100f83:	e8 48 f1 ff ff       	call   801000d0 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
80100f88:	8d 54 b0 5c          	lea    0x5c(%eax,%esi,4),%edx

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
80100f8c:	89 c7                	mov    %eax,%edi
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
80100f8e:	8b 32                	mov    (%edx),%esi
80100f90:	85 f6                	test   %esi,%esi
80100f92:	75 19                	jne    80100fad <bmap+0x6d>
      a[bn] = addr = balloc(ip->dev);
80100f94:	8b 03                	mov    (%ebx),%eax
80100f96:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80100f99:	e8 c2 fd ff ff       	call   80100d60 <balloc>
80100f9e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80100fa1:	89 02                	mov    %eax,(%edx)
80100fa3:	89 c6                	mov    %eax,%esi
      log_write(bp);
80100fa5:	89 3c 24             	mov    %edi,(%esp)
80100fa8:	e8 a3 18 00 00       	call   80102850 <log_write>
    }
    brelse(bp);
80100fad:	89 3c 24             	mov    %edi,(%esp)
80100fb0:	e8 2b f2 ff ff       	call   801001e0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
80100fb5:	83 c4 1c             	add    $0x1c,%esp
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
80100fb8:	89 f0                	mov    %esi,%eax
    return addr;
  }

  panic("bmap: out of range");
}
80100fba:	5b                   	pop    %ebx
80100fbb:	5e                   	pop    %esi
80100fbc:	5f                   	pop    %edi
80100fbd:	5d                   	pop    %ebp
80100fbe:	c3                   	ret    
80100fbf:	90                   	nop
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
80100fc0:	8b 03                	mov    (%ebx),%eax
80100fc2:	e8 99 fd ff ff       	call   80100d60 <balloc>
80100fc7:	89 46 5c             	mov    %eax,0x5c(%esi)
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
}
80100fca:	83 c4 1c             	add    $0x1c,%esp
80100fcd:	5b                   	pop    %ebx
80100fce:	5e                   	pop    %esi
80100fcf:	5f                   	pop    %edi
80100fd0:	5d                   	pop    %ebp
80100fd1:	c3                   	ret    
80100fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  bn -= NDIRECT;

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80100fd8:	8b 03                	mov    (%ebx),%eax
80100fda:	e8 81 fd ff ff       	call   80100d60 <balloc>
80100fdf:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
80100fe5:	eb 93                	jmp    80100f7a <bmap+0x3a>
    }
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
80100fe7:	c7 04 24 e5 37 10 80 	movl   $0x801037e5,(%esp)
80100fee:	e8 6d f3 ff ff       	call   80100360 <panic>
80100ff3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100ff9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101000 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101000:	55                   	push   %ebp
80101001:	89 e5                	mov    %esp,%ebp
80101003:	56                   	push   %esi
80101004:	53                   	push   %ebx
80101005:	83 ec 10             	sub    $0x10,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101008:	8b 45 08             	mov    0x8(%ebp),%eax
8010100b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101012:	00 
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101013:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct buf *bp;

  bp = bread(dev, 1);
80101016:	89 04 24             	mov    %eax,(%esp)
80101019:	e8 b2 f0 ff ff       	call   801000d0 <bread>
  memmove(sb, bp->data, sizeof(*sb));
8010101e:	89 34 24             	mov    %esi,(%esp)
80101021:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101028:	00 
void
readsb(int dev, struct superblock *sb)
{
  struct buf *bp;

  bp = bread(dev, 1);
80101029:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010102b:	8d 40 5c             	lea    0x5c(%eax),%eax
8010102e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101032:	e8 e9 22 00 00       	call   80103320 <memmove>
  brelse(bp);
80101037:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010103a:	83 c4 10             	add    $0x10,%esp
8010103d:	5b                   	pop    %ebx
8010103e:	5e                   	pop    %esi
8010103f:	5d                   	pop    %ebp
{
  struct buf *bp;

  bp = bread(dev, 1);
  memmove(sb, bp->data, sizeof(*sb));
  brelse(bp);
80101040:	e9 9b f1 ff ff       	jmp    801001e0 <brelse>
80101045:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101049:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101050 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101050:	55                   	push   %ebp
80101051:	89 e5                	mov    %esp,%ebp
80101053:	57                   	push   %edi
80101054:	89 d7                	mov    %edx,%edi
80101056:	56                   	push   %esi
80101057:	53                   	push   %ebx
80101058:	89 c3                	mov    %eax,%ebx
8010105a:	83 ec 1c             	sub    $0x1c,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010105d:	89 04 24             	mov    %eax,(%esp)
80101060:	c7 44 24 04 c0 b5 10 	movl   $0x8010b5c0,0x4(%esp)
80101067:	80 
80101068:	e8 93 ff ff ff       	call   80101000 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
8010106d:	89 fa                	mov    %edi,%edx
8010106f:	c1 ea 0c             	shr    $0xc,%edx
80101072:	03 15 d8 b5 10 80    	add    0x8010b5d8,%edx
80101078:	89 1c 24             	mov    %ebx,(%esp)
  bi = b % BPB;
  m = 1 << (bi % 8);
8010107b:	bb 01 00 00 00       	mov    $0x1,%ebx
{
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb));
80101080:	89 54 24 04          	mov    %edx,0x4(%esp)
80101084:	e8 47 f0 ff ff       	call   801000d0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
80101089:	89 f9                	mov    %edi,%ecx
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb));
  bi = b % BPB;
8010108b:	81 e7 ff 0f 00 00    	and    $0xfff,%edi
80101091:	89 fa                	mov    %edi,%edx
  m = 1 << (bi % 8);
80101093:	83 e1 07             	and    $0x7,%ecx
  if((bp->data[bi/8] & m) == 0)
80101096:	c1 fa 03             	sar    $0x3,%edx
  int bi, m;

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb));
  bi = b % BPB;
  m = 1 << (bi % 8);
80101099:	d3 e3                	shl    %cl,%ebx
{
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb));
8010109b:	89 c6                	mov    %eax,%esi
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
8010109d:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801010a2:	0f b6 c8             	movzbl %al,%ecx
801010a5:	85 d9                	test   %ebx,%ecx
801010a7:	74 20                	je     801010c9 <bfree+0x79>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
801010a9:	f7 d3                	not    %ebx
801010ab:	21 c3                	and    %eax,%ebx
801010ad:	88 5c 16 5c          	mov    %bl,0x5c(%esi,%edx,1)
  log_write(bp);
801010b1:	89 34 24             	mov    %esi,(%esp)
801010b4:	e8 97 17 00 00       	call   80102850 <log_write>
  brelse(bp);
801010b9:	89 34 24             	mov    %esi,(%esp)
801010bc:	e8 1f f1 ff ff       	call   801001e0 <brelse>
}
801010c1:	83 c4 1c             	add    $0x1c,%esp
801010c4:	5b                   	pop    %ebx
801010c5:	5e                   	pop    %esi
801010c6:	5f                   	pop    %edi
801010c7:	5d                   	pop    %ebp
801010c8:	c3                   	ret    
  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb));
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
    panic("freeing free block");
801010c9:	c7 04 24 f8 37 10 80 	movl   $0x801037f8,(%esp)
801010d0:	e8 8b f2 ff ff       	call   80100360 <panic>
801010d5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801010d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801010e0 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801010e0:	55                   	push   %ebp
801010e1:	89 e5                	mov    %esp,%ebp
801010e3:	53                   	push   %ebx
801010e4:	bb 20 b6 10 80       	mov    $0x8010b620,%ebx
801010e9:	83 ec 24             	sub    $0x24,%esp
  int i = 0;
  
  initlock(&icache.lock, "icache");
801010ec:	c7 44 24 04 0b 38 10 	movl   $0x8010380b,0x4(%esp)
801010f3:	80 
801010f4:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801010fb:	e8 a0 1f 00 00       	call   801030a0 <initlock>
  for(i = 0; i < NINODE; i++) {
    initsleeplock(&icache.inode[i].lock, "inode");
80101100:	89 1c 24             	mov    %ebx,(%esp)
80101103:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101109:	c7 44 24 04 12 38 10 	movl   $0x80103812,0x4(%esp)
80101110:	80 
80101111:	e8 7a 1e 00 00       	call   80102f90 <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
80101116:	81 fb 40 d2 10 80    	cmp    $0x8010d240,%ebx
8010111c:	75 e2                	jne    80101100 <iinit+0x20>
    initsleeplock(&icache.inode[i].lock, "inode");
  }
  
  readsb(dev, &sb);
8010111e:	8b 45 08             	mov    0x8(%ebp),%eax
80101121:	c7 44 24 04 c0 b5 10 	movl   $0x8010b5c0,0x4(%esp)
80101128:	80 
80101129:	89 04 24             	mov    %eax,(%esp)
8010112c:	e8 cf fe ff ff       	call   80101000 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101131:	a1 d8 b5 10 80       	mov    0x8010b5d8,%eax
80101136:	c7 04 24 70 38 10 80 	movl   $0x80103870,(%esp)
8010113d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101141:	a1 d4 b5 10 80       	mov    0x8010b5d4,%eax
80101146:	89 44 24 18          	mov    %eax,0x18(%esp)
8010114a:	a1 d0 b5 10 80       	mov    0x8010b5d0,%eax
8010114f:	89 44 24 14          	mov    %eax,0x14(%esp)
80101153:	a1 cc b5 10 80       	mov    0x8010b5cc,%eax
80101158:	89 44 24 10          	mov    %eax,0x10(%esp)
8010115c:	a1 c8 b5 10 80       	mov    0x8010b5c8,%eax
80101161:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101165:	a1 c4 b5 10 80       	mov    0x8010b5c4,%eax
8010116a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010116e:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
80101173:	89 44 24 04          	mov    %eax,0x4(%esp)
80101177:	e8 d4 f4 ff ff       	call   80100650 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010117c:	83 c4 24             	add    $0x24,%esp
8010117f:	5b                   	pop    %ebx
80101180:	5d                   	pop    %ebp
80101181:	c3                   	ret    
80101182:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101189:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101190 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101190:	55                   	push   %ebp
80101191:	89 e5                	mov    %esp,%ebp
80101193:	57                   	push   %edi
80101194:	56                   	push   %esi
80101195:	53                   	push   %ebx
80101196:	83 ec 2c             	sub    $0x2c,%esp
80101199:	8b 45 0c             	mov    0xc(%ebp),%eax
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010119c:	83 3d c8 b5 10 80 01 	cmpl   $0x1,0x8010b5c8
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801011a3:	8b 7d 08             	mov    0x8(%ebp),%edi
801011a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801011a9:	0f 86 a2 00 00 00    	jbe    80101251 <ialloc+0xc1>
801011af:	be 01 00 00 00       	mov    $0x1,%esi
801011b4:	bb 01 00 00 00       	mov    $0x1,%ebx
801011b9:	eb 1a                	jmp    801011d5 <ialloc+0x45>
801011bb:	90                   	nop
801011bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
801011c0:	89 14 24             	mov    %edx,(%esp)
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801011c3:	83 c3 01             	add    $0x1,%ebx
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
801011c6:	e8 15 f0 ff ff       	call   801001e0 <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801011cb:	89 de                	mov    %ebx,%esi
801011cd:	3b 1d c8 b5 10 80    	cmp    0x8010b5c8,%ebx
801011d3:	73 7c                	jae    80101251 <ialloc+0xc1>
    bp = bread(dev, IBLOCK(inum, sb));
801011d5:	89 f0                	mov    %esi,%eax
801011d7:	c1 e8 03             	shr    $0x3,%eax
801011da:	03 05 d4 b5 10 80    	add    0x8010b5d4,%eax
801011e0:	89 3c 24             	mov    %edi,(%esp)
801011e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801011e7:	e8 e4 ee ff ff       	call   801000d0 <bread>
801011ec:	89 c2                	mov    %eax,%edx
    dip = (struct dinode*)bp->data + inum%IPB;
801011ee:	89 f0                	mov    %esi,%eax
801011f0:	83 e0 07             	and    $0x7,%eax
801011f3:	c1 e0 06             	shl    $0x6,%eax
801011f6:	8d 4c 02 5c          	lea    0x5c(%edx,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
801011fa:	66 83 39 00          	cmpw   $0x0,(%ecx)
801011fe:	75 c0                	jne    801011c0 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
80101200:	89 0c 24             	mov    %ecx,(%esp)
80101203:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010120a:	00 
8010120b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101212:	00 
80101213:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101216:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80101219:	e8 62 20 00 00       	call   80103280 <memset>
      dip->type = type;
8010121e:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
      log_write(bp);   // mark it allocated on the disk
80101222:	8b 55 dc             	mov    -0x24(%ebp),%edx
  for(inum = 1; inum < sb.ninodes; inum++){
    bp = bread(dev, IBLOCK(inum, sb));
    dip = (struct dinode*)bp->data + inum%IPB;
    if(dip->type == 0){  // a free inode
      memset(dip, 0, sizeof(*dip));
      dip->type = type;
80101225:	8b 4d e0             	mov    -0x20(%ebp),%ecx
      log_write(bp);   // mark it allocated on the disk
80101228:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
    bp = bread(dev, IBLOCK(inum, sb));
    dip = (struct dinode*)bp->data + inum%IPB;
    if(dip->type == 0){  // a free inode
      memset(dip, 0, sizeof(*dip));
      dip->type = type;
8010122b:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
8010122e:	89 14 24             	mov    %edx,(%esp)
80101231:	e8 1a 16 00 00       	call   80102850 <log_write>
      brelse(bp);
80101236:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101239:	89 14 24             	mov    %edx,(%esp)
8010123c:	e8 9f ef ff ff       	call   801001e0 <brelse>
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101241:	83 c4 2c             	add    $0x2c,%esp
    if(dip->type == 0){  // a free inode
      memset(dip, 0, sizeof(*dip));
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
80101244:	89 f2                	mov    %esi,%edx
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101246:	5b                   	pop    %ebx
    if(dip->type == 0){  // a free inode
      memset(dip, 0, sizeof(*dip));
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
80101247:	89 f8                	mov    %edi,%eax
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101249:	5e                   	pop    %esi
8010124a:	5f                   	pop    %edi
8010124b:	5d                   	pop    %ebp
    if(dip->type == 0){  // a free inode
      memset(dip, 0, sizeof(*dip));
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
8010124c:	e9 2f fc ff ff       	jmp    80100e80 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101251:	c7 04 24 18 38 10 80 	movl   $0x80103818,(%esp)
80101258:	e8 03 f1 ff ff       	call   80100360 <panic>
8010125d:	8d 76 00             	lea    0x0(%esi),%esi

80101260 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101260:	55                   	push   %ebp
80101261:	89 e5                	mov    %esp,%ebp
80101263:	56                   	push   %esi
80101264:	53                   	push   %ebx
80101265:	83 ec 10             	sub    $0x10,%esp
80101268:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010126b:	8b 43 04             	mov    0x4(%ebx),%eax
  dip->type = ip->type;
  dip->major = ip->major;
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010126e:	83 c3 5c             	add    $0x5c,%ebx
iupdate(struct inode *ip)
{
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101271:	c1 e8 03             	shr    $0x3,%eax
80101274:	03 05 d4 b5 10 80    	add    0x8010b5d4,%eax
8010127a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010127e:	8b 43 a4             	mov    -0x5c(%ebx),%eax
80101281:	89 04 24             	mov    %eax,(%esp)
80101284:	e8 47 ee ff ff       	call   801000d0 <bread>
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101289:	8b 53 a8             	mov    -0x58(%ebx),%edx
8010128c:	83 e2 07             	and    $0x7,%edx
8010128f:	c1 e2 06             	shl    $0x6,%edx
80101292:	8d 54 10 5c          	lea    0x5c(%eax,%edx,1),%edx
iupdate(struct inode *ip)
{
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101296:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
80101298:	0f b7 43 f4          	movzwl -0xc(%ebx),%eax
  dip->major = ip->major;
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010129c:	83 c2 0c             	add    $0xc,%edx
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
8010129f:	66 89 42 f4          	mov    %ax,-0xc(%edx)
  dip->major = ip->major;
801012a3:	0f b7 43 f6          	movzwl -0xa(%ebx),%eax
801012a7:	66 89 42 f6          	mov    %ax,-0xa(%edx)
  dip->minor = ip->minor;
801012ab:	0f b7 43 f8          	movzwl -0x8(%ebx),%eax
801012af:	66 89 42 f8          	mov    %ax,-0x8(%edx)
  dip->nlink = ip->nlink;
801012b3:	0f b7 43 fa          	movzwl -0x6(%ebx),%eax
801012b7:	66 89 42 fa          	mov    %ax,-0x6(%edx)
  dip->size = ip->size;
801012bb:	8b 43 fc             	mov    -0x4(%ebx),%eax
801012be:	89 42 fc             	mov    %eax,-0x4(%edx)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801012c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801012c5:	89 14 24             	mov    %edx,(%esp)
801012c8:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801012cf:	00 
801012d0:	e8 4b 20 00 00       	call   80103320 <memmove>
  log_write(bp);
801012d5:	89 34 24             	mov    %esi,(%esp)
801012d8:	e8 73 15 00 00       	call   80102850 <log_write>
  brelse(bp);
801012dd:	89 75 08             	mov    %esi,0x8(%ebp)
}
801012e0:	83 c4 10             	add    $0x10,%esp
801012e3:	5b                   	pop    %ebx
801012e4:	5e                   	pop    %esi
801012e5:	5d                   	pop    %ebp
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  log_write(bp);
  brelse(bp);
801012e6:	e9 f5 ee ff ff       	jmp    801001e0 <brelse>
801012eb:	90                   	nop
801012ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801012f0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801012f0:	55                   	push   %ebp
801012f1:	89 e5                	mov    %esp,%ebp
801012f3:	53                   	push   %ebx
801012f4:	83 ec 14             	sub    $0x14,%esp
801012f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
801012fa:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80101301:	e8 1a 1e 00 00       	call   80103120 <acquire>
  ip->ref++;
80101306:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
8010130a:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80101311:	e8 1a 1f 00 00       	call   80103230 <release>
  return ip;
}
80101316:	83 c4 14             	add    $0x14,%esp
80101319:	89 d8                	mov    %ebx,%eax
8010131b:	5b                   	pop    %ebx
8010131c:	5d                   	pop    %ebp
8010131d:	c3                   	ret    
8010131e:	66 90                	xchg   %ax,%ax

80101320 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101320:	55                   	push   %ebp
80101321:	89 e5                	mov    %esp,%ebp
80101323:	56                   	push   %esi
80101324:	53                   	push   %ebx
80101325:	83 ec 10             	sub    $0x10,%esp
80101328:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010132b:	85 db                	test   %ebx,%ebx
8010132d:	0f 84 b0 00 00 00    	je     801013e3 <ilock+0xc3>
80101333:	8b 43 08             	mov    0x8(%ebx),%eax
80101336:	85 c0                	test   %eax,%eax
80101338:	0f 8e a5 00 00 00    	jle    801013e3 <ilock+0xc3>
    panic("ilock");

  acquiresleep(&ip->lock);
8010133e:	8d 43 0c             	lea    0xc(%ebx),%eax
80101341:	89 04 24             	mov    %eax,(%esp)
80101344:	e8 87 1c 00 00       	call   80102fd0 <acquiresleep>

  if(!(ip->flags & I_VALID)){
80101349:	f6 43 4c 02          	testb  $0x2,0x4c(%ebx)
8010134d:	74 09                	je     80101358 <ilock+0x38>
    brelse(bp);
    ip->flags |= I_VALID;
    if(ip->type == 0)
      panic("ilock: no type");
  }
}
8010134f:	83 c4 10             	add    $0x10,%esp
80101352:	5b                   	pop    %ebx
80101353:	5e                   	pop    %esi
80101354:	5d                   	pop    %ebp
80101355:	c3                   	ret    
80101356:	66 90                	xchg   %ax,%ax
    panic("ilock");

  acquiresleep(&ip->lock);

  if(!(ip->flags & I_VALID)){
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101358:	8b 43 04             	mov    0x4(%ebx),%eax
8010135b:	c1 e8 03             	shr    $0x3,%eax
8010135e:	03 05 d4 b5 10 80    	add    0x8010b5d4,%eax
80101364:	89 44 24 04          	mov    %eax,0x4(%esp)
80101368:	8b 03                	mov    (%ebx),%eax
8010136a:	89 04 24             	mov    %eax,(%esp)
8010136d:	e8 5e ed ff ff       	call   801000d0 <bread>
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101372:	8b 53 04             	mov    0x4(%ebx),%edx
80101375:	83 e2 07             	and    $0x7,%edx
80101378:	c1 e2 06             	shl    $0x6,%edx
8010137b:	8d 54 10 5c          	lea    0x5c(%eax,%edx,1),%edx
    panic("ilock");

  acquiresleep(&ip->lock);

  if(!(ip->flags & I_VALID)){
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010137f:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    ip->type = dip->type;
80101381:	0f b7 02             	movzwl (%edx),%eax
    ip->major = dip->major;
    ip->minor = dip->minor;
    ip->nlink = dip->nlink;
    ip->size = dip->size;
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101384:	83 c2 0c             	add    $0xc,%edx
  acquiresleep(&ip->lock);

  if(!(ip->flags & I_VALID)){
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    ip->type = dip->type;
80101387:	66 89 43 50          	mov    %ax,0x50(%ebx)
    ip->major = dip->major;
8010138b:	0f b7 42 f6          	movzwl -0xa(%edx),%eax
8010138f:	66 89 43 52          	mov    %ax,0x52(%ebx)
    ip->minor = dip->minor;
80101393:	0f b7 42 f8          	movzwl -0x8(%edx),%eax
80101397:	66 89 43 54          	mov    %ax,0x54(%ebx)
    ip->nlink = dip->nlink;
8010139b:	0f b7 42 fa          	movzwl -0x6(%edx),%eax
8010139f:	66 89 43 56          	mov    %ax,0x56(%ebx)
    ip->size = dip->size;
801013a3:	8b 42 fc             	mov    -0x4(%edx),%eax
801013a6:	89 43 58             	mov    %eax,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801013a9:	8d 43 5c             	lea    0x5c(%ebx),%eax
801013ac:	89 54 24 04          	mov    %edx,0x4(%esp)
801013b0:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801013b7:	00 
801013b8:	89 04 24             	mov    %eax,(%esp)
801013bb:	e8 60 1f 00 00       	call   80103320 <memmove>
    brelse(bp);
801013c0:	89 34 24             	mov    %esi,(%esp)
801013c3:	e8 18 ee ff ff       	call   801001e0 <brelse>
    ip->flags |= I_VALID;
801013c8:	83 4b 4c 02          	orl    $0x2,0x4c(%ebx)
    if(ip->type == 0)
801013cc:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
801013d1:	0f 85 78 ff ff ff    	jne    8010134f <ilock+0x2f>
      panic("ilock: no type");
801013d7:	c7 04 24 30 38 10 80 	movl   $0x80103830,(%esp)
801013de:	e8 7d ef ff ff       	call   80100360 <panic>
{
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
    panic("ilock");
801013e3:	c7 04 24 2a 38 10 80 	movl   $0x8010382a,(%esp)
801013ea:	e8 71 ef ff ff       	call   80100360 <panic>
801013ef:	90                   	nop

801013f0 <iunlock>:
}

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801013f0:	55                   	push   %ebp
801013f1:	89 e5                	mov    %esp,%ebp
801013f3:	56                   	push   %esi
801013f4:	53                   	push   %ebx
801013f5:	83 ec 10             	sub    $0x10,%esp
801013f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801013fb:	85 db                	test   %ebx,%ebx
801013fd:	74 24                	je     80101423 <iunlock+0x33>
801013ff:	8d 73 0c             	lea    0xc(%ebx),%esi
80101402:	89 34 24             	mov    %esi,(%esp)
80101405:	e8 66 1c 00 00       	call   80103070 <holdingsleep>
8010140a:	85 c0                	test   %eax,%eax
8010140c:	74 15                	je     80101423 <iunlock+0x33>
8010140e:	8b 43 08             	mov    0x8(%ebx),%eax
80101411:	85 c0                	test   %eax,%eax
80101413:	7e 0e                	jle    80101423 <iunlock+0x33>
    panic("iunlock");

  releasesleep(&ip->lock);
80101415:	89 75 08             	mov    %esi,0x8(%ebp)
}
80101418:	83 c4 10             	add    $0x10,%esp
8010141b:	5b                   	pop    %ebx
8010141c:	5e                   	pop    %esi
8010141d:	5d                   	pop    %ebp
iunlock(struct inode *ip)
{
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    panic("iunlock");

  releasesleep(&ip->lock);
8010141e:	e9 0d 1c 00 00       	jmp    80103030 <releasesleep>
// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    panic("iunlock");
80101423:	c7 04 24 3f 38 10 80 	movl   $0x8010383f,(%esp)
8010142a:	e8 31 ef ff ff       	call   80100360 <panic>
8010142f:	90                   	nop

80101430 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101430:	55                   	push   %ebp
80101431:	89 e5                	mov    %esp,%ebp
80101433:	57                   	push   %edi
80101434:	56                   	push   %esi
80101435:	53                   	push   %ebx
80101436:	83 ec 1c             	sub    $0x1c,%esp
80101439:	8b 75 08             	mov    0x8(%ebp),%esi
  acquire(&icache.lock);
8010143c:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80101443:	e8 d8 1c 00 00       	call   80103120 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101448:	8b 46 08             	mov    0x8(%esi),%eax
8010144b:	83 f8 01             	cmp    $0x1,%eax
8010144e:	74 20                	je     80101470 <iput+0x40>
    ip->type = 0;
    iupdate(ip);
    acquire(&icache.lock);
    ip->flags = 0;
  }
  ip->ref--;
80101450:	83 e8 01             	sub    $0x1,%eax
80101453:	89 46 08             	mov    %eax,0x8(%esi)
  release(&icache.lock);
80101456:	c7 45 08 e0 b5 10 80 	movl   $0x8010b5e0,0x8(%ebp)
}
8010145d:	83 c4 1c             	add    $0x1c,%esp
80101460:	5b                   	pop    %ebx
80101461:	5e                   	pop    %esi
80101462:	5f                   	pop    %edi
80101463:	5d                   	pop    %ebp
    iupdate(ip);
    acquire(&icache.lock);
    ip->flags = 0;
  }
  ip->ref--;
  release(&icache.lock);
80101464:	e9 c7 1d 00 00       	jmp    80103230 <release>
80101469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
// case it has to free the inode.
void
iput(struct inode *ip)
{
  acquire(&icache.lock);
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101470:	f6 46 4c 02          	testb  $0x2,0x4c(%esi)
80101474:	74 da                	je     80101450 <iput+0x20>
80101476:	66 83 7e 56 00       	cmpw   $0x0,0x56(%esi)
8010147b:	75 d3                	jne    80101450 <iput+0x20>
    // inode has no links and no other references: truncate and free.
    release(&icache.lock);
8010147d:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80101484:	89 f3                	mov    %esi,%ebx
80101486:	e8 a5 1d 00 00       	call   80103230 <release>
8010148b:	8d 7e 30             	lea    0x30(%esi),%edi
8010148e:	eb 07                	jmp    80101497 <iput+0x67>
80101490:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101493:	39 fb                	cmp    %edi,%ebx
80101495:	74 19                	je     801014b0 <iput+0x80>
    if(ip->addrs[i]){
80101497:	8b 53 5c             	mov    0x5c(%ebx),%edx
8010149a:	85 d2                	test   %edx,%edx
8010149c:	74 f2                	je     80101490 <iput+0x60>
      bfree(ip->dev, ip->addrs[i]);
8010149e:	8b 06                	mov    (%esi),%eax
801014a0:	e8 ab fb ff ff       	call   80101050 <bfree>
      ip->addrs[i] = 0;
801014a5:	c7 43 5c 00 00 00 00 	movl   $0x0,0x5c(%ebx)
801014ac:	eb e2                	jmp    80101490 <iput+0x60>
801014ae:	66 90                	xchg   %ax,%ax
    }
  }

  if(ip->addrs[NDIRECT]){
801014b0:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
801014b6:	85 c0                	test   %eax,%eax
801014b8:	75 3e                	jne    801014f8 <iput+0xc8>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
801014ba:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
801014c1:	89 34 24             	mov    %esi,(%esp)
801014c4:	e8 97 fd ff ff       	call   80101260 <iupdate>
  acquire(&icache.lock);
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
    // inode has no links and no other references: truncate and free.
    release(&icache.lock);
    itrunc(ip);
    ip->type = 0;
801014c9:	31 c0                	xor    %eax,%eax
801014cb:	66 89 46 50          	mov    %ax,0x50(%esi)
    iupdate(ip);
801014cf:	89 34 24             	mov    %esi,(%esp)
801014d2:	e8 89 fd ff ff       	call   80101260 <iupdate>
    acquire(&icache.lock);
801014d7:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801014de:	e8 3d 1c 00 00       	call   80103120 <acquire>
801014e3:	8b 46 08             	mov    0x8(%esi),%eax
    ip->flags = 0;
801014e6:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
801014ed:	e9 5e ff ff ff       	jmp    80101450 <iput+0x20>
801014f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801014f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801014fc:	8b 06                	mov    (%esi),%eax
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
801014fe:	31 db                	xor    %ebx,%ebx
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101500:	89 04 24             	mov    %eax,(%esp)
80101503:	e8 c8 eb ff ff       	call   801000d0 <bread>
80101508:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
8010150b:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
8010150e:	31 c0                	xor    %eax,%eax
80101510:	eb 13                	jmp    80101525 <iput+0xf5>
80101512:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101518:	83 c3 01             	add    $0x1,%ebx
8010151b:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
80101521:	89 d8                	mov    %ebx,%eax
80101523:	74 10                	je     80101535 <iput+0x105>
      if(a[j])
80101525:	8b 14 87             	mov    (%edi,%eax,4),%edx
80101528:	85 d2                	test   %edx,%edx
8010152a:	74 ec                	je     80101518 <iput+0xe8>
        bfree(ip->dev, a[j]);
8010152c:	8b 06                	mov    (%esi),%eax
8010152e:	e8 1d fb ff ff       	call   80101050 <bfree>
80101533:	eb e3                	jmp    80101518 <iput+0xe8>
    }
    brelse(bp);
80101535:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101538:	89 04 24             	mov    %eax,(%esp)
8010153b:	e8 a0 ec ff ff       	call   801001e0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101540:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
80101546:	8b 06                	mov    (%esi),%eax
80101548:	e8 03 fb ff ff       	call   80101050 <bfree>
    ip->addrs[NDIRECT] = 0;
8010154d:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
80101554:	00 00 00 
80101557:	e9 5e ff ff ff       	jmp    801014ba <iput+0x8a>
8010155c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101560 <iunlockput>:
}

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101560:	55                   	push   %ebp
80101561:	89 e5                	mov    %esp,%ebp
80101563:	53                   	push   %ebx
80101564:	83 ec 14             	sub    $0x14,%esp
80101567:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
8010156a:	89 1c 24             	mov    %ebx,(%esp)
8010156d:	e8 7e fe ff ff       	call   801013f0 <iunlock>
  iput(ip);
80101572:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80101575:	83 c4 14             	add    $0x14,%esp
80101578:	5b                   	pop    %ebx
80101579:	5d                   	pop    %ebp
// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
  iput(ip);
8010157a:	e9 b1 fe ff ff       	jmp    80101430 <iput>
8010157f:	90                   	nop

80101580 <stati>:
}

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101580:	55                   	push   %ebp
80101581:	89 e5                	mov    %esp,%ebp
80101583:	8b 55 08             	mov    0x8(%ebp),%edx
80101586:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101589:	8b 0a                	mov    (%edx),%ecx
8010158b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
8010158e:	8b 4a 04             	mov    0x4(%edx),%ecx
80101591:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101594:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101598:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
8010159b:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
8010159f:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
801015a3:	8b 52 58             	mov    0x58(%edx),%edx
801015a6:	89 50 10             	mov    %edx,0x10(%eax)
}
801015a9:	5d                   	pop    %ebp
801015aa:	c3                   	ret    
801015ab:	90                   	nop
801015ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801015b0 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801015b0:	55                   	push   %ebp
801015b1:	89 e5                	mov    %esp,%ebp
801015b3:	57                   	push   %edi
801015b4:	56                   	push   %esi
801015b5:	53                   	push   %ebx
801015b6:	83 ec 2c             	sub    $0x2c,%esp
801015b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801015bc:	8b 7d 08             	mov    0x8(%ebp),%edi
801015bf:	8b 75 10             	mov    0x10(%ebp),%esi
801015c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
801015c5:	8b 45 14             	mov    0x14(%ebp),%eax
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801015c8:	66 83 7f 50 03       	cmpw   $0x3,0x50(%edi)

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801015cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801015d0:	0f 84 aa 00 00 00    	je     80101680 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
801015d6:	8b 47 58             	mov    0x58(%edi),%eax
801015d9:	39 f0                	cmp    %esi,%eax
801015db:	0f 82 c7 00 00 00    	jb     801016a8 <readi+0xf8>
801015e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801015e4:	89 da                	mov    %ebx,%edx
801015e6:	01 f2                	add    %esi,%edx
801015e8:	0f 82 ba 00 00 00    	jb     801016a8 <readi+0xf8>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
801015ee:	89 c1                	mov    %eax,%ecx
801015f0:	29 f1                	sub    %esi,%ecx
801015f2:	39 d0                	cmp    %edx,%eax
801015f4:	0f 43 cb             	cmovae %ebx,%ecx

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801015f7:	31 c0                	xor    %eax,%eax
801015f9:	85 c9                	test   %ecx,%ecx
  }

  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
801015fb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801015fe:	74 70                	je     80101670 <readi+0xc0>
80101600:	89 7d d8             	mov    %edi,-0x28(%ebp)
80101603:	89 c7                	mov    %eax,%edi
80101605:	8d 76 00             	lea    0x0(%esi),%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101608:	8b 5d d8             	mov    -0x28(%ebp),%ebx
8010160b:	89 f2                	mov    %esi,%edx
8010160d:	c1 ea 09             	shr    $0x9,%edx
80101610:	89 d8                	mov    %ebx,%eax
80101612:	e8 29 f9 ff ff       	call   80100f40 <bmap>
80101617:	89 44 24 04          	mov    %eax,0x4(%esp)
8010161b:	8b 03                	mov    (%ebx),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
8010161d:	bb 00 02 00 00       	mov    $0x200,%ebx
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101622:	89 04 24             	mov    %eax,(%esp)
80101625:	e8 a6 ea ff ff       	call   801000d0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
8010162a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010162d:	29 f9                	sub    %edi,%ecx
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010162f:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101631:	89 f0                	mov    %esi,%eax
80101633:	25 ff 01 00 00       	and    $0x1ff,%eax
80101638:	29 c3                	sub    %eax,%ebx
    for (int j = 0; j < min(m, 10); j++) {
      cprintf("%x ", bp->data[off%BSIZE+j]);
    }
    cprintf("\n");
    */
    memmove(dst, bp->data + off%BSIZE, m);
8010163a:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
8010163e:	39 cb                	cmp    %ecx,%ebx
    for (int j = 0; j < min(m, 10); j++) {
      cprintf("%x ", bp->data[off%BSIZE+j]);
    }
    cprintf("\n");
    */
    memmove(dst, bp->data + off%BSIZE, m);
80101640:	89 44 24 04          	mov    %eax,0x4(%esp)
80101644:	8b 45 e0             	mov    -0x20(%ebp),%eax
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
80101647:	0f 47 d9             	cmova  %ecx,%ebx
    for (int j = 0; j < min(m, 10); j++) {
      cprintf("%x ", bp->data[off%BSIZE+j]);
    }
    cprintf("\n");
    */
    memmove(dst, bp->data + off%BSIZE, m);
8010164a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010164e:	01 df                	add    %ebx,%edi
80101650:	01 de                	add    %ebx,%esi
    for (int j = 0; j < min(m, 10); j++) {
      cprintf("%x ", bp->data[off%BSIZE+j]);
    }
    cprintf("\n");
    */
    memmove(dst, bp->data + off%BSIZE, m);
80101652:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101655:	89 04 24             	mov    %eax,(%esp)
80101658:	e8 c3 1c 00 00       	call   80103320 <memmove>
    brelse(bp);
8010165d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101660:	89 14 24             	mov    %edx,(%esp)
80101663:	e8 78 eb ff ff       	call   801001e0 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101668:	01 5d e0             	add    %ebx,-0x20(%ebp)
8010166b:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
8010166e:	77 98                	ja     80101608 <readi+0x58>
    cprintf("\n");
    */
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101670:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80101673:	83 c4 2c             	add    $0x2c,%esp
80101676:	5b                   	pop    %ebx
80101677:	5e                   	pop    %esi
80101678:	5f                   	pop    %edi
80101679:	5d                   	pop    %ebp
8010167a:	c3                   	ret    
8010167b:	90                   	nop
8010167c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101680:	0f bf 47 52          	movswl 0x52(%edi),%eax
80101684:	66 83 f8 09          	cmp    $0x9,%ax
80101688:	77 1e                	ja     801016a8 <readi+0xf8>
8010168a:	8b 04 c5 60 b5 10 80 	mov    -0x7fef4aa0(,%eax,8),%eax
80101691:	85 c0                	test   %eax,%eax
80101693:	74 13                	je     801016a8 <readi+0xf8>
      return -1;
    return devsw[ip->major].read(ip, dst, n);
80101695:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80101698:	89 75 10             	mov    %esi,0x10(%ebp)
    */
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
}
8010169b:	83 c4 2c             	add    $0x2c,%esp
8010169e:	5b                   	pop    %ebx
8010169f:	5e                   	pop    %esi
801016a0:	5f                   	pop    %edi
801016a1:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
801016a2:	ff e0                	jmp    *%eax
801016a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
801016a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801016ad:	eb c4                	jmp    80101673 <readi+0xc3>
801016af:	90                   	nop

801016b0 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801016b0:	55                   	push   %ebp
801016b1:	89 e5                	mov    %esp,%ebp
801016b3:	57                   	push   %edi
801016b4:	56                   	push   %esi
801016b5:	53                   	push   %ebx
801016b6:	83 ec 2c             	sub    $0x2c,%esp
801016b9:	8b 45 08             	mov    0x8(%ebp),%eax
801016bc:	8b 75 0c             	mov    0xc(%ebp),%esi
801016bf:	8b 4d 14             	mov    0x14(%ebp),%ecx
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801016c2:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801016c7:	89 75 dc             	mov    %esi,-0x24(%ebp)
801016ca:	8b 75 10             	mov    0x10(%ebp),%esi
801016cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
801016d0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801016d3:	0f 84 b7 00 00 00    	je     80101790 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
801016d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801016dc:	39 70 58             	cmp    %esi,0x58(%eax)
801016df:	0f 82 e3 00 00 00    	jb     801017c8 <writei+0x118>
801016e5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
801016e8:	89 c8                	mov    %ecx,%eax
801016ea:	01 f0                	add    %esi,%eax
801016ec:	0f 82 d6 00 00 00    	jb     801017c8 <writei+0x118>
    return -1;
  if(off + n > MAXFILE*BSIZE)
801016f2:	3d 00 18 01 00       	cmp    $0x11800,%eax
801016f7:	0f 87 cb 00 00 00    	ja     801017c8 <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801016fd:	85 c9                	test   %ecx,%ecx
801016ff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101706:	74 77                	je     8010177f <writei+0xcf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101708:	8b 7d d8             	mov    -0x28(%ebp),%edi
8010170b:	89 f2                	mov    %esi,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
8010170d:	bb 00 02 00 00       	mov    $0x200,%ebx
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101712:	c1 ea 09             	shr    $0x9,%edx
80101715:	89 f8                	mov    %edi,%eax
80101717:	e8 24 f8 ff ff       	call   80100f40 <bmap>
8010171c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101720:	8b 07                	mov    (%edi),%eax
80101722:	89 04 24             	mov    %eax,(%esp)
80101725:	e8 a6 e9 ff ff       	call   801000d0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
8010172a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
8010172d:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101730:	8b 55 dc             	mov    -0x24(%ebp),%edx
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101733:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101735:	89 f0                	mov    %esi,%eax
80101737:	25 ff 01 00 00       	and    $0x1ff,%eax
8010173c:	29 c3                	sub    %eax,%ebx
8010173e:	39 cb                	cmp    %ecx,%ebx
80101740:	0f 47 d9             	cmova  %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101743:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101747:	01 de                	add    %ebx,%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(bp->data + off%BSIZE, src, m);
80101749:	89 54 24 04          	mov    %edx,0x4(%esp)
8010174d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80101751:	89 04 24             	mov    %eax,(%esp)
80101754:	e8 c7 1b 00 00       	call   80103320 <memmove>
    log_write(bp);
80101759:	89 3c 24             	mov    %edi,(%esp)
8010175c:	e8 ef 10 00 00       	call   80102850 <log_write>
    brelse(bp);
80101761:	89 3c 24             	mov    %edi,(%esp)
80101764:	e8 77 ea ff ff       	call   801001e0 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101769:	01 5d e4             	add    %ebx,-0x1c(%ebp)
8010176c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010176f:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101772:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80101775:	77 91                	ja     80101708 <writei+0x58>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80101777:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010177a:	39 70 58             	cmp    %esi,0x58(%eax)
8010177d:	72 39                	jb     801017b8 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
8010177f:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101782:	83 c4 2c             	add    $0x2c,%esp
80101785:	5b                   	pop    %ebx
80101786:	5e                   	pop    %esi
80101787:	5f                   	pop    %edi
80101788:	5d                   	pop    %ebp
80101789:	c3                   	ret    
8010178a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101790:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101794:	66 83 f8 09          	cmp    $0x9,%ax
80101798:	77 2e                	ja     801017c8 <writei+0x118>
8010179a:	8b 04 c5 64 b5 10 80 	mov    -0x7fef4a9c(,%eax,8),%eax
801017a1:	85 c0                	test   %eax,%eax
801017a3:	74 23                	je     801017c8 <writei+0x118>
      return -1;
    return devsw[ip->major].write(ip, src, n);
801017a5:	89 4d 10             	mov    %ecx,0x10(%ebp)
  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
}
801017a8:	83 c4 2c             	add    $0x2c,%esp
801017ab:	5b                   	pop    %ebx
801017ac:	5e                   	pop    %esi
801017ad:	5f                   	pop    %edi
801017ae:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
801017af:	ff e0                	jmp    *%eax
801017b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
    ip->size = off;
801017b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801017bb:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
801017be:	89 04 24             	mov    %eax,(%esp)
801017c1:	e8 9a fa ff ff       	call   80101260 <iupdate>
801017c6:	eb b7                	jmp    8010177f <writei+0xcf>
  }
  return n;
}
801017c8:	83 c4 2c             	add    $0x2c,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
801017cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
}
801017d0:	5b                   	pop    %ebx
801017d1:	5e                   	pop    %esi
801017d2:	5f                   	pop    %edi
801017d3:	5d                   	pop    %ebp
801017d4:	c3                   	ret    
801017d5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801017d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801017e0 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801017e0:	55                   	push   %ebp
801017e1:	89 e5                	mov    %esp,%ebp
801017e3:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801017e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801017e9:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801017f0:	00 
801017f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801017f5:	8b 45 08             	mov    0x8(%ebp),%eax
801017f8:	89 04 24             	mov    %eax,(%esp)
801017fb:	e8 90 1b 00 00       	call   80103390 <strncmp>
}
80101800:	c9                   	leave  
80101801:	c3                   	ret    
80101802:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101809:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101810 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101810:	55                   	push   %ebp
80101811:	89 e5                	mov    %esp,%ebp
80101813:	57                   	push   %edi
80101814:	56                   	push   %esi
80101815:	53                   	push   %ebx
80101816:	83 ec 2c             	sub    $0x2c,%esp
80101819:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010181c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101821:	0f 85 97 00 00 00    	jne    801018be <dirlookup+0xae>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101827:	8b 53 58             	mov    0x58(%ebx),%edx
8010182a:	31 ff                	xor    %edi,%edi
8010182c:	8d 75 d8             	lea    -0x28(%ebp),%esi
8010182f:	85 d2                	test   %edx,%edx
80101831:	75 0d                	jne    80101840 <dirlookup+0x30>
80101833:	eb 73                	jmp    801018a8 <dirlookup+0x98>
80101835:	8d 76 00             	lea    0x0(%esi),%esi
80101838:	83 c7 10             	add    $0x10,%edi
8010183b:	39 7b 58             	cmp    %edi,0x58(%ebx)
8010183e:	76 68                	jbe    801018a8 <dirlookup+0x98>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101840:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80101847:	00 
80101848:	89 7c 24 08          	mov    %edi,0x8(%esp)
8010184c:	89 74 24 04          	mov    %esi,0x4(%esp)
80101850:	89 1c 24             	mov    %ebx,(%esp)
80101853:	e8 58 fd ff ff       	call   801015b0 <readi>
80101858:	83 f8 10             	cmp    $0x10,%eax
8010185b:	75 55                	jne    801018b2 <dirlookup+0xa2>
      panic("dirlink read");
    if(de.inum == 0)
8010185d:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101862:	74 d4                	je     80101838 <dirlookup+0x28>
// Directories

int
namecmp(const char *s, const char *t)
{
  return strncmp(s, t, DIRSIZ);
80101864:	8d 45 da             	lea    -0x26(%ebp),%eax
80101867:	89 44 24 04          	mov    %eax,0x4(%esp)
8010186b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010186e:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80101875:	00 
80101876:	89 04 24             	mov    %eax,(%esp)
80101879:	e8 12 1b 00 00       	call   80103390 <strncmp>
  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
8010187e:	85 c0                	test   %eax,%eax
80101880:	75 b6                	jne    80101838 <dirlookup+0x28>
      // entry matches path element
      if(poff)
80101882:	8b 45 10             	mov    0x10(%ebp),%eax
80101885:	85 c0                	test   %eax,%eax
80101887:	74 05                	je     8010188e <dirlookup+0x7e>
        *poff = off;
80101889:	8b 45 10             	mov    0x10(%ebp),%eax
8010188c:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
8010188e:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101892:	8b 03                	mov    (%ebx),%eax
80101894:	e8 e7 f5 ff ff       	call   80100e80 <iget>
    }
  }

  return 0;
}
80101899:	83 c4 2c             	add    $0x2c,%esp
8010189c:	5b                   	pop    %ebx
8010189d:	5e                   	pop    %esi
8010189e:	5f                   	pop    %edi
8010189f:	5d                   	pop    %ebp
801018a0:	c3                   	ret    
801018a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801018a8:	83 c4 2c             	add    $0x2c,%esp
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801018ab:	31 c0                	xor    %eax,%eax
}
801018ad:	5b                   	pop    %ebx
801018ae:	5e                   	pop    %esi
801018af:	5f                   	pop    %edi
801018b0:	5d                   	pop    %ebp
801018b1:	c3                   	ret    
  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
801018b2:	c7 04 24 59 38 10 80 	movl   $0x80103859,(%esp)
801018b9:	e8 a2 ea ff ff       	call   80100360 <panic>
{
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");
801018be:	c7 04 24 47 38 10 80 	movl   $0x80103847,(%esp)
801018c5:	e8 96 ea ff ff       	call   80100360 <panic>
801018ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801018d0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801018d0:	55                   	push   %ebp
801018d1:	89 e5                	mov    %esp,%ebp
801018d3:	57                   	push   %edi
801018d4:	89 cf                	mov    %ecx,%edi
801018d6:	56                   	push   %esi
801018d7:	53                   	push   %ebx
801018d8:	89 c3                	mov    %eax,%ebx
801018da:	83 ec 2c             	sub    $0x2c,%esp
  struct inode *ip, *next;

  if(*path == '/')
801018dd:	80 38 2f             	cmpb   $0x2f,(%eax)
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801018e0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
801018e3:	0f 84 51 01 00 00    	je     80101a3a <namex+0x16a>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
801018e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801018ef:	8b 70 10             	mov    0x10(%eax),%esi
// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
  acquire(&icache.lock);
801018f2:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801018f9:	e8 22 18 00 00       	call   80103120 <acquire>
  ip->ref++;
801018fe:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101902:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80101909:	e8 22 19 00 00       	call   80103230 <release>
8010190e:	eb 03                	jmp    80101913 <namex+0x43>
{
  char *s;
  int len;

  while(*path == '/')
    path++;
80101910:	83 c3 01             	add    $0x1,%ebx
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80101913:	0f b6 03             	movzbl (%ebx),%eax
80101916:	3c 2f                	cmp    $0x2f,%al
80101918:	74 f6                	je     80101910 <namex+0x40>
    path++;
  if(*path == 0)
8010191a:	84 c0                	test   %al,%al
8010191c:	0f 84 ed 00 00 00    	je     80101a0f <namex+0x13f>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80101922:	0f b6 03             	movzbl (%ebx),%eax
80101925:	89 da                	mov    %ebx,%edx
80101927:	84 c0                	test   %al,%al
80101929:	0f 84 b1 00 00 00    	je     801019e0 <namex+0x110>
8010192f:	3c 2f                	cmp    $0x2f,%al
80101931:	75 0f                	jne    80101942 <namex+0x72>
80101933:	e9 a8 00 00 00       	jmp    801019e0 <namex+0x110>
80101938:	3c 2f                	cmp    $0x2f,%al
8010193a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101940:	74 0a                	je     8010194c <namex+0x7c>
    path++;
80101942:	83 c2 01             	add    $0x1,%edx
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80101945:	0f b6 02             	movzbl (%edx),%eax
80101948:	84 c0                	test   %al,%al
8010194a:	75 ec                	jne    80101938 <namex+0x68>
8010194c:	89 d1                	mov    %edx,%ecx
8010194e:	29 d9                	sub    %ebx,%ecx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
80101950:	83 f9 0d             	cmp    $0xd,%ecx
80101953:	0f 8e 8f 00 00 00    	jle    801019e8 <namex+0x118>
    memmove(name, s, DIRSIZ);
80101959:	89 5c 24 04          	mov    %ebx,0x4(%esp)
8010195d:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80101964:	00 
80101965:	89 3c 24             	mov    %edi,(%esp)
80101968:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010196b:	e8 b0 19 00 00       	call   80103320 <memmove>
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80101970:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101973:	89 d3                	mov    %edx,%ebx
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80101975:	80 3a 2f             	cmpb   $0x2f,(%edx)
80101978:	75 0e                	jne    80101988 <namex+0xb8>
8010197a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    path++;
80101980:	83 c3 01             	add    $0x1,%ebx
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80101983:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101986:	74 f8                	je     80101980 <namex+0xb0>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101988:	89 34 24             	mov    %esi,(%esp)
8010198b:	e8 90 f9 ff ff       	call   80101320 <ilock>
    if(ip->type != T_DIR){
80101990:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101995:	0f 85 85 00 00 00    	jne    80101a20 <namex+0x150>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
8010199b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010199e:	85 d2                	test   %edx,%edx
801019a0:	74 09                	je     801019ab <namex+0xdb>
801019a2:	80 3b 00             	cmpb   $0x0,(%ebx)
801019a5:	0f 84 a5 00 00 00    	je     80101a50 <namex+0x180>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801019ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801019b2:	00 
801019b3:	89 7c 24 04          	mov    %edi,0x4(%esp)
801019b7:	89 34 24             	mov    %esi,(%esp)
801019ba:	e8 51 fe ff ff       	call   80101810 <dirlookup>
801019bf:	85 c0                	test   %eax,%eax
801019c1:	74 5d                	je     80101a20 <namex+0x150>

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
801019c3:	89 34 24             	mov    %esi,(%esp)
801019c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801019c9:	e8 22 fa ff ff       	call   801013f0 <iunlock>
  iput(ip);
801019ce:	89 34 24             	mov    %esi,(%esp)
801019d1:	e8 5a fa ff ff       	call   80101430 <iput>
    if((next = dirlookup(ip, name, 0)) == 0){
      iunlockput(ip);
      return 0;
    }
    iunlockput(ip);
    ip = next;
801019d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801019d9:	89 c6                	mov    %eax,%esi
801019db:	e9 33 ff ff ff       	jmp    80101913 <namex+0x43>
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801019e0:	31 c9                	xor    %ecx,%ecx
801019e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801019e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801019ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801019f0:	89 3c 24             	mov    %edi,(%esp)
801019f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
801019f6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
801019f9:	e8 22 19 00 00       	call   80103320 <memmove>
    name[len] = 0;
801019fe:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101a01:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101a04:	c6 04 0f 00          	movb   $0x0,(%edi,%ecx,1)
80101a08:	89 d3                	mov    %edx,%ebx
80101a0a:	e9 66 ff ff ff       	jmp    80101975 <namex+0xa5>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80101a0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101a12:	85 c0                	test   %eax,%eax
80101a14:	75 4c                	jne    80101a62 <namex+0x192>
80101a16:	89 f0                	mov    %esi,%eax
    iput(ip);
    return 0;
  }
  return ip;
}
80101a18:	83 c4 2c             	add    $0x2c,%esp
80101a1b:	5b                   	pop    %ebx
80101a1c:	5e                   	pop    %esi
80101a1d:	5f                   	pop    %edi
80101a1e:	5d                   	pop    %ebp
80101a1f:	c3                   	ret    

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
80101a20:	89 34 24             	mov    %esi,(%esp)
80101a23:	e8 c8 f9 ff ff       	call   801013f0 <iunlock>
  iput(ip);
80101a28:	89 34 24             	mov    %esi,(%esp)
80101a2b:	e8 00 fa ff ff       	call   80101430 <iput>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a30:	83 c4 2c             	add    $0x2c,%esp
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
      iunlockput(ip);
      return 0;
80101a33:	31 c0                	xor    %eax,%eax
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a35:	5b                   	pop    %ebx
80101a36:	5e                   	pop    %esi
80101a37:	5f                   	pop    %edi
80101a38:	5d                   	pop    %ebp
80101a39:	c3                   	ret    
namex(char *path, int nameiparent, char *name)
{
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
80101a3a:	ba 01 00 00 00       	mov    $0x1,%edx
80101a3f:	b8 01 00 00 00       	mov    $0x1,%eax
80101a44:	e8 37 f4 ff ff       	call   80100e80 <iget>
80101a49:	89 c6                	mov    %eax,%esi
80101a4b:	e9 c3 fe ff ff       	jmp    80101913 <namex+0x43>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
80101a50:	89 34 24             	mov    %esi,(%esp)
80101a53:	e8 98 f9 ff ff       	call   801013f0 <iunlock>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a58:	83 c4 2c             	add    $0x2c,%esp
      return 0;
    }
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
      return ip;
80101a5b:	89 f0                	mov    %esi,%eax
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a5d:	5b                   	pop    %ebx
80101a5e:	5e                   	pop    %esi
80101a5f:	5f                   	pop    %edi
80101a60:	5d                   	pop    %ebp
80101a61:	c3                   	ret    
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
    iput(ip);
80101a62:	89 34 24             	mov    %esi,(%esp)
80101a65:	e8 c6 f9 ff ff       	call   80101430 <iput>
    return 0;
80101a6a:	31 c0                	xor    %eax,%eax
80101a6c:	eb aa                	jmp    80101a18 <namex+0x148>
80101a6e:	66 90                	xchg   %ax,%ax

80101a70 <dirlink>:
}

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80101a70:	55                   	push   %ebp
80101a71:	89 e5                	mov    %esp,%ebp
80101a73:	57                   	push   %edi
80101a74:	56                   	push   %esi
80101a75:	53                   	push   %ebx
80101a76:	83 ec 2c             	sub    $0x2c,%esp
80101a79:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80101a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101a7f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80101a86:	00 
80101a87:	89 1c 24             	mov    %ebx,(%esp)
80101a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80101a8e:	e8 7d fd ff ff       	call   80101810 <dirlookup>
80101a93:	85 c0                	test   %eax,%eax
80101a95:	0f 85 8b 00 00 00    	jne    80101b26 <dirlink+0xb6>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80101a9b:	8b 43 58             	mov    0x58(%ebx),%eax
80101a9e:	31 ff                	xor    %edi,%edi
80101aa0:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101aa3:	85 c0                	test   %eax,%eax
80101aa5:	75 13                	jne    80101aba <dirlink+0x4a>
80101aa7:	eb 35                	jmp    80101ade <dirlink+0x6e>
80101aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101ab0:	8d 57 10             	lea    0x10(%edi),%edx
80101ab3:	39 53 58             	cmp    %edx,0x58(%ebx)
80101ab6:	89 d7                	mov    %edx,%edi
80101ab8:	76 24                	jbe    80101ade <dirlink+0x6e>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101aba:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80101ac1:	00 
80101ac2:	89 7c 24 08          	mov    %edi,0x8(%esp)
80101ac6:	89 74 24 04          	mov    %esi,0x4(%esp)
80101aca:	89 1c 24             	mov    %ebx,(%esp)
80101acd:	e8 de fa ff ff       	call   801015b0 <readi>
80101ad2:	83 f8 10             	cmp    $0x10,%eax
80101ad5:	75 5e                	jne    80101b35 <dirlink+0xc5>
      panic("dirlink read");
    if(de.inum == 0)
80101ad7:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101adc:	75 d2                	jne    80101ab0 <dirlink+0x40>
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80101ade:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ae1:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80101ae8:	00 
80101ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
80101aed:	8d 45 da             	lea    -0x26(%ebp),%eax
80101af0:	89 04 24             	mov    %eax,(%esp)
80101af3:	e8 08 19 00 00       	call   80103400 <strncpy>
  de.inum = inum;
80101af8:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101afb:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80101b02:	00 
80101b03:	89 7c 24 08          	mov    %edi,0x8(%esp)
80101b07:	89 74 24 04          	mov    %esi,0x4(%esp)
80101b0b:	89 1c 24             	mov    %ebx,(%esp)
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
80101b0e:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b12:	e8 99 fb ff ff       	call   801016b0 <writei>
80101b17:	83 f8 10             	cmp    $0x10,%eax
80101b1a:	75 25                	jne    80101b41 <dirlink+0xd1>
    panic("dirlink");

  return 0;
80101b1c:	31 c0                	xor    %eax,%eax
}
80101b1e:	83 c4 2c             	add    $0x2c,%esp
80101b21:	5b                   	pop    %ebx
80101b22:	5e                   	pop    %esi
80101b23:	5f                   	pop    %edi
80101b24:	5d                   	pop    %ebp
80101b25:	c3                   	ret    
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
80101b26:	89 04 24             	mov    %eax,(%esp)
80101b29:	e8 02 f9 ff ff       	call   80101430 <iput>
    return -1;
80101b2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b33:	eb e9                	jmp    80101b1e <dirlink+0xae>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
80101b35:	c7 04 24 59 38 10 80 	movl   $0x80103859,(%esp)
80101b3c:	e8 1f e8 ff ff       	call   80100360 <panic>
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("dirlink");
80101b41:	c7 04 24 66 38 10 80 	movl   $0x80103866,(%esp)
80101b48:	e8 13 e8 ff ff       	call   80100360 <panic>
80101b4d:	8d 76 00             	lea    0x0(%esi),%esi

80101b50 <namei>:
}

// Opens the named binary path.
struct inode*
namei(char *path)
{
80101b50:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101b51:	31 d2                	xor    %edx,%edx
}

// Opens the named binary path.
struct inode*
namei(char *path)
{
80101b53:	89 e5                	mov    %esp,%ebp
80101b55:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101b58:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5b:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101b5e:	e8 6d fd ff ff       	call   801018d0 <namex>
}
80101b63:	c9                   	leave  
80101b64:	c3                   	ret    
80101b65:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101b69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101b70 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101b70:	55                   	push   %ebp
  return namex(path, 1, name);
80101b71:	ba 01 00 00 00       	mov    $0x1,%edx
  return namex(path, 0, name);
}

struct inode*
nameiparent(char *path, char *name)
{
80101b76:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
80101b78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101b7b:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b7e:	5d                   	pop    %ebp
}

struct inode*
nameiparent(char *path, char *name)
{
  return namex(path, 1, name);
80101b7f:	e9 4c fd ff ff       	jmp    801018d0 <namex>
80101b84:	66 90                	xchg   %ax,%ax
80101b86:	66 90                	xchg   %ax,%ax
80101b88:	66 90                	xchg   %ax,%ax
80101b8a:	66 90                	xchg   %ax,%ax
80101b8c:	66 90                	xchg   %ax,%ax
80101b8e:	66 90                	xchg   %ax,%ax

80101b90 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101b90:	55                   	push   %ebp
80101b91:	89 e5                	mov    %esp,%ebp
80101b93:	56                   	push   %esi
80101b94:	89 c6                	mov    %eax,%esi
80101b96:	53                   	push   %ebx
80101b97:	83 ec 10             	sub    $0x10,%esp
  if(b == 0)
80101b9a:	85 c0                	test   %eax,%eax
80101b9c:	0f 84 99 00 00 00    	je     80101c3b <idestart+0xab>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101ba2:	8b 48 08             	mov    0x8(%eax),%ecx
80101ba5:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101bab:	0f 87 7e 00 00 00    	ja     80101c2f <idestart+0x9f>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101bb1:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101bb6:	66 90                	xchg   %ax,%ax
80101bb8:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101bb9:	83 e0 c0             	and    $0xffffffc0,%eax
80101bbc:	3c 40                	cmp    $0x40,%al
80101bbe:	75 f8                	jne    80101bb8 <idestart+0x28>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101bc0:	31 db                	xor    %ebx,%ebx
80101bc2:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101bc7:	89 d8                	mov    %ebx,%eax
80101bc9:	ee                   	out    %al,(%dx)
80101bca:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101bcf:	b8 01 00 00 00       	mov    $0x1,%eax
80101bd4:	ee                   	out    %al,(%dx)
80101bd5:	0f b6 c1             	movzbl %cl,%eax
80101bd8:	b2 f3                	mov    $0xf3,%dl
80101bda:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101bdb:	89 c8                	mov    %ecx,%eax
80101bdd:	b2 f4                	mov    $0xf4,%dl
80101bdf:	c1 f8 08             	sar    $0x8,%eax
80101be2:	ee                   	out    %al,(%dx)
80101be3:	b2 f5                	mov    $0xf5,%dl
80101be5:	89 d8                	mov    %ebx,%eax
80101be7:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101be8:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101bec:	b2 f6                	mov    $0xf6,%dl
80101bee:	83 e0 01             	and    $0x1,%eax
80101bf1:	c1 e0 04             	shl    $0x4,%eax
80101bf4:	83 c8 e0             	or     $0xffffffe0,%eax
80101bf7:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101bf8:	f6 06 04             	testb  $0x4,(%esi)
80101bfb:	75 13                	jne    80101c10 <idestart+0x80>
80101bfd:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c02:	b8 20 00 00 00       	mov    $0x20,%eax
80101c07:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101c08:	83 c4 10             	add    $0x10,%esp
80101c0b:	5b                   	pop    %ebx
80101c0c:	5e                   	pop    %esi
80101c0d:	5d                   	pop    %ebp
80101c0e:	c3                   	ret    
80101c0f:	90                   	nop
80101c10:	b2 f7                	mov    $0xf7,%dl
80101c12:	b8 30 00 00 00       	mov    $0x30,%eax
80101c17:	ee                   	out    %al,(%dx)
}

static inline void
outsl(int port, const void *addr, int cnt)
{
  asm volatile("cld; rep outsl" :
80101c18:	b9 80 00 00 00       	mov    $0x80,%ecx
  outb(0x1f4, (sector >> 8) & 0xff);
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
80101c1d:	83 c6 5c             	add    $0x5c,%esi
80101c20:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101c25:	fc                   	cld    
80101c26:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101c28:	83 c4 10             	add    $0x10,%esp
80101c2b:	5b                   	pop    %ebx
80101c2c:	5e                   	pop    %esi
80101c2d:	5d                   	pop    %ebp
80101c2e:	c3                   	ret    
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
  if(b->blockno >= FSSIZE)
    panic("incorrect blockno");
80101c2f:	c7 04 24 cc 38 10 80 	movl   $0x801038cc,(%esp)
80101c36:	e8 25 e7 ff ff       	call   80100360 <panic>
// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
80101c3b:	c7 04 24 c3 38 10 80 	movl   $0x801038c3,(%esp)
80101c42:	e8 19 e7 ff ff       	call   80100360 <panic>
80101c47:	89 f6                	mov    %esi,%esi
80101c49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101c50 <ideinit>:
  return 0;
}

void
ideinit(void)
{
80101c50:	55                   	push   %ebp
80101c51:	89 e5                	mov    %esp,%ebp
80101c53:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80101c56:	c7 44 24 04 de 38 10 	movl   $0x801038de,0x4(%esp)
80101c5d:	80 
80101c5e:	c7 04 24 80 51 10 80 	movl   $0x80105180,(%esp)
80101c65:	e8 36 14 00 00       	call   801030a0 <initlock>
  picenable(IRQ_IDE);
80101c6a:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80101c71:	e8 da 0c 00 00       	call   80102950 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101c76:	a1 e0 d3 10 80       	mov    0x8010d3e0,%eax
80101c7b:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80101c82:	83 e8 01             	sub    $0x1,%eax
80101c85:	89 44 24 04          	mov    %eax,0x4(%esp)
80101c89:	e8 82 02 00 00       	call   80101f10 <ioapicenable>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101c8e:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c93:	90                   	nop
80101c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101c98:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101c99:	83 e0 c0             	and    $0xffffffc0,%eax
80101c9c:	3c 40                	cmp    $0x40,%al
80101c9e:	75 f8                	jne    80101c98 <ideinit+0x48>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101ca0:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101ca5:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101caa:	ee                   	out    %al,(%dx)
80101cab:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101cb0:	b2 f7                	mov    $0xf7,%dl
80101cb2:	eb 09                	jmp    80101cbd <ideinit+0x6d>
80101cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80101cb8:	83 e9 01             	sub    $0x1,%ecx
80101cbb:	74 0f                	je     80101ccc <ideinit+0x7c>
80101cbd:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101cbe:	84 c0                	test   %al,%al
80101cc0:	74 f6                	je     80101cb8 <ideinit+0x68>
      havedisk1 = 1;
80101cc2:	c7 05 60 51 10 80 01 	movl   $0x1,0x80105160
80101cc9:	00 00 00 
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101ccc:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cd1:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101cd6:	ee                   	out    %al,(%dx)
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
}
80101cd7:	c9                   	leave  
80101cd8:	c3                   	ret    
80101cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101ce0 <ideintr>:
}

// Interrupt handler.
void
ideintr(void)
{
80101ce0:	55                   	push   %ebp
80101ce1:	89 e5                	mov    %esp,%ebp
80101ce3:	57                   	push   %edi
80101ce4:	56                   	push   %esi
80101ce5:	53                   	push   %ebx
80101ce6:	83 ec 1c             	sub    $0x1c,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101ce9:	c7 04 24 80 51 10 80 	movl   $0x80105180,(%esp)
80101cf0:	e8 2b 14 00 00       	call   80103120 <acquire>
  if((b = idequeue) == 0){
80101cf5:	8b 1d 64 51 10 80    	mov    0x80105164,%ebx
80101cfb:	85 db                	test   %ebx,%ebx
80101cfd:	74 30                	je     80101d2f <ideintr+0x4f>
    release(&idelock);
    // cprintf("spurious IDE interrupt\n");
    return;
  }
  idequeue = b->qnext;
80101cff:	8b 43 58             	mov    0x58(%ebx),%eax
80101d02:	a3 64 51 10 80       	mov    %eax,0x80105164

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d07:	8b 33                	mov    (%ebx),%esi
80101d09:	f7 c6 04 00 00 00    	test   $0x4,%esi
80101d0f:	74 37                	je     80101d48 <ideintr+0x68>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
80101d11:	83 e6 fb             	and    $0xfffffffb,%esi
80101d14:	83 ce 02             	or     $0x2,%esi
80101d17:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
80101d19:	89 1c 24             	mov    %ebx,(%esp)
80101d1c:	e8 9f 11 00 00       	call   80102ec0 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101d21:	a1 64 51 10 80       	mov    0x80105164,%eax
80101d26:	85 c0                	test   %eax,%eax
80101d28:	74 05                	je     80101d2f <ideintr+0x4f>
    idestart(idequeue);
80101d2a:	e8 61 fe ff ff       	call   80101b90 <idestart>
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
  if((b = idequeue) == 0){
    release(&idelock);
80101d2f:	c7 04 24 80 51 10 80 	movl   $0x80105180,(%esp)
80101d36:	e8 f5 14 00 00       	call   80103230 <release>
  // Start disk on next buf in queue.
  if(idequeue != 0)
    idestart(idequeue);

  release(&idelock);
}
80101d3b:	83 c4 1c             	add    $0x1c,%esp
80101d3e:	5b                   	pop    %ebx
80101d3f:	5e                   	pop    %esi
80101d40:	5f                   	pop    %edi
80101d41:	5d                   	pop    %ebp
80101d42:	c3                   	ret    
80101d43:	90                   	nop
80101d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d48:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d4d:	8d 76 00             	lea    0x0(%esi),%esi
80101d50:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101d51:	89 c1                	mov    %eax,%ecx
80101d53:	83 e1 c0             	and    $0xffffffc0,%ecx
80101d56:	80 f9 40             	cmp    $0x40,%cl
80101d59:	75 f5                	jne    80101d50 <ideintr+0x70>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101d5b:	a8 21                	test   $0x21,%al
80101d5d:	75 b2                	jne    80101d11 <ideintr+0x31>
  }
  idequeue = b->qnext;

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
    insl(0x1f0, b->data, BSIZE/4);
80101d5f:	8d 7b 5c             	lea    0x5c(%ebx),%edi
}

static inline void
insl(int port, void *addr, int cnt)
{
  asm volatile("cld; rep insl" :
80101d62:	b9 80 00 00 00       	mov    $0x80,%ecx
80101d67:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101d6c:	fc                   	cld    
80101d6d:	f3 6d                	rep insl (%dx),%es:(%edi)
80101d6f:	8b 33                	mov    (%ebx),%esi
80101d71:	eb 9e                	jmp    80101d11 <ideintr+0x31>
80101d73:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101d79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101d80 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101d80:	55                   	push   %ebp
80101d81:	89 e5                	mov    %esp,%ebp
80101d83:	53                   	push   %ebx
80101d84:	83 ec 14             	sub    $0x14,%esp
80101d87:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101d8a:	8d 43 0c             	lea    0xc(%ebx),%eax
80101d8d:	89 04 24             	mov    %eax,(%esp)
80101d90:	e8 db 12 00 00       	call   80103070 <holdingsleep>
80101d95:	85 c0                	test   %eax,%eax
80101d97:	0f 84 9e 00 00 00    	je     80101e3b <iderw+0xbb>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101d9d:	8b 03                	mov    (%ebx),%eax
80101d9f:	83 e0 06             	and    $0x6,%eax
80101da2:	83 f8 02             	cmp    $0x2,%eax
80101da5:	0f 84 a8 00 00 00    	je     80101e53 <iderw+0xd3>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101dab:	8b 53 04             	mov    0x4(%ebx),%edx
80101dae:	85 d2                	test   %edx,%edx
80101db0:	74 0d                	je     80101dbf <iderw+0x3f>
80101db2:	a1 60 51 10 80       	mov    0x80105160,%eax
80101db7:	85 c0                	test   %eax,%eax
80101db9:	0f 84 88 00 00 00    	je     80101e47 <iderw+0xc7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101dbf:	c7 04 24 80 51 10 80 	movl   $0x80105180,(%esp)
80101dc6:	e8 55 13 00 00       	call   80103120 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101dcb:	a1 64 51 10 80       	mov    0x80105164,%eax
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock

  // Append b to idequeue.
  b->qnext = 0;
80101dd0:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101dd7:	85 c0                	test   %eax,%eax
80101dd9:	75 07                	jne    80101de2 <iderw+0x62>
80101ddb:	eb 4e                	jmp    80101e2b <iderw+0xab>
80101ddd:	8d 76 00             	lea    0x0(%esi),%esi
80101de0:	89 d0                	mov    %edx,%eax
80101de2:	8b 50 58             	mov    0x58(%eax),%edx
80101de5:	85 d2                	test   %edx,%edx
80101de7:	75 f7                	jne    80101de0 <iderw+0x60>
80101de9:	83 c0 58             	add    $0x58,%eax
    ;
  *pp = b;
80101dec:	89 18                	mov    %ebx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80101dee:	39 1d 64 51 10 80    	cmp    %ebx,0x80105164
80101df4:	74 3c                	je     80101e32 <iderw+0xb2>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101df6:	8b 03                	mov    (%ebx),%eax
80101df8:	83 e0 06             	and    $0x6,%eax
80101dfb:	83 f8 02             	cmp    $0x2,%eax
80101dfe:	74 1a                	je     80101e1a <iderw+0x9a>
    sleep(b, &idelock);
80101e00:	c7 44 24 04 80 51 10 	movl   $0x80105180,0x4(%esp)
80101e07:	80 
80101e08:	89 1c 24             	mov    %ebx,(%esp)
80101e0b:	e8 f0 0f 00 00       	call   80102e00 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101e10:	8b 13                	mov    (%ebx),%edx
80101e12:	83 e2 06             	and    $0x6,%edx
80101e15:	83 fa 02             	cmp    $0x2,%edx
80101e18:	75 e6                	jne    80101e00 <iderw+0x80>
    sleep(b, &idelock);
  }

  release(&idelock);
80101e1a:	c7 45 08 80 51 10 80 	movl   $0x80105180,0x8(%ebp)
}
80101e21:	83 c4 14             	add    $0x14,%esp
80101e24:	5b                   	pop    %ebx
80101e25:	5d                   	pop    %ebp
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  }

  release(&idelock);
80101e26:	e9 05 14 00 00       	jmp    80103230 <release>

  acquire(&idelock);  //DOC:acquire-lock

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e2b:	b8 64 51 10 80       	mov    $0x80105164,%eax
80101e30:	eb ba                	jmp    80101dec <iderw+0x6c>
    ;
  *pp = b;

  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
80101e32:	89 d8                	mov    %ebx,%eax
80101e34:	e8 57 fd ff ff       	call   80101b90 <idestart>
80101e39:	eb bb                	jmp    80101df6 <iderw+0x76>
iderw(struct buf *b)
{
  struct buf **pp;

  if(!holdingsleep(&b->lock))
    panic("iderw: buf not locked");
80101e3b:	c7 04 24 e2 38 10 80 	movl   $0x801038e2,(%esp)
80101e42:	e8 19 e5 ff ff       	call   80100360 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
    panic("iderw: ide disk 1 not present");
80101e47:	c7 04 24 0d 39 10 80 	movl   $0x8010390d,(%esp)
80101e4e:	e8 0d e5 ff ff       	call   80100360 <panic>
  struct buf **pp;

  if(!holdingsleep(&b->lock))
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
80101e53:	c7 04 24 f8 38 10 80 	movl   $0x801038f8,(%esp)
80101e5a:	e8 01 e5 ff ff       	call   80100360 <panic>
80101e5f:	90                   	nop

80101e60 <ioapicinit>:
void
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
80101e60:	a1 64 d3 10 80       	mov    0x8010d364,%eax
80101e65:	85 c0                	test   %eax,%eax
80101e67:	0f 84 9b 00 00 00    	je     80101f08 <ioapicinit+0xa8>
  ioapic->data = data;
}

void
ioapicinit(void)
{
80101e6d:	55                   	push   %ebp
80101e6e:	89 e5                	mov    %esp,%ebp
80101e70:	56                   	push   %esi
80101e71:	53                   	push   %ebx
80101e72:	83 ec 10             	sub    $0x10,%esp
  int i, id, maxintr;

  if(!ismp)
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101e75:	c7 05 34 d2 10 80 00 	movl   $0xfec00000,0x8010d234
80101e7c:	00 c0 fe 
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
80101e7f:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
80101e86:	00 00 00 
  return ioapic->data;
80101e89:	8b 15 34 d2 10 80    	mov    0x8010d234,%edx
80101e8f:	8b 42 10             	mov    0x10(%edx),%eax
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
80101e92:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
80101e98:	8b 1d 34 d2 10 80    	mov    0x8010d234,%ebx
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
80101e9e:	0f b6 15 60 d3 10 80 	movzbl 0x8010d360,%edx

  if(!ismp)
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101ea5:	c1 e8 10             	shr    $0x10,%eax
80101ea8:	0f b6 f0             	movzbl %al,%esi

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
  return ioapic->data;
80101eab:	8b 43 10             	mov    0x10(%ebx),%eax
  if(!ismp)
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
80101eae:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101eb1:	39 c2                	cmp    %eax,%edx
80101eb3:	74 12                	je     80101ec7 <ioapicinit+0x67>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101eb5:	c7 04 24 2c 39 10 80 	movl   $0x8010392c,(%esp)
80101ebc:	e8 8f e7 ff ff       	call   80100650 <cprintf>
80101ec1:	8b 1d 34 d2 10 80    	mov    0x8010d234,%ebx
80101ec7:	ba 10 00 00 00       	mov    $0x10,%edx
80101ecc:	31 c0                	xor    %eax,%eax
80101ece:	eb 02                	jmp    80101ed2 <ioapicinit+0x72>
80101ed0:	89 cb                	mov    %ecx,%ebx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80101ed2:	89 13                	mov    %edx,(%ebx)
  ioapic->data = data;
80101ed4:	8b 1d 34 d2 10 80    	mov    0x8010d234,%ebx
80101eda:	8d 48 20             	lea    0x20(%eax),%ecx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101edd:	81 c9 00 00 01 00    	or     $0x10000,%ecx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80101ee3:	83 c0 01             	add    $0x1,%eax

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
80101ee6:	89 4b 10             	mov    %ecx,0x10(%ebx)
80101ee9:	8d 4a 01             	lea    0x1(%edx),%ecx
80101eec:	83 c2 02             	add    $0x2,%edx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80101eef:	89 0b                	mov    %ecx,(%ebx)
  ioapic->data = data;
80101ef1:	8b 0d 34 d2 10 80    	mov    0x8010d234,%ecx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80101ef7:	39 c6                	cmp    %eax,%esi

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
80101ef9:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80101f00:	7d ce                	jge    80101ed0 <ioapicinit+0x70>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80101f02:	83 c4 10             	add    $0x10,%esp
80101f05:	5b                   	pop    %ebx
80101f06:	5e                   	pop    %esi
80101f07:	5d                   	pop    %ebp
80101f08:	f3 c3                	repz ret 
80101f0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101f10 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
80101f10:	8b 15 64 d3 10 80    	mov    0x8010d364,%edx
  }
}

void
ioapicenable(int irq, int cpunum)
{
80101f16:	55                   	push   %ebp
80101f17:	89 e5                	mov    %esp,%ebp
80101f19:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!ismp)
80101f1c:	85 d2                	test   %edx,%edx
80101f1e:	74 29                	je     80101f49 <ioapicenable+0x39>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101f20:	8d 48 20             	lea    0x20(%eax),%ecx
80101f23:	8d 54 00 10          	lea    0x10(%eax,%eax,1),%edx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80101f27:	a1 34 d2 10 80       	mov    0x8010d234,%eax
80101f2c:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80101f2e:	a1 34 d2 10 80       	mov    0x8010d234,%eax

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f33:	83 c2 01             	add    $0x1,%edx

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
80101f36:	89 48 10             	mov    %ecx,0x10(%eax)

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80101f3c:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80101f3e:	a1 34 d2 10 80       	mov    0x8010d234,%eax

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f43:	c1 e1 18             	shl    $0x18,%ecx

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
80101f46:	89 48 10             	mov    %ecx,0x10(%eax)
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80101f49:	5d                   	pop    %ebp
80101f4a:	c3                   	ret    
80101f4b:	66 90                	xchg   %ax,%ax
80101f4d:	66 90                	xchg   %ax,%ax
80101f4f:	90                   	nop

80101f50 <kfree>:

//PAGEBREAK: 21
// Free the page of physical memory pointed at by v, which normally should have
// been returned by a call to kalloc(). (The exception is when initializing the
// allocator; see kinit above.)
void kfree(char* v) {
80101f50:	55                   	push   %ebp
80101f51:	89 e5                	mov    %esp,%ebp
80101f53:	53                   	push   %ebx
80101f54:	83 ec 14             	sub    $0x14,%esp
80101f57:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run* r;

  if (((uint)v % PGSIZE) || v < end || V2P(v) >= PHYSTOP) {
80101f5a:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101f60:	75 7c                	jne    80101fde <kfree+0x8e>
80101f62:	81 fb 38 dd 10 80    	cmp    $0x8010dd38,%ebx
80101f68:	72 74                	jb     80101fde <kfree+0x8e>
80101f6a:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101f70:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101f75:	77 67                	ja     80101fde <kfree+0x8e>
    panic("kfree");
  }

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101f77:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80101f7e:	00 
80101f7f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101f86:	00 
80101f87:	89 1c 24             	mov    %ebx,(%esp)
80101f8a:	e8 f1 12 00 00       	call   80103280 <memset>

  if (kmem.use_lock) {
80101f8f:	8b 15 74 d2 10 80    	mov    0x8010d274,%edx
80101f95:	85 d2                	test   %edx,%edx
80101f97:	75 37                	jne    80101fd0 <kfree+0x80>
    acquire(&kmem.lock);
  }
  r = (struct run*)v;
  r->next = kmem.freelist;
80101f99:	a1 78 d2 10 80       	mov    0x8010d278,%eax
80101f9e:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  if (kmem.use_lock) {
80101fa0:	a1 74 d2 10 80       	mov    0x8010d274,%eax
  if (kmem.use_lock) {
    acquire(&kmem.lock);
  }
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
80101fa5:	89 1d 78 d2 10 80    	mov    %ebx,0x8010d278
  if (kmem.use_lock) {
80101fab:	85 c0                	test   %eax,%eax
80101fad:	75 09                	jne    80101fb8 <kfree+0x68>
    release(&kmem.lock);
  }
}
80101faf:	83 c4 14             	add    $0x14,%esp
80101fb2:	5b                   	pop    %ebx
80101fb3:	5d                   	pop    %ebp
80101fb4:	c3                   	ret    
80101fb5:	8d 76 00             	lea    0x0(%esi),%esi
  }
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  if (kmem.use_lock) {
    release(&kmem.lock);
80101fb8:	c7 45 08 40 d2 10 80 	movl   $0x8010d240,0x8(%ebp)
  }
}
80101fbf:	83 c4 14             	add    $0x14,%esp
80101fc2:	5b                   	pop    %ebx
80101fc3:	5d                   	pop    %ebp
  }
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  if (kmem.use_lock) {
    release(&kmem.lock);
80101fc4:	e9 67 12 00 00       	jmp    80103230 <release>
80101fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);

  if (kmem.use_lock) {
    acquire(&kmem.lock);
80101fd0:	c7 04 24 40 d2 10 80 	movl   $0x8010d240,(%esp)
80101fd7:	e8 44 11 00 00       	call   80103120 <acquire>
80101fdc:	eb bb                	jmp    80101f99 <kfree+0x49>
// allocator; see kinit above.)
void kfree(char* v) {
  struct run* r;

  if (((uint)v % PGSIZE) || v < end || V2P(v) >= PHYSTOP) {
    panic("kfree");
80101fde:	c7 04 24 5e 39 10 80 	movl   $0x8010395e,(%esp)
80101fe5:	e8 76 e3 ff ff       	call   80100360 <panic>
80101fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101ff0 <freerange>:
  initlock(&kmem.lock, "kmem");
  kmem.use_lock = 0;
  freerange(vstart, vend);
}

void freerange(void* vstart, void* vend) {
80101ff0:	55                   	push   %ebp
80101ff1:	89 e5                	mov    %esp,%ebp
80101ff3:	56                   	push   %esi
80101ff4:	53                   	push   %ebx
80101ff5:	83 ec 10             	sub    $0x10,%esp
  char* p;
  p = (char*)PGROUNDUP((uint)vstart);
80101ff8:	8b 45 08             	mov    0x8(%ebp),%eax
  initlock(&kmem.lock, "kmem");
  kmem.use_lock = 0;
  freerange(vstart, vend);
}

void freerange(void* vstart, void* vend) {
80101ffb:	8b 75 0c             	mov    0xc(%ebp),%esi
  char* p;
  p = (char*)PGROUNDUP((uint)vstart);
80101ffe:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80102004:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  for (; p + PGSIZE <= (char*)vend; p += PGSIZE) {
8010200a:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
80102010:	39 de                	cmp    %ebx,%esi
80102012:	73 08                	jae    8010201c <freerange+0x2c>
80102014:	eb 18                	jmp    8010202e <freerange+0x3e>
80102016:	66 90                	xchg   %ax,%ax
80102018:	89 da                	mov    %ebx,%edx
8010201a:	89 c3                	mov    %eax,%ebx
    kfree(p);
8010201c:	89 14 24             	mov    %edx,(%esp)
8010201f:	e8 2c ff ff ff       	call   80101f50 <kfree>
}

void freerange(void* vstart, void* vend) {
  char* p;
  p = (char*)PGROUNDUP((uint)vstart);
  for (; p + PGSIZE <= (char*)vend; p += PGSIZE) {
80102024:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
8010202a:	39 f0                	cmp    %esi,%eax
8010202c:	76 ea                	jbe    80102018 <freerange+0x28>
    kfree(p);
  }
}
8010202e:	83 c4 10             	add    $0x10,%esp
80102031:	5b                   	pop    %ebx
80102032:	5e                   	pop    %esi
80102033:	5d                   	pop    %ebp
80102034:	c3                   	ret    
80102035:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102039:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102040 <kinit1>:
// Initialization happens in two phases.
// 1. main() calls kinit1() while still using entrypgdir to place just
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void kinit1(void* vstart, void* vend) {
80102040:	55                   	push   %ebp
80102041:	89 e5                	mov    %esp,%ebp
80102043:	56                   	push   %esi
80102044:	53                   	push   %ebx
80102045:	83 ec 10             	sub    $0x10,%esp
80102048:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
8010204b:	c7 44 24 04 64 39 10 	movl   $0x80103964,0x4(%esp)
80102052:	80 
80102053:	c7 04 24 40 d2 10 80 	movl   $0x8010d240,(%esp)
8010205a:	e8 41 10 00 00       	call   801030a0 <initlock>
  freerange(vstart, vend);
}

void freerange(void* vstart, void* vend) {
  char* p;
  p = (char*)PGROUNDUP((uint)vstart);
8010205f:	8b 45 08             	mov    0x8(%ebp),%eax
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void kinit1(void* vstart, void* vend) {
  initlock(&kmem.lock, "kmem");
  kmem.use_lock = 0;
80102062:	c7 05 74 d2 10 80 00 	movl   $0x0,0x8010d274
80102069:	00 00 00 
  freerange(vstart, vend);
}

void freerange(void* vstart, void* vend) {
  char* p;
  p = (char*)PGROUNDUP((uint)vstart);
8010206c:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80102072:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  for (; p + PGSIZE <= (char*)vend; p += PGSIZE) {
80102078:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
8010207e:	39 de                	cmp    %ebx,%esi
80102080:	73 0a                	jae    8010208c <kinit1+0x4c>
80102082:	eb 1a                	jmp    8010209e <kinit1+0x5e>
80102084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102088:	89 da                	mov    %ebx,%edx
8010208a:	89 c3                	mov    %eax,%ebx
    kfree(p);
8010208c:	89 14 24             	mov    %edx,(%esp)
8010208f:	e8 bc fe ff ff       	call   80101f50 <kfree>
}

void freerange(void* vstart, void* vend) {
  char* p;
  p = (char*)PGROUNDUP((uint)vstart);
  for (; p + PGSIZE <= (char*)vend; p += PGSIZE) {
80102094:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
8010209a:	39 c6                	cmp    %eax,%esi
8010209c:	73 ea                	jae    80102088 <kinit1+0x48>
// after installing a full page table that maps them on all cores.
void kinit1(void* vstart, void* vend) {
  initlock(&kmem.lock, "kmem");
  kmem.use_lock = 0;
  freerange(vstart, vend);
}
8010209e:	83 c4 10             	add    $0x10,%esp
801020a1:	5b                   	pop    %ebx
801020a2:	5e                   	pop    %esi
801020a3:	5d                   	pop    %ebp
801020a4:	c3                   	ret    
801020a5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801020a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801020b0 <kalloc>:
  }
}

// Allocate one 4096-byte page of physical memory. Return a pointer that the
// kernel can use. Return 0 if the memory cannot be allocated.
char* kalloc(void) {
801020b0:	55                   	push   %ebp
801020b1:	89 e5                	mov    %esp,%ebp
801020b3:	53                   	push   %ebx
801020b4:	83 ec 14             	sub    $0x14,%esp
  struct run* r;
  if (kmem.use_lock) {
801020b7:	a1 74 d2 10 80       	mov    0x8010d274,%eax
801020bc:	85 c0                	test   %eax,%eax
801020be:	75 30                	jne    801020f0 <kalloc+0x40>
    acquire(&kmem.lock);
  }
  r = kmem.freelist;
801020c0:	8b 1d 78 d2 10 80    	mov    0x8010d278,%ebx
  if (r) {
801020c6:	85 db                	test   %ebx,%ebx
801020c8:	74 08                	je     801020d2 <kalloc+0x22>
    kmem.freelist = r->next;
801020ca:	8b 13                	mov    (%ebx),%edx
801020cc:	89 15 78 d2 10 80    	mov    %edx,0x8010d278
  }
  if (kmem.use_lock) {
801020d2:	85 c0                	test   %eax,%eax
801020d4:	74 0c                	je     801020e2 <kalloc+0x32>
    release(&kmem.lock);
801020d6:	c7 04 24 40 d2 10 80 	movl   $0x8010d240,(%esp)
801020dd:	e8 4e 11 00 00       	call   80103230 <release>
  }
  return (char*)r;
}
801020e2:	83 c4 14             	add    $0x14,%esp
801020e5:	89 d8                	mov    %ebx,%eax
801020e7:	5b                   	pop    %ebx
801020e8:	5d                   	pop    %ebp
801020e9:	c3                   	ret    
801020ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
// Allocate one 4096-byte page of physical memory. Return a pointer that the
// kernel can use. Return 0 if the memory cannot be allocated.
char* kalloc(void) {
  struct run* r;
  if (kmem.use_lock) {
    acquire(&kmem.lock);
801020f0:	c7 04 24 40 d2 10 80 	movl   $0x8010d240,(%esp)
801020f7:	e8 24 10 00 00       	call   80103120 <acquire>
801020fc:	a1 74 d2 10 80       	mov    0x8010d274,%eax
80102101:	eb bd                	jmp    801020c0 <kalloc+0x10>
80102103:	66 90                	xchg   %ax,%ax
80102105:	66 90                	xchg   %ax,%ax
80102107:	66 90                	xchg   %ax,%ax
80102109:	66 90                	xchg   %ax,%ax
8010210b:	66 90                	xchg   %ax,%ax
8010210d:	66 90                	xchg   %ax,%ax
8010210f:	90                   	nop

80102110 <fill_rtcdate>:

  return inb(CMOS_RETURN);
}

static void fill_rtcdate(struct rtcdate *r)
{
80102110:	55                   	push   %ebp
80102111:	89 c1                	mov    %eax,%ecx
80102113:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102115:	ba 70 00 00 00       	mov    $0x70,%edx
8010211a:	53                   	push   %ebx
8010211b:	31 c0                	xor    %eax,%eax
8010211d:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010211e:	bb 71 00 00 00       	mov    $0x71,%ebx
80102123:	89 da                	mov    %ebx,%edx
80102125:	ec                   	in     (%dx),%al
static uint cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
80102126:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102129:	b2 70                	mov    $0x70,%dl
8010212b:	89 01                	mov    %eax,(%ecx)
8010212d:	b8 02 00 00 00       	mov    $0x2,%eax
80102132:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102133:	89 da                	mov    %ebx,%edx
80102135:	ec                   	in     (%dx),%al
80102136:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102139:	b2 70                	mov    $0x70,%dl
8010213b:	89 41 04             	mov    %eax,0x4(%ecx)
8010213e:	b8 04 00 00 00       	mov    $0x4,%eax
80102143:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102144:	89 da                	mov    %ebx,%edx
80102146:	ec                   	in     (%dx),%al
80102147:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010214a:	b2 70                	mov    $0x70,%dl
8010214c:	89 41 08             	mov    %eax,0x8(%ecx)
8010214f:	b8 07 00 00 00       	mov    $0x7,%eax
80102154:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102155:	89 da                	mov    %ebx,%edx
80102157:	ec                   	in     (%dx),%al
80102158:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010215b:	b2 70                	mov    $0x70,%dl
8010215d:	89 41 0c             	mov    %eax,0xc(%ecx)
80102160:	b8 08 00 00 00       	mov    $0x8,%eax
80102165:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102166:	89 da                	mov    %ebx,%edx
80102168:	ec                   	in     (%dx),%al
80102169:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010216c:	b2 70                	mov    $0x70,%dl
8010216e:	89 41 10             	mov    %eax,0x10(%ecx)
80102171:	b8 09 00 00 00       	mov    $0x9,%eax
80102176:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102177:	89 da                	mov    %ebx,%edx
80102179:	ec                   	in     (%dx),%al
8010217a:	0f b6 d8             	movzbl %al,%ebx
8010217d:	89 59 14             	mov    %ebx,0x14(%ecx)
  r->minute = cmos_read(MINS);
  r->hour   = cmos_read(HOURS);
  r->day    = cmos_read(DAY);
  r->month  = cmos_read(MONTH);
  r->year   = cmos_read(YEAR);
}
80102180:	5b                   	pop    %ebx
80102181:	5d                   	pop    %ebp
80102182:	c3                   	ret    
80102183:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102189:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102190 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
  if(!lapic)
80102190:	a1 7c d2 10 80       	mov    0x8010d27c,%eax
}
//PAGEBREAK!

void
lapicinit(void)
{
80102195:	55                   	push   %ebp
80102196:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102198:	85 c0                	test   %eax,%eax
8010219a:	0f 84 c0 00 00 00    	je     80102260 <lapicinit+0xd0>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
801021a0:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
801021a7:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
801021aa:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
801021ad:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
801021b4:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801021b7:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
801021ba:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
801021c1:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
801021c4:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
801021c7:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
801021ce:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
801021d1:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
801021d4:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
801021db:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801021de:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
801021e1:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
801021e8:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801021eb:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801021ee:	8b 50 30             	mov    0x30(%eax),%edx
801021f1:	c1 ea 10             	shr    $0x10,%edx
801021f4:	80 fa 03             	cmp    $0x3,%dl
801021f7:	77 6f                	ja     80102268 <lapicinit+0xd8>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
801021f9:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102200:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102203:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102206:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010220d:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102210:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102213:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010221a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010221d:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102220:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102227:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010222a:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010222d:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
80102234:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102237:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010223a:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
80102241:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
80102244:	8b 50 20             	mov    0x20(%eax),%edx
80102247:	90                   	nop
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
80102248:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
8010224e:	80 e6 10             	and    $0x10,%dh
80102251:	75 f5                	jne    80102248 <lapicinit+0xb8>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102253:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
8010225a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010225d:	8b 40 20             	mov    0x20(%eax),%eax
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102260:	5d                   	pop    %ebp
80102261:	c3                   	ret    
80102262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102268:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
8010226f:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102272:	8b 50 20             	mov    0x20(%eax),%edx
80102275:	eb 82                	jmp    801021f9 <lapicinit+0x69>
80102277:	89 f6                	mov    %esi,%esi
80102279:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102280 <cpunum>:
  lapicw(TPR, 0);
}

int
cpunum(void)
{
80102280:	55                   	push   %ebp
80102281:	89 e5                	mov    %esp,%ebp
80102283:	56                   	push   %esi
80102284:	53                   	push   %ebx
80102285:	83 ec 10             	sub    $0x10,%esp
// Return the value of EFLAGS register
static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102288:	9c                   	pushf  
80102289:	58                   	pop    %eax
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
8010228a:	f6 c4 02             	test   $0x2,%ah
8010228d:	74 12                	je     801022a1 <cpunum+0x21>
    static int n;
    if(n++ == 0)
8010228f:	a1 b4 51 10 80       	mov    0x801051b4,%eax
80102294:	8d 50 01             	lea    0x1(%eax),%edx
80102297:	85 c0                	test   %eax,%eax
80102299:	89 15 b4 51 10 80    	mov    %edx,0x801051b4
8010229f:	74 47                	je     801022e8 <cpunum+0x68>
      cprintf("cpu called from %x with interrupts enabled\n",
        __builtin_return_address(0));
  }

  if (!lapic)
801022a1:	a1 7c d2 10 80       	mov    0x8010d27c,%eax
801022a6:	85 c0                	test   %eax,%eax
801022a8:	74 5a                	je     80102304 <cpunum+0x84>
    return 0;

  apicid = lapic[ID] >> 24;
801022aa:	8b 58 20             	mov    0x20(%eax),%ebx
  for (i = 0; i < ncpu; ++i) {
801022ad:	8b 35 e0 d3 10 80    	mov    0x8010d3e0,%esi
  }

  if (!lapic)
    return 0;

  apicid = lapic[ID] >> 24;
801022b3:	c1 eb 18             	shr    $0x18,%ebx
  for (i = 0; i < ncpu; ++i) {
801022b6:	85 f6                	test   %esi,%esi
801022b8:	7e 53                	jle    8010230d <cpunum+0x8d>
    if (cpus[i].apicid == apicid)
801022ba:	0f b6 05 80 d3 10 80 	movzbl 0x8010d380,%eax
801022c1:	39 d8                	cmp    %ebx,%eax
801022c3:	74 3f                	je     80102304 <cpunum+0x84>
801022c5:	ba 8c d3 10 80       	mov    $0x8010d38c,%edx

  if (!lapic)
    return 0;

  apicid = lapic[ID] >> 24;
  for (i = 0; i < ncpu; ++i) {
801022ca:	31 c0                	xor    %eax,%eax
801022cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801022d0:	83 c0 01             	add    $0x1,%eax
801022d3:	39 f0                	cmp    %esi,%eax
801022d5:	74 36                	je     8010230d <cpunum+0x8d>
    if (cpus[i].apicid == apicid)
801022d7:	0f b6 0a             	movzbl (%edx),%ecx
801022da:	83 c2 0c             	add    $0xc,%edx
801022dd:	39 d9                	cmp    %ebx,%ecx
801022df:	75 ef                	jne    801022d0 <cpunum+0x50>
      return i;
  }
  panic("unknown apicid\n");
}
801022e1:	83 c4 10             	add    $0x10,%esp
801022e4:	5b                   	pop    %ebx
801022e5:	5e                   	pop    %esi
801022e6:	5d                   	pop    %ebp
801022e7:	c3                   	ret    
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
    static int n;
    if(n++ == 0)
      cprintf("cpu called from %x with interrupts enabled\n",
801022e8:	8b 45 04             	mov    0x4(%ebp),%eax
801022eb:	c7 04 24 6c 39 10 80 	movl   $0x8010396c,(%esp)
801022f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801022f6:	e8 55 e3 ff ff       	call   80100650 <cprintf>
        __builtin_return_address(0));
  }

  if (!lapic)
801022fb:	a1 7c d2 10 80       	mov    0x8010d27c,%eax
80102300:	85 c0                	test   %eax,%eax
80102302:	75 a6                	jne    801022aa <cpunum+0x2a>
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
      return i;
  }
  panic("unknown apicid\n");
}
80102304:	83 c4 10             	add    $0x10,%esp
      cprintf("cpu called from %x with interrupts enabled\n",
        __builtin_return_address(0));
  }

  if (!lapic)
    return 0;
80102307:	31 c0                	xor    %eax,%eax
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
      return i;
  }
  panic("unknown apicid\n");
}
80102309:	5b                   	pop    %ebx
8010230a:	5e                   	pop    %esi
8010230b:	5d                   	pop    %ebp
8010230c:	c3                   	ret    
  apicid = lapic[ID] >> 24;
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
      return i;
  }
  panic("unknown apicid\n");
8010230d:	c7 04 24 98 39 10 80 	movl   $0x80103998,(%esp)
80102314:	e8 47 e0 ff ff       	call   80100360 <panic>
80102319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102320 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
80102320:	a1 7c d2 10 80       	mov    0x8010d27c,%eax
}

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102325:	55                   	push   %ebp
80102326:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102328:	85 c0                	test   %eax,%eax
8010232a:	74 0d                	je     80102339 <lapiceoi+0x19>
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010232c:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102333:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102336:	8b 40 20             	mov    0x20(%eax),%eax
void
lapiceoi(void)
{
  if(lapic)
    lapicw(EOI, 0);
}
80102339:	5d                   	pop    %ebp
8010233a:	c3                   	ret    
8010233b:	90                   	nop
8010233c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102340 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102340:	55                   	push   %ebp
80102341:	89 e5                	mov    %esp,%ebp
}
80102343:	5d                   	pop    %ebp
80102344:	c3                   	ret    
80102345:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102349:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102350 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102350:	55                   	push   %ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102351:	ba 70 00 00 00       	mov    $0x70,%edx
80102356:	89 e5                	mov    %esp,%ebp
80102358:	b8 0f 00 00 00       	mov    $0xf,%eax
8010235d:	53                   	push   %ebx
8010235e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80102361:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80102364:	ee                   	out    %al,(%dx)
80102365:	b8 0a 00 00 00       	mov    $0xa,%eax
8010236a:	b2 71                	mov    $0x71,%dl
8010236c:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
8010236d:	31 c0                	xor    %eax,%eax
8010236f:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
80102375:	89 d8                	mov    %ebx,%eax
80102377:	c1 e8 04             	shr    $0x4,%eax
8010237a:	66 a3 69 04 00 80    	mov    %ax,0x80000469
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102380:	a1 7c d2 10 80       	mov    0x8010d27c,%eax
  wrv[0] = 0;
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102385:	c1 e1 18             	shl    $0x18,%ecx
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
80102388:	c1 eb 0c             	shr    $0xc,%ebx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010238b:	89 88 10 03 00 00    	mov    %ecx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102391:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102394:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
8010239b:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010239e:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
801023a1:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
801023a8:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
801023ab:	8b 50 20             	mov    0x20(%eax),%edx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
801023ae:	89 88 10 03 00 00    	mov    %ecx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
801023b4:	8b 50 20             	mov    0x20(%eax),%edx
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
801023b7:	89 da                	mov    %ebx,%edx
801023b9:	80 ce 06             	or     $0x6,%dh
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
801023bc:	89 90 00 03 00 00    	mov    %edx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
801023c2:	8b 58 20             	mov    0x20(%eax),%ebx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
801023c5:	89 88 10 03 00 00    	mov    %ecx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
801023cb:	8b 48 20             	mov    0x20(%eax),%ecx
volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
  lapic[index] = value;
801023ce:	89 90 00 03 00 00    	mov    %edx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
801023d4:	8b 40 20             	mov    0x20(%eax),%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801023d7:	5b                   	pop    %ebx
801023d8:	5d                   	pop    %ebp
801023d9:	c3                   	ret    
801023da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801023e0 <cmostime>:
  r->year   = cmos_read(YEAR);
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801023e0:	55                   	push   %ebp
801023e1:	ba 70 00 00 00       	mov    $0x70,%edx
801023e6:	89 e5                	mov    %esp,%ebp
801023e8:	b8 0b 00 00 00       	mov    $0xb,%eax
801023ed:	57                   	push   %edi
801023ee:	56                   	push   %esi
801023ef:	53                   	push   %ebx
801023f0:	83 ec 4c             	sub    $0x4c,%esp
801023f3:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801023f4:	b2 71                	mov    $0x71,%dl
801023f6:	ec                   	in     (%dx),%al
801023f7:	88 45 b7             	mov    %al,-0x49(%ebp)
801023fa:	8d 5d b8             	lea    -0x48(%ebp),%ebx
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
801023fd:	80 65 b7 04          	andb   $0x4,-0x49(%ebp)
80102401:	8d 7d d0             	lea    -0x30(%ebp),%edi
80102404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102408:	be 70 00 00 00       	mov    $0x70,%esi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010240d:	89 d8                	mov    %ebx,%eax
8010240f:	e8 fc fc ff ff       	call   80102110 <fill_rtcdate>
80102414:	b8 0a 00 00 00       	mov    $0xa,%eax
80102419:	89 f2                	mov    %esi,%edx
8010241b:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010241c:	ba 71 00 00 00       	mov    $0x71,%edx
80102421:	ec                   	in     (%dx),%al
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102422:	84 c0                	test   %al,%al
80102424:	78 e7                	js     8010240d <cmostime+0x2d>
        continue;
    fill_rtcdate(&t2);
80102426:	89 f8                	mov    %edi,%eax
80102428:	e8 e3 fc ff ff       	call   80102110 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010242d:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80102434:	00 
80102435:	89 7c 24 04          	mov    %edi,0x4(%esp)
80102439:	89 1c 24             	mov    %ebx,(%esp)
8010243c:	e8 8f 0e 00 00       	call   801032d0 <memcmp>
80102441:	85 c0                	test   %eax,%eax
80102443:	75 c3                	jne    80102408 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
80102445:	80 7d b7 00          	cmpb   $0x0,-0x49(%ebp)
80102449:	75 78                	jne    801024c3 <cmostime+0xe3>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010244b:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010244e:	89 c2                	mov    %eax,%edx
80102450:	83 e0 0f             	and    $0xf,%eax
80102453:	c1 ea 04             	shr    $0x4,%edx
80102456:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102459:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010245c:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
8010245f:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102462:	89 c2                	mov    %eax,%edx
80102464:	83 e0 0f             	and    $0xf,%eax
80102467:	c1 ea 04             	shr    $0x4,%edx
8010246a:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010246d:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102470:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102473:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102476:	89 c2                	mov    %eax,%edx
80102478:	83 e0 0f             	and    $0xf,%eax
8010247b:	c1 ea 04             	shr    $0x4,%edx
8010247e:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102481:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102484:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102487:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010248a:	89 c2                	mov    %eax,%edx
8010248c:	83 e0 0f             	and    $0xf,%eax
8010248f:	c1 ea 04             	shr    $0x4,%edx
80102492:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102495:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102498:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
8010249b:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010249e:	89 c2                	mov    %eax,%edx
801024a0:	83 e0 0f             	and    $0xf,%eax
801024a3:	c1 ea 04             	shr    $0x4,%edx
801024a6:	8d 14 92             	lea    (%edx,%edx,4),%edx
801024a9:	8d 04 50             	lea    (%eax,%edx,2),%eax
801024ac:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
801024af:	8b 45 cc             	mov    -0x34(%ebp),%eax
801024b2:	89 c2                	mov    %eax,%edx
801024b4:	83 e0 0f             	and    $0xf,%eax
801024b7:	c1 ea 04             	shr    $0x4,%edx
801024ba:	8d 14 92             	lea    (%edx,%edx,4),%edx
801024bd:	8d 04 50             	lea    (%eax,%edx,2),%eax
801024c0:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
801024c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801024c6:	8b 45 b8             	mov    -0x48(%ebp),%eax
801024c9:	89 01                	mov    %eax,(%ecx)
801024cb:	8b 45 bc             	mov    -0x44(%ebp),%eax
801024ce:	89 41 04             	mov    %eax,0x4(%ecx)
801024d1:	8b 45 c0             	mov    -0x40(%ebp),%eax
801024d4:	89 41 08             	mov    %eax,0x8(%ecx)
801024d7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801024da:	89 41 0c             	mov    %eax,0xc(%ecx)
801024dd:	8b 45 c8             	mov    -0x38(%ebp),%eax
801024e0:	89 41 10             	mov    %eax,0x10(%ecx)
801024e3:	8b 45 cc             	mov    -0x34(%ebp),%eax
801024e6:	89 41 14             	mov    %eax,0x14(%ecx)
  r->year += 2000;
801024e9:	81 41 14 d0 07 00 00 	addl   $0x7d0,0x14(%ecx)
}
801024f0:	83 c4 4c             	add    $0x4c,%esp
801024f3:	5b                   	pop    %ebx
801024f4:	5e                   	pop    %esi
801024f5:	5f                   	pop    %edi
801024f6:	5d                   	pop    %ebp
801024f7:	c3                   	ret    
801024f8:	66 90                	xchg   %ax,%ax
801024fa:	66 90                	xchg   %ax,%ax
801024fc:	66 90                	xchg   %ax,%ax
801024fe:	66 90                	xchg   %ax,%ax

80102500 <install_trans>:
}

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102500:	55                   	push   %ebp
80102501:	89 e5                	mov    %esp,%ebp
80102503:	57                   	push   %edi
80102504:	56                   	push   %esi
80102505:	53                   	push   %ebx
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102506:	31 db                	xor    %ebx,%ebx
}

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102508:	83 ec 1c             	sub    $0x1c,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010250b:	a1 c8 d2 10 80       	mov    0x8010d2c8,%eax
80102510:	85 c0                	test   %eax,%eax
80102512:	7e 78                	jle    8010258c <install_trans+0x8c>
80102514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102518:	a1 b4 d2 10 80       	mov    0x8010d2b4,%eax
8010251d:	01 d8                	add    %ebx,%eax
8010251f:	83 c0 01             	add    $0x1,%eax
80102522:	89 44 24 04          	mov    %eax,0x4(%esp)
80102526:	a1 c4 d2 10 80       	mov    0x8010d2c4,%eax
8010252b:	89 04 24             	mov    %eax,(%esp)
8010252e:	e8 9d db ff ff       	call   801000d0 <bread>
80102533:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102535:	8b 04 9d cc d2 10 80 	mov    -0x7fef2d34(,%ebx,4),%eax
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010253c:	83 c3 01             	add    $0x1,%ebx
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010253f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102543:	a1 c4 d2 10 80       	mov    0x8010d2c4,%eax
80102548:	89 04 24             	mov    %eax,(%esp)
8010254b:	e8 80 db ff ff       	call   801000d0 <bread>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102550:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80102557:	00 
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102558:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010255a:	8d 47 5c             	lea    0x5c(%edi),%eax
8010255d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102561:	8d 46 5c             	lea    0x5c(%esi),%eax
80102564:	89 04 24             	mov    %eax,(%esp)
80102567:	e8 b4 0d 00 00       	call   80103320 <memmove>
    bwrite(dbuf);  // write dst to disk
8010256c:	89 34 24             	mov    %esi,(%esp)
8010256f:	e8 2c dc ff ff       	call   801001a0 <bwrite>
    brelse(lbuf);
80102574:	89 3c 24             	mov    %edi,(%esp)
80102577:	e8 64 dc ff ff       	call   801001e0 <brelse>
    brelse(dbuf);
8010257c:	89 34 24             	mov    %esi,(%esp)
8010257f:	e8 5c dc ff ff       	call   801001e0 <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102584:	39 1d c8 d2 10 80    	cmp    %ebx,0x8010d2c8
8010258a:	7f 8c                	jg     80102518 <install_trans+0x18>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
8010258c:	83 c4 1c             	add    $0x1c,%esp
8010258f:	5b                   	pop    %ebx
80102590:	5e                   	pop    %esi
80102591:	5f                   	pop    %edi
80102592:	5d                   	pop    %ebp
80102593:	c3                   	ret    
80102594:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010259a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801025a0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801025a0:	55                   	push   %ebp
801025a1:	89 e5                	mov    %esp,%ebp
801025a3:	57                   	push   %edi
801025a4:	56                   	push   %esi
801025a5:	53                   	push   %ebx
801025a6:	83 ec 1c             	sub    $0x1c,%esp
  struct buf *buf = bread(log.dev, log.start);
801025a9:	a1 b4 d2 10 80       	mov    0x8010d2b4,%eax
801025ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801025b2:	a1 c4 d2 10 80       	mov    0x8010d2c4,%eax
801025b7:	89 04 24             	mov    %eax,(%esp)
801025ba:	e8 11 db ff ff       	call   801000d0 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801025bf:	8b 1d c8 d2 10 80    	mov    0x8010d2c8,%ebx
  for (i = 0; i < log.lh.n; i++) {
801025c5:	31 d2                	xor    %edx,%edx
801025c7:	85 db                	test   %ebx,%ebx
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
801025c9:	89 c7                	mov    %eax,%edi
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801025cb:	89 58 5c             	mov    %ebx,0x5c(%eax)
801025ce:	8d 70 5c             	lea    0x5c(%eax),%esi
  for (i = 0; i < log.lh.n; i++) {
801025d1:	7e 17                	jle    801025ea <write_head+0x4a>
801025d3:	90                   	nop
801025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    hb->block[i] = log.lh.block[i];
801025d8:	8b 0c 95 cc d2 10 80 	mov    -0x7fef2d34(,%edx,4),%ecx
801025df:	89 4c 96 04          	mov    %ecx,0x4(%esi,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801025e3:	83 c2 01             	add    $0x1,%edx
801025e6:	39 da                	cmp    %ebx,%edx
801025e8:	75 ee                	jne    801025d8 <write_head+0x38>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801025ea:	89 3c 24             	mov    %edi,(%esp)
801025ed:	e8 ae db ff ff       	call   801001a0 <bwrite>
  brelse(buf);
801025f2:	89 3c 24             	mov    %edi,(%esp)
801025f5:	e8 e6 db ff ff       	call   801001e0 <brelse>
}
801025fa:	83 c4 1c             	add    $0x1c,%esp
801025fd:	5b                   	pop    %ebx
801025fe:	5e                   	pop    %esi
801025ff:	5f                   	pop    %edi
80102600:	5d                   	pop    %ebp
80102601:	c3                   	ret    
80102602:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102609:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102610 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102610:	55                   	push   %ebp
80102611:	89 e5                	mov    %esp,%ebp
80102613:	56                   	push   %esi
80102614:	53                   	push   %ebx
80102615:	83 ec 30             	sub    $0x30,%esp
80102618:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010261b:	c7 44 24 04 a8 39 10 	movl   $0x801039a8,0x4(%esp)
80102622:	80 
80102623:	c7 04 24 80 d2 10 80 	movl   $0x8010d280,(%esp)
8010262a:	e8 71 0a 00 00       	call   801030a0 <initlock>
  readsb(dev, &sb);
8010262f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102632:	89 44 24 04          	mov    %eax,0x4(%esp)
80102636:	89 1c 24             	mov    %ebx,(%esp)
80102639:	e8 c2 e9 ff ff       	call   80101000 <readsb>
  log.start = sb.logstart;
8010263e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  log.size = sb.nlog;
80102641:	8b 55 e8             	mov    -0x18(%ebp),%edx

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
80102644:	89 1c 24             	mov    %ebx,(%esp)
  struct superblock sb;
  initlock(&log.lock, "log");
  readsb(dev, &sb);
  log.start = sb.logstart;
  log.size = sb.nlog;
  log.dev = dev;
80102647:	89 1d c4 d2 10 80    	mov    %ebx,0x8010d2c4

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
8010264d:	89 44 24 04          	mov    %eax,0x4(%esp)

  struct superblock sb;
  initlock(&log.lock, "log");
  readsb(dev, &sb);
  log.start = sb.logstart;
  log.size = sb.nlog;
80102651:	89 15 b8 d2 10 80    	mov    %edx,0x8010d2b8
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
  readsb(dev, &sb);
  log.start = sb.logstart;
80102657:	a3 b4 d2 10 80       	mov    %eax,0x8010d2b4

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
8010265c:	e8 6f da ff ff       	call   801000d0 <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80102661:	31 d2                	xor    %edx,%edx
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102663:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102666:	8d 70 5c             	lea    0x5c(%eax),%esi
  for (i = 0; i < log.lh.n; i++) {
80102669:	85 db                	test   %ebx,%ebx
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
8010266b:	89 1d c8 d2 10 80    	mov    %ebx,0x8010d2c8
  for (i = 0; i < log.lh.n; i++) {
80102671:	7e 17                	jle    8010268a <initlog+0x7a>
80102673:	90                   	nop
80102674:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    log.lh.block[i] = lh->block[i];
80102678:	8b 4c 96 04          	mov    0x4(%esi,%edx,4),%ecx
8010267c:	89 0c 95 cc d2 10 80 	mov    %ecx,-0x7fef2d34(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80102683:	83 c2 01             	add    $0x1,%edx
80102686:	39 da                	cmp    %ebx,%edx
80102688:	75 ee                	jne    80102678 <initlog+0x68>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010268a:	89 04 24             	mov    %eax,(%esp)
8010268d:	e8 4e db ff ff       	call   801001e0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102692:	e8 69 fe ff ff       	call   80102500 <install_trans>
  log.lh.n = 0;
80102697:	c7 05 c8 d2 10 80 00 	movl   $0x0,0x8010d2c8
8010269e:	00 00 00 
  write_head(); // clear the log
801026a1:	e8 fa fe ff ff       	call   801025a0 <write_head>
  readsb(dev, &sb);
  log.start = sb.logstart;
  log.size = sb.nlog;
  log.dev = dev;
  recover_from_log();
}
801026a6:	83 c4 30             	add    $0x30,%esp
801026a9:	5b                   	pop    %ebx
801026aa:	5e                   	pop    %esi
801026ab:	5d                   	pop    %ebp
801026ac:	c3                   	ret    
801026ad:	8d 76 00             	lea    0x0(%esi),%esi

801026b0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
801026b0:	55                   	push   %ebp
801026b1:	89 e5                	mov    %esp,%ebp
801026b3:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801026b6:	c7 04 24 80 d2 10 80 	movl   $0x8010d280,(%esp)
801026bd:	e8 5e 0a 00 00       	call   80103120 <acquire>
801026c2:	eb 18                	jmp    801026dc <begin_op+0x2c>
801026c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
801026c8:	c7 44 24 04 80 d2 10 	movl   $0x8010d280,0x4(%esp)
801026cf:	80 
801026d0:	c7 04 24 80 d2 10 80 	movl   $0x8010d280,(%esp)
801026d7:	e8 24 07 00 00       	call   80102e00 <sleep>
void
begin_op(void)
{
  acquire(&log.lock);
  while(1){
    if(log.committing){
801026dc:	a1 c0 d2 10 80       	mov    0x8010d2c0,%eax
801026e1:	85 c0                	test   %eax,%eax
801026e3:	75 e3                	jne    801026c8 <begin_op+0x18>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801026e5:	a1 bc d2 10 80       	mov    0x8010d2bc,%eax
801026ea:	8b 15 c8 d2 10 80    	mov    0x8010d2c8,%edx
801026f0:	83 c0 01             	add    $0x1,%eax
801026f3:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026f6:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
801026f9:	83 fa 1e             	cmp    $0x1e,%edx
801026fc:	7f ca                	jg     801026c8 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
801026fe:	c7 04 24 80 d2 10 80 	movl   $0x8010d280,(%esp)
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
80102705:	a3 bc d2 10 80       	mov    %eax,0x8010d2bc
      release(&log.lock);
8010270a:	e8 21 0b 00 00       	call   80103230 <release>
      break;
    }
  }
}
8010270f:	c9                   	leave  
80102710:	c3                   	ret    
80102711:	eb 0d                	jmp    80102720 <end_op>
80102713:	90                   	nop
80102714:	90                   	nop
80102715:	90                   	nop
80102716:	90                   	nop
80102717:	90                   	nop
80102718:	90                   	nop
80102719:	90                   	nop
8010271a:	90                   	nop
8010271b:	90                   	nop
8010271c:	90                   	nop
8010271d:	90                   	nop
8010271e:	90                   	nop
8010271f:	90                   	nop

80102720 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102720:	55                   	push   %ebp
80102721:	89 e5                	mov    %esp,%ebp
80102723:	57                   	push   %edi
80102724:	56                   	push   %esi
80102725:	53                   	push   %ebx
80102726:	83 ec 1c             	sub    $0x1c,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102729:	c7 04 24 80 d2 10 80 	movl   $0x8010d280,(%esp)
80102730:	e8 eb 09 00 00       	call   80103120 <acquire>
  log.outstanding -= 1;
80102735:	a1 bc d2 10 80       	mov    0x8010d2bc,%eax
  if(log.committing)
8010273a:	8b 15 c0 d2 10 80    	mov    0x8010d2c0,%edx
end_op(void)
{
  int do_commit = 0;

  acquire(&log.lock);
  log.outstanding -= 1;
80102740:	83 e8 01             	sub    $0x1,%eax
  if(log.committing)
80102743:	85 d2                	test   %edx,%edx
end_op(void)
{
  int do_commit = 0;

  acquire(&log.lock);
  log.outstanding -= 1;
80102745:	a3 bc d2 10 80       	mov    %eax,0x8010d2bc
  if(log.committing)
8010274a:	0f 85 f3 00 00 00    	jne    80102843 <end_op+0x123>
    panic("log.committing");
  if(log.outstanding == 0){
80102750:	85 c0                	test   %eax,%eax
80102752:	0f 85 cb 00 00 00    	jne    80102823 <end_op+0x103>
    log.committing = 1;
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
  }
  release(&log.lock);
80102758:	c7 04 24 80 d2 10 80 	movl   $0x8010d280,(%esp)
}

static void
commit()
{
  if (log.lh.n > 0) {
8010275f:	31 db                	xor    %ebx,%ebx
  log.outstanding -= 1;
  if(log.committing)
    panic("log.committing");
  if(log.outstanding == 0){
    do_commit = 1;
    log.committing = 1;
80102761:	c7 05 c0 d2 10 80 01 	movl   $0x1,0x8010d2c0
80102768:	00 00 00 
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
  }
  release(&log.lock);
8010276b:	e8 c0 0a 00 00       	call   80103230 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102770:	a1 c8 d2 10 80       	mov    0x8010d2c8,%eax
80102775:	85 c0                	test   %eax,%eax
80102777:	0f 8e 90 00 00 00    	jle    8010280d <end_op+0xed>
8010277d:	8d 76 00             	lea    0x0(%esi),%esi
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102780:	a1 b4 d2 10 80       	mov    0x8010d2b4,%eax
80102785:	01 d8                	add    %ebx,%eax
80102787:	83 c0 01             	add    $0x1,%eax
8010278a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010278e:	a1 c4 d2 10 80       	mov    0x8010d2c4,%eax
80102793:	89 04 24             	mov    %eax,(%esp)
80102796:	e8 35 d9 ff ff       	call   801000d0 <bread>
8010279b:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010279d:	8b 04 9d cc d2 10 80 	mov    -0x7fef2d34(,%ebx,4),%eax
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801027a4:	83 c3 01             	add    $0x1,%ebx
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801027a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801027ab:	a1 c4 d2 10 80       	mov    0x8010d2c4,%eax
801027b0:	89 04 24             	mov    %eax,(%esp)
801027b3:	e8 18 d9 ff ff       	call   801000d0 <bread>
    memmove(to->data, from->data, BSIZE);
801027b8:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801027bf:	00 
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801027c0:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
801027c2:	8d 40 5c             	lea    0x5c(%eax),%eax
801027c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801027c9:	8d 46 5c             	lea    0x5c(%esi),%eax
801027cc:	89 04 24             	mov    %eax,(%esp)
801027cf:	e8 4c 0b 00 00       	call   80103320 <memmove>
    bwrite(to);  // write the log
801027d4:	89 34 24             	mov    %esi,(%esp)
801027d7:	e8 c4 d9 ff ff       	call   801001a0 <bwrite>
    brelse(from);
801027dc:	89 3c 24             	mov    %edi,(%esp)
801027df:	e8 fc d9 ff ff       	call   801001e0 <brelse>
    brelse(to);
801027e4:	89 34 24             	mov    %esi,(%esp)
801027e7:	e8 f4 d9 ff ff       	call   801001e0 <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801027ec:	3b 1d c8 d2 10 80    	cmp    0x8010d2c8,%ebx
801027f2:	7c 8c                	jl     80102780 <end_op+0x60>
static void
commit()
{
  if (log.lh.n > 0) {
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
801027f4:	e8 a7 fd ff ff       	call   801025a0 <write_head>
    install_trans(); // Now install writes to home locations
801027f9:	e8 02 fd ff ff       	call   80102500 <install_trans>
    log.lh.n = 0;
801027fe:	c7 05 c8 d2 10 80 00 	movl   $0x0,0x8010d2c8
80102805:	00 00 00 
    write_head();    // Erase the transaction from the log
80102808:	e8 93 fd ff ff       	call   801025a0 <write_head>

  if(do_commit){
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
    acquire(&log.lock);
8010280d:	c7 04 24 80 d2 10 80 	movl   $0x8010d280,(%esp)
80102814:	e8 07 09 00 00       	call   80103120 <acquire>
    log.committing = 0;
80102819:	c7 05 c0 d2 10 80 00 	movl   $0x0,0x8010d2c0
80102820:	00 00 00 
    wakeup(&log);
80102823:	c7 04 24 80 d2 10 80 	movl   $0x8010d280,(%esp)
8010282a:	e8 91 06 00 00       	call   80102ec0 <wakeup>
    release(&log.lock);
8010282f:	c7 04 24 80 d2 10 80 	movl   $0x8010d280,(%esp)
80102836:	e8 f5 09 00 00       	call   80103230 <release>
  }
}
8010283b:	83 c4 1c             	add    $0x1c,%esp
8010283e:	5b                   	pop    %ebx
8010283f:	5e                   	pop    %esi
80102840:	5f                   	pop    %edi
80102841:	5d                   	pop    %ebp
80102842:	c3                   	ret    
  int do_commit = 0;

  acquire(&log.lock);
  log.outstanding -= 1;
  if(log.committing)
    panic("log.committing");
80102843:	c7 04 24 ac 39 10 80 	movl   $0x801039ac,(%esp)
8010284a:	e8 11 db ff ff       	call   80100360 <panic>
8010284f:	90                   	nop

80102850 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102850:	55                   	push   %ebp
80102851:	89 e5                	mov    %esp,%ebp
80102853:	53                   	push   %ebx
80102854:	83 ec 14             	sub    $0x14,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102857:	a1 c8 d2 10 80       	mov    0x8010d2c8,%eax
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010285c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010285f:	83 f8 1d             	cmp    $0x1d,%eax
80102862:	0f 8f 98 00 00 00    	jg     80102900 <log_write+0xb0>
80102868:	8b 0d b8 d2 10 80    	mov    0x8010d2b8,%ecx
8010286e:	8d 51 ff             	lea    -0x1(%ecx),%edx
80102871:	39 d0                	cmp    %edx,%eax
80102873:	0f 8d 87 00 00 00    	jge    80102900 <log_write+0xb0>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102879:	a1 bc d2 10 80       	mov    0x8010d2bc,%eax
8010287e:	85 c0                	test   %eax,%eax
80102880:	0f 8e 86 00 00 00    	jle    8010290c <log_write+0xbc>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102886:	c7 04 24 80 d2 10 80 	movl   $0x8010d280,(%esp)
8010288d:	e8 8e 08 00 00       	call   80103120 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102892:	8b 15 c8 d2 10 80    	mov    0x8010d2c8,%edx
80102898:	83 fa 00             	cmp    $0x0,%edx
8010289b:	7e 54                	jle    801028f1 <log_write+0xa1>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010289d:	8b 4b 08             	mov    0x8(%ebx),%ecx
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801028a0:	31 c0                	xor    %eax,%eax
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801028a2:	39 0d cc d2 10 80    	cmp    %ecx,0x8010d2cc
801028a8:	75 0f                	jne    801028b9 <log_write+0x69>
801028aa:	eb 3c                	jmp    801028e8 <log_write+0x98>
801028ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801028b0:	39 0c 85 cc d2 10 80 	cmp    %ecx,-0x7fef2d34(,%eax,4)
801028b7:	74 2f                	je     801028e8 <log_write+0x98>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801028b9:	83 c0 01             	add    $0x1,%eax
801028bc:	39 d0                	cmp    %edx,%eax
801028be:	75 f0                	jne    801028b0 <log_write+0x60>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
801028c0:	89 0c 95 cc d2 10 80 	mov    %ecx,-0x7fef2d34(,%edx,4)
  if (i == log.lh.n)
    log.lh.n++;
801028c7:	83 c2 01             	add    $0x1,%edx
801028ca:	89 15 c8 d2 10 80    	mov    %edx,0x8010d2c8
  b->flags |= B_DIRTY; // prevent eviction
801028d0:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
801028d3:	c7 45 08 80 d2 10 80 	movl   $0x8010d280,0x8(%ebp)
}
801028da:	83 c4 14             	add    $0x14,%esp
801028dd:	5b                   	pop    %ebx
801028de:	5d                   	pop    %ebp
  }
  log.lh.block[i] = b->blockno;
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
  release(&log.lock);
801028df:	e9 4c 09 00 00       	jmp    80103230 <release>
801028e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
801028e8:	89 0c 85 cc d2 10 80 	mov    %ecx,-0x7fef2d34(,%eax,4)
801028ef:	eb df                	jmp    801028d0 <log_write+0x80>
801028f1:	8b 43 08             	mov    0x8(%ebx),%eax
801028f4:	a3 cc d2 10 80       	mov    %eax,0x8010d2cc
  if (i == log.lh.n)
801028f9:	75 d5                	jne    801028d0 <log_write+0x80>
801028fb:	eb ca                	jmp    801028c7 <log_write+0x77>
801028fd:	8d 76 00             	lea    0x0(%esi),%esi
log_write(struct buf *b)
{
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
80102900:	c7 04 24 bb 39 10 80 	movl   $0x801039bb,(%esp)
80102907:	e8 54 da ff ff       	call   80100360 <panic>
  if (log.outstanding < 1)
    panic("log_write outside of trans");
8010290c:	c7 04 24 d1 39 10 80 	movl   $0x801039d1,(%esp)
80102913:	e8 48 da ff ff       	call   80100360 <panic>
80102918:	66 90                	xchg   %ax,%ax
8010291a:	66 90                	xchg   %ax,%ax
8010291c:	66 90                	xchg   %ax,%ax
8010291e:	66 90                	xchg   %ax,%ax

80102920 <main>:

// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void) {
80102920:	55                   	push   %ebp
80102921:	89 e5                	mov    %esp,%ebp
80102923:	83 e4 f0             	and    $0xfffffff0,%esp
80102926:	83 ec 10             	sub    $0x10,%esp
  // end to 4MB.
  kinit1(end, P2V(4*1024*1024));
80102929:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80102930:	80 
80102931:	c7 04 24 38 dd 10 80 	movl   $0x8010dd38,(%esp)
80102938:	e8 03 f7 ff ff       	call   80102040 <kinit1>
  kvmalloc();
8010293d:	e8 8e 0d 00 00       	call   801036d0 <kvmalloc>
  return 0;
}
80102942:	31 c0                	xor    %eax,%eax
80102944:	c9                   	leave  
80102945:	c3                   	ret    
80102946:	66 90                	xchg   %ax,%ax
80102948:	66 90                	xchg   %ax,%ax
8010294a:	66 90                	xchg   %ax,%ax
8010294c:	66 90                	xchg   %ax,%ax
8010294e:	66 90                	xchg   %ax,%ax

80102950 <picenable>:
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
80102950:	55                   	push   %ebp
  picsetmask(irqmask & ~(1<<irq));
80102951:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  outb(IO_PIC2+1, mask >> 8);
}

void
picenable(int irq)
{
80102956:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102958:	ba 21 00 00 00       	mov    $0x21,%edx
  picsetmask(irqmask & ~(1<<irq));
8010295d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80102960:	d3 c0                	rol    %cl,%eax
80102962:	66 23 05 00 50 10 80 	and    0x80105000,%ax
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
  irqmask = mask;
80102969:	66 a3 00 50 10 80    	mov    %ax,0x80105000
8010296f:	ee                   	out    %al,(%dx)
  outb(IO_PIC1+1, mask);
  outb(IO_PIC2+1, mask >> 8);
80102970:	66 c1 e8 08          	shr    $0x8,%ax
80102974:	b2 a1                	mov    $0xa1,%dl
80102976:	ee                   	out    %al,(%dx)

void
picenable(int irq)
{
  picsetmask(irqmask & ~(1<<irq));
}
80102977:	5d                   	pop    %ebp
80102978:	c3                   	ret    
80102979:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102980 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80102980:	55                   	push   %ebp
80102981:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102986:	89 e5                	mov    %esp,%ebp
80102988:	57                   	push   %edi
80102989:	56                   	push   %esi
8010298a:	53                   	push   %ebx
8010298b:	bb 21 00 00 00       	mov    $0x21,%ebx
80102990:	89 da                	mov    %ebx,%edx
80102992:	ee                   	out    %al,(%dx)
80102993:	b9 a1 00 00 00       	mov    $0xa1,%ecx
80102998:	89 ca                	mov    %ecx,%edx
8010299a:	ee                   	out    %al,(%dx)
8010299b:	bf 11 00 00 00       	mov    $0x11,%edi
801029a0:	be 20 00 00 00       	mov    $0x20,%esi
801029a5:	89 f8                	mov    %edi,%eax
801029a7:	89 f2                	mov    %esi,%edx
801029a9:	ee                   	out    %al,(%dx)
801029aa:	b8 20 00 00 00       	mov    $0x20,%eax
801029af:	89 da                	mov    %ebx,%edx
801029b1:	ee                   	out    %al,(%dx)
801029b2:	b8 04 00 00 00       	mov    $0x4,%eax
801029b7:	ee                   	out    %al,(%dx)
801029b8:	b8 03 00 00 00       	mov    $0x3,%eax
801029bd:	ee                   	out    %al,(%dx)
801029be:	b3 a0                	mov    $0xa0,%bl
801029c0:	89 f8                	mov    %edi,%eax
801029c2:	89 da                	mov    %ebx,%edx
801029c4:	ee                   	out    %al,(%dx)
801029c5:	b8 28 00 00 00       	mov    $0x28,%eax
801029ca:	89 ca                	mov    %ecx,%edx
801029cc:	ee                   	out    %al,(%dx)
801029cd:	b8 02 00 00 00       	mov    $0x2,%eax
801029d2:	ee                   	out    %al,(%dx)
801029d3:	b8 03 00 00 00       	mov    $0x3,%eax
801029d8:	ee                   	out    %al,(%dx)
801029d9:	bf 68 00 00 00       	mov    $0x68,%edi
801029de:	89 f2                	mov    %esi,%edx
801029e0:	89 f8                	mov    %edi,%eax
801029e2:	ee                   	out    %al,(%dx)
801029e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
801029e8:	89 c8                	mov    %ecx,%eax
801029ea:	ee                   	out    %al,(%dx)
801029eb:	89 f8                	mov    %edi,%eax
801029ed:	89 da                	mov    %ebx,%edx
801029ef:	ee                   	out    %al,(%dx)
801029f0:	89 c8                	mov    %ecx,%eax
801029f2:	ee                   	out    %al,(%dx)
  outb(IO_PIC1, 0x0a);             // read IRR by default

  outb(IO_PIC2, 0x68);             // OCW3
  outb(IO_PIC2, 0x0a);             // OCW3

  if(irqmask != 0xFFFF)
801029f3:	0f b7 05 00 50 10 80 	movzwl 0x80105000,%eax
801029fa:	66 83 f8 ff          	cmp    $0xffff,%ax
801029fe:	74 0a                	je     80102a0a <picinit+0x8a>
80102a00:	b2 21                	mov    $0x21,%dl
80102a02:	ee                   	out    %al,(%dx)
static void
picsetmask(ushort mask)
{
  irqmask = mask;
  outb(IO_PIC1+1, mask);
  outb(IO_PIC2+1, mask >> 8);
80102a03:	66 c1 e8 08          	shr    $0x8,%ax
80102a07:	b2 a1                	mov    $0xa1,%dl
80102a09:	ee                   	out    %al,(%dx)
  outb(IO_PIC2, 0x68);             // OCW3
  outb(IO_PIC2, 0x0a);             // OCW3

  if(irqmask != 0xFFFF)
    picsetmask(irqmask);
}
80102a0a:	5b                   	pop    %ebx
80102a0b:	5e                   	pop    %esi
80102a0c:	5f                   	pop    %edi
80102a0d:	5d                   	pop    %ebp
80102a0e:	c3                   	ret    
80102a0f:	90                   	nop

80102a10 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102a10:	55                   	push   %ebp
80102a11:	89 e5                	mov    %esp,%ebp
80102a13:	57                   	push   %edi
80102a14:	56                   	push   %esi
80102a15:	53                   	push   %ebx
80102a16:	83 ec 1c             	sub    $0x1c,%esp
80102a19:	8b 75 08             	mov    0x8(%ebp),%esi
80102a1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102a1f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80102a25:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102a2b:	e8 a0 df ff ff       	call   801009d0 <filealloc>
80102a30:	85 c0                	test   %eax,%eax
80102a32:	89 06                	mov    %eax,(%esi)
80102a34:	0f 84 a4 00 00 00    	je     80102ade <pipealloc+0xce>
80102a3a:	e8 91 df ff ff       	call   801009d0 <filealloc>
80102a3f:	85 c0                	test   %eax,%eax
80102a41:	89 03                	mov    %eax,(%ebx)
80102a43:	0f 84 87 00 00 00    	je     80102ad0 <pipealloc+0xc0>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102a49:	e8 62 f6 ff ff       	call   801020b0 <kalloc>
80102a4e:	85 c0                	test   %eax,%eax
80102a50:	89 c7                	mov    %eax,%edi
80102a52:	74 7c                	je     80102ad0 <pipealloc+0xc0>
    goto bad;
  p->readopen = 1;
80102a54:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102a5b:	00 00 00 
  p->writeopen = 1;
80102a5e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102a65:	00 00 00 
  p->nwrite = 0;
80102a68:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102a6f:	00 00 00 
  p->nread = 0;
80102a72:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102a79:	00 00 00 
  initlock(&p->lock, "pipe");
80102a7c:	89 04 24             	mov    %eax,(%esp)
80102a7f:	c7 44 24 04 ec 39 10 	movl   $0x801039ec,0x4(%esp)
80102a86:	80 
80102a87:	e8 14 06 00 00       	call   801030a0 <initlock>
  (*f0)->type = FD_PIPE;
80102a8c:	8b 06                	mov    (%esi),%eax
80102a8e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102a94:	8b 06                	mov    (%esi),%eax
80102a96:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102a9a:	8b 06                	mov    (%esi),%eax
80102a9c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102aa0:	8b 06                	mov    (%esi),%eax
80102aa2:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102aa5:	8b 03                	mov    (%ebx),%eax
80102aa7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102aad:	8b 03                	mov    (%ebx),%eax
80102aaf:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102ab3:	8b 03                	mov    (%ebx),%eax
80102ab5:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102ab9:	8b 03                	mov    (%ebx),%eax
  return 0;
80102abb:	31 db                	xor    %ebx,%ebx
  (*f0)->writable = 0;
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
80102abd:	89 78 0c             	mov    %edi,0xc(%eax)
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
80102ac0:	83 c4 1c             	add    $0x1c,%esp
80102ac3:	89 d8                	mov    %ebx,%eax
80102ac5:	5b                   	pop    %ebx
80102ac6:	5e                   	pop    %esi
80102ac7:	5f                   	pop    %edi
80102ac8:	5d                   	pop    %ebp
80102ac9:	c3                   	ret    
80102aca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102ad0:	8b 06                	mov    (%esi),%eax
80102ad2:	85 c0                	test   %eax,%eax
80102ad4:	74 08                	je     80102ade <pipealloc+0xce>
    fileclose(*f0);
80102ad6:	89 04 24             	mov    %eax,(%esp)
80102ad9:	e8 b2 df ff ff       	call   80100a90 <fileclose>
  if(*f1)
80102ade:	8b 03                	mov    (%ebx),%eax
    fileclose(*f1);
  return -1;
80102ae0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
    fileclose(*f0);
  if(*f1)
80102ae5:	85 c0                	test   %eax,%eax
80102ae7:	74 d7                	je     80102ac0 <pipealloc+0xb0>
    fileclose(*f1);
80102ae9:	89 04 24             	mov    %eax,(%esp)
80102aec:	e8 9f df ff ff       	call   80100a90 <fileclose>
  return -1;
}
80102af1:	83 c4 1c             	add    $0x1c,%esp
80102af4:	89 d8                	mov    %ebx,%eax
80102af6:	5b                   	pop    %ebx
80102af7:	5e                   	pop    %esi
80102af8:	5f                   	pop    %edi
80102af9:	5d                   	pop    %ebp
80102afa:	c3                   	ret    
80102afb:	90                   	nop
80102afc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102b00 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102b00:	55                   	push   %ebp
80102b01:	89 e5                	mov    %esp,%ebp
80102b03:	56                   	push   %esi
80102b04:	53                   	push   %ebx
80102b05:	83 ec 10             	sub    $0x10,%esp
80102b08:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102b0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
80102b0e:	89 1c 24             	mov    %ebx,(%esp)
80102b11:	e8 0a 06 00 00       	call   80103120 <acquire>
  if(writable){
80102b16:	85 f6                	test   %esi,%esi
80102b18:	74 3e                	je     80102b58 <pipeclose+0x58>
    p->writeopen = 0;
    wakeup(&p->nread);
80102b1a:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
void
pipeclose(struct pipe *p, int writable)
{
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
80102b20:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102b27:	00 00 00 
    wakeup(&p->nread);
80102b2a:	89 04 24             	mov    %eax,(%esp)
80102b2d:	e8 8e 03 00 00       	call   80102ec0 <wakeup>
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102b32:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
80102b38:	85 d2                	test   %edx,%edx
80102b3a:	75 0a                	jne    80102b46 <pipeclose+0x46>
80102b3c:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80102b42:	85 c0                	test   %eax,%eax
80102b44:	74 32                	je     80102b78 <pipeclose+0x78>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102b46:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80102b49:	83 c4 10             	add    $0x10,%esp
80102b4c:	5b                   	pop    %ebx
80102b4d:	5e                   	pop    %esi
80102b4e:	5d                   	pop    %ebp
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102b4f:	e9 dc 06 00 00       	jmp    80103230 <release>
80102b54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
80102b58:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
80102b5e:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102b65:	00 00 00 
    wakeup(&p->nwrite);
80102b68:	89 04 24             	mov    %eax,(%esp)
80102b6b:	e8 50 03 00 00       	call   80102ec0 <wakeup>
80102b70:	eb c0                	jmp    80102b32 <pipeclose+0x32>
80102b72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
80102b78:	89 1c 24             	mov    %ebx,(%esp)
80102b7b:	e8 b0 06 00 00       	call   80103230 <release>
    kfree((char*)p);
80102b80:	89 5d 08             	mov    %ebx,0x8(%ebp)
  } else
    release(&p->lock);
}
80102b83:	83 c4 10             	add    $0x10,%esp
80102b86:	5b                   	pop    %ebx
80102b87:	5e                   	pop    %esi
80102b88:	5d                   	pop    %ebp
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
80102b89:	e9 c2 f3 ff ff       	jmp    80101f50 <kfree>
80102b8e:	66 90                	xchg   %ax,%ax

80102b90 <pipewrite>:
}

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102b90:	55                   	push   %ebp
80102b91:	89 e5                	mov    %esp,%ebp
80102b93:	57                   	push   %edi
80102b94:	56                   	push   %esi
80102b95:	53                   	push   %ebx
80102b96:	83 ec 1c             	sub    $0x1c,%esp
80102b99:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i;

  acquire(&p->lock);
80102b9c:	89 3c 24             	mov    %edi,(%esp)
80102b9f:	e8 7c 05 00 00       	call   80103120 <acquire>
  for(i = 0; i < n; i++){
80102ba4:	8b 45 10             	mov    0x10(%ebp),%eax
80102ba7:	85 c0                	test   %eax,%eax
80102ba9:	0f 8e c2 00 00 00    	jle    80102c71 <pipewrite+0xe1>
80102baf:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bb2:	8d b7 34 02 00 00    	lea    0x234(%edi),%esi
80102bb8:	8b 8f 38 02 00 00    	mov    0x238(%edi),%ecx
80102bbe:	8d 9f 38 02 00 00    	lea    0x238(%edi),%ebx
80102bc4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80102bc7:	03 45 10             	add    0x10(%ebp),%eax
80102bca:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102bcd:	8b 87 34 02 00 00    	mov    0x234(%edi),%eax
80102bd3:	8d 90 00 02 00 00    	lea    0x200(%eax),%edx
80102bd9:	39 d1                	cmp    %edx,%ecx
80102bdb:	0f 85 c4 00 00 00    	jne    80102ca5 <pipewrite+0x115>
      if(p->readopen == 0 || proc->killed){
80102be1:	8b 97 3c 02 00 00    	mov    0x23c(%edi),%edx
80102be7:	85 d2                	test   %edx,%edx
80102be9:	0f 84 a1 00 00 00    	je     80102c90 <pipewrite+0x100>
80102bef:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80102bf6:	8b 42 0c             	mov    0xc(%edx),%eax
80102bf9:	85 c0                	test   %eax,%eax
80102bfb:	74 22                	je     80102c1f <pipewrite+0x8f>
80102bfd:	e9 8e 00 00 00       	jmp    80102c90 <pipewrite+0x100>
80102c02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102c08:	8b 87 3c 02 00 00    	mov    0x23c(%edi),%eax
80102c0e:	85 c0                	test   %eax,%eax
80102c10:	74 7e                	je     80102c90 <pipewrite+0x100>
80102c12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102c18:	8b 48 0c             	mov    0xc(%eax),%ecx
80102c1b:	85 c9                	test   %ecx,%ecx
80102c1d:	75 71                	jne    80102c90 <pipewrite+0x100>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102c1f:	89 34 24             	mov    %esi,(%esp)
80102c22:	e8 99 02 00 00       	call   80102ec0 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102c27:	89 7c 24 04          	mov    %edi,0x4(%esp)
80102c2b:	89 1c 24             	mov    %ebx,(%esp)
80102c2e:	e8 cd 01 00 00       	call   80102e00 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102c33:	8b 87 34 02 00 00    	mov    0x234(%edi),%eax
80102c39:	8b 97 38 02 00 00    	mov    0x238(%edi),%edx
80102c3f:	05 00 02 00 00       	add    $0x200,%eax
80102c44:	39 c2                	cmp    %eax,%edx
80102c46:	74 c0                	je     80102c08 <pipewrite+0x78>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102c48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102c4b:	8d 4a 01             	lea    0x1(%edx),%ecx
80102c4e:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102c54:	89 8f 38 02 00 00    	mov    %ecx,0x238(%edi)
80102c5a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80102c5e:	0f b6 00             	movzbl (%eax),%eax
80102c61:	88 44 17 34          	mov    %al,0x34(%edi,%edx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80102c65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102c68:	3b 45 e0             	cmp    -0x20(%ebp),%eax
80102c6b:	0f 85 5c ff ff ff    	jne    80102bcd <pipewrite+0x3d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102c71:	8d 97 34 02 00 00    	lea    0x234(%edi),%edx
80102c77:	89 14 24             	mov    %edx,(%esp)
80102c7a:	e8 41 02 00 00       	call   80102ec0 <wakeup>
  release(&p->lock);
80102c7f:	89 3c 24             	mov    %edi,(%esp)
80102c82:	e8 a9 05 00 00       	call   80103230 <release>
  return n;
80102c87:	8b 45 10             	mov    0x10(%ebp),%eax
80102c8a:	eb 11                	jmp    80102c9d <pipewrite+0x10d>
80102c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
        release(&p->lock);
80102c90:	89 3c 24             	mov    %edi,(%esp)
80102c93:	e8 98 05 00 00       	call   80103230 <release>
        return -1;
80102c98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80102c9d:	83 c4 1c             	add    $0x1c,%esp
80102ca0:	5b                   	pop    %ebx
80102ca1:	5e                   	pop    %esi
80102ca2:	5f                   	pop    %edi
80102ca3:	5d                   	pop    %ebp
80102ca4:	c3                   	ret    
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102ca5:	89 ca                	mov    %ecx,%edx
80102ca7:	eb 9f                	jmp    80102c48 <pipewrite+0xb8>
80102ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102cb0 <piperead>:
  return n;
}

int
piperead(struct pipe *p, char *addr, int n)
{
80102cb0:	55                   	push   %ebp
80102cb1:	89 e5                	mov    %esp,%ebp
80102cb3:	57                   	push   %edi
80102cb4:	56                   	push   %esi
80102cb5:	53                   	push   %ebx
80102cb6:	83 ec 1c             	sub    $0x1c,%esp
80102cb9:	8b 75 08             	mov    0x8(%ebp),%esi
80102cbc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
80102cbf:	89 34 24             	mov    %esi,(%esp)
80102cc2:	e8 59 04 00 00       	call   80103120 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102cc7:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80102ccd:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
80102cd3:	75 5b                	jne    80102d30 <piperead+0x80>
80102cd5:	8b 9e 40 02 00 00    	mov    0x240(%esi),%ebx
80102cdb:	85 db                	test   %ebx,%ebx
80102cdd:	74 51                	je     80102d30 <piperead+0x80>
80102cdf:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
80102ce5:	eb 25                	jmp    80102d0c <piperead+0x5c>
80102ce7:	90                   	nop
    if(proc->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80102ce8:	89 74 24 04          	mov    %esi,0x4(%esp)
80102cec:	89 1c 24             	mov    %ebx,(%esp)
80102cef:	e8 0c 01 00 00       	call   80102e00 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102cf4:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80102cfa:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
80102d00:	75 2e                	jne    80102d30 <piperead+0x80>
80102d02:	8b 96 40 02 00 00    	mov    0x240(%esi),%edx
80102d08:	85 d2                	test   %edx,%edx
80102d0a:	74 24                	je     80102d30 <piperead+0x80>
    if(proc->killed){
80102d0c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102d12:	8b 48 0c             	mov    0xc(%eax),%ecx
80102d15:	85 c9                	test   %ecx,%ecx
80102d17:	74 cf                	je     80102ce8 <piperead+0x38>
      release(&p->lock);
80102d19:	89 34 24             	mov    %esi,(%esp)
80102d1c:	e8 0f 05 00 00       	call   80103230 <release>
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  release(&p->lock);
  return i;
}
80102d21:	83 c4 1c             	add    $0x1c,%esp

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
    if(proc->killed){
      release(&p->lock);
      return -1;
80102d24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  release(&p->lock);
  return i;
}
80102d29:	5b                   	pop    %ebx
80102d2a:	5e                   	pop    %esi
80102d2b:	5f                   	pop    %edi
80102d2c:	5d                   	pop    %ebp
80102d2d:	c3                   	ret    
80102d2e:	66 90                	xchg   %ax,%ax
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80102d30:	8b 55 10             	mov    0x10(%ebp),%edx
    if(p->nread == p->nwrite)
80102d33:	31 db                	xor    %ebx,%ebx
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80102d35:	85 d2                	test   %edx,%edx
80102d37:	7f 2b                	jg     80102d64 <piperead+0xb4>
80102d39:	eb 31                	jmp    80102d6c <piperead+0xbc>
80102d3b:	90                   	nop
80102d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80102d40:	8d 48 01             	lea    0x1(%eax),%ecx
80102d43:	25 ff 01 00 00       	and    $0x1ff,%eax
80102d48:	89 8e 34 02 00 00    	mov    %ecx,0x234(%esi)
80102d4e:	0f b6 44 06 34       	movzbl 0x34(%esi,%eax,1),%eax
80102d53:	88 04 1f             	mov    %al,(%edi,%ebx,1)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80102d56:	83 c3 01             	add    $0x1,%ebx
80102d59:	3b 5d 10             	cmp    0x10(%ebp),%ebx
80102d5c:	74 0e                	je     80102d6c <piperead+0xbc>
    if(p->nread == p->nwrite)
80102d5e:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80102d64:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
80102d6a:	75 d4                	jne    80102d40 <piperead+0x90>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80102d6c:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
80102d72:	89 04 24             	mov    %eax,(%esp)
80102d75:	e8 46 01 00 00       	call   80102ec0 <wakeup>
  release(&p->lock);
80102d7a:	89 34 24             	mov    %esi,(%esp)
80102d7d:	e8 ae 04 00 00       	call   80103230 <release>
  return i;
}
80102d82:	83 c4 1c             	add    $0x1c,%esp
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  release(&p->lock);
  return i;
80102d85:	89 d8                	mov    %ebx,%eax
}
80102d87:	5b                   	pop    %ebx
80102d88:	5e                   	pop    %esi
80102d89:	5f                   	pop    %edi
80102d8a:	5d                   	pop    %ebp
80102d8b:	c3                   	ret    
80102d8c:	66 90                	xchg   %ax,%ax
80102d8e:	66 90                	xchg   %ax,%ax

80102d90 <sched>:

// Enter scheduler. Must hold only ptable.lock and have changed proc->state.
// Saves and restores intena because intena is a property of this kernel thread,
// not this CPU. It should be proc->intena and proc->ncli, but that would break
// in the few places where a lock is held but there is no process.
void sched(void) {
80102d90:	55                   	push   %ebp
80102d91:	89 e5                	mov    %esp,%ebp
80102d93:	83 ec 18             	sub    $0x18,%esp
  int intena;

  // TODO(lizhi): don't fully understand this part.
  if (!holding(&ptable.lock)) {
80102d96:	c7 04 24 00 d4 10 80 	movl   $0x8010d400,(%esp)
80102d9d:	e8 fe 03 00 00       	call   801031a0 <holding>
80102da2:	85 c0                	test   %eax,%eax
80102da4:	74 20                	je     80102dc6 <sched+0x36>
    panic("sched ptable.lock");
  }
  if (cpu->ncli != 1) {
80102da6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80102dac:	83 78 04 01          	cmpl   $0x1,0x4(%eax)
80102db0:	75 38                	jne    80102dea <sched+0x5a>
    panic("sched locks");
  }
  if (proc->state == RUNNING) {
80102db2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102db8:	83 38 04             	cmpl   $0x4,(%eax)
80102dbb:	74 21                	je     80102dde <sched+0x4e>
// Return the value of EFLAGS register
static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102dbd:	9c                   	pushf  
80102dbe:	58                   	pop    %eax
    panic("sched running");
  }
  if (readeflags()&FL_IF) {
80102dbf:	f6 c4 02             	test   $0x2,%ah
80102dc2:	75 0e                	jne    80102dd2 <sched+0x42>
    panic("sched interruptible");
  }
  intena = cpu->intena;
  // TODO(lizhi): add swtch.
  cpu->intena = intena;
}
80102dc4:	c9                   	leave  
80102dc5:	c3                   	ret    
void sched(void) {
  int intena;

  // TODO(lizhi): don't fully understand this part.
  if (!holding(&ptable.lock)) {
    panic("sched ptable.lock");
80102dc6:	c7 04 24 f1 39 10 80 	movl   $0x801039f1,(%esp)
80102dcd:	e8 8e d5 ff ff       	call   80100360 <panic>
  }
  if (proc->state == RUNNING) {
    panic("sched running");
  }
  if (readeflags()&FL_IF) {
    panic("sched interruptible");
80102dd2:	c7 04 24 1d 3a 10 80 	movl   $0x80103a1d,(%esp)
80102dd9:	e8 82 d5 ff ff       	call   80100360 <panic>
  }
  if (cpu->ncli != 1) {
    panic("sched locks");
  }
  if (proc->state == RUNNING) {
    panic("sched running");
80102dde:	c7 04 24 0f 3a 10 80 	movl   $0x80103a0f,(%esp)
80102de5:	e8 76 d5 ff ff       	call   80100360 <panic>
  // TODO(lizhi): don't fully understand this part.
  if (!holding(&ptable.lock)) {
    panic("sched ptable.lock");
  }
  if (cpu->ncli != 1) {
    panic("sched locks");
80102dea:	c7 04 24 03 3a 10 80 	movl   $0x80103a03,(%esp)
80102df1:	e8 6a d5 ff ff       	call   80100360 <panic>
80102df6:	8d 76 00             	lea    0x0(%esi),%esi
80102df9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102e00 <sleep>:
}

// TODO(lizhi): what is chan??
//
// Atomically release |lock| and sleep on chan. Reacquires lock when awakened.
void sleep(void* chan, struct spinlock* lock) {
80102e00:	55                   	push   %ebp
80102e01:	89 e5                	mov    %esp,%ebp
80102e03:	56                   	push   %esi
80102e04:	53                   	push   %ebx
80102e05:	83 ec 10             	sub    $0x10,%esp
  if (proc == 0) {
80102e08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
}

// TODO(lizhi): what is chan??
//
// Atomically release |lock| and sleep on chan. Reacquires lock when awakened.
void sleep(void* chan, struct spinlock* lock) {
80102e0e:	8b 75 08             	mov    0x8(%ebp),%esi
80102e11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if (proc == 0) {
80102e14:	85 c0                	test   %eax,%eax
80102e16:	0f 84 8a 00 00 00    	je     80102ea6 <sleep+0xa6>
    panic("sleep");
  }
  if (lock == 0) {
80102e1c:	85 db                	test   %ebx,%ebx
80102e1e:	74 7a                	je     80102e9a <sleep+0x9a>

  // Must acquire ptable.lock in order to change p->state and then call sched.
  // Once we hold ptable.lock, we can be guaranteed that we won't miss any
  // wakeup (wakeup runs with ptable.lock locked), so it is okay to release
  // |lock|.
  if (lock != &ptable.lock) {
80102e20:	81 fb 00 d4 10 80    	cmp    $0x8010d400,%ebx
80102e26:	74 50                	je     80102e78 <sleep+0x78>
    acquire(&ptable.lock);
80102e28:	c7 04 24 00 d4 10 80 	movl   $0x8010d400,(%esp)
80102e2f:	e8 ec 02 00 00       	call   80103120 <acquire>
    release(lock);
80102e34:	89 1c 24             	mov    %ebx,(%esp)
80102e37:	e8 f4 03 00 00       	call   80103230 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80102e3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102e42:	89 70 08             	mov    %esi,0x8(%eax)
  proc->state = SLEEPING;
80102e45:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  sched();
80102e4b:	e8 40 ff ff ff       	call   80102d90 <sched>

  // Tidy up.
  proc->chan = 0;
80102e50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102e56:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  // Reacquire original lock.
  if (lock != &ptable.lock) {
    release(&ptable.lock);
80102e5d:	c7 04 24 00 d4 10 80 	movl   $0x8010d400,(%esp)
80102e64:	e8 c7 03 00 00       	call   80103230 <release>
    acquire(lock);
80102e69:	89 5d 08             	mov    %ebx,0x8(%ebp)
  }
}
80102e6c:	83 c4 10             	add    $0x10,%esp
80102e6f:	5b                   	pop    %ebx
80102e70:	5e                   	pop    %esi
80102e71:	5d                   	pop    %ebp
  proc->chan = 0;

  // Reacquire original lock.
  if (lock != &ptable.lock) {
    release(&ptable.lock);
    acquire(lock);
80102e72:	e9 a9 02 00 00       	jmp    80103120 <acquire>
80102e77:	90                   	nop
    acquire(&ptable.lock);
    release(lock);
  }

  // Go to sleep.
  proc->chan = chan;
80102e78:	89 70 08             	mov    %esi,0x8(%eax)
  proc->state = SLEEPING;
80102e7b:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  sched();
80102e81:	e8 0a ff ff ff       	call   80102d90 <sched>

  // Tidy up.
  proc->chan = 0;
80102e86:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102e8c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Reacquire original lock.
  if (lock != &ptable.lock) {
    release(&ptable.lock);
    acquire(lock);
  }
}
80102e93:	83 c4 10             	add    $0x10,%esp
80102e96:	5b                   	pop    %ebx
80102e97:	5e                   	pop    %esi
80102e98:	5d                   	pop    %ebp
80102e99:	c3                   	ret    
void sleep(void* chan, struct spinlock* lock) {
  if (proc == 0) {
    panic("sleep");
  }
  if (lock == 0) {
    panic("sleep without lock");
80102e9a:	c7 04 24 37 3a 10 80 	movl   $0x80103a37,(%esp)
80102ea1:	e8 ba d4 ff ff       	call   80100360 <panic>
// TODO(lizhi): what is chan??
//
// Atomically release |lock| and sleep on chan. Reacquires lock when awakened.
void sleep(void* chan, struct spinlock* lock) {
  if (proc == 0) {
    panic("sleep");
80102ea6:	c7 04 24 31 3a 10 80 	movl   $0x80103a31,(%esp)
80102ead:	e8 ae d4 ff ff       	call   80100360 <panic>
80102eb2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102eb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102ec0 <wakeup>:
}

// TODO(lizhi): what is chan??
//
// wake up all processes sleeping on chan.
void wakeup(void* chan) {
80102ec0:	55                   	push   %ebp
80102ec1:	89 e5                	mov    %esp,%ebp
80102ec3:	53                   	push   %ebx
80102ec4:	83 ec 14             	sub    $0x14,%esp
80102ec7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
80102eca:	c7 04 24 00 d4 10 80 	movl   $0x8010d400,(%esp)
80102ed1:	e8 4a 02 00 00       	call   80103120 <acquire>

//PAGEBREAK!
// wake up all processes sleeping on chan. The ptable lock must be hold!
static void wakeup1(void* chan) {
  struct proc* p;
  for (p = ptable.proc; p < &ptable.proc[NPROC]; ++p) {
80102ed6:	b8 34 d4 10 80       	mov    $0x8010d434,%eax
80102edb:	eb 0d                	jmp    80102eea <wakeup+0x2a>
80102edd:	8d 76 00             	lea    0x0(%esi),%esi
80102ee0:	83 c0 24             	add    $0x24,%eax
80102ee3:	3d 34 dd 10 80       	cmp    $0x8010dd34,%eax
80102ee8:	74 1e                	je     80102f08 <wakeup+0x48>
    if (p->state == SLEEPING && p->chan == chan) {
80102eea:	83 38 02             	cmpl   $0x2,(%eax)
80102eed:	75 f1                	jne    80102ee0 <wakeup+0x20>
80102eef:	3b 58 08             	cmp    0x8(%eax),%ebx
80102ef2:	75 ec                	jne    80102ee0 <wakeup+0x20>
      p->state = RUNNABLE;
80102ef4:	c7 00 03 00 00 00    	movl   $0x3,(%eax)

//PAGEBREAK!
// wake up all processes sleeping on chan. The ptable lock must be hold!
static void wakeup1(void* chan) {
  struct proc* p;
  for (p = ptable.proc; p < &ptable.proc[NPROC]; ++p) {
80102efa:	83 c0 24             	add    $0x24,%eax
80102efd:	3d 34 dd 10 80       	cmp    $0x8010dd34,%eax
80102f02:	75 e6                	jne    80102eea <wakeup+0x2a>
80102f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
//
// wake up all processes sleeping on chan.
void wakeup(void* chan) {
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
80102f08:	c7 45 08 00 d4 10 80 	movl   $0x8010d400,0x8(%ebp)
}
80102f0f:	83 c4 14             	add    $0x14,%esp
80102f12:	5b                   	pop    %ebx
80102f13:	5d                   	pop    %ebp
//
// wake up all processes sleeping on chan.
void wakeup(void* chan) {
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
80102f14:	e9 17 03 00 00       	jmp    80103230 <release>
80102f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102f20 <procdump>:

//PAGEBREAK: 36
// Print a process listing to console. For debugging.
// Runs when user types ^P on concole.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
80102f20:	55                   	push   %ebp
80102f21:	89 e5                	mov    %esp,%ebp
80102f23:	53                   	push   %ebx
80102f24:	bb 48 d4 10 80       	mov    $0x8010d448,%ebx
80102f29:	83 ec 14             	sub    $0x14,%esp
80102f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  struct proc* p;
  char* state;
  // uint pc[10];

  for (p = ptable.proc; p < &ptable.proc[NPROC]; ++p) {
    if (p->state == UNUSED) {
80102f30:	8b 43 ec             	mov    -0x14(%ebx),%eax
80102f33:	85 c0                	test   %eax,%eax
80102f35:	74 42                	je     80102f79 <procdump+0x59>
      continue;
    }
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state]) {
80102f37:	83 f8 05             	cmp    $0x5,%eax
      state = states[p->state];
    } else {
      state = "????? something is wrong";
80102f3a:	ba 4a 3a 10 80       	mov    $0x80103a4a,%edx

  for (p = ptable.proc; p < &ptable.proc[NPROC]; ++p) {
    if (p->state == UNUSED) {
      continue;
    }
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state]) {
80102f3f:	77 11                	ja     80102f52 <procdump+0x32>
80102f41:	8b 14 85 94 3a 10 80 	mov    -0x7fefc56c(,%eax,4),%edx
      state = states[p->state];
    } else {
      state = "????? something is wrong";
80102f48:	b8 4a 3a 10 80       	mov    $0x80103a4a,%eax
80102f4d:	85 d2                	test   %edx,%edx
80102f4f:	0f 44 d0             	cmove  %eax,%edx
    }

    cprintf("%d %s %s", p->pid, state, p->name);
80102f52:	8b 43 f0             	mov    -0x10(%ebx),%eax
80102f55:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80102f59:	89 54 24 08          	mov    %edx,0x8(%esp)
80102f5d:	c7 04 24 63 3a 10 80 	movl   $0x80103a63,(%esp)
80102f64:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f68:	e8 e3 d6 ff ff       	call   80100650 <cprintf>
    if (p->state == SLEEPING) {
      // TODO(lizhi): print stack trace.
    }
    cprintf("\n");
80102f6d:	c7 04 24 e0 3a 10 80 	movl   $0x80103ae0,(%esp)
80102f74:	e8 d7 d6 ff ff       	call   80100650 <cprintf>
80102f79:	83 c3 24             	add    $0x24,%ebx
  // int i;
  struct proc* p;
  char* state;
  // uint pc[10];

  for (p = ptable.proc; p < &ptable.proc[NPROC]; ++p) {
80102f7c:	81 fb 48 dd 10 80    	cmp    $0x8010dd48,%ebx
80102f82:	75 ac                	jne    80102f30 <procdump+0x10>
    if (p->state == SLEEPING) {
      // TODO(lizhi): print stack trace.
    }
    cprintf("\n");
  }
}
80102f84:	83 c4 14             	add    $0x14,%esp
80102f87:	5b                   	pop    %ebx
80102f88:	5d                   	pop    %ebp
80102f89:	c3                   	ret    
80102f8a:	66 90                	xchg   %ax,%ax
80102f8c:	66 90                	xchg   %ax,%ax
80102f8e:	66 90                	xchg   %ax,%ax

80102f90 <initsleeplock>:

#include "defs.h"
#include "proc.h"
#include "sleeplock.h"

void initsleeplock(struct sleeplock* lock, char* name) {
80102f90:	55                   	push   %ebp
80102f91:	89 e5                	mov    %esp,%ebp
80102f93:	56                   	push   %esi
80102f94:	53                   	push   %ebx
80102f95:	83 ec 10             	sub    $0x10,%esp
80102f98:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102f9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&lock->lock, name);
80102f9e:	8d 43 04             	lea    0x4(%ebx),%eax
80102fa1:	89 74 24 04          	mov    %esi,0x4(%esp)
80102fa5:	89 04 24             	mov    %eax,(%esp)
80102fa8:	e8 f3 00 00 00       	call   801030a0 <initlock>
  lock->name = name;
80102fad:	89 73 38             	mov    %esi,0x38(%ebx)
  lock->locked = 0;
80102fb0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lock->pid = 0;
80102fb6:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80102fbd:	83 c4 10             	add    $0x10,%esp
80102fc0:	5b                   	pop    %ebx
80102fc1:	5e                   	pop    %esi
80102fc2:	5d                   	pop    %ebp
80102fc3:	c3                   	ret    
80102fc4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102fca:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80102fd0 <acquiresleep>:

void acquiresleep(struct sleeplock* lock) {
80102fd0:	55                   	push   %ebp
80102fd1:	89 e5                	mov    %esp,%ebp
80102fd3:	56                   	push   %esi
80102fd4:	53                   	push   %ebx
80102fd5:	83 ec 10             	sub    $0x10,%esp
80102fd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lock->lock);
80102fdb:	8d 73 04             	lea    0x4(%ebx),%esi
80102fde:	89 34 24             	mov    %esi,(%esp)
80102fe1:	e8 3a 01 00 00       	call   80103120 <acquire>
  while (lock->locked) {
80102fe6:	8b 13                	mov    (%ebx),%edx
80102fe8:	85 d2                	test   %edx,%edx
80102fea:	74 16                	je     80103002 <acquiresleep+0x32>
80102fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    sleep(lock, &lock->lock);
80102ff0:	89 74 24 04          	mov    %esi,0x4(%esp)
80102ff4:	89 1c 24             	mov    %ebx,(%esp)
80102ff7:	e8 04 fe ff ff       	call   80102e00 <sleep>
  lock->pid = 0;
}

void acquiresleep(struct sleeplock* lock) {
  acquire(&lock->lock);
  while (lock->locked) {
80102ffc:	8b 03                	mov    (%ebx),%eax
80102ffe:	85 c0                	test   %eax,%eax
80103000:	75 ee                	jne    80102ff0 <acquiresleep+0x20>
    sleep(lock, &lock->lock);
  }
  lock->locked = 1;
80103002:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lock->pid = proc->pid;
80103008:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010300e:	8b 40 04             	mov    0x4(%eax),%eax
80103011:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lock->lock);
80103014:	89 75 08             	mov    %esi,0x8(%ebp)
}
80103017:	83 c4 10             	add    $0x10,%esp
8010301a:	5b                   	pop    %ebx
8010301b:	5e                   	pop    %esi
8010301c:	5d                   	pop    %ebp
  while (lock->locked) {
    sleep(lock, &lock->lock);
  }
  lock->locked = 1;
  lock->pid = proc->pid;
  release(&lock->lock);
8010301d:	e9 0e 02 00 00       	jmp    80103230 <release>
80103022:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103029:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103030 <releasesleep>:
}

void releasesleep(struct sleeplock* lock) {
80103030:	55                   	push   %ebp
80103031:	89 e5                	mov    %esp,%ebp
80103033:	56                   	push   %esi
80103034:	53                   	push   %ebx
80103035:	83 ec 10             	sub    $0x10,%esp
80103038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lock->lock);
8010303b:	8d 73 04             	lea    0x4(%ebx),%esi
8010303e:	89 34 24             	mov    %esi,(%esp)
80103041:	e8 da 00 00 00       	call   80103120 <acquire>
  lock->locked = 0;
80103046:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lock->pid = 0;
8010304c:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lock);
80103053:	89 1c 24             	mov    %ebx,(%esp)
80103056:	e8 65 fe ff ff       	call   80102ec0 <wakeup>
  release(&lock->lock);
8010305b:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010305e:	83 c4 10             	add    $0x10,%esp
80103061:	5b                   	pop    %ebx
80103062:	5e                   	pop    %esi
80103063:	5d                   	pop    %ebp
void releasesleep(struct sleeplock* lock) {
  acquire(&lock->lock);
  lock->locked = 0;
  lock->pid = 0;
  wakeup(lock);
  release(&lock->lock);
80103064:	e9 c7 01 00 00       	jmp    80103230 <release>
80103069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103070 <holdingsleep>:
}

// Return 0 when the |lock| is not hold by any process. Otherwise return 1.
int holdingsleep(struct sleeplock* lock) {
80103070:	55                   	push   %ebp
80103071:	89 e5                	mov    %esp,%ebp
80103073:	56                   	push   %esi
80103074:	53                   	push   %ebx
80103075:	83 ec 10             	sub    $0x10,%esp
80103078:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  acquire(&lock->lock);
8010307b:	8d 73 04             	lea    0x4(%ebx),%esi
8010307e:	89 34 24             	mov    %esi,(%esp)
80103081:	e8 9a 00 00 00       	call   80103120 <acquire>
  r = lock->locked;
80103086:	8b 1b                	mov    (%ebx),%ebx
  release(&lock->lock);
80103088:	89 34 24             	mov    %esi,(%esp)
8010308b:	e8 a0 01 00 00       	call   80103230 <release>
  return r;
}
80103090:	83 c4 10             	add    $0x10,%esp
80103093:	89 d8                	mov    %ebx,%eax
80103095:	5b                   	pop    %ebx
80103096:	5e                   	pop    %esi
80103097:	5d                   	pop    %ebp
80103098:	c3                   	ret    
80103099:	66 90                	xchg   %ax,%ax
8010309b:	66 90                	xchg   %ax,%ax
8010309d:	66 90                	xchg   %ax,%ax
8010309f:	90                   	nop

801030a0 <initlock>:
#include "proc.h"
#include "spinlock.h"
#include "types.h"
#include "x86.h"

void initlock(struct spinlock* lock, char* name) {
801030a0:	55                   	push   %ebp
801030a1:	89 e5                	mov    %esp,%ebp
801030a3:	8b 45 08             	mov    0x8(%ebp),%eax
  lock->locked = 0;
  lock->name = name;
801030a6:	8b 55 0c             	mov    0xc(%ebp),%edx
#include "spinlock.h"
#include "types.h"
#include "x86.h"

void initlock(struct spinlock* lock, char* name) {
  lock->locked = 0;
801030a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lock->name = name;
801030af:	89 50 04             	mov    %edx,0x4(%eax)
  lock->cpu = 0;
801030b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801030b9:	5d                   	pop    %ebp
801030ba:	c3                   	ret    
801030bb:	90                   	nop
801030bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801030c0 <getcallerpcs>:
  asm volatile("movl $0, %0" : "+m" (lock->locked) : );
  
  popcli();
}

void getcallerpcs(void* v, uint pcs[]) {
801030c0:	55                   	push   %ebp
801030c1:	89 e5                	mov    %esp,%ebp
  uint* ebp;
  int i;

  ebp = (uint*)v - 2;
801030c3:	8b 45 08             	mov    0x8(%ebp),%eax
  asm volatile("movl $0, %0" : "+m" (lock->locked) : );
  
  popcli();
}

void getcallerpcs(void* v, uint pcs[]) {
801030c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801030c9:	53                   	push   %ebx
  uint* ebp;
  int i;

  ebp = (uint*)v - 2;
801030ca:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++) {
801030cd:	31 c0                	xor    %eax,%eax
801030cf:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801030d0:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
801030d6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
801030dc:	77 1a                	ja     801030f8 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
801030de:	8b 5a 04             	mov    0x4(%edx),%ebx
801030e1:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
void getcallerpcs(void* v, uint pcs[]) {
  uint* ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++) {
801030e4:	83 c0 01             	add    $0x1,%eax
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
      ebp = (uint*)ebp[0]; // saved %ebp
801030e7:	8b 12                	mov    (%edx),%edx
void getcallerpcs(void* v, uint pcs[]) {
  uint* ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++) {
801030e9:	83 f8 0a             	cmp    $0xa,%eax
801030ec:	75 e2                	jne    801030d0 <getcallerpcs+0x10>
    pcs[i] = ebp[1];     // saved %eip
      ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
801030ee:	5b                   	pop    %ebx
801030ef:	5d                   	pop    %ebp
801030f0:	c3                   	ret    
801030f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      break;
    pcs[i] = ebp[1];     // saved %eip
      ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
801030f8:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
      ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801030ff:	83 c0 01             	add    $0x1,%eax
80103102:	83 f8 0a             	cmp    $0xa,%eax
80103105:	74 e7                	je     801030ee <getcallerpcs+0x2e>
    pcs[i] = 0;
80103107:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
      ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010310e:	83 c0 01             	add    $0x1,%eax
80103111:	83 f8 0a             	cmp    $0xa,%eax
80103114:	75 e2                	jne    801030f8 <getcallerpcs+0x38>
80103116:	eb d6                	jmp    801030ee <getcallerpcs+0x2e>
80103118:	90                   	nop
80103119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103120 <acquire>:

// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void acquire(struct spinlock* lock) {
80103120:	55                   	push   %ebp
80103121:	89 e5                	mov    %esp,%ebp
80103123:	83 ec 18             	sub    $0x18,%esp
80103126:	9c                   	pushf  
80103127:	59                   	pop    %ecx
}

static inline void
cli(void)
{
  asm volatile("cli");
80103128:	fa                   	cli    
// popcli to undo two pushcli. Also, if interrupts are off, then pushcli,
// popcli leaves them off.
void pushcli(void) {
  int eflags = readeflags();
  cli();
  if (cpu->ncli == 0) {
80103129:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010312f:	8b 50 04             	mov    0x4(%eax),%edx
80103132:	85 d2                	test   %edx,%edx
80103134:	75 09                	jne    8010313f <acquire+0x1f>
    cpu->intena = eflags & FL_IF;
80103136:	81 e1 00 02 00 00    	and    $0x200,%ecx
8010313c:	89 48 08             	mov    %ecx,0x8(%eax)
  }
  cpu->ncli++;
8010313f:	83 c2 01             	add    $0x1,%edx
80103142:	89 50 04             	mov    %edx,0x4(%eax)
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void acquire(struct spinlock* lock) {
  // Disable interrupt to avoid deadlock.
  pushcli();
  if (holding(lock)) {
80103145:	8b 55 08             	mov    0x8(%ebp),%edx
    pcs[i] = 0;
}

// check whether this cpu is holding the lock.
int holding(struct spinlock* lock) {
  return lock->locked && lock->cpu == cpu;
80103148:	8b 0a                	mov    (%edx),%ecx
8010314a:	85 c9                	test   %ecx,%ecx
8010314c:	74 05                	je     80103153 <acquire+0x33>
8010314e:	3b 42 08             	cmp    0x8(%edx),%eax
80103151:	74 3f                	je     80103192 <acquire+0x72>
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103153:	b9 01 00 00 00       	mov    $0x1,%ecx
80103158:	eb 09                	jmp    80103163 <acquire+0x43>
8010315a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103160:	8b 55 08             	mov    0x8(%ebp),%edx
80103163:	89 c8                	mov    %ecx,%eax
80103165:	f0 87 02             	lock xchg %eax,(%edx)
  pushcli();
  if (holding(lock)) {
    panic("acquire");
  }

  while (xchg(&lock->locked, 1) != 0)
80103168:	85 c0                	test   %eax,%eax
8010316a:	75 f4                	jne    80103160 <acquire+0x40>
    ;

  // tell the C compiler and the processor to not move loads or stores past this
  // point, to ensure that the critical section's memory references happen after
  // the lock is acquired.
  __sync_synchronize();
8010316c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about the lock acquisition for debugging.
  lock->cpu = cpu;
80103171:	8b 45 08             	mov    0x8(%ebp),%eax
80103174:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
  getcallerpcs(&lock, lock->pcs);
8010317b:	83 c0 0c             	add    $0xc,%eax
  // point, to ensure that the critical section's memory references happen after
  // the lock is acquired.
  __sync_synchronize();

  // Record info about the lock acquisition for debugging.
  lock->cpu = cpu;
8010317e:	89 50 fc             	mov    %edx,-0x4(%eax)
  getcallerpcs(&lock, lock->pcs);
80103181:	89 44 24 04          	mov    %eax,0x4(%esp)
80103185:	8d 45 08             	lea    0x8(%ebp),%eax
80103188:	89 04 24             	mov    %eax,(%esp)
8010318b:	e8 30 ff ff ff       	call   801030c0 <getcallerpcs>
}
80103190:	c9                   	leave  
80103191:	c3                   	ret    
// other CPUs to waste time spinning to acquire it.
void acquire(struct spinlock* lock) {
  // Disable interrupt to avoid deadlock.
  pushcli();
  if (holding(lock)) {
    panic("acquire");
80103192:	c7 04 24 ac 3a 10 80 	movl   $0x80103aac,(%esp)
80103199:	e8 c2 d1 ff ff       	call   80100360 <panic>
8010319e:	66 90                	xchg   %ax,%ax

801031a0 <holding>:
  for(; i < 10; i++)
    pcs[i] = 0;
}

// check whether this cpu is holding the lock.
int holding(struct spinlock* lock) {
801031a0:	55                   	push   %ebp
  return lock->locked && lock->cpu == cpu;
801031a1:	31 c0                	xor    %eax,%eax
  for(; i < 10; i++)
    pcs[i] = 0;
}

// check whether this cpu is holding the lock.
int holding(struct spinlock* lock) {
801031a3:	89 e5                	mov    %esp,%ebp
801031a5:	8b 55 08             	mov    0x8(%ebp),%edx
  return lock->locked && lock->cpu == cpu;
801031a8:	8b 0a                	mov    (%edx),%ecx
801031aa:	85 c9                	test   %ecx,%ecx
801031ac:	74 0f                	je     801031bd <holding+0x1d>
801031ae:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801031b4:	39 42 08             	cmp    %eax,0x8(%edx)
801031b7:	0f 94 c0             	sete   %al
801031ba:	0f b6 c0             	movzbl %al,%eax
}
801031bd:	5d                   	pop    %ebp
801031be:	c3                   	ret    
801031bf:	90                   	nop

801031c0 <pushcli>:

// pushcli/popcli are like cli/sti excpet that they are matched: it takes two
// popcli to undo two pushcli. Also, if interrupts are off, then pushcli,
// popcli leaves them off.
void pushcli(void) {
801031c0:	55                   	push   %ebp
801031c1:	89 e5                	mov    %esp,%ebp
// Return the value of EFLAGS register
static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801031c3:	9c                   	pushf  
801031c4:	59                   	pop    %ecx
}

static inline void
cli(void)
{
  asm volatile("cli");
801031c5:	fa                   	cli    
  int eflags = readeflags();
  cli();
  if (cpu->ncli == 0) {
801031c6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801031cc:	8b 50 04             	mov    0x4(%eax),%edx
801031cf:	85 d2                	test   %edx,%edx
801031d1:	75 09                	jne    801031dc <pushcli+0x1c>
    cpu->intena = eflags & FL_IF;
801031d3:	81 e1 00 02 00 00    	and    $0x200,%ecx
801031d9:	89 48 08             	mov    %ecx,0x8(%eax)
  }
  cpu->ncli++;
801031dc:	83 c2 01             	add    $0x1,%edx
801031df:	89 50 04             	mov    %edx,0x4(%eax)
}
801031e2:	5d                   	pop    %ebp
801031e3:	c3                   	ret    
801031e4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801031ea:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801031f0 <popcli>:

void popcli(void) {
801031f0:	55                   	push   %ebp
801031f1:	89 e5                	mov    %esp,%ebp
801031f3:	83 ec 18             	sub    $0x18,%esp
// Return the value of EFLAGS register
static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801031f6:	9c                   	pushf  
801031f7:	58                   	pop    %eax
  if ((readeflags() & FL_IF)) {
801031f8:	f6 c4 02             	test   $0x2,%ah
801031fb:	75 12                	jne    8010320f <popcli+0x1f>
    panic("popcli - interruptible");
  }
  if (--cpu->ncli < 0) {
801031fd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80103204:	83 6a 04 01          	subl   $0x1,0x4(%edx)
80103208:	78 11                	js     8010321b <popcli+0x2b>
    panic("popcli");
  }
  if (cpu->ncli == 0) {
8010320a:	75 01                	jne    8010320d <popcli+0x1d>
}

static inline void
sti(void)
{
  asm volatile("sti");
8010320c:	fb                   	sti    
    sti();
  }
}
8010320d:	c9                   	leave  
8010320e:	c3                   	ret    
  cpu->ncli++;
}

void popcli(void) {
  if ((readeflags() & FL_IF)) {
    panic("popcli - interruptible");
8010320f:	c7 04 24 b4 3a 10 80 	movl   $0x80103ab4,(%esp)
80103216:	e8 45 d1 ff ff       	call   80100360 <panic>
  }
  if (--cpu->ncli < 0) {
    panic("popcli");
8010321b:	c7 04 24 cb 3a 10 80 	movl   $0x80103acb,(%esp)
80103222:	e8 39 d1 ff ff       	call   80100360 <panic>
80103227:	89 f6                	mov    %esi,%esi
80103229:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103230 <release>:
  // Record info about the lock acquisition for debugging.
  lock->cpu = cpu;
  getcallerpcs(&lock, lock->pcs);
}

void release(struct spinlock* lock) {
80103230:	55                   	push   %ebp
80103231:	89 e5                	mov    %esp,%ebp
80103233:	83 ec 18             	sub    $0x18,%esp
80103236:	8b 45 08             	mov    0x8(%ebp),%eax
    pcs[i] = 0;
}

// check whether this cpu is holding the lock.
int holding(struct spinlock* lock) {
  return lock->locked && lock->cpu == cpu;
80103239:	8b 10                	mov    (%eax),%edx
8010323b:	85 d2                	test   %edx,%edx
8010323d:	74 0c                	je     8010324b <release+0x1b>
8010323f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80103246:	39 50 08             	cmp    %edx,0x8(%eax)
80103249:	74 0d                	je     80103258 <release+0x28>
  getcallerpcs(&lock, lock->pcs);
}

void release(struct spinlock* lock) {
  if (!holding(lock)) {
    panic("release");
8010324b:	c7 04 24 d2 3a 10 80 	movl   $0x80103ad2,(%esp)
80103252:	e8 09 d1 ff ff       	call   80100360 <panic>
80103257:	90                   	nop
  }

  lock->pcs[0] = 0;
80103258:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lock->cpu = 0;
8010325f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

  // tell the C compiler and the processor to not move loads or stores past this
  // point, to ensure that the critical section's memory references happen after
  // the lock is acquired.
  __sync_synchronize();
80103266:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  // TODO(lizhi): why???
  // 
  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lock->locked) : );
8010326b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  
  popcli();
}
80103271:	c9                   	leave  
  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lock->locked) : );
  
  popcli();
80103272:	e9 79 ff ff ff       	jmp    801031f0 <popcli>
80103277:	66 90                	xchg   %ax,%ax
80103279:	66 90                	xchg   %ax,%ax
8010327b:	66 90                	xchg   %ax,%ax
8010327d:	66 90                	xchg   %ax,%ax
8010327f:	90                   	nop

80103280 <memset>:
#include "types.h"
#include "x86.h"

// TODO(lizhi): what are the params?
void* memset(void* dst, int c, uint n) {
80103280:	55                   	push   %ebp
80103281:	89 e5                	mov    %esp,%ebp
80103283:	8b 55 08             	mov    0x8(%ebp),%edx
80103286:	57                   	push   %edi
80103287:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010328a:	53                   	push   %ebx
  if ((int)dst%4 == 0 && n%4 == 0){
8010328b:	f6 c2 03             	test   $0x3,%dl
8010328e:	75 05                	jne    80103295 <memset+0x15>
80103290:	f6 c1 03             	test   $0x3,%cl
80103293:	74 13                	je     801032a8 <memset+0x28>
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
80103295:	89 d7                	mov    %edx,%edi
80103297:	8b 45 0c             	mov    0xc(%ebp),%eax
8010329a:	fc                   	cld    
8010329b:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
8010329d:	5b                   	pop    %ebx
8010329e:	89 d0                	mov    %edx,%eax
801032a0:	5f                   	pop    %edi
801032a1:	5d                   	pop    %ebp
801032a2:	c3                   	ret    
801032a3:	90                   	nop
801032a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
#include "x86.h"

// TODO(lizhi): what are the params?
void* memset(void* dst, int c, uint n) {
  if ((int)dst%4 == 0 && n%4 == 0){
    c &= 0xFF;
801032a8:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801032ac:	c1 e9 02             	shr    $0x2,%ecx
801032af:	89 f8                	mov    %edi,%eax
801032b1:	89 fb                	mov    %edi,%ebx
801032b3:	c1 e0 18             	shl    $0x18,%eax
801032b6:	c1 e3 10             	shl    $0x10,%ebx
801032b9:	09 d8                	or     %ebx,%eax
801032bb:	09 f8                	or     %edi,%eax
801032bd:	c1 e7 08             	shl    $0x8,%edi
801032c0:	09 f8                	or     %edi,%eax
}

static inline void
stosl(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosl" :
801032c2:	89 d7                	mov    %edx,%edi
801032c4:	fc                   	cld    
801032c5:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
801032c7:	5b                   	pop    %ebx
801032c8:	89 d0                	mov    %edx,%eax
801032ca:	5f                   	pop    %edi
801032cb:	5d                   	pop    %ebp
801032cc:	c3                   	ret    
801032cd:	8d 76 00             	lea    0x0(%esi),%esi

801032d0 <memcmp>:

// returns 0 if the value pointed to by the two contineous memories (starts from
// v1 and v2, and lasts n bytes) are the same.
void* memcmp(const void* v1, const void* v2, uint n) {
801032d0:	55                   	push   %ebp
801032d1:	89 e5                	mov    %esp,%ebp
801032d3:	8b 45 10             	mov    0x10(%ebp),%eax
801032d6:	57                   	push   %edi
801032d7:	56                   	push   %esi
801032d8:	8b 75 0c             	mov    0xc(%ebp),%esi
801032db:	53                   	push   %ebx
801032dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
801032df:	85 c0                	test   %eax,%eax
801032e1:	8d 78 ff             	lea    -0x1(%eax),%edi
801032e4:	74 26                	je     8010330c <memcmp+0x3c>
    if (*s1 != *s2) {
801032e6:	0f b6 03             	movzbl (%ebx),%eax
801032e9:	31 d2                	xor    %edx,%edx
801032eb:	0f b6 0e             	movzbl (%esi),%ecx
801032ee:	38 c8                	cmp    %cl,%al
801032f0:	74 16                	je     80103308 <memcmp+0x38>
801032f2:	eb 24                	jmp    80103318 <memcmp+0x48>
801032f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801032f8:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
801032fd:	83 c2 01             	add    $0x1,%edx
80103300:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
80103304:	38 c8                	cmp    %cl,%al
80103306:	75 10                	jne    80103318 <memcmp+0x48>
void* memcmp(const void* v1, const void* v2, uint n) {
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
80103308:	39 d7                	cmp    %edx,%edi
8010330a:	75 ec                	jne    801032f8 <memcmp+0x28>
    }
    s1++;
    s2++;
  }
  return 0;
}
8010330c:	5b                   	pop    %ebx
      return (void*)(*s1 - *s2);
    }
    s1++;
    s2++;
  }
  return 0;
8010330d:	31 c0                	xor    %eax,%eax
}
8010330f:	5e                   	pop    %esi
80103310:	5f                   	pop    %edi
80103311:	5d                   	pop    %ebp
80103312:	c3                   	ret    
80103313:	90                   	nop
80103314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103318:	5b                   	pop    %ebx
  
  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    if (*s1 != *s2) {
      return (void*)(*s1 - *s2);
80103319:	29 c8                	sub    %ecx,%eax
    }
    s1++;
    s2++;
  }
  return 0;
}
8010331b:	5e                   	pop    %esi
8010331c:	5f                   	pop    %edi
8010331d:	5d                   	pop    %ebp
8010331e:	c3                   	ret    
8010331f:	90                   	nop

80103320 <memmove>:

// TODO(lizhi): do we really need to return?
// 
// copy |n| bytes starting from |dst| to |src|
void* memmove(void* dst, const void* src, uint n) {
80103320:	55                   	push   %ebp
80103321:	89 e5                	mov    %esp,%ebp
80103323:	57                   	push   %edi
80103324:	8b 45 08             	mov    0x8(%ebp),%eax
80103327:	56                   	push   %esi
80103328:	8b 75 0c             	mov    0xc(%ebp),%esi
8010332b:	53                   	push   %ebx
8010332c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  const char* s;
  char* d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
8010332f:	39 c6                	cmp    %eax,%esi
80103331:	73 35                	jae    80103368 <memmove+0x48>
80103333:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
80103336:	39 c8                	cmp    %ecx,%eax
80103338:	73 2e                	jae    80103368 <memmove+0x48>
    s += n;
    d += n;
    while (n-- > 0) {
8010333a:	85 db                	test   %ebx,%ebx

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
8010333c:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
    while (n-- > 0) {
8010333f:	8d 53 ff             	lea    -0x1(%ebx),%edx
80103342:	74 1b                	je     8010335f <memmove+0x3f>
80103344:	f7 db                	neg    %ebx
80103346:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
80103349:	01 fb                	add    %edi,%ebx
8010334b:	90                   	nop
8010334c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      *--d = * --s;
80103350:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
80103354:	88 0c 13             	mov    %cl,(%ebx,%edx,1)
  s = src;
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    while (n-- > 0) {
80103357:	83 ea 01             	sub    $0x1,%edx
8010335a:	83 fa ff             	cmp    $0xffffffff,%edx
8010335d:	75 f1                	jne    80103350 <memmove+0x30>
      *d++ = *s++;
    }
  }

  return dst;
}
8010335f:	5b                   	pop    %ebx
80103360:	5e                   	pop    %esi
80103361:	5f                   	pop    %edi
80103362:	5d                   	pop    %ebp
80103363:	c3                   	ret    
80103364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    d += n;
    while (n-- > 0) {
      *--d = * --s;
    }
  } else {
    while (n-- > 0) {
80103368:	31 d2                	xor    %edx,%edx
8010336a:	85 db                	test   %ebx,%ebx
8010336c:	74 f1                	je     8010335f <memmove+0x3f>
8010336e:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
80103370:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
80103374:	88 0c 10             	mov    %cl,(%eax,%edx,1)
80103377:	83 c2 01             	add    $0x1,%edx
    d += n;
    while (n-- > 0) {
      *--d = * --s;
    }
  } else {
    while (n-- > 0) {
8010337a:	39 da                	cmp    %ebx,%edx
8010337c:	75 f2                	jne    80103370 <memmove+0x50>
      *d++ = *s++;
    }
  }

  return dst;
}
8010337e:	5b                   	pop    %ebx
8010337f:	5e                   	pop    %esi
80103380:	5f                   	pop    %edi
80103381:	5d                   	pop    %ebp
80103382:	c3                   	ret    
80103383:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103389:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103390 <strncmp>:

int strncmp(const char* p, const char* q, uint n) {
80103390:	55                   	push   %ebp
80103391:	89 e5                	mov    %esp,%ebp
80103393:	56                   	push   %esi
80103394:	8b 75 10             	mov    0x10(%ebp),%esi
80103397:	53                   	push   %ebx
80103398:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010339b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  while (n > 0 && *p && *p == *q) {
8010339e:	85 f6                	test   %esi,%esi
801033a0:	74 30                	je     801033d2 <strncmp+0x42>
801033a2:	0f b6 01             	movzbl (%ecx),%eax
801033a5:	84 c0                	test   %al,%al
801033a7:	74 2f                	je     801033d8 <strncmp+0x48>
801033a9:	0f b6 13             	movzbl (%ebx),%edx
801033ac:	38 d0                	cmp    %dl,%al
801033ae:	75 46                	jne    801033f6 <strncmp+0x66>
801033b0:	8d 51 01             	lea    0x1(%ecx),%edx
801033b3:	01 ce                	add    %ecx,%esi
801033b5:	eb 14                	jmp    801033cb <strncmp+0x3b>
801033b7:	90                   	nop
801033b8:	0f b6 02             	movzbl (%edx),%eax
801033bb:	84 c0                	test   %al,%al
801033bd:	74 31                	je     801033f0 <strncmp+0x60>
801033bf:	0f b6 19             	movzbl (%ecx),%ebx
801033c2:	83 c2 01             	add    $0x1,%edx
801033c5:	38 d8                	cmp    %bl,%al
801033c7:	75 17                	jne    801033e0 <strncmp+0x50>
    n--;
    p++;
    q++;
801033c9:	89 cb                	mov    %ecx,%ebx

  return dst;
}

int strncmp(const char* p, const char* q, uint n) {
  while (n > 0 && *p && *p == *q) {
801033cb:	39 f2                	cmp    %esi,%edx
    n--;
    p++;
    q++;
801033cd:	8d 4b 01             	lea    0x1(%ebx),%ecx

  return dst;
}

int strncmp(const char* p, const char* q, uint n) {
  while (n > 0 && *p && *p == *q) {
801033d0:	75 e6                	jne    801033b8 <strncmp+0x28>
  }
  if (n == 0) {
    return 0;
  }
  return (int)((uchar)*p - (uchar)*q);
}
801033d2:	5b                   	pop    %ebx
    n--;
    p++;
    q++;
  }
  if (n == 0) {
    return 0;
801033d3:	31 c0                	xor    %eax,%eax
  }
  return (int)((uchar)*p - (uchar)*q);
}
801033d5:	5e                   	pop    %esi
801033d6:	5d                   	pop    %ebp
801033d7:	c3                   	ret    
801033d8:	0f b6 1b             	movzbl (%ebx),%ebx

  return dst;
}

int strncmp(const char* p, const char* q, uint n) {
  while (n > 0 && *p && *p == *q) {
801033db:	31 c0                	xor    %eax,%eax
801033dd:	8d 76 00             	lea    0x0(%esi),%esi
    q++;
  }
  if (n == 0) {
    return 0;
  }
  return (int)((uchar)*p - (uchar)*q);
801033e0:	0f b6 d3             	movzbl %bl,%edx
801033e3:	29 d0                	sub    %edx,%eax
}
801033e5:	5b                   	pop    %ebx
801033e6:	5e                   	pop    %esi
801033e7:	5d                   	pop    %ebp
801033e8:	c3                   	ret    
801033e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801033f0:	0f b6 5b 01          	movzbl 0x1(%ebx),%ebx
801033f4:	eb ea                	jmp    801033e0 <strncmp+0x50>

  return dst;
}

int strncmp(const char* p, const char* q, uint n) {
  while (n > 0 && *p && *p == *q) {
801033f6:	89 d3                	mov    %edx,%ebx
801033f8:	eb e6                	jmp    801033e0 <strncmp+0x50>
801033fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103400 <strncpy>:
  return (int)((uchar)*p - (uchar)*q);
}

// Copy the string at address |t| to |s|. If |t| length is smaller than |n|,
// fill in '\0' in the corresponding part of |s|.
char* strncpy(char* s, const char* t, int n) {
80103400:	55                   	push   %ebp
80103401:	89 e5                	mov    %esp,%ebp
80103403:	8b 45 08             	mov    0x8(%ebp),%eax
80103406:	56                   	push   %esi
80103407:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010340a:	53                   	push   %ebx
8010340b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char* os = s;
  while (n-- > 0 && (*s++ = *t++) != 0) {
8010340e:	89 c2                	mov    %eax,%edx
80103410:	eb 19                	jmp    8010342b <strncpy+0x2b>
80103412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103418:	83 c3 01             	add    $0x1,%ebx
8010341b:	0f b6 4b ff          	movzbl -0x1(%ebx),%ecx
8010341f:	83 c2 01             	add    $0x1,%edx
80103422:	84 c9                	test   %cl,%cl
80103424:	88 4a ff             	mov    %cl,-0x1(%edx)
80103427:	74 09                	je     80103432 <strncpy+0x32>
80103429:	89 f1                	mov    %esi,%ecx
8010342b:	85 c9                	test   %ecx,%ecx
8010342d:	8d 71 ff             	lea    -0x1(%ecx),%esi
80103430:	7f e6                	jg     80103418 <strncpy+0x18>
    ;
  }
  while (n-- > 0) {
80103432:	31 c9                	xor    %ecx,%ecx
80103434:	85 f6                	test   %esi,%esi
80103436:	7e 0f                	jle    80103447 <strncpy+0x47>
    *s++ = 0;
80103438:	c6 04 0a 00          	movb   $0x0,(%edx,%ecx,1)
8010343c:	89 f3                	mov    %esi,%ebx
8010343e:	83 c1 01             	add    $0x1,%ecx
80103441:	29 cb                	sub    %ecx,%ebx
char* strncpy(char* s, const char* t, int n) {
  char* os = s;
  while (n-- > 0 && (*s++ = *t++) != 0) {
    ;
  }
  while (n-- > 0) {
80103443:	85 db                	test   %ebx,%ebx
80103445:	7f f1                	jg     80103438 <strncpy+0x38>
    *s++ = 0;
  }
  return os;
}
80103447:	5b                   	pop    %ebx
80103448:	5e                   	pop    %esi
80103449:	5d                   	pop    %ebp
8010344a:	c3                   	ret    
8010344b:	66 90                	xchg   %ax,%ax
8010344d:	66 90                	xchg   %ax,%ax
8010344f:	90                   	nop

80103450 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80103450:	a1 b8 51 10 80       	mov    0x801051b8,%eax
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
80103455:	55                   	push   %ebp
80103456:	89 e5                	mov    %esp,%ebp
  if(!uart)
80103458:	85 c0                	test   %eax,%eax
8010345a:	74 14                	je     80103470 <uartgetc+0x20>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010345c:	ba fd 03 00 00       	mov    $0x3fd,%edx
80103461:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80103462:	a8 01                	test   $0x1,%al
80103464:	74 0a                	je     80103470 <uartgetc+0x20>
80103466:	b2 f8                	mov    $0xf8,%dl
80103468:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80103469:	0f b6 c0             	movzbl %al,%eax
}
8010346c:	5d                   	pop    %ebp
8010346d:	c3                   	ret    
8010346e:	66 90                	xchg   %ax,%ax

static int
uartgetc(void)
{
  if(!uart)
    return -1;
80103470:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  if(!(inb(COM1+5) & 0x01))
    return -1;
  return inb(COM1+0);
}
80103475:	5d                   	pop    %ebp
80103476:	c3                   	ret    
80103477:	89 f6                	mov    %esi,%esi
80103479:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103480 <uartputc>:
void
uartputc(int c)
{
  int i;

  if(!uart)
80103480:	a1 b8 51 10 80       	mov    0x801051b8,%eax
80103485:	85 c0                	test   %eax,%eax
80103487:	74 3f                	je     801034c8 <uartputc+0x48>
    uartputc(*p);
}

void
uartputc(int c)
{
80103489:	55                   	push   %ebp
8010348a:	89 e5                	mov    %esp,%ebp
8010348c:	56                   	push   %esi
8010348d:	be fd 03 00 00       	mov    $0x3fd,%esi
80103492:	53                   	push   %ebx
  int i;

  if(!uart)
80103493:	bb 80 00 00 00       	mov    $0x80,%ebx
    uartputc(*p);
}

void
uartputc(int c)
{
80103498:	83 ec 10             	sub    $0x10,%esp
8010349b:	eb 14                	jmp    801034b1 <uartputc+0x31>
8010349d:	8d 76 00             	lea    0x0(%esi),%esi
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
801034a0:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801034a7:	e8 94 ee ff ff       	call   80102340 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801034ac:	83 eb 01             	sub    $0x1,%ebx
801034af:	74 07                	je     801034b8 <uartputc+0x38>
801034b1:	89 f2                	mov    %esi,%edx
801034b3:	ec                   	in     (%dx),%al
801034b4:	a8 20                	test   $0x20,%al
801034b6:	74 e8                	je     801034a0 <uartputc+0x20>
    microdelay(10);
  outb(COM1+0, c);
801034b8:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801034bc:	ba f8 03 00 00       	mov    $0x3f8,%edx
801034c1:	ee                   	out    %al,(%dx)
}
801034c2:	83 c4 10             	add    $0x10,%esp
801034c5:	5b                   	pop    %ebx
801034c6:	5e                   	pop    %esi
801034c7:	5d                   	pop    %ebp
801034c8:	f3 c3                	repz ret 
801034ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801034d0 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801034d0:	55                   	push   %ebp
801034d1:	31 c9                	xor    %ecx,%ecx
801034d3:	89 e5                	mov    %esp,%ebp
801034d5:	89 c8                	mov    %ecx,%eax
801034d7:	57                   	push   %edi
801034d8:	bf fa 03 00 00       	mov    $0x3fa,%edi
801034dd:	56                   	push   %esi
801034de:	89 fa                	mov    %edi,%edx
801034e0:	53                   	push   %ebx
801034e1:	83 ec 1c             	sub    $0x1c,%esp
801034e4:	ee                   	out    %al,(%dx)
801034e5:	be fb 03 00 00       	mov    $0x3fb,%esi
801034ea:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801034ef:	89 f2                	mov    %esi,%edx
801034f1:	ee                   	out    %al,(%dx)
801034f2:	b8 0c 00 00 00       	mov    $0xc,%eax
801034f7:	b2 f8                	mov    $0xf8,%dl
801034f9:	ee                   	out    %al,(%dx)
801034fa:	bb f9 03 00 00       	mov    $0x3f9,%ebx
801034ff:	89 c8                	mov    %ecx,%eax
80103501:	89 da                	mov    %ebx,%edx
80103503:	ee                   	out    %al,(%dx)
80103504:	b8 03 00 00 00       	mov    $0x3,%eax
80103509:	89 f2                	mov    %esi,%edx
8010350b:	ee                   	out    %al,(%dx)
8010350c:	b2 fc                	mov    $0xfc,%dl
8010350e:	89 c8                	mov    %ecx,%eax
80103510:	ee                   	out    %al,(%dx)
80103511:	b8 01 00 00 00       	mov    $0x1,%eax
80103516:	89 da                	mov    %ebx,%edx
80103518:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103519:	b2 fd                	mov    $0xfd,%dl
8010351b:	ec                   	in     (%dx),%al
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010351c:	3c ff                	cmp    $0xff,%al
8010351e:	74 52                	je     80103572 <uartinit+0xa2>
    return;
  uart = 1;
80103520:	c7 05 b8 51 10 80 01 	movl   $0x1,0x801051b8
80103527:	00 00 00 
8010352a:	89 fa                	mov    %edi,%edx
8010352c:	ec                   	in     (%dx),%al
8010352d:	b2 f8                	mov    $0xf8,%dl
8010352f:	ec                   	in     (%dx),%al

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  picenable(IRQ_COM1);
80103530:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80103537:	bb da 3a 10 80       	mov    $0x80103ada,%ebx

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  picenable(IRQ_COM1);
8010353c:	e8 0f f4 ff ff       	call   80102950 <picenable>
  ioapicenable(IRQ_COM1, 0);
80103541:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103548:	00 
80103549:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103550:	e8 bb e9 ff ff       	call   80101f10 <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80103555:	b8 78 00 00 00       	mov    $0x78,%eax
8010355a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    uartputc(*p);
80103560:	89 04 24             	mov    %eax,(%esp)
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80103563:	83 c3 01             	add    $0x1,%ebx
    uartputc(*p);
80103566:	e8 15 ff ff ff       	call   80103480 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010356b:	0f be 03             	movsbl (%ebx),%eax
8010356e:	84 c0                	test   %al,%al
80103570:	75 ee                	jne    80103560 <uartinit+0x90>
    uartputc(*p);
}
80103572:	83 c4 1c             	add    $0x1c,%esp
80103575:	5b                   	pop    %ebx
80103576:	5e                   	pop    %esi
80103577:	5f                   	pop    %edi
80103578:	5d                   	pop    %ebp
80103579:	c3                   	ret    
8010357a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103580 <uartintr>:
  return inb(COM1+0);
}

void
uartintr(void)
{
80103580:	55                   	push   %ebp
80103581:	89 e5                	mov    %esp,%ebp
80103583:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80103586:	c7 04 24 50 34 10 80 	movl   $0x80103450,(%esp)
8010358d:	e8 1e d2 ff ff       	call   801007b0 <consoleintr>
}
80103592:	c9                   	leave  
80103593:	c3                   	ret    
80103594:	66 90                	xchg   %ax,%ax
80103596:	66 90                	xchg   %ax,%ax
80103598:	66 90                	xchg   %ax,%ax
8010359a:	66 90                	xchg   %ax,%ax
8010359c:	66 90                	xchg   %ax,%ax
8010359e:	66 90                	xchg   %ax,%ax

801035a0 <setupkvm>:
  { (void*)DEVSPACE, DEVSPACE,      0,         PTE_W}, // more devices
};

// Set up kernel part of virtual memory (a page table). Return 0 when fails.
// Return the address of the created page directory.
pde_t* setupkvm(void) {
801035a0:	55                   	push   %ebp
801035a1:	89 e5                	mov    %esp,%ebp
801035a3:	57                   	push   %edi
801035a4:	56                   	push   %esi
801035a5:	53                   	push   %ebx
801035a6:	83 ec 3c             	sub    $0x3c,%esp
  pde_t* pgdir;
  struct kmap* k;
  
  // allocate one 4096-byte page from the kmem freelist.
  if ((pgdir = (pde_t*)kalloc()) == 0) {
801035a9:	e8 02 eb ff ff       	call   801020b0 <kalloc>
801035ae:	85 c0                	test   %eax,%eax
801035b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801035b3:	0f 84 df 00 00 00    	je     80103698 <setupkvm+0xf8>
    return 0;
  }
  memset(pgdir, 0, PGSIZE);
801035b9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801035c0:	00 
801035c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801035c8:	00 
801035c9:	89 04 24             	mov    %eax,(%esp)
801035cc:	e8 af fc ff ff       	call   80103280 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE) {
    panic("PHYSTOP too high");
  }
  for (k = kmap; k < &kmap[NELEM(kmap)]; k++) {
801035d1:	c7 45 d0 20 50 10 80 	movl   $0x80105020,-0x30(%ebp)
    if (mappages(pgdir, k->virt, k->phys_end - k->phys_start, k->phys_start,
801035d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
801035db:	8b 48 0c             	mov    0xc(%eax),%ecx
// addresses starting at |pa|. |va| and |size| might not be page-aligned. Return
// 0 when succeeds, otherwise return -1;
static int mappages(pde_t* pgdir, void* va, uint size, uint pa, int perm) {
  pte_t* pte;

  char* a = (char*)PGROUNDDOWN((uint)va);
801035de:	8b 18                	mov    (%eax),%ebx
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE) {
    panic("PHYSTOP too high");
  }
  for (k = kmap; k < &kmap[NELEM(kmap)]; k++) {
    if (mappages(pgdir, k->virt, k->phys_end - k->phys_start, k->phys_start,
801035e0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
801035e3:	8b 48 04             	mov    0x4(%eax),%ecx
// 0 when succeeds, otherwise return -1;
static int mappages(pde_t* pgdir, void* va, uint size, uint pa, int perm) {
  pte_t* pte;

  char* a = (char*)PGROUNDDOWN((uint)va);
  char* last = (char*)PGROUNDDOWN((uint)pa + size - 1);
801035e6:	8b 40 08             	mov    0x8(%eax),%eax
// addresses starting at |pa|. |va| and |size| might not be page-aligned. Return
// 0 when succeeds, otherwise return -1;
static int mappages(pde_t* pgdir, void* va, uint size, uint pa, int perm) {
  pte_t* pte;

  char* a = (char*)PGROUNDDOWN((uint)va);
801035e9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
      return -1;
    }
    if (*pte & PTE_P) {
      panic("remap");
    }
    *pte = pa | perm | PTE_P;
801035ef:	83 4d d8 01          	orl    $0x1,-0x28(%ebp)
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE) {
    panic("PHYSTOP too high");
  }
  for (k = kmap; k < &kmap[NELEM(kmap)]; k++) {
    if (mappages(pgdir, k->virt, k->phys_end - k->phys_start, k->phys_start,
801035f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
// 0 when succeeds, otherwise return -1;
static int mappages(pde_t* pgdir, void* va, uint size, uint pa, int perm) {
  pte_t* pte;

  char* a = (char*)PGROUNDDOWN((uint)va);
  char* last = (char*)PGROUNDDOWN((uint)pa + size - 1);
801035f6:	83 e8 01             	sub    $0x1,%eax
801035f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
801035fc:	29 5d e0             	sub    %ebx,-0x20(%ebp)
801035ff:	81 65 dc 00 f0 ff ff 	andl   $0xfffff000,-0x24(%ebp)
80103606:	eb 36                	jmp    8010363e <setupkvm+0x9e>
    memset(pgtab, 0, PGSIZE);
    // The permissions here are overly generous, but they can be further
    // restricted by the permissions in the page table entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80103608:	89 d8                	mov    %ebx,%eax
static pte_t* walkpgdir(pde_t* pgdir, const void* va, int alloc) {
  pde_t* pde = &pgdir[PDX(va)];
  pte_t* pgtab;

  if (*pde & PTE_P) {
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010360a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    memset(pgtab, 0, PGSIZE);
    // The permissions here are overly generous, but they can be further
    // restricted by the permissions in the page table entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80103610:	c1 e8 0a             	shr    $0xa,%eax
static pte_t* walkpgdir(pde_t* pgdir, const void* va, int alloc) {
  pde_t* pde = &pgdir[PDX(va)];
  pte_t* pgtab;

  if (*pde & PTE_P) {
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80103613:	8d ba 00 00 00 80    	lea    -0x80000000(%edx),%edi
    memset(pgtab, 0, PGSIZE);
    // The permissions here are overly generous, but they can be further
    // restricted by the permissions in the page table entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80103619:	25 fc 0f 00 00       	and    $0xffc,%eax
  pte_t* pte;

  char* a = (char*)PGROUNDDOWN((uint)va);
  char* last = (char*)PGROUNDDOWN((uint)pa + size - 1);
  for (;;) {
    if ((pte = walkpgdir(pgdir, a, 1)) == 0) {
8010361e:	01 c7                	add    %eax,%edi
80103620:	74 76                	je     80103698 <setupkvm+0xf8>
      return -1;
    }
    if (*pte & PTE_P) {
80103622:	f6 07 01             	testb  $0x1,(%edi)
80103625:	0f 85 99 00 00 00    	jne    801036c4 <setupkvm+0x124>
      panic("remap");
    }
    *pte = pa | perm | PTE_P;
8010362b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010362e:	0b 75 d8             	or     -0x28(%ebp),%esi
    if (a == last) {
80103631:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
      return -1;
    }
    if (*pte & PTE_P) {
      panic("remap");
    }
    *pte = pa | perm | PTE_P;
80103634:	89 37                	mov    %esi,(%edi)
    if (a == last) {
80103636:	74 70                	je     801036a8 <setupkvm+0x108>
      break;
    }
    a += PGSIZE;
80103638:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010363e:	8b 45 e0             	mov    -0x20(%ebp),%eax
pde_t* kpgdir;  // for use in scheduler()

// Return the address of the PTE in page table pgdir that corresponds to
// virtual address va. If alloc != 0, create any required page table pages.
static pte_t* walkpgdir(pde_t* pgdir, const void* va, int alloc) {
  pde_t* pde = &pgdir[PDX(va)];
80103641:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
80103644:	01 d8                	add    %ebx,%eax
80103646:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103649:	89 d8                	mov    %ebx,%eax
8010364b:	c1 e8 16             	shr    $0x16,%eax
8010364e:	8d 34 81             	lea    (%ecx,%eax,4),%esi
  pte_t* pgtab;

  if (*pde & PTE_P) {
80103651:	8b 16                	mov    (%esi),%edx
80103653:	f6 c2 01             	test   $0x1,%dl
80103656:	75 b0                	jne    80103608 <setupkvm+0x68>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if (!alloc || (pgtab = (pte_t*)kalloc()) == 0) {
80103658:	e8 53 ea ff ff       	call   801020b0 <kalloc>
8010365d:	85 c0                	test   %eax,%eax
8010365f:	89 c7                	mov    %eax,%edi
80103661:	74 35                	je     80103698 <setupkvm+0xf8>
      return 0;
    }
    memset(pgtab, 0, PGSIZE);
80103663:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010366a:	00 
8010366b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103672:	00 
80103673:	89 04 24             	mov    %eax,(%esp)
80103676:	e8 05 fc ff ff       	call   80103280 <memset>
    // The permissions here are overly generous, but they can be further
    // restricted by the permissions in the page table entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010367b:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
80103681:	83 c8 07             	or     $0x7,%eax
80103684:	89 06                	mov    %eax,(%esi)
  }
  return &pgtab[PTX(va)];
80103686:	89 d8                	mov    %ebx,%eax
80103688:	c1 e8 0a             	shr    $0xa,%eax
8010368b:	25 fc 0f 00 00       	and    $0xffc,%eax
  pte_t* pte;

  char* a = (char*)PGROUNDDOWN((uint)va);
  char* last = (char*)PGROUNDDOWN((uint)pa + size - 1);
  for (;;) {
    if ((pte = walkpgdir(pgdir, a, 1)) == 0) {
80103690:	01 c7                	add    %eax,%edi
80103692:	75 8e                	jne    80103622 <setupkvm+0x82>
80103694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
                 k->perm) < 0) {
      return 0;
    }
  }
  return pgdir;
}
80103698:	83 c4 3c             	add    $0x3c,%esp
    panic("PHYSTOP too high");
  }
  for (k = kmap; k < &kmap[NELEM(kmap)]; k++) {
    if (mappages(pgdir, k->virt, k->phys_end - k->phys_start, k->phys_start,
                 k->perm) < 0) {
      return 0;
8010369b:	31 c0                	xor    %eax,%eax
    }
  }
  return pgdir;
}
8010369d:	5b                   	pop    %ebx
8010369e:	5e                   	pop    %esi
8010369f:	5f                   	pop    %edi
801036a0:	5d                   	pop    %ebp
801036a1:	c3                   	ret    
801036a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE) {
    panic("PHYSTOP too high");
  }
  for (k = kmap; k < &kmap[NELEM(kmap)]; k++) {
801036a8:	83 45 d0 10          	addl   $0x10,-0x30(%ebp)
801036ac:	81 7d d0 60 50 10 80 	cmpl   $0x80105060,-0x30(%ebp)
801036b3:	0f 82 1f ff ff ff    	jb     801035d8 <setupkvm+0x38>
801036b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
                 k->perm) < 0) {
      return 0;
    }
  }
  return pgdir;
}
801036bc:	83 c4 3c             	add    $0x3c,%esp
801036bf:	5b                   	pop    %ebx
801036c0:	5e                   	pop    %esi
801036c1:	5f                   	pop    %edi
801036c2:	5d                   	pop    %ebp
801036c3:	c3                   	ret    
  for (;;) {
    if ((pte = walkpgdir(pgdir, a, 1)) == 0) {
      return -1;
    }
    if (*pte & PTE_P) {
      panic("remap");
801036c4:	c7 04 24 e2 3a 10 80 	movl   $0x80103ae2,(%esp)
801036cb:	e8 90 cc ff ff       	call   80100360 <panic>

801036d0 <kvmalloc>:
  return pgdir;
}

// Allocate one page table for the machine for the kernel address space for
// scheduler processes.
void kvmalloc(void) {
801036d0:	55                   	push   %ebp
801036d1:	89 e5                	mov    %esp,%ebp
801036d3:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801036d6:	e8 c5 fe ff ff       	call   801035a0 <setupkvm>
801036db:	a3 34 dd 10 80       	mov    %eax,0x8010dd34
}

// Switch h/w page table register to the kernel-only page table, for when no
// process is running.
void switchkvm(void) {
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801036e0:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801036e5:	0f 22 d8             	mov    %eax,%cr3
// Allocate one page table for the machine for the kernel address space for
// scheduler processes.
void kvmalloc(void) {
  kpgdir = setupkvm();
  switchkvm();
}
801036e8:	c9                   	leave  
801036e9:	c3                   	ret    
801036ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801036f0 <switchkvm>:

// Switch h/w page table register to the kernel-only page table, for when no
// process is running.
void switchkvm(void) {
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801036f0:	a1 34 dd 10 80       	mov    0x8010dd34,%eax
  switchkvm();
}

// Switch h/w page table register to the kernel-only page table, for when no
// process is running.
void switchkvm(void) {
801036f5:	55                   	push   %ebp
801036f6:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801036f8:	05 00 00 00 80       	add    $0x80000000,%eax
801036fd:	0f 22 d8             	mov    %eax,%cr3
}
80103700:	5d                   	pop    %ebp
80103701:	c3                   	ret    
