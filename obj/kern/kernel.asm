
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

00100000 <_start-0xc>:
.long MULTIBOOT_HEADER_FLAGS
.long CHECKSUM

.globl		start,_start
start: _start:
	movw	$0x1234,0x472			# warm boot BIOS flag
  100000:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
  100006:	00 00                	add    %al,(%eax)
  100008:	fb                   	sti    
  100009:	4f                   	dec    %edi
  10000a:	52                   	push   %edx
  10000b:	e4 66                	in     $0x66,%al

0010000c <_start>:
  10000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
  100013:	34 12 

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
  100015:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(cpu_boot+4096),%esp
  10001a:	bc 00 60 10 00       	mov    $0x106000,%esp

	# now to C code
	call	init
  10001f:	e8 6f 00 00 00       	call   100093 <init>

00100024 <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
  100024:	eb fe                	jmp    100024 <spin>
  100026:	90                   	nop
  100027:	90                   	nop

00100028 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  100028:	55                   	push   %ebp
  100029:	89 e5                	mov    %esp,%ebp
  10002b:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  10002e:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  100031:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  100034:	89 45 f0             	mov    %eax,-0x10(%ebp)
  100037:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10003a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10003f:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  100042:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100045:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  10004b:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  100050:	74 24                	je     100076 <cpu_cur+0x4e>
  100052:	c7 44 24 0c 20 2a 10 	movl   $0x102a20,0xc(%esp)
  100059:	00 
  10005a:	c7 44 24 08 36 2a 10 	movl   $0x102a36,0x8(%esp)
  100061:	00 
  100062:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  100069:	00 
  10006a:	c7 04 24 4b 2a 10 00 	movl   $0x102a4b,(%esp)
  100071:	e8 ba 02 00 00       	call   100330 <debug_panic>
	return c;
  100076:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  100079:	c9                   	leave  
  10007a:	c3                   	ret    

0010007b <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  10007b:	55                   	push   %ebp
  10007c:	89 e5                	mov    %esp,%ebp
  10007e:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  100081:	e8 a2 ff ff ff       	call   100028 <cpu_cur>
  100086:	3d 00 50 10 00       	cmp    $0x105000,%eax
  10008b:	0f 94 c0             	sete   %al
  10008e:	0f b6 c0             	movzbl %al,%eax
}
  100091:	c9                   	leave  
  100092:	c3                   	ret    

00100093 <init>:
// Called first from entry.S on the bootstrap processor,
// and later from boot/bootother.S on all other processors.
// As a rule, "init" functions in PIOS are called once on EACH processor.
void
init(void)
{
  100093:	55                   	push   %ebp
  100094:	89 e5                	mov    %esp,%ebp
  100096:	83 ec 18             	sub    $0x18,%esp
	extern char start[], edata[], end[];

	// Before anything else, complete the ELF loading process.
	// Clear all uninitialized global data (BSS) in our program,
	// ensuring that all static/global variables start out zero.
	if (cpu_onboot())
  100099:	e8 dd ff ff ff       	call   10007b <cpu_onboot>
  10009e:	85 c0                	test   %eax,%eax
  1000a0:	74 28                	je     1000ca <init+0x37>
		memset(edata, 0, end - edata);
  1000a2:	ba 84 7f 10 00       	mov    $0x107f84,%edx
  1000a7:	b8 30 65 10 00       	mov    $0x106530,%eax
  1000ac:	89 d1                	mov    %edx,%ecx
  1000ae:	29 c1                	sub    %eax,%ecx
  1000b0:	89 c8                	mov    %ecx,%eax
  1000b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1000b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bd:	00 
  1000be:	c7 04 24 30 65 10 00 	movl   $0x106530,(%esp)
  1000c5:	e8 d2 24 00 00       	call   10259c <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
  1000ca:	e8 ee 01 00 00       	call   1002bd <cons_init>

	// Lab 1: test cprintf and debug_trace
	cprintf("1234 decimal is %o octal!\n", 1234);
  1000cf:	c7 44 24 04 d2 04 00 	movl   $0x4d2,0x4(%esp)
  1000d6:	00 
  1000d7:	c7 04 24 58 2a 10 00 	movl   $0x102a58,(%esp)
  1000de:	e8 d2 22 00 00       	call   1023b5 <cprintf>
	debug_check();
  1000e3:	e8 45 04 00 00       	call   10052d <debug_check>

	// Initialize and load the bootstrap CPU's GDT, TSS, and IDT.
	cpu_init();
  1000e8:	e8 a6 0d 00 00       	call   100e93 <cpu_init>
	trap_init();
  1000ed:	e8 83 0e 00 00       	call   100f75 <trap_init>

	// Physical memory detection/initialization.
	// Can't call mem_alloc until after we do this!
	mem_init();
  1000f2:	e8 ec 06 00 00       	call   1007e3 <mem_init>


	// Lab 1: change this so it enters user() in user mode,
	// running on the user_stack declared above,
	// instead of just calling user() directly.
	user();
  1000f7:	e8 02 00 00 00       	call   1000fe <user>
}
  1000fc:	c9                   	leave  
  1000fd:	c3                   	ret    

