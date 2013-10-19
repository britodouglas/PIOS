
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
  10001a:	bc 00 70 10 00       	mov    $0x107000,%esp

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
  100052:	c7 44 24 0c e0 39 10 	movl   $0x1039e0,0xc(%esp)
  100059:	00 
  10005a:	c7 44 24 08 f6 39 10 	movl   $0x1039f6,0x8(%esp)
  100061:	00 
  100062:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  100069:	00 
  10006a:	c7 04 24 0b 3a 10 00 	movl   $0x103a0b,(%esp)
  100071:	e8 ea 02 00 00       	call   100360 <debug_panic>
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
  100086:	3d 00 60 10 00       	cmp    $0x106000,%eax
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
  100096:	83 ec 28             	sub    $0x28,%esp
	extern char start[], edata[], end[];

	// Before anything else, complete the ELF loading process.
	// Clear all uninitialized global data (BSS) in our program,
	// ensuring that all static/global variables start out zero.
	if (cpu_onboot())
  100099:	e8 dd ff ff ff       	call   10007b <cpu_onboot>
  10009e:	85 c0                	test   %eax,%eax
  1000a0:	74 28                	je     1000ca <init+0x37>
		memset(edata, 0, end - edata);
  1000a2:	ba 84 8f 10 00       	mov    $0x108f84,%edx
  1000a7:	b8 30 75 10 00       	mov    $0x107530,%eax
  1000ac:	89 d1                	mov    %edx,%ecx
  1000ae:	29 c1                	sub    %eax,%ecx
  1000b0:	89 c8                	mov    %ecx,%eax
  1000b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1000b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bd:	00 
  1000be:	c7 04 24 30 75 10 00 	movl   $0x107530,(%esp)
  1000c5:	e8 92 34 00 00       	call   10355c <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
  1000ca:	e8 1e 02 00 00       	call   1002ed <cons_init>

	// Lab 1: test cprintf and debug_trace
	cprintf("1234 decimal is %o octal!\n", 1234);
  1000cf:	c7 44 24 04 d2 04 00 	movl   $0x4d2,0x4(%esp)
  1000d6:	00 
  1000d7:	c7 04 24 18 3a 10 00 	movl   $0x103a18,(%esp)
  1000de:	e8 92 32 00 00       	call   103375 <cprintf>
	debug_check();
  1000e3:	e8 df 04 00 00       	call   1005c7 <debug_check>

	// Initialize and load the bootstrap CPU's GDT, TSS, and IDT.
	cpu_init();
  1000e8:	e8 6a 10 00 00       	call   101157 <cpu_init>
	trap_init();
  1000ed:	e8 0b 1d 00 00       	call   101dfd <trap_init>

	// Physical memory detection/initialization.
	// Can't call mem_alloc until after we do this!
	mem_init();
  1000f2:	e8 88 07 00 00       	call   10087f <mem_init>

	user_stack[sizeof(user_stack)-1] = 0;
  1000f7:	c6 05 3f 85 10 00 00 	movb   $0x0,0x10853f
	user_stack[sizeof(user_stack)-2] = 0;
  1000fe:	c6 05 3e 85 10 00 00 	movb   $0x0,0x10853e
	user_stack[sizeof(user_stack)-3] = 0;
  100105:	c6 05 3d 85 10 00 00 	movb   $0x0,0x10853d
	user_stack[sizeof(user_stack)-4] = 0;
  10010c:	c6 05 3c 85 10 00 00 	movb   $0x0,0x10853c
	asm volatile("pushl %0" : : "i" (CPU_GDT_UDATA | 0x3));
  100113:	6a 23                	push   $0x23
	asm volatile("pushl %0" : : "i" (user_stack + sizeof(user_stack) - 4));
  100115:	68 3c 85 10 00       	push   $0x10853c
	uint32_t eflags = (FL_IOPL_MASK & FL_IOPL_3);
  10011a:	c7 45 f4 00 30 00 00 	movl   $0x3000,-0xc(%ebp)
	// eflags = 0;
	asm volatile("pushl %0" : : "a" (eflags));
  100121:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100124:	50                   	push   %eax
	asm volatile("pushl %0" : : "i" (CPU_GDT_UCODE | 0x3));
  100125:	6a 1b                	push   $0x1b
	asm volatile("pushl $user");
  100127:	68 2f 01 10 00       	push   $0x10012f
	asm volatile("iret");
  10012c:	cf                   	iret   
}
  10012d:	c9                   	leave  
  10012e:	c3                   	ret    