001000fe <user>:
// This is the first function that gets run in user mode (ring 3).
// It acts as PIOS's "root process",
// of which all other processes are descendants.
void
user()
{
  1000fe:	55                   	push   %ebp
  1000ff:	89 e5                	mov    %esp,%ebp
  100101:	83 ec 28             	sub    $0x28,%esp
	cprintf("in user()\n");
  100104:	c7 04 24 73 2a 10 00 	movl   $0x102a73,(%esp)
  10010b:	e8 a5 22 00 00       	call   1023b5 <cprintf>

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  100110:	89 65 f0             	mov    %esp,-0x10(%ebp)
        return esp;
  100113:	8b 45 f0             	mov    -0x10(%ebp),%eax
	assert(read_esp() > (uint32_t) &user_stack[0]);
  100116:	89 c2                	mov    %eax,%edx
  100118:	b8 40 65 10 00       	mov    $0x106540,%eax
  10011d:	39 c2                	cmp    %eax,%edx
  10011f:	77 24                	ja     100145 <user+0x47>
  100121:	c7 44 24 0c 80 2a 10 	movl   $0x102a80,0xc(%esp)
  100128:	00 
  100129:	c7 44 24 08 36 2a 10 	movl   $0x102a36,0x8(%esp)
  100130:	00 
  100131:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  100138:	00 
  100139:	c7 04 24 a7 2a 10 00 	movl   $0x102aa7,(%esp)
  100140:	e8 eb 01 00 00       	call   100330 <debug_panic>

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  100145:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
	assert(read_esp() < (uint32_t) &user_stack[sizeof(user_stack)]);
  10014b:	89 c2                	mov    %eax,%edx
  10014d:	b8 40 75 10 00       	mov    $0x107540,%eax
  100152:	39 c2                	cmp    %eax,%edx
  100154:	72 24                	jb     10017a <user+0x7c>
  100156:	c7 44 24 0c b4 2a 10 	movl   $0x102ab4,0xc(%esp)
  10015d:	00 
  10015e:	c7 44 24 08 36 2a 10 	movl   $0x102a36,0x8(%esp)
  100165:	00 
  100166:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  10016d:	00 
  10016e:	c7 04 24 a7 2a 10 00 	movl   $0x102aa7,(%esp)
  100175:	e8 b6 01 00 00       	call   100330 <debug_panic>

	// Check that we're in user mode and can handle traps from there.
	trap_check_user();
  10017a:	e8 fc 10 00 00       	call   10127b <trap_check_user>

	done();
  10017f:	e8 00 00 00 00       	call   100184 <done>

00100184 <done>:
// it just puts the processor into an infinite loop.
// We make this a function so that we can set a breakpoints on it.
// Our grade scripts use this breakpoint to know when to stop QEMU.
void gcc_noreturn
done()
{
  100184:	55                   	push   %ebp
  100185:	89 e5                	mov    %esp,%ebp
	while (1)
		;	// just spin
  100187:	eb fe                	jmp    100187 <done+0x3>
  100189:	90                   	nop
  10018a:	90                   	nop
  10018b:	90                   	nop

0010018c <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  10018c:	55                   	push   %ebp
  10018d:	89 e5                	mov    %esp,%ebp
  10018f:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  100192:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  100198:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10019b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10019e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1001a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  1001a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1001a9:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  1001af:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  1001b4:	74 24                	je     1001da <cpu_cur+0x4e>
  1001b6:	c7 44 24 0c ec 2a 10 	movl   $0x102aec,0xc(%esp)
  1001bd:	00 
  1001be:	c7 44 24 08 02 2b 10 	movl   $0x102b02,0x8(%esp)
  1001c5:	00 
  1001c6:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  1001cd:	00 
  1001ce:	c7 04 24 17 2b 10 00 	movl   $0x102b17,(%esp)
  1001d5:	e8 56 01 00 00       	call   100330 <debug_panic>
	return c;
  1001da:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  1001dd:	c9                   	leave  
  1001de:	c3                   	ret    

001001df <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  1001df:	55                   	push   %ebp
  1001e0:	89 e5                	mov    %esp,%ebp
  1001e2:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  1001e5:	e8 a2 ff ff ff       	call   10018c <cpu_cur>
  1001ea:	3d 00 50 10 00       	cmp    $0x105000,%eax
  1001ef:	0f 94 c0             	sete   %al
  1001f2:	0f b6 c0             	movzbl %al,%eax
}
  1001f5:	c9                   	leave  
  1001f6:	c3                   	ret    

001001f7 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
  1001f7:	55                   	push   %ebp
  1001f8:	89 e5                	mov    %esp,%ebp
  1001fa:	83 ec 18             	sub    $0x18,%esp
	int c;

	while ((c = (*proc)()) != -1) {
  1001fd:	eb 35                	jmp    100234 <cons_intr+0x3d>
		if (c == 0)
  1001ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100203:	74 2e                	je     100233 <cons_intr+0x3c>
			continue;
		cons.buf[cons.wpos++] = c;
  100205:	a1 44 77 10 00       	mov    0x107744,%eax
  10020a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10020d:	88 90 40 75 10 00    	mov    %dl,0x107540(%eax)
  100213:	83 c0 01             	add    $0x1,%eax
  100216:	a3 44 77 10 00       	mov    %eax,0x107744
		if (cons.wpos == CONSBUFSIZE)
  10021b:	a1 44 77 10 00       	mov    0x107744,%eax
  100220:	3d 00 02 00 00       	cmp    $0x200,%eax
  100225:	75 0d                	jne    100234 <cons_intr+0x3d>
			cons.wpos = 0;
  100227:	c7 05 44 77 10 00 00 	movl   $0x0,0x107744
  10022e:	00 00 00 
  100231:	eb 01                	jmp    100234 <cons_intr+0x3d>
{
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
  100233:	90                   	nop
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
  100234:	8b 45 08             	mov    0x8(%ebp),%eax
  100237:	ff d0                	call   *%eax
  100239:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10023c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  100240:	75 bd                	jne    1001ff <cons_intr+0x8>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
  100242:	c9                   	leave  
  100243:	c3                   	ret    

00100244 <cons_getc>:

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
  100244:	55                   	push   %ebp
  100245:	89 e5                	mov    %esp,%ebp
  100247:	83 ec 18             	sub    $0x18,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
  10024a:	e8 f9 17 00 00       	call   101a48 <serial_intr>
	kbd_intr();
  10024f:	e8 4e 17 00 00       	call   1019a2 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
  100254:	8b 15 40 77 10 00    	mov    0x107740,%edx
  10025a:	a1 44 77 10 00       	mov    0x107744,%eax
  10025f:	39 c2                	cmp    %eax,%edx
  100261:	74 35                	je     100298 <cons_getc+0x54>
		c = cons.buf[cons.rpos++];
  100263:	a1 40 77 10 00       	mov    0x107740,%eax
  100268:	0f b6 90 40 75 10 00 	movzbl 0x107540(%eax),%edx
  10026f:	0f b6 d2             	movzbl %dl,%edx
  100272:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100275:	83 c0 01             	add    $0x1,%eax
  100278:	a3 40 77 10 00       	mov    %eax,0x107740
		if (cons.rpos == CONSBUFSIZE)
  10027d:	a1 40 77 10 00       	mov    0x107740,%eax
  100282:	3d 00 02 00 00       	cmp    $0x200,%eax
  100287:	75 0a                	jne    100293 <cons_getc+0x4f>
			cons.rpos = 0;
  100289:	c7 05 40 77 10 00 00 	movl   $0x0,0x107740
  100290:	00 00 00 
		return c;
  100293:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100296:	eb 05                	jmp    10029d <cons_getc+0x59>
	}
	return 0;
  100298:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10029d:	c9                   	leave  
  10029e:	c3                   	ret    

0010029f <cons_putc>:

// output a character to the console
static void
cons_putc(int c)
{
  10029f:	55                   	push   %ebp
  1002a0:	89 e5                	mov    %esp,%ebp
  1002a2:	83 ec 18             	sub    $0x18,%esp
	serial_putc(c);
  1002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1002a8:	89 04 24             	mov    %eax,(%esp)
  1002ab:	e8 b5 17 00 00       	call   101a65 <serial_putc>
	video_putc(c);
  1002b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1002b3:	89 04 24             	mov    %eax,(%esp)
  1002b6:	e8 45 13 00 00       	call   101600 <video_putc>
}
  1002bb:	c9                   	leave  
  1002bc:	c3                   	ret    

001002bd <cons_init>:

// initialize the console devices
void
cons_init(void)
{
  1002bd:	55                   	push   %ebp
  1002be:	89 e5                	mov    %esp,%ebp
  1002c0:	83 ec 18             	sub    $0x18,%esp
	if (!cpu_onboot())	// only do once, on the boot CPU
  1002c3:	e8 17 ff ff ff       	call   1001df <cpu_onboot>
  1002c8:	85 c0                	test   %eax,%eax
  1002ca:	74 36                	je     100302 <cons_init+0x45>
		return;

	video_init();
  1002cc:	e8 63 12 00 00       	call   101534 <video_init>
	kbd_init();
  1002d1:	e8 e0 16 00 00       	call   1019b6 <kbd_init>
	serial_init();
  1002d6:	e8 ef 17 00 00       	call   101aca <serial_init>

	if (!serial_exists)
  1002db:	a1 80 7f 10 00       	mov    0x107f80,%eax
  1002e0:	85 c0                	test   %eax,%eax
  1002e2:	75 1f                	jne    100303 <cons_init+0x46>
		warn("Serial port does not exist!\n");
  1002e4:	c7 44 24 08 24 2b 10 	movl   $0x102b24,0x8(%esp)
  1002eb:	00 
  1002ec:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
  1002f3:	00 
  1002f4:	c7 04 24 41 2b 10 00 	movl   $0x102b41,(%esp)
  1002fb:	e8 ef 00 00 00       	call   1003ef <debug_warn>
  100300:	eb 01                	jmp    100303 <cons_init+0x46>
// initialize the console devices
void
cons_init(void)
{
	if (!cpu_onboot())	// only do once, on the boot CPU
		return;
  100302:	90                   	nop
	kbd_init();
	serial_init();

	if (!serial_exists)
		warn("Serial port does not exist!\n");
}
  100303:	c9                   	leave  
  100304:	c3                   	ret    

00100305 <cputs>:


// `High'-level console I/O.  Used by readline and cprintf.
void
cputs(const char *str)
{
  100305:	55                   	push   %ebp
  100306:	89 e5                	mov    %esp,%ebp
  100308:	83 ec 28             	sub    $0x28,%esp
	char ch;
	while (*str)
  10030b:	eb 15                	jmp    100322 <cputs+0x1d>
		cons_putc(*str++);
  10030d:	8b 45 08             	mov    0x8(%ebp),%eax
  100310:	0f b6 00             	movzbl (%eax),%eax
  100313:	0f be c0             	movsbl %al,%eax
  100316:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10031a:	89 04 24             	mov    %eax,(%esp)
  10031d:	e8 7d ff ff ff       	call   10029f <cons_putc>
// `High'-level console I/O.  Used by readline and cprintf.
void
cputs(const char *str)
{
	char ch;
	while (*str)
  100322:	8b 45 08             	mov    0x8(%ebp),%eax
  100325:	0f b6 00             	movzbl (%eax),%eax
  100328:	84 c0                	test   %al,%al
  10032a:	75 e1                	jne    10030d <cputs+0x8>
		cons_putc(*str++);
}
  10032c:	c9                   	leave  
  10032d:	c3                   	ret    
  10032e:	90                   	nop
  10032f:	90                   	nop

00100330 <debug_panic>:

// Panic is called on unresolvable fatal errors.
// It prints "panic: mesg", and then enters the kernel monitor.
void
debug_panic(const char *file, int line, const char *fmt,...)
{
  100330:	55                   	push   %ebp
  100331:	89 e5                	mov    %esp,%ebp
  100333:	83 ec 58             	sub    $0x58,%esp

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  100336:	8c 4d f2             	mov    %cs,-0xe(%ebp)
        return cs;
  100339:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
	va_list ap;
	int i;

	// Avoid infinite recursion if we're panicking from kernel mode.
	if ((read_cs() & 3) == 0) {
  10033d:	0f b7 c0             	movzwl %ax,%eax
  100340:	83 e0 03             	and    $0x3,%eax
  100343:	85 c0                	test   %eax,%eax
  100345:	75 15                	jne    10035c <debug_panic+0x2c>
		if (panicstr)
  100347:	a1 48 77 10 00       	mov    0x107748,%eax
  10034c:	85 c0                	test   %eax,%eax
  10034e:	0f 85 95 00 00 00    	jne    1003e9 <debug_panic+0xb9>
			goto dead;
		panicstr = fmt;
  100354:	8b 45 10             	mov    0x10(%ebp),%eax
  100357:	a3 48 77 10 00       	mov    %eax,0x107748
	}

	// First print the requested message
	va_start(ap, fmt);
  10035c:	8d 45 10             	lea    0x10(%ebp),%eax
  10035f:	83 c0 04             	add    $0x4,%eax
  100362:	89 45 e8             	mov    %eax,-0x18(%ebp)
	cprintf("kernel panic at %s:%d: ", file, line);
  100365:	8b 45 0c             	mov    0xc(%ebp),%eax
  100368:	89 44 24 08          	mov    %eax,0x8(%esp)
  10036c:	8b 45 08             	mov    0x8(%ebp),%eax
  10036f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100373:	c7 04 24 4d 2b 10 00 	movl   $0x102b4d,(%esp)
  10037a:	e8 36 20 00 00       	call   1023b5 <cprintf>
	vcprintf(fmt, ap);
  10037f:	8b 45 10             	mov    0x10(%ebp),%eax
  100382:	8b 55 e8             	mov    -0x18(%ebp),%edx
  100385:	89 54 24 04          	mov    %edx,0x4(%esp)
  100389:	89 04 24             	mov    %eax,(%esp)
  10038c:	e8 bb 1f 00 00       	call   10234c <vcprintf>
	cprintf("\n");
  100391:	c7 04 24 65 2b 10 00 	movl   $0x102b65,(%esp)
  100398:	e8 18 20 00 00       	call   1023b5 <cprintf>

static gcc_inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=rm" (ebp));
  10039d:	89 6d f4             	mov    %ebp,-0xc(%ebp)
        return ebp;
  1003a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
	va_end(ap);

	// Then print a backtrace of the kernel call chain
	uint32_t eips[DEBUG_TRACEFRAMES];
	debug_trace(read_ebp(), eips);
  1003a3:	8d 55 c0             	lea    -0x40(%ebp),%edx
  1003a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003aa:	89 04 24             	mov    %eax,(%esp)
  1003ad:	e8 86 00 00 00       	call   100438 <debug_trace>
	for (i = 0; i < DEBUG_TRACEFRAMES && eips[i] != 0; i++)
  1003b2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1003b9:	eb 1b                	jmp    1003d6 <debug_panic+0xa6>
		cprintf("  from %08x\n", eips[i]);
  1003bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1003be:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
  1003c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003c6:	c7 04 24 67 2b 10 00 	movl   $0x102b67,(%esp)
  1003cd:	e8 e3 1f 00 00       	call   1023b5 <cprintf>
	va_end(ap);

	// Then print a backtrace of the kernel call chain
	uint32_t eips[DEBUG_TRACEFRAMES];
	debug_trace(read_ebp(), eips);
	for (i = 0; i < DEBUG_TRACEFRAMES && eips[i] != 0; i++)
  1003d2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  1003d6:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
  1003da:	7f 0e                	jg     1003ea <debug_panic+0xba>
  1003dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1003df:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
  1003e3:	85 c0                	test   %eax,%eax
  1003e5:	75 d4                	jne    1003bb <debug_panic+0x8b>
  1003e7:	eb 01                	jmp    1003ea <debug_panic+0xba>
	int i;

	// Avoid infinite recursion if we're panicking from kernel mode.
	if ((read_cs() & 3) == 0) {
		if (panicstr)
			goto dead;
  1003e9:	90                   	nop
	debug_trace(read_ebp(), eips);
	for (i = 0; i < DEBUG_TRACEFRAMES && eips[i] != 0; i++)
		cprintf("  from %08x\n", eips[i]);

dead:
	done();		// enter infinite loop (see kern/init.c)
  1003ea:	e8 95 fd ff ff       	call   100184 <done>

001003ef <debug_warn>:
}

/* like panic, but don't */
void
debug_warn(const char *file, int line, const char *fmt,...)
{
  1003ef:	55                   	push   %ebp
  1003f0:	89 e5                	mov    %esp,%ebp
  1003f2:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  1003f5:	8d 45 10             	lea    0x10(%ebp),%eax
  1003f8:	83 c0 04             	add    $0x4,%eax
  1003fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel warning at %s:%d: ", file, line);
  1003fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  100401:	89 44 24 08          	mov    %eax,0x8(%esp)
  100405:	8b 45 08             	mov    0x8(%ebp),%eax
  100408:	89 44 24 04          	mov    %eax,0x4(%esp)
  10040c:	c7 04 24 74 2b 10 00 	movl   $0x102b74,(%esp)
  100413:	e8 9d 1f 00 00       	call   1023b5 <cprintf>
	vcprintf(fmt, ap);
  100418:	8b 45 10             	mov    0x10(%ebp),%eax
  10041b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10041e:	89 54 24 04          	mov    %edx,0x4(%esp)
  100422:	89 04 24             	mov    %eax,(%esp)
  100425:	e8 22 1f 00 00       	call   10234c <vcprintf>
	cprintf("\n");
  10042a:	c7 04 24 65 2b 10 00 	movl   $0x102b65,(%esp)
  100431:	e8 7f 1f 00 00       	call   1023b5 <cprintf>
	va_end(ap);
}
  100436:	c9                   	leave  
  100437:	c3                   	ret    

00100438 <debug_trace>:

// Record the current call stack in eips[] by following the %ebp chain.
void gcc_noinline
debug_trace(uint32_t ebp, uint32_t eips[DEBUG_TRACEFRAMES])
{
  100438:	55                   	push   %ebp
  100439:	89 e5                	mov    %esp,%ebp
  10043b:	83 ec 10             	sub    $0x10,%esp
	uint32_t frame = *(((uint32_t *)ebp)+1);
  10043e:	8b 45 08             	mov    0x8(%ebp),%eax
  100441:	83 c0 04             	add    $0x4,%eax
  100444:	8b 00                	mov    (%eax),%eax
  100446:	89 45 f8             	mov    %eax,-0x8(%ebp)
	int i=0;
  100449:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	while ((ebp!=0x000000)&&(i<DEBUG_TRACEFRAMES)) {
  100450:	eb 25                	jmp    100477 <debug_trace+0x3f>
		eips[i]=frame;
  100452:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100455:	c1 e0 02             	shl    $0x2,%eax
  100458:	03 45 0c             	add    0xc(%ebp),%eax
  10045b:	8b 55 f8             	mov    -0x8(%ebp),%edx
  10045e:	89 10                	mov    %edx,(%eax)
		ebp=*((uint32_t *)ebp);
  100460:	8b 45 08             	mov    0x8(%ebp),%eax
  100463:	8b 00                	mov    (%eax),%eax
  100465:	89 45 08             	mov    %eax,0x8(%ebp)
		frame=*(((uint32_t *)ebp)+1);
  100468:	8b 45 08             	mov    0x8(%ebp),%eax
  10046b:	83 c0 04             	add    $0x4,%eax
  10046e:	8b 00                	mov    (%eax),%eax
  100470:	89 45 f8             	mov    %eax,-0x8(%ebp)
		i++;
  100473:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
void gcc_noinline
debug_trace(uint32_t ebp, uint32_t eips[DEBUG_TRACEFRAMES])
{
	uint32_t frame = *(((uint32_t *)ebp)+1);
	int i=0;
	while ((ebp!=0x000000)&&(i<DEBUG_TRACEFRAMES)) {
  100477:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10047b:	74 1b                	je     100498 <debug_trace+0x60>
  10047d:	83 7d fc 09          	cmpl   $0x9,-0x4(%ebp)
  100481:	7e cf                	jle    100452 <debug_trace+0x1a>
		ebp=*((uint32_t *)ebp);
		frame=*(((uint32_t *)ebp)+1);
		i++;
	}
	//se há menos que DEBUG_TRACEFRAMES frames eips[i] é setado como nulo
	while (i<DEBUG_TRACEFRAMES) {
  100483:	eb 13                	jmp    100498 <debug_trace+0x60>
		eips[i]=0x000000;
  100485:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100488:	c1 e0 02             	shl    $0x2,%eax
  10048b:	03 45 0c             	add    0xc(%ebp),%eax
  10048e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		i++;
  100494:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
		ebp=*((uint32_t *)ebp);
		frame=*(((uint32_t *)ebp)+1);
		i++;
	}
	//se há menos que DEBUG_TRACEFRAMES frames eips[i] é setado como nulo
	while (i<DEBUG_TRACEFRAMES) {
  100498:	83 7d fc 09          	cmpl   $0x9,-0x4(%ebp)
  10049c:	7e e7                	jle    100485 <debug_trace+0x4d>
		eips[i]=0x000000;
		i++;
	}
}
  10049e:	c9                   	leave  
  10049f:	c3                   	ret    

001004a0 <f3>:


static void gcc_noinline f3(int r, uint32_t *e) { debug_trace(read_ebp(), e); }
  1004a0:	55                   	push   %ebp
  1004a1:	89 e5                	mov    %esp,%ebp
  1004a3:	83 ec 18             	sub    $0x18,%esp

static gcc_inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=rm" (ebp));
  1004a6:	89 6d fc             	mov    %ebp,-0x4(%ebp)
        return ebp;
  1004a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  1004af:	89 54 24 04          	mov    %edx,0x4(%esp)
  1004b3:	89 04 24             	mov    %eax,(%esp)
  1004b6:	e8 7d ff ff ff       	call   100438 <debug_trace>
  1004bb:	c9                   	leave  
  1004bc:	c3                   	ret    

001004bd <f2>:
static void gcc_noinline f2(int r, uint32_t *e) { r & 2 ? f3(r,e) : f3(r,e); }
  1004bd:	55                   	push   %ebp
  1004be:	89 e5                	mov    %esp,%ebp
  1004c0:	83 ec 08             	sub    $0x8,%esp
  1004c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1004c6:	83 e0 02             	and    $0x2,%eax
  1004c9:	85 c0                	test   %eax,%eax
  1004cb:	74 14                	je     1004e1 <f2+0x24>
  1004cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1004d7:	89 04 24             	mov    %eax,(%esp)
  1004da:	e8 c1 ff ff ff       	call   1004a0 <f3>
  1004df:	eb 12                	jmp    1004f3 <f2+0x36>
  1004e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1004eb:	89 04 24             	mov    %eax,(%esp)
  1004ee:	e8 ad ff ff ff       	call   1004a0 <f3>
  1004f3:	c9                   	leave  
  1004f4:	c3                   	ret    

001004f5 <f1>:
static void gcc_noinline f1(int r, uint32_t *e) { r & 1 ? f2(r,e) : f2(r,e); }
  1004f5:	55                   	push   %ebp
  1004f6:	89 e5                	mov    %esp,%ebp
  1004f8:	83 ec 08             	sub    $0x8,%esp
  1004fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1004fe:	83 e0 01             	and    $0x1,%eax
  100501:	84 c0                	test   %al,%al
  100503:	74 14                	je     100519 <f1+0x24>
  100505:	8b 45 0c             	mov    0xc(%ebp),%eax
  100508:	89 44 24 04          	mov    %eax,0x4(%esp)
  10050c:	8b 45 08             	mov    0x8(%ebp),%eax
  10050f:	89 04 24             	mov    %eax,(%esp)
  100512:	e8 a6 ff ff ff       	call   1004bd <f2>
  100517:	eb 12                	jmp    10052b <f1+0x36>
  100519:	8b 45 0c             	mov    0xc(%ebp),%eax
  10051c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100520:	8b 45 08             	mov    0x8(%ebp),%eax
  100523:	89 04 24             	mov    %eax,(%esp)
  100526:	e8 92 ff ff ff       	call   1004bd <f2>
  10052b:	c9                   	leave  
  10052c:	c3                   	ret    

0010052d <debug_check>:

// Test the backtrace implementation for correct operation
void
debug_check(void)
{
  10052d:	55                   	push   %ebp
  10052e:	89 e5                	mov    %esp,%ebp
  100530:	81 ec c8 00 00 00    	sub    $0xc8,%esp
	uint32_t eips[4][DEBUG_TRACEFRAMES];
	int r, i;

	// produce several related backtraces...
	for (i = 0; i < 4; i++)
  100536:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10053d:	eb 29                	jmp    100568 <debug_check+0x3b>
		f1(i, eips[i]);
  10053f:	8d 8d 50 ff ff ff    	lea    -0xb0(%ebp),%ecx
  100545:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100548:	89 d0                	mov    %edx,%eax
  10054a:	c1 e0 02             	shl    $0x2,%eax
  10054d:	01 d0                	add    %edx,%eax
  10054f:	c1 e0 03             	shl    $0x3,%eax
  100552:	8d 04 01             	lea    (%ecx,%eax,1),%eax
  100555:	89 44 24 04          	mov    %eax,0x4(%esp)
  100559:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10055c:	89 04 24             	mov    %eax,(%esp)
  10055f:	e8 91 ff ff ff       	call   1004f5 <f1>
{
	uint32_t eips[4][DEBUG_TRACEFRAMES];
	int r, i;

	// produce several related backtraces...
	for (i = 0; i < 4; i++)
  100564:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100568:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
  10056c:	7e d1                	jle    10053f <debug_check+0x12>
		f1(i, eips[i]);

	// ...and make sure they come out correctly.
	for (r = 0; r < 4; r++)
  10056e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  100575:	e9 bc 00 00 00       	jmp    100636 <debug_check+0x109>
		for (i = 0; i < DEBUG_TRACEFRAMES; i++) {
  10057a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100581:	e9 a2 00 00 00       	jmp    100628 <debug_check+0xfb>
			assert((eips[r][i] != 0) == (i < 5));
  100586:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100589:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  10058c:	89 d0                	mov    %edx,%eax
  10058e:	c1 e0 02             	shl    $0x2,%eax
  100591:	01 d0                	add    %edx,%eax
  100593:	01 c0                	add    %eax,%eax
  100595:	01 c8                	add    %ecx,%eax
  100597:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
  10059e:	85 c0                	test   %eax,%eax
  1005a0:	0f 95 c2             	setne  %dl
  1005a3:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
  1005a7:	0f 9e c0             	setle  %al
  1005aa:	31 d0                	xor    %edx,%eax
  1005ac:	84 c0                	test   %al,%al
  1005ae:	74 24                	je     1005d4 <debug_check+0xa7>
  1005b0:	c7 44 24 0c 8e 2b 10 	movl   $0x102b8e,0xc(%esp)
  1005b7:	00 
  1005b8:	c7 44 24 08 ab 2b 10 	movl   $0x102bab,0x8(%esp)
  1005bf:	00 
  1005c0:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  1005c7:	00 
  1005c8:	c7 04 24 c0 2b 10 00 	movl   $0x102bc0,(%esp)
  1005cf:	e8 5c fd ff ff       	call   100330 <debug_panic>
			if (i >= 2)
  1005d4:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  1005d8:	7e 4a                	jle    100624 <debug_check+0xf7>
				assert(eips[r][i] == eips[0][i]);
  1005da:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005dd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  1005e0:	89 d0                	mov    %edx,%eax
  1005e2:	c1 e0 02             	shl    $0x2,%eax
  1005e5:	01 d0                	add    %edx,%eax
  1005e7:	01 c0                	add    %eax,%eax
  1005e9:	01 c8                	add    %ecx,%eax
  1005eb:	8b 94 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%edx
  1005f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005f5:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
  1005fc:	39 c2                	cmp    %eax,%edx
  1005fe:	74 24                	je     100624 <debug_check+0xf7>
  100600:	c7 44 24 0c cd 2b 10 	movl   $0x102bcd,0xc(%esp)
  100607:	00 
  100608:	c7 44 24 08 ab 2b 10 	movl   $0x102bab,0x8(%esp)
  10060f:	00 
  100610:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  100617:	00 
  100618:	c7 04 24 c0 2b 10 00 	movl   $0x102bc0,(%esp)
  10061f:	e8 0c fd ff ff       	call   100330 <debug_panic>
	for (i = 0; i < 4; i++)
		f1(i, eips[i]);

	// ...and make sure they come out correctly.
	for (r = 0; r < 4; r++)
		for (i = 0; i < DEBUG_TRACEFRAMES; i++) {
  100624:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100628:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  10062c:	0f 8e 54 ff ff ff    	jle    100586 <debug_check+0x59>
	// produce several related backtraces...
	for (i = 0; i < 4; i++)
		f1(i, eips[i]);

	// ...and make sure they come out correctly.
	for (r = 0; r < 4; r++)
  100632:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  100636:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
  10063a:	0f 8e 3a ff ff ff    	jle    10057a <debug_check+0x4d>
		for (i = 0; i < DEBUG_TRACEFRAMES; i++) {
			assert((eips[r][i] != 0) == (i < 5));
			if (i >= 2)
				assert(eips[r][i] == eips[0][i]);
		}
	assert(eips[0][0] == eips[1][0]);
  100640:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  100646:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  10064c:	39 c2                	cmp    %eax,%edx
  10064e:	74 24                	je     100674 <debug_check+0x147>
  100650:	c7 44 24 0c e6 2b 10 	movl   $0x102be6,0xc(%esp)
  100657:	00 
  100658:	c7 44 24 08 ab 2b 10 	movl   $0x102bab,0x8(%esp)
  10065f:	00 
  100660:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  100667:	00 
  100668:	c7 04 24 c0 2b 10 00 	movl   $0x102bc0,(%esp)
  10066f:	e8 bc fc ff ff       	call   100330 <debug_panic>
	assert(eips[2][0] == eips[3][0]);
  100674:	8b 55 a0             	mov    -0x60(%ebp),%edx
  100677:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10067a:	39 c2                	cmp    %eax,%edx
  10067c:	74 24                	je     1006a2 <debug_check+0x175>
  10067e:	c7 44 24 0c ff 2b 10 	movl   $0x102bff,0xc(%esp)
  100685:	00 
  100686:	c7 44 24 08 ab 2b 10 	movl   $0x102bab,0x8(%esp)
  10068d:	00 
  10068e:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  100695:	00 
  100696:	c7 04 24 c0 2b 10 00 	movl   $0x102bc0,(%esp)
  10069d:	e8 8e fc ff ff       	call   100330 <debug_panic>
	assert(eips[1][0] != eips[2][0]);
  1006a2:	8b 95 78 ff ff ff    	mov    -0x88(%ebp),%edx
  1006a8:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1006ab:	39 c2                	cmp    %eax,%edx
  1006ad:	75 24                	jne    1006d3 <debug_check+0x1a6>
  1006af:	c7 44 24 0c 18 2c 10 	movl   $0x102c18,0xc(%esp)
  1006b6:	00 
  1006b7:	c7 44 24 08 ab 2b 10 	movl   $0x102bab,0x8(%esp)
  1006be:	00 
  1006bf:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
  1006c6:	00 
  1006c7:	c7 04 24 c0 2b 10 00 	movl   $0x102bc0,(%esp)
  1006ce:	e8 5d fc ff ff       	call   100330 <debug_panic>
	assert(eips[0][1] == eips[2][1]);
  1006d3:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  1006d9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1006dc:	39 c2                	cmp    %eax,%edx
  1006de:	74 24                	je     100704 <debug_check+0x1d7>
  1006e0:	c7 44 24 0c 31 2c 10 	movl   $0x102c31,0xc(%esp)
  1006e7:	00 
  1006e8:	c7 44 24 08 ab 2b 10 	movl   $0x102bab,0x8(%esp)
  1006ef:	00 
  1006f0:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
  1006f7:	00 
  1006f8:	c7 04 24 c0 2b 10 00 	movl   $0x102bc0,(%esp)
  1006ff:	e8 2c fc ff ff       	call   100330 <debug_panic>
	assert(eips[1][1] == eips[3][1]);
  100704:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  10070a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10070d:	39 c2                	cmp    %eax,%edx
  10070f:	74 24                	je     100735 <debug_check+0x208>
  100711:	c7 44 24 0c 4a 2c 10 	movl   $0x102c4a,0xc(%esp)
  100718:	00 
  100719:	c7 44 24 08 ab 2b 10 	movl   $0x102bab,0x8(%esp)
  100720:	00 
  100721:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  100728:	00 
  100729:	c7 04 24 c0 2b 10 00 	movl   $0x102bc0,(%esp)
  100730:	e8 fb fb ff ff       	call   100330 <debug_panic>
	assert(eips[0][1] != eips[1][1]);
  100735:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  10073b:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  100741:	39 c2                	cmp    %eax,%edx
  100743:	75 24                	jne    100769 <debug_check+0x23c>
  100745:	c7 44 24 0c 63 2c 10 	movl   $0x102c63,0xc(%esp)
  10074c:	00 
  10074d:	c7 44 24 08 ab 2b 10 	movl   $0x102bab,0x8(%esp)
  100754:	00 
  100755:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  10075c:	00 
  10075d:	c7 04 24 c0 2b 10 00 	movl   $0x102bc0,(%esp)
  100764:	e8 c7 fb ff ff       	call   100330 <debug_panic>

	cprintf("debug_check() succeeded!\n");
  100769:	c7 04 24 7c 2c 10 00 	movl   $0x102c7c,(%esp)
  100770:	e8 40 1c 00 00       	call   1023b5 <cprintf>
}
  100775:	c9                   	leave  
  100776:	c3                   	ret    
  100777:	90                   	nop

00100778 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  100778:	55                   	push   %ebp
  100779:	89 e5                	mov    %esp,%ebp
  10077b:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  10077e:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  100781:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  100784:	89 45 f0             	mov    %eax,-0x10(%ebp)
  100787:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10078a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10078f:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  100792:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100795:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  10079b:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  1007a0:	74 24                	je     1007c6 <cpu_cur+0x4e>
  1007a2:	c7 44 24 0c 98 2c 10 	movl   $0x102c98,0xc(%esp)
  1007a9:	00 
  1007aa:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  1007b1:	00 
  1007b2:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  1007b9:	00 
  1007ba:	c7 04 24 c3 2c 10 00 	movl   $0x102cc3,(%esp)
  1007c1:	e8 6a fb ff ff       	call   100330 <debug_panic>
	return c;
  1007c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  1007c9:	c9                   	leave  
  1007ca:	c3                   	ret    

001007cb <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  1007cb:	55                   	push   %ebp
  1007cc:	89 e5                	mov    %esp,%ebp
  1007ce:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  1007d1:	e8 a2 ff ff ff       	call   100778 <cpu_cur>
  1007d6:	3d 00 50 10 00       	cmp    $0x105000,%eax
  1007db:	0f 94 c0             	sete   %al
  1007de:	0f b6 c0             	movzbl %al,%eax
}
  1007e1:	c9                   	leave  
  1007e2:	c3                   	ret    

001007e3 <mem_init>:

void mem_check(void);

void
mem_init(void)
{
  1007e3:	55                   	push   %ebp
  1007e4:	89 e5                	mov    %esp,%ebp
  1007e6:	83 ec 38             	sub    $0x38,%esp
	if (!cpu_onboot())	// only do once, on the boot CPU
  1007e9:	e8 dd ff ff ff       	call   1007cb <cpu_onboot>
  1007ee:	85 c0                	test   %eax,%eax
  1007f0:	0f 84 2d 01 00 00    	je     100923 <mem_init+0x140>
	// is available in the system (in bytes),
	// by reading the PC's BIOS-managed nonvolatile RAM (NVRAM).
	// The NVRAM tells us how many kilobytes there are.
	// Since the count is 16 bits, this gives us up to 64MB of RAM;
	// additional RAM beyond that would have to be detected another way.
	size_t basemem = ROUNDDOWN(nvram_read16(NVRAM_BASELO)*1024, PAGESIZE);
  1007f6:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
  1007fd:	e8 cd 13 00 00       	call   101bcf <nvram_read16>
  100802:	c1 e0 0a             	shl    $0xa,%eax
  100805:	89 45 f0             	mov    %eax,-0x10(%ebp)
  100808:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10080b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  100810:	89 45 e0             	mov    %eax,-0x20(%ebp)
	size_t extmem = ROUNDDOWN(nvram_read16(NVRAM_EXTLO)*1024, PAGESIZE);
  100813:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
  10081a:	e8 b0 13 00 00       	call   101bcf <nvram_read16>
  10081f:	c1 e0 0a             	shl    $0xa,%eax
  100822:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100825:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100828:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10082d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	warn("Assuming we have 1GB of memory!");
  100830:	c7 44 24 08 d0 2c 10 	movl   $0x102cd0,0x8(%esp)
  100837:	00 
  100838:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  10083f:	00 
  100840:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100847:	e8 a3 fb ff ff       	call   1003ef <debug_warn>
	extmem = 1024*1024*1024 - MEM_EXT;	// assume 1GB total memory
  10084c:	c7 45 e4 00 00 f0 3f 	movl   $0x3ff00000,-0x1c(%ebp)

	// The maximum physical address is the top of extended memory.
	mem_max = MEM_EXT + extmem;
  100853:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100856:	05 00 00 10 00       	add    $0x100000,%eax
  10085b:	a3 78 7f 10 00       	mov    %eax,0x107f78

	// Compute the total number of physical pages (including I/O holes)
	mem_npage = mem_max / PAGESIZE;
  100860:	a1 78 7f 10 00       	mov    0x107f78,%eax
  100865:	c1 e8 0c             	shr    $0xc,%eax
  100868:	a3 74 7f 10 00       	mov    %eax,0x107f74

	cprintf("Physical memory: %dK available, ", (int)(mem_max/1024));
  10086d:	a1 78 7f 10 00       	mov    0x107f78,%eax
  100872:	c1 e8 0a             	shr    $0xa,%eax
  100875:	89 44 24 04          	mov    %eax,0x4(%esp)
  100879:	c7 04 24 fc 2c 10 00 	movl   $0x102cfc,(%esp)
  100880:	e8 30 1b 00 00       	call   1023b5 <cprintf>
	cprintf("base = %dK, extended = %dK\n",
		(int)(basemem/1024), (int)(extmem/1024));
  100885:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100888:	c1 e8 0a             	shr    $0xa,%eax

	// Compute the total number of physical pages (including I/O holes)
	mem_npage = mem_max / PAGESIZE;

	cprintf("Physical memory: %dK available, ", (int)(mem_max/1024));
	cprintf("base = %dK, extended = %dK\n",
  10088b:	89 c2                	mov    %eax,%edx
		(int)(basemem/1024), (int)(extmem/1024));
  10088d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100890:	c1 e8 0a             	shr    $0xa,%eax

	// Compute the total number of physical pages (including I/O holes)
	mem_npage = mem_max / PAGESIZE;

	cprintf("Physical memory: %dK available, ", (int)(mem_max/1024));
	cprintf("base = %dK, extended = %dK\n",
  100893:	89 54 24 08          	mov    %edx,0x8(%esp)
  100897:	89 44 24 04          	mov    %eax,0x4(%esp)
  10089b:	c7 04 24 1d 2d 10 00 	movl   $0x102d1d,(%esp)
  1008a2:	e8 0e 1b 00 00       	call   1023b5 <cprintf>
	//     Some of it is in use, some is free.
	//     Which pages hold the kernel and the pageinfo array?
	//     Hint: the linker places the kernel (see start and end above),
	//     but YOU decide where to place the pageinfo array.
	// Change the code to reflect this.
	pageinfo **freetail = &mem_freelist;
  1008a7:	c7 45 e8 70 7f 10 00 	movl   $0x107f70,-0x18(%ebp)
	int i;
	for (i = 0; i < mem_npage; i++) {
  1008ae:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1008b5:	eb 3b                	jmp    1008f2 <mem_init+0x10f>
		// A free page has no references to it.
		mem_pageinfo[i].refcount = 0;
  1008b7:	a1 7c 7f 10 00       	mov    0x107f7c,%eax
  1008bc:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1008bf:	c1 e2 03             	shl    $0x3,%edx
  1008c2:	01 d0                	add    %edx,%eax
  1008c4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

		// Add the page to the end of the free list.
		*freetail = &mem_pageinfo[i];
  1008cb:	a1 7c 7f 10 00       	mov    0x107f7c,%eax
  1008d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1008d3:	c1 e2 03             	shl    $0x3,%edx
  1008d6:	8d 14 10             	lea    (%eax,%edx,1),%edx
  1008d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1008dc:	89 10                	mov    %edx,(%eax)
		freetail = &mem_pageinfo[i].free_next;
  1008de:	a1 7c 7f 10 00       	mov    0x107f7c,%eax
  1008e3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1008e6:	c1 e2 03             	shl    $0x3,%edx
  1008e9:	01 d0                	add    %edx,%eax
  1008eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
	//     Hint: the linker places the kernel (see start and end above),
	//     but YOU decide where to place the pageinfo array.
	// Change the code to reflect this.
	pageinfo **freetail = &mem_freelist;
	int i;
	for (i = 0; i < mem_npage; i++) {
  1008ee:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  1008f2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1008f5:	a1 74 7f 10 00       	mov    0x107f74,%eax
  1008fa:	39 c2                	cmp    %eax,%edx
  1008fc:	72 b9                	jb     1008b7 <mem_init+0xd4>

		// Add the page to the end of the free list.
		*freetail = &mem_pageinfo[i];
		freetail = &mem_pageinfo[i].free_next;
	}
	*freetail = NULL;	// null-terminate the freelist
  1008fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100901:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// ...and remove this when you're ready.
	panic("mem_init() not implemented");
  100907:	c7 44 24 08 39 2d 10 	movl   $0x102d39,0x8(%esp)
  10090e:	00 
  10090f:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  100916:	00 
  100917:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  10091e:	e8 0d fa ff ff       	call   100330 <debug_panic>

	// Check to make sure the page allocator seems to work correctly.
	mem_check();
}
  100923:	c9                   	leave  
  100924:	c3                   	ret    

00100925 <mem_alloc>:
//
// Hint: pi->refs should not be incremented 
// Hint: be sure to use proper mutual exclusion for multiprocessor operation.
pageinfo *
mem_alloc(void)
{
  100925:	55                   	push   %ebp
  100926:	89 e5                	mov    %esp,%ebp
  100928:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	// Fill this function in.
	panic("mem_alloc not implemented.");
  10092b:	c7 44 24 08 54 2d 10 	movl   $0x102d54,0x8(%esp)
  100932:	00 
  100933:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  10093a:	00 
  10093b:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100942:	e8 e9 f9 ff ff       	call   100330 <debug_panic>

00100947 <mem_free>:
// Return a page to the free list, given its pageinfo pointer.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
mem_free(pageinfo *pi)
{
  100947:	55                   	push   %ebp
  100948:	89 e5                	mov    %esp,%ebp
  10094a:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in.
	panic("mem_free not implemented.");
  10094d:	c7 44 24 08 6f 2d 10 	movl   $0x102d6f,0x8(%esp)
  100954:	00 
  100955:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  10095c:	00 
  10095d:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100964:	e8 c7 f9 ff ff       	call   100330 <debug_panic>

00100969 <mem_check>:
// Check the physical page allocator (mem_alloc(), mem_free())
// for correct operation after initialization via mem_init().
//
void
mem_check()
{
  100969:	55                   	push   %ebp
  10096a:	89 e5                	mov    %esp,%ebp
  10096c:	83 ec 38             	sub    $0x38,%esp
	int i;

        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	int freepages = 0;
  10096f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (pp = mem_freelist; pp != 0; pp = pp->free_next) {
  100976:	a1 70 7f 10 00       	mov    0x107f70,%eax
  10097b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10097e:	eb 38                	jmp    1009b8 <mem_check+0x4f>
		memset(mem_pi2ptr(pp), 0x97, 128);
  100980:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100983:	a1 7c 7f 10 00       	mov    0x107f7c,%eax
  100988:	89 d1                	mov    %edx,%ecx
  10098a:	29 c1                	sub    %eax,%ecx
  10098c:	89 c8                	mov    %ecx,%eax
  10098e:	c1 f8 03             	sar    $0x3,%eax
  100991:	c1 e0 0c             	shl    $0xc,%eax
  100994:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  10099b:	00 
  10099c:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
  1009a3:	00 
  1009a4:	89 04 24             	mov    %eax,(%esp)
  1009a7:	e8 f0 1b 00 00       	call   10259c <memset>
		freepages++;
  1009ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	int freepages = 0;
	for (pp = mem_freelist; pp != 0; pp = pp->free_next) {
  1009b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1009b3:	8b 00                	mov    (%eax),%eax
  1009b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1009b8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1009bc:	75 c2                	jne    100980 <mem_check+0x17>
		memset(mem_pi2ptr(pp), 0x97, 128);
		freepages++;
	}
	cprintf("mem_check: %d free pages\n", freepages);
  1009be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009c5:	c7 04 24 89 2d 10 00 	movl   $0x102d89,(%esp)
  1009cc:	e8 e4 19 00 00       	call   1023b5 <cprintf>
	assert(freepages < mem_npage);	// can't have more free than total!
  1009d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1009d4:	a1 74 7f 10 00       	mov    0x107f74,%eax
  1009d9:	39 c2                	cmp    %eax,%edx
  1009db:	72 24                	jb     100a01 <mem_check+0x98>
  1009dd:	c7 44 24 0c a3 2d 10 	movl   $0x102da3,0xc(%esp)
  1009e4:	00 
  1009e5:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  1009ec:	00 
  1009ed:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
  1009f4:	00 
  1009f5:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  1009fc:	e8 2f f9 ff ff       	call   100330 <debug_panic>
	assert(freepages > 16000);	// make sure it's in the right ballpark
  100a01:	81 7d f4 80 3e 00 00 	cmpl   $0x3e80,-0xc(%ebp)
  100a08:	7f 24                	jg     100a2e <mem_check+0xc5>
  100a0a:	c7 44 24 0c b9 2d 10 	movl   $0x102db9,0xc(%esp)
  100a11:	00 
  100a12:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100a19:	00 
  100a1a:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  100a21:	00 
  100a22:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100a29:	e8 02 f9 ff ff       	call   100330 <debug_panic>

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
  100a2e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100a35:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100a3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100a3e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	pp0 = mem_alloc(); assert(pp0 != 0);
  100a41:	e8 df fe ff ff       	call   100925 <mem_alloc>
  100a46:	89 45 e0             	mov    %eax,-0x20(%ebp)
  100a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  100a4d:	75 24                	jne    100a73 <mem_check+0x10a>
  100a4f:	c7 44 24 0c cb 2d 10 	movl   $0x102dcb,0xc(%esp)
  100a56:	00 
  100a57:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100a5e:	00 
  100a5f:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  100a66:	00 
  100a67:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100a6e:	e8 bd f8 ff ff       	call   100330 <debug_panic>
	pp1 = mem_alloc(); assert(pp1 != 0);
  100a73:	e8 ad fe ff ff       	call   100925 <mem_alloc>
  100a78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100a7b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  100a7f:	75 24                	jne    100aa5 <mem_check+0x13c>
  100a81:	c7 44 24 0c d4 2d 10 	movl   $0x102dd4,0xc(%esp)
  100a88:	00 
  100a89:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100a90:	00 
  100a91:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  100a98:	00 
  100a99:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100aa0:	e8 8b f8 ff ff       	call   100330 <debug_panic>
	pp2 = mem_alloc(); assert(pp2 != 0);
  100aa5:	e8 7b fe ff ff       	call   100925 <mem_alloc>
  100aaa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  100aad:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  100ab1:	75 24                	jne    100ad7 <mem_check+0x16e>
  100ab3:	c7 44 24 0c dd 2d 10 	movl   $0x102ddd,0xc(%esp)
  100aba:	00 
  100abb:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100ac2:	00 
  100ac3:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  100aca:	00 
  100acb:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100ad2:	e8 59 f8 ff ff       	call   100330 <debug_panic>

	assert(pp0);
  100ad7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  100adb:	75 24                	jne    100b01 <mem_check+0x198>
  100add:	c7 44 24 0c e6 2d 10 	movl   $0x102de6,0xc(%esp)
  100ae4:	00 
  100ae5:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100aec:	00 
  100aed:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
  100af4:	00 
  100af5:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100afc:	e8 2f f8 ff ff       	call   100330 <debug_panic>
	assert(pp1 && pp1 != pp0);
  100b01:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  100b05:	74 08                	je     100b0f <mem_check+0x1a6>
  100b07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100b0a:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  100b0d:	75 24                	jne    100b33 <mem_check+0x1ca>
  100b0f:	c7 44 24 0c ea 2d 10 	movl   $0x102dea,0xc(%esp)
  100b16:	00 
  100b17:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100b1e:	00 
  100b1f:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  100b26:	00 
  100b27:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100b2e:	e8 fd f7 ff ff       	call   100330 <debug_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
  100b33:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  100b37:	74 10                	je     100b49 <mem_check+0x1e0>
  100b39:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100b3c:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  100b3f:	74 08                	je     100b49 <mem_check+0x1e0>
  100b41:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100b44:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  100b47:	75 24                	jne    100b6d <mem_check+0x204>
  100b49:	c7 44 24 0c fc 2d 10 	movl   $0x102dfc,0xc(%esp)
  100b50:	00 
  100b51:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100b58:	00 
  100b59:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  100b60:	00 
  100b61:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100b68:	e8 c3 f7 ff ff       	call   100330 <debug_panic>
        assert(mem_pi2phys(pp0) < mem_npage*PAGESIZE);
  100b6d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100b70:	a1 7c 7f 10 00       	mov    0x107f7c,%eax
  100b75:	89 d1                	mov    %edx,%ecx
  100b77:	29 c1                	sub    %eax,%ecx
  100b79:	89 c8                	mov    %ecx,%eax
  100b7b:	c1 f8 03             	sar    $0x3,%eax
  100b7e:	c1 e0 0c             	shl    $0xc,%eax
  100b81:	8b 15 74 7f 10 00    	mov    0x107f74,%edx
  100b87:	c1 e2 0c             	shl    $0xc,%edx
  100b8a:	39 d0                	cmp    %edx,%eax
  100b8c:	72 24                	jb     100bb2 <mem_check+0x249>
  100b8e:	c7 44 24 0c 1c 2e 10 	movl   $0x102e1c,0xc(%esp)
  100b95:	00 
  100b96:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100b9d:	00 
  100b9e:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  100ba5:	00 
  100ba6:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100bad:	e8 7e f7 ff ff       	call   100330 <debug_panic>
        assert(mem_pi2phys(pp1) < mem_npage*PAGESIZE);
  100bb2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100bb5:	a1 7c 7f 10 00       	mov    0x107f7c,%eax
  100bba:	89 d1                	mov    %edx,%ecx
  100bbc:	29 c1                	sub    %eax,%ecx
  100bbe:	89 c8                	mov    %ecx,%eax
  100bc0:	c1 f8 03             	sar    $0x3,%eax
  100bc3:	c1 e0 0c             	shl    $0xc,%eax
  100bc6:	8b 15 74 7f 10 00    	mov    0x107f74,%edx
  100bcc:	c1 e2 0c             	shl    $0xc,%edx
  100bcf:	39 d0                	cmp    %edx,%eax
  100bd1:	72 24                	jb     100bf7 <mem_check+0x28e>
  100bd3:	c7 44 24 0c 44 2e 10 	movl   $0x102e44,0xc(%esp)
  100bda:	00 
  100bdb:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100be2:	00 
  100be3:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  100bea:	00 
  100beb:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100bf2:	e8 39 f7 ff ff       	call   100330 <debug_panic>
        assert(mem_pi2phys(pp2) < mem_npage*PAGESIZE);
  100bf7:	8b 55 e8             	mov    -0x18(%ebp),%edx
  100bfa:	a1 7c 7f 10 00       	mov    0x107f7c,%eax
  100bff:	89 d1                	mov    %edx,%ecx
  100c01:	29 c1                	sub    %eax,%ecx
  100c03:	89 c8                	mov    %ecx,%eax
  100c05:	c1 f8 03             	sar    $0x3,%eax
  100c08:	c1 e0 0c             	shl    $0xc,%eax
  100c0b:	8b 15 74 7f 10 00    	mov    0x107f74,%edx
  100c11:	c1 e2 0c             	shl    $0xc,%edx
  100c14:	39 d0                	cmp    %edx,%eax
  100c16:	72 24                	jb     100c3c <mem_check+0x2d3>
  100c18:	c7 44 24 0c 6c 2e 10 	movl   $0x102e6c,0xc(%esp)
  100c1f:	00 
  100c20:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100c27:	00 
  100c28:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  100c2f:	00 
  100c30:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100c37:	e8 f4 f6 ff ff       	call   100330 <debug_panic>

	// temporarily steal the rest of the free pages
	fl = mem_freelist;
  100c3c:	a1 70 7f 10 00       	mov    0x107f70,%eax
  100c41:	89 45 ec             	mov    %eax,-0x14(%ebp)
	mem_freelist = 0;
  100c44:	c7 05 70 7f 10 00 00 	movl   $0x0,0x107f70
  100c4b:	00 00 00 

	// should be no free memory
	assert(mem_alloc() == 0);
  100c4e:	e8 d2 fc ff ff       	call   100925 <mem_alloc>
  100c53:	85 c0                	test   %eax,%eax
  100c55:	74 24                	je     100c7b <mem_check+0x312>
  100c57:	c7 44 24 0c 92 2e 10 	movl   $0x102e92,0xc(%esp)
  100c5e:	00 
  100c5f:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100c66:	00 
  100c67:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
  100c6e:	00 
  100c6f:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100c76:	e8 b5 f6 ff ff       	call   100330 <debug_panic>

        // free and re-allocate?
        mem_free(pp0);
  100c7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100c7e:	89 04 24             	mov    %eax,(%esp)
  100c81:	e8 c1 fc ff ff       	call   100947 <mem_free>
        mem_free(pp1);
  100c86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100c89:	89 04 24             	mov    %eax,(%esp)
  100c8c:	e8 b6 fc ff ff       	call   100947 <mem_free>
        mem_free(pp2);
  100c91:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100c94:	89 04 24             	mov    %eax,(%esp)
  100c97:	e8 ab fc ff ff       	call   100947 <mem_free>
	pp0 = pp1 = pp2 = 0;
  100c9c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100ca3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ca6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100ca9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100cac:	89 45 e0             	mov    %eax,-0x20(%ebp)
	pp0 = mem_alloc(); assert(pp0 != 0);
  100caf:	e8 71 fc ff ff       	call   100925 <mem_alloc>
  100cb4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  100cb7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  100cbb:	75 24                	jne    100ce1 <mem_check+0x378>
  100cbd:	c7 44 24 0c cb 2d 10 	movl   $0x102dcb,0xc(%esp)
  100cc4:	00 
  100cc5:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100ccc:	00 
  100ccd:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
  100cd4:	00 
  100cd5:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100cdc:	e8 4f f6 ff ff       	call   100330 <debug_panic>
	pp1 = mem_alloc(); assert(pp1 != 0);
  100ce1:	e8 3f fc ff ff       	call   100925 <mem_alloc>
  100ce6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100ce9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  100ced:	75 24                	jne    100d13 <mem_check+0x3aa>
  100cef:	c7 44 24 0c d4 2d 10 	movl   $0x102dd4,0xc(%esp)
  100cf6:	00 
  100cf7:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100cfe:	00 
  100cff:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
  100d06:	00 
  100d07:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100d0e:	e8 1d f6 ff ff       	call   100330 <debug_panic>
	pp2 = mem_alloc(); assert(pp2 != 0);
  100d13:	e8 0d fc ff ff       	call   100925 <mem_alloc>
  100d18:	89 45 e8             	mov    %eax,-0x18(%ebp)
  100d1b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  100d1f:	75 24                	jne    100d45 <mem_check+0x3dc>
  100d21:	c7 44 24 0c dd 2d 10 	movl   $0x102ddd,0xc(%esp)
  100d28:	00 
  100d29:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100d30:	00 
  100d31:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  100d38:	00 
  100d39:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100d40:	e8 eb f5 ff ff       	call   100330 <debug_panic>
	assert(pp0);
  100d45:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  100d49:	75 24                	jne    100d6f <mem_check+0x406>
  100d4b:	c7 44 24 0c e6 2d 10 	movl   $0x102de6,0xc(%esp)
  100d52:	00 
  100d53:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100d5a:	00 
  100d5b:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  100d62:	00 
  100d63:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100d6a:	e8 c1 f5 ff ff       	call   100330 <debug_panic>
	assert(pp1 && pp1 != pp0);
  100d6f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  100d73:	74 08                	je     100d7d <mem_check+0x414>
  100d75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100d78:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  100d7b:	75 24                	jne    100da1 <mem_check+0x438>
  100d7d:	c7 44 24 0c ea 2d 10 	movl   $0x102dea,0xc(%esp)
  100d84:	00 
  100d85:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100d8c:	00 
  100d8d:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
  100d94:	00 
  100d95:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100d9c:	e8 8f f5 ff ff       	call   100330 <debug_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
  100da1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  100da5:	74 10                	je     100db7 <mem_check+0x44e>
  100da7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100daa:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  100dad:	74 08                	je     100db7 <mem_check+0x44e>
  100daf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100db2:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  100db5:	75 24                	jne    100ddb <mem_check+0x472>
  100db7:	c7 44 24 0c fc 2d 10 	movl   $0x102dfc,0xc(%esp)
  100dbe:	00 
  100dbf:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100dc6:	00 
  100dc7:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
  100dce:	00 
  100dcf:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100dd6:	e8 55 f5 ff ff       	call   100330 <debug_panic>
	assert(mem_alloc() == 0);
  100ddb:	e8 45 fb ff ff       	call   100925 <mem_alloc>
  100de0:	85 c0                	test   %eax,%eax
  100de2:	74 24                	je     100e08 <mem_check+0x49f>
  100de4:	c7 44 24 0c 92 2e 10 	movl   $0x102e92,0xc(%esp)
  100deb:	00 
  100dec:	c7 44 24 08 ae 2c 10 	movl   $0x102cae,0x8(%esp)
  100df3:	00 
  100df4:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
  100dfb:	00 
  100dfc:	c7 04 24 f0 2c 10 00 	movl   $0x102cf0,(%esp)
  100e03:	e8 28 f5 ff ff       	call   100330 <debug_panic>

	// give free list back
	mem_freelist = fl;
  100e08:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100e0b:	a3 70 7f 10 00       	mov    %eax,0x107f70

	// free the pages we took
	mem_free(pp0);
  100e10:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100e13:	89 04 24             	mov    %eax,(%esp)
  100e16:	e8 2c fb ff ff       	call   100947 <mem_free>
	mem_free(pp1);
  100e1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100e1e:	89 04 24             	mov    %eax,(%esp)
  100e21:	e8 21 fb ff ff       	call   100947 <mem_free>
	mem_free(pp2);
  100e26:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100e29:	89 04 24             	mov    %eax,(%esp)
  100e2c:	e8 16 fb ff ff       	call   100947 <mem_free>

	cprintf("mem_check() succeeded!\n");
  100e31:	c7 04 24 a3 2e 10 00 	movl   $0x102ea3,(%esp)
  100e38:	e8 78 15 00 00       	call   1023b5 <cprintf>
}
  100e3d:	c9                   	leave  
  100e3e:	c3                   	ret    
  100e3f:	90                   	nop

00100e40 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  100e40:	55                   	push   %ebp
  100e41:	89 e5                	mov    %esp,%ebp
  100e43:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  100e46:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  100e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  100e4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  100e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100e52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  100e57:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  100e5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100e5d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  100e63:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  100e68:	74 24                	je     100e8e <cpu_cur+0x4e>
  100e6a:	c7 44 24 0c bb 2e 10 	movl   $0x102ebb,0xc(%esp)
  100e71:	00 
  100e72:	c7 44 24 08 d1 2e 10 	movl   $0x102ed1,0x8(%esp)
  100e79:	00 
  100e7a:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  100e81:	00 
  100e82:	c7 04 24 e6 2e 10 00 	movl   $0x102ee6,(%esp)
  100e89:	e8 a2 f4 ff ff       	call   100330 <debug_panic>
	return c;
  100e8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  100e91:	c9                   	leave  
  100e92:	c3                   	ret    

00100e93 <cpu_init>:
	magic: CPU_MAGIC
};


void cpu_init()
{
  100e93:	55                   	push   %ebp
  100e94:	89 e5                	mov    %esp,%ebp
  100e96:	83 ec 18             	sub    $0x18,%esp
	cpu *c = cpu_cur();
  100e99:	e8 a2 ff ff ff       	call   100e40 <cpu_cur>
  100e9e:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Load the GDT
	struct pseudodesc gdt_pd = {
		sizeof(c->gdt) - 1, (uint32_t) c->gdt };
  100ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ea4:	66 c7 45 ee 37 00    	movw   $0x37,-0x12(%ebp)
  100eaa:	89 45 f0             	mov    %eax,-0x10(%ebp)
	asm volatile("lgdt %0" : : "m" (gdt_pd));
  100ead:	0f 01 55 ee          	lgdtl  -0x12(%ebp)

	// Reload all segment registers.
	asm volatile("movw %%ax,%%gs" :: "a" (CPU_GDT_UDATA|3));
  100eb1:	b8 23 00 00 00       	mov    $0x23,%eax
  100eb6:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (CPU_GDT_UDATA|3));
  100eb8:	b8 23 00 00 00       	mov    $0x23,%eax
  100ebd:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (CPU_GDT_KDATA));
  100ebf:	b8 10 00 00 00       	mov    $0x10,%eax
  100ec4:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (CPU_GDT_KDATA));
  100ec6:	b8 10 00 00 00       	mov    $0x10,%eax
  100ecb:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (CPU_GDT_KDATA));
  100ecd:	b8 10 00 00 00       	mov    $0x10,%eax
  100ed2:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (CPU_GDT_KCODE)); // reload CS
  100ed4:	ea db 0e 10 00 08 00 	ljmp   $0x8,$0x100edb

	// We don't need an LDT.
	asm volatile("lldt %%ax" :: "a" (0));
  100edb:	b8 00 00 00 00       	mov    $0x0,%eax
  100ee0:	0f 00 d0             	lldt   %ax
}
  100ee3:	c9                   	leave  
  100ee4:	c3                   	ret    
  100ee5:	90                   	nop
  100ee6:	90                   	nop
  100ee7:	90                   	nop

00100ee8 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  100ee8:	55                   	push   %ebp
  100ee9:	89 e5                	mov    %esp,%ebp
  100eeb:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  100eee:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  100ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  100ef4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  100ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100efa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  100eff:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  100f02:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100f05:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  100f0b:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  100f10:	74 24                	je     100f36 <cpu_cur+0x4e>
  100f12:	c7 44 24 0c 00 2f 10 	movl   $0x102f00,0xc(%esp)
  100f19:	00 
  100f1a:	c7 44 24 08 16 2f 10 	movl   $0x102f16,0x8(%esp)
  100f21:	00 
  100f22:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  100f29:	00 
  100f2a:	c7 04 24 2b 2f 10 00 	movl   $0x102f2b,(%esp)
  100f31:	e8 fa f3 ff ff       	call   100330 <debug_panic>
	return c;
  100f36:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  100f39:	c9                   	leave  
  100f3a:	c3                   	ret    

00100f3b <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  100f3b:	55                   	push   %ebp
  100f3c:	89 e5                	mov    %esp,%ebp
  100f3e:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  100f41:	e8 a2 ff ff ff       	call   100ee8 <cpu_cur>
  100f46:	3d 00 50 10 00       	cmp    $0x105000,%eax
  100f4b:	0f 94 c0             	sete   %al
  100f4e:	0f b6 c0             	movzbl %al,%eax
}
  100f51:	c9                   	leave  
  100f52:	c3                   	ret    

00100f53 <trap_init_idt>:
};


static void
trap_init_idt(void)
{
  100f53:	55                   	push   %ebp
  100f54:	89 e5                	mov    %esp,%ebp
  100f56:	83 ec 18             	sub    $0x18,%esp
	extern segdesc gdt[];
	
	panic("trap_init() not implemented.");
  100f59:	c7 44 24 08 38 2f 10 	movl   $0x102f38,0x8(%esp)
  100f60:	00 
  100f61:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  100f68:	00 
  100f69:	c7 04 24 55 2f 10 00 	movl   $0x102f55,(%esp)
  100f70:	e8 bb f3 ff ff       	call   100330 <debug_panic>

00100f75 <trap_init>:
}

void
trap_init(void)
{
  100f75:	55                   	push   %ebp
  100f76:	89 e5                	mov    %esp,%ebp
  100f78:	83 ec 08             	sub    $0x8,%esp
	// The first time we get called on the bootstrap processor,
	// initialize the IDT.  Other CPUs will share the same IDT.
	if (cpu_onboot())
  100f7b:	e8 bb ff ff ff       	call   100f3b <cpu_onboot>
  100f80:	85 c0                	test   %eax,%eax
  100f82:	74 05                	je     100f89 <trap_init+0x14>
		trap_init_idt();
  100f84:	e8 ca ff ff ff       	call   100f53 <trap_init_idt>

	// Load the IDT into this processor's IDT register.
	asm volatile("lidt %0" : : "m" (idt_pd));
  100f89:	0f 01 1d 00 60 10 00 	lidtl  0x106000

	// Check for the correct IDT and trap handler operation.
	if (cpu_onboot())
  100f90:	e8 a6 ff ff ff       	call   100f3b <cpu_onboot>
  100f95:	85 c0                	test   %eax,%eax
  100f97:	74 05                	je     100f9e <trap_init+0x29>
		trap_check_kernel();
  100f99:	e8 62 02 00 00       	call   101200 <trap_check_kernel>
}
  100f9e:	c9                   	leave  
  100f9f:	c3                   	ret    

00100fa0 <trap_name>:

const char *trap_name(int trapno)
{
  100fa0:	55                   	push   %ebp
  100fa1:	89 e5                	mov    %esp,%ebp
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
  100fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  100fa6:	83 f8 13             	cmp    $0x13,%eax
  100fa9:	77 0c                	ja     100fb7 <trap_name+0x17>
		return excnames[trapno];
  100fab:	8b 45 08             	mov    0x8(%ebp),%eax
  100fae:	8b 04 85 00 33 10 00 	mov    0x103300(,%eax,4),%eax
  100fb5:	eb 05                	jmp    100fbc <trap_name+0x1c>
	return "(unknown trap)";
  100fb7:	b8 61 2f 10 00       	mov    $0x102f61,%eax
}
  100fbc:	5d                   	pop    %ebp
  100fbd:	c3                   	ret    

00100fbe <trap_print_regs>:

void
trap_print_regs(pushregs *regs)
{
  100fbe:	55                   	push   %ebp
  100fbf:	89 e5                	mov    %esp,%ebp
  100fc1:	83 ec 18             	sub    $0x18,%esp
	cprintf("  edi  0x%08x\n", regs->edi);
  100fc4:	8b 45 08             	mov    0x8(%ebp),%eax
  100fc7:	8b 00                	mov    (%eax),%eax
  100fc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  100fcd:	c7 04 24 70 2f 10 00 	movl   $0x102f70,(%esp)
  100fd4:	e8 dc 13 00 00       	call   1023b5 <cprintf>
	cprintf("  esi  0x%08x\n", regs->esi);
  100fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  100fdc:	8b 40 04             	mov    0x4(%eax),%eax
  100fdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  100fe3:	c7 04 24 7f 2f 10 00 	movl   $0x102f7f,(%esp)
  100fea:	e8 c6 13 00 00       	call   1023b5 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->ebp);
  100fef:	8b 45 08             	mov    0x8(%ebp),%eax
  100ff2:	8b 40 08             	mov    0x8(%eax),%eax
  100ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ff9:	c7 04 24 8e 2f 10 00 	movl   $0x102f8e,(%esp)
  101000:	e8 b0 13 00 00       	call   1023b5 <cprintf>
//	cprintf("  oesp 0x%08x\n", regs->oesp);	don't print - useless
	cprintf("  ebx  0x%08x\n", regs->ebx);
  101005:	8b 45 08             	mov    0x8(%ebp),%eax
  101008:	8b 40 10             	mov    0x10(%eax),%eax
  10100b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10100f:	c7 04 24 9d 2f 10 00 	movl   $0x102f9d,(%esp)
  101016:	e8 9a 13 00 00       	call   1023b5 <cprintf>
	cprintf("  edx  0x%08x\n", regs->edx);
  10101b:	8b 45 08             	mov    0x8(%ebp),%eax
  10101e:	8b 40 14             	mov    0x14(%eax),%eax
  101021:	89 44 24 04          	mov    %eax,0x4(%esp)
  101025:	c7 04 24 ac 2f 10 00 	movl   $0x102fac,(%esp)
  10102c:	e8 84 13 00 00       	call   1023b5 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->ecx);
  101031:	8b 45 08             	mov    0x8(%ebp),%eax
  101034:	8b 40 18             	mov    0x18(%eax),%eax
  101037:	89 44 24 04          	mov    %eax,0x4(%esp)
  10103b:	c7 04 24 bb 2f 10 00 	movl   $0x102fbb,(%esp)
  101042:	e8 6e 13 00 00       	call   1023b5 <cprintf>
	cprintf("  eax  0x%08x\n", regs->eax);
  101047:	8b 45 08             	mov    0x8(%ebp),%eax
  10104a:	8b 40 1c             	mov    0x1c(%eax),%eax
  10104d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101051:	c7 04 24 ca 2f 10 00 	movl   $0x102fca,(%esp)
  101058:	e8 58 13 00 00       	call   1023b5 <cprintf>
}
  10105d:	c9                   	leave  
  10105e:	c3                   	ret    

0010105f <trap_print>:

void
trap_print(trapframe *tf)
{
  10105f:	55                   	push   %ebp
  101060:	89 e5                	mov    %esp,%ebp
  101062:	83 ec 18             	sub    $0x18,%esp
	cprintf("TRAP frame at %p\n", tf);
  101065:	8b 45 08             	mov    0x8(%ebp),%eax
  101068:	89 44 24 04          	mov    %eax,0x4(%esp)
  10106c:	c7 04 24 d9 2f 10 00 	movl   $0x102fd9,(%esp)
  101073:	e8 3d 13 00 00       	call   1023b5 <cprintf>
	trap_print_regs(&tf->regs);
  101078:	8b 45 08             	mov    0x8(%ebp),%eax
  10107b:	89 04 24             	mov    %eax,(%esp)
  10107e:	e8 3b ff ff ff       	call   100fbe <trap_print_regs>
	cprintf("  es   0x----%04x\n", tf->es);
  101083:	8b 45 08             	mov    0x8(%ebp),%eax
  101086:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  10108a:	0f b7 c0             	movzwl %ax,%eax
  10108d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101091:	c7 04 24 eb 2f 10 00 	movl   $0x102feb,(%esp)
  101098:	e8 18 13 00 00       	call   1023b5 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->ds);
  10109d:	8b 45 08             	mov    0x8(%ebp),%eax
  1010a0:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  1010a4:	0f b7 c0             	movzwl %ax,%eax
  1010a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1010ab:	c7 04 24 fe 2f 10 00 	movl   $0x102ffe,(%esp)
  1010b2:	e8 fe 12 00 00       	call   1023b5 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->trapno, trap_name(tf->trapno));
  1010b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1010ba:	8b 40 30             	mov    0x30(%eax),%eax
  1010bd:	89 04 24             	mov    %eax,(%esp)
  1010c0:	e8 db fe ff ff       	call   100fa0 <trap_name>
  1010c5:	8b 55 08             	mov    0x8(%ebp),%edx
  1010c8:	8b 52 30             	mov    0x30(%edx),%edx
  1010cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  1010cf:	89 54 24 04          	mov    %edx,0x4(%esp)
  1010d3:	c7 04 24 11 30 10 00 	movl   $0x103011,(%esp)
  1010da:	e8 d6 12 00 00       	call   1023b5 <cprintf>
	cprintf("  err  0x%08x\n", tf->err);
  1010df:	8b 45 08             	mov    0x8(%ebp),%eax
  1010e2:	8b 40 34             	mov    0x34(%eax),%eax
  1010e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1010e9:	c7 04 24 23 30 10 00 	movl   $0x103023,(%esp)
  1010f0:	e8 c0 12 00 00       	call   1023b5 <cprintf>
	cprintf("  eip  0x%08x\n", tf->eip);
  1010f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1010f8:	8b 40 38             	mov    0x38(%eax),%eax
  1010fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1010ff:	c7 04 24 32 30 10 00 	movl   $0x103032,(%esp)
  101106:	e8 aa 12 00 00       	call   1023b5 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->cs);
  10110b:	8b 45 08             	mov    0x8(%ebp),%eax
  10110e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101112:	0f b7 c0             	movzwl %ax,%eax
  101115:	89 44 24 04          	mov    %eax,0x4(%esp)
  101119:	c7 04 24 41 30 10 00 	movl   $0x103041,(%esp)
  101120:	e8 90 12 00 00       	call   1023b5 <cprintf>
	cprintf("  flag 0x%08x\n", tf->eflags);
  101125:	8b 45 08             	mov    0x8(%ebp),%eax
  101128:	8b 40 40             	mov    0x40(%eax),%eax
  10112b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10112f:	c7 04 24 54 30 10 00 	movl   $0x103054,(%esp)
  101136:	e8 7a 12 00 00       	call   1023b5 <cprintf>
	cprintf("  esp  0x%08x\n", tf->esp);
  10113b:	8b 45 08             	mov    0x8(%ebp),%eax
  10113e:	8b 40 44             	mov    0x44(%eax),%eax
  101141:	89 44 24 04          	mov    %eax,0x4(%esp)
  101145:	c7 04 24 63 30 10 00 	movl   $0x103063,(%esp)
  10114c:	e8 64 12 00 00       	call   1023b5 <cprintf>
	cprintf("  ss   0x----%04x\n", tf->ss);
  101151:	8b 45 08             	mov    0x8(%ebp),%eax
  101154:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101158:	0f b7 c0             	movzwl %ax,%eax
  10115b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10115f:	c7 04 24 72 30 10 00 	movl   $0x103072,(%esp)
  101166:	e8 4a 12 00 00       	call   1023b5 <cprintf>
}
  10116b:	c9                   	leave  
  10116c:	c3                   	ret    

0010116d <trap>:

void gcc_noreturn
trap(trapframe *tf)
{
  10116d:	55                   	push   %ebp
  10116e:	89 e5                	mov    %esp,%ebp
  101170:	83 ec 28             	sub    $0x28,%esp
	// The user-level environment may have set the DF flag,
	// and some versions of GCC rely on DF being clear.
	asm volatile("cld" ::: "cc");
  101173:	fc                   	cld    

	// If this trap was anticipated, just use the designated handler.
	cpu *c = cpu_cur();
  101174:	e8 6f fd ff ff       	call   100ee8 <cpu_cur>
  101179:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (c->recover)
  10117c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10117f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  101185:	85 c0                	test   %eax,%eax
  101187:	74 1e                	je     1011a7 <trap+0x3a>
		c->recover(tf, c->recoverdata);
  101189:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10118c:	8b 90 a0 00 00 00    	mov    0xa0(%eax),%edx
  101192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101195:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  10119b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10119f:	8b 45 08             	mov    0x8(%ebp),%eax
  1011a2:	89 04 24             	mov    %eax,(%esp)
  1011a5:	ff d2                	call   *%edx

	trap_print(tf);
  1011a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1011aa:	89 04 24             	mov    %eax,(%esp)
  1011ad:	e8 ad fe ff ff       	call   10105f <trap_print>
	panic("unhandled trap");
  1011b2:	c7 44 24 08 85 30 10 	movl   $0x103085,0x8(%esp)
  1011b9:	00 
  1011ba:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  1011c1:	00 
  1011c2:	c7 04 24 55 2f 10 00 	movl   $0x102f55,(%esp)
  1011c9:	e8 62 f1 ff ff       	call   100330 <debug_panic>

001011ce <trap_check_recover>:

// Helper function for trap_check_recover(), below:
// handles "anticipated" traps by simply resuming at a new EIP.
static void gcc_noreturn
trap_check_recover(trapframe *tf, void *recoverdata)
{
  1011ce:	55                   	push   %ebp
  1011cf:	89 e5                	mov    %esp,%ebp
  1011d1:	83 ec 28             	sub    $0x28,%esp
	trap_check_args *args = recoverdata;
  1011d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1011d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	tf->eip = (uint32_t) args->reip;	// Use recovery EIP on return
  1011da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1011dd:	8b 00                	mov    (%eax),%eax
  1011df:	89 c2                	mov    %eax,%edx
  1011e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1011e4:	89 50 38             	mov    %edx,0x38(%eax)
	args->trapno = tf->trapno;		// Return trap number
  1011e7:	8b 45 08             	mov    0x8(%ebp),%eax
  1011ea:	8b 40 30             	mov    0x30(%eax),%eax
  1011ed:	89 c2                	mov    %eax,%edx
  1011ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1011f2:	89 50 04             	mov    %edx,0x4(%eax)
	trap_return(tf);
  1011f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1011f8:	89 04 24             	mov    %eax,(%esp)
  1011fb:	e8 30 03 00 00       	call   101530 <trap_return>

00101200 <trap_check_kernel>:

// Check for correct handling of traps from kernel mode.
// Called on the boot CPU after trap_init() and trap_setup().
void
trap_check_kernel(void)
{
  101200:	55                   	push   %ebp
  101201:	89 e5                	mov    %esp,%ebp
  101203:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  101206:	8c 4d f6             	mov    %cs,-0xa(%ebp)
        return cs;
  101209:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
	assert((read_cs() & 3) == 0);	// better be in kernel mode!
  10120d:	0f b7 c0             	movzwl %ax,%eax
  101210:	83 e0 03             	and    $0x3,%eax
  101213:	85 c0                	test   %eax,%eax
  101215:	74 24                	je     10123b <trap_check_kernel+0x3b>
  101217:	c7 44 24 0c 94 30 10 	movl   $0x103094,0xc(%esp)
  10121e:	00 
  10121f:	c7 44 24 08 16 2f 10 	movl   $0x102f16,0x8(%esp)
  101226:	00 
  101227:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  10122e:	00 
  10122f:	c7 04 24 55 2f 10 00 	movl   $0x102f55,(%esp)
  101236:	e8 f5 f0 ff ff       	call   100330 <debug_panic>

	cpu *c = cpu_cur();
  10123b:	e8 a8 fc ff ff       	call   100ee8 <cpu_cur>
  101240:	89 45 f0             	mov    %eax,-0x10(%ebp)
	c->recover = trap_check_recover;
  101243:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101246:	c7 80 a0 00 00 00 ce 	movl   $0x1011ce,0xa0(%eax)
  10124d:	11 10 00 
	trap_check(&c->recoverdata);
  101250:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101253:	05 a4 00 00 00       	add    $0xa4,%eax
  101258:	89 04 24             	mov    %eax,(%esp)
  10125b:	e8 96 00 00 00       	call   1012f6 <trap_check>
	c->recover = NULL;	// No more mr. nice-guy; traps are real again
  101260:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101263:	c7 80 a0 00 00 00 00 	movl   $0x0,0xa0(%eax)
  10126a:	00 00 00 

	cprintf("trap_check_kernel() succeeded!\n");
  10126d:	c7 04 24 ac 30 10 00 	movl   $0x1030ac,(%esp)
  101274:	e8 3c 11 00 00       	call   1023b5 <cprintf>
}
  101279:	c9                   	leave  
  10127a:	c3                   	ret    

0010127b <trap_check_user>:
// Called from user() in kern/init.c, only in lab 1.
// We assume the "current cpu" is always the boot cpu;
// this true only because lab 1 doesn't start any other CPUs.
void
trap_check_user(void)
{
  10127b:	55                   	push   %ebp
  10127c:	89 e5                	mov    %esp,%ebp
  10127e:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  101281:	8c 4d f6             	mov    %cs,-0xa(%ebp)
        return cs;
  101284:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
	assert((read_cs() & 3) == 3);	// better be in user mode!
  101288:	0f b7 c0             	movzwl %ax,%eax
  10128b:	83 e0 03             	and    $0x3,%eax
  10128e:	83 f8 03             	cmp    $0x3,%eax
  101291:	74 24                	je     1012b7 <trap_check_user+0x3c>
  101293:	c7 44 24 0c cc 30 10 	movl   $0x1030cc,0xc(%esp)
  10129a:	00 
  10129b:	c7 44 24 08 16 2f 10 	movl   $0x102f16,0x8(%esp)
  1012a2:	00 
  1012a3:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  1012aa:	00 
  1012ab:	c7 04 24 55 2f 10 00 	movl   $0x102f55,(%esp)
  1012b2:	e8 79 f0 ff ff       	call   100330 <debug_panic>

	cpu *c = &cpu_boot;	// cpu_cur doesn't work from user mode!
  1012b7:	c7 45 f0 00 50 10 00 	movl   $0x105000,-0x10(%ebp)
	c->recover = trap_check_recover;
  1012be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1012c1:	c7 80 a0 00 00 00 ce 	movl   $0x1011ce,0xa0(%eax)
  1012c8:	11 10 00 
	trap_check(&c->recoverdata);
  1012cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1012ce:	05 a4 00 00 00       	add    $0xa4,%eax
  1012d3:	89 04 24             	mov    %eax,(%esp)
  1012d6:	e8 1b 00 00 00       	call   1012f6 <trap_check>
	c->recover = NULL;	// No more mr. nice-guy; traps are real again
  1012db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1012de:	c7 80 a0 00 00 00 00 	movl   $0x0,0xa0(%eax)
  1012e5:	00 00 00 

	cprintf("trap_check_user() succeeded!\n");
  1012e8:	c7 04 24 e1 30 10 00 	movl   $0x1030e1,(%esp)
  1012ef:	e8 c1 10 00 00       	call   1023b5 <cprintf>
}
  1012f4:	c9                   	leave  
  1012f5:	c3                   	ret    

001012f6 <trap_check>:
void after_priv();

// Multi-purpose trap checking function.
void
trap_check(void **argsp)
{
  1012f6:	55                   	push   %ebp
  1012f7:	89 e5                	mov    %esp,%ebp
  1012f9:	57                   	push   %edi
  1012fa:	56                   	push   %esi
  1012fb:	53                   	push   %ebx
  1012fc:	83 ec 3c             	sub    $0x3c,%esp
	volatile int cookie = 0xfeedface;
  1012ff:	c7 45 e0 ce fa ed fe 	movl   $0xfeedface,-0x20(%ebp)
	volatile trap_check_args args;
	*argsp = (void*)&args;	// provide args needed for trap recovery
  101306:	8b 45 08             	mov    0x8(%ebp),%eax
  101309:	8d 55 d8             	lea    -0x28(%ebp),%edx
  10130c:	89 10                	mov    %edx,(%eax)

	// Try a divide by zero trap.
	// Be careful when using && to take the address of a label:
	// some versions of GCC (4.4.2 at least) will incorrectly try to
	// eliminate code it thinks is _only_ reachable via such a pointer.
	args.reip = after_div0;
  10130e:	c7 45 d8 1c 13 10 00 	movl   $0x10131c,-0x28(%ebp)
	asm volatile("div %0,%0; after_div0:" : : "r" (0));
  101315:	b8 00 00 00 00       	mov    $0x0,%eax
  10131a:	f7 f0                	div    %eax

0010131c <after_div0>:
	assert(args.trapno == T_DIVIDE);
  10131c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10131f:	85 c0                	test   %eax,%eax
  101321:	74 24                	je     101347 <after_div0+0x2b>
  101323:	c7 44 24 0c ff 30 10 	movl   $0x1030ff,0xc(%esp)
  10132a:	00 
  10132b:	c7 44 24 08 16 2f 10 	movl   $0x102f16,0x8(%esp)
  101332:	00 
  101333:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
  10133a:	00 
  10133b:	c7 04 24 55 2f 10 00 	movl   $0x102f55,(%esp)
  101342:	e8 e9 ef ff ff       	call   100330 <debug_panic>

	// Make sure we got our correct stack back with us.
	// The asm ensures gcc uses ebp/esp to get the cookie.
	asm volatile("" : : : "eax","ebx","ecx","edx","esi","edi");
	assert(cookie == 0xfeedface);
  101347:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10134a:	3d ce fa ed fe       	cmp    $0xfeedface,%eax
  10134f:	74 24                	je     101375 <after_div0+0x59>
  101351:	c7 44 24 0c 17 31 10 	movl   $0x103117,0xc(%esp)
  101358:	00 
  101359:	c7 44 24 08 16 2f 10 	movl   $0x102f16,0x8(%esp)
  101360:	00 
  101361:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
  101368:	00 
  101369:	c7 04 24 55 2f 10 00 	movl   $0x102f55,(%esp)
  101370:	e8 bb ef ff ff       	call   100330 <debug_panic>

	// Breakpoint trap
	args.reip = after_breakpoint;
  101375:	c7 45 d8 7d 13 10 00 	movl   $0x10137d,-0x28(%ebp)
	asm volatile("int3; after_breakpoint:");
  10137c:	cc                   	int3   

0010137d <after_breakpoint>:
	assert(args.trapno == T_BRKPT);
  10137d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  101380:	83 f8 03             	cmp    $0x3,%eax
  101383:	74 24                	je     1013a9 <after_breakpoint+0x2c>
  101385:	c7 44 24 0c 2c 31 10 	movl   $0x10312c,0xc(%esp)
  10138c:	00 
  10138d:	c7 44 24 08 16 2f 10 	movl   $0x102f16,0x8(%esp)
  101394:	00 
  101395:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  10139c:	00 
  10139d:	c7 04 24 55 2f 10 00 	movl   $0x102f55,(%esp)
  1013a4:	e8 87 ef ff ff       	call   100330 <debug_panic>

	// Overflow trap
	args.reip = after_overflow;
  1013a9:	c7 45 d8 b8 13 10 00 	movl   $0x1013b8,-0x28(%ebp)
	asm volatile("addl %0,%0; into; after_overflow:" : : "r" (0x70000000));
  1013b0:	b8 00 00 00 70       	mov    $0x70000000,%eax
  1013b5:	01 c0                	add    %eax,%eax
  1013b7:	ce                   	into   

001013b8 <after_overflow>:
	assert(args.trapno == T_OFLOW);
  1013b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1013bb:	83 f8 04             	cmp    $0x4,%eax
  1013be:	74 24                	je     1013e4 <after_overflow+0x2c>
  1013c0:	c7 44 24 0c 43 31 10 	movl   $0x103143,0xc(%esp)
  1013c7:	00 
  1013c8:	c7 44 24 08 16 2f 10 	movl   $0x102f16,0x8(%esp)
  1013cf:	00 
  1013d0:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
  1013d7:	00 
  1013d8:	c7 04 24 55 2f 10 00 	movl   $0x102f55,(%esp)
  1013df:	e8 4c ef ff ff       	call   100330 <debug_panic>

	// Bounds trap
	args.reip = after_bound;
  1013e4:	c7 45 d8 01 14 10 00 	movl   $0x101401,-0x28(%ebp)
	int bounds[2] = { 1, 3 };
  1013eb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1013f2:	c7 45 d4 03 00 00 00 	movl   $0x3,-0x2c(%ebp)
	asm volatile("boundl %0,%1; after_bound:" : : "r" (0), "m" (bounds[0]));
  1013f9:	b8 00 00 00 00       	mov    $0x0,%eax
  1013fe:	62 45 d0             	bound  %eax,-0x30(%ebp)

00101401 <after_bound>:
	assert(args.trapno == T_BOUND);
  101401:	8b 45 dc             	mov    -0x24(%ebp),%eax
  101404:	83 f8 05             	cmp    $0x5,%eax
  101407:	74 24                	je     10142d <after_bound+0x2c>
  101409:	c7 44 24 0c 5a 31 10 	movl   $0x10315a,0xc(%esp)
  101410:	00 
  101411:	c7 44 24 08 16 2f 10 	movl   $0x102f16,0x8(%esp)
  101418:	00 
  101419:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  101420:	00 
  101421:	c7 04 24 55 2f 10 00 	movl   $0x102f55,(%esp)
  101428:	e8 03 ef ff ff       	call   100330 <debug_panic>

	// Illegal instruction trap
	args.reip = after_illegal;
  10142d:	c7 45 d8 36 14 10 00 	movl   $0x101436,-0x28(%ebp)
	asm volatile("ud2; after_illegal:");	// guaranteed to be undefined
  101434:	0f 0b                	ud2    

00101436 <after_illegal>:
	assert(args.trapno == T_ILLOP);
  101436:	8b 45 dc             	mov    -0x24(%ebp),%eax
  101439:	83 f8 06             	cmp    $0x6,%eax
  10143c:	74 24                	je     101462 <after_illegal+0x2c>
  10143e:	c7 44 24 0c 71 31 10 	movl   $0x103171,0xc(%esp)
  101445:	00 
  101446:	c7 44 24 08 16 2f 10 	movl   $0x102f16,0x8(%esp)
  10144d:	00 
  10144e:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
  101455:	00 
  101456:	c7 04 24 55 2f 10 00 	movl   $0x102f55,(%esp)
  10145d:	e8 ce ee ff ff       	call   100330 <debug_panic>

	// General protection fault due to invalid segment load
	args.reip = after_gpfault;
  101462:	c7 45 d8 70 14 10 00 	movl   $0x101470,-0x28(%ebp)
	asm volatile("movl %0,%%fs; after_gpfault:" : : "r" (-1));
  101469:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10146e:	8e e0                	mov    %eax,%fs

00101470 <after_gpfault>:
	assert(args.trapno == T_GPFLT);
  101470:	8b 45 dc             	mov    -0x24(%ebp),%eax
  101473:	83 f8 0d             	cmp    $0xd,%eax
  101476:	74 24                	je     10149c <after_gpfault+0x2c>
  101478:	c7 44 24 0c 88 31 10 	movl   $0x103188,0xc(%esp)
  10147f:	00 
  101480:	c7 44 24 08 16 2f 10 	movl   $0x102f16,0x8(%esp)
  101487:	00 
  101488:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  10148f:	00 
  101490:	c7 04 24 55 2f 10 00 	movl   $0x102f55,(%esp)
  101497:	e8 94 ee ff ff       	call   100330 <debug_panic>

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  10149c:	8c 4d e6             	mov    %cs,-0x1a(%ebp)
        return cs;
  10149f:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax

	// General protection fault due to privilege violation
	if (read_cs() & 3) {
  1014a3:	0f b7 c0             	movzwl %ax,%eax
  1014a6:	83 e0 03             	and    $0x3,%eax
  1014a9:	85 c0                	test   %eax,%eax
  1014ab:	74 3a                	je     1014e7 <after_priv+0x2c>
		args.reip = after_priv;
  1014ad:	c7 45 d8 bb 14 10 00 	movl   $0x1014bb,-0x28(%ebp)
		asm volatile("lidt %0; after_priv:" : : "m" (idt_pd));
  1014b4:	0f 01 1d 00 60 10 00 	lidtl  0x106000

001014bb <after_priv>:
		assert(args.trapno == T_GPFLT);
  1014bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1014be:	83 f8 0d             	cmp    $0xd,%eax
  1014c1:	74 24                	je     1014e7 <after_priv+0x2c>
  1014c3:	c7 44 24 0c 88 31 10 	movl   $0x103188,0xc(%esp)
  1014ca:	00 
  1014cb:	c7 44 24 08 16 2f 10 	movl   $0x102f16,0x8(%esp)
  1014d2:	00 
  1014d3:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  1014da:	00 
  1014db:	c7 04 24 55 2f 10 00 	movl   $0x102f55,(%esp)
  1014e2:	e8 49 ee ff ff       	call   100330 <debug_panic>
	}

	// Make sure our stack cookie is still with us
	assert(cookie == 0xfeedface);
  1014e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1014ea:	3d ce fa ed fe       	cmp    $0xfeedface,%eax
  1014ef:	74 24                	je     101515 <after_priv+0x5a>
  1014f1:	c7 44 24 0c 17 31 10 	movl   $0x103117,0xc(%esp)
  1014f8:	00 
  1014f9:	c7 44 24 08 16 2f 10 	movl   $0x102f16,0x8(%esp)
  101500:	00 
  101501:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  101508:	00 
  101509:	c7 04 24 55 2f 10 00 	movl   $0x102f55,(%esp)
  101510:	e8 1b ee ff ff       	call   100330 <debug_panic>

	*argsp = NULL;	// recovery mechanism not needed anymore
  101515:	8b 45 08             	mov    0x8(%ebp),%eax
  101518:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
  10151e:	83 c4 3c             	add    $0x3c,%esp
  101521:	5b                   	pop    %ebx
  101522:	5e                   	pop    %esi
  101523:	5f                   	pop    %edi
  101524:	5d                   	pop    %ebp
  101525:	c3                   	ret    
  101526:	90                   	nop
  101527:	90                   	nop
  101528:	90                   	nop
  101529:	90                   	nop
  10152a:	90                   	nop
  10152b:	90                   	nop
  10152c:	90                   	nop
  10152d:	90                   	nop
  10152e:	90                   	nop
  10152f:	90                   	nop

00101530 <trap_return>:
.p2align 4, 0x90		/* 16-byte alignment, nop filled */
trap_return:
/*
 * Lab 1: Your code here for trap_return
 */
1:	jmp	1b		// just spin
  101530:	eb fe                	jmp    101530 <trap_return>
  101532:	90                   	nop
  101533:	90                   	nop

00101534 <video_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
video_init(void)
{
  101534:	55                   	push   %ebp
  101535:	89 e5                	mov    %esp,%ebp
  101537:	83 ec 30             	sub    $0x30,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	/* Get a pointer to the memory-mapped text display buffer. */
	cp = (uint16_t*) mem_ptr(CGA_BUF);
  10153a:	c7 45 d8 00 80 0b 00 	movl   $0xb8000,-0x28(%ebp)
	was = *cp;
  101541:	8b 45 d8             	mov    -0x28(%ebp),%eax
  101544:	0f b7 00             	movzwl (%eax),%eax
  101547:	66 89 45 de          	mov    %ax,-0x22(%ebp)
	*cp = (uint16_t) 0xA55A;
  10154b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10154e:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
  101553:	8b 45 d8             	mov    -0x28(%ebp),%eax
  101556:	0f b7 00             	movzwl (%eax),%eax
  101559:	66 3d 5a a5          	cmp    $0xa55a,%ax
  10155d:	74 13                	je     101572 <video_init+0x3e>
		cp = (uint16_t*) mem_ptr(MONO_BUF);
  10155f:	c7 45 d8 00 00 0b 00 	movl   $0xb0000,-0x28(%ebp)
		addr_6845 = MONO_BASE;
  101566:	c7 05 60 7f 10 00 b4 	movl   $0x3b4,0x107f60
  10156d:	03 00 00 
  101570:	eb 14                	jmp    101586 <video_init+0x52>
	} else {
		*cp = was;
  101572:	8b 45 d8             	mov    -0x28(%ebp),%eax
  101575:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101579:	66 89 10             	mov    %dx,(%eax)
		addr_6845 = CGA_BASE;
  10157c:	c7 05 60 7f 10 00 d4 	movl   $0x3d4,0x107f60
  101583:	03 00 00 
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
  101586:	a1 60 7f 10 00       	mov    0x107f60,%eax
  10158b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10158e:	c6 45 e7 0e          	movb   $0xe,-0x19(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  101592:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  101596:	8b 55 e8             	mov    -0x18(%ebp),%edx
  101599:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
  10159a:	a1 60 7f 10 00       	mov    0x107f60,%eax
  10159f:	83 c0 01             	add    $0x1,%eax
  1015a2:	89 45 ec             	mov    %eax,-0x14(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1015a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1015a8:	89 c2                	mov    %eax,%edx
  1015aa:	ec                   	in     (%dx),%al
  1015ab:	88 45 f2             	mov    %al,-0xe(%ebp)
	return data;
  1015ae:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
  1015b2:	0f b6 c0             	movzbl %al,%eax
  1015b5:	c1 e0 08             	shl    $0x8,%eax
  1015b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	outb(addr_6845, 15);
  1015bb:	a1 60 7f 10 00       	mov    0x107f60,%eax
  1015c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1015c3:	c6 45 f3 0f          	movb   $0xf,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  1015c7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1015ce:	ee                   	out    %al,(%dx)
	pos |= inb(addr_6845 + 1);
  1015cf:	a1 60 7f 10 00       	mov    0x107f60,%eax
  1015d4:	83 c0 01             	add    $0x1,%eax
  1015d7:	89 45 f8             	mov    %eax,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1015da:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1015dd:	89 c2                	mov    %eax,%edx
  1015df:	ec                   	in     (%dx),%al
  1015e0:	88 45 ff             	mov    %al,-0x1(%ebp)
	return data;
  1015e3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
  1015e7:	0f b6 c0             	movzbl %al,%eax
  1015ea:	09 45 e0             	or     %eax,-0x20(%ebp)

	crt_buf = (uint16_t*) cp;
  1015ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1015f0:	a3 64 7f 10 00       	mov    %eax,0x107f64
	crt_pos = pos;
  1015f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1015f8:	66 a3 68 7f 10 00    	mov    %ax,0x107f68
}
  1015fe:	c9                   	leave  
  1015ff:	c3                   	ret    

00101600 <video_putc>:



void
video_putc(int c)
{
  101600:	55                   	push   %ebp
  101601:	89 e5                	mov    %esp,%ebp
  101603:	53                   	push   %ebx
  101604:	83 ec 44             	sub    $0x44,%esp
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
  101607:	8b 45 08             	mov    0x8(%ebp),%eax
  10160a:	b0 00                	mov    $0x0,%al
  10160c:	85 c0                	test   %eax,%eax
  10160e:	75 07                	jne    101617 <video_putc+0x17>
		c |= 0x0700;
  101610:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)

	switch (c & 0xff) {
  101617:	8b 45 08             	mov    0x8(%ebp),%eax
  10161a:	25 ff 00 00 00       	and    $0xff,%eax
  10161f:	83 f8 09             	cmp    $0x9,%eax
  101622:	0f 84 ae 00 00 00    	je     1016d6 <video_putc+0xd6>
  101628:	83 f8 09             	cmp    $0x9,%eax
  10162b:	7f 0a                	jg     101637 <video_putc+0x37>
  10162d:	83 f8 08             	cmp    $0x8,%eax
  101630:	74 14                	je     101646 <video_putc+0x46>
  101632:	e9 dd 00 00 00       	jmp    101714 <video_putc+0x114>
  101637:	83 f8 0a             	cmp    $0xa,%eax
  10163a:	74 4e                	je     10168a <video_putc+0x8a>
  10163c:	83 f8 0d             	cmp    $0xd,%eax
  10163f:	74 59                	je     10169a <video_putc+0x9a>
  101641:	e9 ce 00 00 00       	jmp    101714 <video_putc+0x114>
	case '\b':
		if (crt_pos > 0) {
  101646:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  10164d:	66 85 c0             	test   %ax,%ax
  101650:	0f 84 e4 00 00 00    	je     10173a <video_putc+0x13a>
			crt_pos--;
  101656:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  10165d:	83 e8 01             	sub    $0x1,%eax
  101660:	66 a3 68 7f 10 00    	mov    %ax,0x107f68
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101666:	a1 64 7f 10 00       	mov    0x107f64,%eax
  10166b:	0f b7 15 68 7f 10 00 	movzwl 0x107f68,%edx
  101672:	0f b7 d2             	movzwl %dx,%edx
  101675:	01 d2                	add    %edx,%edx
  101677:	8d 14 10             	lea    (%eax,%edx,1),%edx
  10167a:	8b 45 08             	mov    0x8(%ebp),%eax
  10167d:	b0 00                	mov    $0x0,%al
  10167f:	83 c8 20             	or     $0x20,%eax
  101682:	66 89 02             	mov    %ax,(%edx)
		}
		break;
  101685:	e9 b1 00 00 00       	jmp    10173b <video_putc+0x13b>
	case '\n':
		crt_pos += CRT_COLS;
  10168a:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  101691:	83 c0 50             	add    $0x50,%eax
  101694:	66 a3 68 7f 10 00    	mov    %ax,0x107f68
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
  10169a:	0f b7 1d 68 7f 10 00 	movzwl 0x107f68,%ebx
  1016a1:	0f b7 0d 68 7f 10 00 	movzwl 0x107f68,%ecx
  1016a8:	0f b7 c1             	movzwl %cx,%eax
  1016ab:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  1016b1:	c1 e8 10             	shr    $0x10,%eax
  1016b4:	89 c2                	mov    %eax,%edx
  1016b6:	66 c1 ea 06          	shr    $0x6,%dx
  1016ba:	89 d0                	mov    %edx,%eax
  1016bc:	c1 e0 02             	shl    $0x2,%eax
  1016bf:	01 d0                	add    %edx,%eax
  1016c1:	c1 e0 04             	shl    $0x4,%eax
  1016c4:	89 ca                	mov    %ecx,%edx
  1016c6:	66 29 c2             	sub    %ax,%dx
  1016c9:	89 d8                	mov    %ebx,%eax
  1016cb:	66 29 d0             	sub    %dx,%ax
  1016ce:	66 a3 68 7f 10 00    	mov    %ax,0x107f68
		break;
  1016d4:	eb 65                	jmp    10173b <video_putc+0x13b>
	case '\t':
		video_putc(' ');
  1016d6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1016dd:	e8 1e ff ff ff       	call   101600 <video_putc>
		video_putc(' ');
  1016e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1016e9:	e8 12 ff ff ff       	call   101600 <video_putc>
		video_putc(' ');
  1016ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1016f5:	e8 06 ff ff ff       	call   101600 <video_putc>
		video_putc(' ');
  1016fa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101701:	e8 fa fe ff ff       	call   101600 <video_putc>
		video_putc(' ');
  101706:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10170d:	e8 ee fe ff ff       	call   101600 <video_putc>
		break;
  101712:	eb 27                	jmp    10173b <video_putc+0x13b>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
  101714:	8b 15 64 7f 10 00    	mov    0x107f64,%edx
  10171a:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  101721:	0f b7 c8             	movzwl %ax,%ecx
  101724:	01 c9                	add    %ecx,%ecx
  101726:	8d 0c 0a             	lea    (%edx,%ecx,1),%ecx
  101729:	8b 55 08             	mov    0x8(%ebp),%edx
  10172c:	66 89 11             	mov    %dx,(%ecx)
  10172f:	83 c0 01             	add    $0x1,%eax
  101732:	66 a3 68 7f 10 00    	mov    %ax,0x107f68
  101738:	eb 01                	jmp    10173b <video_putc+0x13b>
	case '\b':
		if (crt_pos > 0) {
			crt_pos--;
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
		}
		break;
  10173a:	90                   	nop
		crt_buf[crt_pos++] = c;		/* write the character */
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
  10173b:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  101742:	66 3d cf 07          	cmp    $0x7cf,%ax
  101746:	76 5b                	jbe    1017a3 <video_putc+0x1a3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS,
  101748:	a1 64 7f 10 00       	mov    0x107f64,%eax
  10174d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101753:	a1 64 7f 10 00       	mov    0x107f64,%eax
  101758:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10175f:	00 
  101760:	89 54 24 04          	mov    %edx,0x4(%esp)
  101764:	89 04 24             	mov    %eax,(%esp)
  101767:	e8 a4 0e 00 00       	call   102610 <memmove>
			(CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
  10176c:	c7 45 d4 80 07 00 00 	movl   $0x780,-0x2c(%ebp)
  101773:	eb 15                	jmp    10178a <video_putc+0x18a>
			crt_buf[i] = 0x0700 | ' ';
  101775:	a1 64 7f 10 00       	mov    0x107f64,%eax
  10177a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10177d:	01 d2                	add    %edx,%edx
  10177f:	01 d0                	add    %edx,%eax
  101781:	66 c7 00 20 07       	movw   $0x720,(%eax)
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS,
			(CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
  101786:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
  10178a:	81 7d d4 cf 07 00 00 	cmpl   $0x7cf,-0x2c(%ebp)
  101791:	7e e2                	jle    101775 <video_putc+0x175>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
  101793:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  10179a:	83 e8 50             	sub    $0x50,%eax
  10179d:	66 a3 68 7f 10 00    	mov    %ax,0x107f68
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
  1017a3:	a1 60 7f 10 00       	mov    0x107f60,%eax
  1017a8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1017ab:	c6 45 db 0e          	movb   $0xe,-0x25(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  1017af:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  1017b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1017b6:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
  1017b7:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  1017be:	66 c1 e8 08          	shr    $0x8,%ax
  1017c2:	0f b6 c0             	movzbl %al,%eax
  1017c5:	8b 15 60 7f 10 00    	mov    0x107f60,%edx
  1017cb:	83 c2 01             	add    $0x1,%edx
  1017ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1017d1:	88 45 e3             	mov    %al,-0x1d(%ebp)
  1017d4:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1017d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1017db:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
  1017dc:	a1 60 7f 10 00       	mov    0x107f60,%eax
  1017e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1017e4:	c6 45 eb 0f          	movb   $0xf,-0x15(%ebp)
  1017e8:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  1017ec:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1017ef:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos);
  1017f0:	0f b7 05 68 7f 10 00 	movzwl 0x107f68,%eax
  1017f7:	0f b6 c0             	movzbl %al,%eax
  1017fa:	8b 15 60 7f 10 00    	mov    0x107f60,%edx
  101800:	83 c2 01             	add    $0x1,%edx
  101803:	89 55 f4             	mov    %edx,-0xc(%ebp)
  101806:	88 45 f3             	mov    %al,-0xd(%ebp)
  101809:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10180d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101810:	ee                   	out    %al,(%dx)
}
  101811:	83 c4 44             	add    $0x44,%esp
  101814:	5b                   	pop    %ebx
  101815:	5d                   	pop    %ebp
  101816:	c3                   	ret    
  101817:	90                   	nop

00101818 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
  101818:	55                   	push   %ebp
  101819:	89 e5                	mov    %esp,%ebp
  10181b:	83 ec 38             	sub    $0x38,%esp
  10181e:	c7 45 e4 64 00 00 00 	movl   $0x64,-0x1c(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101825:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101828:	89 c2                	mov    %eax,%edx
  10182a:	ec                   	in     (%dx),%al
  10182b:	88 45 eb             	mov    %al,-0x15(%ebp)
	return data;
  10182e:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
  101832:	0f b6 c0             	movzbl %al,%eax
  101835:	83 e0 01             	and    $0x1,%eax
  101838:	85 c0                	test   %eax,%eax
  10183a:	75 0a                	jne    101846 <kbd_proc_data+0x2e>
		return -1;
  10183c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101841:	e9 5a 01 00 00       	jmp    1019a0 <kbd_proc_data+0x188>
  101846:	c7 45 ec 60 00 00 00 	movl   $0x60,-0x14(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  10184d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101850:	89 c2                	mov    %eax,%edx
  101852:	ec                   	in     (%dx),%al
  101853:	88 45 f2             	mov    %al,-0xe(%ebp)
	return data;
  101856:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax

	data = inb(KBDATAP);
  10185a:	88 45 e3             	mov    %al,-0x1d(%ebp)

	if (data == 0xE0) {
  10185d:	80 7d e3 e0          	cmpb   $0xe0,-0x1d(%ebp)
  101861:	75 17                	jne    10187a <kbd_proc_data+0x62>
		// E0 escape character
		shift |= E0ESC;
  101863:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  101868:	83 c8 40             	or     $0x40,%eax
  10186b:	a3 6c 7f 10 00       	mov    %eax,0x107f6c
		return 0;
  101870:	b8 00 00 00 00       	mov    $0x0,%eax
  101875:	e9 26 01 00 00       	jmp    1019a0 <kbd_proc_data+0x188>
	} else if (data & 0x80) {
  10187a:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  10187e:	84 c0                	test   %al,%al
  101880:	79 47                	jns    1018c9 <kbd_proc_data+0xb1>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
  101882:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  101887:	83 e0 40             	and    $0x40,%eax
  10188a:	85 c0                	test   %eax,%eax
  10188c:	75 09                	jne    101897 <kbd_proc_data+0x7f>
  10188e:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  101892:	83 e0 7f             	and    $0x7f,%eax
  101895:	eb 04                	jmp    10189b <kbd_proc_data+0x83>
  101897:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  10189b:	88 45 e3             	mov    %al,-0x1d(%ebp)
		shift &= ~(shiftcode[data] | E0ESC);
  10189e:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1018a2:	0f b6 80 20 60 10 00 	movzbl 0x106020(%eax),%eax
  1018a9:	83 c8 40             	or     $0x40,%eax
  1018ac:	0f b6 c0             	movzbl %al,%eax
  1018af:	f7 d0                	not    %eax
  1018b1:	89 c2                	mov    %eax,%edx
  1018b3:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  1018b8:	21 d0                	and    %edx,%eax
  1018ba:	a3 6c 7f 10 00       	mov    %eax,0x107f6c
		return 0;
  1018bf:	b8 00 00 00 00       	mov    $0x0,%eax
  1018c4:	e9 d7 00 00 00       	jmp    1019a0 <kbd_proc_data+0x188>
	} else if (shift & E0ESC) {
  1018c9:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  1018ce:	83 e0 40             	and    $0x40,%eax
  1018d1:	85 c0                	test   %eax,%eax
  1018d3:	74 11                	je     1018e6 <kbd_proc_data+0xce>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
  1018d5:	80 4d e3 80          	orb    $0x80,-0x1d(%ebp)
		shift &= ~E0ESC;
  1018d9:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  1018de:	83 e0 bf             	and    $0xffffffbf,%eax
  1018e1:	a3 6c 7f 10 00       	mov    %eax,0x107f6c
	}

	shift |= shiftcode[data];
  1018e6:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1018ea:	0f b6 80 20 60 10 00 	movzbl 0x106020(%eax),%eax
  1018f1:	0f b6 d0             	movzbl %al,%edx
  1018f4:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  1018f9:	09 d0                	or     %edx,%eax
  1018fb:	a3 6c 7f 10 00       	mov    %eax,0x107f6c
	shift ^= togglecode[data];
  101900:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  101904:	0f b6 80 20 61 10 00 	movzbl 0x106120(%eax),%eax
  10190b:	0f b6 d0             	movzbl %al,%edx
  10190e:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  101913:	31 d0                	xor    %edx,%eax
  101915:	a3 6c 7f 10 00       	mov    %eax,0x107f6c

	c = charcode[shift & (CTL | SHIFT)][data];
  10191a:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  10191f:	83 e0 03             	and    $0x3,%eax
  101922:	8b 14 85 20 65 10 00 	mov    0x106520(,%eax,4),%edx
  101929:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  10192d:	8d 04 02             	lea    (%edx,%eax,1),%eax
  101930:	0f b6 00             	movzbl (%eax),%eax
  101933:	0f b6 c0             	movzbl %al,%eax
  101936:	89 45 dc             	mov    %eax,-0x24(%ebp)
	if (shift & CAPSLOCK) {
  101939:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  10193e:	83 e0 08             	and    $0x8,%eax
  101941:	85 c0                	test   %eax,%eax
  101943:	74 22                	je     101967 <kbd_proc_data+0x14f>
		if ('a' <= c && c <= 'z')
  101945:	83 7d dc 60          	cmpl   $0x60,-0x24(%ebp)
  101949:	7e 0c                	jle    101957 <kbd_proc_data+0x13f>
  10194b:	83 7d dc 7a          	cmpl   $0x7a,-0x24(%ebp)
  10194f:	7f 06                	jg     101957 <kbd_proc_data+0x13f>
			c += 'A' - 'a';
  101951:	83 6d dc 20          	subl   $0x20,-0x24(%ebp)
	shift |= shiftcode[data];
	shift ^= togglecode[data];

	c = charcode[shift & (CTL | SHIFT)][data];
	if (shift & CAPSLOCK) {
		if ('a' <= c && c <= 'z')
  101955:	eb 10                	jmp    101967 <kbd_proc_data+0x14f>
			c += 'A' - 'a';
		else if ('A' <= c && c <= 'Z')
  101957:	83 7d dc 40          	cmpl   $0x40,-0x24(%ebp)
  10195b:	7e 0a                	jle    101967 <kbd_proc_data+0x14f>
  10195d:	83 7d dc 5a          	cmpl   $0x5a,-0x24(%ebp)
  101961:	7f 04                	jg     101967 <kbd_proc_data+0x14f>
			c += 'a' - 'A';
  101963:	83 45 dc 20          	addl   $0x20,-0x24(%ebp)
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101967:	a1 6c 7f 10 00       	mov    0x107f6c,%eax
  10196c:	f7 d0                	not    %eax
  10196e:	83 e0 06             	and    $0x6,%eax
  101971:	85 c0                	test   %eax,%eax
  101973:	75 28                	jne    10199d <kbd_proc_data+0x185>
  101975:	81 7d dc e9 00 00 00 	cmpl   $0xe9,-0x24(%ebp)
  10197c:	75 1f                	jne    10199d <kbd_proc_data+0x185>
		cprintf("Rebooting!\n");
  10197e:	c7 04 24 50 33 10 00 	movl   $0x103350,(%esp)
  101985:	e8 2b 0a 00 00       	call   1023b5 <cprintf>
  10198a:	c7 45 f4 92 00 00 00 	movl   $0x92,-0xc(%ebp)
  101991:	c6 45 f3 03          	movb   $0x3,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  101995:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101999:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10199c:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
  10199d:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
  1019a0:	c9                   	leave  
  1019a1:	c3                   	ret    

001019a2 <kbd_intr>:

void
kbd_intr(void)
{
  1019a2:	55                   	push   %ebp
  1019a3:	89 e5                	mov    %esp,%ebp
  1019a5:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
  1019a8:	c7 04 24 18 18 10 00 	movl   $0x101818,(%esp)
  1019af:	e8 43 e8 ff ff       	call   1001f7 <cons_intr>
}
  1019b4:	c9                   	leave  
  1019b5:	c3                   	ret    

001019b6 <kbd_init>:

void
kbd_init(void)
{
  1019b6:	55                   	push   %ebp
  1019b7:	89 e5                	mov    %esp,%ebp
}
  1019b9:	5d                   	pop    %ebp
  1019ba:	c3                   	ret    
  1019bb:	90                   	nop

001019bc <delay>:


// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
  1019bc:	55                   	push   %ebp
  1019bd:	89 e5                	mov    %esp,%ebp
  1019bf:	83 ec 20             	sub    $0x20,%esp
  1019c2:	c7 45 e0 84 00 00 00 	movl   $0x84,-0x20(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1019c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1019cc:	89 c2                	mov    %eax,%edx
  1019ce:	ec                   	in     (%dx),%al
  1019cf:	88 45 e7             	mov    %al,-0x19(%ebp)
	return data;
  1019d2:	c7 45 e8 84 00 00 00 	movl   $0x84,-0x18(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1019d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1019dc:	89 c2                	mov    %eax,%edx
  1019de:	ec                   	in     (%dx),%al
  1019df:	88 45 ef             	mov    %al,-0x11(%ebp)
	return data;
  1019e2:	c7 45 f0 84 00 00 00 	movl   $0x84,-0x10(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1019e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1019ec:	89 c2                	mov    %eax,%edx
  1019ee:	ec                   	in     (%dx),%al
  1019ef:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
  1019f2:	c7 45 f8 84 00 00 00 	movl   $0x84,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1019f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1019fc:	89 c2                	mov    %eax,%edx
  1019fe:	ec                   	in     (%dx),%al
  1019ff:	88 45 ff             	mov    %al,-0x1(%ebp)
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
  101a02:	c9                   	leave  
  101a03:	c3                   	ret    

00101a04 <serial_proc_data>:

static int
serial_proc_data(void)
{
  101a04:	55                   	push   %ebp
  101a05:	89 e5                	mov    %esp,%ebp
  101a07:	83 ec 10             	sub    $0x10,%esp
  101a0a:	c7 45 f0 fd 03 00 00 	movl   $0x3fd,-0x10(%ebp)
  101a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101a14:	89 c2                	mov    %eax,%edx
  101a16:	ec                   	in     (%dx),%al
  101a17:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
  101a1a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
  101a1e:	0f b6 c0             	movzbl %al,%eax
  101a21:	83 e0 01             	and    $0x1,%eax
  101a24:	85 c0                	test   %eax,%eax
  101a26:	75 07                	jne    101a2f <serial_proc_data+0x2b>
		return -1;
  101a28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101a2d:	eb 17                	jmp    101a46 <serial_proc_data+0x42>
  101a2f:	c7 45 f8 f8 03 00 00 	movl   $0x3f8,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101a36:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a39:	89 c2                	mov    %eax,%edx
  101a3b:	ec                   	in     (%dx),%al
  101a3c:	88 45 ff             	mov    %al,-0x1(%ebp)
	return data;
  101a3f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
	return inb(COM1+COM_RX);
  101a43:	0f b6 c0             	movzbl %al,%eax
}
  101a46:	c9                   	leave  
  101a47:	c3                   	ret    

00101a48 <serial_intr>:

void
serial_intr(void)
{
  101a48:	55                   	push   %ebp
  101a49:	89 e5                	mov    %esp,%ebp
  101a4b:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
  101a4e:	a1 80 7f 10 00       	mov    0x107f80,%eax
  101a53:	85 c0                	test   %eax,%eax
  101a55:	74 0c                	je     101a63 <serial_intr+0x1b>
		cons_intr(serial_proc_data);
  101a57:	c7 04 24 04 1a 10 00 	movl   $0x101a04,(%esp)
  101a5e:	e8 94 e7 ff ff       	call   1001f7 <cons_intr>
}
  101a63:	c9                   	leave  
  101a64:	c3                   	ret    

00101a65 <serial_putc>:

void
serial_putc(int c)
{
  101a65:	55                   	push   %ebp
  101a66:	89 e5                	mov    %esp,%ebp
  101a68:	83 ec 10             	sub    $0x10,%esp
	if (!serial_exists)
  101a6b:	a1 80 7f 10 00       	mov    0x107f80,%eax
  101a70:	85 c0                	test   %eax,%eax
  101a72:	74 53                	je     101ac7 <serial_putc+0x62>
		return;

	int i;
	for (i = 0;
  101a74:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  101a7b:	eb 09                	jmp    101a86 <serial_putc+0x21>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
  101a7d:	e8 3a ff ff ff       	call   1019bc <delay>
		return;

	int i;
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
  101a82:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  101a86:	c7 45 f4 fd 03 00 00 	movl   $0x3fd,-0xc(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101a90:	89 c2                	mov    %eax,%edx
  101a92:	ec                   	in     (%dx),%al
  101a93:	88 45 fa             	mov    %al,-0x6(%ebp)
	return data;
  101a96:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
	if (!serial_exists)
		return;

	int i;
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  101a9a:	0f b6 c0             	movzbl %al,%eax
  101a9d:	83 e0 20             	and    $0x20,%eax
{
	if (!serial_exists)
		return;

	int i;
	for (i = 0;
  101aa0:	85 c0                	test   %eax,%eax
  101aa2:	75 09                	jne    101aad <serial_putc+0x48>
  101aa4:	81 7d f0 ff 31 00 00 	cmpl   $0x31ff,-0x10(%ebp)
  101aab:	7e d0                	jle    101a7d <serial_putc+0x18>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
  101aad:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab0:	0f b6 c0             	movzbl %al,%eax
  101ab3:	c7 45 fc f8 03 00 00 	movl   $0x3f8,-0x4(%ebp)
  101aba:	88 45 fb             	mov    %al,-0x5(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  101abd:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  101ac1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101ac4:	ee                   	out    %al,(%dx)
  101ac5:	eb 01                	jmp    101ac8 <serial_putc+0x63>

void
serial_putc(int c)
{
	if (!serial_exists)
		return;
  101ac7:	90                   	nop
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
}
  101ac8:	c9                   	leave  
  101ac9:	c3                   	ret    

00101aca <serial_init>:

void
serial_init(void)
{
  101aca:	55                   	push   %ebp
  101acb:	89 e5                	mov    %esp,%ebp
  101acd:	83 ec 50             	sub    $0x50,%esp
  101ad0:	c7 45 b4 fa 03 00 00 	movl   $0x3fa,-0x4c(%ebp)
  101ad7:	c6 45 b3 00          	movb   $0x0,-0x4d(%ebp)
  101adb:	0f b6 45 b3          	movzbl -0x4d(%ebp),%eax
  101adf:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  101ae2:	ee                   	out    %al,(%dx)
  101ae3:	c7 45 bc fb 03 00 00 	movl   $0x3fb,-0x44(%ebp)
  101aea:	c6 45 bb 80          	movb   $0x80,-0x45(%ebp)
  101aee:	0f b6 45 bb          	movzbl -0x45(%ebp),%eax
  101af2:	8b 55 bc             	mov    -0x44(%ebp),%edx
  101af5:	ee                   	out    %al,(%dx)
  101af6:	c7 45 c4 f8 03 00 00 	movl   $0x3f8,-0x3c(%ebp)
  101afd:	c6 45 c3 0c          	movb   $0xc,-0x3d(%ebp)
  101b01:	0f b6 45 c3          	movzbl -0x3d(%ebp),%eax
  101b05:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  101b08:	ee                   	out    %al,(%dx)
  101b09:	c7 45 cc f9 03 00 00 	movl   $0x3f9,-0x34(%ebp)
  101b10:	c6 45 cb 00          	movb   $0x0,-0x35(%ebp)
  101b14:	0f b6 45 cb          	movzbl -0x35(%ebp),%eax
  101b18:	8b 55 cc             	mov    -0x34(%ebp),%edx
  101b1b:	ee                   	out    %al,(%dx)
  101b1c:	c7 45 d4 fb 03 00 00 	movl   $0x3fb,-0x2c(%ebp)
  101b23:	c6 45 d3 03          	movb   $0x3,-0x2d(%ebp)
  101b27:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
  101b2b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  101b2e:	ee                   	out    %al,(%dx)
  101b2f:	c7 45 dc fc 03 00 00 	movl   $0x3fc,-0x24(%ebp)
  101b36:	c6 45 db 00          	movb   $0x0,-0x25(%ebp)
  101b3a:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  101b3e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  101b41:	ee                   	out    %al,(%dx)
  101b42:	c7 45 e4 f9 03 00 00 	movl   $0x3f9,-0x1c(%ebp)
  101b49:	c6 45 e3 01          	movb   $0x1,-0x1d(%ebp)
  101b4d:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  101b51:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  101b54:	ee                   	out    %al,(%dx)
  101b55:	c7 45 e8 fd 03 00 00 	movl   $0x3fd,-0x18(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101b5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  101b5f:	89 c2                	mov    %eax,%edx
  101b61:	ec                   	in     (%dx),%al
  101b62:	88 45 ef             	mov    %al,-0x11(%ebp)
	return data;
  101b65:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
  101b69:	3c ff                	cmp    $0xff,%al
  101b6b:	0f 95 c0             	setne  %al
  101b6e:	0f b6 c0             	movzbl %al,%eax
  101b71:	a3 80 7f 10 00       	mov    %eax,0x107f80
  101b76:	c7 45 f0 fa 03 00 00 	movl   $0x3fa,-0x10(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b80:	89 c2                	mov    %eax,%edx
  101b82:	ec                   	in     (%dx),%al
  101b83:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
  101b86:	c7 45 f8 f8 03 00 00 	movl   $0x3f8,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101b8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101b90:	89 c2                	mov    %eax,%edx
  101b92:	ec                   	in     (%dx),%al
  101b93:	88 45 ff             	mov    %al,-0x1(%ebp)
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);
}
  101b96:	c9                   	leave  
  101b97:	c3                   	ret    

00101b98 <nvram_read>:
#include <dev/nvram.h>


unsigned
nvram_read(unsigned reg)
{
  101b98:	55                   	push   %ebp
  101b99:	89 e5                	mov    %esp,%ebp
  101b9b:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
  101b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba1:	0f b6 c0             	movzbl %al,%eax
  101ba4:	c7 45 f4 70 00 00 00 	movl   $0x70,-0xc(%ebp)
  101bab:	88 45 f3             	mov    %al,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  101bae:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101bb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101bb5:	ee                   	out    %al,(%dx)
  101bb6:	c7 45 f8 71 00 00 00 	movl   $0x71,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  101bbd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101bc0:	89 c2                	mov    %eax,%edx
  101bc2:	ec                   	in     (%dx),%al
  101bc3:	88 45 ff             	mov    %al,-0x1(%ebp)
	return data;
  101bc6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
	return inb(IO_RTC+1);
  101bca:	0f b6 c0             	movzbl %al,%eax
}
  101bcd:	c9                   	leave  
  101bce:	c3                   	ret    

00101bcf <nvram_read16>:

unsigned
nvram_read16(unsigned r)
{
  101bcf:	55                   	push   %ebp
  101bd0:	89 e5                	mov    %esp,%ebp
  101bd2:	53                   	push   %ebx
  101bd3:	83 ec 04             	sub    $0x4,%esp
	return nvram_read(r) | (nvram_read(r + 1) << 8);
  101bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd9:	89 04 24             	mov    %eax,(%esp)
  101bdc:	e8 b7 ff ff ff       	call   101b98 <nvram_read>
  101be1:	89 c3                	mov    %eax,%ebx
  101be3:	8b 45 08             	mov    0x8(%ebp),%eax
  101be6:	83 c0 01             	add    $0x1,%eax
  101be9:	89 04 24             	mov    %eax,(%esp)
  101bec:	e8 a7 ff ff ff       	call   101b98 <nvram_read>
  101bf1:	c1 e0 08             	shl    $0x8,%eax
  101bf4:	09 d8                	or     %ebx,%eax
}
  101bf6:	83 c4 04             	add    $0x4,%esp
  101bf9:	5b                   	pop    %ebx
  101bfa:	5d                   	pop    %ebp
  101bfb:	c3                   	ret    

00101bfc <nvram_write>:

void
nvram_write(unsigned reg, unsigned datum)
{
  101bfc:	55                   	push   %ebp
  101bfd:	89 e5                	mov    %esp,%ebp
  101bff:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
  101c02:	8b 45 08             	mov    0x8(%ebp),%eax
  101c05:	0f b6 c0             	movzbl %al,%eax
  101c08:	c7 45 f4 70 00 00 00 	movl   $0x70,-0xc(%ebp)
  101c0f:	88 45 f3             	mov    %al,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  101c12:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101c16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101c19:	ee                   	out    %al,(%dx)
	outb(IO_RTC+1, datum);
  101c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c1d:	0f b6 c0             	movzbl %al,%eax
  101c20:	c7 45 fc 71 00 00 00 	movl   $0x71,-0x4(%ebp)
  101c27:	88 45 fb             	mov    %al,-0x5(%ebp)
  101c2a:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  101c2e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101c31:	ee                   	out    %al,(%dx)
}
  101c32:	c9                   	leave  
  101c33:	c3                   	ret    

00101c34 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static uintmax_t
getuint(printstate *st, va_list *ap)
{
  101c34:	55                   	push   %ebp
  101c35:	89 e5                	mov    %esp,%ebp
	if (st->flags & F_LL)
  101c37:	8b 45 08             	mov    0x8(%ebp),%eax
  101c3a:	8b 40 18             	mov    0x18(%eax),%eax
  101c3d:	83 e0 02             	and    $0x2,%eax
  101c40:	85 c0                	test   %eax,%eax
  101c42:	74 1c                	je     101c60 <getuint+0x2c>
		return va_arg(*ap, unsigned long long);
  101c44:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c47:	8b 00                	mov    (%eax),%eax
  101c49:	8d 50 08             	lea    0x8(%eax),%edx
  101c4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c4f:	89 10                	mov    %edx,(%eax)
  101c51:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c54:	8b 00                	mov    (%eax),%eax
  101c56:	83 e8 08             	sub    $0x8,%eax
  101c59:	8b 50 04             	mov    0x4(%eax),%edx
  101c5c:	8b 00                	mov    (%eax),%eax
  101c5e:	eb 47                	jmp    101ca7 <getuint+0x73>
	else if (st->flags & F_L)
  101c60:	8b 45 08             	mov    0x8(%ebp),%eax
  101c63:	8b 40 18             	mov    0x18(%eax),%eax
  101c66:	83 e0 01             	and    $0x1,%eax
  101c69:	84 c0                	test   %al,%al
  101c6b:	74 1e                	je     101c8b <getuint+0x57>
		return va_arg(*ap, unsigned long);
  101c6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c70:	8b 00                	mov    (%eax),%eax
  101c72:	8d 50 04             	lea    0x4(%eax),%edx
  101c75:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c78:	89 10                	mov    %edx,(%eax)
  101c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c7d:	8b 00                	mov    (%eax),%eax
  101c7f:	83 e8 04             	sub    $0x4,%eax
  101c82:	8b 00                	mov    (%eax),%eax
  101c84:	ba 00 00 00 00       	mov    $0x0,%edx
  101c89:	eb 1c                	jmp    101ca7 <getuint+0x73>
	else
		return va_arg(*ap, unsigned int);
  101c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c8e:	8b 00                	mov    (%eax),%eax
  101c90:	8d 50 04             	lea    0x4(%eax),%edx
  101c93:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c96:	89 10                	mov    %edx,(%eax)
  101c98:	8b 45 0c             	mov    0xc(%ebp),%eax
  101c9b:	8b 00                	mov    (%eax),%eax
  101c9d:	83 e8 04             	sub    $0x4,%eax
  101ca0:	8b 00                	mov    (%eax),%eax
  101ca2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  101ca7:	5d                   	pop    %ebp
  101ca8:	c3                   	ret    

00101ca9 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static intmax_t
getint(printstate *st, va_list *ap)
{
  101ca9:	55                   	push   %ebp
  101caa:	89 e5                	mov    %esp,%ebp
	if (st->flags & F_LL)
  101cac:	8b 45 08             	mov    0x8(%ebp),%eax
  101caf:	8b 40 18             	mov    0x18(%eax),%eax
  101cb2:	83 e0 02             	and    $0x2,%eax
  101cb5:	85 c0                	test   %eax,%eax
  101cb7:	74 1c                	je     101cd5 <getint+0x2c>
		return va_arg(*ap, long long);
  101cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  101cbc:	8b 00                	mov    (%eax),%eax
  101cbe:	8d 50 08             	lea    0x8(%eax),%edx
  101cc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  101cc4:	89 10                	mov    %edx,(%eax)
  101cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  101cc9:	8b 00                	mov    (%eax),%eax
  101ccb:	83 e8 08             	sub    $0x8,%eax
  101cce:	8b 50 04             	mov    0x4(%eax),%edx
  101cd1:	8b 00                	mov    (%eax),%eax
  101cd3:	eb 47                	jmp    101d1c <getint+0x73>
	else if (st->flags & F_L)
  101cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  101cd8:	8b 40 18             	mov    0x18(%eax),%eax
  101cdb:	83 e0 01             	and    $0x1,%eax
  101cde:	84 c0                	test   %al,%al
  101ce0:	74 1e                	je     101d00 <getint+0x57>
		return va_arg(*ap, long);
  101ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
  101ce5:	8b 00                	mov    (%eax),%eax
  101ce7:	8d 50 04             	lea    0x4(%eax),%edx
  101cea:	8b 45 0c             	mov    0xc(%ebp),%eax
  101ced:	89 10                	mov    %edx,(%eax)
  101cef:	8b 45 0c             	mov    0xc(%ebp),%eax
  101cf2:	8b 00                	mov    (%eax),%eax
  101cf4:	83 e8 04             	sub    $0x4,%eax
  101cf7:	8b 00                	mov    (%eax),%eax
  101cf9:	89 c2                	mov    %eax,%edx
  101cfb:	c1 fa 1f             	sar    $0x1f,%edx
  101cfe:	eb 1c                	jmp    101d1c <getint+0x73>
	else
		return va_arg(*ap, int);
  101d00:	8b 45 0c             	mov    0xc(%ebp),%eax
  101d03:	8b 00                	mov    (%eax),%eax
  101d05:	8d 50 04             	lea    0x4(%eax),%edx
  101d08:	8b 45 0c             	mov    0xc(%ebp),%eax
  101d0b:	89 10                	mov    %edx,(%eax)
  101d0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  101d10:	8b 00                	mov    (%eax),%eax
  101d12:	83 e8 04             	sub    $0x4,%eax
  101d15:	8b 00                	mov    (%eax),%eax
  101d17:	89 c2                	mov    %eax,%edx
  101d19:	c1 fa 1f             	sar    $0x1f,%edx
}
  101d1c:	5d                   	pop    %ebp
  101d1d:	c3                   	ret    

00101d1e <putpad>:

// Print padding characters, and an optional sign before a number.
static void
putpad(printstate *st)
{
  101d1e:	55                   	push   %ebp
  101d1f:	89 e5                	mov    %esp,%ebp
  101d21:	83 ec 18             	sub    $0x18,%esp
	while (--st->width >= 0)
  101d24:	eb 1a                	jmp    101d40 <putpad+0x22>
		st->putch(st->padc, st->putdat);
  101d26:	8b 45 08             	mov    0x8(%ebp),%eax
  101d29:	8b 08                	mov    (%eax),%ecx
  101d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  101d2e:	8b 50 04             	mov    0x4(%eax),%edx
  101d31:	8b 45 08             	mov    0x8(%ebp),%eax
  101d34:	8b 40 08             	mov    0x8(%eax),%eax
  101d37:	89 54 24 04          	mov    %edx,0x4(%esp)
  101d3b:	89 04 24             	mov    %eax,(%esp)
  101d3e:	ff d1                	call   *%ecx

// Print padding characters, and an optional sign before a number.
static void
putpad(printstate *st)
{
	while (--st->width >= 0)
  101d40:	8b 45 08             	mov    0x8(%ebp),%eax
  101d43:	8b 40 0c             	mov    0xc(%eax),%eax
  101d46:	8d 50 ff             	lea    -0x1(%eax),%edx
  101d49:	8b 45 08             	mov    0x8(%ebp),%eax
  101d4c:	89 50 0c             	mov    %edx,0xc(%eax)
  101d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  101d52:	8b 40 0c             	mov    0xc(%eax),%eax
  101d55:	85 c0                	test   %eax,%eax
  101d57:	79 cd                	jns    101d26 <putpad+0x8>
		st->putch(st->padc, st->putdat);
}
  101d59:	c9                   	leave  
  101d5a:	c3                   	ret    

00101d5b <putstr>:

// Print a string with a specified maximum length (-1=unlimited),
// with any appropriate left or right field padding.
static void
putstr(printstate *st, const char *str, int maxlen)
{
  101d5b:	55                   	push   %ebp
  101d5c:	89 e5                	mov    %esp,%ebp
  101d5e:	53                   	push   %ebx
  101d5f:	83 ec 24             	sub    $0x24,%esp
	const char *lim;		// find where the string actually ends
	if (maxlen < 0)
  101d62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  101d66:	79 18                	jns    101d80 <putstr+0x25>
		lim = strchr(str, 0);	// find the terminating null
  101d68:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  101d6f:	00 
  101d70:	8b 45 0c             	mov    0xc(%ebp),%eax
  101d73:	89 04 24             	mov    %eax,(%esp)
  101d76:	e8 e9 07 00 00       	call   102564 <strchr>
  101d7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  101d7e:	eb 2c                	jmp    101dac <putstr+0x51>
	else if ((lim = memchr(str, 0, maxlen)) == NULL)
  101d80:	8b 45 10             	mov    0x10(%ebp),%eax
  101d83:	89 44 24 08          	mov    %eax,0x8(%esp)
  101d87:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  101d8e:	00 
  101d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  101d92:	89 04 24             	mov    %eax,(%esp)
  101d95:	e8 ce 09 00 00       	call   102768 <memchr>
  101d9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  101d9d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  101da1:	75 09                	jne    101dac <putstr+0x51>
		lim = str + maxlen;
  101da3:	8b 45 10             	mov    0x10(%ebp),%eax
  101da6:	03 45 0c             	add    0xc(%ebp),%eax
  101da9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	st->width -= (lim-str);		// deduct string length from field width
  101dac:	8b 45 08             	mov    0x8(%ebp),%eax
  101daf:	8b 40 0c             	mov    0xc(%eax),%eax
  101db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  101db5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  101db8:	89 cb                	mov    %ecx,%ebx
  101dba:	29 d3                	sub    %edx,%ebx
  101dbc:	89 da                	mov    %ebx,%edx
  101dbe:	8d 14 10             	lea    (%eax,%edx,1),%edx
  101dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  101dc4:	89 50 0c             	mov    %edx,0xc(%eax)

	if (!(st->flags & F_RPAD))	// print left-side padding
  101dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  101dca:	8b 40 18             	mov    0x18(%eax),%eax
  101dcd:	83 e0 10             	and    $0x10,%eax
  101dd0:	85 c0                	test   %eax,%eax
  101dd2:	75 32                	jne    101e06 <putstr+0xab>
		putpad(st);		// (also leaves st->width == 0)
  101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  101dd7:	89 04 24             	mov    %eax,(%esp)
  101dda:	e8 3f ff ff ff       	call   101d1e <putpad>
	while (str < lim) {
  101ddf:	eb 25                	jmp    101e06 <putstr+0xab>
		char ch = *str++;
  101de1:	8b 45 0c             	mov    0xc(%ebp),%eax
  101de4:	0f b6 00             	movzbl (%eax),%eax
  101de7:	88 45 f7             	mov    %al,-0x9(%ebp)
  101dea:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
			st->putch(ch, st->putdat);
  101dee:	8b 45 08             	mov    0x8(%ebp),%eax
  101df1:	8b 08                	mov    (%eax),%ecx
  101df3:	8b 45 08             	mov    0x8(%ebp),%eax
  101df6:	8b 50 04             	mov    0x4(%eax),%edx
  101df9:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101dfd:	89 54 24 04          	mov    %edx,0x4(%esp)
  101e01:	89 04 24             	mov    %eax,(%esp)
  101e04:	ff d1                	call   *%ecx
		lim = str + maxlen;
	st->width -= (lim-str);		// deduct string length from field width

	if (!(st->flags & F_RPAD))	// print left-side padding
		putpad(st);		// (also leaves st->width == 0)
	while (str < lim) {
  101e06:	8b 45 0c             	mov    0xc(%ebp),%eax
  101e09:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  101e0c:	72 d3                	jb     101de1 <putstr+0x86>
		char ch = *str++;
			st->putch(ch, st->putdat);
	}
	putpad(st);			// print right-side padding
  101e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  101e11:	89 04 24             	mov    %eax,(%esp)
  101e14:	e8 05 ff ff ff       	call   101d1e <putpad>
}
  101e19:	83 c4 24             	add    $0x24,%esp
  101e1c:	5b                   	pop    %ebx
  101e1d:	5d                   	pop    %ebp
  101e1e:	c3                   	ret    

00101e1f <genint>:

// Generate a number (base <= 16) in reverse order into a string buffer.
static char *
genint(printstate *st, char *p, uintmax_t num)
{
  101e1f:	55                   	push   %ebp
  101e20:	89 e5                	mov    %esp,%ebp
  101e22:	53                   	push   %ebx
  101e23:	83 ec 24             	sub    $0x24,%esp
  101e26:	8b 45 10             	mov    0x10(%ebp),%eax
  101e29:	89 45 f0             	mov    %eax,-0x10(%ebp)
  101e2c:	8b 45 14             	mov    0x14(%ebp),%eax
  101e2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= st->base)
  101e32:	8b 45 08             	mov    0x8(%ebp),%eax
  101e35:	8b 40 1c             	mov    0x1c(%eax),%eax
  101e38:	89 c2                	mov    %eax,%edx
  101e3a:	c1 fa 1f             	sar    $0x1f,%edx
  101e3d:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  101e40:	77 4e                	ja     101e90 <genint+0x71>
  101e42:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  101e45:	72 05                	jb     101e4c <genint+0x2d>
  101e47:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  101e4a:	77 44                	ja     101e90 <genint+0x71>
		p = genint(st, p, num / st->base);	// output higher digits
  101e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  101e4f:	8b 40 1c             	mov    0x1c(%eax),%eax
  101e52:	89 c2                	mov    %eax,%edx
  101e54:	c1 fa 1f             	sar    $0x1f,%edx
  101e57:	89 44 24 08          	mov    %eax,0x8(%esp)
  101e5b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  101e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101e62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101e65:	89 04 24             	mov    %eax,(%esp)
  101e68:	89 54 24 04          	mov    %edx,0x4(%esp)
  101e6c:	e8 3f 09 00 00       	call   1027b0 <__udivdi3>
  101e71:	89 44 24 08          	mov    %eax,0x8(%esp)
  101e75:	89 54 24 0c          	mov    %edx,0xc(%esp)
  101e79:	8b 45 0c             	mov    0xc(%ebp),%eax
  101e7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e80:	8b 45 08             	mov    0x8(%ebp),%eax
  101e83:	89 04 24             	mov    %eax,(%esp)
  101e86:	e8 94 ff ff ff       	call   101e1f <genint>
  101e8b:	89 45 0c             	mov    %eax,0xc(%ebp)
  101e8e:	eb 1b                	jmp    101eab <genint+0x8c>
	else if (st->signc >= 0)
  101e90:	8b 45 08             	mov    0x8(%ebp),%eax
  101e93:	8b 40 14             	mov    0x14(%eax),%eax
  101e96:	85 c0                	test   %eax,%eax
  101e98:	78 11                	js     101eab <genint+0x8c>
		*p++ = st->signc;			// output leading sign
  101e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  101e9d:	8b 40 14             	mov    0x14(%eax),%eax
  101ea0:	89 c2                	mov    %eax,%edx
  101ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
  101ea5:	88 10                	mov    %dl,(%eax)
  101ea7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	*p++ = "0123456789abcdef"[num % st->base];	// output this digit
  101eab:	8b 45 08             	mov    0x8(%ebp),%eax
  101eae:	8b 40 1c             	mov    0x1c(%eax),%eax
  101eb1:	89 c1                	mov    %eax,%ecx
  101eb3:	89 c3                	mov    %eax,%ebx
  101eb5:	c1 fb 1f             	sar    $0x1f,%ebx
  101eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101ebb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101ebe:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  101ec2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  101ec6:	89 04 24             	mov    %eax,(%esp)
  101ec9:	89 54 24 04          	mov    %edx,0x4(%esp)
  101ecd:	e8 0e 0a 00 00       	call   1028e0 <__umoddi3>
  101ed2:	05 5c 33 10 00       	add    $0x10335c,%eax
  101ed7:	0f b6 10             	movzbl (%eax),%edx
  101eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  101edd:	88 10                	mov    %dl,(%eax)
  101edf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	return p;
  101ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
}
  101ee6:	83 c4 24             	add    $0x24,%esp
  101ee9:	5b                   	pop    %ebx
  101eea:	5d                   	pop    %ebp
  101eeb:	c3                   	ret    

00101eec <putint>:

// Print an integer with any appropriate field padding.
static void
putint(printstate *st, uintmax_t num, int base)
{
  101eec:	55                   	push   %ebp
  101eed:	89 e5                	mov    %esp,%ebp
  101eef:	83 ec 58             	sub    $0x58,%esp
  101ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
  101ef5:	89 45 c0             	mov    %eax,-0x40(%ebp)
  101ef8:	8b 45 10             	mov    0x10(%ebp),%eax
  101efb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	char buf[30], *p = buf;		// big enough for any 64-bit int in octal
  101efe:	8d 45 d6             	lea    -0x2a(%ebp),%eax
  101f01:	89 45 f4             	mov    %eax,-0xc(%ebp)
	st->base = base;		// select base for genint
  101f04:	8b 45 08             	mov    0x8(%ebp),%eax
  101f07:	8b 55 14             	mov    0x14(%ebp),%edx
  101f0a:	89 50 1c             	mov    %edx,0x1c(%eax)
	p = genint(st, p, num);		// output to the string buffer
  101f0d:	8b 45 c0             	mov    -0x40(%ebp),%eax
  101f10:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  101f13:	89 44 24 08          	mov    %eax,0x8(%esp)
  101f17:	89 54 24 0c          	mov    %edx,0xc(%esp)
  101f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f22:	8b 45 08             	mov    0x8(%ebp),%eax
  101f25:	89 04 24             	mov    %eax,(%esp)
  101f28:	e8 f2 fe ff ff       	call   101e1f <genint>
  101f2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	putstr(st, buf, p-buf);		// print it with left/right padding
  101f30:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101f33:	8d 45 d6             	lea    -0x2a(%ebp),%eax
  101f36:	89 d1                	mov    %edx,%ecx
  101f38:	29 c1                	sub    %eax,%ecx
  101f3a:	89 c8                	mov    %ecx,%eax
  101f3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  101f40:	8d 45 d6             	lea    -0x2a(%ebp),%eax
  101f43:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f47:	8b 45 08             	mov    0x8(%ebp),%eax
  101f4a:	89 04 24             	mov    %eax,(%esp)
  101f4d:	e8 09 fe ff ff       	call   101d5b <putstr>
}
  101f52:	c9                   	leave  
  101f53:	c3                   	ret    

00101f54 <vprintfmt>:
#endif	// ! PIOS_KERNEL

// Main function to format and print a string.
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  101f54:	55                   	push   %ebp
  101f55:	89 e5                	mov    %esp,%ebp
  101f57:	53                   	push   %ebx
  101f58:	83 ec 44             	sub    $0x44,%esp
	register int ch, err;

	printstate st = { .putch = putch, .putdat = putdat };
  101f5b:	8d 55 c8             	lea    -0x38(%ebp),%edx
  101f5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  101f63:	b8 20 00 00 00       	mov    $0x20,%eax
  101f68:	89 c3                	mov    %eax,%ebx
  101f6a:	83 e3 fc             	and    $0xfffffffc,%ebx
  101f6d:	b8 00 00 00 00       	mov    $0x0,%eax
  101f72:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
  101f75:	83 c0 04             	add    $0x4,%eax
  101f78:	39 d8                	cmp    %ebx,%eax
  101f7a:	72 f6                	jb     101f72 <vprintfmt+0x1e>
  101f7c:	01 c2                	add    %eax,%edx
  101f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  101f81:	89 45 c8             	mov    %eax,-0x38(%ebp)
  101f84:	8b 45 0c             	mov    0xc(%ebp),%eax
  101f87:	89 45 cc             	mov    %eax,-0x34(%ebp)
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  101f8a:	eb 17                	jmp    101fa3 <vprintfmt+0x4f>
			if (ch == '\0')
  101f8c:	85 db                	test   %ebx,%ebx
  101f8e:	0f 84 52 03 00 00    	je     1022e6 <vprintfmt+0x392>
				return;
			putch(ch, putdat);
  101f94:	8b 45 0c             	mov    0xc(%ebp),%eax
  101f97:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f9b:	89 1c 24             	mov    %ebx,(%esp)
  101f9e:	8b 45 08             	mov    0x8(%ebp),%eax
  101fa1:	ff d0                	call   *%eax
{
	register int ch, err;

	printstate st = { .putch = putch, .putdat = putdat };
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  101fa3:	8b 45 10             	mov    0x10(%ebp),%eax
  101fa6:	0f b6 00             	movzbl (%eax),%eax
  101fa9:	0f b6 d8             	movzbl %al,%ebx
  101fac:	83 fb 25             	cmp    $0x25,%ebx
  101faf:	0f 95 c0             	setne  %al
  101fb2:	83 45 10 01          	addl   $0x1,0x10(%ebp)
  101fb6:	84 c0                	test   %al,%al
  101fb8:	75 d2                	jne    101f8c <vprintfmt+0x38>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		st.padc = ' ';
  101fba:	c7 45 d0 20 00 00 00 	movl   $0x20,-0x30(%ebp)
		st.width = -1;
  101fc1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		st.prec = -1;
  101fc8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		st.signc = -1;
  101fcf:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		st.flags = 0;
  101fd6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		st.base = 10;
  101fdd:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
  101fe4:	eb 04                	jmp    101fea <vprintfmt+0x96>
			goto reswitch;

		case ' ': // prefix signless numeric values with a space
			if (st.signc < 0)	// (but only if no '+' is specified)
				st.signc = ' ';
			goto reswitch;
  101fe6:	90                   	nop
  101fe7:	eb 01                	jmp    101fea <vprintfmt+0x96>
		gotprec:
			if (!(st.flags & F_DOT)) {	// haven't seen a '.' yet?
				st.width = st.prec;	// then it's a field width
				st.prec = -1;
			}
			goto reswitch;
  101fe9:	90                   	nop
		st.signc = -1;
		st.flags = 0;
		st.base = 10;
		uintmax_t num;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  101fea:	8b 45 10             	mov    0x10(%ebp),%eax
  101fed:	0f b6 00             	movzbl (%eax),%eax
  101ff0:	0f b6 d8             	movzbl %al,%ebx
  101ff3:	89 d8                	mov    %ebx,%eax
  101ff5:	83 45 10 01          	addl   $0x1,0x10(%ebp)
  101ff9:	83 e8 20             	sub    $0x20,%eax
  101ffc:	83 f8 58             	cmp    $0x58,%eax
  101fff:	0f 87 b1 02 00 00    	ja     1022b6 <vprintfmt+0x362>
  102005:	8b 04 85 74 33 10 00 	mov    0x103374(,%eax,4),%eax
  10200c:	ff e0                	jmp    *%eax

		// modifier flags
		case '-': // pad on the right instead of the left
			st.flags |= F_RPAD;
  10200e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102011:	83 c8 10             	or     $0x10,%eax
  102014:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  102017:	eb d1                	jmp    101fea <vprintfmt+0x96>

		case '+': // prefix positive numeric values with a '+' sign
			st.signc = '+';
  102019:	c7 45 dc 2b 00 00 00 	movl   $0x2b,-0x24(%ebp)
			goto reswitch;
  102020:	eb c8                	jmp    101fea <vprintfmt+0x96>

		case ' ': // prefix signless numeric values with a space
			if (st.signc < 0)	// (but only if no '+' is specified)
  102022:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102025:	85 c0                	test   %eax,%eax
  102027:	79 bd                	jns    101fe6 <vprintfmt+0x92>
				st.signc = ' ';
  102029:	c7 45 dc 20 00 00 00 	movl   $0x20,-0x24(%ebp)
			goto reswitch;
  102030:	eb b8                	jmp    101fea <vprintfmt+0x96>

		// width or precision field
		case '0':
			if (!(st.flags & F_DOT))
  102032:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102035:	83 e0 08             	and    $0x8,%eax
  102038:	85 c0                	test   %eax,%eax
  10203a:	75 07                	jne    102043 <vprintfmt+0xef>
				st.padc = '0'; // pad with 0's instead of spaces
  10203c:	c7 45 d0 30 00 00 00 	movl   $0x30,-0x30(%ebp)
		case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9':
			for (st.prec = 0; ; ++fmt) {
  102043:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
				st.prec = st.prec * 10 + ch - '0';
  10204a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10204d:	89 d0                	mov    %edx,%eax
  10204f:	c1 e0 02             	shl    $0x2,%eax
  102052:	01 d0                	add    %edx,%eax
  102054:	01 c0                	add    %eax,%eax
  102056:	01 d8                	add    %ebx,%eax
  102058:	83 e8 30             	sub    $0x30,%eax
  10205b:	89 45 d8             	mov    %eax,-0x28(%ebp)
				ch = *fmt;
  10205e:	8b 45 10             	mov    0x10(%ebp),%eax
  102061:	0f b6 00             	movzbl (%eax),%eax
  102064:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  102067:	83 fb 2f             	cmp    $0x2f,%ebx
  10206a:	7e 21                	jle    10208d <vprintfmt+0x139>
  10206c:	83 fb 39             	cmp    $0x39,%ebx
  10206f:	7f 1f                	jg     102090 <vprintfmt+0x13c>
		case '0':
			if (!(st.flags & F_DOT))
				st.padc = '0'; // pad with 0's instead of spaces
		case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9':
			for (st.prec = 0; ; ++fmt) {
  102071:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				st.prec = st.prec * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  102075:	eb d3                	jmp    10204a <vprintfmt+0xf6>
			goto gotprec;

		case '*':
			st.prec = va_arg(ap, int);
  102077:	8b 45 14             	mov    0x14(%ebp),%eax
  10207a:	83 c0 04             	add    $0x4,%eax
  10207d:	89 45 14             	mov    %eax,0x14(%ebp)
  102080:	8b 45 14             	mov    0x14(%ebp),%eax
  102083:	83 e8 04             	sub    $0x4,%eax
  102086:	8b 00                	mov    (%eax),%eax
  102088:	89 45 d8             	mov    %eax,-0x28(%ebp)
  10208b:	eb 04                	jmp    102091 <vprintfmt+0x13d>
				st.prec = st.prec * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto gotprec;
  10208d:	90                   	nop
  10208e:	eb 01                	jmp    102091 <vprintfmt+0x13d>
  102090:	90                   	nop

		case '*':
			st.prec = va_arg(ap, int);
		gotprec:
			if (!(st.flags & F_DOT)) {	// haven't seen a '.' yet?
  102091:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102094:	83 e0 08             	and    $0x8,%eax
  102097:	85 c0                	test   %eax,%eax
  102099:	0f 85 4a ff ff ff    	jne    101fe9 <vprintfmt+0x95>
				st.width = st.prec;	// then it's a field width
  10209f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1020a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				st.prec = -1;
  1020a5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
			}
			goto reswitch;
  1020ac:	e9 39 ff ff ff       	jmp    101fea <vprintfmt+0x96>

		case '.':
			st.flags |= F_DOT;
  1020b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1020b4:	83 c8 08             	or     $0x8,%eax
  1020b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  1020ba:	e9 2b ff ff ff       	jmp    101fea <vprintfmt+0x96>

		case '#':
			st.flags |= F_ALT;
  1020bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1020c2:	83 c8 04             	or     $0x4,%eax
  1020c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  1020c8:	e9 1d ff ff ff       	jmp    101fea <vprintfmt+0x96>

		// long flag (doubled for long long)
		case 'l':
			st.flags |= (st.flags & F_L) ? F_LL : F_L;
  1020cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1020d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1020d3:	83 e0 01             	and    $0x1,%eax
  1020d6:	84 c0                	test   %al,%al
  1020d8:	74 07                	je     1020e1 <vprintfmt+0x18d>
  1020da:	b8 02 00 00 00       	mov    $0x2,%eax
  1020df:	eb 05                	jmp    1020e6 <vprintfmt+0x192>
  1020e1:	b8 01 00 00 00       	mov    $0x1,%eax
  1020e6:	09 d0                	or     %edx,%eax
  1020e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  1020eb:	e9 fa fe ff ff       	jmp    101fea <vprintfmt+0x96>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  1020f0:	8b 45 14             	mov    0x14(%ebp),%eax
  1020f3:	83 c0 04             	add    $0x4,%eax
  1020f6:	89 45 14             	mov    %eax,0x14(%ebp)
  1020f9:	8b 45 14             	mov    0x14(%ebp),%eax
  1020fc:	83 e8 04             	sub    $0x4,%eax
  1020ff:	8b 00                	mov    (%eax),%eax
  102101:	8b 55 0c             	mov    0xc(%ebp),%edx
  102104:	89 54 24 04          	mov    %edx,0x4(%esp)
  102108:	89 04 24             	mov    %eax,(%esp)
  10210b:	8b 45 08             	mov    0x8(%ebp),%eax
  10210e:	ff d0                	call   *%eax
			break;
  102110:	e9 cb 01 00 00       	jmp    1022e0 <vprintfmt+0x38c>

		// string
		case 's': {
			const char *s;
			if ((s = va_arg(ap, char *)) == NULL)
  102115:	8b 45 14             	mov    0x14(%ebp),%eax
  102118:	83 c0 04             	add    $0x4,%eax
  10211b:	89 45 14             	mov    %eax,0x14(%ebp)
  10211e:	8b 45 14             	mov    0x14(%ebp),%eax
  102121:	83 e8 04             	sub    $0x4,%eax
  102124:	8b 00                	mov    (%eax),%eax
  102126:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102129:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10212d:	75 07                	jne    102136 <vprintfmt+0x1e2>
				s = "(null)";
  10212f:	c7 45 f4 6d 33 10 00 	movl   $0x10336d,-0xc(%ebp)
			putstr(&st, s, st.prec);
  102136:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102139:	89 44 24 08          	mov    %eax,0x8(%esp)
  10213d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102140:	89 44 24 04          	mov    %eax,0x4(%esp)
  102144:	8d 45 c8             	lea    -0x38(%ebp),%eax
  102147:	89 04 24             	mov    %eax,(%esp)
  10214a:	e8 0c fc ff ff       	call   101d5b <putstr>
			break;
  10214f:	e9 8c 01 00 00       	jmp    1022e0 <vprintfmt+0x38c>
		    }

		// (signed) decimal
		case 'd':
			num = getint(&st, &ap);
  102154:	8d 45 14             	lea    0x14(%ebp),%eax
  102157:	89 44 24 04          	mov    %eax,0x4(%esp)
  10215b:	8d 45 c8             	lea    -0x38(%ebp),%eax
  10215e:	89 04 24             	mov    %eax,(%esp)
  102161:	e8 43 fb ff ff       	call   101ca9 <getint>
  102166:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102169:	89 55 ec             	mov    %edx,-0x14(%ebp)
			if ((intmax_t) num < 0) {
  10216c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10216f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102172:	85 d2                	test   %edx,%edx
  102174:	79 1a                	jns    102190 <vprintfmt+0x23c>
				num = -(intmax_t) num;
  102176:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102179:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10217c:	f7 d8                	neg    %eax
  10217e:	83 d2 00             	adc    $0x0,%edx
  102181:	f7 da                	neg    %edx
  102183:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102186:	89 55 ec             	mov    %edx,-0x14(%ebp)
				st.signc = '-';
  102189:	c7 45 dc 2d 00 00 00 	movl   $0x2d,-0x24(%ebp)
			}
			putint(&st, num, 10);
  102190:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  102197:	00 
  102198:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10219b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10219e:	89 44 24 04          	mov    %eax,0x4(%esp)
  1021a2:	89 54 24 08          	mov    %edx,0x8(%esp)
  1021a6:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1021a9:	89 04 24             	mov    %eax,(%esp)
  1021ac:	e8 3b fd ff ff       	call   101eec <putint>
			break;
  1021b1:	e9 2a 01 00 00       	jmp    1022e0 <vprintfmt+0x38c>

		// unsigned decimal
		case 'u':
			putint(&st, getuint(&st, &ap), 10);
  1021b6:	8d 45 14             	lea    0x14(%ebp),%eax
  1021b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1021bd:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1021c0:	89 04 24             	mov    %eax,(%esp)
  1021c3:	e8 6c fa ff ff       	call   101c34 <getuint>
  1021c8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  1021cf:	00 
  1021d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1021d4:	89 54 24 08          	mov    %edx,0x8(%esp)
  1021d8:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1021db:	89 04 24             	mov    %eax,(%esp)
  1021de:	e8 09 fd ff ff       	call   101eec <putint>
			break;
  1021e3:	e9 f8 00 00 00       	jmp    1022e0 <vprintfmt+0x38c>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);,,....
			putint(&st, getuint(&st, &ap), 8);
  1021e8:	8d 45 14             	lea    0x14(%ebp),%eax
  1021eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1021ef:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1021f2:	89 04 24             	mov    %eax,(%esp)
  1021f5:	e8 3a fa ff ff       	call   101c34 <getuint>
  1021fa:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  102201:	00 
  102202:	89 44 24 04          	mov    %eax,0x4(%esp)
  102206:	89 54 24 08          	mov    %edx,0x8(%esp)
  10220a:	8d 45 c8             	lea    -0x38(%ebp),%eax
  10220d:	89 04 24             	mov    %eax,(%esp)
  102210:	e8 d7 fc ff ff       	call   101eec <putint>
			
			break;
  102215:	e9 c6 00 00 00       	jmp    1022e0 <vprintfmt+0x38c>

		// (unsigned) hexadecimal
		case 'x':
			putint(&st, getuint(&st, &ap), 16);
  10221a:	8d 45 14             	lea    0x14(%ebp),%eax
  10221d:	89 44 24 04          	mov    %eax,0x4(%esp)
  102221:	8d 45 c8             	lea    -0x38(%ebp),%eax
  102224:	89 04 24             	mov    %eax,(%esp)
  102227:	e8 08 fa ff ff       	call   101c34 <getuint>
  10222c:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  102233:	00 
  102234:	89 44 24 04          	mov    %eax,0x4(%esp)
  102238:	89 54 24 08          	mov    %edx,0x8(%esp)
  10223c:	8d 45 c8             	lea    -0x38(%ebp),%eax
  10223f:	89 04 24             	mov    %eax,(%esp)
  102242:	e8 a5 fc ff ff       	call   101eec <putint>
			break;
  102247:	e9 94 00 00 00       	jmp    1022e0 <vprintfmt+0x38c>

		// pointer
		case 'p':
			putch('0', putdat);
  10224c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10224f:	89 44 24 04          	mov    %eax,0x4(%esp)
  102253:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  10225a:	8b 45 08             	mov    0x8(%ebp),%eax
  10225d:	ff d0                	call   *%eax
			putch('x', putdat);
  10225f:	8b 45 0c             	mov    0xc(%ebp),%eax
  102262:	89 44 24 04          	mov    %eax,0x4(%esp)
  102266:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  10226d:	8b 45 08             	mov    0x8(%ebp),%eax
  102270:	ff d0                	call   *%eax
			putint(&st, (uintptr_t) va_arg(ap, void *), 16);
  102272:	8b 45 14             	mov    0x14(%ebp),%eax
  102275:	83 c0 04             	add    $0x4,%eax
  102278:	89 45 14             	mov    %eax,0x14(%ebp)
  10227b:	8b 45 14             	mov    0x14(%ebp),%eax
  10227e:	83 e8 04             	sub    $0x4,%eax
  102281:	8b 00                	mov    (%eax),%eax
  102283:	ba 00 00 00 00       	mov    $0x0,%edx
  102288:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  10228f:	00 
  102290:	89 44 24 04          	mov    %eax,0x4(%esp)
  102294:	89 54 24 08          	mov    %edx,0x8(%esp)
  102298:	8d 45 c8             	lea    -0x38(%ebp),%eax
  10229b:	89 04 24             	mov    %eax,(%esp)
  10229e:	e8 49 fc ff ff       	call   101eec <putint>
			break;
  1022a3:	eb 3b                	jmp    1022e0 <vprintfmt+0x38c>
		    }
#endif	// ! PIOS_KERNEL

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  1022a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1022a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1022ac:	89 1c 24             	mov    %ebx,(%esp)
  1022af:	8b 45 08             	mov    0x8(%ebp),%eax
  1022b2:	ff d0                	call   *%eax
			break;
  1022b4:	eb 2a                	jmp    1022e0 <vprintfmt+0x38c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  1022b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1022b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1022bd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  1022c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1022c7:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  1022c9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1022cd:	eb 04                	jmp    1022d3 <vprintfmt+0x37f>
  1022cf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1022d3:	8b 45 10             	mov    0x10(%ebp),%eax
  1022d6:	83 e8 01             	sub    $0x1,%eax
  1022d9:	0f b6 00             	movzbl (%eax),%eax
  1022dc:	3c 25                	cmp    $0x25,%al
  1022de:	75 ef                	jne    1022cf <vprintfmt+0x37b>
				/* do nothing */;
			break;
		}
	}
  1022e0:	90                   	nop
{
	register int ch, err;

	printstate st = { .putch = putch, .putdat = putdat };
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  1022e1:	e9 bd fc ff ff       	jmp    101fa3 <vprintfmt+0x4f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  1022e6:	83 c4 44             	add    $0x44,%esp
  1022e9:	5b                   	pop    %ebx
  1022ea:	5d                   	pop    %ebp
  1022eb:	c3                   	ret    

001022ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  1022ec:	55                   	push   %ebp
  1022ed:	89 e5                	mov    %esp,%ebp
  1022ef:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  1022f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1022f5:	8b 00                	mov    (%eax),%eax
  1022f7:	8b 55 08             	mov    0x8(%ebp),%edx
  1022fa:	89 d1                	mov    %edx,%ecx
  1022fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  1022ff:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
  102303:	8d 50 01             	lea    0x1(%eax),%edx
  102306:	8b 45 0c             	mov    0xc(%ebp),%eax
  102309:	89 10                	mov    %edx,(%eax)
	if (b->idx == CPUTS_MAX-1) {
  10230b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10230e:	8b 00                	mov    (%eax),%eax
  102310:	3d ff 00 00 00       	cmp    $0xff,%eax
  102315:	75 24                	jne    10233b <putch+0x4f>
		b->buf[b->idx] = 0;
  102317:	8b 45 0c             	mov    0xc(%ebp),%eax
  10231a:	8b 00                	mov    (%eax),%eax
  10231c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10231f:	c6 44 02 08 00       	movb   $0x0,0x8(%edx,%eax,1)
		cputs(b->buf);
  102324:	8b 45 0c             	mov    0xc(%ebp),%eax
  102327:	83 c0 08             	add    $0x8,%eax
  10232a:	89 04 24             	mov    %eax,(%esp)
  10232d:	e8 d3 df ff ff       	call   100305 <cputs>
		b->idx = 0;
  102332:	8b 45 0c             	mov    0xc(%ebp),%eax
  102335:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  10233b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10233e:	8b 40 04             	mov    0x4(%eax),%eax
  102341:	8d 50 01             	lea    0x1(%eax),%edx
  102344:	8b 45 0c             	mov    0xc(%ebp),%eax
  102347:	89 50 04             	mov    %edx,0x4(%eax)
}
  10234a:	c9                   	leave  
  10234b:	c3                   	ret    

0010234c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  10234c:	55                   	push   %ebp
  10234d:	89 e5                	mov    %esp,%ebp
  10234f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  102355:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  10235c:	00 00 00 
	b.cnt = 0;
  10235f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  102366:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  102369:	b8 ec 22 10 00       	mov    $0x1022ec,%eax
  10236e:	8b 55 0c             	mov    0xc(%ebp),%edx
  102371:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102375:	8b 55 08             	mov    0x8(%ebp),%edx
  102378:	89 54 24 08          	mov    %edx,0x8(%esp)
  10237c:	8d 95 f0 fe ff ff    	lea    -0x110(%ebp),%edx
  102382:	89 54 24 04          	mov    %edx,0x4(%esp)
  102386:	89 04 24             	mov    %eax,(%esp)
  102389:	e8 c6 fb ff ff       	call   101f54 <vprintfmt>

	b.buf[b.idx] = 0;
  10238e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  102394:	c6 84 05 f8 fe ff ff 	movb   $0x0,-0x108(%ebp,%eax,1)
  10239b:	00 
	cputs(b.buf);
  10239c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  1023a2:	83 c0 08             	add    $0x8,%eax
  1023a5:	89 04 24             	mov    %eax,(%esp)
  1023a8:	e8 58 df ff ff       	call   100305 <cputs>

	return b.cnt;
  1023ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  1023b3:	c9                   	leave  
  1023b4:	c3                   	ret    

001023b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  1023b5:	55                   	push   %ebp
  1023b6:	89 e5                	mov    %esp,%ebp
  1023b8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  1023bb:	8d 45 08             	lea    0x8(%ebp),%eax
  1023be:	83 c0 04             	add    $0x4,%eax
  1023c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  1023c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1023c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1023ca:	89 54 24 04          	mov    %edx,0x4(%esp)
  1023ce:	89 04 24             	mov    %eax,(%esp)
  1023d1:	e8 76 ff ff ff       	call   10234c <vcprintf>
  1023d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  1023d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1023dc:	c9                   	leave  
  1023dd:	c3                   	ret    
  1023de:	90                   	nop
  1023df:	90                   	nop

001023e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  1023e0:	55                   	push   %ebp
  1023e1:	89 e5                	mov    %esp,%ebp
  1023e3:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  1023e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1023ed:	eb 08                	jmp    1023f7 <strlen+0x17>
		n++;
  1023ef:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  1023f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1023f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1023fa:	0f b6 00             	movzbl (%eax),%eax
  1023fd:	84 c0                	test   %al,%al
  1023ff:	75 ee                	jne    1023ef <strlen+0xf>
		n++;
	return n;
  102401:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102404:	c9                   	leave  
  102405:	c3                   	ret    

00102406 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  102406:	55                   	push   %ebp
  102407:	89 e5                	mov    %esp,%ebp
  102409:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  10240c:	8b 45 08             	mov    0x8(%ebp),%eax
  10240f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  102412:	8b 45 0c             	mov    0xc(%ebp),%eax
  102415:	0f b6 10             	movzbl (%eax),%edx
  102418:	8b 45 08             	mov    0x8(%ebp),%eax
  10241b:	88 10                	mov    %dl,(%eax)
  10241d:	8b 45 08             	mov    0x8(%ebp),%eax
  102420:	0f b6 00             	movzbl (%eax),%eax
  102423:	84 c0                	test   %al,%al
  102425:	0f 95 c0             	setne  %al
  102428:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10242c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  102430:	84 c0                	test   %al,%al
  102432:	75 de                	jne    102412 <strcpy+0xc>
		/* do nothing */;
	return ret;
  102434:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102437:	c9                   	leave  
  102438:	c3                   	ret    

00102439 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  102439:	55                   	push   %ebp
  10243a:	89 e5                	mov    %esp,%ebp
  10243c:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  10243f:	8b 45 08             	mov    0x8(%ebp),%eax
  102442:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (i = 0; i < size; i++) {
  102445:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  10244c:	eb 21                	jmp    10246f <strncpy+0x36>
		*dst++ = *src;
  10244e:	8b 45 0c             	mov    0xc(%ebp),%eax
  102451:	0f b6 10             	movzbl (%eax),%edx
  102454:	8b 45 08             	mov    0x8(%ebp),%eax
  102457:	88 10                	mov    %dl,(%eax)
  102459:	83 45 08 01          	addl   $0x1,0x8(%ebp)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  10245d:	8b 45 0c             	mov    0xc(%ebp),%eax
  102460:	0f b6 00             	movzbl (%eax),%eax
  102463:	84 c0                	test   %al,%al
  102465:	74 04                	je     10246b <strncpy+0x32>
			src++;
  102467:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
{
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  10246b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  10246f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102472:	3b 45 10             	cmp    0x10(%ebp),%eax
  102475:	72 d7                	jb     10244e <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  102477:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10247a:	c9                   	leave  
  10247b:	c3                   	ret    

0010247c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  10247c:	55                   	push   %ebp
  10247d:	89 e5                	mov    %esp,%ebp
  10247f:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  102482:	8b 45 08             	mov    0x8(%ebp),%eax
  102485:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  102488:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10248c:	74 2f                	je     1024bd <strlcpy+0x41>
		while (--size > 0 && *src != '\0')
  10248e:	eb 13                	jmp    1024a3 <strlcpy+0x27>
			*dst++ = *src++;
  102490:	8b 45 0c             	mov    0xc(%ebp),%eax
  102493:	0f b6 10             	movzbl (%eax),%edx
  102496:	8b 45 08             	mov    0x8(%ebp),%eax
  102499:	88 10                	mov    %dl,(%eax)
  10249b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10249f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  1024a3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1024a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1024ab:	74 0a                	je     1024b7 <strlcpy+0x3b>
  1024ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  1024b0:	0f b6 00             	movzbl (%eax),%eax
  1024b3:	84 c0                	test   %al,%al
  1024b5:	75 d9                	jne    102490 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  1024b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1024ba:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  1024bd:	8b 55 08             	mov    0x8(%ebp),%edx
  1024c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1024c3:	89 d1                	mov    %edx,%ecx
  1024c5:	29 c1                	sub    %eax,%ecx
  1024c7:	89 c8                	mov    %ecx,%eax
}
  1024c9:	c9                   	leave  
  1024ca:	c3                   	ret    

001024cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  1024cb:	55                   	push   %ebp
  1024cc:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  1024ce:	eb 08                	jmp    1024d8 <strcmp+0xd>
		p++, q++;
  1024d0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1024d4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  1024d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1024db:	0f b6 00             	movzbl (%eax),%eax
  1024de:	84 c0                	test   %al,%al
  1024e0:	74 10                	je     1024f2 <strcmp+0x27>
  1024e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1024e5:	0f b6 10             	movzbl (%eax),%edx
  1024e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1024eb:	0f b6 00             	movzbl (%eax),%eax
  1024ee:	38 c2                	cmp    %al,%dl
  1024f0:	74 de                	je     1024d0 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  1024f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1024f5:	0f b6 00             	movzbl (%eax),%eax
  1024f8:	0f b6 d0             	movzbl %al,%edx
  1024fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1024fe:	0f b6 00             	movzbl (%eax),%eax
  102501:	0f b6 c0             	movzbl %al,%eax
  102504:	89 d1                	mov    %edx,%ecx
  102506:	29 c1                	sub    %eax,%ecx
  102508:	89 c8                	mov    %ecx,%eax
}
  10250a:	5d                   	pop    %ebp
  10250b:	c3                   	ret    

0010250c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  10250c:	55                   	push   %ebp
  10250d:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  10250f:	eb 0c                	jmp    10251d <strncmp+0x11>
		n--, p++, q++;
  102511:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  102515:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102519:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  10251d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102521:	74 1a                	je     10253d <strncmp+0x31>
  102523:	8b 45 08             	mov    0x8(%ebp),%eax
  102526:	0f b6 00             	movzbl (%eax),%eax
  102529:	84 c0                	test   %al,%al
  10252b:	74 10                	je     10253d <strncmp+0x31>
  10252d:	8b 45 08             	mov    0x8(%ebp),%eax
  102530:	0f b6 10             	movzbl (%eax),%edx
  102533:	8b 45 0c             	mov    0xc(%ebp),%eax
  102536:	0f b6 00             	movzbl (%eax),%eax
  102539:	38 c2                	cmp    %al,%dl
  10253b:	74 d4                	je     102511 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  10253d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102541:	75 07                	jne    10254a <strncmp+0x3e>
		return 0;
  102543:	b8 00 00 00 00       	mov    $0x0,%eax
  102548:	eb 18                	jmp    102562 <strncmp+0x56>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  10254a:	8b 45 08             	mov    0x8(%ebp),%eax
  10254d:	0f b6 00             	movzbl (%eax),%eax
  102550:	0f b6 d0             	movzbl %al,%edx
  102553:	8b 45 0c             	mov    0xc(%ebp),%eax
  102556:	0f b6 00             	movzbl (%eax),%eax
  102559:	0f b6 c0             	movzbl %al,%eax
  10255c:	89 d1                	mov    %edx,%ecx
  10255e:	29 c1                	sub    %eax,%ecx
  102560:	89 c8                	mov    %ecx,%eax
}
  102562:	5d                   	pop    %ebp
  102563:	c3                   	ret    

00102564 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  102564:	55                   	push   %ebp
  102565:	89 e5                	mov    %esp,%ebp
  102567:	83 ec 04             	sub    $0x4,%esp
  10256a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10256d:	88 45 fc             	mov    %al,-0x4(%ebp)
	while (*s != c)
  102570:	eb 1a                	jmp    10258c <strchr+0x28>
		if (*s++ == 0)
  102572:	8b 45 08             	mov    0x8(%ebp),%eax
  102575:	0f b6 00             	movzbl (%eax),%eax
  102578:	84 c0                	test   %al,%al
  10257a:	0f 94 c0             	sete   %al
  10257d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102581:	84 c0                	test   %al,%al
  102583:	74 07                	je     10258c <strchr+0x28>
			return NULL;
  102585:	b8 00 00 00 00       	mov    $0x0,%eax
  10258a:	eb 0e                	jmp    10259a <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	while (*s != c)
  10258c:	8b 45 08             	mov    0x8(%ebp),%eax
  10258f:	0f b6 00             	movzbl (%eax),%eax
  102592:	3a 45 fc             	cmp    -0x4(%ebp),%al
  102595:	75 db                	jne    102572 <strchr+0xe>
		if (*s++ == 0)
			return NULL;
	return (char *) s;
  102597:	8b 45 08             	mov    0x8(%ebp),%eax
}
  10259a:	c9                   	leave  
  10259b:	c3                   	ret    

0010259c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  10259c:	55                   	push   %ebp
  10259d:	89 e5                	mov    %esp,%ebp
  10259f:	57                   	push   %edi
  1025a0:	83 ec 10             	sub    $0x10,%esp
	char *p;

	if (n == 0)
  1025a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1025a7:	75 05                	jne    1025ae <memset+0x12>
		return v;
  1025a9:	8b 45 08             	mov    0x8(%ebp),%eax
  1025ac:	eb 5c                	jmp    10260a <memset+0x6e>
	if ((int)v%4 == 0 && n%4 == 0) {
  1025ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1025b1:	83 e0 03             	and    $0x3,%eax
  1025b4:	85 c0                	test   %eax,%eax
  1025b6:	75 41                	jne    1025f9 <memset+0x5d>
  1025b8:	8b 45 10             	mov    0x10(%ebp),%eax
  1025bb:	83 e0 03             	and    $0x3,%eax
  1025be:	85 c0                	test   %eax,%eax
  1025c0:	75 37                	jne    1025f9 <memset+0x5d>
		c &= 0xFF;
  1025c2:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  1025c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1025cc:	89 c2                	mov    %eax,%edx
  1025ce:	c1 e2 18             	shl    $0x18,%edx
  1025d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1025d4:	c1 e0 10             	shl    $0x10,%eax
  1025d7:	09 c2                	or     %eax,%edx
  1025d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1025dc:	c1 e0 08             	shl    $0x8,%eax
  1025df:	09 d0                	or     %edx,%eax
  1025e1:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  1025e4:	8b 45 10             	mov    0x10(%ebp),%eax
  1025e7:	89 c1                	mov    %eax,%ecx
  1025e9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  1025ec:	8b 55 08             	mov    0x8(%ebp),%edx
  1025ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1025f2:	89 d7                	mov    %edx,%edi
  1025f4:	fc                   	cld    
  1025f5:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  1025f7:	eb 0e                	jmp    102607 <memset+0x6b>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  1025f9:	8b 55 08             	mov    0x8(%ebp),%edx
  1025fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1025ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
  102602:	89 d7                	mov    %edx,%edi
  102604:	fc                   	cld    
  102605:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  102607:	8b 45 08             	mov    0x8(%ebp),%eax
}
  10260a:	83 c4 10             	add    $0x10,%esp
  10260d:	5f                   	pop    %edi
  10260e:	5d                   	pop    %ebp
  10260f:	c3                   	ret    

00102610 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  102610:	55                   	push   %ebp
  102611:	89 e5                	mov    %esp,%ebp
  102613:	57                   	push   %edi
  102614:	56                   	push   %esi
  102615:	53                   	push   %ebx
  102616:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;
	
	s = src;
  102619:	8b 45 0c             	mov    0xc(%ebp),%eax
  10261c:	89 45 ec             	mov    %eax,-0x14(%ebp)
	d = dst;
  10261f:	8b 45 08             	mov    0x8(%ebp),%eax
  102622:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (s < d && s + n > d) {
  102625:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102628:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  10262b:	73 6e                	jae    10269b <memmove+0x8b>
  10262d:	8b 45 10             	mov    0x10(%ebp),%eax
  102630:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102633:	8d 04 02             	lea    (%edx,%eax,1),%eax
  102636:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102639:	76 60                	jbe    10269b <memmove+0x8b>
		s += n;
  10263b:	8b 45 10             	mov    0x10(%ebp),%eax
  10263e:	01 45 ec             	add    %eax,-0x14(%ebp)
		d += n;
  102641:	8b 45 10             	mov    0x10(%ebp),%eax
  102644:	01 45 f0             	add    %eax,-0x10(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  102647:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10264a:	83 e0 03             	and    $0x3,%eax
  10264d:	85 c0                	test   %eax,%eax
  10264f:	75 2f                	jne    102680 <memmove+0x70>
  102651:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102654:	83 e0 03             	and    $0x3,%eax
  102657:	85 c0                	test   %eax,%eax
  102659:	75 25                	jne    102680 <memmove+0x70>
  10265b:	8b 45 10             	mov    0x10(%ebp),%eax
  10265e:	83 e0 03             	and    $0x3,%eax
  102661:	85 c0                	test   %eax,%eax
  102663:	75 1b                	jne    102680 <memmove+0x70>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  102665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102668:	83 e8 04             	sub    $0x4,%eax
  10266b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10266e:	83 ea 04             	sub    $0x4,%edx
  102671:	8b 4d 10             	mov    0x10(%ebp),%ecx
  102674:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  102677:	89 c7                	mov    %eax,%edi
  102679:	89 d6                	mov    %edx,%esi
  10267b:	fd                   	std    
  10267c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  10267e:	eb 18                	jmp    102698 <memmove+0x88>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  102680:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102683:	8d 50 ff             	lea    -0x1(%eax),%edx
  102686:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102689:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  10268c:	8b 45 10             	mov    0x10(%ebp),%eax
  10268f:	89 d7                	mov    %edx,%edi
  102691:	89 de                	mov    %ebx,%esi
  102693:	89 c1                	mov    %eax,%ecx
  102695:	fd                   	std    
  102696:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  102698:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  102699:	eb 45                	jmp    1026e0 <memmove+0xd0>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  10269b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10269e:	83 e0 03             	and    $0x3,%eax
  1026a1:	85 c0                	test   %eax,%eax
  1026a3:	75 2b                	jne    1026d0 <memmove+0xc0>
  1026a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1026a8:	83 e0 03             	and    $0x3,%eax
  1026ab:	85 c0                	test   %eax,%eax
  1026ad:	75 21                	jne    1026d0 <memmove+0xc0>
  1026af:	8b 45 10             	mov    0x10(%ebp),%eax
  1026b2:	83 e0 03             	and    $0x3,%eax
  1026b5:	85 c0                	test   %eax,%eax
  1026b7:	75 17                	jne    1026d0 <memmove+0xc0>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  1026b9:	8b 45 10             	mov    0x10(%ebp),%eax
  1026bc:	89 c1                	mov    %eax,%ecx
  1026be:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  1026c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1026c4:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1026c7:	89 c7                	mov    %eax,%edi
  1026c9:	89 d6                	mov    %edx,%esi
  1026cb:	fc                   	cld    
  1026cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  1026ce:	eb 10                	jmp    1026e0 <memmove+0xd0>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  1026d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1026d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1026d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  1026d9:	89 c7                	mov    %eax,%edi
  1026db:	89 d6                	mov    %edx,%esi
  1026dd:	fc                   	cld    
  1026de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  1026e0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1026e3:	83 c4 10             	add    $0x10,%esp
  1026e6:	5b                   	pop    %ebx
  1026e7:	5e                   	pop    %esi
  1026e8:	5f                   	pop    %edi
  1026e9:	5d                   	pop    %ebp
  1026ea:	c3                   	ret    

001026eb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  1026eb:	55                   	push   %ebp
  1026ec:	89 e5                	mov    %esp,%ebp
  1026ee:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  1026f1:	8b 45 10             	mov    0x10(%ebp),%eax
  1026f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1026f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1026fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1026ff:	8b 45 08             	mov    0x8(%ebp),%eax
  102702:	89 04 24             	mov    %eax,(%esp)
  102705:	e8 06 ff ff ff       	call   102610 <memmove>
}
  10270a:	c9                   	leave  
  10270b:	c3                   	ret    

0010270c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  10270c:	55                   	push   %ebp
  10270d:	89 e5                	mov    %esp,%ebp
  10270f:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  102712:	8b 45 08             	mov    0x8(%ebp),%eax
  102715:	89 45 f8             	mov    %eax,-0x8(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  102718:	8b 45 0c             	mov    0xc(%ebp),%eax
  10271b:	89 45 fc             	mov    %eax,-0x4(%ebp)

	while (n-- > 0) {
  10271e:	eb 32                	jmp    102752 <memcmp+0x46>
		if (*s1 != *s2)
  102720:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102723:	0f b6 10             	movzbl (%eax),%edx
  102726:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102729:	0f b6 00             	movzbl (%eax),%eax
  10272c:	38 c2                	cmp    %al,%dl
  10272e:	74 1a                	je     10274a <memcmp+0x3e>
			return (int) *s1 - (int) *s2;
  102730:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102733:	0f b6 00             	movzbl (%eax),%eax
  102736:	0f b6 d0             	movzbl %al,%edx
  102739:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10273c:	0f b6 00             	movzbl (%eax),%eax
  10273f:	0f b6 c0             	movzbl %al,%eax
  102742:	89 d1                	mov    %edx,%ecx
  102744:	29 c1                	sub    %eax,%ecx
  102746:	89 c8                	mov    %ecx,%eax
  102748:	eb 1c                	jmp    102766 <memcmp+0x5a>
		s1++, s2++;
  10274a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  10274e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  102752:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102756:	0f 95 c0             	setne  %al
  102759:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10275d:	84 c0                	test   %al,%al
  10275f:	75 bf                	jne    102720 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  102761:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102766:	c9                   	leave  
  102767:	c3                   	ret    

00102768 <memchr>:

void *
memchr(const void *s, int c, size_t n)
{
  102768:	55                   	push   %ebp
  102769:	89 e5                	mov    %esp,%ebp
  10276b:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  10276e:	8b 45 10             	mov    0x10(%ebp),%eax
  102771:	8b 55 08             	mov    0x8(%ebp),%edx
  102774:	8d 04 02             	lea    (%edx,%eax,1),%eax
  102777:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  10277a:	eb 16                	jmp    102792 <memchr+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  10277c:	8b 45 08             	mov    0x8(%ebp),%eax
  10277f:	0f b6 10             	movzbl (%eax),%edx
  102782:	8b 45 0c             	mov    0xc(%ebp),%eax
  102785:	38 c2                	cmp    %al,%dl
  102787:	75 05                	jne    10278e <memchr+0x26>
			return (void *) s;
  102789:	8b 45 08             	mov    0x8(%ebp),%eax
  10278c:	eb 11                	jmp    10279f <memchr+0x37>

void *
memchr(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  10278e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102792:	8b 45 08             	mov    0x8(%ebp),%eax
  102795:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  102798:	72 e2                	jb     10277c <memchr+0x14>
		if (*(const unsigned char *) s == (unsigned char) c)
			return (void *) s;
	return NULL;
  10279a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10279f:	c9                   	leave  
  1027a0:	c3                   	ret    
  1027a1:	90                   	nop
  1027a2:	90                   	nop
  1027a3:	90                   	nop
  1027a4:	90                   	nop
  1027a5:	90                   	nop
  1027a6:	90                   	nop
  1027a7:	90                   	nop
  1027a8:	90                   	nop
  1027a9:	90                   	nop
  1027aa:	90                   	nop
  1027ab:	90                   	nop
  1027ac:	90                   	nop
  1027ad:	90                   	nop
  1027ae:	90                   	nop
  1027af:	90                   	nop

001027b0 <__udivdi3>:
  1027b0:	55                   	push   %ebp
  1027b1:	89 e5                	mov    %esp,%ebp
  1027b3:	57                   	push   %edi
  1027b4:	56                   	push   %esi
  1027b5:	83 ec 10             	sub    $0x10,%esp
  1027b8:	8b 45 14             	mov    0x14(%ebp),%eax
  1027bb:	8b 55 08             	mov    0x8(%ebp),%edx
  1027be:	8b 75 10             	mov    0x10(%ebp),%esi
  1027c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  1027c4:	85 c0                	test   %eax,%eax
  1027c6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  1027c9:	75 35                	jne    102800 <__udivdi3+0x50>
  1027cb:	39 fe                	cmp    %edi,%esi
  1027cd:	77 61                	ja     102830 <__udivdi3+0x80>
  1027cf:	85 f6                	test   %esi,%esi
  1027d1:	75 0b                	jne    1027de <__udivdi3+0x2e>
  1027d3:	b8 01 00 00 00       	mov    $0x1,%eax
  1027d8:	31 d2                	xor    %edx,%edx
  1027da:	f7 f6                	div    %esi
  1027dc:	89 c6                	mov    %eax,%esi
  1027de:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1027e1:	31 d2                	xor    %edx,%edx
  1027e3:	89 f8                	mov    %edi,%eax
  1027e5:	f7 f6                	div    %esi
  1027e7:	89 c7                	mov    %eax,%edi
  1027e9:	89 c8                	mov    %ecx,%eax
  1027eb:	f7 f6                	div    %esi
  1027ed:	89 c1                	mov    %eax,%ecx
  1027ef:	89 fa                	mov    %edi,%edx
  1027f1:	89 c8                	mov    %ecx,%eax
  1027f3:	83 c4 10             	add    $0x10,%esp
  1027f6:	5e                   	pop    %esi
  1027f7:	5f                   	pop    %edi
  1027f8:	5d                   	pop    %ebp
  1027f9:	c3                   	ret    
  1027fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  102800:	39 f8                	cmp    %edi,%eax
  102802:	77 1c                	ja     102820 <__udivdi3+0x70>
  102804:	0f bd d0             	bsr    %eax,%edx
  102807:	83 f2 1f             	xor    $0x1f,%edx
  10280a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10280d:	75 39                	jne    102848 <__udivdi3+0x98>
  10280f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  102812:	0f 86 a0 00 00 00    	jbe    1028b8 <__udivdi3+0x108>
  102818:	39 f8                	cmp    %edi,%eax
  10281a:	0f 82 98 00 00 00    	jb     1028b8 <__udivdi3+0x108>
  102820:	31 ff                	xor    %edi,%edi
  102822:	31 c9                	xor    %ecx,%ecx
  102824:	89 c8                	mov    %ecx,%eax
  102826:	89 fa                	mov    %edi,%edx
  102828:	83 c4 10             	add    $0x10,%esp
  10282b:	5e                   	pop    %esi
  10282c:	5f                   	pop    %edi
  10282d:	5d                   	pop    %ebp
  10282e:	c3                   	ret    
  10282f:	90                   	nop
  102830:	89 d1                	mov    %edx,%ecx
  102832:	89 fa                	mov    %edi,%edx
  102834:	89 c8                	mov    %ecx,%eax
  102836:	31 ff                	xor    %edi,%edi
  102838:	f7 f6                	div    %esi
  10283a:	89 c1                	mov    %eax,%ecx
  10283c:	89 fa                	mov    %edi,%edx
  10283e:	89 c8                	mov    %ecx,%eax
  102840:	83 c4 10             	add    $0x10,%esp
  102843:	5e                   	pop    %esi
  102844:	5f                   	pop    %edi
  102845:	5d                   	pop    %ebp
  102846:	c3                   	ret    
  102847:	90                   	nop
  102848:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  10284c:	89 f2                	mov    %esi,%edx
  10284e:	d3 e0                	shl    %cl,%eax
  102850:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102853:	b8 20 00 00 00       	mov    $0x20,%eax
  102858:	2b 45 f4             	sub    -0xc(%ebp),%eax
  10285b:	89 c1                	mov    %eax,%ecx
  10285d:	d3 ea                	shr    %cl,%edx
  10285f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  102863:	0b 55 ec             	or     -0x14(%ebp),%edx
  102866:	d3 e6                	shl    %cl,%esi
  102868:	89 c1                	mov    %eax,%ecx
  10286a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  10286d:	89 fe                	mov    %edi,%esi
  10286f:	d3 ee                	shr    %cl,%esi
  102871:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  102875:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102878:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10287b:	d3 e7                	shl    %cl,%edi
  10287d:	89 c1                	mov    %eax,%ecx
  10287f:	d3 ea                	shr    %cl,%edx
  102881:	09 d7                	or     %edx,%edi
  102883:	89 f2                	mov    %esi,%edx
  102885:	89 f8                	mov    %edi,%eax
  102887:	f7 75 ec             	divl   -0x14(%ebp)
  10288a:	89 d6                	mov    %edx,%esi
  10288c:	89 c7                	mov    %eax,%edi
  10288e:	f7 65 e8             	mull   -0x18(%ebp)
  102891:	39 d6                	cmp    %edx,%esi
  102893:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102896:	72 30                	jb     1028c8 <__udivdi3+0x118>
  102898:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10289b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  10289f:	d3 e2                	shl    %cl,%edx
  1028a1:	39 c2                	cmp    %eax,%edx
  1028a3:	73 05                	jae    1028aa <__udivdi3+0xfa>
  1028a5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  1028a8:	74 1e                	je     1028c8 <__udivdi3+0x118>
  1028aa:	89 f9                	mov    %edi,%ecx
  1028ac:	31 ff                	xor    %edi,%edi
  1028ae:	e9 71 ff ff ff       	jmp    102824 <__udivdi3+0x74>
  1028b3:	90                   	nop
  1028b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1028b8:	31 ff                	xor    %edi,%edi
  1028ba:	b9 01 00 00 00       	mov    $0x1,%ecx
  1028bf:	e9 60 ff ff ff       	jmp    102824 <__udivdi3+0x74>
  1028c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1028c8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  1028cb:	31 ff                	xor    %edi,%edi
  1028cd:	89 c8                	mov    %ecx,%eax
  1028cf:	89 fa                	mov    %edi,%edx
  1028d1:	83 c4 10             	add    $0x10,%esp
  1028d4:	5e                   	pop    %esi
  1028d5:	5f                   	pop    %edi
  1028d6:	5d                   	pop    %ebp
  1028d7:	c3                   	ret    
  1028d8:	90                   	nop
  1028d9:	90                   	nop
  1028da:	90                   	nop
  1028db:	90                   	nop
  1028dc:	90                   	nop
  1028dd:	90                   	nop
  1028de:	90                   	nop
  1028df:	90                   	nop

001028e0 <__umoddi3>:
  1028e0:	55                   	push   %ebp
  1028e1:	89 e5                	mov    %esp,%ebp
  1028e3:	57                   	push   %edi
  1028e4:	56                   	push   %esi
  1028e5:	83 ec 20             	sub    $0x20,%esp
  1028e8:	8b 55 14             	mov    0x14(%ebp),%edx
  1028eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  1028ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  1028f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  1028f4:	85 d2                	test   %edx,%edx
  1028f6:	89 c8                	mov    %ecx,%eax
  1028f8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  1028fb:	75 13                	jne    102910 <__umoddi3+0x30>
  1028fd:	39 f7                	cmp    %esi,%edi
  1028ff:	76 3f                	jbe    102940 <__umoddi3+0x60>
  102901:	89 f2                	mov    %esi,%edx
  102903:	f7 f7                	div    %edi
  102905:	89 d0                	mov    %edx,%eax
  102907:	31 d2                	xor    %edx,%edx
  102909:	83 c4 20             	add    $0x20,%esp
  10290c:	5e                   	pop    %esi
  10290d:	5f                   	pop    %edi
  10290e:	5d                   	pop    %ebp
  10290f:	c3                   	ret    
  102910:	39 f2                	cmp    %esi,%edx
  102912:	77 4c                	ja     102960 <__umoddi3+0x80>
  102914:	0f bd ca             	bsr    %edx,%ecx
  102917:	83 f1 1f             	xor    $0x1f,%ecx
  10291a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  10291d:	75 51                	jne    102970 <__umoddi3+0x90>
  10291f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  102922:	0f 87 e0 00 00 00    	ja     102a08 <__umoddi3+0x128>
  102928:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10292b:	29 f8                	sub    %edi,%eax
  10292d:	19 d6                	sbb    %edx,%esi
  10292f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102932:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102935:	89 f2                	mov    %esi,%edx
  102937:	83 c4 20             	add    $0x20,%esp
  10293a:	5e                   	pop    %esi
  10293b:	5f                   	pop    %edi
  10293c:	5d                   	pop    %ebp
  10293d:	c3                   	ret    
  10293e:	66 90                	xchg   %ax,%ax
  102940:	85 ff                	test   %edi,%edi
  102942:	75 0b                	jne    10294f <__umoddi3+0x6f>
  102944:	b8 01 00 00 00       	mov    $0x1,%eax
  102949:	31 d2                	xor    %edx,%edx
  10294b:	f7 f7                	div    %edi
  10294d:	89 c7                	mov    %eax,%edi
  10294f:	89 f0                	mov    %esi,%eax
  102951:	31 d2                	xor    %edx,%edx
  102953:	f7 f7                	div    %edi
  102955:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102958:	f7 f7                	div    %edi
  10295a:	eb a9                	jmp    102905 <__umoddi3+0x25>
  10295c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102960:	89 c8                	mov    %ecx,%eax
  102962:	89 f2                	mov    %esi,%edx
  102964:	83 c4 20             	add    $0x20,%esp
  102967:	5e                   	pop    %esi
  102968:	5f                   	pop    %edi
  102969:	5d                   	pop    %ebp
  10296a:	c3                   	ret    
  10296b:	90                   	nop
  10296c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102970:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  102974:	d3 e2                	shl    %cl,%edx
  102976:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102979:	ba 20 00 00 00       	mov    $0x20,%edx
  10297e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  102981:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102984:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  102988:	89 fa                	mov    %edi,%edx
  10298a:	d3 ea                	shr    %cl,%edx
  10298c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  102990:	0b 55 f4             	or     -0xc(%ebp),%edx
  102993:	d3 e7                	shl    %cl,%edi
  102995:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  102999:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10299c:	89 f2                	mov    %esi,%edx
  10299e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  1029a1:	89 c7                	mov    %eax,%edi
  1029a3:	d3 ea                	shr    %cl,%edx
  1029a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  1029a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1029ac:	89 c2                	mov    %eax,%edx
  1029ae:	d3 e6                	shl    %cl,%esi
  1029b0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  1029b4:	d3 ea                	shr    %cl,%edx
  1029b6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  1029ba:	09 d6                	or     %edx,%esi
  1029bc:	89 f0                	mov    %esi,%eax
  1029be:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  1029c1:	d3 e7                	shl    %cl,%edi
  1029c3:	89 f2                	mov    %esi,%edx
  1029c5:	f7 75 f4             	divl   -0xc(%ebp)
  1029c8:	89 d6                	mov    %edx,%esi
  1029ca:	f7 65 e8             	mull   -0x18(%ebp)
  1029cd:	39 d6                	cmp    %edx,%esi
  1029cf:	72 2b                	jb     1029fc <__umoddi3+0x11c>
  1029d1:	39 c7                	cmp    %eax,%edi
  1029d3:	72 23                	jb     1029f8 <__umoddi3+0x118>
  1029d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  1029d9:	29 c7                	sub    %eax,%edi
  1029db:	19 d6                	sbb    %edx,%esi
  1029dd:	89 f0                	mov    %esi,%eax
  1029df:	89 f2                	mov    %esi,%edx
  1029e1:	d3 ef                	shr    %cl,%edi
  1029e3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  1029e7:	d3 e0                	shl    %cl,%eax
  1029e9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  1029ed:	09 f8                	or     %edi,%eax
  1029ef:	d3 ea                	shr    %cl,%edx
  1029f1:	83 c4 20             	add    $0x20,%esp
  1029f4:	5e                   	pop    %esi
  1029f5:	5f                   	pop    %edi
  1029f6:	5d                   	pop    %ebp
  1029f7:	c3                   	ret    
  1029f8:	39 d6                	cmp    %edx,%esi
  1029fa:	75 d9                	jne    1029d5 <__umoddi3+0xf5>
  1029fc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  1029ff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  102a02:	eb d1                	jmp    1029d5 <__umoddi3+0xf5>
  102a04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  102a08:	39 f2                	cmp    %esi,%edx
  102a0a:	0f 82 18 ff ff ff    	jb     102928 <__umoddi3+0x48>
  102a10:	e9 1d ff ff ff       	jmp    102932 <__umoddi3+0x52>