0010012f <user>:
// This is the first function that gets run in user mode (ring 3).
// It acts as PIOS's "root process",
// of which all other processes are descendants.
void
user()
{
  10012f:	55                   	push   %ebp
  100130:	89 e5                	mov    %esp,%ebp
  100132:	83 ec 28             	sub    $0x28,%esp
	assert(0 == 0);
	cprintf("in user()\n");
  100135:	c7 04 24 33 3a 10 00 	movl   $0x103a33,(%esp)
  10013c:	e8 34 32 00 00       	call   103375 <cprintf>

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  100141:	89 65 f0             	mov    %esp,-0x10(%ebp)
        return esp;
  100144:	8b 45 f0             	mov    -0x10(%ebp),%eax
	assert(read_esp() > (uint32_t) &user_stack[0]);
  100147:	89 c2                	mov    %eax,%edx
  100149:	b8 40 75 10 00       	mov    $0x107540,%eax
  10014e:	39 c2                	cmp    %eax,%edx
  100150:	77 24                	ja     100176 <user+0x47>
  100152:	c7 44 24 0c 40 3a 10 	movl   $0x103a40,0xc(%esp)
  100159:	00 
  10015a:	c7 44 24 08 f6 39 10 	movl   $0x1039f6,0x8(%esp)
  100161:	00 
  100162:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  100169:	00 
  10016a:	c7 04 24 67 3a 10 00 	movl   $0x103a67,(%esp)
  100171:	e8 ea 01 00 00       	call   100360 <debug_panic>

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  100176:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  100179:	8b 45 f4             	mov    -0xc(%ebp),%eax
	assert(read_esp() < (uint32_t) &user_stack[sizeof(user_stack)]);
  10017c:	89 c2                	mov    %eax,%edx
  10017e:	b8 40 85 10 00       	mov    $0x108540,%eax
  100183:	39 c2                	cmp    %eax,%edx
  100185:	72 24                	jb     1001ab <user+0x7c>
  100187:	c7 44 24 0c 74 3a 10 	movl   $0x103a74,0xc(%esp)
  10018e:	00 
  10018f:	c7 44 24 08 f6 39 10 	movl   $0x1039f6,0x8(%esp)
  100196:	00 
  100197:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  10019e:	00 
  10019f:	c7 04 24 67 3a 10 00 	movl   $0x103a67,(%esp)
  1001a6:	e8 b5 01 00 00       	call   100360 <debug_panic>

	// Check that we're in user mode and can handle traps from there.
	trap_check_user();
  1001ab:	e8 7e 1f 00 00       	call   10212e <trap_check_user>

	done();
  1001b0:	e8 00 00 00 00       	call   1001b5 <done>

001001b5 <done>:
// it just puts the processor into an infinite loop.
// We make this a function so that we can set a breakpoints on it.
// Our grade scripts use this breakpoint to know when to stop QEMU.
void gcc_noreturn
done()
{
  1001b5:	55                   	push   %ebp
  1001b6:	89 e5                	mov    %esp,%ebp
	while (1)
		;	// just spin
  1001b8:	eb fe                	jmp    1001b8 <done+0x3>
  1001ba:	90                   	nop
  1001bb:	90                   	nop

001001bc <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  1001bc:	55                   	push   %ebp
  1001bd:	89 e5                	mov    %esp,%ebp
  1001bf:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  1001c2:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  1001c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  1001c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1001cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1001ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1001d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  1001d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1001d9:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  1001df:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  1001e4:	74 24                	je     10020a <cpu_cur+0x4e>
  1001e6:	c7 44 24 0c ac 3a 10 	movl   $0x103aac,0xc(%esp)
  1001ed:	00 
  1001ee:	c7 44 24 08 c2 3a 10 	movl   $0x103ac2,0x8(%esp)
  1001f5:	00 
  1001f6:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  1001fd:	00 
  1001fe:	c7 04 24 d7 3a 10 00 	movl   $0x103ad7,(%esp)
  100205:	e8 56 01 00 00       	call   100360 <debug_panic>
	return c;
  10020a:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  10020d:	c9                   	leave  
  10020e:	c3                   	ret    

0010020f <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  10020f:	55                   	push   %ebp
  100210:	89 e5                	mov    %esp,%ebp
  100212:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  100215:	e8 a2 ff ff ff       	call   1001bc <cpu_cur>
  10021a:	3d 00 60 10 00       	cmp    $0x106000,%eax
  10021f:	0f 94 c0             	sete   %al
  100222:	0f b6 c0             	movzbl %al,%eax
}
  100225:	c9                   	leave  
  100226:	c3                   	ret    

00100227 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
  100227:	55                   	push   %ebp
  100228:	89 e5                	mov    %esp,%ebp
  10022a:	83 ec 18             	sub    $0x18,%esp
	int c;

	while ((c = (*proc)()) != -1) {
  10022d:	eb 35                	jmp    100264 <cons_intr+0x3d>
		if (c == 0)
  10022f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100233:	74 2e                	je     100263 <cons_intr+0x3c>
			continue;
		cons.buf[cons.wpos++] = c;
  100235:	a1 44 87 10 00       	mov    0x108744,%eax
  10023a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10023d:	88 90 40 85 10 00    	mov    %dl,0x108540(%eax)
  100243:	83 c0 01             	add    $0x1,%eax
  100246:	a3 44 87 10 00       	mov    %eax,0x108744
		if (cons.wpos == CONSBUFSIZE)
  10024b:	a1 44 87 10 00       	mov    0x108744,%eax
  100250:	3d 00 02 00 00       	cmp    $0x200,%eax
  100255:	75 0d                	jne    100264 <cons_intr+0x3d>
			cons.wpos = 0;
  100257:	c7 05 44 87 10 00 00 	movl   $0x0,0x108744
  10025e:	00 00 00 
  100261:	eb 01                	jmp    100264 <cons_intr+0x3d>
{
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
  100263:	90                   	nop
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
  100264:	8b 45 08             	mov    0x8(%ebp),%eax
  100267:	ff d0                	call   *%eax
  100269:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10026c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  100270:	75 bd                	jne    10022f <cons_intr+0x8>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
  100272:	c9                   	leave  
  100273:	c3                   	ret    

00100274 <cons_getc>:

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
  100274:	55                   	push   %ebp
  100275:	89 e5                	mov    %esp,%ebp
  100277:	83 ec 18             	sub    $0x18,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
  10027a:	e8 89 27 00 00       	call   102a08 <serial_intr>
	kbd_intr();
  10027f:	e8 de 26 00 00       	call   102962 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
  100284:	8b 15 40 87 10 00    	mov    0x108740,%edx
  10028a:	a1 44 87 10 00       	mov    0x108744,%eax
  10028f:	39 c2                	cmp    %eax,%edx
  100291:	74 35                	je     1002c8 <cons_getc+0x54>
		c = cons.buf[cons.rpos++];
  100293:	a1 40 87 10 00       	mov    0x108740,%eax
  100298:	0f b6 90 40 85 10 00 	movzbl 0x108540(%eax),%edx
  10029f:	0f b6 d2             	movzbl %dl,%edx
  1002a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1002a5:	83 c0 01             	add    $0x1,%eax
  1002a8:	a3 40 87 10 00       	mov    %eax,0x108740
		if (cons.rpos == CONSBUFSIZE)
  1002ad:	a1 40 87 10 00       	mov    0x108740,%eax
  1002b2:	3d 00 02 00 00       	cmp    $0x200,%eax
  1002b7:	75 0a                	jne    1002c3 <cons_getc+0x4f>
			cons.rpos = 0;
  1002b9:	c7 05 40 87 10 00 00 	movl   $0x0,0x108740
  1002c0:	00 00 00 
		return c;
  1002c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002c6:	eb 05                	jmp    1002cd <cons_getc+0x59>
	}
	return 0;
  1002c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1002cd:	c9                   	leave  
  1002ce:	c3                   	ret    

001002cf <cons_putc>:

// output a character to the console
static void
cons_putc(int c)
{
  1002cf:	55                   	push   %ebp
  1002d0:	89 e5                	mov    %esp,%ebp
  1002d2:	83 ec 18             	sub    $0x18,%esp
	serial_putc(c);
  1002d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1002d8:	89 04 24             	mov    %eax,(%esp)
  1002db:	e8 45 27 00 00       	call   102a25 <serial_putc>
	video_putc(c);
  1002e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1002e3:	89 04 24             	mov    %eax,(%esp)
  1002e6:	e8 d5 22 00 00       	call   1025c0 <video_putc>
}
  1002eb:	c9                   	leave  
  1002ec:	c3                   	ret    

001002ed <cons_init>:

// initialize the console devices
void
cons_init(void)
{
  1002ed:	55                   	push   %ebp
  1002ee:	89 e5                	mov    %esp,%ebp
  1002f0:	83 ec 18             	sub    $0x18,%esp
	if (!cpu_onboot())	// only do once, on the boot CPU
  1002f3:	e8 17 ff ff ff       	call   10020f <cpu_onboot>
  1002f8:	85 c0                	test   %eax,%eax
  1002fa:	74 36                	je     100332 <cons_init+0x45>
		return;

	video_init();
  1002fc:	e8 f3 21 00 00       	call   1024f4 <video_init>
	kbd_init();
  100301:	e8 70 26 00 00       	call   102976 <kbd_init>
	serial_init();
  100306:	e8 7f 27 00 00       	call   102a8a <serial_init>

	if (!serial_exists)
  10030b:	a1 80 8f 10 00       	mov    0x108f80,%eax
  100310:	85 c0                	test   %eax,%eax
  100312:	75 1f                	jne    100333 <cons_init+0x46>
		warn("Serial port does not exist!\n");
  100314:	c7 44 24 08 e4 3a 10 	movl   $0x103ae4,0x8(%esp)
  10031b:	00 
  10031c:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
  100323:	00 
  100324:	c7 04 24 01 3b 10 00 	movl   $0x103b01,(%esp)
  10032b:	e8 ef 00 00 00       	call   10041f <debug_warn>
  100330:	eb 01                	jmp    100333 <cons_init+0x46>
// initialize the console devices
void
cons_init(void)
{
	if (!cpu_onboot())	// only do once, on the boot CPU
		return;
  100332:	90                   	nop
	kbd_init();
	serial_init();

	if (!serial_exists)
		warn("Serial port does not exist!\n");
}
  100333:	c9                   	leave  
  100334:	c3                   	ret    

00100335 <cputs>:


// `High'-level console I/O.  Used by readline and cprintf.
void
cputs(const char *str)
{
  100335:	55                   	push   %ebp
  100336:	89 e5                	mov    %esp,%ebp
  100338:	83 ec 28             	sub    $0x28,%esp
	char ch;
	while (*str)
  10033b:	eb 15                	jmp    100352 <cputs+0x1d>
		cons_putc(*str++);
  10033d:	8b 45 08             	mov    0x8(%ebp),%eax
  100340:	0f b6 00             	movzbl (%eax),%eax
  100343:	0f be c0             	movsbl %al,%eax
  100346:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10034a:	89 04 24             	mov    %eax,(%esp)
  10034d:	e8 7d ff ff ff       	call   1002cf <cons_putc>
// `High'-level console I/O.  Used by readline and cprintf.
void
cputs(const char *str)
{
	char ch;
	while (*str)
  100352:	8b 45 08             	mov    0x8(%ebp),%eax
  100355:	0f b6 00             	movzbl (%eax),%eax
  100358:	84 c0                	test   %al,%al
  10035a:	75 e1                	jne    10033d <cputs+0x8>
		cons_putc(*str++);
}
  10035c:	c9                   	leave  
  10035d:	c3                   	ret    
  10035e:	90                   	nop
  10035f:	90                   	nop

00100360 <debug_panic>:

// Panic is called on unresolvable fatal errors.
// It prints "panic: mesg", and then enters the kernel monitor.
void
debug_panic(const char *file, int line, const char *fmt,...)
{
  100360:	55                   	push   %ebp
  100361:	89 e5                	mov    %esp,%ebp
  100363:	83 ec 58             	sub    $0x58,%esp

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  100366:	8c 4d f2             	mov    %cs,-0xe(%ebp)
        return cs;
  100369:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
	va_list ap;
	int i;

	// Avoid infinite recursion if we're panicking from kernel mode.
	if ((read_cs() & 3) == 0) {
  10036d:	0f b7 c0             	movzwl %ax,%eax
  100370:	83 e0 03             	and    $0x3,%eax
  100373:	85 c0                	test   %eax,%eax
  100375:	75 15                	jne    10038c <debug_panic+0x2c>
		if (panicstr)
  100377:	a1 48 87 10 00       	mov    0x108748,%eax
  10037c:	85 c0                	test   %eax,%eax
  10037e:	0f 85 95 00 00 00    	jne    100419 <debug_panic+0xb9>
			goto dead;
		panicstr = fmt;
  100384:	8b 45 10             	mov    0x10(%ebp),%eax
  100387:	a3 48 87 10 00       	mov    %eax,0x108748
	}

	// First print the requested message
	va_start(ap, fmt);
  10038c:	8d 45 10             	lea    0x10(%ebp),%eax
  10038f:	83 c0 04             	add    $0x4,%eax
  100392:	89 45 e8             	mov    %eax,-0x18(%ebp)
	cprintf("kernel panic at %s:%d: ", file, line);
  100395:	8b 45 0c             	mov    0xc(%ebp),%eax
  100398:	89 44 24 08          	mov    %eax,0x8(%esp)
  10039c:	8b 45 08             	mov    0x8(%ebp),%eax
  10039f:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003a3:	c7 04 24 10 3b 10 00 	movl   $0x103b10,(%esp)
  1003aa:	e8 c6 2f 00 00       	call   103375 <cprintf>
	vcprintf(fmt, ap);
  1003af:	8b 45 10             	mov    0x10(%ebp),%eax
  1003b2:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1003b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003b9:	89 04 24             	mov    %eax,(%esp)
  1003bc:	e8 4b 2f 00 00       	call   10330c <vcprintf>
	cprintf("\n");
  1003c1:	c7 04 24 28 3b 10 00 	movl   $0x103b28,(%esp)
  1003c8:	e8 a8 2f 00 00       	call   103375 <cprintf>

static gcc_inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=rm" (ebp));
  1003cd:	89 6d f4             	mov    %ebp,-0xc(%ebp)
        return ebp;
  1003d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
	va_end(ap);

	// Then print a backtrace of the kernel call chain
	uint32_t eips[DEBUG_TRACEFRAMES];
	debug_trace(read_ebp(), eips);
  1003d3:	8d 55 c0             	lea    -0x40(%ebp),%edx
  1003d6:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003da:	89 04 24             	mov    %eax,(%esp)
  1003dd:	e8 86 00 00 00       	call   100468 <debug_trace>
	for (i = 0; i < DEBUG_TRACEFRAMES && eips[i] != 0; i++)
  1003e2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1003e9:	eb 1b                	jmp    100406 <debug_panic+0xa6>
		cprintf("  from %08x\n", eips[i]);
  1003eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1003ee:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
  1003f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003f6:	c7 04 24 2a 3b 10 00 	movl   $0x103b2a,(%esp)
  1003fd:	e8 73 2f 00 00       	call   103375 <cprintf>
	va_end(ap);

	// Then print a backtrace of the kernel call chain
	uint32_t eips[DEBUG_TRACEFRAMES];
	debug_trace(read_ebp(), eips);
	for (i = 0; i < DEBUG_TRACEFRAMES && eips[i] != 0; i++)
  100402:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100406:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
  10040a:	7f 0e                	jg     10041a <debug_panic+0xba>
  10040c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10040f:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
  100413:	85 c0                	test   %eax,%eax
  100415:	75 d4                	jne    1003eb <debug_panic+0x8b>
  100417:	eb 01                	jmp    10041a <debug_panic+0xba>
	int i;

	// Avoid infinite recursion if we're panicking from kernel mode.
	if ((read_cs() & 3) == 0) {
		if (panicstr)
			goto dead;
  100419:	90                   	nop
	debug_trace(read_ebp(), eips);
	for (i = 0; i < DEBUG_TRACEFRAMES && eips[i] != 0; i++)
		cprintf("  from %08x\n", eips[i]);

dead:
	done();		// enter infinite loop (see kern/init.c)
  10041a:	e8 96 fd ff ff       	call   1001b5 <done>

0010041f <debug_warn>:
}

/* like panic, but don't */
void
debug_warn(const char *file, int line, const char *fmt,...)
{
  10041f:	55                   	push   %ebp
  100420:	89 e5                	mov    %esp,%ebp
  100422:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  100425:	8d 45 10             	lea    0x10(%ebp),%eax
  100428:	83 c0 04             	add    $0x4,%eax
  10042b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel warning at %s:%d: ", file, line);
  10042e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100431:	89 44 24 08          	mov    %eax,0x8(%esp)
  100435:	8b 45 08             	mov    0x8(%ebp),%eax
  100438:	89 44 24 04          	mov    %eax,0x4(%esp)
  10043c:	c7 04 24 37 3b 10 00 	movl   $0x103b37,(%esp)
  100443:	e8 2d 2f 00 00       	call   103375 <cprintf>
	vcprintf(fmt, ap);
  100448:	8b 45 10             	mov    0x10(%ebp),%eax
  10044b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10044e:	89 54 24 04          	mov    %edx,0x4(%esp)
  100452:	89 04 24             	mov    %eax,(%esp)
  100455:	e8 b2 2e 00 00       	call   10330c <vcprintf>
	cprintf("\n");
  10045a:	c7 04 24 28 3b 10 00 	movl   $0x103b28,(%esp)
  100461:	e8 0f 2f 00 00       	call   103375 <cprintf>
	va_end(ap);
}
  100466:	c9                   	leave  
  100467:	c3                   	ret    

00100468 <debug_trace>:

// Record the current call stack in eips[] by following the %ebp chain.
void gcc_noinline
debug_trace(uint32_t ebp, uint32_t eips[DEBUG_TRACEFRAMES])
{
  100468:	55                   	push   %ebp
  100469:	89 e5                	mov    %esp,%ebp
  10046b:	56                   	push   %esi
  10046c:	53                   	push   %ebx
  10046d:	83 ec 30             	sub    $0x30,%esp
	int i = 0;
  100470:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	for(; i < DEBUG_TRACEFRAMES && ebp; i++) {
  100477:	e9 8c 00 00 00       	jmp    100508 <debug_trace+0xa0>
		uint32_t eip = (*(uint32_t *)(ebp + 4));
  10047c:	8b 45 08             	mov    0x8(%ebp),%eax
  10047f:	83 c0 04             	add    $0x4,%eax
  100482:	8b 00                	mov    (%eax),%eax
  100484:	89 45 f4             	mov    %eax,-0xc(%ebp)
		eips[i] = eip;
  100487:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10048a:	c1 e0 02             	shl    $0x2,%eax
  10048d:	03 45 0c             	add    0xc(%ebp),%eax
  100490:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100493:	89 10                	mov    %edx,(%eax)
		cprintf("ebp %08x  eip %08x  ", ebp, (*(uint32_t *)(ebp + 4)));
  100495:	8b 45 08             	mov    0x8(%ebp),%eax
  100498:	83 c0 04             	add    $0x4,%eax
  10049b:	8b 00                	mov    (%eax),%eax
  10049d:	89 44 24 08          	mov    %eax,0x8(%esp)
  1004a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1004a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004a8:	c7 04 24 51 3b 10 00 	movl   $0x103b51,(%esp)
  1004af:	e8 c1 2e 00 00       	call   103375 <cprintf>
		cprintf("args %08x %08x %08x %08x %08x\n",
				(*(uint32_t *)(ebp + 8)),
				(*(uint32_t *)(ebp + 12)),
				(*(uint32_t *)(ebp + 16)),
				(*(uint32_t *)(ebp + 20)),
				(*(uint32_t *)(ebp + 24)));
  1004b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1004b7:	83 c0 18             	add    $0x18,%eax
	int i = 0;
	for(; i < DEBUG_TRACEFRAMES && ebp; i++) {
		uint32_t eip = (*(uint32_t *)(ebp + 4));
		eips[i] = eip;
		cprintf("ebp %08x  eip %08x  ", ebp, (*(uint32_t *)(ebp + 4)));
		cprintf("args %08x %08x %08x %08x %08x\n",
  1004ba:	8b 30                	mov    (%eax),%esi
				(*(uint32_t *)(ebp + 8)),
				(*(uint32_t *)(ebp + 12)),
				(*(uint32_t *)(ebp + 16)),
				(*(uint32_t *)(ebp + 20)),
  1004bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1004bf:	83 c0 14             	add    $0x14,%eax
	int i = 0;
	for(; i < DEBUG_TRACEFRAMES && ebp; i++) {
		uint32_t eip = (*(uint32_t *)(ebp + 4));
		eips[i] = eip;
		cprintf("ebp %08x  eip %08x  ", ebp, (*(uint32_t *)(ebp + 4)));
		cprintf("args %08x %08x %08x %08x %08x\n",
  1004c2:	8b 18                	mov    (%eax),%ebx
				(*(uint32_t *)(ebp + 8)),
				(*(uint32_t *)(ebp + 12)),
				(*(uint32_t *)(ebp + 16)),
  1004c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1004c7:	83 c0 10             	add    $0x10,%eax
	int i = 0;
	for(; i < DEBUG_TRACEFRAMES && ebp; i++) {
		uint32_t eip = (*(uint32_t *)(ebp + 4));
		eips[i] = eip;
		cprintf("ebp %08x  eip %08x  ", ebp, (*(uint32_t *)(ebp + 4)));
		cprintf("args %08x %08x %08x %08x %08x\n",
  1004ca:	8b 08                	mov    (%eax),%ecx
				(*(uint32_t *)(ebp + 8)),
				(*(uint32_t *)(ebp + 12)),
  1004cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1004cf:	83 c0 0c             	add    $0xc,%eax
	int i = 0;
	for(; i < DEBUG_TRACEFRAMES && ebp; i++) {
		uint32_t eip = (*(uint32_t *)(ebp + 4));
		eips[i] = eip;
		cprintf("ebp %08x  eip %08x  ", ebp, (*(uint32_t *)(ebp + 4)));
		cprintf("args %08x %08x %08x %08x %08x\n",
  1004d2:	8b 10                	mov    (%eax),%edx
				(*(uint32_t *)(ebp + 8)),
  1004d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1004d7:	83 c0 08             	add    $0x8,%eax
	int i = 0;
	for(; i < DEBUG_TRACEFRAMES && ebp; i++) {
		uint32_t eip = (*(uint32_t *)(ebp + 4));
		eips[i] = eip;
		cprintf("ebp %08x  eip %08x  ", ebp, (*(uint32_t *)(ebp + 4)));
		cprintf("args %08x %08x %08x %08x %08x\n",
  1004da:	8b 00                	mov    (%eax),%eax
  1004dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  1004e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  1004e4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1004e8:	89 54 24 08          	mov    %edx,0x8(%esp)
  1004ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004f0:	c7 04 24 68 3b 10 00 	movl   $0x103b68,(%esp)
  1004f7:	e8 79 2e 00 00       	call   103375 <cprintf>
				(*(uint32_t *)(ebp + 8)),
				(*(uint32_t *)(ebp + 12)),
				(*(uint32_t *)(ebp + 16)),
				(*(uint32_t *)(ebp + 20)),
				(*(uint32_t *)(ebp + 24)));
		ebp = (*(uint32_t *)(ebp));
  1004fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1004ff:	8b 00                	mov    (%eax),%eax
  100501:	89 45 08             	mov    %eax,0x8(%ebp)
// Record the current call stack in eips[] by following the %ebp chain.
void gcc_noinline
debug_trace(uint32_t ebp, uint32_t eips[DEBUG_TRACEFRAMES])
{
	int i = 0;
	for(; i < DEBUG_TRACEFRAMES && ebp; i++) {
  100504:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  100508:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
  10050c:	7f 1f                	jg     10052d <debug_trace+0xc5>
  10050e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100512:	0f 85 64 ff ff ff    	jne    10047c <debug_trace+0x14>
				(*(uint32_t *)(ebp + 16)),
				(*(uint32_t *)(ebp + 20)),
				(*(uint32_t *)(ebp + 24)));
		ebp = (*(uint32_t *)(ebp));
	}
	for(; i < DEBUG_TRACEFRAMES; i++) { eips[i] = 0; }
  100518:	eb 13                	jmp    10052d <debug_trace+0xc5>
  10051a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10051d:	c1 e0 02             	shl    $0x2,%eax
  100520:	03 45 0c             	add    0xc(%ebp),%eax
  100523:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  100529:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  10052d:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
  100531:	7e e7                	jle    10051a <debug_trace+0xb2>
}
  100533:	83 c4 30             	add    $0x30,%esp
  100536:	5b                   	pop    %ebx
  100537:	5e                   	pop    %esi
  100538:	5d                   	pop    %ebp
  100539:	c3                   	ret    

0010053a <f3>:


static void gcc_noinline f3(int r, uint32_t *e) { debug_trace(read_ebp(), e); }
  10053a:	55                   	push   %ebp
  10053b:	89 e5                	mov    %esp,%ebp
  10053d:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=rm" (ebp));
  100540:	89 6d f4             	mov    %ebp,-0xc(%ebp)
        return ebp;
  100543:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100546:	8b 55 0c             	mov    0xc(%ebp),%edx
  100549:	89 54 24 04          	mov    %edx,0x4(%esp)
  10054d:	89 04 24             	mov    %eax,(%esp)
  100550:	e8 13 ff ff ff       	call   100468 <debug_trace>
  100555:	c9                   	leave  
  100556:	c3                   	ret    

00100557 <f2>:
static void gcc_noinline f2(int r, uint32_t *e) { r & 2 ? f3(r,e) : f3(r,e); }
  100557:	55                   	push   %ebp
  100558:	89 e5                	mov    %esp,%ebp
  10055a:	83 ec 18             	sub    $0x18,%esp
  10055d:	8b 45 08             	mov    0x8(%ebp),%eax
  100560:	83 e0 02             	and    $0x2,%eax
  100563:	85 c0                	test   %eax,%eax
  100565:	74 14                	je     10057b <f2+0x24>
  100567:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10056e:	8b 45 08             	mov    0x8(%ebp),%eax
  100571:	89 04 24             	mov    %eax,(%esp)
  100574:	e8 c1 ff ff ff       	call   10053a <f3>
  100579:	eb 12                	jmp    10058d <f2+0x36>
  10057b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10057e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100582:	8b 45 08             	mov    0x8(%ebp),%eax
  100585:	89 04 24             	mov    %eax,(%esp)
  100588:	e8 ad ff ff ff       	call   10053a <f3>
  10058d:	c9                   	leave  
  10058e:	c3                   	ret    

0010058f <f1>:
static void gcc_noinline f1(int r, uint32_t *e) { r & 1 ? f2(r,e) : f2(r,e); }
  10058f:	55                   	push   %ebp
  100590:	89 e5                	mov    %esp,%ebp
  100592:	83 ec 18             	sub    $0x18,%esp
  100595:	8b 45 08             	mov    0x8(%ebp),%eax
  100598:	83 e0 01             	and    $0x1,%eax
  10059b:	84 c0                	test   %al,%al
  10059d:	74 14                	je     1005b3 <f1+0x24>
  10059f:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1005a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1005a9:	89 04 24             	mov    %eax,(%esp)
  1005ac:	e8 a6 ff ff ff       	call   100557 <f2>
  1005b1:	eb 12                	jmp    1005c5 <f1+0x36>
  1005b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1005ba:	8b 45 08             	mov    0x8(%ebp),%eax
  1005bd:	89 04 24             	mov    %eax,(%esp)
  1005c0:	e8 92 ff ff ff       	call   100557 <f2>
  1005c5:	c9                   	leave  
  1005c6:	c3                   	ret    

001005c7 <debug_check>:

// Test the backtrace implementation for correct operation
void
debug_check(void)
{
  1005c7:	55                   	push   %ebp
  1005c8:	89 e5                	mov    %esp,%ebp
  1005ca:	81 ec c8 00 00 00    	sub    $0xc8,%esp
	uint32_t eips[4][DEBUG_TRACEFRAMES];
	int r, i;

	// produce several related backtraces...
	for (i = 0; i < 4; i++)
  1005d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1005d7:	eb 29                	jmp    100602 <debug_check+0x3b>
		f1(i, eips[i]);
  1005d9:	8d 8d 50 ff ff ff    	lea    -0xb0(%ebp),%ecx
  1005df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1005e2:	89 d0                	mov    %edx,%eax
  1005e4:	c1 e0 02             	shl    $0x2,%eax
  1005e7:	01 d0                	add    %edx,%eax
  1005e9:	c1 e0 03             	shl    $0x3,%eax
  1005ec:	8d 04 01             	lea    (%ecx,%eax,1),%eax
  1005ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  1005f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005f6:	89 04 24             	mov    %eax,(%esp)
  1005f9:	e8 91 ff ff ff       	call   10058f <f1>
{
	uint32_t eips[4][DEBUG_TRACEFRAMES];
	int r, i;

	// produce several related backtraces...
	for (i = 0; i < 4; i++)
  1005fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100602:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
  100606:	7e d1                	jle    1005d9 <debug_check+0x12>
		f1(i, eips[i]);

	// ...and make sure they come out correctly.
	for (r = 0; r < 4; r++)
  100608:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  10060f:	e9 bc 00 00 00       	jmp    1006d0 <debug_check+0x109>
		for (i = 0; i < DEBUG_TRACEFRAMES; i++) {
  100614:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10061b:	e9 a2 00 00 00       	jmp    1006c2 <debug_check+0xfb>
			assert((eips[r][i] != 0) == (i < 5));
  100620:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100623:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100626:	89 d0                	mov    %edx,%eax
  100628:	c1 e0 02             	shl    $0x2,%eax
  10062b:	01 d0                	add    %edx,%eax
  10062d:	01 c0                	add    %eax,%eax
  10062f:	01 c8                	add    %ecx,%eax
  100631:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
  100638:	85 c0                	test   %eax,%eax
  10063a:	0f 95 c2             	setne  %dl
  10063d:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
  100641:	0f 9e c0             	setle  %al
  100644:	31 d0                	xor    %edx,%eax
  100646:	84 c0                	test   %al,%al
  100648:	74 24                	je     10066e <debug_check+0xa7>
  10064a:	c7 44 24 0c 87 3b 10 	movl   $0x103b87,0xc(%esp)
  100651:	00 
  100652:	c7 44 24 08 a4 3b 10 	movl   $0x103ba4,0x8(%esp)
  100659:	00 
  10065a:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  100661:	00 
  100662:	c7 04 24 b9 3b 10 00 	movl   $0x103bb9,(%esp)
  100669:	e8 f2 fc ff ff       	call   100360 <debug_panic>
			if (i >= 2)
  10066e:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  100672:	7e 4a                	jle    1006be <debug_check+0xf7>
				assert(eips[r][i] == eips[0][i]);
  100674:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100677:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  10067a:	89 d0                	mov    %edx,%eax
  10067c:	c1 e0 02             	shl    $0x2,%eax
  10067f:	01 d0                	add    %edx,%eax
  100681:	01 c0                	add    %eax,%eax
  100683:	01 c8                	add    %ecx,%eax
  100685:	8b 94 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%edx
  10068c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10068f:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
  100696:	39 c2                	cmp    %eax,%edx
  100698:	74 24                	je     1006be <debug_check+0xf7>
  10069a:	c7 44 24 0c c6 3b 10 	movl   $0x103bc6,0xc(%esp)
  1006a1:	00 
  1006a2:	c7 44 24 08 a4 3b 10 	movl   $0x103ba4,0x8(%esp)
  1006a9:	00 
  1006aa:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  1006b1:	00 
  1006b2:	c7 04 24 b9 3b 10 00 	movl   $0x103bb9,(%esp)
  1006b9:	e8 a2 fc ff ff       	call   100360 <debug_panic>
	for (i = 0; i < 4; i++)
		f1(i, eips[i]);

	// ...and make sure they come out correctly.
	for (r = 0; r < 4; r++)
		for (i = 0; i < DEBUG_TRACEFRAMES; i++) {
  1006be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1006c2:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  1006c6:	0f 8e 54 ff ff ff    	jle    100620 <debug_check+0x59>
	// produce several related backtraces...
	for (i = 0; i < 4; i++)
		f1(i, eips[i]);

	// ...and make sure they come out correctly.
	for (r = 0; r < 4; r++)
  1006cc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  1006d0:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
  1006d4:	0f 8e 3a ff ff ff    	jle    100614 <debug_check+0x4d>
		for (i = 0; i < DEBUG_TRACEFRAMES; i++) {
			assert((eips[r][i] != 0) == (i < 5));
			if (i >= 2)
				assert(eips[r][i] == eips[0][i]);
		}
	assert(eips[0][0] == eips[1][0]);
  1006da:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  1006e0:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  1006e6:	39 c2                	cmp    %eax,%edx
  1006e8:	74 24                	je     10070e <debug_check+0x147>
  1006ea:	c7 44 24 0c df 3b 10 	movl   $0x103bdf,0xc(%esp)
  1006f1:	00 
  1006f2:	c7 44 24 08 a4 3b 10 	movl   $0x103ba4,0x8(%esp)
  1006f9:	00 
  1006fa:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  100701:	00 
  100702:	c7 04 24 b9 3b 10 00 	movl   $0x103bb9,(%esp)
  100709:	e8 52 fc ff ff       	call   100360 <debug_panic>
	assert(eips[2][0] == eips[3][0]);
  10070e:	8b 55 a0             	mov    -0x60(%ebp),%edx
  100711:	8b 45 c8             	mov    -0x38(%ebp),%eax
  100714:	39 c2                	cmp    %eax,%edx
  100716:	74 24                	je     10073c <debug_check+0x175>
  100718:	c7 44 24 0c f8 3b 10 	movl   $0x103bf8,0xc(%esp)
  10071f:	00 
  100720:	c7 44 24 08 a4 3b 10 	movl   $0x103ba4,0x8(%esp)
  100727:	00 
  100728:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
  10072f:	00 
  100730:	c7 04 24 b9 3b 10 00 	movl   $0x103bb9,(%esp)
  100737:	e8 24 fc ff ff       	call   100360 <debug_panic>
	assert(eips[1][0] != eips[2][0]);
  10073c:	8b 95 78 ff ff ff    	mov    -0x88(%ebp),%edx
  100742:	8b 45 a0             	mov    -0x60(%ebp),%eax
  100745:	39 c2                	cmp    %eax,%edx
  100747:	75 24                	jne    10076d <debug_check+0x1a6>
  100749:	c7 44 24 0c 11 3c 10 	movl   $0x103c11,0xc(%esp)
  100750:	00 
  100751:	c7 44 24 08 a4 3b 10 	movl   $0x103ba4,0x8(%esp)
  100758:	00 
  100759:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
  100760:	00 
  100761:	c7 04 24 b9 3b 10 00 	movl   $0x103bb9,(%esp)
  100768:	e8 f3 fb ff ff       	call   100360 <debug_panic>
	assert(eips[0][1] == eips[2][1]);
  10076d:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  100773:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  100776:	39 c2                	cmp    %eax,%edx
  100778:	74 24                	je     10079e <debug_check+0x1d7>
  10077a:	c7 44 24 0c 2a 3c 10 	movl   $0x103c2a,0xc(%esp)
  100781:	00 
  100782:	c7 44 24 08 a4 3b 10 	movl   $0x103ba4,0x8(%esp)
  100789:	00 
  10078a:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  100791:	00 
  100792:	c7 04 24 b9 3b 10 00 	movl   $0x103bb9,(%esp)
  100799:	e8 c2 fb ff ff       	call   100360 <debug_panic>
	assert(eips[1][1] == eips[3][1]);
  10079e:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  1007a4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1007a7:	39 c2                	cmp    %eax,%edx
  1007a9:	74 24                	je     1007cf <debug_check+0x208>
  1007ab:	c7 44 24 0c 43 3c 10 	movl   $0x103c43,0xc(%esp)
  1007b2:	00 
  1007b3:	c7 44 24 08 a4 3b 10 	movl   $0x103ba4,0x8(%esp)
  1007ba:	00 
  1007bb:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  1007c2:	00 
  1007c3:	c7 04 24 b9 3b 10 00 	movl   $0x103bb9,(%esp)
  1007ca:	e8 91 fb ff ff       	call   100360 <debug_panic>
	assert(eips[0][1] != eips[1][1]);
  1007cf:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  1007d5:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  1007db:	39 c2                	cmp    %eax,%edx
  1007dd:	75 24                	jne    100803 <debug_check+0x23c>
  1007df:	c7 44 24 0c 5c 3c 10 	movl   $0x103c5c,0xc(%esp)
  1007e6:	00 
  1007e7:	c7 44 24 08 a4 3b 10 	movl   $0x103ba4,0x8(%esp)
  1007ee:	00 
  1007ef:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  1007f6:	00 
  1007f7:	c7 04 24 b9 3b 10 00 	movl   $0x103bb9,(%esp)
  1007fe:	e8 5d fb ff ff       	call   100360 <debug_panic>

	cprintf("debug_check() succeeded!\n");
  100803:	c7 04 24 75 3c 10 00 	movl   $0x103c75,(%esp)
  10080a:	e8 66 2b 00 00       	call   103375 <cprintf>
}
  10080f:	c9                   	leave  
  100810:	c3                   	ret    
  100811:	90                   	nop
  100812:	90                   	nop
  100813:	90                   	nop

00100814 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  100814:	55                   	push   %ebp
  100815:	89 e5                	mov    %esp,%ebp
  100817:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  10081a:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  10081d:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  100820:	89 45 f0             	mov    %eax,-0x10(%ebp)
  100823:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100826:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10082b:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  10082e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100831:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  100837:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  10083c:	74 24                	je     100862 <cpu_cur+0x4e>
  10083e:	c7 44 24 0c 90 3c 10 	movl   $0x103c90,0xc(%esp)
  100845:	00 
  100846:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  10084d:	00 
  10084e:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  100855:	00 
  100856:	c7 04 24 bb 3c 10 00 	movl   $0x103cbb,(%esp)
  10085d:	e8 fe fa ff ff       	call   100360 <debug_panic>
	return c;
  100862:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  100865:	c9                   	leave  
  100866:	c3                   	ret    

00100867 <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  100867:	55                   	push   %ebp
  100868:	89 e5                	mov    %esp,%ebp
  10086a:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  10086d:	e8 a2 ff ff ff       	call   100814 <cpu_cur>
  100872:	3d 00 60 10 00       	cmp    $0x106000,%eax
  100877:	0f 94 c0             	sete   %al
  10087a:	0f b6 c0             	movzbl %al,%eax
}
  10087d:	c9                   	leave  
  10087e:	c3                   	ret    

0010087f <mem_init>:

void mem_check(void);

void
mem_init(void)
{
  10087f:	55                   	push   %ebp
  100880:	89 e5                	mov    %esp,%ebp
  100882:	83 ec 68             	sub    $0x68,%esp
	if (!cpu_onboot())	// only do once, on the boot CPU
  100885:	e8 dd ff ff ff       	call   100867 <cpu_onboot>
  10088a:	85 c0                	test   %eax,%eax
  10088c:	0f 84 22 03 00 00    	je     100bb4 <mem_init+0x335>
	// is available in the system (in bytes),
	// by reading the PC's BIOS-managed nonvolatile RAM (NVRAM).
	// The NVRAM tells us how many kilobytes there are.
	// Since the count is 16 bits, this gives us up to 64MB of RAM;
	// additional RAM beyond that would have to be detected another way.
	size_t basemem = ROUNDDOWN(nvram_read16(NVRAM_BASELO)*1024, PAGESIZE);
  100892:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
  100899:	e8 f1 22 00 00       	call   102b8f <nvram_read16>
  10089e:	c1 e0 0a             	shl    $0xa,%eax
  1008a1:	89 45 b8             	mov    %eax,-0x48(%ebp)
  1008a4:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1008a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1008ac:	89 45 a8             	mov    %eax,-0x58(%ebp)
	size_t extmem = ROUNDDOWN(nvram_read16(NVRAM_EXTLO)*1024, PAGESIZE);
  1008af:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
  1008b6:	e8 d4 22 00 00       	call   102b8f <nvram_read16>
  1008bb:	c1 e0 0a             	shl    $0xa,%eax
  1008be:	89 45 bc             	mov    %eax,-0x44(%ebp)
  1008c1:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1008c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1008c9:	89 45 ac             	mov    %eax,-0x54(%ebp)

	warn("Assuming we have 1GB of memory!");
  1008cc:	c7 44 24 08 c8 3c 10 	movl   $0x103cc8,0x8(%esp)
  1008d3:	00 
  1008d4:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  1008db:	00 
  1008dc:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  1008e3:	e8 37 fb ff ff       	call   10041f <debug_warn>
	extmem = 1024*1024*1024 - MEM_EXT;	// assume 1GB total memory
  1008e8:	c7 45 ac 00 00 f0 3f 	movl   $0x3ff00000,-0x54(%ebp)

	// The maximum physical address is the top of extended memory.
	mem_max = MEM_EXT + extmem;
  1008ef:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1008f2:	05 00 00 10 00       	add    $0x100000,%eax
  1008f7:	a3 78 8f 10 00       	mov    %eax,0x108f78

	// Compute the total number of physical pages (including I/O holes)
	mem_npage = mem_max / PAGESIZE;
  1008fc:	a1 78 8f 10 00       	mov    0x108f78,%eax
  100901:	c1 e8 0c             	shr    $0xc,%eax
  100904:	a3 74 8f 10 00       	mov    %eax,0x108f74

	cprintf("Physical memory: %dK available, ", (int)(mem_max/1024));
  100909:	a1 78 8f 10 00       	mov    0x108f78,%eax
  10090e:	c1 e8 0a             	shr    $0xa,%eax
  100911:	89 44 24 04          	mov    %eax,0x4(%esp)
  100915:	c7 04 24 f4 3c 10 00 	movl   $0x103cf4,(%esp)
  10091c:	e8 54 2a 00 00       	call   103375 <cprintf>
	cprintf("base = %dK, extended = %dK\n",
		(int)(basemem/1024), (int)(extmem/1024));
  100921:	8b 45 ac             	mov    -0x54(%ebp),%eax
  100924:	c1 e8 0a             	shr    $0xa,%eax

	// Compute the total number of physical pages (including I/O holes)
	mem_npage = mem_max / PAGESIZE;

	cprintf("Physical memory: %dK available, ", (int)(mem_max/1024));
	cprintf("base = %dK, extended = %dK\n",
  100927:	89 c2                	mov    %eax,%edx
		(int)(basemem/1024), (int)(extmem/1024));
  100929:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10092c:	c1 e8 0a             	shr    $0xa,%eax

	// Compute the total number of physical pages (including I/O holes)
	mem_npage = mem_max / PAGESIZE;

	cprintf("Physical memory: %dK available, ", (int)(mem_max/1024));
	cprintf("base = %dK, extended = %dK\n",
  10092f:	89 54 24 08          	mov    %edx,0x8(%esp)
  100933:	89 44 24 04          	mov    %eax,0x4(%esp)
  100937:	c7 04 24 15 3d 10 00 	movl   $0x103d15,(%esp)
  10093e:	e8 32 2a 00 00       	call   103375 <cprintf>
		(int)(basemem/1024), (int)(extmem/1024));

	// Insert code here to:
	// (1)	allocate physical memory for the mem_pageinfo array,
	//	making it big enough to hold mem_npage entries.
	mem_pageinfo = mem_ptr(ROUNDUP(mem_phys(end), PAGESIZE));
  100943:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  10094a:	b8 84 8f 10 00       	mov    $0x108f84,%eax
  10094f:	83 e8 01             	sub    $0x1,%eax
  100952:	03 45 c0             	add    -0x40(%ebp),%eax
  100955:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  100958:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10095b:	ba 00 00 00 00       	mov    $0x0,%edx
  100960:	f7 75 c0             	divl   -0x40(%ebp)
  100963:	89 d0                	mov    %edx,%eax
  100965:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  100968:	89 d1                	mov    %edx,%ecx
  10096a:	29 c1                	sub    %eax,%ecx
  10096c:	89 c8                	mov    %ecx,%eax
  10096e:	a3 7c 8f 10 00       	mov    %eax,0x108f7c
	cprintf("kernel end %p, pageinfo %p\n", end, mem_pageinfo);
  100973:	a1 7c 8f 10 00       	mov    0x108f7c,%eax
  100978:	89 44 24 08          	mov    %eax,0x8(%esp)
  10097c:	c7 44 24 04 84 8f 10 	movl   $0x108f84,0x4(%esp)
  100983:	00 
  100984:	c7 04 24 31 3d 10 00 	movl   $0x103d31,(%esp)
  10098b:	e8 e5 29 00 00       	call   103375 <cprintf>
	cprintf("num pages %d, pagetable takes %d pages\n", mem_npage,
		ROUNDUP(mem_npage*sizeof(pageinfo), PAGESIZE) / PAGESIZE);
  100990:	c7 45 c8 00 10 00 00 	movl   $0x1000,-0x38(%ebp)
  100997:	a1 74 8f 10 00       	mov    0x108f74,%eax
  10099c:	c1 e0 03             	shl    $0x3,%eax
  10099f:	03 45 c8             	add    -0x38(%ebp),%eax
  1009a2:	83 e8 01             	sub    $0x1,%eax
  1009a5:	89 45 cc             	mov    %eax,-0x34(%ebp)
  1009a8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1009ab:	ba 00 00 00 00       	mov    $0x0,%edx
  1009b0:	f7 75 c8             	divl   -0x38(%ebp)
  1009b3:	89 d0                	mov    %edx,%eax
  1009b5:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1009b8:	89 d1                	mov    %edx,%ecx
  1009ba:	29 c1                	sub    %eax,%ecx
  1009bc:	89 c8                	mov    %ecx,%eax
	// Insert code here to:
	// (1)	allocate physical memory for the mem_pageinfo array,
	//	making it big enough to hold mem_npage entries.
	mem_pageinfo = mem_ptr(ROUNDUP(mem_phys(end), PAGESIZE));
	cprintf("kernel end %p, pageinfo %p\n", end, mem_pageinfo);
	cprintf("num pages %d, pagetable takes %d pages\n", mem_npage,
  1009be:	89 c2                	mov    %eax,%edx
  1009c0:	c1 ea 0c             	shr    $0xc,%edx
  1009c3:	a1 74 8f 10 00       	mov    0x108f74,%eax
  1009c8:	89 54 24 08          	mov    %edx,0x8(%esp)
  1009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009d0:	c7 04 24 50 3d 10 00 	movl   $0x103d50,(%esp)
  1009d7:	e8 99 29 00 00       	call   103375 <cprintf>
	//     Some of it is in use, some is free.
	//     Which pages hold the kernel and the pageinfo array?
	//     Hint: the linker places the kernel (see start and end above),
	//     but YOU decide where to place the pageinfo array.
	// Change the code to reflect this.
	pageinfo **freetail = &mem_freelist;
  1009dc:	c7 45 b0 70 8f 10 00 	movl   $0x108f70,-0x50(%ebp)
	int i;
	for (i = 0; i < mem_npage; i++) {
  1009e3:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%ebp)
  1009ea:	e9 a5 01 00 00       	jmp    100b94 <mem_init+0x315>
		if(i == 0 || i == 1) {
  1009ef:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  1009f3:	74 06                	je     1009fb <mem_init+0x17c>
  1009f5:	83 7d b4 01          	cmpl   $0x1,-0x4c(%ebp)
  1009f9:	75 18                	jne    100a13 <mem_init+0x194>
			cprintf("page %d: IDT/BIOS/IO\n", i);
  1009fb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1009fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a02:	c7 04 24 78 3d 10 00 	movl   $0x103d78,(%esp)
  100a09:	e8 67 29 00 00       	call   103375 <cprintf>
			continue;
  100a0e:	e9 7d 01 00 00       	jmp    100b90 <mem_init+0x311>
		}
		if(i >= MEM_IO/PAGESIZE && i < MEM_EXT/PAGESIZE) {
  100a13:	81 7d b4 9f 00 00 00 	cmpl   $0x9f,-0x4c(%ebp)
  100a1a:	7e 21                	jle    100a3d <mem_init+0x1be>
  100a1c:	81 7d b4 ff 00 00 00 	cmpl   $0xff,-0x4c(%ebp)
  100a23:	7f 18                	jg     100a3d <mem_init+0x1be>
			cprintf("page %d: BIOS IO\n", i);
  100a25:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100a28:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a2c:	c7 04 24 8e 3d 10 00 	movl   $0x103d8e,(%esp)
  100a33:	e8 3d 29 00 00       	call   103375 <cprintf>
			continue;
  100a38:	e9 53 01 00 00       	jmp    100b90 <mem_init+0x311>
		}
		uint32_t kstartpg = ROUNDDOWN(mem_phys(start),PAGESIZE);
  100a3d:	c7 45 e0 0c 00 10 00 	movl   $0x10000c,-0x20(%ebp)
  100a44:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100a47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  100a4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		kstartpg /= PAGESIZE;
  100a4f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100a52:	c1 e8 0c             	shr    $0xc,%eax
  100a55:	89 45 d0             	mov    %eax,-0x30(%ebp)
		uint32_t kendpg = ROUNDUP(mem_phys(end), PAGESIZE);
  100a58:	c7 45 e4 00 10 00 00 	movl   $0x1000,-0x1c(%ebp)
  100a5f:	b8 84 8f 10 00       	mov    $0x108f84,%eax
  100a64:	83 e8 01             	sub    $0x1,%eax
  100a67:	03 45 e4             	add    -0x1c(%ebp),%eax
  100a6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  100a6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a70:	ba 00 00 00 00       	mov    $0x0,%edx
  100a75:	f7 75 e4             	divl   -0x1c(%ebp)
  100a78:	89 d0                	mov    %edx,%eax
  100a7a:	8b 55 e8             	mov    -0x18(%ebp),%edx
  100a7d:	89 d1                	mov    %edx,%ecx
  100a7f:	29 c1                	sub    %eax,%ecx
  100a81:	89 c8                	mov    %ecx,%eax
  100a83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		kendpg /= PAGESIZE;
  100a86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100a89:	c1 e8 0c             	shr    $0xc,%eax
  100a8c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		if(i >= kstartpg && i < kendpg) {
  100a8f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100a92:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  100a95:	72 20                	jb     100ab7 <mem_init+0x238>
  100a97:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100a9a:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  100a9d:	73 18                	jae    100ab7 <mem_init+0x238>
			cprintf("page %d: KERNEL\n", i);
  100a9f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  100aa6:	c7 04 24 a0 3d 10 00 	movl   $0x103da0,(%esp)
  100aad:	e8 c3 28 00 00       	call   103375 <cprintf>
			continue;
  100ab2:	e9 d9 00 00 00       	jmp    100b90 <mem_init+0x311>
		}
		uint32_t mstartpg = ROUNDDOWN(mem_phys(mem_pageinfo),PAGESIZE);
  100ab7:	a1 7c 8f 10 00       	mov    0x108f7c,%eax
  100abc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  100abf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100ac2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  100ac7:	89 45 d8             	mov    %eax,-0x28(%ebp)
		mstartpg /= PAGESIZE;
  100aca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100acd:	c1 e8 0c             	shr    $0xc,%eax
  100ad0:	89 45 d8             	mov    %eax,-0x28(%ebp)
		uint32_t mendpg = mem_phys(&mem_pageinfo[mem_npage]);
  100ad3:	a1 7c 8f 10 00       	mov    0x108f7c,%eax
  100ad8:	8b 15 74 8f 10 00    	mov    0x108f74,%edx
  100ade:	c1 e2 03             	shl    $0x3,%edx
  100ae1:	01 d0                	add    %edx,%eax
  100ae3:	89 45 dc             	mov    %eax,-0x24(%ebp)
		mendpg = ROUNDUP(mendpg, PAGESIZE) / PAGESIZE;
  100ae6:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  100aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100af0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100af3:	8d 04 02             	lea    (%edx,%eax,1),%eax
  100af6:	83 e8 01             	sub    $0x1,%eax
  100af9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100aff:	ba 00 00 00 00       	mov    $0x0,%edx
  100b04:	f7 75 f0             	divl   -0x10(%ebp)
  100b07:	89 d0                	mov    %edx,%eax
  100b09:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b0c:	89 d1                	mov    %edx,%ecx
  100b0e:	29 c1                	sub    %eax,%ecx
  100b10:	89 c8                	mov    %ecx,%eax
  100b12:	c1 e8 0c             	shr    $0xc,%eax
  100b15:	89 45 dc             	mov    %eax,-0x24(%ebp)
		if(i >= mstartpg && i < mendpg) {
  100b18:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100b1b:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  100b1e:	72 1d                	jb     100b3d <mem_init+0x2be>
  100b20:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100b23:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  100b26:	73 15                	jae    100b3d <mem_init+0x2be>
			cprintf("page %d: MEMPAGES\n", i);
  100b28:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b2f:	c7 04 24 b1 3d 10 00 	movl   $0x103db1,(%esp)
  100b36:	e8 3a 28 00 00       	call   103375 <cprintf>
			continue;
  100b3b:	eb 53                	jmp    100b90 <mem_init+0x311>
		}
		if(i < 1000) cprintf("page %d: free\n", i);
  100b3d:	81 7d b4 e7 03 00 00 	cmpl   $0x3e7,-0x4c(%ebp)
  100b44:	7f 13                	jg     100b59 <mem_init+0x2da>
  100b46:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100b49:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b4d:	c7 04 24 c4 3d 10 00 	movl   $0x103dc4,(%esp)
  100b54:	e8 1c 28 00 00       	call   103375 <cprintf>

		// A free page has no references to it.
		mem_pageinfo[i].refcount = 0;
  100b59:	a1 7c 8f 10 00       	mov    0x108f7c,%eax
  100b5e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  100b61:	c1 e2 03             	shl    $0x3,%edx
  100b64:	01 d0                	add    %edx,%eax
  100b66:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

		// Add the page to the end of the free list.
		*freetail = &mem_pageinfo[i];
  100b6d:	a1 7c 8f 10 00       	mov    0x108f7c,%eax
  100b72:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  100b75:	c1 e2 03             	shl    $0x3,%edx
  100b78:	8d 14 10             	lea    (%eax,%edx,1),%edx
  100b7b:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100b7e:	89 10                	mov    %edx,(%eax)
		freetail = &mem_pageinfo[i].free_next;
  100b80:	a1 7c 8f 10 00       	mov    0x108f7c,%eax
  100b85:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  100b88:	c1 e2 03             	shl    $0x3,%edx
  100b8b:	01 d0                	add    %edx,%eax
  100b8d:	89 45 b0             	mov    %eax,-0x50(%ebp)
	//     Hint: the linker places the kernel (see start and end above),
	//     but YOU decide where to place the pageinfo array.
	// Change the code to reflect this.
	pageinfo **freetail = &mem_freelist;
	int i;
	for (i = 0; i < mem_npage; i++) {
  100b90:	83 45 b4 01          	addl   $0x1,-0x4c(%ebp)
  100b94:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  100b97:	a1 74 8f 10 00       	mov    0x108f74,%eax
  100b9c:	39 c2                	cmp    %eax,%edx
  100b9e:	0f 82 4b fe ff ff    	jb     1009ef <mem_init+0x170>

		// Add the page to the end of the free list.
		*freetail = &mem_pageinfo[i];
		freetail = &mem_pageinfo[i].free_next;
	}
	*freetail = NULL;	// null-terminate the freelist
  100ba4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100ba7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// ...and remove this when you're ready.
	// panic("mem_init() not implemented");

	// Check to make sure the page allocator seems to work correctly.
	mem_check();
  100bad:	e8 7b 00 00 00       	call   100c2d <mem_check>
  100bb2:	eb 01                	jmp    100bb5 <mem_init+0x336>

void
mem_init(void)
{
	if (!cpu_onboot())	// only do once, on the boot CPU
		return;
  100bb4:	90                   	nop
	// ...and remove this when you're ready.
	// panic("mem_init() not implemented");

	// Check to make sure the page allocator seems to work correctly.
	mem_check();
}
  100bb5:	c9                   	leave  
  100bb6:	c3                   	ret    

00100bb7 <mem_alloc>:
//
// Hint: pi->refs should not be incremented 
// Hint: be sure to use proper mutual exclusion for multiprocessor operation.
pageinfo *
mem_alloc(void)
{
  100bb7:	55                   	push   %ebp
  100bb8:	89 e5                	mov    %esp,%ebp
  100bba:	83 ec 10             	sub    $0x10,%esp
	if(!mem_freelist) { return NULL; }
  100bbd:	a1 70 8f 10 00       	mov    0x108f70,%eax
  100bc2:	85 c0                	test   %eax,%eax
  100bc4:	75 07                	jne    100bcd <mem_alloc+0x16>
  100bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  100bcb:	eb 15                	jmp    100be2 <mem_alloc+0x2b>
	pageinfo *r = mem_freelist;
  100bcd:	a1 70 8f 10 00       	mov    0x108f70,%eax
  100bd2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	mem_freelist = r->free_next;
  100bd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100bd8:	8b 00                	mov    (%eax),%eax
  100bda:	a3 70 8f 10 00       	mov    %eax,0x108f70
	// TODO: MUTUAL EXCLUSION
	return r;
  100bdf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100be2:	c9                   	leave  
  100be3:	c3                   	ret    

00100be4 <mem_free>:
// Return a page to the free list, given its pageinfo pointer.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
mem_free(pageinfo *pi)
{
  100be4:	55                   	push   %ebp
  100be5:	89 e5                	mov    %esp,%ebp
  100be7:	83 ec 18             	sub    $0x18,%esp
	assert(pi->refcount == 0);
  100bea:	8b 45 08             	mov    0x8(%ebp),%eax
  100bed:	8b 40 04             	mov    0x4(%eax),%eax
  100bf0:	85 c0                	test   %eax,%eax
  100bf2:	74 24                	je     100c18 <mem_free+0x34>
  100bf4:	c7 44 24 0c d3 3d 10 	movl   $0x103dd3,0xc(%esp)
  100bfb:	00 
  100bfc:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100c03:	00 
  100c04:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
  100c0b:	00 
  100c0c:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100c13:	e8 48 f7 ff ff       	call   100360 <debug_panic>
	pi->free_next = mem_freelist;
  100c18:	8b 15 70 8f 10 00    	mov    0x108f70,%edx
  100c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  100c21:	89 10                	mov    %edx,(%eax)
	mem_freelist = pi;
  100c23:	8b 45 08             	mov    0x8(%ebp),%eax
  100c26:	a3 70 8f 10 00       	mov    %eax,0x108f70
}
  100c2b:	c9                   	leave  
  100c2c:	c3                   	ret    

00100c2d <mem_check>:
// Check the physical page allocator (mem_alloc(), mem_free())
// for correct operation after initialization via mem_init().
//
void
mem_check()
{
  100c2d:	55                   	push   %ebp
  100c2e:	89 e5                	mov    %esp,%ebp
  100c30:	83 ec 38             	sub    $0x38,%esp
	int i;

        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	int freepages = 0;
  100c33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (pp = mem_freelist; pp != 0; pp = pp->free_next) {
  100c3a:	a1 70 8f 10 00       	mov    0x108f70,%eax
  100c3f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100c42:	eb 38                	jmp    100c7c <mem_check+0x4f>
		memset(mem_pi2ptr(pp), 0x97, 128);
  100c44:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100c47:	a1 7c 8f 10 00       	mov    0x108f7c,%eax
  100c4c:	89 d1                	mov    %edx,%ecx
  100c4e:	29 c1                	sub    %eax,%ecx
  100c50:	89 c8                	mov    %ecx,%eax
  100c52:	c1 f8 03             	sar    $0x3,%eax
  100c55:	c1 e0 0c             	shl    $0xc,%eax
  100c58:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  100c5f:	00 
  100c60:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
  100c67:	00 
  100c68:	89 04 24             	mov    %eax,(%esp)
  100c6b:	e8 ec 28 00 00       	call   10355c <memset>
		freepages++;
  100c70:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	int freepages = 0;
	for (pp = mem_freelist; pp != 0; pp = pp->free_next) {
  100c74:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100c77:	8b 00                	mov    (%eax),%eax
  100c79:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100c7c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  100c80:	75 c2                	jne    100c44 <mem_check+0x17>
		memset(mem_pi2ptr(pp), 0x97, 128);
		freepages++;
	}
	cprintf("mem_check: %d free pages\n", freepages);
  100c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c85:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c89:	c7 04 24 e5 3d 10 00 	movl   $0x103de5,(%esp)
  100c90:	e8 e0 26 00 00       	call   103375 <cprintf>
	assert(freepages < mem_npage);	// can't have more free than total!
  100c95:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c98:	a1 74 8f 10 00       	mov    0x108f74,%eax
  100c9d:	39 c2                	cmp    %eax,%edx
  100c9f:	72 24                	jb     100cc5 <mem_check+0x98>
  100ca1:	c7 44 24 0c ff 3d 10 	movl   $0x103dff,0xc(%esp)
  100ca8:	00 
  100ca9:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100cb0:	00 
  100cb1:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
  100cb8:	00 
  100cb9:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100cc0:	e8 9b f6 ff ff       	call   100360 <debug_panic>
	assert(freepages > 16000);	// make sure it's in the right ballpark
  100cc5:	81 7d f4 80 3e 00 00 	cmpl   $0x3e80,-0xc(%ebp)
  100ccc:	7f 24                	jg     100cf2 <mem_check+0xc5>
  100cce:	c7 44 24 0c 15 3e 10 	movl   $0x103e15,0xc(%esp)
  100cd5:	00 
  100cd6:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100cdd:	00 
  100cde:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
  100ce5:	00 
  100ce6:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100ced:	e8 6e f6 ff ff       	call   100360 <debug_panic>

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
  100cf2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100cf9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100cfc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100cff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100d02:	89 45 e0             	mov    %eax,-0x20(%ebp)
	pp0 = mem_alloc(); assert(pp0 != 0);
  100d05:	e8 ad fe ff ff       	call   100bb7 <mem_alloc>
  100d0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  100d0d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  100d11:	75 24                	jne    100d37 <mem_check+0x10a>
  100d13:	c7 44 24 0c 27 3e 10 	movl   $0x103e27,0xc(%esp)
  100d1a:	00 
  100d1b:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100d22:	00 
  100d23:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
  100d2a:	00 
  100d2b:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100d32:	e8 29 f6 ff ff       	call   100360 <debug_panic>
	pp1 = mem_alloc(); assert(pp1 != 0);
  100d37:	e8 7b fe ff ff       	call   100bb7 <mem_alloc>
  100d3c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100d3f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  100d43:	75 24                	jne    100d69 <mem_check+0x13c>
  100d45:	c7 44 24 0c 30 3e 10 	movl   $0x103e30,0xc(%esp)
  100d4c:	00 
  100d4d:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100d54:	00 
  100d55:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
  100d5c:	00 
  100d5d:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100d64:	e8 f7 f5 ff ff       	call   100360 <debug_panic>
	pp2 = mem_alloc(); assert(pp2 != 0);
  100d69:	e8 49 fe ff ff       	call   100bb7 <mem_alloc>
  100d6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  100d71:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  100d75:	75 24                	jne    100d9b <mem_check+0x16e>
  100d77:	c7 44 24 0c 39 3e 10 	movl   $0x103e39,0xc(%esp)
  100d7e:	00 
  100d7f:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100d86:	00 
  100d87:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
  100d8e:	00 
  100d8f:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100d96:	e8 c5 f5 ff ff       	call   100360 <debug_panic>

	assert(pp0);
  100d9b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  100d9f:	75 24                	jne    100dc5 <mem_check+0x198>
  100da1:	c7 44 24 0c 42 3e 10 	movl   $0x103e42,0xc(%esp)
  100da8:	00 
  100da9:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100db0:	00 
  100db1:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
  100db8:	00 
  100db9:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100dc0:	e8 9b f5 ff ff       	call   100360 <debug_panic>
	assert(pp1 && pp1 != pp0);
  100dc5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  100dc9:	74 08                	je     100dd3 <mem_check+0x1a6>
  100dcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100dce:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  100dd1:	75 24                	jne    100df7 <mem_check+0x1ca>
  100dd3:	c7 44 24 0c 46 3e 10 	movl   $0x103e46,0xc(%esp)
  100dda:	00 
  100ddb:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100de2:	00 
  100de3:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
  100dea:	00 
  100deb:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100df2:	e8 69 f5 ff ff       	call   100360 <debug_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
  100df7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  100dfb:	74 10                	je     100e0d <mem_check+0x1e0>
  100dfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100e00:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  100e03:	74 08                	je     100e0d <mem_check+0x1e0>
  100e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100e08:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  100e0b:	75 24                	jne    100e31 <mem_check+0x204>
  100e0d:	c7 44 24 0c 58 3e 10 	movl   $0x103e58,0xc(%esp)
  100e14:	00 
  100e15:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100e1c:	00 
  100e1d:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
  100e24:	00 
  100e25:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100e2c:	e8 2f f5 ff ff       	call   100360 <debug_panic>
        assert(mem_pi2phys(pp0) < mem_npage*PAGESIZE);
  100e31:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100e34:	a1 7c 8f 10 00       	mov    0x108f7c,%eax
  100e39:	89 d1                	mov    %edx,%ecx
  100e3b:	29 c1                	sub    %eax,%ecx
  100e3d:	89 c8                	mov    %ecx,%eax
  100e3f:	c1 f8 03             	sar    $0x3,%eax
  100e42:	c1 e0 0c             	shl    $0xc,%eax
  100e45:	8b 15 74 8f 10 00    	mov    0x108f74,%edx
  100e4b:	c1 e2 0c             	shl    $0xc,%edx
  100e4e:	39 d0                	cmp    %edx,%eax
  100e50:	72 24                	jb     100e76 <mem_check+0x249>
  100e52:	c7 44 24 0c 78 3e 10 	movl   $0x103e78,0xc(%esp)
  100e59:	00 
  100e5a:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100e61:	00 
  100e62:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  100e69:	00 
  100e6a:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100e71:	e8 ea f4 ff ff       	call   100360 <debug_panic>
        assert(mem_pi2phys(pp1) < mem_npage*PAGESIZE);
  100e76:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100e79:	a1 7c 8f 10 00       	mov    0x108f7c,%eax
  100e7e:	89 d1                	mov    %edx,%ecx
  100e80:	29 c1                	sub    %eax,%ecx
  100e82:	89 c8                	mov    %ecx,%eax
  100e84:	c1 f8 03             	sar    $0x3,%eax
  100e87:	c1 e0 0c             	shl    $0xc,%eax
  100e8a:	8b 15 74 8f 10 00    	mov    0x108f74,%edx
  100e90:	c1 e2 0c             	shl    $0xc,%edx
  100e93:	39 d0                	cmp    %edx,%eax
  100e95:	72 24                	jb     100ebb <mem_check+0x28e>
  100e97:	c7 44 24 0c a0 3e 10 	movl   $0x103ea0,0xc(%esp)
  100e9e:	00 
  100e9f:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100ea6:	00 
  100ea7:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
  100eae:	00 
  100eaf:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100eb6:	e8 a5 f4 ff ff       	call   100360 <debug_panic>
        assert(mem_pi2phys(pp2) < mem_npage*PAGESIZE);
  100ebb:	8b 55 e8             	mov    -0x18(%ebp),%edx
  100ebe:	a1 7c 8f 10 00       	mov    0x108f7c,%eax
  100ec3:	89 d1                	mov    %edx,%ecx
  100ec5:	29 c1                	sub    %eax,%ecx
  100ec7:	89 c8                	mov    %ecx,%eax
  100ec9:	c1 f8 03             	sar    $0x3,%eax
  100ecc:	c1 e0 0c             	shl    $0xc,%eax
  100ecf:	8b 15 74 8f 10 00    	mov    0x108f74,%edx
  100ed5:	c1 e2 0c             	shl    $0xc,%edx
  100ed8:	39 d0                	cmp    %edx,%eax
  100eda:	72 24                	jb     100f00 <mem_check+0x2d3>
  100edc:	c7 44 24 0c c8 3e 10 	movl   $0x103ec8,0xc(%esp)
  100ee3:	00 
  100ee4:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100eeb:	00 
  100eec:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
  100ef3:	00 
  100ef4:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100efb:	e8 60 f4 ff ff       	call   100360 <debug_panic>

	// temporarily steal the rest of the free pages
	fl = mem_freelist;
  100f00:	a1 70 8f 10 00       	mov    0x108f70,%eax
  100f05:	89 45 ec             	mov    %eax,-0x14(%ebp)
	mem_freelist = 0;
  100f08:	c7 05 70 8f 10 00 00 	movl   $0x0,0x108f70
  100f0f:	00 00 00 

	// should be no free memory
	assert(mem_alloc() == 0);
  100f12:	e8 a0 fc ff ff       	call   100bb7 <mem_alloc>
  100f17:	85 c0                	test   %eax,%eax
  100f19:	74 24                	je     100f3f <mem_check+0x312>
  100f1b:	c7 44 24 0c ee 3e 10 	movl   $0x103eee,0xc(%esp)
  100f22:	00 
  100f23:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100f2a:	00 
  100f2b:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
  100f32:	00 
  100f33:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100f3a:	e8 21 f4 ff ff       	call   100360 <debug_panic>

        // free and re-allocate?
        mem_free(pp0);
  100f3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100f42:	89 04 24             	mov    %eax,(%esp)
  100f45:	e8 9a fc ff ff       	call   100be4 <mem_free>
        mem_free(pp1);
  100f4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100f4d:	89 04 24             	mov    %eax,(%esp)
  100f50:	e8 8f fc ff ff       	call   100be4 <mem_free>
        mem_free(pp2);
  100f55:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100f58:	89 04 24             	mov    %eax,(%esp)
  100f5b:	e8 84 fc ff ff       	call   100be4 <mem_free>
	pp0 = pp1 = pp2 = 0;
  100f60:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100f67:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100f6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100f6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100f70:	89 45 e0             	mov    %eax,-0x20(%ebp)
	pp0 = mem_alloc(); assert(pp0 != 0);
  100f73:	e8 3f fc ff ff       	call   100bb7 <mem_alloc>
  100f78:	89 45 e0             	mov    %eax,-0x20(%ebp)
  100f7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  100f7f:	75 24                	jne    100fa5 <mem_check+0x378>
  100f81:	c7 44 24 0c 27 3e 10 	movl   $0x103e27,0xc(%esp)
  100f88:	00 
  100f89:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100f90:	00 
  100f91:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
  100f98:	00 
  100f99:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100fa0:	e8 bb f3 ff ff       	call   100360 <debug_panic>
	pp1 = mem_alloc(); assert(pp1 != 0);
  100fa5:	e8 0d fc ff ff       	call   100bb7 <mem_alloc>
  100faa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100fad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  100fb1:	75 24                	jne    100fd7 <mem_check+0x3aa>
  100fb3:	c7 44 24 0c 30 3e 10 	movl   $0x103e30,0xc(%esp)
  100fba:	00 
  100fbb:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100fc2:	00 
  100fc3:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
  100fca:	00 
  100fcb:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  100fd2:	e8 89 f3 ff ff       	call   100360 <debug_panic>
	pp2 = mem_alloc(); assert(pp2 != 0);
  100fd7:	e8 db fb ff ff       	call   100bb7 <mem_alloc>
  100fdc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  100fdf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  100fe3:	75 24                	jne    101009 <mem_check+0x3dc>
  100fe5:	c7 44 24 0c 39 3e 10 	movl   $0x103e39,0xc(%esp)
  100fec:	00 
  100fed:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  100ff4:	00 
  100ff5:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
  100ffc:	00 
  100ffd:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  101004:	e8 57 f3 ff ff       	call   100360 <debug_panic>
	assert(pp0);
  101009:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10100d:	75 24                	jne    101033 <mem_check+0x406>
  10100f:	c7 44 24 0c 42 3e 10 	movl   $0x103e42,0xc(%esp)
  101016:	00 
  101017:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  10101e:	00 
  10101f:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  101026:	00 
  101027:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  10102e:	e8 2d f3 ff ff       	call   100360 <debug_panic>
	assert(pp1 && pp1 != pp0);
  101033:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  101037:	74 08                	je     101041 <mem_check+0x414>
  101039:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10103c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  10103f:	75 24                	jne    101065 <mem_check+0x438>
  101041:	c7 44 24 0c 46 3e 10 	movl   $0x103e46,0xc(%esp)
  101048:	00 
  101049:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  101050:	00 
  101051:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  101058:	00 
  101059:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  101060:	e8 fb f2 ff ff       	call   100360 <debug_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
  101065:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  101069:	74 10                	je     10107b <mem_check+0x44e>
  10106b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10106e:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  101071:	74 08                	je     10107b <mem_check+0x44e>
  101073:	8b 45 e8             	mov    -0x18(%ebp),%eax
  101076:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  101079:	75 24                	jne    10109f <mem_check+0x472>
  10107b:	c7 44 24 0c 58 3e 10 	movl   $0x103e58,0xc(%esp)
  101082:	00 
  101083:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  10108a:	00 
  10108b:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
  101092:	00 
  101093:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  10109a:	e8 c1 f2 ff ff       	call   100360 <debug_panic>
	assert(mem_alloc() == 0);
  10109f:	e8 13 fb ff ff       	call   100bb7 <mem_alloc>
  1010a4:	85 c0                	test   %eax,%eax
  1010a6:	74 24                	je     1010cc <mem_check+0x49f>
  1010a8:	c7 44 24 0c ee 3e 10 	movl   $0x103eee,0xc(%esp)
  1010af:	00 
  1010b0:	c7 44 24 08 a6 3c 10 	movl   $0x103ca6,0x8(%esp)
  1010b7:	00 
  1010b8:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  1010bf:	00 
  1010c0:	c7 04 24 e8 3c 10 00 	movl   $0x103ce8,(%esp)
  1010c7:	e8 94 f2 ff ff       	call   100360 <debug_panic>

	// give free list back
	mem_freelist = fl;
  1010cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1010cf:	a3 70 8f 10 00       	mov    %eax,0x108f70

	// free the pages we took
	mem_free(pp0);
  1010d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1010d7:	89 04 24             	mov    %eax,(%esp)
  1010da:	e8 05 fb ff ff       	call   100be4 <mem_free>
	mem_free(pp1);
  1010df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1010e2:	89 04 24             	mov    %eax,(%esp)
  1010e5:	e8 fa fa ff ff       	call   100be4 <mem_free>
	mem_free(pp2);
  1010ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1010ed:	89 04 24             	mov    %eax,(%esp)
  1010f0:	e8 ef fa ff ff       	call   100be4 <mem_free>

	cprintf("mem_check() succeeded!\n");
  1010f5:	c7 04 24 ff 3e 10 00 	movl   $0x103eff,(%esp)
  1010fc:	e8 74 22 00 00       	call   103375 <cprintf>
}
  101101:	c9                   	leave  
  101102:	c3                   	ret    
  101103:	90                   	nop

00101104 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  101104:	55                   	push   %ebp
  101105:	89 e5                	mov    %esp,%ebp
  101107:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  10110a:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  10110d:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  101110:	89 45 f0             	mov    %eax,-0x10(%ebp)
  101113:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101116:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10111b:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  10111e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101121:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  101127:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  10112c:	74 24                	je     101152 <cpu_cur+0x4e>
  10112e:	c7 44 24 0c 17 3f 10 	movl   $0x103f17,0xc(%esp)
  101135:	00 
  101136:	c7 44 24 08 2d 3f 10 	movl   $0x103f2d,0x8(%esp)
  10113d:	00 
  10113e:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  101145:	00 
  101146:	c7 04 24 42 3f 10 00 	movl   $0x103f42,(%esp)
  10114d:	e8 0e f2 ff ff       	call   100360 <debug_panic>
	return c;
  101152:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  101155:	c9                   	leave  
  101156:	c3                   	ret    

00101157 <cpu_init>:
	magic: CPU_MAGIC
};


void cpu_init()
{
  101157:	55                   	push   %ebp
  101158:	89 e5                	mov    %esp,%ebp
  10115a:	53                   	push   %ebx
  10115b:	83 ec 24             	sub    $0x24,%esp
	cpu *c = cpu_cur();
  10115e:	e8 a1 ff ff ff       	call   101104 <cpu_cur>
  101163:	89 45 f0             	mov    %eax,-0x10(%ebp)

	// Load the GDT
	struct pseudodesc gdt_pd = {
		sizeof(c->gdt) - 1, (uint32_t) c->gdt };
  101166:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101169:	66 c7 45 ea 37 00    	movw   $0x37,-0x16(%ebp)
  10116f:	89 45 ec             	mov    %eax,-0x14(%ebp)
	asm volatile("lgdt %0" : : "m" (gdt_pd));
  101172:	0f 01 55 ea          	lgdtl  -0x16(%ebp)

	// Reload all segment registers.
	asm volatile("movw %%ax,%%gs" :: "a" (CPU_GDT_UDATA|3));
  101176:	b8 23 00 00 00       	mov    $0x23,%eax
  10117b:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (CPU_GDT_UDATA|3));
  10117d:	b8 23 00 00 00       	mov    $0x23,%eax
  101182:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (CPU_GDT_KDATA));
  101184:	b8 10 00 00 00       	mov    $0x10,%eax
  101189:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (CPU_GDT_KDATA));
  10118b:	b8 10 00 00 00       	mov    $0x10,%eax
  101190:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (CPU_GDT_KDATA));
  101192:	b8 10 00 00 00       	mov    $0x10,%eax
  101197:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (CPU_GDT_KCODE));
  101199:	ea a0 11 10 00 08 00 	ljmp   $0x8,$0x1011a0
	// reload CS

	c->gdt[CPU_GDT_TSS >> 3] = SEGDESC16(0, STS_T32A, 
  1011a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1011a3:	83 c0 38             	add    $0x38,%eax
  1011a6:	89 c3                	mov    %eax,%ebx
  1011a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1011ab:	83 c0 38             	add    $0x38,%eax
  1011ae:	c1 e8 10             	shr    $0x10,%eax
  1011b1:	89 c1                	mov    %eax,%ecx
  1011b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1011b6:	83 c0 38             	add    $0x38,%eax
  1011b9:	c1 e8 18             	shr    $0x18,%eax
  1011bc:	89 c2                	mov    %eax,%edx
  1011be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1011c1:	66 c7 40 30 67 00    	movw   $0x67,0x30(%eax)
  1011c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1011ca:	66 89 58 32          	mov    %bx,0x32(%eax)
  1011ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1011d1:	88 48 34             	mov    %cl,0x34(%eax)
  1011d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1011d7:	0f b6 48 35          	movzbl 0x35(%eax),%ecx
  1011db:	83 e1 f0             	and    $0xfffffff0,%ecx
  1011de:	83 c9 09             	or     $0x9,%ecx
  1011e1:	88 48 35             	mov    %cl,0x35(%eax)
  1011e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1011e7:	0f b6 48 35          	movzbl 0x35(%eax),%ecx
  1011eb:	83 e1 ef             	and    $0xffffffef,%ecx
  1011ee:	88 48 35             	mov    %cl,0x35(%eax)
  1011f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1011f4:	0f b6 48 35          	movzbl 0x35(%eax),%ecx
  1011f8:	83 e1 9f             	and    $0xffffff9f,%ecx
  1011fb:	88 48 35             	mov    %cl,0x35(%eax)
  1011fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101201:	0f b6 48 35          	movzbl 0x35(%eax),%ecx
  101205:	83 c9 80             	or     $0xffffff80,%ecx
  101208:	88 48 35             	mov    %cl,0x35(%eax)
  10120b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10120e:	0f b6 48 36          	movzbl 0x36(%eax),%ecx
  101212:	83 e1 f0             	and    $0xfffffff0,%ecx
  101215:	88 48 36             	mov    %cl,0x36(%eax)
  101218:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10121b:	0f b6 48 36          	movzbl 0x36(%eax),%ecx
  10121f:	83 e1 ef             	and    $0xffffffef,%ecx
  101222:	88 48 36             	mov    %cl,0x36(%eax)
  101225:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101228:	0f b6 48 36          	movzbl 0x36(%eax),%ecx
  10122c:	83 e1 df             	and    $0xffffffdf,%ecx
  10122f:	88 48 36             	mov    %cl,0x36(%eax)
  101232:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101235:	0f b6 48 36          	movzbl 0x36(%eax),%ecx
  101239:	83 c9 40             	or     $0x40,%ecx
  10123c:	88 48 36             	mov    %cl,0x36(%eax)
  10123f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101242:	0f b6 48 36          	movzbl 0x36(%eax),%ecx
  101246:	83 e1 7f             	and    $0x7f,%ecx
  101249:	88 48 36             	mov    %cl,0x36(%eax)
  10124c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10124f:	88 50 37             	mov    %dl,0x37(%eax)
			(uintptr_t)(&(c->tss)), sizeof(taskstate)-1, 0);
	c->tss.ts_esp0 = (uintptr_t)(c->kstackhi);
  101252:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101255:	05 00 10 00 00       	add    $0x1000,%eax
  10125a:	89 c2                	mov    %eax,%edx
  10125c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10125f:	89 50 3c             	mov    %edx,0x3c(%eax)
	c->tss.ts_ss0 = CPU_GDT_KDATA;
  101262:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101265:	66 c7 40 40 10 00    	movw   $0x10,0x40(%eax)
  10126b:	66 c7 45 f6 30 00    	movw   $0x30,-0xa(%ebp)
}

static gcc_inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
  101271:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101275:	0f 00 d8             	ltr    %ax
	ltr(CPU_GDT_TSS);

	// We don't need an LDT.
	asm volatile("lldt %%ax" :: "a" (0));
  101278:	b8 00 00 00 00       	mov    $0x0,%eax
  10127d:	0f 00 d0             	lldt   %ax
	cprintf("cpu_init complete\n");
  101280:	c7 04 24 4f 3f 10 00 	movl   $0x103f4f,(%esp)
  101287:	e8 e9 20 00 00       	call   103375 <cprintf>
}
  10128c:	83 c4 24             	add    $0x24,%esp
  10128f:	5b                   	pop    %ebx
  101290:	5d                   	pop    %ebp
  101291:	c3                   	ret    
  101292:	90                   	nop
  101293:	90                   	nop

00101294 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  101294:	55                   	push   %ebp
  101295:	89 e5                	mov    %esp,%ebp
  101297:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  10129a:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  10129d:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  1012a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1012a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1012a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1012ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  1012ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1012b1:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  1012b7:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  1012bc:	74 24                	je     1012e2 <cpu_cur+0x4e>
  1012be:	c7 44 24 0c 80 3f 10 	movl   $0x103f80,0xc(%esp)
  1012c5:	00 
  1012c6:	c7 44 24 08 96 3f 10 	movl   $0x103f96,0x8(%esp)
  1012cd:	00 
  1012ce:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  1012d5:	00 
  1012d6:	c7 04 24 ab 3f 10 00 	movl   $0x103fab,(%esp)
  1012dd:	e8 7e f0 ff ff       	call   100360 <debug_panic>
	return c;
  1012e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  1012e5:	c9                   	leave  
  1012e6:	c3                   	ret    

001012e7 <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  1012e7:	55                   	push   %ebp
  1012e8:	89 e5                	mov    %esp,%ebp
  1012ea:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  1012ed:	e8 a2 ff ff ff       	call   101294 <cpu_cur>
  1012f2:	3d 00 60 10 00       	cmp    $0x106000,%eax
  1012f7:	0f 94 c0             	sete   %al
  1012fa:	0f b6 c0             	movzbl %al,%eax
}
  1012fd:	c9                   	leave  
  1012fe:	c3                   	ret    

001012ff <trap_init_idt>:
};


static void
trap_init_idt(void)
{
  1012ff:	55                   	push   %ebp
  101300:	89 e5                	mov    %esp,%ebp
  101302:	83 ec 18             	sub    $0x18,%esp
	extern void (*tv49)(void);
	extern void (*tv50)(void);
	extern void (*tv500)(void);
	extern void (*tv501)(void);

	cprintf("initializing idt\n");
  101305:	c7 04 24 b8 3f 10 00 	movl   $0x103fb8,(%esp)
  10130c:	e8 64 20 00 00       	call   103375 <cprintf>
	SETGATE(idt[0], 0, CPU_GDT_KCODE, &tv0, 0);
  101311:	b8 e0 23 10 00       	mov    $0x1023e0,%eax
  101316:	66 a3 60 87 10 00    	mov    %ax,0x108760
  10131c:	66 c7 05 62 87 10 00 	movw   $0x8,0x108762
  101323:	08 00 
  101325:	0f b6 05 64 87 10 00 	movzbl 0x108764,%eax
  10132c:	83 e0 e0             	and    $0xffffffe0,%eax
  10132f:	a2 64 87 10 00       	mov    %al,0x108764
  101334:	0f b6 05 64 87 10 00 	movzbl 0x108764,%eax
  10133b:	83 e0 1f             	and    $0x1f,%eax
  10133e:	a2 64 87 10 00       	mov    %al,0x108764
  101343:	0f b6 05 65 87 10 00 	movzbl 0x108765,%eax
  10134a:	83 e0 f0             	and    $0xfffffff0,%eax
  10134d:	83 c8 0e             	or     $0xe,%eax
  101350:	a2 65 87 10 00       	mov    %al,0x108765
  101355:	0f b6 05 65 87 10 00 	movzbl 0x108765,%eax
  10135c:	83 e0 ef             	and    $0xffffffef,%eax
  10135f:	a2 65 87 10 00       	mov    %al,0x108765
  101364:	0f b6 05 65 87 10 00 	movzbl 0x108765,%eax
  10136b:	83 e0 9f             	and    $0xffffff9f,%eax
  10136e:	a2 65 87 10 00       	mov    %al,0x108765
  101373:	0f b6 05 65 87 10 00 	movzbl 0x108765,%eax
  10137a:	83 c8 80             	or     $0xffffff80,%eax
  10137d:	a2 65 87 10 00       	mov    %al,0x108765
  101382:	b8 e0 23 10 00       	mov    $0x1023e0,%eax
  101387:	c1 e8 10             	shr    $0x10,%eax
  10138a:	66 a3 66 87 10 00    	mov    %ax,0x108766
	SETGATE(idt[2], 0, CPU_GDT_KCODE, &tv2, 0);
  101390:	b8 ea 23 10 00       	mov    $0x1023ea,%eax
  101395:	66 a3 70 87 10 00    	mov    %ax,0x108770
  10139b:	66 c7 05 72 87 10 00 	movw   $0x8,0x108772
  1013a2:	08 00 
  1013a4:	0f b6 05 74 87 10 00 	movzbl 0x108774,%eax
  1013ab:	83 e0 e0             	and    $0xffffffe0,%eax
  1013ae:	a2 74 87 10 00       	mov    %al,0x108774
  1013b3:	0f b6 05 74 87 10 00 	movzbl 0x108774,%eax
  1013ba:	83 e0 1f             	and    $0x1f,%eax
  1013bd:	a2 74 87 10 00       	mov    %al,0x108774
  1013c2:	0f b6 05 75 87 10 00 	movzbl 0x108775,%eax
  1013c9:	83 e0 f0             	and    $0xfffffff0,%eax
  1013cc:	83 c8 0e             	or     $0xe,%eax
  1013cf:	a2 75 87 10 00       	mov    %al,0x108775
  1013d4:	0f b6 05 75 87 10 00 	movzbl 0x108775,%eax
  1013db:	83 e0 ef             	and    $0xffffffef,%eax
  1013de:	a2 75 87 10 00       	mov    %al,0x108775
  1013e3:	0f b6 05 75 87 10 00 	movzbl 0x108775,%eax
  1013ea:	83 e0 9f             	and    $0xffffff9f,%eax
  1013ed:	a2 75 87 10 00       	mov    %al,0x108775
  1013f2:	0f b6 05 75 87 10 00 	movzbl 0x108775,%eax
  1013f9:	83 c8 80             	or     $0xffffff80,%eax
  1013fc:	a2 75 87 10 00       	mov    %al,0x108775
  101401:	b8 ea 23 10 00       	mov    $0x1023ea,%eax
  101406:	c1 e8 10             	shr    $0x10,%eax
  101409:	66 a3 76 87 10 00    	mov    %ax,0x108776
	SETGATE(idt[3], 0, CPU_GDT_KCODE, &tv3, 3);
  10140f:	b8 f4 23 10 00       	mov    $0x1023f4,%eax
  101414:	66 a3 78 87 10 00    	mov    %ax,0x108778
  10141a:	66 c7 05 7a 87 10 00 	movw   $0x8,0x10877a
  101421:	08 00 
  101423:	0f b6 05 7c 87 10 00 	movzbl 0x10877c,%eax
  10142a:	83 e0 e0             	and    $0xffffffe0,%eax
  10142d:	a2 7c 87 10 00       	mov    %al,0x10877c
  101432:	0f b6 05 7c 87 10 00 	movzbl 0x10877c,%eax
  101439:	83 e0 1f             	and    $0x1f,%eax
  10143c:	a2 7c 87 10 00       	mov    %al,0x10877c
  101441:	0f b6 05 7d 87 10 00 	movzbl 0x10877d,%eax
  101448:	83 e0 f0             	and    $0xfffffff0,%eax
  10144b:	83 c8 0e             	or     $0xe,%eax
  10144e:	a2 7d 87 10 00       	mov    %al,0x10877d
  101453:	0f b6 05 7d 87 10 00 	movzbl 0x10877d,%eax
  10145a:	83 e0 ef             	and    $0xffffffef,%eax
  10145d:	a2 7d 87 10 00       	mov    %al,0x10877d
  101462:	0f b6 05 7d 87 10 00 	movzbl 0x10877d,%eax
  101469:	83 c8 60             	or     $0x60,%eax
  10146c:	a2 7d 87 10 00       	mov    %al,0x10877d
  101471:	0f b6 05 7d 87 10 00 	movzbl 0x10877d,%eax
  101478:	83 c8 80             	or     $0xffffff80,%eax
  10147b:	a2 7d 87 10 00       	mov    %al,0x10877d
  101480:	b8 f4 23 10 00       	mov    $0x1023f4,%eax
  101485:	c1 e8 10             	shr    $0x10,%eax
  101488:	66 a3 7e 87 10 00    	mov    %ax,0x10877e
	SETGATE(idt[4], 0, CPU_GDT_KCODE, &tv4, 3);
  10148e:	b8 fe 23 10 00       	mov    $0x1023fe,%eax
  101493:	66 a3 80 87 10 00    	mov    %ax,0x108780
  101499:	66 c7 05 82 87 10 00 	movw   $0x8,0x108782
  1014a0:	08 00 
  1014a2:	0f b6 05 84 87 10 00 	movzbl 0x108784,%eax
  1014a9:	83 e0 e0             	and    $0xffffffe0,%eax
  1014ac:	a2 84 87 10 00       	mov    %al,0x108784
  1014b1:	0f b6 05 84 87 10 00 	movzbl 0x108784,%eax
  1014b8:	83 e0 1f             	and    $0x1f,%eax
  1014bb:	a2 84 87 10 00       	mov    %al,0x108784
  1014c0:	0f b6 05 85 87 10 00 	movzbl 0x108785,%eax
  1014c7:	83 e0 f0             	and    $0xfffffff0,%eax
  1014ca:	83 c8 0e             	or     $0xe,%eax
  1014cd:	a2 85 87 10 00       	mov    %al,0x108785
  1014d2:	0f b6 05 85 87 10 00 	movzbl 0x108785,%eax
  1014d9:	83 e0 ef             	and    $0xffffffef,%eax
  1014dc:	a2 85 87 10 00       	mov    %al,0x108785
  1014e1:	0f b6 05 85 87 10 00 	movzbl 0x108785,%eax
  1014e8:	83 c8 60             	or     $0x60,%eax
  1014eb:	a2 85 87 10 00       	mov    %al,0x108785
  1014f0:	0f b6 05 85 87 10 00 	movzbl 0x108785,%eax
  1014f7:	83 c8 80             	or     $0xffffff80,%eax
  1014fa:	a2 85 87 10 00       	mov    %al,0x108785
  1014ff:	b8 fe 23 10 00       	mov    $0x1023fe,%eax
  101504:	c1 e8 10             	shr    $0x10,%eax
  101507:	66 a3 86 87 10 00    	mov    %ax,0x108786
	SETGATE(idt[5], 0, CPU_GDT_KCODE, &tv5, 0);
  10150d:	b8 08 24 10 00       	mov    $0x102408,%eax
  101512:	66 a3 88 87 10 00    	mov    %ax,0x108788
  101518:	66 c7 05 8a 87 10 00 	movw   $0x8,0x10878a
  10151f:	08 00 
  101521:	0f b6 05 8c 87 10 00 	movzbl 0x10878c,%eax
  101528:	83 e0 e0             	and    $0xffffffe0,%eax
  10152b:	a2 8c 87 10 00       	mov    %al,0x10878c
  101530:	0f b6 05 8c 87 10 00 	movzbl 0x10878c,%eax
  101537:	83 e0 1f             	and    $0x1f,%eax
  10153a:	a2 8c 87 10 00       	mov    %al,0x10878c
  10153f:	0f b6 05 8d 87 10 00 	movzbl 0x10878d,%eax
  101546:	83 e0 f0             	and    $0xfffffff0,%eax
  101549:	83 c8 0e             	or     $0xe,%eax
  10154c:	a2 8d 87 10 00       	mov    %al,0x10878d
  101551:	0f b6 05 8d 87 10 00 	movzbl 0x10878d,%eax
  101558:	83 e0 ef             	and    $0xffffffef,%eax
  10155b:	a2 8d 87 10 00       	mov    %al,0x10878d
  101560:	0f b6 05 8d 87 10 00 	movzbl 0x10878d,%eax
  101567:	83 e0 9f             	and    $0xffffff9f,%eax
  10156a:	a2 8d 87 10 00       	mov    %al,0x10878d
  10156f:	0f b6 05 8d 87 10 00 	movzbl 0x10878d,%eax
  101576:	83 c8 80             	or     $0xffffff80,%eax
  101579:	a2 8d 87 10 00       	mov    %al,0x10878d
  10157e:	b8 08 24 10 00       	mov    $0x102408,%eax
  101583:	c1 e8 10             	shr    $0x10,%eax
  101586:	66 a3 8e 87 10 00    	mov    %ax,0x10878e
	SETGATE(idt[6], 0, CPU_GDT_KCODE, &tv6, 0);
  10158c:	b8 12 24 10 00       	mov    $0x102412,%eax
  101591:	66 a3 90 87 10 00    	mov    %ax,0x108790
  101597:	66 c7 05 92 87 10 00 	movw   $0x8,0x108792
  10159e:	08 00 
  1015a0:	0f b6 05 94 87 10 00 	movzbl 0x108794,%eax
  1015a7:	83 e0 e0             	and    $0xffffffe0,%eax
  1015aa:	a2 94 87 10 00       	mov    %al,0x108794
  1015af:	0f b6 05 94 87 10 00 	movzbl 0x108794,%eax
  1015b6:	83 e0 1f             	and    $0x1f,%eax
  1015b9:	a2 94 87 10 00       	mov    %al,0x108794
  1015be:	0f b6 05 95 87 10 00 	movzbl 0x108795,%eax
  1015c5:	83 e0 f0             	and    $0xfffffff0,%eax
  1015c8:	83 c8 0e             	or     $0xe,%eax
  1015cb:	a2 95 87 10 00       	mov    %al,0x108795
  1015d0:	0f b6 05 95 87 10 00 	movzbl 0x108795,%eax
  1015d7:	83 e0 ef             	and    $0xffffffef,%eax
  1015da:	a2 95 87 10 00       	mov    %al,0x108795
  1015df:	0f b6 05 95 87 10 00 	movzbl 0x108795,%eax
  1015e6:	83 e0 9f             	and    $0xffffff9f,%eax
  1015e9:	a2 95 87 10 00       	mov    %al,0x108795
  1015ee:	0f b6 05 95 87 10 00 	movzbl 0x108795,%eax
  1015f5:	83 c8 80             	or     $0xffffff80,%eax
  1015f8:	a2 95 87 10 00       	mov    %al,0x108795
  1015fd:	b8 12 24 10 00       	mov    $0x102412,%eax
  101602:	c1 e8 10             	shr    $0x10,%eax
  101605:	66 a3 96 87 10 00    	mov    %ax,0x108796
	SETGATE(idt[7], 0, CPU_GDT_KCODE, &tv7, 0);
  10160b:	b8 1c 24 10 00       	mov    $0x10241c,%eax
  101610:	66 a3 98 87 10 00    	mov    %ax,0x108798
  101616:	66 c7 05 9a 87 10 00 	movw   $0x8,0x10879a
  10161d:	08 00 
  10161f:	0f b6 05 9c 87 10 00 	movzbl 0x10879c,%eax
  101626:	83 e0 e0             	and    $0xffffffe0,%eax
  101629:	a2 9c 87 10 00       	mov    %al,0x10879c
  10162e:	0f b6 05 9c 87 10 00 	movzbl 0x10879c,%eax
  101635:	83 e0 1f             	and    $0x1f,%eax
  101638:	a2 9c 87 10 00       	mov    %al,0x10879c
  10163d:	0f b6 05 9d 87 10 00 	movzbl 0x10879d,%eax
  101644:	83 e0 f0             	and    $0xfffffff0,%eax
  101647:	83 c8 0e             	or     $0xe,%eax
  10164a:	a2 9d 87 10 00       	mov    %al,0x10879d
  10164f:	0f b6 05 9d 87 10 00 	movzbl 0x10879d,%eax
  101656:	83 e0 ef             	and    $0xffffffef,%eax
  101659:	a2 9d 87 10 00       	mov    %al,0x10879d
  10165e:	0f b6 05 9d 87 10 00 	movzbl 0x10879d,%eax
  101665:	83 e0 9f             	and    $0xffffff9f,%eax
  101668:	a2 9d 87 10 00       	mov    %al,0x10879d
  10166d:	0f b6 05 9d 87 10 00 	movzbl 0x10879d,%eax
  101674:	83 c8 80             	or     $0xffffff80,%eax
  101677:	a2 9d 87 10 00       	mov    %al,0x10879d
  10167c:	b8 1c 24 10 00       	mov    $0x10241c,%eax
  101681:	c1 e8 10             	shr    $0x10,%eax
  101684:	66 a3 9e 87 10 00    	mov    %ax,0x10879e
	SETGATE(idt[8], 0, CPU_GDT_KCODE, &tv8, 0);
  10168a:	b8 26 24 10 00       	mov    $0x102426,%eax
  10168f:	66 a3 a0 87 10 00    	mov    %ax,0x1087a0
  101695:	66 c7 05 a2 87 10 00 	movw   $0x8,0x1087a2
  10169c:	08 00 
  10169e:	0f b6 05 a4 87 10 00 	movzbl 0x1087a4,%eax
  1016a5:	83 e0 e0             	and    $0xffffffe0,%eax
  1016a8:	a2 a4 87 10 00       	mov    %al,0x1087a4
  1016ad:	0f b6 05 a4 87 10 00 	movzbl 0x1087a4,%eax
  1016b4:	83 e0 1f             	and    $0x1f,%eax
  1016b7:	a2 a4 87 10 00       	mov    %al,0x1087a4
  1016bc:	0f b6 05 a5 87 10 00 	movzbl 0x1087a5,%eax
  1016c3:	83 e0 f0             	and    $0xfffffff0,%eax
  1016c6:	83 c8 0e             	or     $0xe,%eax
  1016c9:	a2 a5 87 10 00       	mov    %al,0x1087a5
  1016ce:	0f b6 05 a5 87 10 00 	movzbl 0x1087a5,%eax
  1016d5:	83 e0 ef             	and    $0xffffffef,%eax
  1016d8:	a2 a5 87 10 00       	mov    %al,0x1087a5
  1016dd:	0f b6 05 a5 87 10 00 	movzbl 0x1087a5,%eax
  1016e4:	83 e0 9f             	and    $0xffffff9f,%eax
  1016e7:	a2 a5 87 10 00       	mov    %al,0x1087a5
  1016ec:	0f b6 05 a5 87 10 00 	movzbl 0x1087a5,%eax
  1016f3:	83 c8 80             	or     $0xffffff80,%eax
  1016f6:	a2 a5 87 10 00       	mov    %al,0x1087a5
  1016fb:	b8 26 24 10 00       	mov    $0x102426,%eax
  101700:	c1 e8 10             	shr    $0x10,%eax
  101703:	66 a3 a6 87 10 00    	mov    %ax,0x1087a6
	SETGATE(idt[10], 0, CPU_GDT_KCODE, &tv10, 0);
  101709:	b8 2e 24 10 00       	mov    $0x10242e,%eax
  10170e:	66 a3 b0 87 10 00    	mov    %ax,0x1087b0
  101714:	66 c7 05 b2 87 10 00 	movw   $0x8,0x1087b2
  10171b:	08 00 
  10171d:	0f b6 05 b4 87 10 00 	movzbl 0x1087b4,%eax
  101724:	83 e0 e0             	and    $0xffffffe0,%eax
  101727:	a2 b4 87 10 00       	mov    %al,0x1087b4
  10172c:	0f b6 05 b4 87 10 00 	movzbl 0x1087b4,%eax
  101733:	83 e0 1f             	and    $0x1f,%eax
  101736:	a2 b4 87 10 00       	mov    %al,0x1087b4
  10173b:	0f b6 05 b5 87 10 00 	movzbl 0x1087b5,%eax
  101742:	83 e0 f0             	and    $0xfffffff0,%eax
  101745:	83 c8 0e             	or     $0xe,%eax
  101748:	a2 b5 87 10 00       	mov    %al,0x1087b5
  10174d:	0f b6 05 b5 87 10 00 	movzbl 0x1087b5,%eax
  101754:	83 e0 ef             	and    $0xffffffef,%eax
  101757:	a2 b5 87 10 00       	mov    %al,0x1087b5
  10175c:	0f b6 05 b5 87 10 00 	movzbl 0x1087b5,%eax
  101763:	83 e0 9f             	and    $0xffffff9f,%eax
  101766:	a2 b5 87 10 00       	mov    %al,0x1087b5
  10176b:	0f b6 05 b5 87 10 00 	movzbl 0x1087b5,%eax
  101772:	83 c8 80             	or     $0xffffff80,%eax
  101775:	a2 b5 87 10 00       	mov    %al,0x1087b5
  10177a:	b8 2e 24 10 00       	mov    $0x10242e,%eax
  10177f:	c1 e8 10             	shr    $0x10,%eax
  101782:	66 a3 b6 87 10 00    	mov    %ax,0x1087b6
	SETGATE(idt[11], 0, CPU_GDT_KCODE, &tv11, 0);
  101788:	b8 36 24 10 00       	mov    $0x102436,%eax
  10178d:	66 a3 b8 87 10 00    	mov    %ax,0x1087b8
  101793:	66 c7 05 ba 87 10 00 	movw   $0x8,0x1087ba
  10179a:	08 00 
  10179c:	0f b6 05 bc 87 10 00 	movzbl 0x1087bc,%eax
  1017a3:	83 e0 e0             	and    $0xffffffe0,%eax
  1017a6:	a2 bc 87 10 00       	mov    %al,0x1087bc
  1017ab:	0f b6 05 bc 87 10 00 	movzbl 0x1087bc,%eax
  1017b2:	83 e0 1f             	and    $0x1f,%eax
  1017b5:	a2 bc 87 10 00       	mov    %al,0x1087bc
  1017ba:	0f b6 05 bd 87 10 00 	movzbl 0x1087bd,%eax
  1017c1:	83 e0 f0             	and    $0xfffffff0,%eax
  1017c4:	83 c8 0e             	or     $0xe,%eax
  1017c7:	a2 bd 87 10 00       	mov    %al,0x1087bd
  1017cc:	0f b6 05 bd 87 10 00 	movzbl 0x1087bd,%eax
  1017d3:	83 e0 ef             	and    $0xffffffef,%eax
  1017d6:	a2 bd 87 10 00       	mov    %al,0x1087bd
  1017db:	0f b6 05 bd 87 10 00 	movzbl 0x1087bd,%eax
  1017e2:	83 e0 9f             	and    $0xffffff9f,%eax
  1017e5:	a2 bd 87 10 00       	mov    %al,0x1087bd
  1017ea:	0f b6 05 bd 87 10 00 	movzbl 0x1087bd,%eax
  1017f1:	83 c8 80             	or     $0xffffff80,%eax
  1017f4:	a2 bd 87 10 00       	mov    %al,0x1087bd
  1017f9:	b8 36 24 10 00       	mov    $0x102436,%eax
  1017fe:	c1 e8 10             	shr    $0x10,%eax
  101801:	66 a3 be 87 10 00    	mov    %ax,0x1087be
	SETGATE(idt[12], 0, CPU_GDT_KCODE, &tv12, 0);
  101807:	b8 3e 24 10 00       	mov    $0x10243e,%eax
  10180c:	66 a3 c0 87 10 00    	mov    %ax,0x1087c0
  101812:	66 c7 05 c2 87 10 00 	movw   $0x8,0x1087c2
  101819:	08 00 
  10181b:	0f b6 05 c4 87 10 00 	movzbl 0x1087c4,%eax
  101822:	83 e0 e0             	and    $0xffffffe0,%eax
  101825:	a2 c4 87 10 00       	mov    %al,0x1087c4
  10182a:	0f b6 05 c4 87 10 00 	movzbl 0x1087c4,%eax
  101831:	83 e0 1f             	and    $0x1f,%eax
  101834:	a2 c4 87 10 00       	mov    %al,0x1087c4
  101839:	0f b6 05 c5 87 10 00 	movzbl 0x1087c5,%eax
  101840:	83 e0 f0             	and    $0xfffffff0,%eax
  101843:	83 c8 0e             	or     $0xe,%eax
  101846:	a2 c5 87 10 00       	mov    %al,0x1087c5
  10184b:	0f b6 05 c5 87 10 00 	movzbl 0x1087c5,%eax
  101852:	83 e0 ef             	and    $0xffffffef,%eax
  101855:	a2 c5 87 10 00       	mov    %al,0x1087c5
  10185a:	0f b6 05 c5 87 10 00 	movzbl 0x1087c5,%eax
  101861:	83 e0 9f             	and    $0xffffff9f,%eax
  101864:	a2 c5 87 10 00       	mov    %al,0x1087c5
  101869:	0f b6 05 c5 87 10 00 	movzbl 0x1087c5,%eax
  101870:	83 c8 80             	or     $0xffffff80,%eax
  101873:	a2 c5 87 10 00       	mov    %al,0x1087c5
  101878:	b8 3e 24 10 00       	mov    $0x10243e,%eax
  10187d:	c1 e8 10             	shr    $0x10,%eax
  101880:	66 a3 c6 87 10 00    	mov    %ax,0x1087c6
	SETGATE(idt[13], 0, CPU_GDT_KCODE, &tv13, 0);
  101886:	b8 46 24 10 00       	mov    $0x102446,%eax
  10188b:	66 a3 c8 87 10 00    	mov    %ax,0x1087c8
  101891:	66 c7 05 ca 87 10 00 	movw   $0x8,0x1087ca
  101898:	08 00 
  10189a:	0f b6 05 cc 87 10 00 	movzbl 0x1087cc,%eax
  1018a1:	83 e0 e0             	and    $0xffffffe0,%eax
  1018a4:	a2 cc 87 10 00       	mov    %al,0x1087cc
  1018a9:	0f b6 05 cc 87 10 00 	movzbl 0x1087cc,%eax
  1018b0:	83 e0 1f             	and    $0x1f,%eax
  1018b3:	a2 cc 87 10 00       	mov    %al,0x1087cc
  1018b8:	0f b6 05 cd 87 10 00 	movzbl 0x1087cd,%eax
  1018bf:	83 e0 f0             	and    $0xfffffff0,%eax
  1018c2:	83 c8 0e             	or     $0xe,%eax
  1018c5:	a2 cd 87 10 00       	mov    %al,0x1087cd
  1018ca:	0f b6 05 cd 87 10 00 	movzbl 0x1087cd,%eax
  1018d1:	83 e0 ef             	and    $0xffffffef,%eax
  1018d4:	a2 cd 87 10 00       	mov    %al,0x1087cd
  1018d9:	0f b6 05 cd 87 10 00 	movzbl 0x1087cd,%eax
  1018e0:	83 e0 9f             	and    $0xffffff9f,%eax
  1018e3:	a2 cd 87 10 00       	mov    %al,0x1087cd
  1018e8:	0f b6 05 cd 87 10 00 	movzbl 0x1087cd,%eax
  1018ef:	83 c8 80             	or     $0xffffff80,%eax
  1018f2:	a2 cd 87 10 00       	mov    %al,0x1087cd
  1018f7:	b8 46 24 10 00       	mov    $0x102446,%eax
  1018fc:	c1 e8 10             	shr    $0x10,%eax
  1018ff:	66 a3 ce 87 10 00    	mov    %ax,0x1087ce
	SETGATE(idt[14], 0, CPU_GDT_KCODE, &tv14, 0);
  101905:	b8 4e 24 10 00       	mov    $0x10244e,%eax
  10190a:	66 a3 d0 87 10 00    	mov    %ax,0x1087d0
  101910:	66 c7 05 d2 87 10 00 	movw   $0x8,0x1087d2
  101917:	08 00 
  101919:	0f b6 05 d4 87 10 00 	movzbl 0x1087d4,%eax
  101920:	83 e0 e0             	and    $0xffffffe0,%eax
  101923:	a2 d4 87 10 00       	mov    %al,0x1087d4
  101928:	0f b6 05 d4 87 10 00 	movzbl 0x1087d4,%eax
  10192f:	83 e0 1f             	and    $0x1f,%eax
  101932:	a2 d4 87 10 00       	mov    %al,0x1087d4
  101937:	0f b6 05 d5 87 10 00 	movzbl 0x1087d5,%eax
  10193e:	83 e0 f0             	and    $0xfffffff0,%eax
  101941:	83 c8 0e             	or     $0xe,%eax
  101944:	a2 d5 87 10 00       	mov    %al,0x1087d5
  101949:	0f b6 05 d5 87 10 00 	movzbl 0x1087d5,%eax
  101950:	83 e0 ef             	and    $0xffffffef,%eax
  101953:	a2 d5 87 10 00       	mov    %al,0x1087d5
  101958:	0f b6 05 d5 87 10 00 	movzbl 0x1087d5,%eax
  10195f:	83 e0 9f             	and    $0xffffff9f,%eax
  101962:	a2 d5 87 10 00       	mov    %al,0x1087d5
  101967:	0f b6 05 d5 87 10 00 	movzbl 0x1087d5,%eax
  10196e:	83 c8 80             	or     $0xffffff80,%eax
  101971:	a2 d5 87 10 00       	mov    %al,0x1087d5
  101976:	b8 4e 24 10 00       	mov    $0x10244e,%eax
  10197b:	c1 e8 10             	shr    $0x10,%eax
  10197e:	66 a3 d6 87 10 00    	mov    %ax,0x1087d6
	SETGATE(idt[16], 0, CPU_GDT_KCODE, &tv16, 0);
  101984:	b8 56 24 10 00       	mov    $0x102456,%eax
  101989:	66 a3 e0 87 10 00    	mov    %ax,0x1087e0
  10198f:	66 c7 05 e2 87 10 00 	movw   $0x8,0x1087e2
  101996:	08 00 
  101998:	0f b6 05 e4 87 10 00 	movzbl 0x1087e4,%eax
  10199f:	83 e0 e0             	and    $0xffffffe0,%eax
  1019a2:	a2 e4 87 10 00       	mov    %al,0x1087e4
  1019a7:	0f b6 05 e4 87 10 00 	movzbl 0x1087e4,%eax
  1019ae:	83 e0 1f             	and    $0x1f,%eax
  1019b1:	a2 e4 87 10 00       	mov    %al,0x1087e4
  1019b6:	0f b6 05 e5 87 10 00 	movzbl 0x1087e5,%eax
  1019bd:	83 e0 f0             	and    $0xfffffff0,%eax
  1019c0:	83 c8 0e             	or     $0xe,%eax
  1019c3:	a2 e5 87 10 00       	mov    %al,0x1087e5
  1019c8:	0f b6 05 e5 87 10 00 	movzbl 0x1087e5,%eax
  1019cf:	83 e0 ef             	and    $0xffffffef,%eax
  1019d2:	a2 e5 87 10 00       	mov    %al,0x1087e5
  1019d7:	0f b6 05 e5 87 10 00 	movzbl 0x1087e5,%eax
  1019de:	83 e0 9f             	and    $0xffffff9f,%eax
  1019e1:	a2 e5 87 10 00       	mov    %al,0x1087e5
  1019e6:	0f b6 05 e5 87 10 00 	movzbl 0x1087e5,%eax
  1019ed:	83 c8 80             	or     $0xffffff80,%eax
  1019f0:	a2 e5 87 10 00       	mov    %al,0x1087e5
  1019f5:	b8 56 24 10 00       	mov    $0x102456,%eax
  1019fa:	c1 e8 10             	shr    $0x10,%eax
  1019fd:	66 a3 e6 87 10 00    	mov    %ax,0x1087e6
	SETGATE(idt[17], 0, CPU_GDT_KCODE, &tv17, 0);
  101a03:	b8 60 24 10 00       	mov    $0x102460,%eax
  101a08:	66 a3 e8 87 10 00    	mov    %ax,0x1087e8
  101a0e:	66 c7 05 ea 87 10 00 	movw   $0x8,0x1087ea
  101a15:	08 00 
  101a17:	0f b6 05 ec 87 10 00 	movzbl 0x1087ec,%eax
  101a1e:	83 e0 e0             	and    $0xffffffe0,%eax
  101a21:	a2 ec 87 10 00       	mov    %al,0x1087ec
  101a26:	0f b6 05 ec 87 10 00 	movzbl 0x1087ec,%eax
  101a2d:	83 e0 1f             	and    $0x1f,%eax
  101a30:	a2 ec 87 10 00       	mov    %al,0x1087ec
  101a35:	0f b6 05 ed 87 10 00 	movzbl 0x1087ed,%eax
  101a3c:	83 e0 f0             	and    $0xfffffff0,%eax
  101a3f:	83 c8 0e             	or     $0xe,%eax
  101a42:	a2 ed 87 10 00       	mov    %al,0x1087ed
  101a47:	0f b6 05 ed 87 10 00 	movzbl 0x1087ed,%eax
  101a4e:	83 e0 ef             	and    $0xffffffef,%eax
  101a51:	a2 ed 87 10 00       	mov    %al,0x1087ed
  101a56:	0f b6 05 ed 87 10 00 	movzbl 0x1087ed,%eax
  101a5d:	83 e0 9f             	and    $0xffffff9f,%eax
  101a60:	a2 ed 87 10 00       	mov    %al,0x1087ed
  101a65:	0f b6 05 ed 87 10 00 	movzbl 0x1087ed,%eax
  101a6c:	83 c8 80             	or     $0xffffff80,%eax
  101a6f:	a2 ed 87 10 00       	mov    %al,0x1087ed
  101a74:	b8 60 24 10 00       	mov    $0x102460,%eax
  101a79:	c1 e8 10             	shr    $0x10,%eax
  101a7c:	66 a3 ee 87 10 00    	mov    %ax,0x1087ee
	SETGATE(idt[18], 0, CPU_GDT_KCODE, &tv18, 0);
  101a82:	b8 68 24 10 00       	mov    $0x102468,%eax
  101a87:	66 a3 f0 87 10 00    	mov    %ax,0x1087f0
  101a8d:	66 c7 05 f2 87 10 00 	movw   $0x8,0x1087f2
  101a94:	08 00 
  101a96:	0f b6 05 f4 87 10 00 	movzbl 0x1087f4,%eax
  101a9d:	83 e0 e0             	and    $0xffffffe0,%eax
  101aa0:	a2 f4 87 10 00       	mov    %al,0x1087f4
  101aa5:	0f b6 05 f4 87 10 00 	movzbl 0x1087f4,%eax
  101aac:	83 e0 1f             	and    $0x1f,%eax
  101aaf:	a2 f4 87 10 00       	mov    %al,0x1087f4
  101ab4:	0f b6 05 f5 87 10 00 	movzbl 0x1087f5,%eax
  101abb:	83 e0 f0             	and    $0xfffffff0,%eax
  101abe:	83 c8 0e             	or     $0xe,%eax
  101ac1:	a2 f5 87 10 00       	mov    %al,0x1087f5
  101ac6:	0f b6 05 f5 87 10 00 	movzbl 0x1087f5,%eax
  101acd:	83 e0 ef             	and    $0xffffffef,%eax
  101ad0:	a2 f5 87 10 00       	mov    %al,0x1087f5
  101ad5:	0f b6 05 f5 87 10 00 	movzbl 0x1087f5,%eax
  101adc:	83 e0 9f             	and    $0xffffff9f,%eax
  101adf:	a2 f5 87 10 00       	mov    %al,0x1087f5
  101ae4:	0f b6 05 f5 87 10 00 	movzbl 0x1087f5,%eax
  101aeb:	83 c8 80             	or     $0xffffff80,%eax
  101aee:	a2 f5 87 10 00       	mov    %al,0x1087f5
  101af3:	b8 68 24 10 00       	mov    $0x102468,%eax
  101af8:	c1 e8 10             	shr    $0x10,%eax
  101afb:	66 a3 f6 87 10 00    	mov    %ax,0x1087f6
	SETGATE(idt[19], 0, CPU_GDT_KCODE, &tv19, 0);
  101b01:	b8 72 24 10 00       	mov    $0x102472,%eax
  101b06:	66 a3 f8 87 10 00    	mov    %ax,0x1087f8
  101b0c:	66 c7 05 fa 87 10 00 	movw   $0x8,0x1087fa
  101b13:	08 00 
  101b15:	0f b6 05 fc 87 10 00 	movzbl 0x1087fc,%eax
  101b1c:	83 e0 e0             	and    $0xffffffe0,%eax
  101b1f:	a2 fc 87 10 00       	mov    %al,0x1087fc
  101b24:	0f b6 05 fc 87 10 00 	movzbl 0x1087fc,%eax
  101b2b:	83 e0 1f             	and    $0x1f,%eax
  101b2e:	a2 fc 87 10 00       	mov    %al,0x1087fc
  101b33:	0f b6 05 fd 87 10 00 	movzbl 0x1087fd,%eax
  101b3a:	83 e0 f0             	and    $0xfffffff0,%eax
  101b3d:	83 c8 0e             	or     $0xe,%eax
  101b40:	a2 fd 87 10 00       	mov    %al,0x1087fd
  101b45:	0f b6 05 fd 87 10 00 	movzbl 0x1087fd,%eax
  101b4c:	83 e0 ef             	and    $0xffffffef,%eax
  101b4f:	a2 fd 87 10 00       	mov    %al,0x1087fd
  101b54:	0f b6 05 fd 87 10 00 	movzbl 0x1087fd,%eax
  101b5b:	83 e0 9f             	and    $0xffffff9f,%eax
  101b5e:	a2 fd 87 10 00       	mov    %al,0x1087fd
  101b63:	0f b6 05 fd 87 10 00 	movzbl 0x1087fd,%eax
  101b6a:	83 c8 80             	or     $0xffffff80,%eax
  101b6d:	a2 fd 87 10 00       	mov    %al,0x1087fd
  101b72:	b8 72 24 10 00       	mov    $0x102472,%eax
  101b77:	c1 e8 10             	shr    $0x10,%eax
  101b7a:	66 a3 fe 87 10 00    	mov    %ax,0x1087fe
	SETGATE(idt[30], 0, CPU_GDT_KCODE, &tv30, 0);
  101b80:	b8 7c 24 10 00       	mov    $0x10247c,%eax
  101b85:	66 a3 50 88 10 00    	mov    %ax,0x108850
  101b8b:	66 c7 05 52 88 10 00 	movw   $0x8,0x108852
  101b92:	08 00 
  101b94:	0f b6 05 54 88 10 00 	movzbl 0x108854,%eax
  101b9b:	83 e0 e0             	and    $0xffffffe0,%eax
  101b9e:	a2 54 88 10 00       	mov    %al,0x108854
  101ba3:	0f b6 05 54 88 10 00 	movzbl 0x108854,%eax
  101baa:	83 e0 1f             	and    $0x1f,%eax
  101bad:	a2 54 88 10 00       	mov    %al,0x108854
  101bb2:	0f b6 05 55 88 10 00 	movzbl 0x108855,%eax
  101bb9:	83 e0 f0             	and    $0xfffffff0,%eax
  101bbc:	83 c8 0e             	or     $0xe,%eax
  101bbf:	a2 55 88 10 00       	mov    %al,0x108855
  101bc4:	0f b6 05 55 88 10 00 	movzbl 0x108855,%eax
  101bcb:	83 e0 ef             	and    $0xffffffef,%eax
  101bce:	a2 55 88 10 00       	mov    %al,0x108855
  101bd3:	0f b6 05 55 88 10 00 	movzbl 0x108855,%eax
  101bda:	83 e0 9f             	and    $0xffffff9f,%eax
  101bdd:	a2 55 88 10 00       	mov    %al,0x108855
  101be2:	0f b6 05 55 88 10 00 	movzbl 0x108855,%eax
  101be9:	83 c8 80             	or     $0xffffff80,%eax
  101bec:	a2 55 88 10 00       	mov    %al,0x108855
  101bf1:	b8 7c 24 10 00       	mov    $0x10247c,%eax
  101bf6:	c1 e8 10             	shr    $0x10,%eax
  101bf9:	66 a3 56 88 10 00    	mov    %ax,0x108856
	SETGATE(idt[32], 0, CPU_GDT_KCODE, &tv32, 0);
  101bff:	b8 86 24 10 00       	mov    $0x102486,%eax
  101c04:	66 a3 60 88 10 00    	mov    %ax,0x108860
  101c0a:	66 c7 05 62 88 10 00 	movw   $0x8,0x108862
  101c11:	08 00 
  101c13:	0f b6 05 64 88 10 00 	movzbl 0x108864,%eax
  101c1a:	83 e0 e0             	and    $0xffffffe0,%eax
  101c1d:	a2 64 88 10 00       	mov    %al,0x108864
  101c22:	0f b6 05 64 88 10 00 	movzbl 0x108864,%eax
  101c29:	83 e0 1f             	and    $0x1f,%eax
  101c2c:	a2 64 88 10 00       	mov    %al,0x108864
  101c31:	0f b6 05 65 88 10 00 	movzbl 0x108865,%eax
  101c38:	83 e0 f0             	and    $0xfffffff0,%eax
  101c3b:	83 c8 0e             	or     $0xe,%eax
  101c3e:	a2 65 88 10 00       	mov    %al,0x108865
  101c43:	0f b6 05 65 88 10 00 	movzbl 0x108865,%eax
  101c4a:	83 e0 ef             	and    $0xffffffef,%eax
  101c4d:	a2 65 88 10 00       	mov    %al,0x108865
  101c52:	0f b6 05 65 88 10 00 	movzbl 0x108865,%eax
  101c59:	83 e0 9f             	and    $0xffffff9f,%eax
  101c5c:	a2 65 88 10 00       	mov    %al,0x108865
  101c61:	0f b6 05 65 88 10 00 	movzbl 0x108865,%eax
  101c68:	83 c8 80             	or     $0xffffff80,%eax
  101c6b:	a2 65 88 10 00       	mov    %al,0x108865
  101c70:	b8 86 24 10 00       	mov    $0x102486,%eax
  101c75:	c1 e8 10             	shr    $0x10,%eax
  101c78:	66 a3 66 88 10 00    	mov    %ax,0x108866
	SETGATE(idt[48], 0, CPU_GDT_KCODE, &tv48, 3);
  101c7e:	b8 90 24 10 00       	mov    $0x102490,%eax
  101c83:	66 a3 e0 88 10 00    	mov    %ax,0x1088e0
  101c89:	66 c7 05 e2 88 10 00 	movw   $0x8,0x1088e2
  101c90:	08 00 
  101c92:	0f b6 05 e4 88 10 00 	movzbl 0x1088e4,%eax
  101c99:	83 e0 e0             	and    $0xffffffe0,%eax
  101c9c:	a2 e4 88 10 00       	mov    %al,0x1088e4
  101ca1:	0f b6 05 e4 88 10 00 	movzbl 0x1088e4,%eax
  101ca8:	83 e0 1f             	and    $0x1f,%eax
  101cab:	a2 e4 88 10 00       	mov    %al,0x1088e4
  101cb0:	0f b6 05 e5 88 10 00 	movzbl 0x1088e5,%eax
  101cb7:	83 e0 f0             	and    $0xfffffff0,%eax
  101cba:	83 c8 0e             	or     $0xe,%eax
  101cbd:	a2 e5 88 10 00       	mov    %al,0x1088e5
  101cc2:	0f b6 05 e5 88 10 00 	movzbl 0x1088e5,%eax
  101cc9:	83 e0 ef             	and    $0xffffffef,%eax
  101ccc:	a2 e5 88 10 00       	mov    %al,0x1088e5
  101cd1:	0f b6 05 e5 88 10 00 	movzbl 0x1088e5,%eax
  101cd8:	83 c8 60             	or     $0x60,%eax
  101cdb:	a2 e5 88 10 00       	mov    %al,0x1088e5
  101ce0:	0f b6 05 e5 88 10 00 	movzbl 0x1088e5,%eax
  101ce7:	83 c8 80             	or     $0xffffff80,%eax
  101cea:	a2 e5 88 10 00       	mov    %al,0x1088e5
  101cef:	b8 90 24 10 00       	mov    $0x102490,%eax
  101cf4:	c1 e8 10             	shr    $0x10,%eax
  101cf7:	66 a3 e6 88 10 00    	mov    %ax,0x1088e6
	SETGATE(idt[49], 0, CPU_GDT_KCODE, &tv49, 0);
  101cfd:	b8 9a 24 10 00       	mov    $0x10249a,%eax
  101d02:	66 a3 e8 88 10 00    	mov    %ax,0x1088e8
  101d08:	66 c7 05 ea 88 10 00 	movw   $0x8,0x1088ea
  101d0f:	08 00 
  101d11:	0f b6 05 ec 88 10 00 	movzbl 0x1088ec,%eax
  101d18:	83 e0 e0             	and    $0xffffffe0,%eax
  101d1b:	a2 ec 88 10 00       	mov    %al,0x1088ec
  101d20:	0f b6 05 ec 88 10 00 	movzbl 0x1088ec,%eax
  101d27:	83 e0 1f             	and    $0x1f,%eax
  101d2a:	a2 ec 88 10 00       	mov    %al,0x1088ec
  101d2f:	0f b6 05 ed 88 10 00 	movzbl 0x1088ed,%eax
  101d36:	83 e0 f0             	and    $0xfffffff0,%eax
  101d39:	83 c8 0e             	or     $0xe,%eax
  101d3c:	a2 ed 88 10 00       	mov    %al,0x1088ed
  101d41:	0f b6 05 ed 88 10 00 	movzbl 0x1088ed,%eax
  101d48:	83 e0 ef             	and    $0xffffffef,%eax
  101d4b:	a2 ed 88 10 00       	mov    %al,0x1088ed
  101d50:	0f b6 05 ed 88 10 00 	movzbl 0x1088ed,%eax
  101d57:	83 e0 9f             	and    $0xffffff9f,%eax
  101d5a:	a2 ed 88 10 00       	mov    %al,0x1088ed
  101d5f:	0f b6 05 ed 88 10 00 	movzbl 0x1088ed,%eax
  101d66:	83 c8 80             	or     $0xffffff80,%eax
  101d69:	a2 ed 88 10 00       	mov    %al,0x1088ed
  101d6e:	b8 9a 24 10 00       	mov    $0x10249a,%eax
  101d73:	c1 e8 10             	shr    $0x10,%eax
  101d76:	66 a3 ee 88 10 00    	mov    %ax,0x1088ee
	SETGATE(idt[50], 0, CPU_GDT_KCODE, &tv50, 0);
  101d7c:	b8 a4 24 10 00       	mov    $0x1024a4,%eax
  101d81:	66 a3 f0 88 10 00    	mov    %ax,0x1088f0
  101d87:	66 c7 05 f2 88 10 00 	movw   $0x8,0x1088f2
  101d8e:	08 00 
  101d90:	0f b6 05 f4 88 10 00 	movzbl 0x1088f4,%eax
  101d97:	83 e0 e0             	and    $0xffffffe0,%eax
  101d9a:	a2 f4 88 10 00       	mov    %al,0x1088f4
  101d9f:	0f b6 05 f4 88 10 00 	movzbl 0x1088f4,%eax
  101da6:	83 e0 1f             	and    $0x1f,%eax
  101da9:	a2 f4 88 10 00       	mov    %al,0x1088f4
  101dae:	0f b6 05 f5 88 10 00 	movzbl 0x1088f5,%eax
  101db5:	83 e0 f0             	and    $0xfffffff0,%eax
  101db8:	83 c8 0e             	or     $0xe,%eax
  101dbb:	a2 f5 88 10 00       	mov    %al,0x1088f5
  101dc0:	0f b6 05 f5 88 10 00 	movzbl 0x1088f5,%eax
  101dc7:	83 e0 ef             	and    $0xffffffef,%eax
  101dca:	a2 f5 88 10 00       	mov    %al,0x1088f5
  101dcf:	0f b6 05 f5 88 10 00 	movzbl 0x1088f5,%eax
  101dd6:	83 e0 9f             	and    $0xffffff9f,%eax
  101dd9:	a2 f5 88 10 00       	mov    %al,0x1088f5
  101dde:	0f b6 05 f5 88 10 00 	movzbl 0x1088f5,%eax
  101de5:	83 c8 80             	or     $0xffffff80,%eax
  101de8:	a2 f5 88 10 00       	mov    %al,0x1088f5
  101ded:	b8 a4 24 10 00       	mov    $0x1024a4,%eax
  101df2:	c1 e8 10             	shr    $0x10,%eax
  101df5:	66 a3 f6 88 10 00    	mov    %ax,0x1088f6
}
  101dfb:	c9                   	leave  
  101dfc:	c3                   	ret    

00101dfd <trap_init>:

void
trap_init(void)
{
  101dfd:	55                   	push   %ebp
  101dfe:	89 e5                	mov    %esp,%ebp
  101e00:	83 ec 08             	sub    $0x8,%esp
	// The first time we get called on the bootstrap processor,
	// initialize the IDT.  Other CPUs will share the same IDT.
	if (cpu_onboot())
  101e03:	e8 df f4 ff ff       	call   1012e7 <cpu_onboot>
  101e08:	85 c0                	test   %eax,%eax
  101e0a:	74 05                	je     101e11 <trap_init+0x14>
		trap_init_idt();
  101e0c:	e8 ee f4 ff ff       	call   1012ff <trap_init_idt>

	// Load the IDT into this processor's IDT register.
	asm volatile("lidt %0" : : "m" (idt_pd));
  101e11:	0f 01 1d 00 70 10 00 	lidtl  0x107000

	// Check for the correct IDT and trap handler operation.
	if (cpu_onboot())
  101e18:	e8 ca f4 ff ff       	call   1012e7 <cpu_onboot>
  101e1d:	85 c0                	test   %eax,%eax
  101e1f:	74 05                	je     101e26 <trap_init+0x29>
		trap_check_kernel();
  101e21:	e8 8d 02 00 00       	call   1020b3 <trap_check_kernel>
}
  101e26:	c9                   	leave  
  101e27:	c3                   	ret    

00101e28 <trap_name>:

const char *trap_name(int trapno)
{
  101e28:	55                   	push   %ebp
  101e29:	89 e5                	mov    %esp,%ebp
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
  101e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  101e2e:	83 f8 13             	cmp    $0x13,%eax
  101e31:	77 0c                	ja     101e3f <trap_name+0x17>
		return excnames[trapno];
  101e33:	8b 45 08             	mov    0x8(%ebp),%eax
  101e36:	8b 04 85 80 43 10 00 	mov    0x104380(,%eax,4),%eax
  101e3d:	eb 05                	jmp    101e44 <trap_name+0x1c>
	return "(unknown trap)";
  101e3f:	b8 ca 3f 10 00       	mov    $0x103fca,%eax
}
  101e44:	5d                   	pop    %ebp
  101e45:	c3                   	ret    

00101e46 <trap_print_regs>:

void
trap_print_regs(pushregs *regs)
{
  101e46:	55                   	push   %ebp
  101e47:	89 e5                	mov    %esp,%ebp
  101e49:	83 ec 18             	sub    $0x18,%esp
	cprintf("  edi  0x%08x\n", regs->edi);
  101e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  101e4f:	8b 00                	mov    (%eax),%eax
  101e51:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e55:	c7 04 24 d9 3f 10 00 	movl   $0x103fd9,(%esp)
  101e5c:	e8 14 15 00 00       	call   103375 <cprintf>
	cprintf("  esi  0x%08x\n", regs->esi);
  101e61:	8b 45 08             	mov    0x8(%ebp),%eax
  101e64:	8b 40 04             	mov    0x4(%eax),%eax
  101e67:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e6b:	c7 04 24 e8 3f 10 00 	movl   $0x103fe8,(%esp)
  101e72:	e8 fe 14 00 00       	call   103375 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->ebp);
  101e77:	8b 45 08             	mov    0x8(%ebp),%eax
  101e7a:	8b 40 08             	mov    0x8(%eax),%eax
  101e7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e81:	c7 04 24 f7 3f 10 00 	movl   $0x103ff7,(%esp)
  101e88:	e8 e8 14 00 00       	call   103375 <cprintf>
//	cprintf("  oesp 0x%08x\n", regs->oesp);	don't print - useless
	cprintf("  ebx  0x%08x\n", regs->ebx);
  101e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  101e90:	8b 40 10             	mov    0x10(%eax),%eax
  101e93:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e97:	c7 04 24 06 40 10 00 	movl   $0x104006,(%esp)
  101e9e:	e8 d2 14 00 00       	call   103375 <cprintf>
	cprintf("  edx  0x%08x\n", regs->edx);
  101ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  101ea6:	8b 40 14             	mov    0x14(%eax),%eax
  101ea9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ead:	c7 04 24 15 40 10 00 	movl   $0x104015,(%esp)
  101eb4:	e8 bc 14 00 00       	call   103375 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->ecx);
  101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  101ebc:	8b 40 18             	mov    0x18(%eax),%eax
  101ebf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ec3:	c7 04 24 24 40 10 00 	movl   $0x104024,(%esp)
  101eca:	e8 a6 14 00 00       	call   103375 <cprintf>
	cprintf("  eax  0x%08x\n", regs->eax);
  101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  101ed2:	8b 40 1c             	mov    0x1c(%eax),%eax
  101ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ed9:	c7 04 24 33 40 10 00 	movl   $0x104033,(%esp)
  101ee0:	e8 90 14 00 00       	call   103375 <cprintf>
}
  101ee5:	c9                   	leave  
  101ee6:	c3                   	ret    

00101ee7 <trap_print>:

void
trap_print(trapframe *tf)
{
  101ee7:	55                   	push   %ebp
  101ee8:	89 e5                	mov    %esp,%ebp
  101eea:	83 ec 18             	sub    $0x18,%esp
	cprintf("TRAP frame at %p\n", tf);
  101eed:	8b 45 08             	mov    0x8(%ebp),%eax
  101ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ef4:	c7 04 24 42 40 10 00 	movl   $0x104042,(%esp)
  101efb:	e8 75 14 00 00       	call   103375 <cprintf>
	trap_print_regs(&tf->regs);
  101f00:	8b 45 08             	mov    0x8(%ebp),%eax
  101f03:	89 04 24             	mov    %eax,(%esp)
  101f06:	e8 3b ff ff ff       	call   101e46 <trap_print_regs>
	cprintf("  es   0x----%04x\n", tf->es);
  101f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  101f0e:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101f12:	0f b7 c0             	movzwl %ax,%eax
  101f15:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f19:	c7 04 24 54 40 10 00 	movl   $0x104054,(%esp)
  101f20:	e8 50 14 00 00       	call   103375 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->ds);
  101f25:	8b 45 08             	mov    0x8(%ebp),%eax
  101f28:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101f2c:	0f b7 c0             	movzwl %ax,%eax
  101f2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f33:	c7 04 24 67 40 10 00 	movl   $0x104067,(%esp)
  101f3a:	e8 36 14 00 00       	call   103375 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->trapno, trap_name(tf->trapno));
  101f3f:	8b 45 08             	mov    0x8(%ebp),%eax
  101f42:	8b 40 30             	mov    0x30(%eax),%eax
  101f45:	89 04 24             	mov    %eax,(%esp)
  101f48:	e8 db fe ff ff       	call   101e28 <trap_name>
  101f4d:	8b 55 08             	mov    0x8(%ebp),%edx
  101f50:	8b 52 30             	mov    0x30(%edx),%edx
  101f53:	89 44 24 08          	mov    %eax,0x8(%esp)
  101f57:	89 54 24 04          	mov    %edx,0x4(%esp)
  101f5b:	c7 04 24 7a 40 10 00 	movl   $0x10407a,(%esp)
  101f62:	e8 0e 14 00 00       	call   103375 <cprintf>
	cprintf("  err  0x%08x\n", tf->err);
  101f67:	8b 45 08             	mov    0x8(%ebp),%eax
  101f6a:	8b 40 34             	mov    0x34(%eax),%eax
  101f6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f71:	c7 04 24 8c 40 10 00 	movl   $0x10408c,(%esp)
  101f78:	e8 f8 13 00 00       	call   103375 <cprintf>
	cprintf("  eip  0x%08x\n", tf->eip);
  101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
  101f80:	8b 40 38             	mov    0x38(%eax),%eax
  101f83:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f87:	c7 04 24 9b 40 10 00 	movl   $0x10409b,(%esp)
  101f8e:	e8 e2 13 00 00       	call   103375 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->cs);
  101f93:	8b 45 08             	mov    0x8(%ebp),%eax
  101f96:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f9a:	0f b7 c0             	movzwl %ax,%eax
  101f9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101fa1:	c7 04 24 aa 40 10 00 	movl   $0x1040aa,(%esp)
  101fa8:	e8 c8 13 00 00       	call   103375 <cprintf>
	cprintf("  flag 0x%08x\n", tf->eflags);
  101fad:	8b 45 08             	mov    0x8(%ebp),%eax
  101fb0:	8b 40 40             	mov    0x40(%eax),%eax
  101fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101fb7:	c7 04 24 bd 40 10 00 	movl   $0x1040bd,(%esp)
  101fbe:	e8 b2 13 00 00       	call   103375 <cprintf>
	cprintf("  esp  0x%08x\n", tf->esp);
  101fc3:	8b 45 08             	mov    0x8(%ebp),%eax
  101fc6:	8b 40 44             	mov    0x44(%eax),%eax
  101fc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101fcd:	c7 04 24 cc 40 10 00 	movl   $0x1040cc,(%esp)
  101fd4:	e8 9c 13 00 00       	call   103375 <cprintf>
	cprintf("  ss   0x----%04x\n", tf->ss);
  101fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  101fdc:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101fe0:	0f b7 c0             	movzwl %ax,%eax
  101fe3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101fe7:	c7 04 24 db 40 10 00 	movl   $0x1040db,(%esp)
  101fee:	e8 82 13 00 00       	call   103375 <cprintf>
}
  101ff3:	c9                   	leave  
  101ff4:	c3                   	ret    

00101ff5 <trap>:

void gcc_noreturn
trap(trapframe *tf)
{
  101ff5:	55                   	push   %ebp
  101ff6:	89 e5                	mov    %esp,%ebp
  101ff8:	83 ec 28             	sub    $0x28,%esp
	// The user-level environment may have set the DF flag,
	// and some versions of GCC rely on DF being clear.
	asm volatile("cld" ::: "cc");
  101ffb:	fc                   	cld    

	// If this trap was anticipated, just use the designated handler.
	cpu *c = cpu_cur();
  101ffc:	e8 93 f2 ff ff       	call   101294 <cpu_cur>
  102001:	89 45 f4             	mov    %eax,-0xc(%ebp)
	trap_print(tf);
  102004:	8b 45 08             	mov    0x8(%ebp),%eax
  102007:	89 04 24             	mov    %eax,(%esp)
  10200a:	e8 d8 fe ff ff       	call   101ee7 <trap_print>
	if (c->recover)
  10200f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102012:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  102018:	85 c0                	test   %eax,%eax
  10201a:	74 1e                	je     10203a <trap+0x45>
		c->recover(tf, c->recoverdata);
  10201c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10201f:	8b 90 a0 00 00 00    	mov    0xa0(%eax),%edx
  102025:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102028:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  10202e:	89 44 24 04          	mov    %eax,0x4(%esp)
  102032:	8b 45 08             	mov    0x8(%ebp),%eax
  102035:	89 04 24             	mov    %eax,(%esp)
  102038:	ff d2                	call   *%edx

	trap_print(tf);
  10203a:	8b 45 08             	mov    0x8(%ebp),%eax
  10203d:	89 04 24             	mov    %eax,(%esp)
  102040:	e8 a2 fe ff ff       	call   101ee7 <trap_print>
	panic("unhandled trap");
  102045:	c7 44 24 08 ee 40 10 	movl   $0x1040ee,0x8(%esp)
  10204c:	00 
  10204d:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
  102054:	00 
  102055:	c7 04 24 fd 40 10 00 	movl   $0x1040fd,(%esp)
  10205c:	e8 ff e2 ff ff       	call   100360 <debug_panic>

00102061 <trap_check_recover>:

// Helper function for trap_check_recover(), below:
// handles "anticipated" traps by simply resuming at a new EIP.
static void gcc_noreturn
trap_check_recover(trapframe *tf, void *recoverdata)
{
  102061:	55                   	push   %ebp
  102062:	89 e5                	mov    %esp,%ebp
  102064:	83 ec 28             	sub    $0x28,%esp
	trap_check_args *args = recoverdata;
  102067:	8b 45 0c             	mov    0xc(%ebp),%eax
  10206a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	trap_print(tf);
  10206d:	8b 45 08             	mov    0x8(%ebp),%eax
  102070:	89 04 24             	mov    %eax,(%esp)
  102073:	e8 6f fe ff ff       	call   101ee7 <trap_print>
	cprintf("reip = %d\n", args->reip);
  102078:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10207b:	8b 00                	mov    (%eax),%eax
  10207d:	89 44 24 04          	mov    %eax,0x4(%esp)
  102081:	c7 04 24 09 41 10 00 	movl   $0x104109,(%esp)
  102088:	e8 e8 12 00 00       	call   103375 <cprintf>
	tf->eip = (uint32_t) args->reip;	// Use recovery EIP on return
  10208d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102090:	8b 00                	mov    (%eax),%eax
  102092:	89 c2                	mov    %eax,%edx
  102094:	8b 45 08             	mov    0x8(%ebp),%eax
  102097:	89 50 38             	mov    %edx,0x38(%eax)
	args->trapno = tf->trapno;		// Return trap number
  10209a:	8b 45 08             	mov    0x8(%ebp),%eax
  10209d:	8b 40 30             	mov    0x30(%eax),%eax
  1020a0:	89 c2                	mov    %eax,%edx
  1020a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1020a5:	89 50 04             	mov    %edx,0x4(%eax)
	trap_return(tf);
  1020a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1020ab:	89 04 24             	mov    %eax,(%esp)
  1020ae:	e8 2d 04 00 00       	call   1024e0 <trap_return>

001020b3 <trap_check_kernel>:

// Check for correct handling of traps from kernel mode.
// Called on the boot CPU after trap_init() and trap_setup().
void
trap_check_kernel(void)
{
  1020b3:	55                   	push   %ebp
  1020b4:	89 e5                	mov    %esp,%ebp
  1020b6:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  1020b9:	8c 4d f6             	mov    %cs,-0xa(%ebp)
        return cs;
  1020bc:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
	assert((read_cs() & 3) == 0);	// better be in kernel mode!
  1020c0:	0f b7 c0             	movzwl %ax,%eax
  1020c3:	83 e0 03             	and    $0x3,%eax
  1020c6:	85 c0                	test   %eax,%eax
  1020c8:	74 24                	je     1020ee <trap_check_kernel+0x3b>
  1020ca:	c7 44 24 0c 14 41 10 	movl   $0x104114,0xc(%esp)
  1020d1:	00 
  1020d2:	c7 44 24 08 96 3f 10 	movl   $0x103f96,0x8(%esp)
  1020d9:	00 
  1020da:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
  1020e1:	00 
  1020e2:	c7 04 24 fd 40 10 00 	movl   $0x1040fd,(%esp)
  1020e9:	e8 72 e2 ff ff       	call   100360 <debug_panic>

	cpu *c = cpu_cur();
  1020ee:	e8 a1 f1 ff ff       	call   101294 <cpu_cur>
  1020f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	c->recover = trap_check_recover;
  1020f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1020f9:	c7 80 a0 00 00 00 61 	movl   $0x102061,0xa0(%eax)
  102100:	20 10 00 
	trap_check(&c->recoverdata);
  102103:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102106:	05 a4 00 00 00       	add    $0xa4,%eax
  10210b:	89 04 24             	mov    %eax,(%esp)
  10210e:	e8 96 00 00 00       	call   1021a9 <trap_check>
	c->recover = NULL;	// No more mr. nice-guy; traps are real again
  102113:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102116:	c7 80 a0 00 00 00 00 	movl   $0x0,0xa0(%eax)
  10211d:	00 00 00 

	cprintf("trap_check_kernel() succeeded!\n");
  102120:	c7 04 24 2c 41 10 00 	movl   $0x10412c,(%esp)
  102127:	e8 49 12 00 00       	call   103375 <cprintf>
}
  10212c:	c9                   	leave  
  10212d:	c3                   	ret    

0010212e <trap_check_user>:
// Called from user() in kern/init.c, only in lab 1.
// We assume the "current cpu" is always the boot cpu;
// this true only because lab 1 doesn't start any other CPUs.
void
trap_check_user(void)
{
  10212e:	55                   	push   %ebp
  10212f:	89 e5                	mov    %esp,%ebp
  102131:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  102134:	8c 4d f6             	mov    %cs,-0xa(%ebp)
        return cs;
  102137:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
	assert((read_cs() & 3) == 3);	// better be in user mode!
  10213b:	0f b7 c0             	movzwl %ax,%eax
  10213e:	83 e0 03             	and    $0x3,%eax
  102141:	83 f8 03             	cmp    $0x3,%eax
  102144:	74 24                	je     10216a <trap_check_user+0x3c>
  102146:	c7 44 24 0c 4c 41 10 	movl   $0x10414c,0xc(%esp)
  10214d:	00 
  10214e:	c7 44 24 08 96 3f 10 	movl   $0x103f96,0x8(%esp)
  102155:	00 
  102156:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  10215d:	00 
  10215e:	c7 04 24 fd 40 10 00 	movl   $0x1040fd,(%esp)
  102165:	e8 f6 e1 ff ff       	call   100360 <debug_panic>

	cpu *c = &cpu_boot;	// cpu_cur doesn't work from user mode!
  10216a:	c7 45 f0 00 60 10 00 	movl   $0x106000,-0x10(%ebp)
	c->recover = trap_check_recover;
  102171:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102174:	c7 80 a0 00 00 00 61 	movl   $0x102061,0xa0(%eax)
  10217b:	20 10 00 
	trap_check(&c->recoverdata);
  10217e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102181:	05 a4 00 00 00       	add    $0xa4,%eax
  102186:	89 04 24             	mov    %eax,(%esp)
  102189:	e8 1b 00 00 00       	call   1021a9 <trap_check>
	c->recover = NULL;	// No more mr. nice-guy; traps are real again
  10218e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102191:	c7 80 a0 00 00 00 00 	movl   $0x0,0xa0(%eax)
  102198:	00 00 00 

	cprintf("trap_check_user() succeeded!\n");
  10219b:	c7 04 24 61 41 10 00 	movl   $0x104161,(%esp)
  1021a2:	e8 ce 11 00 00       	call   103375 <cprintf>
}
  1021a7:	c9                   	leave  
  1021a8:	c3                   	ret    

001021a9 <trap_check>:
void after_priv();

// Multi-purpose trap checking function.
void
trap_check(void **argsp)
{
  1021a9:	55                   	push   %ebp
  1021aa:	89 e5                	mov    %esp,%ebp
  1021ac:	57                   	push   %edi
  1021ad:	56                   	push   %esi
  1021ae:	53                   	push   %ebx
  1021af:	83 ec 3c             	sub    $0x3c,%esp
	volatile int cookie = 0xfeedface;
  1021b2:	c7 45 e0 ce fa ed fe 	movl   $0xfeedface,-0x20(%ebp)
	volatile trap_check_args args;
	*argsp = (void*)&args;	// provide args needed for trap recovery
  1021b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1021bc:	8d 55 d8             	lea    -0x28(%ebp),%edx
  1021bf:	89 10                	mov    %edx,(%eax)

	// Try a divide by zero trap.
	// Be careful when using && to take the address of a label:
	// some versions of GCC (4.4.2 at least) will incorrectly try to
	// eliminate code it thinks is _only_ reachable via such a pointer.
	args.reip = after_div0;
  1021c1:	c7 45 d8 cf 21 10 00 	movl   $0x1021cf,-0x28(%ebp)
	asm volatile("div %0,%0; after_div0:" : : "r" (0));
  1021c8:	b8 00 00 00 00       	mov    $0x0,%eax
  1021cd:	f7 f0                	div    %eax

001021cf <after_div0>:
	assert(args.trapno == T_DIVIDE);
  1021cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1021d2:	85 c0                	test   %eax,%eax
  1021d4:	74 24                	je     1021fa <after_div0+0x2b>
  1021d6:	c7 44 24 0c 7f 41 10 	movl   $0x10417f,0xc(%esp)
  1021dd:	00 
  1021de:	c7 44 24 08 96 3f 10 	movl   $0x103f96,0x8(%esp)
  1021e5:	00 
  1021e6:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
  1021ed:	00 
  1021ee:	c7 04 24 fd 40 10 00 	movl   $0x1040fd,(%esp)
  1021f5:	e8 66 e1 ff ff       	call   100360 <debug_panic>

	// Make sure we got our correct stack back with us.
	// The asm ensures gcc uses ebp/esp to get the cookie.
	asm volatile("" : : : "eax","ebx","ecx","edx","esi","edi");
	assert(cookie == 0xfeedface);
  1021fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1021fd:	3d ce fa ed fe       	cmp    $0xfeedface,%eax
  102202:	74 24                	je     102228 <after_div0+0x59>
  102204:	c7 44 24 0c 97 41 10 	movl   $0x104197,0xc(%esp)
  10220b:	00 
  10220c:	c7 44 24 08 96 3f 10 	movl   $0x103f96,0x8(%esp)
  102213:	00 
  102214:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  10221b:	00 
  10221c:	c7 04 24 fd 40 10 00 	movl   $0x1040fd,(%esp)
  102223:	e8 38 e1 ff ff       	call   100360 <debug_panic>

	// Breakpoint trap
	args.reip = after_breakpoint;
  102228:	c7 45 d8 30 22 10 00 	movl   $0x102230,-0x28(%ebp)
	asm volatile("int3; after_breakpoint:");
  10222f:	cc                   	int3   

00102230 <after_breakpoint>:
	assert(args.trapno == T_BRKPT);
  102230:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102233:	83 f8 03             	cmp    $0x3,%eax
  102236:	74 24                	je     10225c <after_breakpoint+0x2c>
  102238:	c7 44 24 0c ac 41 10 	movl   $0x1041ac,0xc(%esp)
  10223f:	00 
  102240:	c7 44 24 08 96 3f 10 	movl   $0x103f96,0x8(%esp)
  102247:	00 
  102248:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  10224f:	00 
  102250:	c7 04 24 fd 40 10 00 	movl   $0x1040fd,(%esp)
  102257:	e8 04 e1 ff ff       	call   100360 <debug_panic>

	// Overflow trap
	args.reip = after_overflow;
  10225c:	c7 45 d8 6b 22 10 00 	movl   $0x10226b,-0x28(%ebp)
	asm volatile("addl %0,%0; into; after_overflow:" : : "r" (0x70000000));
  102263:	b8 00 00 00 70       	mov    $0x70000000,%eax
  102268:	01 c0                	add    %eax,%eax
  10226a:	ce                   	into   

0010226b <after_overflow>:
	assert(args.trapno == T_OFLOW);
  10226b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10226e:	83 f8 04             	cmp    $0x4,%eax
  102271:	74 24                	je     102297 <after_overflow+0x2c>
  102273:	c7 44 24 0c c3 41 10 	movl   $0x1041c3,0xc(%esp)
  10227a:	00 
  10227b:	c7 44 24 08 96 3f 10 	movl   $0x103f96,0x8(%esp)
  102282:	00 
  102283:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  10228a:	00 
  10228b:	c7 04 24 fd 40 10 00 	movl   $0x1040fd,(%esp)
  102292:	e8 c9 e0 ff ff       	call   100360 <debug_panic>

	// Bounds trap
	args.reip = after_bound;
  102297:	c7 45 d8 b4 22 10 00 	movl   $0x1022b4,-0x28(%ebp)
	int bounds[2] = { 1, 3 };
  10229e:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1022a5:	c7 45 d4 03 00 00 00 	movl   $0x3,-0x2c(%ebp)
	asm volatile("boundl %0,%1; after_bound:" : : "r" (0), "m" (bounds[0]));
  1022ac:	b8 00 00 00 00       	mov    $0x0,%eax
  1022b1:	62 45 d0             	bound  %eax,-0x30(%ebp)

001022b4 <after_bound>:
	assert(args.trapno == T_BOUND);
  1022b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1022b7:	83 f8 05             	cmp    $0x5,%eax
  1022ba:	74 24                	je     1022e0 <after_bound+0x2c>
  1022bc:	c7 44 24 0c da 41 10 	movl   $0x1041da,0xc(%esp)
  1022c3:	00 
  1022c4:	c7 44 24 08 96 3f 10 	movl   $0x103f96,0x8(%esp)
  1022cb:	00 
  1022cc:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  1022d3:	00 
  1022d4:	c7 04 24 fd 40 10 00 	movl   $0x1040fd,(%esp)
  1022db:	e8 80 e0 ff ff       	call   100360 <debug_panic>

	// Illegal instruction trap
	args.reip = after_illegal;
  1022e0:	c7 45 d8 e9 22 10 00 	movl   $0x1022e9,-0x28(%ebp)
	asm volatile("ud2; after_illegal:");	// guaranteed to be undefined
  1022e7:	0f 0b                	ud2    

001022e9 <after_illegal>:
	assert(args.trapno == T_ILLOP);
  1022e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1022ec:	83 f8 06             	cmp    $0x6,%eax
  1022ef:	74 24                	je     102315 <after_illegal+0x2c>
  1022f1:	c7 44 24 0c f1 41 10 	movl   $0x1041f1,0xc(%esp)
  1022f8:	00 
  1022f9:	c7 44 24 08 96 3f 10 	movl   $0x103f96,0x8(%esp)
  102300:	00 
  102301:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
  102308:	00 
  102309:	c7 04 24 fd 40 10 00 	movl   $0x1040fd,(%esp)
  102310:	e8 4b e0 ff ff       	call   100360 <debug_panic>

	// General protection fault due to invalid segment load
	args.reip = after_gpfault;
  102315:	c7 45 d8 23 23 10 00 	movl   $0x102323,-0x28(%ebp)
	asm volatile("movl %0,%%fs; after_gpfault:" : : "r" (-1));
  10231c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102321:	8e e0                	mov    %eax,%fs

00102323 <after_gpfault>:
	assert(args.trapno == T_GPFLT);
  102323:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102326:	83 f8 0d             	cmp    $0xd,%eax
  102329:	74 24                	je     10234f <after_gpfault+0x2c>
  10232b:	c7 44 24 0c 08 42 10 	movl   $0x104208,0xc(%esp)
  102332:	00 
  102333:	c7 44 24 08 96 3f 10 	movl   $0x103f96,0x8(%esp)
  10233a:	00 
  10233b:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  102342:	00 
  102343:	c7 04 24 fd 40 10 00 	movl   $0x1040fd,(%esp)
  10234a:	e8 11 e0 ff ff       	call   100360 <debug_panic>

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  10234f:	8c 4d e6             	mov    %cs,-0x1a(%ebp)
        return cs;
  102352:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax

	// General protection fault due to privilege violation
	if (read_cs() & 3) {
  102356:	0f b7 c0             	movzwl %ax,%eax
  102359:	83 e0 03             	and    $0x3,%eax
  10235c:	85 c0                	test   %eax,%eax
  10235e:	74 3a                	je     10239a <after_priv+0x2c>
		args.reip = after_priv;
  102360:	c7 45 d8 6e 23 10 00 	movl   $0x10236e,-0x28(%ebp)
		asm volatile("lidt %0; after_priv:" : : "m" (idt_pd));
  102367:	0f 01 1d 00 70 10 00 	lidtl  0x107000

0010236e <after_priv>:
		assert(args.trapno == T_GPFLT);
  10236e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102371:	83 f8 0d             	cmp    $0xd,%eax
  102374:	74 24                	je     10239a <after_priv+0x2c>
  102376:	c7 44 24 0c 08 42 10 	movl   $0x104208,0xc(%esp)
  10237d:	00 
  10237e:	c7 44 24 08 96 3f 10 	movl   $0x103f96,0x8(%esp)
  102385:	00 
  102386:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  10238d:	00 
  10238e:	c7 04 24 fd 40 10 00 	movl   $0x1040fd,(%esp)
  102395:	e8 c6 df ff ff       	call   100360 <debug_panic>
	}

	// Make sure our stack cookie is still with us
	assert(cookie == 0xfeedface);
  10239a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10239d:	3d ce fa ed fe       	cmp    $0xfeedface,%eax
  1023a2:	74 24                	je     1023c8 <after_priv+0x5a>
  1023a4:	c7 44 24 0c 97 41 10 	movl   $0x104197,0xc(%esp)
  1023ab:	00 
  1023ac:	c7 44 24 08 96 3f 10 	movl   $0x103f96,0x8(%esp)
  1023b3:	00 
  1023b4:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  1023bb:	00 
  1023bc:	c7 04 24 fd 40 10 00 	movl   $0x1040fd,(%esp)
  1023c3:	e8 98 df ff ff       	call   100360 <debug_panic>

	*argsp = NULL;	// recovery mechanism not needed anymore
  1023c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1023cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
  1023d1:	83 c4 3c             	add    $0x3c,%esp
  1023d4:	5b                   	pop    %ebx
  1023d5:	5e                   	pop    %esi
  1023d6:	5f                   	pop    %edi
  1023d7:	5d                   	pop    %ebp
  1023d8:	c3                   	ret    
  1023d9:	90                   	nop
  1023da:	90                   	nop
  1023db:	90                   	nop
  1023dc:	90                   	nop
  1023dd:	90                   	nop
  1023de:	90                   	nop
  1023df:	90                   	nop

001023e0 <tv0>:
.text

/*
 * Lab 1: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(tv0, 0);
  1023e0:	6a 00                	push   $0x0
  1023e2:	6a 00                	push   $0x0
  1023e4:	e9 dd 00 00 00       	jmp    1024c6 <_alltraps>
  1023e9:	90                   	nop

001023ea <tv2>:
/* TRAPHANDLER_NOEC(trap_debug, 1); */
TRAPHANDLER_NOEC(tv2, 2);
  1023ea:	6a 00                	push   $0x0
  1023ec:	6a 02                	push   $0x2
  1023ee:	e9 d3 00 00 00       	jmp    1024c6 <_alltraps>
  1023f3:	90                   	nop

001023f4 <tv3>:
TRAPHANDLER_NOEC(tv3, 3);
  1023f4:	6a 00                	push   $0x0
  1023f6:	6a 03                	push   $0x3
  1023f8:	e9 c9 00 00 00       	jmp    1024c6 <_alltraps>
  1023fd:	90                   	nop

001023fe <tv4>:
TRAPHANDLER_NOEC(tv4, 4);
  1023fe:	6a 00                	push   $0x0
  102400:	6a 04                	push   $0x4
  102402:	e9 bf 00 00 00       	jmp    1024c6 <_alltraps>
  102407:	90                   	nop

00102408 <tv5>:
TRAPHANDLER_NOEC(tv5, 5);
  102408:	6a 00                	push   $0x0
  10240a:	6a 05                	push   $0x5
  10240c:	e9 b5 00 00 00       	jmp    1024c6 <_alltraps>
  102411:	90                   	nop

00102412 <tv6>:
TRAPHANDLER_NOEC(tv6, 6);
  102412:	6a 00                	push   $0x0
  102414:	6a 06                	push   $0x6
  102416:	e9 ab 00 00 00       	jmp    1024c6 <_alltraps>
  10241b:	90                   	nop

0010241c <tv7>:
TRAPHANDLER_NOEC(tv7, 7);
  10241c:	6a 00                	push   $0x0
  10241e:	6a 07                	push   $0x7
  102420:	e9 a1 00 00 00       	jmp    1024c6 <_alltraps>
  102425:	90                   	nop

00102426 <tv8>:
TRAPHANDLER(tv8, 8);
  102426:	6a 08                	push   $0x8
  102428:	e9 99 00 00 00       	jmp    1024c6 <_alltraps>
  10242d:	90                   	nop

0010242e <tv10>:
/* TRAPHANDLER_NOEC(trap_coproc_seg_overrun, 9); */
TRAPHANDLER(tv10, 10);
  10242e:	6a 0a                	push   $0xa
  102430:	e9 91 00 00 00       	jmp    1024c6 <_alltraps>
  102435:	90                   	nop

00102436 <tv11>:
TRAPHANDLER(tv11, 11);
  102436:	6a 0b                	push   $0xb
  102438:	e9 89 00 00 00       	jmp    1024c6 <_alltraps>
  10243d:	90                   	nop

0010243e <tv12>:
TRAPHANDLER(tv12, 12);
  10243e:	6a 0c                	push   $0xc
  102440:	e9 81 00 00 00       	jmp    1024c6 <_alltraps>
  102445:	90                   	nop

00102446 <tv13>:
TRAPHANDLER(tv13, 13);
  102446:	6a 0d                	push   $0xd
  102448:	e9 79 00 00 00       	jmp    1024c6 <_alltraps>
  10244d:	90                   	nop

0010244e <tv14>:
TRAPHANDLER(tv14, 14);
  10244e:	6a 0e                	push   $0xe
  102450:	e9 71 00 00 00       	jmp    1024c6 <_alltraps>
  102455:	90                   	nop

00102456 <tv16>:
/* TRAPHANDLER_NOEC(reserved, 15); */
TRAPHANDLER_NOEC(tv16, 16);
  102456:	6a 00                	push   $0x0
  102458:	6a 10                	push   $0x10
  10245a:	e9 67 00 00 00       	jmp    1024c6 <_alltraps>
  10245f:	90                   	nop

00102460 <tv17>:
TRAPHANDLER(tv17, 17);
  102460:	6a 11                	push   $0x11
  102462:	e9 5f 00 00 00       	jmp    1024c6 <_alltraps>
  102467:	90                   	nop

00102468 <tv18>:
TRAPHANDLER_NOEC(tv18, 18);
  102468:	6a 00                	push   $0x0
  10246a:	6a 12                	push   $0x12
  10246c:	e9 55 00 00 00       	jmp    1024c6 <_alltraps>
  102471:	90                   	nop

00102472 <tv19>:
TRAPHANDLER_NOEC(tv19, 19);
  102472:	6a 00                	push   $0x0
  102474:	6a 13                	push   $0x13
  102476:	e9 4b 00 00 00       	jmp    1024c6 <_alltraps>
  10247b:	90                   	nop

0010247c <tv30>:
TRAPHANDLER_NOEC(tv30, 30);
  10247c:	6a 00                	push   $0x0
  10247e:	6a 1e                	push   $0x1e
  102480:	e9 41 00 00 00       	jmp    1024c6 <_alltraps>
  102485:	90                   	nop

00102486 <tv32>:
TRAPHANDLER_NOEC(tv32, 32);
  102486:	6a 00                	push   $0x0
  102488:	6a 20                	push   $0x20
  10248a:	e9 37 00 00 00       	jmp    1024c6 <_alltraps>
  10248f:	90                   	nop

00102490 <tv48>:
TRAPHANDLER_NOEC(tv48, 48);
  102490:	6a 00                	push   $0x0
  102492:	6a 30                	push   $0x30
  102494:	e9 2d 00 00 00       	jmp    1024c6 <_alltraps>
  102499:	90                   	nop

0010249a <tv49>:
TRAPHANDLER_NOEC(tv49, 49);
  10249a:	6a 00                	push   $0x0
  10249c:	6a 31                	push   $0x31
  10249e:	e9 23 00 00 00       	jmp    1024c6 <_alltraps>
  1024a3:	90                   	nop

001024a4 <tv50>:
TRAPHANDLER_NOEC(tv50, 50);
  1024a4:	6a 00                	push   $0x0
  1024a6:	6a 32                	push   $0x32
  1024a8:	e9 19 00 00 00       	jmp    1024c6 <_alltraps>
  1024ad:	90                   	nop

001024ae <tv500>:
TRAPHANDLER_NOEC(tv500, 500);
  1024ae:	6a 00                	push   $0x0
  1024b0:	68 f4 01 00 00       	push   $0x1f4
  1024b5:	e9 0c 00 00 00       	jmp    1024c6 <_alltraps>

001024ba <tv501>:
TRAPHANDLER_NOEC(tv501, 501);
  1024ba:	6a 00                	push   $0x0
  1024bc:	68 f5 01 00 00       	push   $0x1f5
  1024c1:	e9 00 00 00 00       	jmp    1024c6 <_alltraps>

001024c6 <_alltraps>:
/*
 * Lab 1: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
	pushl %ds
  1024c6:	1e                   	push   %ds
	pushl %es
  1024c7:	06                   	push   %es
	pushl %fs
  1024c8:	0f a0                	push   %fs
	pushl %gs
  1024ca:	0f a8                	push   %gs
	pushal
  1024cc:	60                   	pusha  

	movw $CPU_GDT_KDATA, %ax
  1024cd:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
  1024d1:	8e d8                	mov    %eax,%ds
	movw %ax, %es
  1024d3:	8e c0                	mov    %eax,%es

	pushl %esp // passing trapframe addr as parameter
  1024d5:	54                   	push   %esp
	call trap
  1024d6:	e8 1a fb ff ff       	call   101ff5 <trap>
  1024db:	90                   	nop
  1024dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

001024e0 <trap_return>:
// replaces the caller's stack pointer and other registers.
.globl	trap_return
.type	trap_return,@function
.p2align 4, 0x90		/* 16-byte alignment, nop filled */
trap_return:
	movl 0x4(%esp), %eax
  1024e0:	8b 44 24 04          	mov    0x4(%esp),%eax
	movl %eax, %esp // setting stack to trap frame
  1024e4:	89 c4                	mov    %eax,%esp
	popal
  1024e6:	61                   	popa   
	popl %gs
  1024e7:	0f a9                	pop    %gs
	popl %fs
  1024e9:	0f a1                	pop    %fs
	popl %es
  1024eb:	07                   	pop    %es
	popl %ds
  1024ec:	1f                   	pop    %ds
	addl $0x8, %esp // trapno and errcode
  1024ed:	83 c4 08             	add    $0x8,%esp
	iret
  1024f0:	cf                   	iret   
  1024f1:	90                   	nop
  1024f2:	90                   	nop
  1024f3:	90                   	nop

001024f4 <video_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
video_init(void)
{
  1024f4:	55                   	push   %ebp
  1024f5:	89 e5                	mov    %esp,%ebp
  1024f7:	83 ec 30             	sub    $0x30,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	/* Get a pointer to the memory-mapped text display buffer. */
	cp = (uint16_t*) mem_ptr(CGA_BUF);
  1024fa:	c7 45 d8 00 80 0b 00 	movl   $0xb8000,-0x28(%ebp)
	was = *cp;
  102501:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102504:	0f b7 00             	movzwl (%eax),%eax
  102507:	66 89 45 de          	mov    %ax,-0x22(%ebp)
	*cp = (uint16_t) 0xA55A;
  10250b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10250e:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
  102513:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102516:	0f b7 00             	movzwl (%eax),%eax
  102519:	66 3d 5a a5          	cmp    $0xa55a,%ax
  10251d:	74 13                	je     102532 <video_init+0x3e>
		cp = (uint16_t*) mem_ptr(MONO_BUF);
  10251f:	c7 45 d8 00 00 0b 00 	movl   $0xb0000,-0x28(%ebp)
		addr_6845 = MONO_BASE;
  102526:	c7 05 60 8f 10 00 b4 	movl   $0x3b4,0x108f60
  10252d:	03 00 00 
  102530:	eb 14                	jmp    102546 <video_init+0x52>
	} else {
		*cp = was;
  102532:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102535:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  102539:	66 89 10             	mov    %dx,(%eax)
		addr_6845 = CGA_BASE;
  10253c:	c7 05 60 8f 10 00 d4 	movl   $0x3d4,0x108f60
  102543:	03 00 00 
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
  102546:	a1 60 8f 10 00       	mov    0x108f60,%eax
  10254b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10254e:	c6 45 e7 0e          	movb   $0xe,-0x19(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  102552:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  102556:	8b 55 e8             	mov    -0x18(%ebp),%edx
  102559:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
  10255a:	a1 60 8f 10 00       	mov    0x108f60,%eax
  10255f:	83 c0 01             	add    $0x1,%eax
  102562:	89 45 ec             	mov    %eax,-0x14(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  102565:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102568:	89 c2                	mov    %eax,%edx
  10256a:	ec                   	in     (%dx),%al
  10256b:	88 45 f2             	mov    %al,-0xe(%ebp)
	return data;
  10256e:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
  102572:	0f b6 c0             	movzbl %al,%eax
  102575:	c1 e0 08             	shl    $0x8,%eax
  102578:	89 45 e0             	mov    %eax,-0x20(%ebp)
	outb(addr_6845, 15);
  10257b:	a1 60 8f 10 00       	mov    0x108f60,%eax
  102580:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102583:	c6 45 f3 0f          	movb   $0xf,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  102587:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10258b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10258e:	ee                   	out    %al,(%dx)
	pos |= inb(addr_6845 + 1);
  10258f:	a1 60 8f 10 00       	mov    0x108f60,%eax
  102594:	83 c0 01             	add    $0x1,%eax
  102597:	89 45 f8             	mov    %eax,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  10259a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10259d:	89 c2                	mov    %eax,%edx
  10259f:	ec                   	in     (%dx),%al
  1025a0:	88 45 ff             	mov    %al,-0x1(%ebp)
	return data;
  1025a3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
  1025a7:	0f b6 c0             	movzbl %al,%eax
  1025aa:	09 45 e0             	or     %eax,-0x20(%ebp)

	crt_buf = (uint16_t*) cp;
  1025ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1025b0:	a3 64 8f 10 00       	mov    %eax,0x108f64
	crt_pos = pos;
  1025b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1025b8:	66 a3 68 8f 10 00    	mov    %ax,0x108f68
}
  1025be:	c9                   	leave  
  1025bf:	c3                   	ret    

001025c0 <video_putc>:



void
video_putc(int c)
{
  1025c0:	55                   	push   %ebp
  1025c1:	89 e5                	mov    %esp,%ebp
  1025c3:	53                   	push   %ebx
  1025c4:	83 ec 44             	sub    $0x44,%esp
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
  1025c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1025ca:	b0 00                	mov    $0x0,%al
  1025cc:	85 c0                	test   %eax,%eax
  1025ce:	75 07                	jne    1025d7 <video_putc+0x17>
		c |= 0x0700;
  1025d0:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)

	switch (c & 0xff) {
  1025d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1025da:	25 ff 00 00 00       	and    $0xff,%eax
  1025df:	83 f8 09             	cmp    $0x9,%eax
  1025e2:	0f 84 ae 00 00 00    	je     102696 <video_putc+0xd6>
  1025e8:	83 f8 09             	cmp    $0x9,%eax
  1025eb:	7f 0a                	jg     1025f7 <video_putc+0x37>
  1025ed:	83 f8 08             	cmp    $0x8,%eax
  1025f0:	74 14                	je     102606 <video_putc+0x46>
  1025f2:	e9 dd 00 00 00       	jmp    1026d4 <video_putc+0x114>
  1025f7:	83 f8 0a             	cmp    $0xa,%eax
  1025fa:	74 4e                	je     10264a <video_putc+0x8a>
  1025fc:	83 f8 0d             	cmp    $0xd,%eax
  1025ff:	74 59                	je     10265a <video_putc+0x9a>
  102601:	e9 ce 00 00 00       	jmp    1026d4 <video_putc+0x114>
	case '\b':
		if (crt_pos > 0) {
  102606:	0f b7 05 68 8f 10 00 	movzwl 0x108f68,%eax
  10260d:	66 85 c0             	test   %ax,%ax
  102610:	0f 84 e4 00 00 00    	je     1026fa <video_putc+0x13a>
			crt_pos--;
  102616:	0f b7 05 68 8f 10 00 	movzwl 0x108f68,%eax
  10261d:	83 e8 01             	sub    $0x1,%eax
  102620:	66 a3 68 8f 10 00    	mov    %ax,0x108f68
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
  102626:	a1 64 8f 10 00       	mov    0x108f64,%eax
  10262b:	0f b7 15 68 8f 10 00 	movzwl 0x108f68,%edx
  102632:	0f b7 d2             	movzwl %dx,%edx
  102635:	01 d2                	add    %edx,%edx
  102637:	8d 14 10             	lea    (%eax,%edx,1),%edx
  10263a:	8b 45 08             	mov    0x8(%ebp),%eax
  10263d:	b0 00                	mov    $0x0,%al
  10263f:	83 c8 20             	or     $0x20,%eax
  102642:	66 89 02             	mov    %ax,(%edx)
		}
		break;
  102645:	e9 b1 00 00 00       	jmp    1026fb <video_putc+0x13b>
	case '\n':
		crt_pos += CRT_COLS;
  10264a:	0f b7 05 68 8f 10 00 	movzwl 0x108f68,%eax
  102651:	83 c0 50             	add    $0x50,%eax
  102654:	66 a3 68 8f 10 00    	mov    %ax,0x108f68
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
  10265a:	0f b7 1d 68 8f 10 00 	movzwl 0x108f68,%ebx
  102661:	0f b7 0d 68 8f 10 00 	movzwl 0x108f68,%ecx
  102668:	0f b7 c1             	movzwl %cx,%eax
  10266b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  102671:	c1 e8 10             	shr    $0x10,%eax
  102674:	89 c2                	mov    %eax,%edx
  102676:	66 c1 ea 06          	shr    $0x6,%dx
  10267a:	89 d0                	mov    %edx,%eax
  10267c:	c1 e0 02             	shl    $0x2,%eax
  10267f:	01 d0                	add    %edx,%eax
  102681:	c1 e0 04             	shl    $0x4,%eax
  102684:	89 ca                	mov    %ecx,%edx
  102686:	66 29 c2             	sub    %ax,%dx
  102689:	89 d8                	mov    %ebx,%eax
  10268b:	66 29 d0             	sub    %dx,%ax
  10268e:	66 a3 68 8f 10 00    	mov    %ax,0x108f68
		break;
  102694:	eb 65                	jmp    1026fb <video_putc+0x13b>
	case '\t':
		video_putc(' ');
  102696:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10269d:	e8 1e ff ff ff       	call   1025c0 <video_putc>
		video_putc(' ');
  1026a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1026a9:	e8 12 ff ff ff       	call   1025c0 <video_putc>
		video_putc(' ');
  1026ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1026b5:	e8 06 ff ff ff       	call   1025c0 <video_putc>
		video_putc(' ');
  1026ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1026c1:	e8 fa fe ff ff       	call   1025c0 <video_putc>
		video_putc(' ');
  1026c6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1026cd:	e8 ee fe ff ff       	call   1025c0 <video_putc>
		break;
  1026d2:	eb 27                	jmp    1026fb <video_putc+0x13b>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
  1026d4:	8b 15 64 8f 10 00    	mov    0x108f64,%edx
  1026da:	0f b7 05 68 8f 10 00 	movzwl 0x108f68,%eax
  1026e1:	0f b7 c8             	movzwl %ax,%ecx
  1026e4:	01 c9                	add    %ecx,%ecx
  1026e6:	8d 0c 0a             	lea    (%edx,%ecx,1),%ecx
  1026e9:	8b 55 08             	mov    0x8(%ebp),%edx
  1026ec:	66 89 11             	mov    %dx,(%ecx)
  1026ef:	83 c0 01             	add    $0x1,%eax
  1026f2:	66 a3 68 8f 10 00    	mov    %ax,0x108f68
  1026f8:	eb 01                	jmp    1026fb <video_putc+0x13b>
	case '\b':
		if (crt_pos > 0) {
			crt_pos--;
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
		}
		break;
  1026fa:	90                   	nop
		crt_buf[crt_pos++] = c;		/* write the character */
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
  1026fb:	0f b7 05 68 8f 10 00 	movzwl 0x108f68,%eax
  102702:	66 3d cf 07          	cmp    $0x7cf,%ax
  102706:	76 5b                	jbe    102763 <video_putc+0x1a3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS,
  102708:	a1 64 8f 10 00       	mov    0x108f64,%eax
  10270d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  102713:	a1 64 8f 10 00       	mov    0x108f64,%eax
  102718:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10271f:	00 
  102720:	89 54 24 04          	mov    %edx,0x4(%esp)
  102724:	89 04 24             	mov    %eax,(%esp)
  102727:	e8 a4 0e 00 00       	call   1035d0 <memmove>
			(CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
  10272c:	c7 45 d4 80 07 00 00 	movl   $0x780,-0x2c(%ebp)
  102733:	eb 15                	jmp    10274a <video_putc+0x18a>
			crt_buf[i] = 0x0700 | ' ';
  102735:	a1 64 8f 10 00       	mov    0x108f64,%eax
  10273a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10273d:	01 d2                	add    %edx,%edx
  10273f:	01 d0                	add    %edx,%eax
  102741:	66 c7 00 20 07       	movw   $0x720,(%eax)
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS,
			(CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
  102746:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
  10274a:	81 7d d4 cf 07 00 00 	cmpl   $0x7cf,-0x2c(%ebp)
  102751:	7e e2                	jle    102735 <video_putc+0x175>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
  102753:	0f b7 05 68 8f 10 00 	movzwl 0x108f68,%eax
  10275a:	83 e8 50             	sub    $0x50,%eax
  10275d:	66 a3 68 8f 10 00    	mov    %ax,0x108f68
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
  102763:	a1 60 8f 10 00       	mov    0x108f60,%eax
  102768:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10276b:	c6 45 db 0e          	movb   $0xe,-0x25(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  10276f:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  102773:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102776:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
  102777:	0f b7 05 68 8f 10 00 	movzwl 0x108f68,%eax
  10277e:	66 c1 e8 08          	shr    $0x8,%ax
  102782:	0f b6 c0             	movzbl %al,%eax
  102785:	8b 15 60 8f 10 00    	mov    0x108f60,%edx
  10278b:	83 c2 01             	add    $0x1,%edx
  10278e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  102791:	88 45 e3             	mov    %al,-0x1d(%ebp)
  102794:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  102798:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10279b:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
  10279c:	a1 60 8f 10 00       	mov    0x108f60,%eax
  1027a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1027a4:	c6 45 eb 0f          	movb   $0xf,-0x15(%ebp)
  1027a8:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  1027ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1027af:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos);
  1027b0:	0f b7 05 68 8f 10 00 	movzwl 0x108f68,%eax
  1027b7:	0f b6 c0             	movzbl %al,%eax
  1027ba:	8b 15 60 8f 10 00    	mov    0x108f60,%edx
  1027c0:	83 c2 01             	add    $0x1,%edx
  1027c3:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1027c6:	88 45 f3             	mov    %al,-0xd(%ebp)
  1027c9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1027cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1027d0:	ee                   	out    %al,(%dx)
}
  1027d1:	83 c4 44             	add    $0x44,%esp
  1027d4:	5b                   	pop    %ebx
  1027d5:	5d                   	pop    %ebp
  1027d6:	c3                   	ret    
  1027d7:	90                   	nop

001027d8 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
  1027d8:	55                   	push   %ebp
  1027d9:	89 e5                	mov    %esp,%ebp
  1027db:	83 ec 38             	sub    $0x38,%esp
  1027de:	c7 45 e4 64 00 00 00 	movl   $0x64,-0x1c(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1027e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1027e8:	89 c2                	mov    %eax,%edx
  1027ea:	ec                   	in     (%dx),%al
  1027eb:	88 45 eb             	mov    %al,-0x15(%ebp)
	return data;
  1027ee:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
  1027f2:	0f b6 c0             	movzbl %al,%eax
  1027f5:	83 e0 01             	and    $0x1,%eax
  1027f8:	85 c0                	test   %eax,%eax
  1027fa:	75 0a                	jne    102806 <kbd_proc_data+0x2e>
		return -1;
  1027fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  102801:	e9 5a 01 00 00       	jmp    102960 <kbd_proc_data+0x188>
  102806:	c7 45 ec 60 00 00 00 	movl   $0x60,-0x14(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  10280d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102810:	89 c2                	mov    %eax,%edx
  102812:	ec                   	in     (%dx),%al
  102813:	88 45 f2             	mov    %al,-0xe(%ebp)
	return data;
  102816:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax

	data = inb(KBDATAP);
  10281a:	88 45 e3             	mov    %al,-0x1d(%ebp)

	if (data == 0xE0) {
  10281d:	80 7d e3 e0          	cmpb   $0xe0,-0x1d(%ebp)
  102821:	75 17                	jne    10283a <kbd_proc_data+0x62>
		// E0 escape character
		shift |= E0ESC;
  102823:	a1 6c 8f 10 00       	mov    0x108f6c,%eax
  102828:	83 c8 40             	or     $0x40,%eax
  10282b:	a3 6c 8f 10 00       	mov    %eax,0x108f6c
		return 0;
  102830:	b8 00 00 00 00       	mov    $0x0,%eax
  102835:	e9 26 01 00 00       	jmp    102960 <kbd_proc_data+0x188>
	} else if (data & 0x80) {
  10283a:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  10283e:	84 c0                	test   %al,%al
  102840:	79 47                	jns    102889 <kbd_proc_data+0xb1>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
  102842:	a1 6c 8f 10 00       	mov    0x108f6c,%eax
  102847:	83 e0 40             	and    $0x40,%eax
  10284a:	85 c0                	test   %eax,%eax
  10284c:	75 09                	jne    102857 <kbd_proc_data+0x7f>
  10284e:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  102852:	83 e0 7f             	and    $0x7f,%eax
  102855:	eb 04                	jmp    10285b <kbd_proc_data+0x83>
  102857:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  10285b:	88 45 e3             	mov    %al,-0x1d(%ebp)
		shift &= ~(shiftcode[data] | E0ESC);
  10285e:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  102862:	0f b6 80 20 70 10 00 	movzbl 0x107020(%eax),%eax
  102869:	83 c8 40             	or     $0x40,%eax
  10286c:	0f b6 c0             	movzbl %al,%eax
  10286f:	f7 d0                	not    %eax
  102871:	89 c2                	mov    %eax,%edx
  102873:	a1 6c 8f 10 00       	mov    0x108f6c,%eax
  102878:	21 d0                	and    %edx,%eax
  10287a:	a3 6c 8f 10 00       	mov    %eax,0x108f6c
		return 0;
  10287f:	b8 00 00 00 00       	mov    $0x0,%eax
  102884:	e9 d7 00 00 00       	jmp    102960 <kbd_proc_data+0x188>
	} else if (shift & E0ESC) {
  102889:	a1 6c 8f 10 00       	mov    0x108f6c,%eax
  10288e:	83 e0 40             	and    $0x40,%eax
  102891:	85 c0                	test   %eax,%eax
  102893:	74 11                	je     1028a6 <kbd_proc_data+0xce>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
  102895:	80 4d e3 80          	orb    $0x80,-0x1d(%ebp)
		shift &= ~E0ESC;
  102899:	a1 6c 8f 10 00       	mov    0x108f6c,%eax
  10289e:	83 e0 bf             	and    $0xffffffbf,%eax
  1028a1:	a3 6c 8f 10 00       	mov    %eax,0x108f6c
	}

	shift |= shiftcode[data];
  1028a6:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1028aa:	0f b6 80 20 70 10 00 	movzbl 0x107020(%eax),%eax
  1028b1:	0f b6 d0             	movzbl %al,%edx
  1028b4:	a1 6c 8f 10 00       	mov    0x108f6c,%eax
  1028b9:	09 d0                	or     %edx,%eax
  1028bb:	a3 6c 8f 10 00       	mov    %eax,0x108f6c
	shift ^= togglecode[data];
  1028c0:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1028c4:	0f b6 80 20 71 10 00 	movzbl 0x107120(%eax),%eax
  1028cb:	0f b6 d0             	movzbl %al,%edx
  1028ce:	a1 6c 8f 10 00       	mov    0x108f6c,%eax
  1028d3:	31 d0                	xor    %edx,%eax
  1028d5:	a3 6c 8f 10 00       	mov    %eax,0x108f6c

	c = charcode[shift & (CTL | SHIFT)][data];
  1028da:	a1 6c 8f 10 00       	mov    0x108f6c,%eax
  1028df:	83 e0 03             	and    $0x3,%eax
  1028e2:	8b 14 85 20 75 10 00 	mov    0x107520(,%eax,4),%edx
  1028e9:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1028ed:	8d 04 02             	lea    (%edx,%eax,1),%eax
  1028f0:	0f b6 00             	movzbl (%eax),%eax
  1028f3:	0f b6 c0             	movzbl %al,%eax
  1028f6:	89 45 dc             	mov    %eax,-0x24(%ebp)
	if (shift & CAPSLOCK) {
  1028f9:	a1 6c 8f 10 00       	mov    0x108f6c,%eax
  1028fe:	83 e0 08             	and    $0x8,%eax
  102901:	85 c0                	test   %eax,%eax
  102903:	74 22                	je     102927 <kbd_proc_data+0x14f>
		if ('a' <= c && c <= 'z')
  102905:	83 7d dc 60          	cmpl   $0x60,-0x24(%ebp)
  102909:	7e 0c                	jle    102917 <kbd_proc_data+0x13f>
  10290b:	83 7d dc 7a          	cmpl   $0x7a,-0x24(%ebp)
  10290f:	7f 06                	jg     102917 <kbd_proc_data+0x13f>
			c += 'A' - 'a';
  102911:	83 6d dc 20          	subl   $0x20,-0x24(%ebp)
	shift |= shiftcode[data];
	shift ^= togglecode[data];

	c = charcode[shift & (CTL | SHIFT)][data];
	if (shift & CAPSLOCK) {
		if ('a' <= c && c <= 'z')
  102915:	eb 10                	jmp    102927 <kbd_proc_data+0x14f>
			c += 'A' - 'a';
		else if ('A' <= c && c <= 'Z')
  102917:	83 7d dc 40          	cmpl   $0x40,-0x24(%ebp)
  10291b:	7e 0a                	jle    102927 <kbd_proc_data+0x14f>
  10291d:	83 7d dc 5a          	cmpl   $0x5a,-0x24(%ebp)
  102921:	7f 04                	jg     102927 <kbd_proc_data+0x14f>
			c += 'a' - 'A';
  102923:	83 45 dc 20          	addl   $0x20,-0x24(%ebp)
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  102927:	a1 6c 8f 10 00       	mov    0x108f6c,%eax
  10292c:	f7 d0                	not    %eax
  10292e:	83 e0 06             	and    $0x6,%eax
  102931:	85 c0                	test   %eax,%eax
  102933:	75 28                	jne    10295d <kbd_proc_data+0x185>
  102935:	81 7d dc e9 00 00 00 	cmpl   $0xe9,-0x24(%ebp)
  10293c:	75 1f                	jne    10295d <kbd_proc_data+0x185>
		cprintf("Rebooting!\n");
  10293e:	c7 04 24 d0 43 10 00 	movl   $0x1043d0,(%esp)
  102945:	e8 2b 0a 00 00       	call   103375 <cprintf>
  10294a:	c7 45 f4 92 00 00 00 	movl   $0x92,-0xc(%ebp)
  102951:	c6 45 f3 03          	movb   $0x3,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  102955:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  102959:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10295c:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
  10295d:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
  102960:	c9                   	leave  
  102961:	c3                   	ret    

00102962 <kbd_intr>:

void
kbd_intr(void)
{
  102962:	55                   	push   %ebp
  102963:	89 e5                	mov    %esp,%ebp
  102965:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
  102968:	c7 04 24 d8 27 10 00 	movl   $0x1027d8,(%esp)
  10296f:	e8 b3 d8 ff ff       	call   100227 <cons_intr>
}
  102974:	c9                   	leave  
  102975:	c3                   	ret    

00102976 <kbd_init>:

void
kbd_init(void)
{
  102976:	55                   	push   %ebp
  102977:	89 e5                	mov    %esp,%ebp
}
  102979:	5d                   	pop    %ebp
  10297a:	c3                   	ret    
  10297b:	90                   	nop

0010297c <delay>:


// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
  10297c:	55                   	push   %ebp
  10297d:	89 e5                	mov    %esp,%ebp
  10297f:	83 ec 20             	sub    $0x20,%esp
  102982:	c7 45 e0 84 00 00 00 	movl   $0x84,-0x20(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  102989:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10298c:	89 c2                	mov    %eax,%edx
  10298e:	ec                   	in     (%dx),%al
  10298f:	88 45 e7             	mov    %al,-0x19(%ebp)
	return data;
  102992:	c7 45 e8 84 00 00 00 	movl   $0x84,-0x18(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  102999:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10299c:	89 c2                	mov    %eax,%edx
  10299e:	ec                   	in     (%dx),%al
  10299f:	88 45 ef             	mov    %al,-0x11(%ebp)
	return data;
  1029a2:	c7 45 f0 84 00 00 00 	movl   $0x84,-0x10(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1029a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1029ac:	89 c2                	mov    %eax,%edx
  1029ae:	ec                   	in     (%dx),%al
  1029af:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
  1029b2:	c7 45 f8 84 00 00 00 	movl   $0x84,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1029b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1029bc:	89 c2                	mov    %eax,%edx
  1029be:	ec                   	in     (%dx),%al
  1029bf:	88 45 ff             	mov    %al,-0x1(%ebp)
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
  1029c2:	c9                   	leave  
  1029c3:	c3                   	ret    

001029c4 <serial_proc_data>:

static int
serial_proc_data(void)
{
  1029c4:	55                   	push   %ebp
  1029c5:	89 e5                	mov    %esp,%ebp
  1029c7:	83 ec 10             	sub    $0x10,%esp
  1029ca:	c7 45 f0 fd 03 00 00 	movl   $0x3fd,-0x10(%ebp)
  1029d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1029d4:	89 c2                	mov    %eax,%edx
  1029d6:	ec                   	in     (%dx),%al
  1029d7:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
  1029da:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
  1029de:	0f b6 c0             	movzbl %al,%eax
  1029e1:	83 e0 01             	and    $0x1,%eax
  1029e4:	85 c0                	test   %eax,%eax
  1029e6:	75 07                	jne    1029ef <serial_proc_data+0x2b>
		return -1;
  1029e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1029ed:	eb 17                	jmp    102a06 <serial_proc_data+0x42>
  1029ef:	c7 45 f8 f8 03 00 00 	movl   $0x3f8,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1029f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1029f9:	89 c2                	mov    %eax,%edx
  1029fb:	ec                   	in     (%dx),%al
  1029fc:	88 45 ff             	mov    %al,-0x1(%ebp)
	return data;
  1029ff:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
	return inb(COM1+COM_RX);
  102a03:	0f b6 c0             	movzbl %al,%eax
}
  102a06:	c9                   	leave  
  102a07:	c3                   	ret    

00102a08 <serial_intr>:

void
serial_intr(void)
{
  102a08:	55                   	push   %ebp
  102a09:	89 e5                	mov    %esp,%ebp
  102a0b:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
  102a0e:	a1 80 8f 10 00       	mov    0x108f80,%eax
  102a13:	85 c0                	test   %eax,%eax
  102a15:	74 0c                	je     102a23 <serial_intr+0x1b>
		cons_intr(serial_proc_data);
  102a17:	c7 04 24 c4 29 10 00 	movl   $0x1029c4,(%esp)
  102a1e:	e8 04 d8 ff ff       	call   100227 <cons_intr>
}
  102a23:	c9                   	leave  
  102a24:	c3                   	ret    

00102a25 <serial_putc>:

void
serial_putc(int c)
{
  102a25:	55                   	push   %ebp
  102a26:	89 e5                	mov    %esp,%ebp
  102a28:	83 ec 10             	sub    $0x10,%esp
	if (!serial_exists)
  102a2b:	a1 80 8f 10 00       	mov    0x108f80,%eax
  102a30:	85 c0                	test   %eax,%eax
  102a32:	74 53                	je     102a87 <serial_putc+0x62>
		return;

	int i;
	for (i = 0;
  102a34:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  102a3b:	eb 09                	jmp    102a46 <serial_putc+0x21>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
  102a3d:	e8 3a ff ff ff       	call   10297c <delay>
		return;

	int i;
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
  102a42:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  102a46:	c7 45 f4 fd 03 00 00 	movl   $0x3fd,-0xc(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  102a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a50:	89 c2                	mov    %eax,%edx
  102a52:	ec                   	in     (%dx),%al
  102a53:	88 45 fa             	mov    %al,-0x6(%ebp)
	return data;
  102a56:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
	if (!serial_exists)
		return;

	int i;
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  102a5a:	0f b6 c0             	movzbl %al,%eax
  102a5d:	83 e0 20             	and    $0x20,%eax
{
	if (!serial_exists)
		return;

	int i;
	for (i = 0;
  102a60:	85 c0                	test   %eax,%eax
  102a62:	75 09                	jne    102a6d <serial_putc+0x48>
  102a64:	81 7d f0 ff 31 00 00 	cmpl   $0x31ff,-0x10(%ebp)
  102a6b:	7e d0                	jle    102a3d <serial_putc+0x18>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
  102a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  102a70:	0f b6 c0             	movzbl %al,%eax
  102a73:	c7 45 fc f8 03 00 00 	movl   $0x3f8,-0x4(%ebp)
  102a7a:	88 45 fb             	mov    %al,-0x5(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  102a7d:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  102a81:	8b 55 fc             	mov    -0x4(%ebp),%edx
  102a84:	ee                   	out    %al,(%dx)
  102a85:	eb 01                	jmp    102a88 <serial_putc+0x63>

void
serial_putc(int c)
{
	if (!serial_exists)
		return;
  102a87:	90                   	nop
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
}
  102a88:	c9                   	leave  
  102a89:	c3                   	ret    

00102a8a <serial_init>:

void
serial_init(void)
{
  102a8a:	55                   	push   %ebp
  102a8b:	89 e5                	mov    %esp,%ebp
  102a8d:	83 ec 50             	sub    $0x50,%esp
  102a90:	c7 45 b4 fa 03 00 00 	movl   $0x3fa,-0x4c(%ebp)
  102a97:	c6 45 b3 00          	movb   $0x0,-0x4d(%ebp)
  102a9b:	0f b6 45 b3          	movzbl -0x4d(%ebp),%eax
  102a9f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102aa2:	ee                   	out    %al,(%dx)
  102aa3:	c7 45 bc fb 03 00 00 	movl   $0x3fb,-0x44(%ebp)
  102aaa:	c6 45 bb 80          	movb   $0x80,-0x45(%ebp)
  102aae:	0f b6 45 bb          	movzbl -0x45(%ebp),%eax
  102ab2:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102ab5:	ee                   	out    %al,(%dx)
  102ab6:	c7 45 c4 f8 03 00 00 	movl   $0x3f8,-0x3c(%ebp)
  102abd:	c6 45 c3 0c          	movb   $0xc,-0x3d(%ebp)
  102ac1:	0f b6 45 c3          	movzbl -0x3d(%ebp),%eax
  102ac5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102ac8:	ee                   	out    %al,(%dx)
  102ac9:	c7 45 cc f9 03 00 00 	movl   $0x3f9,-0x34(%ebp)
  102ad0:	c6 45 cb 00          	movb   $0x0,-0x35(%ebp)
  102ad4:	0f b6 45 cb          	movzbl -0x35(%ebp),%eax
  102ad8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102adb:	ee                   	out    %al,(%dx)
  102adc:	c7 45 d4 fb 03 00 00 	movl   $0x3fb,-0x2c(%ebp)
  102ae3:	c6 45 d3 03          	movb   $0x3,-0x2d(%ebp)
  102ae7:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
  102aeb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102aee:	ee                   	out    %al,(%dx)
  102aef:	c7 45 dc fc 03 00 00 	movl   $0x3fc,-0x24(%ebp)
  102af6:	c6 45 db 00          	movb   $0x0,-0x25(%ebp)
  102afa:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  102afe:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102b01:	ee                   	out    %al,(%dx)
  102b02:	c7 45 e4 f9 03 00 00 	movl   $0x3f9,-0x1c(%ebp)
  102b09:	c6 45 e3 01          	movb   $0x1,-0x1d(%ebp)
  102b0d:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  102b11:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102b14:	ee                   	out    %al,(%dx)
  102b15:	c7 45 e8 fd 03 00 00 	movl   $0x3fd,-0x18(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  102b1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b1f:	89 c2                	mov    %eax,%edx
  102b21:	ec                   	in     (%dx),%al
  102b22:	88 45 ef             	mov    %al,-0x11(%ebp)
	return data;
  102b25:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
  102b29:	3c ff                	cmp    $0xff,%al
  102b2b:	0f 95 c0             	setne  %al
  102b2e:	0f b6 c0             	movzbl %al,%eax
  102b31:	a3 80 8f 10 00       	mov    %eax,0x108f80
  102b36:	c7 45 f0 fa 03 00 00 	movl   $0x3fa,-0x10(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  102b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b40:	89 c2                	mov    %eax,%edx
  102b42:	ec                   	in     (%dx),%al
  102b43:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
  102b46:	c7 45 f8 f8 03 00 00 	movl   $0x3f8,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  102b4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102b50:	89 c2                	mov    %eax,%edx
  102b52:	ec                   	in     (%dx),%al
  102b53:	88 45 ff             	mov    %al,-0x1(%ebp)
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);
}
  102b56:	c9                   	leave  
  102b57:	c3                   	ret    

00102b58 <nvram_read>:
#include <dev/nvram.h>


unsigned
nvram_read(unsigned reg)
{
  102b58:	55                   	push   %ebp
  102b59:	89 e5                	mov    %esp,%ebp
  102b5b:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
  102b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  102b61:	0f b6 c0             	movzbl %al,%eax
  102b64:	c7 45 f4 70 00 00 00 	movl   $0x70,-0xc(%ebp)
  102b6b:	88 45 f3             	mov    %al,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  102b6e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  102b72:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102b75:	ee                   	out    %al,(%dx)
  102b76:	c7 45 f8 71 00 00 00 	movl   $0x71,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  102b7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102b80:	89 c2                	mov    %eax,%edx
  102b82:	ec                   	in     (%dx),%al
  102b83:	88 45 ff             	mov    %al,-0x1(%ebp)
	return data;
  102b86:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
	return inb(IO_RTC+1);
  102b8a:	0f b6 c0             	movzbl %al,%eax
}
  102b8d:	c9                   	leave  
  102b8e:	c3                   	ret    

00102b8f <nvram_read16>:

unsigned
nvram_read16(unsigned r)
{
  102b8f:	55                   	push   %ebp
  102b90:	89 e5                	mov    %esp,%ebp
  102b92:	53                   	push   %ebx
  102b93:	83 ec 04             	sub    $0x4,%esp
	return nvram_read(r) | (nvram_read(r + 1) << 8);
  102b96:	8b 45 08             	mov    0x8(%ebp),%eax
  102b99:	89 04 24             	mov    %eax,(%esp)
  102b9c:	e8 b7 ff ff ff       	call   102b58 <nvram_read>
  102ba1:	89 c3                	mov    %eax,%ebx
  102ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  102ba6:	83 c0 01             	add    $0x1,%eax
  102ba9:	89 04 24             	mov    %eax,(%esp)
  102bac:	e8 a7 ff ff ff       	call   102b58 <nvram_read>
  102bb1:	c1 e0 08             	shl    $0x8,%eax
  102bb4:	09 d8                	or     %ebx,%eax
}
  102bb6:	83 c4 04             	add    $0x4,%esp
  102bb9:	5b                   	pop    %ebx
  102bba:	5d                   	pop    %ebp
  102bbb:	c3                   	ret    

00102bbc <nvram_write>:

void
nvram_write(unsigned reg, unsigned datum)
{
  102bbc:	55                   	push   %ebp
  102bbd:	89 e5                	mov    %esp,%ebp
  102bbf:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
  102bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  102bc5:	0f b6 c0             	movzbl %al,%eax
  102bc8:	c7 45 f4 70 00 00 00 	movl   $0x70,-0xc(%ebp)
  102bcf:	88 45 f3             	mov    %al,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  102bd2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  102bd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102bd9:	ee                   	out    %al,(%dx)
	outb(IO_RTC+1, datum);
  102bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  102bdd:	0f b6 c0             	movzbl %al,%eax
  102be0:	c7 45 fc 71 00 00 00 	movl   $0x71,-0x4(%ebp)
  102be7:	88 45 fb             	mov    %al,-0x5(%ebp)
  102bea:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  102bee:	8b 55 fc             	mov    -0x4(%ebp),%edx
  102bf1:	ee                   	out    %al,(%dx)
}
  102bf2:	c9                   	leave  
  102bf3:	c3                   	ret    

00102bf4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static uintmax_t
getuint(printstate *st, va_list *ap)
{
  102bf4:	55                   	push   %ebp
  102bf5:	89 e5                	mov    %esp,%ebp
	if (st->flags & F_LL)
  102bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  102bfa:	8b 40 18             	mov    0x18(%eax),%eax
  102bfd:	83 e0 02             	and    $0x2,%eax
  102c00:	85 c0                	test   %eax,%eax
  102c02:	74 1c                	je     102c20 <getuint+0x2c>
		return va_arg(*ap, unsigned long long);
  102c04:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c07:	8b 00                	mov    (%eax),%eax
  102c09:	8d 50 08             	lea    0x8(%eax),%edx
  102c0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c0f:	89 10                	mov    %edx,(%eax)
  102c11:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c14:	8b 00                	mov    (%eax),%eax
  102c16:	83 e8 08             	sub    $0x8,%eax
  102c19:	8b 50 04             	mov    0x4(%eax),%edx
  102c1c:	8b 00                	mov    (%eax),%eax
  102c1e:	eb 47                	jmp    102c67 <getuint+0x73>
	else if (st->flags & F_L)
  102c20:	8b 45 08             	mov    0x8(%ebp),%eax
  102c23:	8b 40 18             	mov    0x18(%eax),%eax
  102c26:	83 e0 01             	and    $0x1,%eax
  102c29:	84 c0                	test   %al,%al
  102c2b:	74 1e                	je     102c4b <getuint+0x57>
		return va_arg(*ap, unsigned long);
  102c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c30:	8b 00                	mov    (%eax),%eax
  102c32:	8d 50 04             	lea    0x4(%eax),%edx
  102c35:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c38:	89 10                	mov    %edx,(%eax)
  102c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c3d:	8b 00                	mov    (%eax),%eax
  102c3f:	83 e8 04             	sub    $0x4,%eax
  102c42:	8b 00                	mov    (%eax),%eax
  102c44:	ba 00 00 00 00       	mov    $0x0,%edx
  102c49:	eb 1c                	jmp    102c67 <getuint+0x73>
	else
		return va_arg(*ap, unsigned int);
  102c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c4e:	8b 00                	mov    (%eax),%eax
  102c50:	8d 50 04             	lea    0x4(%eax),%edx
  102c53:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c56:	89 10                	mov    %edx,(%eax)
  102c58:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c5b:	8b 00                	mov    (%eax),%eax
  102c5d:	83 e8 04             	sub    $0x4,%eax
  102c60:	8b 00                	mov    (%eax),%eax
  102c62:	ba 00 00 00 00       	mov    $0x0,%edx
}
  102c67:	5d                   	pop    %ebp
  102c68:	c3                   	ret    

00102c69 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static intmax_t
getint(printstate *st, va_list *ap)
{
  102c69:	55                   	push   %ebp
  102c6a:	89 e5                	mov    %esp,%ebp
	if (st->flags & F_LL)
  102c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  102c6f:	8b 40 18             	mov    0x18(%eax),%eax
  102c72:	83 e0 02             	and    $0x2,%eax
  102c75:	85 c0                	test   %eax,%eax
  102c77:	74 1c                	je     102c95 <getint+0x2c>
		return va_arg(*ap, long long);
  102c79:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c7c:	8b 00                	mov    (%eax),%eax
  102c7e:	8d 50 08             	lea    0x8(%eax),%edx
  102c81:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c84:	89 10                	mov    %edx,(%eax)
  102c86:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c89:	8b 00                	mov    (%eax),%eax
  102c8b:	83 e8 08             	sub    $0x8,%eax
  102c8e:	8b 50 04             	mov    0x4(%eax),%edx
  102c91:	8b 00                	mov    (%eax),%eax
  102c93:	eb 47                	jmp    102cdc <getint+0x73>
	else if (st->flags & F_L)
  102c95:	8b 45 08             	mov    0x8(%ebp),%eax
  102c98:	8b 40 18             	mov    0x18(%eax),%eax
  102c9b:	83 e0 01             	and    $0x1,%eax
  102c9e:	84 c0                	test   %al,%al
  102ca0:	74 1e                	je     102cc0 <getint+0x57>
		return va_arg(*ap, long);
  102ca2:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ca5:	8b 00                	mov    (%eax),%eax
  102ca7:	8d 50 04             	lea    0x4(%eax),%edx
  102caa:	8b 45 0c             	mov    0xc(%ebp),%eax
  102cad:	89 10                	mov    %edx,(%eax)
  102caf:	8b 45 0c             	mov    0xc(%ebp),%eax
  102cb2:	8b 00                	mov    (%eax),%eax
  102cb4:	83 e8 04             	sub    $0x4,%eax
  102cb7:	8b 00                	mov    (%eax),%eax
  102cb9:	89 c2                	mov    %eax,%edx
  102cbb:	c1 fa 1f             	sar    $0x1f,%edx
  102cbe:	eb 1c                	jmp    102cdc <getint+0x73>
	else
		return va_arg(*ap, int);
  102cc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  102cc3:	8b 00                	mov    (%eax),%eax
  102cc5:	8d 50 04             	lea    0x4(%eax),%edx
  102cc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ccb:	89 10                	mov    %edx,(%eax)
  102ccd:	8b 45 0c             	mov    0xc(%ebp),%eax
  102cd0:	8b 00                	mov    (%eax),%eax
  102cd2:	83 e8 04             	sub    $0x4,%eax
  102cd5:	8b 00                	mov    (%eax),%eax
  102cd7:	89 c2                	mov    %eax,%edx
  102cd9:	c1 fa 1f             	sar    $0x1f,%edx
}
  102cdc:	5d                   	pop    %ebp
  102cdd:	c3                   	ret    

00102cde <putpad>:

// Print padding characters, and an optional sign before a number.
static void
putpad(printstate *st)
{
  102cde:	55                   	push   %ebp
  102cdf:	89 e5                	mov    %esp,%ebp
  102ce1:	83 ec 18             	sub    $0x18,%esp
	while (--st->width >= 0)
  102ce4:	eb 1a                	jmp    102d00 <putpad+0x22>
		st->putch(st->padc, st->putdat);
  102ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  102ce9:	8b 08                	mov    (%eax),%ecx
  102ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  102cee:	8b 50 04             	mov    0x4(%eax),%edx
  102cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  102cf4:	8b 40 08             	mov    0x8(%eax),%eax
  102cf7:	89 54 24 04          	mov    %edx,0x4(%esp)
  102cfb:	89 04 24             	mov    %eax,(%esp)
  102cfe:	ff d1                	call   *%ecx

// Print padding characters, and an optional sign before a number.
static void
putpad(printstate *st)
{
	while (--st->width >= 0)
  102d00:	8b 45 08             	mov    0x8(%ebp),%eax
  102d03:	8b 40 0c             	mov    0xc(%eax),%eax
  102d06:	8d 50 ff             	lea    -0x1(%eax),%edx
  102d09:	8b 45 08             	mov    0x8(%ebp),%eax
  102d0c:	89 50 0c             	mov    %edx,0xc(%eax)
  102d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  102d12:	8b 40 0c             	mov    0xc(%eax),%eax
  102d15:	85 c0                	test   %eax,%eax
  102d17:	79 cd                	jns    102ce6 <putpad+0x8>
		st->putch(st->padc, st->putdat);
}
  102d19:	c9                   	leave  
  102d1a:	c3                   	ret    

00102d1b <putstr>:

// Print a string with a specified maximum length (-1=unlimited),
// with any appropriate left or right field padding.
static void
putstr(printstate *st, const char *str, int maxlen)
{
  102d1b:	55                   	push   %ebp
  102d1c:	89 e5                	mov    %esp,%ebp
  102d1e:	53                   	push   %ebx
  102d1f:	83 ec 24             	sub    $0x24,%esp
	const char *lim;		// find where the string actually ends
	if (maxlen < 0)
  102d22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102d26:	79 18                	jns    102d40 <putstr+0x25>
		lim = strchr(str, 0);	// find the terminating null
  102d28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102d2f:	00 
  102d30:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d33:	89 04 24             	mov    %eax,(%esp)
  102d36:	e8 e9 07 00 00       	call   103524 <strchr>
  102d3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102d3e:	eb 2c                	jmp    102d6c <putstr+0x51>
	else if ((lim = memchr(str, 0, maxlen)) == NULL)
  102d40:	8b 45 10             	mov    0x10(%ebp),%eax
  102d43:	89 44 24 08          	mov    %eax,0x8(%esp)
  102d47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102d4e:	00 
  102d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d52:	89 04 24             	mov    %eax,(%esp)
  102d55:	e8 ce 09 00 00       	call   103728 <memchr>
  102d5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102d5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102d61:	75 09                	jne    102d6c <putstr+0x51>
		lim = str + maxlen;
  102d63:	8b 45 10             	mov    0x10(%ebp),%eax
  102d66:	03 45 0c             	add    0xc(%ebp),%eax
  102d69:	89 45 f0             	mov    %eax,-0x10(%ebp)
	st->width -= (lim-str);		// deduct string length from field width
  102d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  102d6f:	8b 40 0c             	mov    0xc(%eax),%eax
  102d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  102d75:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102d78:	89 cb                	mov    %ecx,%ebx
  102d7a:	29 d3                	sub    %edx,%ebx
  102d7c:	89 da                	mov    %ebx,%edx
  102d7e:	8d 14 10             	lea    (%eax,%edx,1),%edx
  102d81:	8b 45 08             	mov    0x8(%ebp),%eax
  102d84:	89 50 0c             	mov    %edx,0xc(%eax)

	if (!(st->flags & F_RPAD))	// print left-side padding
  102d87:	8b 45 08             	mov    0x8(%ebp),%eax
  102d8a:	8b 40 18             	mov    0x18(%eax),%eax
  102d8d:	83 e0 10             	and    $0x10,%eax
  102d90:	85 c0                	test   %eax,%eax
  102d92:	75 32                	jne    102dc6 <putstr+0xab>
		putpad(st);		// (also leaves st->width == 0)
  102d94:	8b 45 08             	mov    0x8(%ebp),%eax
  102d97:	89 04 24             	mov    %eax,(%esp)
  102d9a:	e8 3f ff ff ff       	call   102cde <putpad>
	while (str < lim) {
  102d9f:	eb 25                	jmp    102dc6 <putstr+0xab>
		char ch = *str++;
  102da1:	8b 45 0c             	mov    0xc(%ebp),%eax
  102da4:	0f b6 00             	movzbl (%eax),%eax
  102da7:	88 45 f7             	mov    %al,-0x9(%ebp)
  102daa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
			st->putch(ch, st->putdat);
  102dae:	8b 45 08             	mov    0x8(%ebp),%eax
  102db1:	8b 08                	mov    (%eax),%ecx
  102db3:	8b 45 08             	mov    0x8(%ebp),%eax
  102db6:	8b 50 04             	mov    0x4(%eax),%edx
  102db9:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  102dbd:	89 54 24 04          	mov    %edx,0x4(%esp)
  102dc1:	89 04 24             	mov    %eax,(%esp)
  102dc4:	ff d1                	call   *%ecx
		lim = str + maxlen;
	st->width -= (lim-str);		// deduct string length from field width

	if (!(st->flags & F_RPAD))	// print left-side padding
		putpad(st);		// (also leaves st->width == 0)
	while (str < lim) {
  102dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  102dc9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102dcc:	72 d3                	jb     102da1 <putstr+0x86>
		char ch = *str++;
			st->putch(ch, st->putdat);
	}
	putpad(st);			// print right-side padding
  102dce:	8b 45 08             	mov    0x8(%ebp),%eax
  102dd1:	89 04 24             	mov    %eax,(%esp)
  102dd4:	e8 05 ff ff ff       	call   102cde <putpad>
}
  102dd9:	83 c4 24             	add    $0x24,%esp
  102ddc:	5b                   	pop    %ebx
  102ddd:	5d                   	pop    %ebp
  102dde:	c3                   	ret    

00102ddf <genint>:

// Generate a number (base <= 16) in reverse order into a string buffer.
static char *
genint(printstate *st, char *p, uintmax_t num)
{
  102ddf:	55                   	push   %ebp
  102de0:	89 e5                	mov    %esp,%ebp
  102de2:	53                   	push   %ebx
  102de3:	83 ec 24             	sub    $0x24,%esp
  102de6:	8b 45 10             	mov    0x10(%ebp),%eax
  102de9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102dec:	8b 45 14             	mov    0x14(%ebp),%eax
  102def:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= st->base)
  102df2:	8b 45 08             	mov    0x8(%ebp),%eax
  102df5:	8b 40 1c             	mov    0x1c(%eax),%eax
  102df8:	89 c2                	mov    %eax,%edx
  102dfa:	c1 fa 1f             	sar    $0x1f,%edx
  102dfd:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  102e00:	77 4e                	ja     102e50 <genint+0x71>
  102e02:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  102e05:	72 05                	jb     102e0c <genint+0x2d>
  102e07:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102e0a:	77 44                	ja     102e50 <genint+0x71>
		p = genint(st, p, num / st->base);	// output higher digits
  102e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  102e0f:	8b 40 1c             	mov    0x1c(%eax),%eax
  102e12:	89 c2                	mov    %eax,%edx
  102e14:	c1 fa 1f             	sar    $0x1f,%edx
  102e17:	89 44 24 08          	mov    %eax,0x8(%esp)
  102e1b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102e25:	89 04 24             	mov    %eax,(%esp)
  102e28:	89 54 24 04          	mov    %edx,0x4(%esp)
  102e2c:	e8 3f 09 00 00       	call   103770 <__udivdi3>
  102e31:	89 44 24 08          	mov    %eax,0x8(%esp)
  102e35:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102e39:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e40:	8b 45 08             	mov    0x8(%ebp),%eax
  102e43:	89 04 24             	mov    %eax,(%esp)
  102e46:	e8 94 ff ff ff       	call   102ddf <genint>
  102e4b:	89 45 0c             	mov    %eax,0xc(%ebp)
  102e4e:	eb 1b                	jmp    102e6b <genint+0x8c>
	else if (st->signc >= 0)
  102e50:	8b 45 08             	mov    0x8(%ebp),%eax
  102e53:	8b 40 14             	mov    0x14(%eax),%eax
  102e56:	85 c0                	test   %eax,%eax
  102e58:	78 11                	js     102e6b <genint+0x8c>
		*p++ = st->signc;			// output leading sign
  102e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  102e5d:	8b 40 14             	mov    0x14(%eax),%eax
  102e60:	89 c2                	mov    %eax,%edx
  102e62:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e65:	88 10                	mov    %dl,(%eax)
  102e67:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	*p++ = "0123456789abcdef"[num % st->base];	// output this digit
  102e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  102e6e:	8b 40 1c             	mov    0x1c(%eax),%eax
  102e71:	89 c1                	mov    %eax,%ecx
  102e73:	89 c3                	mov    %eax,%ebx
  102e75:	c1 fb 1f             	sar    $0x1f,%ebx
  102e78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102e7e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  102e82:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  102e86:	89 04 24             	mov    %eax,(%esp)
  102e89:	89 54 24 04          	mov    %edx,0x4(%esp)
  102e8d:	e8 0e 0a 00 00       	call   1038a0 <__umoddi3>
  102e92:	05 dc 43 10 00       	add    $0x1043dc,%eax
  102e97:	0f b6 10             	movzbl (%eax),%edx
  102e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e9d:	88 10                	mov    %dl,(%eax)
  102e9f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	return p;
  102ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
}
  102ea6:	83 c4 24             	add    $0x24,%esp
  102ea9:	5b                   	pop    %ebx
  102eaa:	5d                   	pop    %ebp
  102eab:	c3                   	ret    

00102eac <putint>:

// Print an integer with any appropriate field padding.
static void
putint(printstate *st, uintmax_t num, int base)
{
  102eac:	55                   	push   %ebp
  102ead:	89 e5                	mov    %esp,%ebp
  102eaf:	83 ec 58             	sub    $0x58,%esp
  102eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  102eb5:	89 45 c0             	mov    %eax,-0x40(%ebp)
  102eb8:	8b 45 10             	mov    0x10(%ebp),%eax
  102ebb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	char buf[30], *p = buf;		// big enough for any 64-bit int in octal
  102ebe:	8d 45 d6             	lea    -0x2a(%ebp),%eax
  102ec1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	st->base = base;		// select base for genint
  102ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  102ec7:	8b 55 14             	mov    0x14(%ebp),%edx
  102eca:	89 50 1c             	mov    %edx,0x1c(%eax)
	p = genint(st, p, num);		// output to the string buffer
  102ecd:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102ed0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102ed3:	89 44 24 08          	mov    %eax,0x8(%esp)
  102ed7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ede:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  102ee5:	89 04 24             	mov    %eax,(%esp)
  102ee8:	e8 f2 fe ff ff       	call   102ddf <genint>
  102eed:	89 45 f4             	mov    %eax,-0xc(%ebp)
	putstr(st, buf, p-buf);		// print it with left/right padding
  102ef0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102ef3:	8d 45 d6             	lea    -0x2a(%ebp),%eax
  102ef6:	89 d1                	mov    %edx,%ecx
  102ef8:	29 c1                	sub    %eax,%ecx
  102efa:	89 c8                	mov    %ecx,%eax
  102efc:	89 44 24 08          	mov    %eax,0x8(%esp)
  102f00:	8d 45 d6             	lea    -0x2a(%ebp),%eax
  102f03:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f07:	8b 45 08             	mov    0x8(%ebp),%eax
  102f0a:	89 04 24             	mov    %eax,(%esp)
  102f0d:	e8 09 fe ff ff       	call   102d1b <putstr>
}
  102f12:	c9                   	leave  
  102f13:	c3                   	ret    

00102f14 <vprintfmt>:
#endif	// ! PIOS_KERNEL

// Main function to format and print a string.
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  102f14:	55                   	push   %ebp
  102f15:	89 e5                	mov    %esp,%ebp
  102f17:	53                   	push   %ebx
  102f18:	83 ec 44             	sub    $0x44,%esp
	register int ch, err;

	printstate st = { .putch = putch, .putdat = putdat };
  102f1b:	8d 55 c8             	lea    -0x38(%ebp),%edx
  102f1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  102f23:	b8 20 00 00 00       	mov    $0x20,%eax
  102f28:	89 c3                	mov    %eax,%ebx
  102f2a:	83 e3 fc             	and    $0xfffffffc,%ebx
  102f2d:	b8 00 00 00 00       	mov    $0x0,%eax
  102f32:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
  102f35:	83 c0 04             	add    $0x4,%eax
  102f38:	39 d8                	cmp    %ebx,%eax
  102f3a:	72 f6                	jb     102f32 <vprintfmt+0x1e>
  102f3c:	01 c2                	add    %eax,%edx
  102f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  102f41:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102f44:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f47:	89 45 cc             	mov    %eax,-0x34(%ebp)
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  102f4a:	eb 17                	jmp    102f63 <vprintfmt+0x4f>
			if (ch == '\0')
  102f4c:	85 db                	test   %ebx,%ebx
  102f4e:	0f 84 52 03 00 00    	je     1032a6 <vprintfmt+0x392>
				return;
			putch(ch, putdat);
  102f54:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f57:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f5b:	89 1c 24             	mov    %ebx,(%esp)
  102f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  102f61:	ff d0                	call   *%eax
{
	register int ch, err;

	printstate st = { .putch = putch, .putdat = putdat };
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  102f63:	8b 45 10             	mov    0x10(%ebp),%eax
  102f66:	0f b6 00             	movzbl (%eax),%eax
  102f69:	0f b6 d8             	movzbl %al,%ebx
  102f6c:	83 fb 25             	cmp    $0x25,%ebx
  102f6f:	0f 95 c0             	setne  %al
  102f72:	83 45 10 01          	addl   $0x1,0x10(%ebp)
  102f76:	84 c0                	test   %al,%al
  102f78:	75 d2                	jne    102f4c <vprintfmt+0x38>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		st.padc = ' ';
  102f7a:	c7 45 d0 20 00 00 00 	movl   $0x20,-0x30(%ebp)
		st.width = -1;
  102f81:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		st.prec = -1;
  102f88:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		st.signc = -1;
  102f8f:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		st.flags = 0;
  102f96:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		st.base = 10;
  102f9d:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
  102fa4:	eb 04                	jmp    102faa <vprintfmt+0x96>
			goto reswitch;

		case ' ': // prefix signless numeric values with a space
			if (st.signc < 0)	// (but only if no '+' is specified)
				st.signc = ' ';
			goto reswitch;
  102fa6:	90                   	nop
  102fa7:	eb 01                	jmp    102faa <vprintfmt+0x96>
		gotprec:
			if (!(st.flags & F_DOT)) {	// haven't seen a '.' yet?
				st.width = st.prec;	// then it's a field width
				st.prec = -1;
			}
			goto reswitch;
  102fa9:	90                   	nop
		st.signc = -1;
		st.flags = 0;
		st.base = 10;
		uintmax_t num;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  102faa:	8b 45 10             	mov    0x10(%ebp),%eax
  102fad:	0f b6 00             	movzbl (%eax),%eax
  102fb0:	0f b6 d8             	movzbl %al,%ebx
  102fb3:	89 d8                	mov    %ebx,%eax
  102fb5:	83 45 10 01          	addl   $0x1,0x10(%ebp)
  102fb9:	83 e8 20             	sub    $0x20,%eax
  102fbc:	83 f8 58             	cmp    $0x58,%eax
  102fbf:	0f 87 b1 02 00 00    	ja     103276 <vprintfmt+0x362>
  102fc5:	8b 04 85 f4 43 10 00 	mov    0x1043f4(,%eax,4),%eax
  102fcc:	ff e0                	jmp    *%eax

		// modifier flags
		case '-': // pad on the right instead of the left
			st.flags |= F_RPAD;
  102fce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102fd1:	83 c8 10             	or     $0x10,%eax
  102fd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  102fd7:	eb d1                	jmp    102faa <vprintfmt+0x96>

		case '+': // prefix positive numeric values with a '+' sign
			st.signc = '+';
  102fd9:	c7 45 dc 2b 00 00 00 	movl   $0x2b,-0x24(%ebp)
			goto reswitch;
  102fe0:	eb c8                	jmp    102faa <vprintfmt+0x96>

		case ' ': // prefix signless numeric values with a space
			if (st.signc < 0)	// (but only if no '+' is specified)
  102fe2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102fe5:	85 c0                	test   %eax,%eax
  102fe7:	79 bd                	jns    102fa6 <vprintfmt+0x92>
				st.signc = ' ';
  102fe9:	c7 45 dc 20 00 00 00 	movl   $0x20,-0x24(%ebp)
			goto reswitch;
  102ff0:	eb b8                	jmp    102faa <vprintfmt+0x96>

		// width or precision field
		case '0':
			if (!(st.flags & F_DOT))
  102ff2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ff5:	83 e0 08             	and    $0x8,%eax
  102ff8:	85 c0                	test   %eax,%eax
  102ffa:	75 07                	jne    103003 <vprintfmt+0xef>
				st.padc = '0'; // pad with 0's instead of spaces
  102ffc:	c7 45 d0 30 00 00 00 	movl   $0x30,-0x30(%ebp)
		case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9':
			for (st.prec = 0; ; ++fmt) {
  103003:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
				st.prec = st.prec * 10 + ch - '0';
  10300a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10300d:	89 d0                	mov    %edx,%eax
  10300f:	c1 e0 02             	shl    $0x2,%eax
  103012:	01 d0                	add    %edx,%eax
  103014:	01 c0                	add    %eax,%eax
  103016:	01 d8                	add    %ebx,%eax
  103018:	83 e8 30             	sub    $0x30,%eax
  10301b:	89 45 d8             	mov    %eax,-0x28(%ebp)
				ch = *fmt;
  10301e:	8b 45 10             	mov    0x10(%ebp),%eax
  103021:	0f b6 00             	movzbl (%eax),%eax
  103024:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  103027:	83 fb 2f             	cmp    $0x2f,%ebx
  10302a:	7e 21                	jle    10304d <vprintfmt+0x139>
  10302c:	83 fb 39             	cmp    $0x39,%ebx
  10302f:	7f 1f                	jg     103050 <vprintfmt+0x13c>
		case '0':
			if (!(st.flags & F_DOT))
				st.padc = '0'; // pad with 0's instead of spaces
		case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9':
			for (st.prec = 0; ; ++fmt) {
  103031:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				st.prec = st.prec * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  103035:	eb d3                	jmp    10300a <vprintfmt+0xf6>
			goto gotprec;

		case '*':
			st.prec = va_arg(ap, int);
  103037:	8b 45 14             	mov    0x14(%ebp),%eax
  10303a:	83 c0 04             	add    $0x4,%eax
  10303d:	89 45 14             	mov    %eax,0x14(%ebp)
  103040:	8b 45 14             	mov    0x14(%ebp),%eax
  103043:	83 e8 04             	sub    $0x4,%eax
  103046:	8b 00                	mov    (%eax),%eax
  103048:	89 45 d8             	mov    %eax,-0x28(%ebp)
  10304b:	eb 04                	jmp    103051 <vprintfmt+0x13d>
				st.prec = st.prec * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto gotprec;
  10304d:	90                   	nop
  10304e:	eb 01                	jmp    103051 <vprintfmt+0x13d>
  103050:	90                   	nop

		case '*':
			st.prec = va_arg(ap, int);
		gotprec:
			if (!(st.flags & F_DOT)) {	// haven't seen a '.' yet?
  103051:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103054:	83 e0 08             	and    $0x8,%eax
  103057:	85 c0                	test   %eax,%eax
  103059:	0f 85 4a ff ff ff    	jne    102fa9 <vprintfmt+0x95>
				st.width = st.prec;	// then it's a field width
  10305f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103062:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				st.prec = -1;
  103065:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
			}
			goto reswitch;
  10306c:	e9 39 ff ff ff       	jmp    102faa <vprintfmt+0x96>

		case '.':
			st.flags |= F_DOT;
  103071:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103074:	83 c8 08             	or     $0x8,%eax
  103077:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  10307a:	e9 2b ff ff ff       	jmp    102faa <vprintfmt+0x96>

		case '#':
			st.flags |= F_ALT;
  10307f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103082:	83 c8 04             	or     $0x4,%eax
  103085:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  103088:	e9 1d ff ff ff       	jmp    102faa <vprintfmt+0x96>

		// long flag (doubled for long long)
		case 'l':
			st.flags |= (st.flags & F_L) ? F_LL : F_L;
  10308d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103090:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103093:	83 e0 01             	and    $0x1,%eax
  103096:	84 c0                	test   %al,%al
  103098:	74 07                	je     1030a1 <vprintfmt+0x18d>
  10309a:	b8 02 00 00 00       	mov    $0x2,%eax
  10309f:	eb 05                	jmp    1030a6 <vprintfmt+0x192>
  1030a1:	b8 01 00 00 00       	mov    $0x1,%eax
  1030a6:	09 d0                	or     %edx,%eax
  1030a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  1030ab:	e9 fa fe ff ff       	jmp    102faa <vprintfmt+0x96>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  1030b0:	8b 45 14             	mov    0x14(%ebp),%eax
  1030b3:	83 c0 04             	add    $0x4,%eax
  1030b6:	89 45 14             	mov    %eax,0x14(%ebp)
  1030b9:	8b 45 14             	mov    0x14(%ebp),%eax
  1030bc:	83 e8 04             	sub    $0x4,%eax
  1030bf:	8b 00                	mov    (%eax),%eax
  1030c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  1030c4:	89 54 24 04          	mov    %edx,0x4(%esp)
  1030c8:	89 04 24             	mov    %eax,(%esp)
  1030cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1030ce:	ff d0                	call   *%eax
			break;
  1030d0:	e9 cb 01 00 00       	jmp    1032a0 <vprintfmt+0x38c>

		// string
		case 's': {
			const char *s;
			if ((s = va_arg(ap, char *)) == NULL)
  1030d5:	8b 45 14             	mov    0x14(%ebp),%eax
  1030d8:	83 c0 04             	add    $0x4,%eax
  1030db:	89 45 14             	mov    %eax,0x14(%ebp)
  1030de:	8b 45 14             	mov    0x14(%ebp),%eax
  1030e1:	83 e8 04             	sub    $0x4,%eax
  1030e4:	8b 00                	mov    (%eax),%eax
  1030e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1030e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1030ed:	75 07                	jne    1030f6 <vprintfmt+0x1e2>
				s = "(null)";
  1030ef:	c7 45 f4 ed 43 10 00 	movl   $0x1043ed,-0xc(%ebp)
			putstr(&st, s, st.prec);
  1030f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1030f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1030fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103100:	89 44 24 04          	mov    %eax,0x4(%esp)
  103104:	8d 45 c8             	lea    -0x38(%ebp),%eax
  103107:	89 04 24             	mov    %eax,(%esp)
  10310a:	e8 0c fc ff ff       	call   102d1b <putstr>
			break;
  10310f:	e9 8c 01 00 00       	jmp    1032a0 <vprintfmt+0x38c>
		    }

		// (signed) decimal
		case 'd':
			num = getint(&st, &ap);
  103114:	8d 45 14             	lea    0x14(%ebp),%eax
  103117:	89 44 24 04          	mov    %eax,0x4(%esp)
  10311b:	8d 45 c8             	lea    -0x38(%ebp),%eax
  10311e:	89 04 24             	mov    %eax,(%esp)
  103121:	e8 43 fb ff ff       	call   102c69 <getint>
  103126:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103129:	89 55 ec             	mov    %edx,-0x14(%ebp)
			if ((intmax_t) num < 0) {
  10312c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10312f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103132:	85 d2                	test   %edx,%edx
  103134:	79 1a                	jns    103150 <vprintfmt+0x23c>
				num = -(intmax_t) num;
  103136:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103139:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10313c:	f7 d8                	neg    %eax
  10313e:	83 d2 00             	adc    $0x0,%edx
  103141:	f7 da                	neg    %edx
  103143:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103146:	89 55 ec             	mov    %edx,-0x14(%ebp)
				st.signc = '-';
  103149:	c7 45 dc 2d 00 00 00 	movl   $0x2d,-0x24(%ebp)
			}
			putint(&st, num, 10);
  103150:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  103157:	00 
  103158:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10315b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10315e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103162:	89 54 24 08          	mov    %edx,0x8(%esp)
  103166:	8d 45 c8             	lea    -0x38(%ebp),%eax
  103169:	89 04 24             	mov    %eax,(%esp)
  10316c:	e8 3b fd ff ff       	call   102eac <putint>
			break;
  103171:	e9 2a 01 00 00       	jmp    1032a0 <vprintfmt+0x38c>

		// unsigned decimal
		case 'u':
			putint(&st, getuint(&st, &ap), 10);
  103176:	8d 45 14             	lea    0x14(%ebp),%eax
  103179:	89 44 24 04          	mov    %eax,0x4(%esp)
  10317d:	8d 45 c8             	lea    -0x38(%ebp),%eax
  103180:	89 04 24             	mov    %eax,(%esp)
  103183:	e8 6c fa ff ff       	call   102bf4 <getuint>
  103188:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  10318f:	00 
  103190:	89 44 24 04          	mov    %eax,0x4(%esp)
  103194:	89 54 24 08          	mov    %edx,0x8(%esp)
  103198:	8d 45 c8             	lea    -0x38(%ebp),%eax
  10319b:	89 04 24             	mov    %eax,(%esp)
  10319e:	e8 09 fd ff ff       	call   102eac <putint>
			break;
  1031a3:	e9 f8 00 00 00       	jmp    1032a0 <vprintfmt+0x38c>

		// (unsigned) octal
		case 'o':
			putint(&st, getuint(&st, &ap), 8);
  1031a8:	8d 45 14             	lea    0x14(%ebp),%eax
  1031ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031af:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1031b2:	89 04 24             	mov    %eax,(%esp)
  1031b5:	e8 3a fa ff ff       	call   102bf4 <getuint>
  1031ba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  1031c1:	00 
  1031c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031c6:	89 54 24 08          	mov    %edx,0x8(%esp)
  1031ca:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1031cd:	89 04 24             	mov    %eax,(%esp)
  1031d0:	e8 d7 fc ff ff       	call   102eac <putint>
			break;
  1031d5:	e9 c6 00 00 00       	jmp    1032a0 <vprintfmt+0x38c>

		// (unsigned) hexadecimal
		case 'x':
			putint(&st, getuint(&st, &ap), 16);
  1031da:	8d 45 14             	lea    0x14(%ebp),%eax
  1031dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031e1:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1031e4:	89 04 24             	mov    %eax,(%esp)
  1031e7:	e8 08 fa ff ff       	call   102bf4 <getuint>
  1031ec:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  1031f3:	00 
  1031f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031f8:	89 54 24 08          	mov    %edx,0x8(%esp)
  1031fc:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1031ff:	89 04 24             	mov    %eax,(%esp)
  103202:	e8 a5 fc ff ff       	call   102eac <putint>
			break;
  103207:	e9 94 00 00 00       	jmp    1032a0 <vprintfmt+0x38c>

		// pointer
		case 'p':
			putch('0', putdat);
  10320c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10320f:	89 44 24 04          	mov    %eax,0x4(%esp)
  103213:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  10321a:	8b 45 08             	mov    0x8(%ebp),%eax
  10321d:	ff d0                	call   *%eax
			putch('x', putdat);
  10321f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103222:	89 44 24 04          	mov    %eax,0x4(%esp)
  103226:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  10322d:	8b 45 08             	mov    0x8(%ebp),%eax
  103230:	ff d0                	call   *%eax
			putint(&st, (uintptr_t) va_arg(ap, void *), 16);
  103232:	8b 45 14             	mov    0x14(%ebp),%eax
  103235:	83 c0 04             	add    $0x4,%eax
  103238:	89 45 14             	mov    %eax,0x14(%ebp)
  10323b:	8b 45 14             	mov    0x14(%ebp),%eax
  10323e:	83 e8 04             	sub    $0x4,%eax
  103241:	8b 00                	mov    (%eax),%eax
  103243:	ba 00 00 00 00       	mov    $0x0,%edx
  103248:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  10324f:	00 
  103250:	89 44 24 04          	mov    %eax,0x4(%esp)
  103254:	89 54 24 08          	mov    %edx,0x8(%esp)
  103258:	8d 45 c8             	lea    -0x38(%ebp),%eax
  10325b:	89 04 24             	mov    %eax,(%esp)
  10325e:	e8 49 fc ff ff       	call   102eac <putint>
			break;
  103263:	eb 3b                	jmp    1032a0 <vprintfmt+0x38c>
		    }
#endif	// ! PIOS_KERNEL

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  103265:	8b 45 0c             	mov    0xc(%ebp),%eax
  103268:	89 44 24 04          	mov    %eax,0x4(%esp)
  10326c:	89 1c 24             	mov    %ebx,(%esp)
  10326f:	8b 45 08             	mov    0x8(%ebp),%eax
  103272:	ff d0                	call   *%eax
			break;
  103274:	eb 2a                	jmp    1032a0 <vprintfmt+0x38c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  103276:	8b 45 0c             	mov    0xc(%ebp),%eax
  103279:	89 44 24 04          	mov    %eax,0x4(%esp)
  10327d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  103284:	8b 45 08             	mov    0x8(%ebp),%eax
  103287:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  103289:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10328d:	eb 04                	jmp    103293 <vprintfmt+0x37f>
  10328f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  103293:	8b 45 10             	mov    0x10(%ebp),%eax
  103296:	83 e8 01             	sub    $0x1,%eax
  103299:	0f b6 00             	movzbl (%eax),%eax
  10329c:	3c 25                	cmp    $0x25,%al
  10329e:	75 ef                	jne    10328f <vprintfmt+0x37b>
				/* do nothing */;
			break;
		}
	}
  1032a0:	90                   	nop
{
	register int ch, err;

	printstate st = { .putch = putch, .putdat = putdat };
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  1032a1:	e9 bd fc ff ff       	jmp    102f63 <vprintfmt+0x4f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  1032a6:	83 c4 44             	add    $0x44,%esp
  1032a9:	5b                   	pop    %ebx
  1032aa:	5d                   	pop    %ebp
  1032ab:	c3                   	ret    

001032ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  1032ac:	55                   	push   %ebp
  1032ad:	89 e5                	mov    %esp,%ebp
  1032af:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  1032b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032b5:	8b 00                	mov    (%eax),%eax
  1032b7:	8b 55 08             	mov    0x8(%ebp),%edx
  1032ba:	89 d1                	mov    %edx,%ecx
  1032bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  1032bf:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
  1032c3:	8d 50 01             	lea    0x1(%eax),%edx
  1032c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032c9:	89 10                	mov    %edx,(%eax)
	if (b->idx == CPUTS_MAX-1) {
  1032cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032ce:	8b 00                	mov    (%eax),%eax
  1032d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  1032d5:	75 24                	jne    1032fb <putch+0x4f>
		b->buf[b->idx] = 0;
  1032d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032da:	8b 00                	mov    (%eax),%eax
  1032dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  1032df:	c6 44 02 08 00       	movb   $0x0,0x8(%edx,%eax,1)
		cputs(b->buf);
  1032e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032e7:	83 c0 08             	add    $0x8,%eax
  1032ea:	89 04 24             	mov    %eax,(%esp)
  1032ed:	e8 43 d0 ff ff       	call   100335 <cputs>
		b->idx = 0;
  1032f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  1032fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032fe:	8b 40 04             	mov    0x4(%eax),%eax
  103301:	8d 50 01             	lea    0x1(%eax),%edx
  103304:	8b 45 0c             	mov    0xc(%ebp),%eax
  103307:	89 50 04             	mov    %edx,0x4(%eax)
}
  10330a:	c9                   	leave  
  10330b:	c3                   	ret    

0010330c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  10330c:	55                   	push   %ebp
  10330d:	89 e5                	mov    %esp,%ebp
  10330f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  103315:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  10331c:	00 00 00 
	b.cnt = 0;
  10331f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  103326:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  103329:	b8 ac 32 10 00       	mov    $0x1032ac,%eax
  10332e:	8b 55 0c             	mov    0xc(%ebp),%edx
  103331:	89 54 24 0c          	mov    %edx,0xc(%esp)
  103335:	8b 55 08             	mov    0x8(%ebp),%edx
  103338:	89 54 24 08          	mov    %edx,0x8(%esp)
  10333c:	8d 95 f0 fe ff ff    	lea    -0x110(%ebp),%edx
  103342:	89 54 24 04          	mov    %edx,0x4(%esp)
  103346:	89 04 24             	mov    %eax,(%esp)
  103349:	e8 c6 fb ff ff       	call   102f14 <vprintfmt>

	b.buf[b.idx] = 0;
  10334e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  103354:	c6 84 05 f8 fe ff ff 	movb   $0x0,-0x108(%ebp,%eax,1)
  10335b:	00 
	cputs(b.buf);
  10335c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  103362:	83 c0 08             	add    $0x8,%eax
  103365:	89 04 24             	mov    %eax,(%esp)
  103368:	e8 c8 cf ff ff       	call   100335 <cputs>

	return b.cnt;
  10336d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  103373:	c9                   	leave  
  103374:	c3                   	ret    

00103375 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  103375:	55                   	push   %ebp
  103376:	89 e5                	mov    %esp,%ebp
  103378:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  10337b:	8d 45 08             	lea    0x8(%ebp),%eax
  10337e:	83 c0 04             	add    $0x4,%eax
  103381:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  103384:	8b 45 08             	mov    0x8(%ebp),%eax
  103387:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10338a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10338e:	89 04 24             	mov    %eax,(%esp)
  103391:	e8 76 ff ff ff       	call   10330c <vcprintf>
  103396:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  103399:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10339c:	c9                   	leave  
  10339d:	c3                   	ret    
  10339e:	90                   	nop
  10339f:	90                   	nop

001033a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  1033a0:	55                   	push   %ebp
  1033a1:	89 e5                	mov    %esp,%ebp
  1033a3:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  1033a6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1033ad:	eb 08                	jmp    1033b7 <strlen+0x17>
		n++;
  1033af:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  1033b3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1033b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1033ba:	0f b6 00             	movzbl (%eax),%eax
  1033bd:	84 c0                	test   %al,%al
  1033bf:	75 ee                	jne    1033af <strlen+0xf>
		n++;
	return n;
  1033c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1033c4:	c9                   	leave  
  1033c5:	c3                   	ret    

001033c6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  1033c6:	55                   	push   %ebp
  1033c7:	89 e5                	mov    %esp,%ebp
  1033c9:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  1033cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1033cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  1033d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033d5:	0f b6 10             	movzbl (%eax),%edx
  1033d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1033db:	88 10                	mov    %dl,(%eax)
  1033dd:	8b 45 08             	mov    0x8(%ebp),%eax
  1033e0:	0f b6 00             	movzbl (%eax),%eax
  1033e3:	84 c0                	test   %al,%al
  1033e5:	0f 95 c0             	setne  %al
  1033e8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1033ec:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  1033f0:	84 c0                	test   %al,%al
  1033f2:	75 de                	jne    1033d2 <strcpy+0xc>
		/* do nothing */;
	return ret;
  1033f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1033f7:	c9                   	leave  
  1033f8:	c3                   	ret    

001033f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  1033f9:	55                   	push   %ebp
  1033fa:	89 e5                	mov    %esp,%ebp
  1033fc:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  1033ff:	8b 45 08             	mov    0x8(%ebp),%eax
  103402:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (i = 0; i < size; i++) {
  103405:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  10340c:	eb 21                	jmp    10342f <strncpy+0x36>
		*dst++ = *src;
  10340e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103411:	0f b6 10             	movzbl (%eax),%edx
  103414:	8b 45 08             	mov    0x8(%ebp),%eax
  103417:	88 10                	mov    %dl,(%eax)
  103419:	83 45 08 01          	addl   $0x1,0x8(%ebp)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  10341d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103420:	0f b6 00             	movzbl (%eax),%eax
  103423:	84 c0                	test   %al,%al
  103425:	74 04                	je     10342b <strncpy+0x32>
			src++;
  103427:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
{
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  10342b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  10342f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103432:	3b 45 10             	cmp    0x10(%ebp),%eax
  103435:	72 d7                	jb     10340e <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  103437:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10343a:	c9                   	leave  
  10343b:	c3                   	ret    

0010343c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  10343c:	55                   	push   %ebp
  10343d:	89 e5                	mov    %esp,%ebp
  10343f:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  103442:	8b 45 08             	mov    0x8(%ebp),%eax
  103445:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  103448:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10344c:	74 2f                	je     10347d <strlcpy+0x41>
		while (--size > 0 && *src != '\0')
  10344e:	eb 13                	jmp    103463 <strlcpy+0x27>
			*dst++ = *src++;
  103450:	8b 45 0c             	mov    0xc(%ebp),%eax
  103453:	0f b6 10             	movzbl (%eax),%edx
  103456:	8b 45 08             	mov    0x8(%ebp),%eax
  103459:	88 10                	mov    %dl,(%eax)
  10345b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10345f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  103463:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  103467:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10346b:	74 0a                	je     103477 <strlcpy+0x3b>
  10346d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103470:	0f b6 00             	movzbl (%eax),%eax
  103473:	84 c0                	test   %al,%al
  103475:	75 d9                	jne    103450 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  103477:	8b 45 08             	mov    0x8(%ebp),%eax
  10347a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  10347d:	8b 55 08             	mov    0x8(%ebp),%edx
  103480:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103483:	89 d1                	mov    %edx,%ecx
  103485:	29 c1                	sub    %eax,%ecx
  103487:	89 c8                	mov    %ecx,%eax
}
  103489:	c9                   	leave  
  10348a:	c3                   	ret    

0010348b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  10348b:	55                   	push   %ebp
  10348c:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  10348e:	eb 08                	jmp    103498 <strcmp+0xd>
		p++, q++;
  103490:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  103494:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  103498:	8b 45 08             	mov    0x8(%ebp),%eax
  10349b:	0f b6 00             	movzbl (%eax),%eax
  10349e:	84 c0                	test   %al,%al
  1034a0:	74 10                	je     1034b2 <strcmp+0x27>
  1034a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1034a5:	0f b6 10             	movzbl (%eax),%edx
  1034a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034ab:	0f b6 00             	movzbl (%eax),%eax
  1034ae:	38 c2                	cmp    %al,%dl
  1034b0:	74 de                	je     103490 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  1034b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1034b5:	0f b6 00             	movzbl (%eax),%eax
  1034b8:	0f b6 d0             	movzbl %al,%edx
  1034bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034be:	0f b6 00             	movzbl (%eax),%eax
  1034c1:	0f b6 c0             	movzbl %al,%eax
  1034c4:	89 d1                	mov    %edx,%ecx
  1034c6:	29 c1                	sub    %eax,%ecx
  1034c8:	89 c8                	mov    %ecx,%eax
}
  1034ca:	5d                   	pop    %ebp
  1034cb:	c3                   	ret    

001034cc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  1034cc:	55                   	push   %ebp
  1034cd:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  1034cf:	eb 0c                	jmp    1034dd <strncmp+0x11>
		n--, p++, q++;
  1034d1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1034d5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1034d9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  1034dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1034e1:	74 1a                	je     1034fd <strncmp+0x31>
  1034e3:	8b 45 08             	mov    0x8(%ebp),%eax
  1034e6:	0f b6 00             	movzbl (%eax),%eax
  1034e9:	84 c0                	test   %al,%al
  1034eb:	74 10                	je     1034fd <strncmp+0x31>
  1034ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1034f0:	0f b6 10             	movzbl (%eax),%edx
  1034f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034f6:	0f b6 00             	movzbl (%eax),%eax
  1034f9:	38 c2                	cmp    %al,%dl
  1034fb:	74 d4                	je     1034d1 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  1034fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103501:	75 07                	jne    10350a <strncmp+0x3e>
		return 0;
  103503:	b8 00 00 00 00       	mov    $0x0,%eax
  103508:	eb 18                	jmp    103522 <strncmp+0x56>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  10350a:	8b 45 08             	mov    0x8(%ebp),%eax
  10350d:	0f b6 00             	movzbl (%eax),%eax
  103510:	0f b6 d0             	movzbl %al,%edx
  103513:	8b 45 0c             	mov    0xc(%ebp),%eax
  103516:	0f b6 00             	movzbl (%eax),%eax
  103519:	0f b6 c0             	movzbl %al,%eax
  10351c:	89 d1                	mov    %edx,%ecx
  10351e:	29 c1                	sub    %eax,%ecx
  103520:	89 c8                	mov    %ecx,%eax
}
  103522:	5d                   	pop    %ebp
  103523:	c3                   	ret    

00103524 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  103524:	55                   	push   %ebp
  103525:	89 e5                	mov    %esp,%ebp
  103527:	83 ec 04             	sub    $0x4,%esp
  10352a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10352d:	88 45 fc             	mov    %al,-0x4(%ebp)
	while (*s != c)
  103530:	eb 1a                	jmp    10354c <strchr+0x28>
		if (*s++ == 0)
  103532:	8b 45 08             	mov    0x8(%ebp),%eax
  103535:	0f b6 00             	movzbl (%eax),%eax
  103538:	84 c0                	test   %al,%al
  10353a:	0f 94 c0             	sete   %al
  10353d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  103541:	84 c0                	test   %al,%al
  103543:	74 07                	je     10354c <strchr+0x28>
			return NULL;
  103545:	b8 00 00 00 00       	mov    $0x0,%eax
  10354a:	eb 0e                	jmp    10355a <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	while (*s != c)
  10354c:	8b 45 08             	mov    0x8(%ebp),%eax
  10354f:	0f b6 00             	movzbl (%eax),%eax
  103552:	3a 45 fc             	cmp    -0x4(%ebp),%al
  103555:	75 db                	jne    103532 <strchr+0xe>
		if (*s++ == 0)
			return NULL;
	return (char *) s;
  103557:	8b 45 08             	mov    0x8(%ebp),%eax
}
  10355a:	c9                   	leave  
  10355b:	c3                   	ret    

0010355c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  10355c:	55                   	push   %ebp
  10355d:	89 e5                	mov    %esp,%ebp
  10355f:	57                   	push   %edi
  103560:	83 ec 10             	sub    $0x10,%esp
	char *p;

	if (n == 0)
  103563:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103567:	75 05                	jne    10356e <memset+0x12>
		return v;
  103569:	8b 45 08             	mov    0x8(%ebp),%eax
  10356c:	eb 5c                	jmp    1035ca <memset+0x6e>
	if ((int)v%4 == 0 && n%4 == 0) {
  10356e:	8b 45 08             	mov    0x8(%ebp),%eax
  103571:	83 e0 03             	and    $0x3,%eax
  103574:	85 c0                	test   %eax,%eax
  103576:	75 41                	jne    1035b9 <memset+0x5d>
  103578:	8b 45 10             	mov    0x10(%ebp),%eax
  10357b:	83 e0 03             	and    $0x3,%eax
  10357e:	85 c0                	test   %eax,%eax
  103580:	75 37                	jne    1035b9 <memset+0x5d>
		c &= 0xFF;
  103582:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  103589:	8b 45 0c             	mov    0xc(%ebp),%eax
  10358c:	89 c2                	mov    %eax,%edx
  10358e:	c1 e2 18             	shl    $0x18,%edx
  103591:	8b 45 0c             	mov    0xc(%ebp),%eax
  103594:	c1 e0 10             	shl    $0x10,%eax
  103597:	09 c2                	or     %eax,%edx
  103599:	8b 45 0c             	mov    0xc(%ebp),%eax
  10359c:	c1 e0 08             	shl    $0x8,%eax
  10359f:	09 d0                	or     %edx,%eax
  1035a1:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  1035a4:	8b 45 10             	mov    0x10(%ebp),%eax
  1035a7:	89 c1                	mov    %eax,%ecx
  1035a9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  1035ac:	8b 55 08             	mov    0x8(%ebp),%edx
  1035af:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035b2:	89 d7                	mov    %edx,%edi
  1035b4:	fc                   	cld    
  1035b5:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  1035b7:	eb 0e                	jmp    1035c7 <memset+0x6b>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  1035b9:	8b 55 08             	mov    0x8(%ebp),%edx
  1035bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  1035c2:	89 d7                	mov    %edx,%edi
  1035c4:	fc                   	cld    
  1035c5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  1035c7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1035ca:	83 c4 10             	add    $0x10,%esp
  1035cd:	5f                   	pop    %edi
  1035ce:	5d                   	pop    %ebp
  1035cf:	c3                   	ret    

001035d0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  1035d0:	55                   	push   %ebp
  1035d1:	89 e5                	mov    %esp,%ebp
  1035d3:	57                   	push   %edi
  1035d4:	56                   	push   %esi
  1035d5:	53                   	push   %ebx
  1035d6:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;
	
	s = src;
  1035d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
	d = dst;
  1035df:	8b 45 08             	mov    0x8(%ebp),%eax
  1035e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (s < d && s + n > d) {
  1035e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1035e8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1035eb:	73 6e                	jae    10365b <memmove+0x8b>
  1035ed:	8b 45 10             	mov    0x10(%ebp),%eax
  1035f0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1035f3:	8d 04 02             	lea    (%edx,%eax,1),%eax
  1035f6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1035f9:	76 60                	jbe    10365b <memmove+0x8b>
		s += n;
  1035fb:	8b 45 10             	mov    0x10(%ebp),%eax
  1035fe:	01 45 ec             	add    %eax,-0x14(%ebp)
		d += n;
  103601:	8b 45 10             	mov    0x10(%ebp),%eax
  103604:	01 45 f0             	add    %eax,-0x10(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  103607:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10360a:	83 e0 03             	and    $0x3,%eax
  10360d:	85 c0                	test   %eax,%eax
  10360f:	75 2f                	jne    103640 <memmove+0x70>
  103611:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103614:	83 e0 03             	and    $0x3,%eax
  103617:	85 c0                	test   %eax,%eax
  103619:	75 25                	jne    103640 <memmove+0x70>
  10361b:	8b 45 10             	mov    0x10(%ebp),%eax
  10361e:	83 e0 03             	and    $0x3,%eax
  103621:	85 c0                	test   %eax,%eax
  103623:	75 1b                	jne    103640 <memmove+0x70>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  103625:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103628:	83 e8 04             	sub    $0x4,%eax
  10362b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10362e:	83 ea 04             	sub    $0x4,%edx
  103631:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103634:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  103637:	89 c7                	mov    %eax,%edi
  103639:	89 d6                	mov    %edx,%esi
  10363b:	fd                   	std    
  10363c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  10363e:	eb 18                	jmp    103658 <memmove+0x88>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  103640:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103643:	8d 50 ff             	lea    -0x1(%eax),%edx
  103646:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103649:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  10364c:	8b 45 10             	mov    0x10(%ebp),%eax
  10364f:	89 d7                	mov    %edx,%edi
  103651:	89 de                	mov    %ebx,%esi
  103653:	89 c1                	mov    %eax,%ecx
  103655:	fd                   	std    
  103656:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  103658:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  103659:	eb 45                	jmp    1036a0 <memmove+0xd0>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  10365b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10365e:	83 e0 03             	and    $0x3,%eax
  103661:	85 c0                	test   %eax,%eax
  103663:	75 2b                	jne    103690 <memmove+0xc0>
  103665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103668:	83 e0 03             	and    $0x3,%eax
  10366b:	85 c0                	test   %eax,%eax
  10366d:	75 21                	jne    103690 <memmove+0xc0>
  10366f:	8b 45 10             	mov    0x10(%ebp),%eax
  103672:	83 e0 03             	and    $0x3,%eax
  103675:	85 c0                	test   %eax,%eax
  103677:	75 17                	jne    103690 <memmove+0xc0>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  103679:	8b 45 10             	mov    0x10(%ebp),%eax
  10367c:	89 c1                	mov    %eax,%ecx
  10367e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  103681:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103684:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103687:	89 c7                	mov    %eax,%edi
  103689:	89 d6                	mov    %edx,%esi
  10368b:	fc                   	cld    
  10368c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  10368e:	eb 10                	jmp    1036a0 <memmove+0xd0>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  103690:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103693:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103696:	8b 4d 10             	mov    0x10(%ebp),%ecx
  103699:	89 c7                	mov    %eax,%edi
  10369b:	89 d6                	mov    %edx,%esi
  10369d:	fc                   	cld    
  10369e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  1036a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1036a3:	83 c4 10             	add    $0x10,%esp
  1036a6:	5b                   	pop    %ebx
  1036a7:	5e                   	pop    %esi
  1036a8:	5f                   	pop    %edi
  1036a9:	5d                   	pop    %ebp
  1036aa:	c3                   	ret    

001036ab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  1036ab:	55                   	push   %ebp
  1036ac:	89 e5                	mov    %esp,%ebp
  1036ae:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  1036b1:	8b 45 10             	mov    0x10(%ebp),%eax
  1036b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1036b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1036bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1036bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1036c2:	89 04 24             	mov    %eax,(%esp)
  1036c5:	e8 06 ff ff ff       	call   1035d0 <memmove>
}
  1036ca:	c9                   	leave  
  1036cb:	c3                   	ret    

001036cc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  1036cc:	55                   	push   %ebp
  1036cd:	89 e5                	mov    %esp,%ebp
  1036cf:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  1036d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1036d5:	89 45 f8             	mov    %eax,-0x8(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  1036d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1036db:	89 45 fc             	mov    %eax,-0x4(%ebp)

	while (n-- > 0) {
  1036de:	eb 32                	jmp    103712 <memcmp+0x46>
		if (*s1 != *s2)
  1036e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1036e3:	0f b6 10             	movzbl (%eax),%edx
  1036e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1036e9:	0f b6 00             	movzbl (%eax),%eax
  1036ec:	38 c2                	cmp    %al,%dl
  1036ee:	74 1a                	je     10370a <memcmp+0x3e>
			return (int) *s1 - (int) *s2;
  1036f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1036f3:	0f b6 00             	movzbl (%eax),%eax
  1036f6:	0f b6 d0             	movzbl %al,%edx
  1036f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1036fc:	0f b6 00             	movzbl (%eax),%eax
  1036ff:	0f b6 c0             	movzbl %al,%eax
  103702:	89 d1                	mov    %edx,%ecx
  103704:	29 c1                	sub    %eax,%ecx
  103706:	89 c8                	mov    %ecx,%eax
  103708:	eb 1c                	jmp    103726 <memcmp+0x5a>
		s1++, s2++;
  10370a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  10370e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  103712:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103716:	0f 95 c0             	setne  %al
  103719:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10371d:	84 c0                	test   %al,%al
  10371f:	75 bf                	jne    1036e0 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  103721:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103726:	c9                   	leave  
  103727:	c3                   	ret    

00103728 <memchr>:

void *
memchr(const void *s, int c, size_t n)
{
  103728:	55                   	push   %ebp
  103729:	89 e5                	mov    %esp,%ebp
  10372b:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  10372e:	8b 45 10             	mov    0x10(%ebp),%eax
  103731:	8b 55 08             	mov    0x8(%ebp),%edx
  103734:	8d 04 02             	lea    (%edx,%eax,1),%eax
  103737:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  10373a:	eb 16                	jmp    103752 <memchr+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  10373c:	8b 45 08             	mov    0x8(%ebp),%eax
  10373f:	0f b6 10             	movzbl (%eax),%edx
  103742:	8b 45 0c             	mov    0xc(%ebp),%eax
  103745:	38 c2                	cmp    %al,%dl
  103747:	75 05                	jne    10374e <memchr+0x26>
			return (void *) s;
  103749:	8b 45 08             	mov    0x8(%ebp),%eax
  10374c:	eb 11                	jmp    10375f <memchr+0x37>

void *
memchr(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  10374e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  103752:	8b 45 08             	mov    0x8(%ebp),%eax
  103755:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  103758:	72 e2                	jb     10373c <memchr+0x14>
		if (*(const unsigned char *) s == (unsigned char) c)
			return (void *) s;
	return NULL;
  10375a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10375f:	c9                   	leave  
  103760:	c3                   	ret    
  103761:	90                   	nop
  103762:	90                   	nop
  103763:	90                   	nop
  103764:	90                   	nop
  103765:	90                   	nop
  103766:	90                   	nop
  103767:	90                   	nop
  103768:	90                   	nop
  103769:	90                   	nop
  10376a:	90                   	nop
  10376b:	90                   	nop
  10376c:	90                   	nop
  10376d:	90                   	nop
  10376e:	90                   	nop
  10376f:	90                   	nop

00103770 <__udivdi3>:
  103770:	55                   	push   %ebp
  103771:	89 e5                	mov    %esp,%ebp
  103773:	57                   	push   %edi
  103774:	56                   	push   %esi
  103775:	83 ec 10             	sub    $0x10,%esp
  103778:	8b 45 14             	mov    0x14(%ebp),%eax
  10377b:	8b 55 08             	mov    0x8(%ebp),%edx
  10377e:	8b 75 10             	mov    0x10(%ebp),%esi
  103781:	8b 7d 0c             	mov    0xc(%ebp),%edi
  103784:	85 c0                	test   %eax,%eax
  103786:	89 55 f0             	mov    %edx,-0x10(%ebp)
  103789:	75 35                	jne    1037c0 <__udivdi3+0x50>
  10378b:	39 fe                	cmp    %edi,%esi
  10378d:	77 61                	ja     1037f0 <__udivdi3+0x80>
  10378f:	85 f6                	test   %esi,%esi
  103791:	75 0b                	jne    10379e <__udivdi3+0x2e>
  103793:	b8 01 00 00 00       	mov    $0x1,%eax
  103798:	31 d2                	xor    %edx,%edx
  10379a:	f7 f6                	div    %esi
  10379c:	89 c6                	mov    %eax,%esi
  10379e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1037a1:	31 d2                	xor    %edx,%edx
  1037a3:	89 f8                	mov    %edi,%eax
  1037a5:	f7 f6                	div    %esi
  1037a7:	89 c7                	mov    %eax,%edi
  1037a9:	89 c8                	mov    %ecx,%eax
  1037ab:	f7 f6                	div    %esi
  1037ad:	89 c1                	mov    %eax,%ecx
  1037af:	89 fa                	mov    %edi,%edx
  1037b1:	89 c8                	mov    %ecx,%eax
  1037b3:	83 c4 10             	add    $0x10,%esp
  1037b6:	5e                   	pop    %esi
  1037b7:	5f                   	pop    %edi
  1037b8:	5d                   	pop    %ebp
  1037b9:	c3                   	ret    
  1037ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  1037c0:	39 f8                	cmp    %edi,%eax
  1037c2:	77 1c                	ja     1037e0 <__udivdi3+0x70>
  1037c4:	0f bd d0             	bsr    %eax,%edx
  1037c7:	83 f2 1f             	xor    $0x1f,%edx
  1037ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1037cd:	75 39                	jne    103808 <__udivdi3+0x98>
  1037cf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  1037d2:	0f 86 a0 00 00 00    	jbe    103878 <__udivdi3+0x108>
  1037d8:	39 f8                	cmp    %edi,%eax
  1037da:	0f 82 98 00 00 00    	jb     103878 <__udivdi3+0x108>
  1037e0:	31 ff                	xor    %edi,%edi
  1037e2:	31 c9                	xor    %ecx,%ecx
  1037e4:	89 c8                	mov    %ecx,%eax
  1037e6:	89 fa                	mov    %edi,%edx
  1037e8:	83 c4 10             	add    $0x10,%esp
  1037eb:	5e                   	pop    %esi
  1037ec:	5f                   	pop    %edi
  1037ed:	5d                   	pop    %ebp
  1037ee:	c3                   	ret    
  1037ef:	90                   	nop
  1037f0:	89 d1                	mov    %edx,%ecx
  1037f2:	89 fa                	mov    %edi,%edx
  1037f4:	89 c8                	mov    %ecx,%eax
  1037f6:	31 ff                	xor    %edi,%edi
  1037f8:	f7 f6                	div    %esi
  1037fa:	89 c1                	mov    %eax,%ecx
  1037fc:	89 fa                	mov    %edi,%edx
  1037fe:	89 c8                	mov    %ecx,%eax
  103800:	83 c4 10             	add    $0x10,%esp
  103803:	5e                   	pop    %esi
  103804:	5f                   	pop    %edi
  103805:	5d                   	pop    %ebp
  103806:	c3                   	ret    
  103807:	90                   	nop
  103808:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  10380c:	89 f2                	mov    %esi,%edx
  10380e:	d3 e0                	shl    %cl,%eax
  103810:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103813:	b8 20 00 00 00       	mov    $0x20,%eax
  103818:	2b 45 f4             	sub    -0xc(%ebp),%eax
  10381b:	89 c1                	mov    %eax,%ecx
  10381d:	d3 ea                	shr    %cl,%edx
  10381f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  103823:	0b 55 ec             	or     -0x14(%ebp),%edx
  103826:	d3 e6                	shl    %cl,%esi
  103828:	89 c1                	mov    %eax,%ecx
  10382a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  10382d:	89 fe                	mov    %edi,%esi
  10382f:	d3 ee                	shr    %cl,%esi
  103831:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  103835:	89 55 ec             	mov    %edx,-0x14(%ebp)
  103838:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10383b:	d3 e7                	shl    %cl,%edi
  10383d:	89 c1                	mov    %eax,%ecx
  10383f:	d3 ea                	shr    %cl,%edx
  103841:	09 d7                	or     %edx,%edi
  103843:	89 f2                	mov    %esi,%edx
  103845:	89 f8                	mov    %edi,%eax
  103847:	f7 75 ec             	divl   -0x14(%ebp)
  10384a:	89 d6                	mov    %edx,%esi
  10384c:	89 c7                	mov    %eax,%edi
  10384e:	f7 65 e8             	mull   -0x18(%ebp)
  103851:	39 d6                	cmp    %edx,%esi
  103853:	89 55 ec             	mov    %edx,-0x14(%ebp)
  103856:	72 30                	jb     103888 <__udivdi3+0x118>
  103858:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10385b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  10385f:	d3 e2                	shl    %cl,%edx
  103861:	39 c2                	cmp    %eax,%edx
  103863:	73 05                	jae    10386a <__udivdi3+0xfa>
  103865:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  103868:	74 1e                	je     103888 <__udivdi3+0x118>
  10386a:	89 f9                	mov    %edi,%ecx
  10386c:	31 ff                	xor    %edi,%edi
  10386e:	e9 71 ff ff ff       	jmp    1037e4 <__udivdi3+0x74>
  103873:	90                   	nop
  103874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103878:	31 ff                	xor    %edi,%edi
  10387a:	b9 01 00 00 00       	mov    $0x1,%ecx
  10387f:	e9 60 ff ff ff       	jmp    1037e4 <__udivdi3+0x74>
  103884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103888:	8d 4f ff             	lea    -0x1(%edi),%ecx
  10388b:	31 ff                	xor    %edi,%edi
  10388d:	89 c8                	mov    %ecx,%eax
  10388f:	89 fa                	mov    %edi,%edx
  103891:	83 c4 10             	add    $0x10,%esp
  103894:	5e                   	pop    %esi
  103895:	5f                   	pop    %edi
  103896:	5d                   	pop    %ebp
  103897:	c3                   	ret    
  103898:	90                   	nop
  103899:	90                   	nop
  10389a:	90                   	nop
  10389b:	90                   	nop
  10389c:	90                   	nop
  10389d:	90                   	nop
  10389e:	90                   	nop
  10389f:	90                   	nop

001038a0 <__umoddi3>:
  1038a0:	55                   	push   %ebp
  1038a1:	89 e5                	mov    %esp,%ebp
  1038a3:	57                   	push   %edi
  1038a4:	56                   	push   %esi
  1038a5:	83 ec 20             	sub    $0x20,%esp
  1038a8:	8b 55 14             	mov    0x14(%ebp),%edx
  1038ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  1038ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  1038b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  1038b4:	85 d2                	test   %edx,%edx
  1038b6:	89 c8                	mov    %ecx,%eax
  1038b8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  1038bb:	75 13                	jne    1038d0 <__umoddi3+0x30>
  1038bd:	39 f7                	cmp    %esi,%edi
  1038bf:	76 3f                	jbe    103900 <__umoddi3+0x60>
  1038c1:	89 f2                	mov    %esi,%edx
  1038c3:	f7 f7                	div    %edi
  1038c5:	89 d0                	mov    %edx,%eax
  1038c7:	31 d2                	xor    %edx,%edx
  1038c9:	83 c4 20             	add    $0x20,%esp
  1038cc:	5e                   	pop    %esi
  1038cd:	5f                   	pop    %edi
  1038ce:	5d                   	pop    %ebp
  1038cf:	c3                   	ret    
  1038d0:	39 f2                	cmp    %esi,%edx
  1038d2:	77 4c                	ja     103920 <__umoddi3+0x80>
  1038d4:	0f bd ca             	bsr    %edx,%ecx
  1038d7:	83 f1 1f             	xor    $0x1f,%ecx
  1038da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  1038dd:	75 51                	jne    103930 <__umoddi3+0x90>
  1038df:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  1038e2:	0f 87 e0 00 00 00    	ja     1039c8 <__umoddi3+0x128>
  1038e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1038eb:	29 f8                	sub    %edi,%eax
  1038ed:	19 d6                	sbb    %edx,%esi
  1038ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1038f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1038f5:	89 f2                	mov    %esi,%edx
  1038f7:	83 c4 20             	add    $0x20,%esp
  1038fa:	5e                   	pop    %esi
  1038fb:	5f                   	pop    %edi
  1038fc:	5d                   	pop    %ebp
  1038fd:	c3                   	ret    
  1038fe:	66 90                	xchg   %ax,%ax
  103900:	85 ff                	test   %edi,%edi
  103902:	75 0b                	jne    10390f <__umoddi3+0x6f>
  103904:	b8 01 00 00 00       	mov    $0x1,%eax
  103909:	31 d2                	xor    %edx,%edx
  10390b:	f7 f7                	div    %edi
  10390d:	89 c7                	mov    %eax,%edi
  10390f:	89 f0                	mov    %esi,%eax
  103911:	31 d2                	xor    %edx,%edx
  103913:	f7 f7                	div    %edi
  103915:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103918:	f7 f7                	div    %edi
  10391a:	eb a9                	jmp    1038c5 <__umoddi3+0x25>
  10391c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103920:	89 c8                	mov    %ecx,%eax
  103922:	89 f2                	mov    %esi,%edx
  103924:	83 c4 20             	add    $0x20,%esp
  103927:	5e                   	pop    %esi
  103928:	5f                   	pop    %edi
  103929:	5d                   	pop    %ebp
  10392a:	c3                   	ret    
  10392b:	90                   	nop
  10392c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  103930:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  103934:	d3 e2                	shl    %cl,%edx
  103936:	89 55 f4             	mov    %edx,-0xc(%ebp)
  103939:	ba 20 00 00 00       	mov    $0x20,%edx
  10393e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  103941:	89 55 ec             	mov    %edx,-0x14(%ebp)
  103944:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  103948:	89 fa                	mov    %edi,%edx
  10394a:	d3 ea                	shr    %cl,%edx
  10394c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  103950:	0b 55 f4             	or     -0xc(%ebp),%edx
  103953:	d3 e7                	shl    %cl,%edi
  103955:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  103959:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10395c:	89 f2                	mov    %esi,%edx
  10395e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  103961:	89 c7                	mov    %eax,%edi
  103963:	d3 ea                	shr    %cl,%edx
  103965:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  103969:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10396c:	89 c2                	mov    %eax,%edx
  10396e:	d3 e6                	shl    %cl,%esi
  103970:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  103974:	d3 ea                	shr    %cl,%edx
  103976:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  10397a:	09 d6                	or     %edx,%esi
  10397c:	89 f0                	mov    %esi,%eax
  10397e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  103981:	d3 e7                	shl    %cl,%edi
  103983:	89 f2                	mov    %esi,%edx
  103985:	f7 75 f4             	divl   -0xc(%ebp)
  103988:	89 d6                	mov    %edx,%esi
  10398a:	f7 65 e8             	mull   -0x18(%ebp)
  10398d:	39 d6                	cmp    %edx,%esi
  10398f:	72 2b                	jb     1039bc <__umoddi3+0x11c>
  103991:	39 c7                	cmp    %eax,%edi
  103993:	72 23                	jb     1039b8 <__umoddi3+0x118>
  103995:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  103999:	29 c7                	sub    %eax,%edi
  10399b:	19 d6                	sbb    %edx,%esi
  10399d:	89 f0                	mov    %esi,%eax
  10399f:	89 f2                	mov    %esi,%edx
  1039a1:	d3 ef                	shr    %cl,%edi
  1039a3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  1039a7:	d3 e0                	shl    %cl,%eax
  1039a9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  1039ad:	09 f8                	or     %edi,%eax
  1039af:	d3 ea                	shr    %cl,%edx
  1039b1:	83 c4 20             	add    $0x20,%esp
  1039b4:	5e                   	pop    %esi
  1039b5:	5f                   	pop    %edi
  1039b6:	5d                   	pop    %ebp
  1039b7:	c3                   	ret    
  1039b8:	39 d6                	cmp    %edx,%esi
  1039ba:	75 d9                	jne    103995 <__umoddi3+0xf5>
  1039bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  1039bf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  1039c2:	eb d1                	jmp    103995 <__umoddi3+0xf5>
  1039c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1039c8:	39 f2                	cmp    %esi,%edx
  1039ca:	0f 82 18 ff ff ff    	jb     1038e8 <__umoddi3+0x48>
  1039d0:	e9 1d ff ff ff       	jmp    1038f2 <__umoddi3+0x52>
