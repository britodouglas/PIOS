
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
  10001a:	bc 00 80 10 00       	mov    $0x108000,%esp

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
  100045:	8b 80 b8 00 00 00    	mov    0xb8(%eax),%eax
  10004b:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  100050:	74 24                	je     100076 <cpu_cur+0x4e>
  100052:	c7 44 24 0c c0 58 10 	movl   $0x1058c0,0xc(%esp)
  100059:	00 
  10005a:	c7 44 24 08 d6 58 10 	movl   $0x1058d6,0x8(%esp)
  100061:	00 
  100062:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  100069:	00 
  10006a:	c7 04 24 eb 58 10 00 	movl   $0x1058eb,(%esp)
  100071:	e8 96 03 00 00       	call   10040c <debug_panic>
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
  100086:	3d 00 70 10 00       	cmp    $0x107000,%eax
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
  1000a2:	ba 4c e9 10 00       	mov    $0x10e94c,%edx
  1000a7:	b8 9e 85 10 00       	mov    $0x10859e,%eax
  1000ac:	89 d1                	mov    %edx,%ecx
  1000ae:	29 c1                	sub    %eax,%ecx
  1000b0:	89 c8                	mov    %ecx,%eax
  1000b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1000b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bd:	00 
  1000be:	c7 04 24 9e 85 10 00 	movl   $0x10859e,(%esp)
  1000c5:	e8 62 53 00 00       	call   10542c <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
  1000ca:	e8 4e 02 00 00       	call   10031d <cons_init>

	// Initialize and load the bootstrap CPU's GDT, TSS, and IDT.
	cpu_init();
  1000cf:	e8 61 11 00 00       	call   101235 <cpu_init>
	trap_init();
  1000d4:	e8 70 1f 00 00       	call   102049 <trap_init>

	// Physical memory detection/initialization.
	// Can't call mem_alloc until after we do this!
	mem_init();
  1000d9:	e8 4d 08 00 00       	call   10092b <mem_init>

//<<<<<<< HEAD
	// Lab 2: check spinlock implementation
	if (cpu_onboot())
  1000de:	e8 98 ff ff ff       	call   10007b <cpu_onboot>
  1000e3:	85 c0                	test   %eax,%eax
  1000e5:	74 05                	je     1000ec <init+0x59>
		spinlock_check();
  1000e7:	e8 62 2c 00 00       	call   102d4e <spinlock_check>

	// Find and start other processors in a multiprocessor system
	mp_init();		// Find info about processors in system
  1000ec:	e8 f5 28 00 00       	call   1029e6 <mp_init>
	pic_init();		// setup the legacy PIC (mainly to disable it)
  1000f1:	e8 3a 42 00 00       	call   104330 <pic_init>
	ioapic_init();		// prepare to handle external device interrupts
  1000f6:	e8 6a 48 00 00       	call   104965 <ioapic_init>
	lapic_init();		// setup this CPU's local APIC
  1000fb:	e8 15 45 00 00       	call   104615 <lapic_init>
	cpu_bootothers();	// Get other processors started
  100100:	e8 19 13 00 00       	call   10141e <cpu_bootothers>
//	cprintf("CPU %d (%s) has booted\n", cpu_cur()->id,
//		cpu_onboot() ? "BP" : "AP");

	// Initialize the process management code.
	proc_init();
  100105:	e8 ff 31 00 00       	call   103309 <proc_init>

	// Lab 1: change this so it enters user() in user mode,
	// running on the user_stack declared above,
	// instead of just calling user() directly.
	user();
  10010a:	e8 38 00 00 00       	call   100147 <user>
//=======
	user_stack[sizeof(user_stack)-1] = 0;
  10010f:	c6 05 9f 95 10 00 00 	movb   $0x0,0x10959f
	user_stack[sizeof(user_stack)-2] = 0;
  100116:	c6 05 9e 95 10 00 00 	movb   $0x0,0x10959e
	user_stack[sizeof(user_stack)-3] = 0;
  10011d:	c6 05 9d 95 10 00 00 	movb   $0x0,0x10959d
	user_stack[sizeof(user_stack)-4] = 0;
  100124:	c6 05 9c 95 10 00 00 	movb   $0x0,0x10959c
	asm volatile("pushl %0" : : "i" (CPU_GDT_UDATA | 0x3));
  10012b:	6a 23                	push   $0x23
	asm volatile("pushl %0" : : "i" (user_stack + sizeof(user_stack) - 4));
  10012d:	68 9c 95 10 00       	push   $0x10959c
	uint32_t eflags = (FL_IOPL_MASK & FL_IOPL_3);
  100132:	c7 45 f4 00 30 00 00 	movl   $0x3000,-0xc(%ebp)
	// eflags = 0;
	asm volatile("pushl %0" : : "a" (eflags));
  100139:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10013c:	50                   	push   %eax
	asm volatile("pushl %0" : : "i" (CPU_GDT_UCODE | 0x3));
  10013d:	6a 1b                	push   $0x1b
	asm volatile("pushl $user");
  10013f:	68 47 01 10 00       	push   $0x100147
	asm volatile("iret");
  100144:	cf                   	iret   
//>>>>>>> lab1
}
  100145:	c9                   	leave  
  100146:	c3                   	ret    

00100147 <user>:
// This is the first function that gets run in user mode (ring 3).
// It acts as PIOS's "root process",
// of which all other processes are descendants.
void
user()
{
  100147:	55                   	push   %ebp
  100148:	89 e5                	mov    %esp,%ebp
  10014a:	83 ec 28             	sub    $0x28,%esp
	assert(0 == 0);
	cprintf("in user()\n");
  10014d:	c7 04 24 f8 58 10 00 	movl   $0x1058f8,(%esp)
  100154:	e8 ec 50 00 00       	call   105245 <cprintf>

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  100159:	89 65 f0             	mov    %esp,-0x10(%ebp)
        return esp;
  10015c:	8b 45 f0             	mov    -0x10(%ebp),%eax
	assert(read_esp() > (uint32_t) &user_stack[0]);
  10015f:	89 c2                	mov    %eax,%edx
  100161:	b8 a0 85 10 00       	mov    $0x1085a0,%eax
  100166:	39 c2                	cmp    %eax,%edx
  100168:	77 24                	ja     10018e <user+0x47>
  10016a:	c7 44 24 0c 04 59 10 	movl   $0x105904,0xc(%esp)
  100171:	00 
  100172:	c7 44 24 08 d6 58 10 	movl   $0x1058d6,0x8(%esp)
  100179:	00 
  10017a:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  100181:	00 
  100182:	c7 04 24 2b 59 10 00 	movl   $0x10592b,(%esp)
  100189:	e8 7e 02 00 00       	call   10040c <debug_panic>

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  10018e:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  100191:	8b 45 f4             	mov    -0xc(%ebp),%eax
	assert(read_esp() < (uint32_t) &user_stack[sizeof(user_stack)]);
  100194:	89 c2                	mov    %eax,%edx
  100196:	b8 a0 95 10 00       	mov    $0x1095a0,%eax
  10019b:	39 c2                	cmp    %eax,%edx
  10019d:	72 24                	jb     1001c3 <user+0x7c>
  10019f:	c7 44 24 0c 38 59 10 	movl   $0x105938,0xc(%esp)
  1001a6:	00 
  1001a7:	c7 44 24 08 d6 58 10 	movl   $0x1058d6,0x8(%esp)
  1001ae:	00 
  1001af:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
  1001b6:	00 
  1001b7:	c7 04 24 2b 59 10 00 	movl   $0x10592b,(%esp)
  1001be:	e8 49 02 00 00       	call   10040c <debug_panic>

	// Check the system call and process scheduling code.
	proc_check();
  1001c3:	e8 a2 33 00 00       	call   10356a <proc_check>

	done();
  1001c8:	e8 00 00 00 00       	call   1001cd <done>

001001cd <done>:
// it just puts the processor into an infinite loop.
// We make this a function so that we can set a breakpoints on it.
// Our grade scripts use this breakpoint to know when to stop QEMU.
void gcc_noreturn
done()
{
  1001cd:	55                   	push   %ebp
  1001ce:	89 e5                	mov    %esp,%ebp
	while (1)
		;	// just spin
  1001d0:	eb fe                	jmp    1001d0 <done+0x3>
  1001d2:	90                   	nop
  1001d3:	90                   	nop

001001d4 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  1001d4:	55                   	push   %ebp
  1001d5:	89 e5                	mov    %esp,%ebp
  1001d7:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  1001da:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  1001dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  1001e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1001e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1001e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1001eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  1001ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1001f1:	8b 80 b8 00 00 00    	mov    0xb8(%eax),%eax
  1001f7:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  1001fc:	74 24                	je     100222 <cpu_cur+0x4e>
  1001fe:	c7 44 24 0c 70 59 10 	movl   $0x105970,0xc(%esp)
  100205:	00 
  100206:	c7 44 24 08 86 59 10 	movl   $0x105986,0x8(%esp)
  10020d:	00 
  10020e:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  100215:	00 
  100216:	c7 04 24 9b 59 10 00 	movl   $0x10599b,(%esp)
  10021d:	e8 ea 01 00 00       	call   10040c <debug_panic>
	return c;
  100222:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  100225:	c9                   	leave  
  100226:	c3                   	ret    

00100227 <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  100227:	55                   	push   %ebp
  100228:	89 e5                	mov    %esp,%ebp
  10022a:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  10022d:	e8 a2 ff ff ff       	call   1001d4 <cpu_cur>
  100232:	3d 00 70 10 00       	cmp    $0x107000,%eax
  100237:	0f 94 c0             	sete   %al
  10023a:	0f b6 c0             	movzbl %al,%eax
}
  10023d:	c9                   	leave  
  10023e:	c3                   	ret    

0010023f <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
  10023f:	55                   	push   %ebp
  100240:	89 e5                	mov    %esp,%ebp
  100242:	83 ec 28             	sub    $0x28,%esp
	int c;

	spinlock_acquire(&cons_lock);
  100245:	c7 04 24 40 e2 10 00 	movl   $0x10e240,(%esp)
  10024c:	e8 c1 29 00 00       	call   102c12 <spinlock_acquire>
	while ((c = (*proc)()) != -1) {
  100251:	eb 35                	jmp    100288 <cons_intr+0x49>
		if (c == 0)
  100253:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100257:	74 2e                	je     100287 <cons_intr+0x48>
			continue;
		cons.buf[cons.wpos++] = c;
  100259:	a1 a4 97 10 00       	mov    0x1097a4,%eax
  10025e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100261:	88 90 a0 95 10 00    	mov    %dl,0x1095a0(%eax)
  100267:	83 c0 01             	add    $0x1,%eax
  10026a:	a3 a4 97 10 00       	mov    %eax,0x1097a4
		if (cons.wpos == CONSBUFSIZE)
  10026f:	a1 a4 97 10 00       	mov    0x1097a4,%eax
  100274:	3d 00 02 00 00       	cmp    $0x200,%eax
  100279:	75 0d                	jne    100288 <cons_intr+0x49>
			cons.wpos = 0;
  10027b:	c7 05 a4 97 10 00 00 	movl   $0x0,0x1097a4
  100282:	00 00 00 
  100285:	eb 01                	jmp    100288 <cons_intr+0x49>
	int c;

	spinlock_acquire(&cons_lock);
	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
  100287:	90                   	nop
cons_intr(int (*proc)(void))
{
	int c;

	spinlock_acquire(&cons_lock);
	while ((c = (*proc)()) != -1) {
  100288:	8b 45 08             	mov    0x8(%ebp),%eax
  10028b:	ff d0                	call   *%eax
  10028d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100290:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  100294:	75 bd                	jne    100253 <cons_intr+0x14>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
	spinlock_release(&cons_lock);
  100296:	c7 04 24 40 e2 10 00 	movl   $0x10e240,(%esp)
  10029d:	e8 e5 29 00 00       	call   102c87 <spinlock_release>

}
  1002a2:	c9                   	leave  
  1002a3:	c3                   	ret    

001002a4 <cons_getc>:

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
  1002a4:	55                   	push   %ebp
  1002a5:	89 e5                	mov    %esp,%ebp
  1002a7:	83 ec 18             	sub    $0x18,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
  1002aa:	e8 31 3f 00 00       	call   1041e0 <serial_intr>
	kbd_intr();
  1002af:	e8 86 3e 00 00       	call   10413a <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
  1002b4:	8b 15 a0 97 10 00    	mov    0x1097a0,%edx
  1002ba:	a1 a4 97 10 00       	mov    0x1097a4,%eax
  1002bf:	39 c2                	cmp    %eax,%edx
  1002c1:	74 35                	je     1002f8 <cons_getc+0x54>
		c = cons.buf[cons.rpos++];
  1002c3:	a1 a0 97 10 00       	mov    0x1097a0,%eax
  1002c8:	0f b6 90 a0 95 10 00 	movzbl 0x1095a0(%eax),%edx
  1002cf:	0f b6 d2             	movzbl %dl,%edx
  1002d2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1002d5:	83 c0 01             	add    $0x1,%eax
  1002d8:	a3 a0 97 10 00       	mov    %eax,0x1097a0
		if (cons.rpos == CONSBUFSIZE)
  1002dd:	a1 a0 97 10 00       	mov    0x1097a0,%eax
  1002e2:	3d 00 02 00 00       	cmp    $0x200,%eax
  1002e7:	75 0a                	jne    1002f3 <cons_getc+0x4f>
			cons.rpos = 0;
  1002e9:	c7 05 a0 97 10 00 00 	movl   $0x0,0x1097a0
  1002f0:	00 00 00 
		return c;
  1002f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002f6:	eb 05                	jmp    1002fd <cons_getc+0x59>
	}
	return 0;
  1002f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1002fd:	c9                   	leave  
  1002fe:	c3                   	ret    

001002ff <cons_putc>:

// output a character to the console
static void
cons_putc(int c)
{
  1002ff:	55                   	push   %ebp
  100300:	89 e5                	mov    %esp,%ebp
  100302:	83 ec 18             	sub    $0x18,%esp
	serial_putc(c);
  100305:	8b 45 08             	mov    0x8(%ebp),%eax
  100308:	89 04 24             	mov    %eax,(%esp)
  10030b:	e8 ed 3e 00 00       	call   1041fd <serial_putc>
	video_putc(c);
  100310:	8b 45 08             	mov    0x8(%ebp),%eax
  100313:	89 04 24             	mov    %eax,(%esp)
  100316:	e8 7d 3a 00 00       	call   103d98 <video_putc>
}
  10031b:	c9                   	leave  
  10031c:	c3                   	ret    

0010031d <cons_init>:

// initialize the console devices
void
cons_init(void)
{
  10031d:	55                   	push   %ebp
  10031e:	89 e5                	mov    %esp,%ebp
  100320:	83 ec 18             	sub    $0x18,%esp
	if (!cpu_onboot())	// only do once, on the boot CPU
  100323:	e8 ff fe ff ff       	call   100227 <cpu_onboot>
  100328:	85 c0                	test   %eax,%eax
  10032a:	74 52                	je     10037e <cons_init+0x61>
		return;

	spinlock_init(&cons_lock);
  10032c:	c7 44 24 08 6a 00 00 	movl   $0x6a,0x8(%esp)
  100333:	00 
  100334:	c7 44 24 04 a8 59 10 	movl   $0x1059a8,0x4(%esp)
  10033b:	00 
  10033c:	c7 04 24 40 e2 10 00 	movl   $0x10e240,(%esp)
  100343:	e8 a0 28 00 00       	call   102be8 <spinlock_init_>
	video_init();
  100348:	e8 7f 39 00 00       	call   103ccc <video_init>
	kbd_init();
  10034d:	e8 fc 3d 00 00       	call   10414e <kbd_init>
	serial_init();
  100352:	e8 0b 3f 00 00       	call   104262 <serial_init>

	if (!serial_exists)
  100357:	a1 44 e9 10 00       	mov    0x10e944,%eax
  10035c:	85 c0                	test   %eax,%eax
  10035e:	75 1f                	jne    10037f <cons_init+0x62>
		warn("Serial port does not exist!\n");
  100360:	c7 44 24 08 b4 59 10 	movl   $0x1059b4,0x8(%esp)
  100367:	00 
  100368:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  10036f:	00 
  100370:	c7 04 24 a8 59 10 00 	movl   $0x1059a8,(%esp)
  100377:	e8 4f 01 00 00       	call   1004cb <debug_warn>
  10037c:	eb 01                	jmp    10037f <cons_init+0x62>
// initialize the console devices
void
cons_init(void)
{
	if (!cpu_onboot())	// only do once, on the boot CPU
		return;
  10037e:	90                   	nop
	kbd_init();
	serial_init();

	if (!serial_exists)
		warn("Serial port does not exist!\n");
}
  10037f:	c9                   	leave  
  100380:	c3                   	ret    

00100381 <cputs>:


// `High'-level console I/O.  Used by readline and cprintf.
void
cputs(const char *str)
{
  100381:	55                   	push   %ebp
  100382:	89 e5                	mov    %esp,%ebp
  100384:	53                   	push   %ebx
  100385:	83 ec 24             	sub    $0x24,%esp

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  100388:	8c 4d f2             	mov    %cs,-0xe(%ebp)
        return cs;
  10038b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
	if (read_cs() & 3)
  10038f:	0f b7 c0             	movzwl %ax,%eax
  100392:	83 e0 03             	and    $0x3,%eax
  100395:	85 c0                	test   %eax,%eax
  100397:	74 14                	je     1003ad <cputs+0x2c>
  100399:	8b 45 08             	mov    0x8(%ebp),%eax
  10039c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %0" :
  10039f:	b8 00 00 00 00       	mov    $0x0,%eax
  1003a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1003a7:	89 d3                	mov    %edx,%ebx
  1003a9:	cd 30                	int    $0x30
		return sys_cputs(str);	// use syscall from user mode
  1003ab:	eb 57                	jmp    100404 <cputs+0x83>

	// Hold the console spinlock while printing the entire string,
	// so that the output of different cputs calls won't get mixed.
	// Implement ad hoc recursive locking for debugging convenience.
	bool already = spinlock_holding(&cons_lock);
  1003ad:	c7 04 24 40 e2 10 00 	movl   $0x10e240,(%esp)
  1003b4:	e8 28 29 00 00       	call   102ce1 <spinlock_holding>
  1003b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (!already)
  1003bc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1003c0:	75 25                	jne    1003e7 <cputs+0x66>
		spinlock_acquire(&cons_lock);
  1003c2:	c7 04 24 40 e2 10 00 	movl   $0x10e240,(%esp)
  1003c9:	e8 44 28 00 00       	call   102c12 <spinlock_acquire>

	char ch;
	while (*str)
  1003ce:	eb 18                	jmp    1003e8 <cputs+0x67>
		cons_putc(*str++);
  1003d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1003d3:	0f b6 00             	movzbl (%eax),%eax
  1003d6:	0f be c0             	movsbl %al,%eax
  1003d9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1003dd:	89 04 24             	mov    %eax,(%esp)
  1003e0:	e8 1a ff ff ff       	call   1002ff <cons_putc>
  1003e5:	eb 01                	jmp    1003e8 <cputs+0x67>
	bool already = spinlock_holding(&cons_lock);
	if (!already)
		spinlock_acquire(&cons_lock);

	char ch;
	while (*str)
  1003e7:	90                   	nop
  1003e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1003eb:	0f b6 00             	movzbl (%eax),%eax
  1003ee:	84 c0                	test   %al,%al
  1003f0:	75 de                	jne    1003d0 <cputs+0x4f>
		cons_putc(*str++);

	if (!already)
  1003f2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1003f6:	75 0c                	jne    100404 <cputs+0x83>
		spinlock_release(&cons_lock);
  1003f8:	c7 04 24 40 e2 10 00 	movl   $0x10e240,(%esp)
  1003ff:	e8 83 28 00 00       	call   102c87 <spinlock_release>
}
  100404:	83 c4 24             	add    $0x24,%esp
  100407:	5b                   	pop    %ebx
  100408:	5d                   	pop    %ebp
  100409:	c3                   	ret    
  10040a:	90                   	nop
  10040b:	90                   	nop

0010040c <debug_panic>:

// Panic is called on unresolvable fatal errors.
// It prints "panic: mesg", and then enters the kernel monitor.
void
debug_panic(const char *file, int line, const char *fmt,...)
{
  10040c:	55                   	push   %ebp
  10040d:	89 e5                	mov    %esp,%ebp
  10040f:	83 ec 58             	sub    $0x58,%esp

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  100412:	8c 4d f2             	mov    %cs,-0xe(%ebp)
        return cs;
  100415:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
	va_list ap;
	int i;

	// Avoid infinite recursion if we're panicking from kernel mode.
	if ((read_cs() & 3) == 0) {
  100419:	0f b7 c0             	movzwl %ax,%eax
  10041c:	83 e0 03             	and    $0x3,%eax
  10041f:	85 c0                	test   %eax,%eax
  100421:	75 15                	jne    100438 <debug_panic+0x2c>
		if (panicstr)
  100423:	a1 a8 97 10 00       	mov    0x1097a8,%eax
  100428:	85 c0                	test   %eax,%eax
  10042a:	0f 85 95 00 00 00    	jne    1004c5 <debug_panic+0xb9>
			goto dead;
		panicstr = fmt;
  100430:	8b 45 10             	mov    0x10(%ebp),%eax
  100433:	a3 a8 97 10 00       	mov    %eax,0x1097a8
	}

	// First print the requested message
	va_start(ap, fmt);
  100438:	8d 45 10             	lea    0x10(%ebp),%eax
  10043b:	83 c0 04             	add    $0x4,%eax
  10043e:	89 45 e8             	mov    %eax,-0x18(%ebp)
	cprintf("kernel panic at %s:%d: ", file, line);
  100441:	8b 45 0c             	mov    0xc(%ebp),%eax
  100444:	89 44 24 08          	mov    %eax,0x8(%esp)
  100448:	8b 45 08             	mov    0x8(%ebp),%eax
  10044b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10044f:	c7 04 24 d4 59 10 00 	movl   $0x1059d4,(%esp)
  100456:	e8 ea 4d 00 00       	call   105245 <cprintf>
	vcprintf(fmt, ap);
  10045b:	8b 45 10             	mov    0x10(%ebp),%eax
  10045e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  100461:	89 54 24 04          	mov    %edx,0x4(%esp)
  100465:	89 04 24             	mov    %eax,(%esp)
  100468:	e8 6f 4d 00 00       	call   1051dc <vcprintf>
	cprintf("\n");
  10046d:	c7 04 24 ec 59 10 00 	movl   $0x1059ec,(%esp)
  100474:	e8 cc 4d 00 00       	call   105245 <cprintf>

static gcc_inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=rm" (ebp));
  100479:	89 6d f4             	mov    %ebp,-0xc(%ebp)
        return ebp;
  10047c:	8b 45 f4             	mov    -0xc(%ebp),%eax
	va_end(ap);

	// Then print a backtrace of the kernel call chain
	uint32_t eips[DEBUG_TRACEFRAMES];
	debug_trace(read_ebp(), eips);
  10047f:	8d 55 c0             	lea    -0x40(%ebp),%edx
  100482:	89 54 24 04          	mov    %edx,0x4(%esp)
  100486:	89 04 24             	mov    %eax,(%esp)
  100489:	e8 86 00 00 00       	call   100514 <debug_trace>
	for (i = 0; i < DEBUG_TRACEFRAMES && eips[i] != 0; i++)
  10048e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100495:	eb 1b                	jmp    1004b2 <debug_panic+0xa6>
		cprintf("  from %08x\n", eips[i]);
  100497:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10049a:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
  10049e:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004a2:	c7 04 24 ee 59 10 00 	movl   $0x1059ee,(%esp)
  1004a9:	e8 97 4d 00 00       	call   105245 <cprintf>
	va_end(ap);

	// Then print a backtrace of the kernel call chain
	uint32_t eips[DEBUG_TRACEFRAMES];
	debug_trace(read_ebp(), eips);
	for (i = 0; i < DEBUG_TRACEFRAMES && eips[i] != 0; i++)
  1004ae:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  1004b2:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
  1004b6:	7f 0e                	jg     1004c6 <debug_panic+0xba>
  1004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004bb:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
  1004bf:	85 c0                	test   %eax,%eax
  1004c1:	75 d4                	jne    100497 <debug_panic+0x8b>
  1004c3:	eb 01                	jmp    1004c6 <debug_panic+0xba>
	int i;

	// Avoid infinite recursion if we're panicking from kernel mode.
	if ((read_cs() & 3) == 0) {
		if (panicstr)
			goto dead;
  1004c5:	90                   	nop
	debug_trace(read_ebp(), eips);
	for (i = 0; i < DEBUG_TRACEFRAMES && eips[i] != 0; i++)
		cprintf("  from %08x\n", eips[i]);

dead:
	done();		// enter infinite loop (see kern/init.c)
  1004c6:	e8 02 fd ff ff       	call   1001cd <done>

001004cb <debug_warn>:
}

/* like panic, but don't */
void
debug_warn(const char *file, int line, const char *fmt,...)
{
  1004cb:	55                   	push   %ebp
  1004cc:	89 e5                	mov    %esp,%ebp
  1004ce:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  1004d1:	8d 45 10             	lea    0x10(%ebp),%eax
  1004d4:	83 c0 04             	add    $0x4,%eax
  1004d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel warning at %s:%d: ", file, line);
  1004da:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  1004e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1004e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004e8:	c7 04 24 fb 59 10 00 	movl   $0x1059fb,(%esp)
  1004ef:	e8 51 4d 00 00       	call   105245 <cprintf>
	vcprintf(fmt, ap);
  1004f4:	8b 45 10             	mov    0x10(%ebp),%eax
  1004f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1004fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  1004fe:	89 04 24             	mov    %eax,(%esp)
  100501:	e8 d6 4c 00 00       	call   1051dc <vcprintf>
	cprintf("\n");
  100506:	c7 04 24 ec 59 10 00 	movl   $0x1059ec,(%esp)
  10050d:	e8 33 4d 00 00       	call   105245 <cprintf>
	va_end(ap);
}
  100512:	c9                   	leave  
  100513:	c3                   	ret    

00100514 <debug_trace>:

// Record the current call stack in eips[] by following the %ebp chain.
void gcc_noinline
debug_trace(uint32_t ebp, uint32_t eips[DEBUG_TRACEFRAMES])
{
  100514:	55                   	push   %ebp
  100515:	89 e5                	mov    %esp,%ebp
  100517:	56                   	push   %esi
  100518:	53                   	push   %ebx
  100519:	83 ec 30             	sub    $0x30,%esp
	int i = 0;
  10051c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	for(; i < DEBUG_TRACEFRAMES && ebp; i++) {
  100523:	e9 8c 00 00 00       	jmp    1005b4 <debug_trace+0xa0>
		uint32_t eip = (*(uint32_t *)(ebp + 4));
  100528:	8b 45 08             	mov    0x8(%ebp),%eax
  10052b:	83 c0 04             	add    $0x4,%eax
  10052e:	8b 00                	mov    (%eax),%eax
  100530:	89 45 f4             	mov    %eax,-0xc(%ebp)
		eips[i] = eip;
  100533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100536:	c1 e0 02             	shl    $0x2,%eax
  100539:	03 45 0c             	add    0xc(%ebp),%eax
  10053c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10053f:	89 10                	mov    %edx,(%eax)
		cprintf("ebp %08x  eip %08x  ", ebp, (*(uint32_t *)(ebp + 4)));
  100541:	8b 45 08             	mov    0x8(%ebp),%eax
  100544:	83 c0 04             	add    $0x4,%eax
  100547:	8b 00                	mov    (%eax),%eax
  100549:	89 44 24 08          	mov    %eax,0x8(%esp)
  10054d:	8b 45 08             	mov    0x8(%ebp),%eax
  100550:	89 44 24 04          	mov    %eax,0x4(%esp)
  100554:	c7 04 24 15 5a 10 00 	movl   $0x105a15,(%esp)
  10055b:	e8 e5 4c 00 00       	call   105245 <cprintf>
		cprintf("args %08x %08x %08x %08x %08x\n",
				(*(uint32_t *)(ebp + 8)),
				(*(uint32_t *)(ebp + 12)),
				(*(uint32_t *)(ebp + 16)),
				(*(uint32_t *)(ebp + 20)),
				(*(uint32_t *)(ebp + 24)));
  100560:	8b 45 08             	mov    0x8(%ebp),%eax
  100563:	83 c0 18             	add    $0x18,%eax
	int i = 0;
	for(; i < DEBUG_TRACEFRAMES && ebp; i++) {
		uint32_t eip = (*(uint32_t *)(ebp + 4));
		eips[i] = eip;
		cprintf("ebp %08x  eip %08x  ", ebp, (*(uint32_t *)(ebp + 4)));
		cprintf("args %08x %08x %08x %08x %08x\n",
  100566:	8b 30                	mov    (%eax),%esi
				(*(uint32_t *)(ebp + 8)),
				(*(uint32_t *)(ebp + 12)),
				(*(uint32_t *)(ebp + 16)),
				(*(uint32_t *)(ebp + 20)),
  100568:	8b 45 08             	mov    0x8(%ebp),%eax
  10056b:	83 c0 14             	add    $0x14,%eax
	int i = 0;
	for(; i < DEBUG_TRACEFRAMES && ebp; i++) {
		uint32_t eip = (*(uint32_t *)(ebp + 4));
		eips[i] = eip;
		cprintf("ebp %08x  eip %08x  ", ebp, (*(uint32_t *)(ebp + 4)));
		cprintf("args %08x %08x %08x %08x %08x\n",
  10056e:	8b 18                	mov    (%eax),%ebx
				(*(uint32_t *)(ebp + 8)),
				(*(uint32_t *)(ebp + 12)),
				(*(uint32_t *)(ebp + 16)),
  100570:	8b 45 08             	mov    0x8(%ebp),%eax
  100573:	83 c0 10             	add    $0x10,%eax
	int i = 0;
	for(; i < DEBUG_TRACEFRAMES && ebp; i++) {
		uint32_t eip = (*(uint32_t *)(ebp + 4));
		eips[i] = eip;
		cprintf("ebp %08x  eip %08x  ", ebp, (*(uint32_t *)(ebp + 4)));
		cprintf("args %08x %08x %08x %08x %08x\n",
  100576:	8b 08                	mov    (%eax),%ecx
				(*(uint32_t *)(ebp + 8)),
				(*(uint32_t *)(ebp + 12)),
  100578:	8b 45 08             	mov    0x8(%ebp),%eax
  10057b:	83 c0 0c             	add    $0xc,%eax
	int i = 0;
	for(; i < DEBUG_TRACEFRAMES && ebp; i++) {
		uint32_t eip = (*(uint32_t *)(ebp + 4));
		eips[i] = eip;
		cprintf("ebp %08x  eip %08x  ", ebp, (*(uint32_t *)(ebp + 4)));
		cprintf("args %08x %08x %08x %08x %08x\n",
  10057e:	8b 10                	mov    (%eax),%edx
				(*(uint32_t *)(ebp + 8)),
  100580:	8b 45 08             	mov    0x8(%ebp),%eax
  100583:	83 c0 08             	add    $0x8,%eax
	int i = 0;
	for(; i < DEBUG_TRACEFRAMES && ebp; i++) {
		uint32_t eip = (*(uint32_t *)(ebp + 4));
		eips[i] = eip;
		cprintf("ebp %08x  eip %08x  ", ebp, (*(uint32_t *)(ebp + 4)));
		cprintf("args %08x %08x %08x %08x %08x\n",
  100586:	8b 00                	mov    (%eax),%eax
  100588:	89 74 24 14          	mov    %esi,0x14(%esp)
  10058c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  100590:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100594:	89 54 24 08          	mov    %edx,0x8(%esp)
  100598:	89 44 24 04          	mov    %eax,0x4(%esp)
  10059c:	c7 04 24 2c 5a 10 00 	movl   $0x105a2c,(%esp)
  1005a3:	e8 9d 4c 00 00       	call   105245 <cprintf>
				(*(uint32_t *)(ebp + 8)),
				(*(uint32_t *)(ebp + 12)),
				(*(uint32_t *)(ebp + 16)),
				(*(uint32_t *)(ebp + 20)),
				(*(uint32_t *)(ebp + 24)));
		ebp = (*(uint32_t *)(ebp));
  1005a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1005ab:	8b 00                	mov    (%eax),%eax
  1005ad:	89 45 08             	mov    %eax,0x8(%ebp)
// Record the current call stack in eips[] by following the %ebp chain.
void gcc_noinline
debug_trace(uint32_t ebp, uint32_t eips[DEBUG_TRACEFRAMES])
{
	int i = 0;
	for(; i < DEBUG_TRACEFRAMES && ebp; i++) {
  1005b0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  1005b4:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
  1005b8:	7f 1f                	jg     1005d9 <debug_trace+0xc5>
  1005ba:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1005be:	0f 85 64 ff ff ff    	jne    100528 <debug_trace+0x14>
				(*(uint32_t *)(ebp + 16)),
				(*(uint32_t *)(ebp + 20)),
				(*(uint32_t *)(ebp + 24)));
		ebp = (*(uint32_t *)(ebp));
	}
	for(; i < DEBUG_TRACEFRAMES; i++) { eips[i] = 0; }
  1005c4:	eb 13                	jmp    1005d9 <debug_trace+0xc5>
  1005c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005c9:	c1 e0 02             	shl    $0x2,%eax
  1005cc:	03 45 0c             	add    0xc(%ebp),%eax
  1005cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  1005d5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  1005d9:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
  1005dd:	7e e7                	jle    1005c6 <debug_trace+0xb2>
}
  1005df:	83 c4 30             	add    $0x30,%esp
  1005e2:	5b                   	pop    %ebx
  1005e3:	5e                   	pop    %esi
  1005e4:	5d                   	pop    %ebp
  1005e5:	c3                   	ret    

001005e6 <f3>:


static void gcc_noinline f3(int r, uint32_t *e) { debug_trace(read_ebp(), e); }
  1005e6:	55                   	push   %ebp
  1005e7:	89 e5                	mov    %esp,%ebp
  1005e9:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=rm" (ebp));
  1005ec:	89 6d f4             	mov    %ebp,-0xc(%ebp)
        return ebp;
  1005ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  1005f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1005f9:	89 04 24             	mov    %eax,(%esp)
  1005fc:	e8 13 ff ff ff       	call   100514 <debug_trace>
  100601:	c9                   	leave  
  100602:	c3                   	ret    

00100603 <f2>:
static void gcc_noinline f2(int r, uint32_t *e) { r & 2 ? f3(r,e) : f3(r,e); }
  100603:	55                   	push   %ebp
  100604:	89 e5                	mov    %esp,%ebp
  100606:	83 ec 18             	sub    $0x18,%esp
  100609:	8b 45 08             	mov    0x8(%ebp),%eax
  10060c:	83 e0 02             	and    $0x2,%eax
  10060f:	85 c0                	test   %eax,%eax
  100611:	74 14                	je     100627 <f2+0x24>
  100613:	8b 45 0c             	mov    0xc(%ebp),%eax
  100616:	89 44 24 04          	mov    %eax,0x4(%esp)
  10061a:	8b 45 08             	mov    0x8(%ebp),%eax
  10061d:	89 04 24             	mov    %eax,(%esp)
  100620:	e8 c1 ff ff ff       	call   1005e6 <f3>
  100625:	eb 12                	jmp    100639 <f2+0x36>
  100627:	8b 45 0c             	mov    0xc(%ebp),%eax
  10062a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10062e:	8b 45 08             	mov    0x8(%ebp),%eax
  100631:	89 04 24             	mov    %eax,(%esp)
  100634:	e8 ad ff ff ff       	call   1005e6 <f3>
  100639:	c9                   	leave  
  10063a:	c3                   	ret    

0010063b <f1>:
static void gcc_noinline f1(int r, uint32_t *e) { r & 1 ? f2(r,e) : f2(r,e); }
  10063b:	55                   	push   %ebp
  10063c:	89 e5                	mov    %esp,%ebp
  10063e:	83 ec 18             	sub    $0x18,%esp
  100641:	8b 45 08             	mov    0x8(%ebp),%eax
  100644:	83 e0 01             	and    $0x1,%eax
  100647:	84 c0                	test   %al,%al
  100649:	74 14                	je     10065f <f1+0x24>
  10064b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10064e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100652:	8b 45 08             	mov    0x8(%ebp),%eax
  100655:	89 04 24             	mov    %eax,(%esp)
  100658:	e8 a6 ff ff ff       	call   100603 <f2>
  10065d:	eb 12                	jmp    100671 <f1+0x36>
  10065f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100662:	89 44 24 04          	mov    %eax,0x4(%esp)
  100666:	8b 45 08             	mov    0x8(%ebp),%eax
  100669:	89 04 24             	mov    %eax,(%esp)
  10066c:	e8 92 ff ff ff       	call   100603 <f2>
  100671:	c9                   	leave  
  100672:	c3                   	ret    

00100673 <debug_check>:

// Test the backtrace implementation for correct operation
void
debug_check(void)
{
  100673:	55                   	push   %ebp
  100674:	89 e5                	mov    %esp,%ebp
  100676:	81 ec c8 00 00 00    	sub    $0xc8,%esp
	uint32_t eips[4][DEBUG_TRACEFRAMES];
	int r, i;

	// produce several related backtraces...
	for (i = 0; i < 4; i++)
  10067c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100683:	eb 29                	jmp    1006ae <debug_check+0x3b>
		f1(i, eips[i]);
  100685:	8d 8d 50 ff ff ff    	lea    -0xb0(%ebp),%ecx
  10068b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10068e:	89 d0                	mov    %edx,%eax
  100690:	c1 e0 02             	shl    $0x2,%eax
  100693:	01 d0                	add    %edx,%eax
  100695:	c1 e0 03             	shl    $0x3,%eax
  100698:	8d 04 01             	lea    (%ecx,%eax,1),%eax
  10069b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006a2:	89 04 24             	mov    %eax,(%esp)
  1006a5:	e8 91 ff ff ff       	call   10063b <f1>
{
	uint32_t eips[4][DEBUG_TRACEFRAMES];
	int r, i;

	// produce several related backtraces...
	for (i = 0; i < 4; i++)
  1006aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1006ae:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
  1006b2:	7e d1                	jle    100685 <debug_check+0x12>
		f1(i, eips[i]);

	// ...and make sure they come out correctly.
	for (r = 0; r < 4; r++)
  1006b4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1006bb:	e9 bc 00 00 00       	jmp    10077c <debug_check+0x109>
		for (i = 0; i < DEBUG_TRACEFRAMES; i++) {
  1006c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1006c7:	e9 a2 00 00 00       	jmp    10076e <debug_check+0xfb>
			assert((eips[r][i] != 0) == (i < 5));
  1006cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1006cf:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  1006d2:	89 d0                	mov    %edx,%eax
  1006d4:	c1 e0 02             	shl    $0x2,%eax
  1006d7:	01 d0                	add    %edx,%eax
  1006d9:	01 c0                	add    %eax,%eax
  1006db:	01 c8                	add    %ecx,%eax
  1006dd:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
  1006e4:	85 c0                	test   %eax,%eax
  1006e6:	0f 95 c2             	setne  %dl
  1006e9:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
  1006ed:	0f 9e c0             	setle  %al
  1006f0:	31 d0                	xor    %edx,%eax
  1006f2:	84 c0                	test   %al,%al
  1006f4:	74 24                	je     10071a <debug_check+0xa7>
  1006f6:	c7 44 24 0c 4b 5a 10 	movl   $0x105a4b,0xc(%esp)
  1006fd:	00 
  1006fe:	c7 44 24 08 68 5a 10 	movl   $0x105a68,0x8(%esp)
  100705:	00 
  100706:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  10070d:	00 
  10070e:	c7 04 24 7d 5a 10 00 	movl   $0x105a7d,(%esp)
  100715:	e8 f2 fc ff ff       	call   10040c <debug_panic>
			if (i >= 2)
  10071a:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  10071e:	7e 4a                	jle    10076a <debug_check+0xf7>
				assert(eips[r][i] == eips[0][i]);
  100720:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100723:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100726:	89 d0                	mov    %edx,%eax
  100728:	c1 e0 02             	shl    $0x2,%eax
  10072b:	01 d0                	add    %edx,%eax
  10072d:	01 c0                	add    %eax,%eax
  10072f:	01 c8                	add    %ecx,%eax
  100731:	8b 94 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%edx
  100738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10073b:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
  100742:	39 c2                	cmp    %eax,%edx
  100744:	74 24                	je     10076a <debug_check+0xf7>
  100746:	c7 44 24 0c 8a 5a 10 	movl   $0x105a8a,0xc(%esp)
  10074d:	00 
  10074e:	c7 44 24 08 68 5a 10 	movl   $0x105a68,0x8(%esp)
  100755:	00 
  100756:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  10075d:	00 
  10075e:	c7 04 24 7d 5a 10 00 	movl   $0x105a7d,(%esp)
  100765:	e8 a2 fc ff ff       	call   10040c <debug_panic>
	for (i = 0; i < 4; i++)
		f1(i, eips[i]);

	// ...and make sure they come out correctly.
	for (r = 0; r < 4; r++)
		for (i = 0; i < DEBUG_TRACEFRAMES; i++) {
  10076a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10076e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  100772:	0f 8e 54 ff ff ff    	jle    1006cc <debug_check+0x59>
	// produce several related backtraces...
	for (i = 0; i < 4; i++)
		f1(i, eips[i]);

	// ...and make sure they come out correctly.
	for (r = 0; r < 4; r++)
  100778:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  10077c:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
  100780:	0f 8e 3a ff ff ff    	jle    1006c0 <debug_check+0x4d>
		for (i = 0; i < DEBUG_TRACEFRAMES; i++) {
			assert((eips[r][i] != 0) == (i < 5));
			if (i >= 2)
				assert(eips[r][i] == eips[0][i]);
		}
	assert(eips[0][0] == eips[1][0]);
  100786:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  10078c:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  100792:	39 c2                	cmp    %eax,%edx
  100794:	74 24                	je     1007ba <debug_check+0x147>
  100796:	c7 44 24 0c a3 5a 10 	movl   $0x105aa3,0xc(%esp)
  10079d:	00 
  10079e:	c7 44 24 08 68 5a 10 	movl   $0x105a68,0x8(%esp)
  1007a5:	00 
  1007a6:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
  1007ad:	00 
  1007ae:	c7 04 24 7d 5a 10 00 	movl   $0x105a7d,(%esp)
  1007b5:	e8 52 fc ff ff       	call   10040c <debug_panic>
	assert(eips[2][0] == eips[3][0]);
  1007ba:	8b 55 a0             	mov    -0x60(%ebp),%edx
  1007bd:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1007c0:	39 c2                	cmp    %eax,%edx
  1007c2:	74 24                	je     1007e8 <debug_check+0x175>
  1007c4:	c7 44 24 0c bc 5a 10 	movl   $0x105abc,0xc(%esp)
  1007cb:	00 
  1007cc:	c7 44 24 08 68 5a 10 	movl   $0x105a68,0x8(%esp)
  1007d3:	00 
  1007d4:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
  1007db:	00 
  1007dc:	c7 04 24 7d 5a 10 00 	movl   $0x105a7d,(%esp)
  1007e3:	e8 24 fc ff ff       	call   10040c <debug_panic>
	assert(eips[1][0] != eips[2][0]);
  1007e8:	8b 95 78 ff ff ff    	mov    -0x88(%ebp),%edx
  1007ee:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1007f1:	39 c2                	cmp    %eax,%edx
  1007f3:	75 24                	jne    100819 <debug_check+0x1a6>
  1007f5:	c7 44 24 0c d5 5a 10 	movl   $0x105ad5,0xc(%esp)
  1007fc:	00 
  1007fd:	c7 44 24 08 68 5a 10 	movl   $0x105a68,0x8(%esp)
  100804:	00 
  100805:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  10080c:	00 
  10080d:	c7 04 24 7d 5a 10 00 	movl   $0x105a7d,(%esp)
  100814:	e8 f3 fb ff ff       	call   10040c <debug_panic>
	assert(eips[0][1] == eips[2][1]);
  100819:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  10081f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  100822:	39 c2                	cmp    %eax,%edx
  100824:	74 24                	je     10084a <debug_check+0x1d7>
  100826:	c7 44 24 0c ee 5a 10 	movl   $0x105aee,0xc(%esp)
  10082d:	00 
  10082e:	c7 44 24 08 68 5a 10 	movl   $0x105a68,0x8(%esp)
  100835:	00 
  100836:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  10083d:	00 
  10083e:	c7 04 24 7d 5a 10 00 	movl   $0x105a7d,(%esp)
  100845:	e8 c2 fb ff ff       	call   10040c <debug_panic>
	assert(eips[1][1] == eips[3][1]);
  10084a:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  100850:	8b 45 cc             	mov    -0x34(%ebp),%eax
  100853:	39 c2                	cmp    %eax,%edx
  100855:	74 24                	je     10087b <debug_check+0x208>
  100857:	c7 44 24 0c 07 5b 10 	movl   $0x105b07,0xc(%esp)
  10085e:	00 
  10085f:	c7 44 24 08 68 5a 10 	movl   $0x105a68,0x8(%esp)
  100866:	00 
  100867:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  10086e:	00 
  10086f:	c7 04 24 7d 5a 10 00 	movl   $0x105a7d,(%esp)
  100876:	e8 91 fb ff ff       	call   10040c <debug_panic>
	assert(eips[0][1] != eips[1][1]);
  10087b:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  100881:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  100887:	39 c2                	cmp    %eax,%edx
  100889:	75 24                	jne    1008af <debug_check+0x23c>
  10088b:	c7 44 24 0c 20 5b 10 	movl   $0x105b20,0xc(%esp)
  100892:	00 
  100893:	c7 44 24 08 68 5a 10 	movl   $0x105a68,0x8(%esp)
  10089a:	00 
  10089b:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  1008a2:	00 
  1008a3:	c7 04 24 7d 5a 10 00 	movl   $0x105a7d,(%esp)
  1008aa:	e8 5d fb ff ff       	call   10040c <debug_panic>

	cprintf("debug_check() succeeded!\n");
  1008af:	c7 04 24 39 5b 10 00 	movl   $0x105b39,(%esp)
  1008b6:	e8 8a 49 00 00       	call   105245 <cprintf>
}
  1008bb:	c9                   	leave  
  1008bc:	c3                   	ret    
  1008bd:	90                   	nop
  1008be:	90                   	nop
  1008bf:	90                   	nop

001008c0 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  1008c0:	55                   	push   %ebp
  1008c1:	89 e5                	mov    %esp,%ebp
  1008c3:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  1008c6:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  1008c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  1008cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1008cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1008d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1008d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  1008da:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008dd:	8b 80 b8 00 00 00    	mov    0xb8(%eax),%eax
  1008e3:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  1008e8:	74 24                	je     10090e <cpu_cur+0x4e>
  1008ea:	c7 44 24 0c 54 5b 10 	movl   $0x105b54,0xc(%esp)
  1008f1:	00 
  1008f2:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  1008f9:	00 
  1008fa:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  100901:	00 
  100902:	c7 04 24 7f 5b 10 00 	movl   $0x105b7f,(%esp)
  100909:	e8 fe fa ff ff       	call   10040c <debug_panic>
	return c;
  10090e:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  100911:	c9                   	leave  
  100912:	c3                   	ret    

00100913 <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  100913:	55                   	push   %ebp
  100914:	89 e5                	mov    %esp,%ebp
  100916:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  100919:	e8 a2 ff ff ff       	call   1008c0 <cpu_cur>
  10091e:	3d 00 70 10 00       	cmp    $0x107000,%eax
  100923:	0f 94 c0             	sete   %al
  100926:	0f b6 c0             	movzbl %al,%eax
}
  100929:	c9                   	leave  
  10092a:	c3                   	ret    

0010092b <mem_init>:

void mem_check(void);

void
mem_init(void)
{
  10092b:	55                   	push   %ebp
  10092c:	89 e5                	mov    %esp,%ebp
  10092e:	83 ec 68             	sub    $0x68,%esp
	if (!cpu_onboot())	// only do once, on the boot CPU
  100931:	e8 dd ff ff ff       	call   100913 <cpu_onboot>
  100936:	85 c0                	test   %eax,%eax
  100938:	0f 84 22 03 00 00    	je     100c60 <mem_init+0x335>
	// is available in the system (in bytes),
	// by reading the PC's BIOS-managed nonvolatile RAM (NVRAM).
	// The NVRAM tells us how many kilobytes there are.
	// Since the count is 16 bits, this gives us up to 64MB of RAM;
	// additional RAM beyond that would have to be detected another way.
	size_t basemem = ROUNDDOWN(nvram_read16(NVRAM_BASELO)*1024, PAGESIZE);
  10093e:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
  100945:	e8 f1 3b 00 00       	call   10453b <nvram_read16>
  10094a:	c1 e0 0a             	shl    $0xa,%eax
  10094d:	89 45 b8             	mov    %eax,-0x48(%ebp)
  100950:	8b 45 b8             	mov    -0x48(%ebp),%eax
  100953:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  100958:	89 45 a8             	mov    %eax,-0x58(%ebp)
	size_t extmem = ROUNDDOWN(nvram_read16(NVRAM_EXTLO)*1024, PAGESIZE);
  10095b:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
  100962:	e8 d4 3b 00 00       	call   10453b <nvram_read16>
  100967:	c1 e0 0a             	shl    $0xa,%eax
  10096a:	89 45 bc             	mov    %eax,-0x44(%ebp)
  10096d:	8b 45 bc             	mov    -0x44(%ebp),%eax
  100970:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  100975:	89 45 ac             	mov    %eax,-0x54(%ebp)

	warn("Assuming we have 1GB of memory!");
  100978:	c7 44 24 08 8c 5b 10 	movl   $0x105b8c,0x8(%esp)
  10097f:	00 
  100980:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  100987:	00 
  100988:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  10098f:	e8 37 fb ff ff       	call   1004cb <debug_warn>
	extmem = 1024*1024*1024 - MEM_EXT;	// assume 1GB total memory
  100994:	c7 45 ac 00 00 f0 3f 	movl   $0x3ff00000,-0x54(%ebp)

	// The maximum physical address is the top of extended memory.
	mem_max = MEM_EXT + extmem;
  10099b:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10099e:	05 00 00 10 00       	add    $0x100000,%eax
  1009a3:	a3 80 e2 10 00       	mov    %eax,0x10e280

	// Compute the total number of physical pages (including I/O holes)
	mem_npage = mem_max / PAGESIZE;
  1009a8:	a1 80 e2 10 00       	mov    0x10e280,%eax
  1009ad:	c1 e8 0c             	shr    $0xc,%eax
  1009b0:	a3 7c e2 10 00       	mov    %eax,0x10e27c

	cprintf("Physical memory: %dK available, ", (int)(mem_max/1024));
  1009b5:	a1 80 e2 10 00       	mov    0x10e280,%eax
  1009ba:	c1 e8 0a             	shr    $0xa,%eax
  1009bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009c1:	c7 04 24 b8 5b 10 00 	movl   $0x105bb8,(%esp)
  1009c8:	e8 78 48 00 00       	call   105245 <cprintf>
	cprintf("base = %dK, extended = %dK\n",
		(int)(basemem/1024), (int)(extmem/1024));
  1009cd:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1009d0:	c1 e8 0a             	shr    $0xa,%eax

	// Compute the total number of physical pages (including I/O holes)
	mem_npage = mem_max / PAGESIZE;

	cprintf("Physical memory: %dK available, ", (int)(mem_max/1024));
	cprintf("base = %dK, extended = %dK\n",
  1009d3:	89 c2                	mov    %eax,%edx
		(int)(basemem/1024), (int)(extmem/1024));
  1009d5:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1009d8:	c1 e8 0a             	shr    $0xa,%eax

	// Compute the total number of physical pages (including I/O holes)
	mem_npage = mem_max / PAGESIZE;

	cprintf("Physical memory: %dK available, ", (int)(mem_max/1024));
	cprintf("base = %dK, extended = %dK\n",
  1009db:	89 54 24 08          	mov    %edx,0x8(%esp)
  1009df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009e3:	c7 04 24 d9 5b 10 00 	movl   $0x105bd9,(%esp)
  1009ea:	e8 56 48 00 00       	call   105245 <cprintf>
		(int)(basemem/1024), (int)(extmem/1024));

	// Insert code here to:
	// (1)	allocate physical memory for the mem_pageinfo array,
	//	making it big enough to hold mem_npage entries.
	mem_pageinfo = mem_ptr(ROUNDUP(mem_phys(end), PAGESIZE));
  1009ef:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  1009f6:	b8 4c e9 10 00       	mov    $0x10e94c,%eax
  1009fb:	83 e8 01             	sub    $0x1,%eax
  1009fe:	03 45 c0             	add    -0x40(%ebp),%eax
  100a01:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  100a04:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  100a07:	ba 00 00 00 00       	mov    $0x0,%edx
  100a0c:	f7 75 c0             	divl   -0x40(%ebp)
  100a0f:	89 d0                	mov    %edx,%eax
  100a11:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  100a14:	89 d1                	mov    %edx,%ecx
  100a16:	29 c1                	sub    %eax,%ecx
  100a18:	89 c8                	mov    %ecx,%eax
  100a1a:	a3 84 e2 10 00       	mov    %eax,0x10e284
	cprintf("kernel end %p, pageinfo %p\n", end, mem_pageinfo);
  100a1f:	a1 84 e2 10 00       	mov    0x10e284,%eax
  100a24:	89 44 24 08          	mov    %eax,0x8(%esp)
  100a28:	c7 44 24 04 4c e9 10 	movl   $0x10e94c,0x4(%esp)
  100a2f:	00 
  100a30:	c7 04 24 f5 5b 10 00 	movl   $0x105bf5,(%esp)
  100a37:	e8 09 48 00 00       	call   105245 <cprintf>
	cprintf("num pages %d, pagetable takes %d pages\n", mem_npage,
		ROUNDUP(mem_npage*sizeof(pageinfo), PAGESIZE) / PAGESIZE);
  100a3c:	c7 45 c8 00 10 00 00 	movl   $0x1000,-0x38(%ebp)
  100a43:	a1 7c e2 10 00       	mov    0x10e27c,%eax
  100a48:	c1 e0 03             	shl    $0x3,%eax
  100a4b:	03 45 c8             	add    -0x38(%ebp),%eax
  100a4e:	83 e8 01             	sub    $0x1,%eax
  100a51:	89 45 cc             	mov    %eax,-0x34(%ebp)
  100a54:	8b 45 cc             	mov    -0x34(%ebp),%eax
  100a57:	ba 00 00 00 00       	mov    $0x0,%edx
  100a5c:	f7 75 c8             	divl   -0x38(%ebp)
  100a5f:	89 d0                	mov    %edx,%eax
  100a61:	8b 55 cc             	mov    -0x34(%ebp),%edx
  100a64:	89 d1                	mov    %edx,%ecx
  100a66:	29 c1                	sub    %eax,%ecx
  100a68:	89 c8                	mov    %ecx,%eax
	// Insert code here to:
	// (1)	allocate physical memory for the mem_pageinfo array,
	//	making it big enough to hold mem_npage entries.
	mem_pageinfo = mem_ptr(ROUNDUP(mem_phys(end), PAGESIZE));
	cprintf("kernel end %p, pageinfo %p\n", end, mem_pageinfo);
	cprintf("num pages %d, pagetable takes %d pages\n", mem_npage,
  100a6a:	89 c2                	mov    %eax,%edx
  100a6c:	c1 ea 0c             	shr    $0xc,%edx
  100a6f:	a1 7c e2 10 00       	mov    0x10e27c,%eax
  100a74:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a78:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a7c:	c7 04 24 14 5c 10 00 	movl   $0x105c14,(%esp)
  100a83:	e8 bd 47 00 00       	call   105245 <cprintf>
	//     Some of it is in use, some is free.
	//     Which pages hold the kernel and the pageinfo array?
	//     Hint: the linker places the kernel (see start and end above),
	//     but YOU decide where to place the pageinfo array.
	// Change the code to reflect this.
	pageinfo **freetail = &mem_freelist;
  100a88:	c7 45 b0 78 e2 10 00 	movl   $0x10e278,-0x50(%ebp)
	int i;
	for (i = 0; i < mem_npage; i++) {
  100a8f:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%ebp)
  100a96:	e9 a5 01 00 00       	jmp    100c40 <mem_init+0x315>
		if(i == 0 || i == 1) {
  100a9b:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  100a9f:	74 06                	je     100aa7 <mem_init+0x17c>
  100aa1:	83 7d b4 01          	cmpl   $0x1,-0x4c(%ebp)
  100aa5:	75 18                	jne    100abf <mem_init+0x194>
			cprintf("page %d: IDT/BIOS/IO\n", i);
  100aa7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  100aae:	c7 04 24 3c 5c 10 00 	movl   $0x105c3c,(%esp)
  100ab5:	e8 8b 47 00 00       	call   105245 <cprintf>
			continue;
  100aba:	e9 7d 01 00 00       	jmp    100c3c <mem_init+0x311>
		}
		if(i >= MEM_IO/PAGESIZE && i < MEM_EXT/PAGESIZE) {
  100abf:	81 7d b4 9f 00 00 00 	cmpl   $0x9f,-0x4c(%ebp)
  100ac6:	7e 21                	jle    100ae9 <mem_init+0x1be>
  100ac8:	81 7d b4 ff 00 00 00 	cmpl   $0xff,-0x4c(%ebp)
  100acf:	7f 18                	jg     100ae9 <mem_init+0x1be>
			cprintf("page %d: BIOS IO\n", i);
  100ad1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ad8:	c7 04 24 52 5c 10 00 	movl   $0x105c52,(%esp)
  100adf:	e8 61 47 00 00       	call   105245 <cprintf>
			continue;
  100ae4:	e9 53 01 00 00       	jmp    100c3c <mem_init+0x311>
		}
		uint32_t kstartpg = ROUNDDOWN(mem_phys(start),PAGESIZE);
  100ae9:	c7 45 e0 0c 00 10 00 	movl   $0x10000c,-0x20(%ebp)
  100af0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100af3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  100af8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		kstartpg /= PAGESIZE;
  100afb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100afe:	c1 e8 0c             	shr    $0xc,%eax
  100b01:	89 45 d0             	mov    %eax,-0x30(%ebp)
		uint32_t kendpg = ROUNDUP(mem_phys(end), PAGESIZE);
  100b04:	c7 45 e4 00 10 00 00 	movl   $0x1000,-0x1c(%ebp)
  100b0b:	b8 4c e9 10 00       	mov    $0x10e94c,%eax
  100b10:	83 e8 01             	sub    $0x1,%eax
  100b13:	03 45 e4             	add    -0x1c(%ebp),%eax
  100b16:	89 45 e8             	mov    %eax,-0x18(%ebp)
  100b19:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  100b21:	f7 75 e4             	divl   -0x1c(%ebp)
  100b24:	89 d0                	mov    %edx,%eax
  100b26:	8b 55 e8             	mov    -0x18(%ebp),%edx
  100b29:	89 d1                	mov    %edx,%ecx
  100b2b:	29 c1                	sub    %eax,%ecx
  100b2d:	89 c8                	mov    %ecx,%eax
  100b2f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		kendpg /= PAGESIZE;
  100b32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100b35:	c1 e8 0c             	shr    $0xc,%eax
  100b38:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		if(i >= kstartpg && i < kendpg) {
  100b3b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100b3e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  100b41:	72 20                	jb     100b63 <mem_init+0x238>
  100b43:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100b46:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  100b49:	73 18                	jae    100b63 <mem_init+0x238>
			cprintf("page %d: KERNEL\n", i);
  100b4b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b52:	c7 04 24 64 5c 10 00 	movl   $0x105c64,(%esp)
  100b59:	e8 e7 46 00 00       	call   105245 <cprintf>
			continue;
  100b5e:	e9 d9 00 00 00       	jmp    100c3c <mem_init+0x311>
		}
		uint32_t mstartpg = ROUNDDOWN(mem_phys(mem_pageinfo),PAGESIZE);
  100b63:	a1 84 e2 10 00       	mov    0x10e284,%eax
  100b68:	89 45 ec             	mov    %eax,-0x14(%ebp)
  100b6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100b6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  100b73:	89 45 d8             	mov    %eax,-0x28(%ebp)
		mstartpg /= PAGESIZE;
  100b76:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100b79:	c1 e8 0c             	shr    $0xc,%eax
  100b7c:	89 45 d8             	mov    %eax,-0x28(%ebp)
		uint32_t mendpg = mem_phys(&mem_pageinfo[mem_npage]);
  100b7f:	a1 84 e2 10 00       	mov    0x10e284,%eax
  100b84:	8b 15 7c e2 10 00    	mov    0x10e27c,%edx
  100b8a:	c1 e2 03             	shl    $0x3,%edx
  100b8d:	01 d0                	add    %edx,%eax
  100b8f:	89 45 dc             	mov    %eax,-0x24(%ebp)
		mendpg = ROUNDUP(mendpg, PAGESIZE) / PAGESIZE;
  100b92:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  100b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b9c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100b9f:	8d 04 02             	lea    (%edx,%eax,1),%eax
  100ba2:	83 e8 01             	sub    $0x1,%eax
  100ba5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bab:	ba 00 00 00 00       	mov    $0x0,%edx
  100bb0:	f7 75 f0             	divl   -0x10(%ebp)
  100bb3:	89 d0                	mov    %edx,%eax
  100bb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100bb8:	89 d1                	mov    %edx,%ecx
  100bba:	29 c1                	sub    %eax,%ecx
  100bbc:	89 c8                	mov    %ecx,%eax
  100bbe:	c1 e8 0c             	shr    $0xc,%eax
  100bc1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		if(i >= mstartpg && i < mendpg) {
  100bc4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100bc7:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  100bca:	72 1d                	jb     100be9 <mem_init+0x2be>
  100bcc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100bcf:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  100bd2:	73 15                	jae    100be9 <mem_init+0x2be>
			cprintf("page %d: MEMPAGES\n", i);
  100bd4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bdb:	c7 04 24 75 5c 10 00 	movl   $0x105c75,(%esp)
  100be2:	e8 5e 46 00 00       	call   105245 <cprintf>
			continue;
  100be7:	eb 53                	jmp    100c3c <mem_init+0x311>
		}
		if(i < 1000) cprintf("page %d: free\n", i);
  100be9:	81 7d b4 e7 03 00 00 	cmpl   $0x3e7,-0x4c(%ebp)
  100bf0:	7f 13                	jg     100c05 <mem_init+0x2da>
  100bf2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  100bf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bf9:	c7 04 24 88 5c 10 00 	movl   $0x105c88,(%esp)
  100c00:	e8 40 46 00 00       	call   105245 <cprintf>

		// A free page has no references to it.
		mem_pageinfo[i].refcount = 0;
  100c05:	a1 84 e2 10 00       	mov    0x10e284,%eax
  100c0a:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  100c0d:	c1 e2 03             	shl    $0x3,%edx
  100c10:	01 d0                	add    %edx,%eax
  100c12:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

		// Add the page to the end of the free list.
		*freetail = &mem_pageinfo[i];
  100c19:	a1 84 e2 10 00       	mov    0x10e284,%eax
  100c1e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  100c21:	c1 e2 03             	shl    $0x3,%edx
  100c24:	8d 14 10             	lea    (%eax,%edx,1),%edx
  100c27:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c2a:	89 10                	mov    %edx,(%eax)
		freetail = &mem_pageinfo[i].free_next;
  100c2c:	a1 84 e2 10 00       	mov    0x10e284,%eax
  100c31:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  100c34:	c1 e2 03             	shl    $0x3,%edx
  100c37:	01 d0                	add    %edx,%eax
  100c39:	89 45 b0             	mov    %eax,-0x50(%ebp)
	//     Hint: the linker places the kernel (see start and end above),
	//     but YOU decide where to place the pageinfo array.
	// Change the code to reflect this.
	pageinfo **freetail = &mem_freelist;
	int i;
	for (i = 0; i < mem_npage; i++) {
  100c3c:	83 45 b4 01          	addl   $0x1,-0x4c(%ebp)
  100c40:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  100c43:	a1 7c e2 10 00       	mov    0x10e27c,%eax
  100c48:	39 c2                	cmp    %eax,%edx
  100c4a:	0f 82 4b fe ff ff    	jb     100a9b <mem_init+0x170>

		// Add the page to the end of the free list.
		*freetail = &mem_pageinfo[i];
		freetail = &mem_pageinfo[i].free_next;
	}
	*freetail = NULL;	// null-terminate the freelist
  100c50:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// ...and remove this when you're ready.
	// panic("mem_init() not implemented");

	// Check to make sure the page allocator seems to work correctly.
	mem_check();
  100c59:	e8 7b 00 00 00       	call   100cd9 <mem_check>
  100c5e:	eb 01                	jmp    100c61 <mem_init+0x336>

void
mem_init(void)
{
	if (!cpu_onboot())	// only do once, on the boot CPU
		return;
  100c60:	90                   	nop
	// ...and remove this when you're ready.
	// panic("mem_init() not implemented");

	// Check to make sure the page allocator seems to work correctly.
	mem_check();
}
  100c61:	c9                   	leave  
  100c62:	c3                   	ret    

00100c63 <mem_alloc>:
//
// Hint: pi->refs should not be incremented 
// Hint: be sure to use proper mutual exclusion for multiprocessor operation.
pageinfo *
mem_alloc(void)
{
  100c63:	55                   	push   %ebp
  100c64:	89 e5                	mov    %esp,%ebp
  100c66:	83 ec 10             	sub    $0x10,%esp
	if(!mem_freelist) { return NULL; }
  100c69:	a1 78 e2 10 00       	mov    0x10e278,%eax
  100c6e:	85 c0                	test   %eax,%eax
  100c70:	75 07                	jne    100c79 <mem_alloc+0x16>
  100c72:	b8 00 00 00 00       	mov    $0x0,%eax
  100c77:	eb 15                	jmp    100c8e <mem_alloc+0x2b>
	pageinfo *r = mem_freelist;
  100c79:	a1 78 e2 10 00       	mov    0x10e278,%eax
  100c7e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	mem_freelist = r->free_next;
  100c81:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100c84:	8b 00                	mov    (%eax),%eax
  100c86:	a3 78 e2 10 00       	mov    %eax,0x10e278
	// TODO: MUTUAL EXCLUSION
	return r;
  100c8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100c8e:	c9                   	leave  
  100c8f:	c3                   	ret    

00100c90 <mem_free>:
// Return a page to the free list, given its pageinfo pointer.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
mem_free(pageinfo *pi)
{
  100c90:	55                   	push   %ebp
  100c91:	89 e5                	mov    %esp,%ebp
  100c93:	83 ec 18             	sub    $0x18,%esp
	assert(pi->refcount == 0);
  100c96:	8b 45 08             	mov    0x8(%ebp),%eax
  100c99:	8b 40 04             	mov    0x4(%eax),%eax
  100c9c:	85 c0                	test   %eax,%eax
  100c9e:	74 24                	je     100cc4 <mem_free+0x34>
  100ca0:	c7 44 24 0c 97 5c 10 	movl   $0x105c97,0xc(%esp)
  100ca7:	00 
  100ca8:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  100caf:	00 
  100cb0:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
  100cb7:	00 
  100cb8:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  100cbf:	e8 48 f7 ff ff       	call   10040c <debug_panic>
	pi->free_next = mem_freelist;
  100cc4:	8b 15 78 e2 10 00    	mov    0x10e278,%edx
  100cca:	8b 45 08             	mov    0x8(%ebp),%eax
  100ccd:	89 10                	mov    %edx,(%eax)
	mem_freelist = pi;
  100ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  100cd2:	a3 78 e2 10 00       	mov    %eax,0x10e278
}
  100cd7:	c9                   	leave  
  100cd8:	c3                   	ret    

00100cd9 <mem_check>:
// Check the physical page allocator (mem_alloc(), mem_free())
// for correct operation after initialization via mem_init().
//
void
mem_check()
{
  100cd9:	55                   	push   %ebp
  100cda:	89 e5                	mov    %esp,%ebp
  100cdc:	83 ec 38             	sub    $0x38,%esp
	int i;

        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	int freepages = 0;
  100cdf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (pp = mem_freelist; pp != 0; pp = pp->free_next) {
  100ce6:	a1 78 e2 10 00       	mov    0x10e278,%eax
  100ceb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100cee:	eb 38                	jmp    100d28 <mem_check+0x4f>
		memset(mem_pi2ptr(pp), 0x97, 128);
  100cf0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100cf3:	a1 84 e2 10 00       	mov    0x10e284,%eax
  100cf8:	89 d1                	mov    %edx,%ecx
  100cfa:	29 c1                	sub    %eax,%ecx
  100cfc:	89 c8                	mov    %ecx,%eax
  100cfe:	c1 f8 03             	sar    $0x3,%eax
  100d01:	c1 e0 0c             	shl    $0xc,%eax
  100d04:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  100d0b:	00 
  100d0c:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
  100d13:	00 
  100d14:	89 04 24             	mov    %eax,(%esp)
  100d17:	e8 10 47 00 00       	call   10542c <memset>
		freepages++;
  100d1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	int freepages = 0;
	for (pp = mem_freelist; pp != 0; pp = pp->free_next) {
  100d20:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100d23:	8b 00                	mov    (%eax),%eax
  100d25:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100d28:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  100d2c:	75 c2                	jne    100cf0 <mem_check+0x17>
		memset(mem_pi2ptr(pp), 0x97, 128);
		freepages++;
	}
	cprintf("mem_check: %d free pages\n", freepages);
  100d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d31:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d35:	c7 04 24 a9 5c 10 00 	movl   $0x105ca9,(%esp)
  100d3c:	e8 04 45 00 00       	call   105245 <cprintf>
	assert(freepages < mem_npage);	// can't have more free than total!
  100d41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d44:	a1 7c e2 10 00       	mov    0x10e27c,%eax
  100d49:	39 c2                	cmp    %eax,%edx
  100d4b:	72 24                	jb     100d71 <mem_check+0x98>
  100d4d:	c7 44 24 0c c3 5c 10 	movl   $0x105cc3,0xc(%esp)
  100d54:	00 
  100d55:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  100d5c:	00 
  100d5d:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
  100d64:	00 
  100d65:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  100d6c:	e8 9b f6 ff ff       	call   10040c <debug_panic>
	assert(freepages > 16000);	// make sure it's in the right ballpark
  100d71:	81 7d f4 80 3e 00 00 	cmpl   $0x3e80,-0xc(%ebp)
  100d78:	7f 24                	jg     100d9e <mem_check+0xc5>
  100d7a:	c7 44 24 0c d9 5c 10 	movl   $0x105cd9,0xc(%esp)
  100d81:	00 
  100d82:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  100d89:	00 
  100d8a:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  100d91:	00 
  100d92:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  100d99:	e8 6e f6 ff ff       	call   10040c <debug_panic>

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
  100d9e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100da5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100da8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100dab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100dae:	89 45 e0             	mov    %eax,-0x20(%ebp)
	pp0 = mem_alloc(); assert(pp0 != 0);
  100db1:	e8 ad fe ff ff       	call   100c63 <mem_alloc>
  100db6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  100db9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  100dbd:	75 24                	jne    100de3 <mem_check+0x10a>
  100dbf:	c7 44 24 0c eb 5c 10 	movl   $0x105ceb,0xc(%esp)
  100dc6:	00 
  100dc7:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  100dce:	00 
  100dcf:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
  100dd6:	00 
  100dd7:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  100dde:	e8 29 f6 ff ff       	call   10040c <debug_panic>
	pp1 = mem_alloc(); assert(pp1 != 0);
  100de3:	e8 7b fe ff ff       	call   100c63 <mem_alloc>
  100de8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  100deb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  100def:	75 24                	jne    100e15 <mem_check+0x13c>
  100df1:	c7 44 24 0c f4 5c 10 	movl   $0x105cf4,0xc(%esp)
  100df8:	00 
  100df9:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  100e00:	00 
  100e01:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
  100e08:	00 
  100e09:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  100e10:	e8 f7 f5 ff ff       	call   10040c <debug_panic>
	pp2 = mem_alloc(); assert(pp2 != 0);
  100e15:	e8 49 fe ff ff       	call   100c63 <mem_alloc>
  100e1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  100e1d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  100e21:	75 24                	jne    100e47 <mem_check+0x16e>
  100e23:	c7 44 24 0c fd 5c 10 	movl   $0x105cfd,0xc(%esp)
  100e2a:	00 
  100e2b:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  100e32:	00 
  100e33:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  100e3a:	00 
  100e3b:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  100e42:	e8 c5 f5 ff ff       	call   10040c <debug_panic>

	assert(pp0);
  100e47:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  100e4b:	75 24                	jne    100e71 <mem_check+0x198>
  100e4d:	c7 44 24 0c 06 5d 10 	movl   $0x105d06,0xc(%esp)
  100e54:	00 
  100e55:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  100e5c:	00 
  100e5d:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
  100e64:	00 
  100e65:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  100e6c:	e8 9b f5 ff ff       	call   10040c <debug_panic>
	assert(pp1 && pp1 != pp0);
  100e71:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  100e75:	74 08                	je     100e7f <mem_check+0x1a6>
  100e77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100e7a:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  100e7d:	75 24                	jne    100ea3 <mem_check+0x1ca>
  100e7f:	c7 44 24 0c 0a 5d 10 	movl   $0x105d0a,0xc(%esp)
  100e86:	00 
  100e87:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  100e8e:	00 
  100e8f:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
  100e96:	00 
  100e97:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  100e9e:	e8 69 f5 ff ff       	call   10040c <debug_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
  100ea3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  100ea7:	74 10                	je     100eb9 <mem_check+0x1e0>
  100ea9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100eac:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  100eaf:	74 08                	je     100eb9 <mem_check+0x1e0>
  100eb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100eb4:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  100eb7:	75 24                	jne    100edd <mem_check+0x204>
  100eb9:	c7 44 24 0c 1c 5d 10 	movl   $0x105d1c,0xc(%esp)
  100ec0:	00 
  100ec1:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  100ec8:	00 
  100ec9:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  100ed0:	00 
  100ed1:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  100ed8:	e8 2f f5 ff ff       	call   10040c <debug_panic>
        assert(mem_pi2phys(pp0) < mem_npage*PAGESIZE);
  100edd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100ee0:	a1 84 e2 10 00       	mov    0x10e284,%eax
  100ee5:	89 d1                	mov    %edx,%ecx
  100ee7:	29 c1                	sub    %eax,%ecx
  100ee9:	89 c8                	mov    %ecx,%eax
  100eeb:	c1 f8 03             	sar    $0x3,%eax
  100eee:	c1 e0 0c             	shl    $0xc,%eax
  100ef1:	8b 15 7c e2 10 00    	mov    0x10e27c,%edx
  100ef7:	c1 e2 0c             	shl    $0xc,%edx
  100efa:	39 d0                	cmp    %edx,%eax
  100efc:	72 24                	jb     100f22 <mem_check+0x249>
  100efe:	c7 44 24 0c 3c 5d 10 	movl   $0x105d3c,0xc(%esp)
  100f05:	00 
  100f06:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  100f0d:	00 
  100f0e:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
  100f15:	00 
  100f16:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  100f1d:	e8 ea f4 ff ff       	call   10040c <debug_panic>
        assert(mem_pi2phys(pp1) < mem_npage*PAGESIZE);
  100f22:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100f25:	a1 84 e2 10 00       	mov    0x10e284,%eax
  100f2a:	89 d1                	mov    %edx,%ecx
  100f2c:	29 c1                	sub    %eax,%ecx
  100f2e:	89 c8                	mov    %ecx,%eax
  100f30:	c1 f8 03             	sar    $0x3,%eax
  100f33:	c1 e0 0c             	shl    $0xc,%eax
  100f36:	8b 15 7c e2 10 00    	mov    0x10e27c,%edx
  100f3c:	c1 e2 0c             	shl    $0xc,%edx
  100f3f:	39 d0                	cmp    %edx,%eax
  100f41:	72 24                	jb     100f67 <mem_check+0x28e>
  100f43:	c7 44 24 0c 64 5d 10 	movl   $0x105d64,0xc(%esp)
  100f4a:	00 
  100f4b:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  100f52:	00 
  100f53:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
  100f5a:	00 
  100f5b:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  100f62:	e8 a5 f4 ff ff       	call   10040c <debug_panic>
        assert(mem_pi2phys(pp2) < mem_npage*PAGESIZE);
  100f67:	8b 55 e8             	mov    -0x18(%ebp),%edx
  100f6a:	a1 84 e2 10 00       	mov    0x10e284,%eax
  100f6f:	89 d1                	mov    %edx,%ecx
  100f71:	29 c1                	sub    %eax,%ecx
  100f73:	89 c8                	mov    %ecx,%eax
  100f75:	c1 f8 03             	sar    $0x3,%eax
  100f78:	c1 e0 0c             	shl    $0xc,%eax
  100f7b:	8b 15 7c e2 10 00    	mov    0x10e27c,%edx
  100f81:	c1 e2 0c             	shl    $0xc,%edx
  100f84:	39 d0                	cmp    %edx,%eax
  100f86:	72 24                	jb     100fac <mem_check+0x2d3>
  100f88:	c7 44 24 0c 8c 5d 10 	movl   $0x105d8c,0xc(%esp)
  100f8f:	00 
  100f90:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  100f97:	00 
  100f98:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  100f9f:	00 
  100fa0:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  100fa7:	e8 60 f4 ff ff       	call   10040c <debug_panic>

	// temporarily steal the rest of the free pages
	fl = mem_freelist;
  100fac:	a1 78 e2 10 00       	mov    0x10e278,%eax
  100fb1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	mem_freelist = 0;
  100fb4:	c7 05 78 e2 10 00 00 	movl   $0x0,0x10e278
  100fbb:	00 00 00 

	// should be no free memory
	assert(mem_alloc() == 0);
  100fbe:	e8 a0 fc ff ff       	call   100c63 <mem_alloc>
  100fc3:	85 c0                	test   %eax,%eax
  100fc5:	74 24                	je     100feb <mem_check+0x312>
  100fc7:	c7 44 24 0c b2 5d 10 	movl   $0x105db2,0xc(%esp)
  100fce:	00 
  100fcf:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  100fd6:	00 
  100fd7:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  100fde:	00 
  100fdf:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  100fe6:	e8 21 f4 ff ff       	call   10040c <debug_panic>

        // free and re-allocate?
        mem_free(pp0);
  100feb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100fee:	89 04 24             	mov    %eax,(%esp)
  100ff1:	e8 9a fc ff ff       	call   100c90 <mem_free>
        mem_free(pp1);
  100ff6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100ff9:	89 04 24             	mov    %eax,(%esp)
  100ffc:	e8 8f fc ff ff       	call   100c90 <mem_free>
        mem_free(pp2);
  101001:	8b 45 e8             	mov    -0x18(%ebp),%eax
  101004:	89 04 24             	mov    %eax,(%esp)
  101007:	e8 84 fc ff ff       	call   100c90 <mem_free>
	pp0 = pp1 = pp2 = 0;
  10100c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  101013:	8b 45 e8             	mov    -0x18(%ebp),%eax
  101016:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  101019:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10101c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	pp0 = mem_alloc(); assert(pp0 != 0);
  10101f:	e8 3f fc ff ff       	call   100c63 <mem_alloc>
  101024:	89 45 e0             	mov    %eax,-0x20(%ebp)
  101027:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10102b:	75 24                	jne    101051 <mem_check+0x378>
  10102d:	c7 44 24 0c eb 5c 10 	movl   $0x105ceb,0xc(%esp)
  101034:	00 
  101035:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  10103c:	00 
  10103d:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
  101044:	00 
  101045:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  10104c:	e8 bb f3 ff ff       	call   10040c <debug_panic>
	pp1 = mem_alloc(); assert(pp1 != 0);
  101051:	e8 0d fc ff ff       	call   100c63 <mem_alloc>
  101056:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  101059:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10105d:	75 24                	jne    101083 <mem_check+0x3aa>
  10105f:	c7 44 24 0c f4 5c 10 	movl   $0x105cf4,0xc(%esp)
  101066:	00 
  101067:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  10106e:	00 
  10106f:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
  101076:	00 
  101077:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  10107e:	e8 89 f3 ff ff       	call   10040c <debug_panic>
	pp2 = mem_alloc(); assert(pp2 != 0);
  101083:	e8 db fb ff ff       	call   100c63 <mem_alloc>
  101088:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10108b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10108f:	75 24                	jne    1010b5 <mem_check+0x3dc>
  101091:	c7 44 24 0c fd 5c 10 	movl   $0x105cfd,0xc(%esp)
  101098:	00 
  101099:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  1010a0:	00 
  1010a1:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  1010a8:	00 
  1010a9:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  1010b0:	e8 57 f3 ff ff       	call   10040c <debug_panic>
	assert(pp0);
  1010b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1010b9:	75 24                	jne    1010df <mem_check+0x406>
  1010bb:	c7 44 24 0c 06 5d 10 	movl   $0x105d06,0xc(%esp)
  1010c2:	00 
  1010c3:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  1010ca:	00 
  1010cb:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  1010d2:	00 
  1010d3:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  1010da:	e8 2d f3 ff ff       	call   10040c <debug_panic>
	assert(pp1 && pp1 != pp0);
  1010df:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1010e3:	74 08                	je     1010ed <mem_check+0x414>
  1010e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1010e8:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  1010eb:	75 24                	jne    101111 <mem_check+0x438>
  1010ed:	c7 44 24 0c 0a 5d 10 	movl   $0x105d0a,0xc(%esp)
  1010f4:	00 
  1010f5:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  1010fc:	00 
  1010fd:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
  101104:	00 
  101105:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  10110c:	e8 fb f2 ff ff       	call   10040c <debug_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
  101111:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  101115:	74 10                	je     101127 <mem_check+0x44e>
  101117:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10111a:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  10111d:	74 08                	je     101127 <mem_check+0x44e>
  10111f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  101122:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  101125:	75 24                	jne    10114b <mem_check+0x472>
  101127:	c7 44 24 0c 1c 5d 10 	movl   $0x105d1c,0xc(%esp)
  10112e:	00 
  10112f:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  101136:	00 
  101137:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  10113e:	00 
  10113f:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  101146:	e8 c1 f2 ff ff       	call   10040c <debug_panic>
	assert(mem_alloc() == 0);
  10114b:	e8 13 fb ff ff       	call   100c63 <mem_alloc>
  101150:	85 c0                	test   %eax,%eax
  101152:	74 24                	je     101178 <mem_check+0x49f>
  101154:	c7 44 24 0c b2 5d 10 	movl   $0x105db2,0xc(%esp)
  10115b:	00 
  10115c:	c7 44 24 08 6a 5b 10 	movl   $0x105b6a,0x8(%esp)
  101163:	00 
  101164:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
  10116b:	00 
  10116c:	c7 04 24 ac 5b 10 00 	movl   $0x105bac,(%esp)
  101173:	e8 94 f2 ff ff       	call   10040c <debug_panic>

	// give free list back
	mem_freelist = fl;
  101178:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10117b:	a3 78 e2 10 00       	mov    %eax,0x10e278

	// free the pages we took
	mem_free(pp0);
  101180:	8b 45 e0             	mov    -0x20(%ebp),%eax
  101183:	89 04 24             	mov    %eax,(%esp)
  101186:	e8 05 fb ff ff       	call   100c90 <mem_free>
	mem_free(pp1);
  10118b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10118e:	89 04 24             	mov    %eax,(%esp)
  101191:	e8 fa fa ff ff       	call   100c90 <mem_free>
	mem_free(pp2);
  101196:	8b 45 e8             	mov    -0x18(%ebp),%eax
  101199:	89 04 24             	mov    %eax,(%esp)
  10119c:	e8 ef fa ff ff       	call   100c90 <mem_free>

	cprintf("mem_check() succeeded!\n");
  1011a1:	c7 04 24 c3 5d 10 00 	movl   $0x105dc3,(%esp)
  1011a8:	e8 98 40 00 00       	call   105245 <cprintf>
}
  1011ad:	c9                   	leave  
  1011ae:	c3                   	ret    
  1011af:	90                   	nop

001011b0 <xchg>:
}

// Atomically set *addr to newval and return the old value of *addr.
static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
  1011b0:	55                   	push   %ebp
  1011b1:	89 e5                	mov    %esp,%ebp
  1011b3:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
  1011b6:	8b 55 08             	mov    0x8(%ebp),%edx
  1011b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1011bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  1011bf:	f0 87 02             	lock xchg %eax,(%edx)
  1011c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	       "+m" (*addr), "=a" (result) :
	       "1" (newval) :
	       "cc");
	return result;
  1011c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1011c8:	c9                   	leave  
  1011c9:	c3                   	ret    

001011ca <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  1011ca:	55                   	push   %ebp
  1011cb:	89 e5                	mov    %esp,%ebp
  1011cd:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  1011d0:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  1011d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  1011d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1011d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1011dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1011e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  1011e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1011e7:	8b 80 b8 00 00 00    	mov    0xb8(%eax),%eax
  1011ed:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  1011f2:	74 24                	je     101218 <cpu_cur+0x4e>
  1011f4:	c7 44 24 0c db 5d 10 	movl   $0x105ddb,0xc(%esp)
  1011fb:	00 
  1011fc:	c7 44 24 08 f1 5d 10 	movl   $0x105df1,0x8(%esp)
  101203:	00 
  101204:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  10120b:	00 
  10120c:	c7 04 24 06 5e 10 00 	movl   $0x105e06,(%esp)
  101213:	e8 f4 f1 ff ff       	call   10040c <debug_panic>
	return c;
  101218:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  10121b:	c9                   	leave  
  10121c:	c3                   	ret    

0010121d <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  10121d:	55                   	push   %ebp
  10121e:	89 e5                	mov    %esp,%ebp
  101220:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  101223:	e8 a2 ff ff ff       	call   1011ca <cpu_cur>
  101228:	3d 00 70 10 00       	cmp    $0x107000,%eax
  10122d:	0f 94 c0             	sete   %al
  101230:	0f b6 c0             	movzbl %al,%eax
}
  101233:	c9                   	leave  
  101234:	c3                   	ret    

00101235 <cpu_init>:
	magic: CPU_MAGIC
};


void cpu_init()
{
  101235:	55                   	push   %ebp
  101236:	89 e5                	mov    %esp,%ebp
  101238:	53                   	push   %ebx
  101239:	83 ec 24             	sub    $0x24,%esp
	cpu *c = cpu_cur();
  10123c:	e8 89 ff ff ff       	call   1011ca <cpu_cur>
  101241:	89 45 f0             	mov    %eax,-0x10(%ebp)

	// Load the GDT
	struct pseudodesc gdt_pd = {
		sizeof(c->gdt) - 1, (uint32_t) c->gdt };
  101244:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101247:	66 c7 45 ea 37 00    	movw   $0x37,-0x16(%ebp)
  10124d:	89 45 ec             	mov    %eax,-0x14(%ebp)
	asm volatile("lgdt %0" : : "m" (gdt_pd));
  101250:	0f 01 55 ea          	lgdtl  -0x16(%ebp)

	// Reload all segment registers.
	asm volatile("movw %%ax,%%gs" :: "a" (CPU_GDT_UDATA|3));
  101254:	b8 23 00 00 00       	mov    $0x23,%eax
  101259:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (CPU_GDT_UDATA|3));
  10125b:	b8 23 00 00 00       	mov    $0x23,%eax
  101260:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (CPU_GDT_KDATA));
  101262:	b8 10 00 00 00       	mov    $0x10,%eax
  101267:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (CPU_GDT_KDATA));
  101269:	b8 10 00 00 00       	mov    $0x10,%eax
  10126e:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (CPU_GDT_KDATA));
  101270:	b8 10 00 00 00       	mov    $0x10,%eax
  101275:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (CPU_GDT_KCODE));
  101277:	ea 7e 12 10 00 08 00 	ljmp   $0x8,$0x10127e
	// reload CS

	c->gdt[CPU_GDT_TSS >> 3] = SEGDESC16(0, STS_T32A, 
  10127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101281:	83 c0 38             	add    $0x38,%eax
  101284:	89 c3                	mov    %eax,%ebx
  101286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101289:	83 c0 38             	add    $0x38,%eax
  10128c:	c1 e8 10             	shr    $0x10,%eax
  10128f:	89 c1                	mov    %eax,%ecx
  101291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101294:	83 c0 38             	add    $0x38,%eax
  101297:	c1 e8 18             	shr    $0x18,%eax
  10129a:	89 c2                	mov    %eax,%edx
  10129c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10129f:	66 c7 40 30 67 00    	movw   $0x67,0x30(%eax)
  1012a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1012a8:	66 89 58 32          	mov    %bx,0x32(%eax)
  1012ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1012af:	88 48 34             	mov    %cl,0x34(%eax)
  1012b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1012b5:	0f b6 48 35          	movzbl 0x35(%eax),%ecx
  1012b9:	83 e1 f0             	and    $0xfffffff0,%ecx
  1012bc:	83 c9 09             	or     $0x9,%ecx
  1012bf:	88 48 35             	mov    %cl,0x35(%eax)
  1012c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1012c5:	0f b6 48 35          	movzbl 0x35(%eax),%ecx
  1012c9:	83 e1 ef             	and    $0xffffffef,%ecx
  1012cc:	88 48 35             	mov    %cl,0x35(%eax)
  1012cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1012d2:	0f b6 48 35          	movzbl 0x35(%eax),%ecx
  1012d6:	83 e1 9f             	and    $0xffffff9f,%ecx
  1012d9:	88 48 35             	mov    %cl,0x35(%eax)
  1012dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1012df:	0f b6 48 35          	movzbl 0x35(%eax),%ecx
  1012e3:	83 c9 80             	or     $0xffffff80,%ecx
  1012e6:	88 48 35             	mov    %cl,0x35(%eax)
  1012e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1012ec:	0f b6 48 36          	movzbl 0x36(%eax),%ecx
  1012f0:	83 e1 f0             	and    $0xfffffff0,%ecx
  1012f3:	88 48 36             	mov    %cl,0x36(%eax)
  1012f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1012f9:	0f b6 48 36          	movzbl 0x36(%eax),%ecx
  1012fd:	83 e1 ef             	and    $0xffffffef,%ecx
  101300:	88 48 36             	mov    %cl,0x36(%eax)
  101303:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101306:	0f b6 48 36          	movzbl 0x36(%eax),%ecx
  10130a:	83 e1 df             	and    $0xffffffdf,%ecx
  10130d:	88 48 36             	mov    %cl,0x36(%eax)
  101310:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101313:	0f b6 48 36          	movzbl 0x36(%eax),%ecx
  101317:	83 c9 40             	or     $0x40,%ecx
  10131a:	88 48 36             	mov    %cl,0x36(%eax)
  10131d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101320:	0f b6 48 36          	movzbl 0x36(%eax),%ecx
  101324:	83 e1 7f             	and    $0x7f,%ecx
  101327:	88 48 36             	mov    %cl,0x36(%eax)
  10132a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10132d:	88 50 37             	mov    %dl,0x37(%eax)
			(uintptr_t)(&(c->tss)), sizeof(taskstate)-1, 0);
	c->tss.ts_esp0 = (uintptr_t)(c->kstackhi);
  101330:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101333:	05 00 10 00 00       	add    $0x1000,%eax
  101338:	89 c2                	mov    %eax,%edx
  10133a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10133d:	89 50 3c             	mov    %edx,0x3c(%eax)
	c->tss.ts_ss0 = CPU_GDT_KDATA;
  101340:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101343:	66 c7 40 40 10 00    	movw   $0x10,0x40(%eax)
  101349:	66 c7 45 f6 30 00    	movw   $0x30,-0xa(%ebp)
}

static gcc_inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
  10134f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101353:	0f 00 d8             	ltr    %ax
	ltr(CPU_GDT_TSS);

	// We don't need an LDT.
	asm volatile("lldt %%ax" :: "a" (0));
  101356:	b8 00 00 00 00       	mov    $0x0,%eax
  10135b:	0f 00 d0             	lldt   %ax
	cprintf("cpu_init complete\n");
  10135e:	c7 04 24 13 5e 10 00 	movl   $0x105e13,(%esp)
  101365:	e8 db 3e 00 00       	call   105245 <cprintf>
}
  10136a:	83 c4 24             	add    $0x24,%esp
  10136d:	5b                   	pop    %ebx
  10136e:	5d                   	pop    %ebp
  10136f:	c3                   	ret    

00101370 <cpu_alloc>:

// Allocate an additional cpu struct representing a non-bootstrap processor.
cpu *
cpu_alloc(void)
{
  101370:	55                   	push   %ebp
  101371:	89 e5                	mov    %esp,%ebp
  101373:	83 ec 28             	sub    $0x28,%esp
	// Pointer to the cpu.next pointer of the last CPU on the list,
	// for chaining on new CPUs in cpu_alloc().  Note: static.
	static cpu **cpu_tail = &cpu_boot.next;

	pageinfo *pi = mem_alloc();
  101376:	e8 e8 f8 ff ff       	call   100c63 <mem_alloc>
  10137b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	assert(pi != 0);	// shouldn't be out of memory just yet!
  10137e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  101382:	75 24                	jne    1013a8 <cpu_alloc+0x38>
  101384:	c7 44 24 0c 26 5e 10 	movl   $0x105e26,0xc(%esp)
  10138b:	00 
  10138c:	c7 44 24 08 f1 5d 10 	movl   $0x105df1,0x8(%esp)
  101393:	00 
  101394:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  10139b:	00 
  10139c:	c7 04 24 2e 5e 10 00 	movl   $0x105e2e,(%esp)
  1013a3:	e8 64 f0 ff ff       	call   10040c <debug_panic>

	cpu *c = (cpu*) mem_pi2ptr(pi);
  1013a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1013ab:	a1 84 e2 10 00       	mov    0x10e284,%eax
  1013b0:	89 d1                	mov    %edx,%ecx
  1013b2:	29 c1                	sub    %eax,%ecx
  1013b4:	89 c8                	mov    %ecx,%eax
  1013b6:	c1 f8 03             	sar    $0x3,%eax
  1013b9:	c1 e0 0c             	shl    $0xc,%eax
  1013bc:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Clear the whole page for good measure: cpu struct and kernel stack
	memset(c, 0, PAGESIZE);
  1013bf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1013c6:	00 
  1013c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1013ce:	00 
  1013cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1013d2:	89 04 24             	mov    %eax,(%esp)
  1013d5:	e8 52 40 00 00       	call   10542c <memset>
	// when it starts up and calls cpu_init().

	// Initialize the new cpu's GDT by copying from the cpu_boot.
	// The TSS descriptor will be filled in later by cpu_init().
	assert(sizeof(c->gdt) == sizeof(segdesc) * CPU_GDT_NDESC);
	memmove(c->gdt, cpu_boot.gdt, sizeof(c->gdt));
  1013da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1013dd:	c7 44 24 08 38 00 00 	movl   $0x38,0x8(%esp)
  1013e4:	00 
  1013e5:	c7 44 24 04 00 70 10 	movl   $0x107000,0x4(%esp)
  1013ec:	00 
  1013ed:	89 04 24             	mov    %eax,(%esp)
  1013f0:	e8 ab 40 00 00       	call   1054a0 <memmove>

	// Magic verification tag for stack overflow/cpu corruption checking
	c->magic = CPU_MAGIC;
  1013f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1013f8:	c7 80 b8 00 00 00 32 	movl   $0x98765432,0xb8(%eax)
  1013ff:	54 76 98 

	// Chain the new CPU onto the tail of the list.
	*cpu_tail = c;
  101402:	a1 00 80 10 00       	mov    0x108000,%eax
  101407:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10140a:	89 10                	mov    %edx,(%eax)
	cpu_tail = &c->next;
  10140c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10140f:	05 a8 00 00 00       	add    $0xa8,%eax
  101414:	a3 00 80 10 00       	mov    %eax,0x108000

	return c;
  101419:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10141c:	c9                   	leave  
  10141d:	c3                   	ret    

0010141e <cpu_bootothers>:

void
cpu_bootothers(void)
{
  10141e:	55                   	push   %ebp
  10141f:	89 e5                	mov    %esp,%ebp
  101421:	83 ec 28             	sub    $0x28,%esp
	extern uint8_t _binary_obj_boot_bootother_start[],
			_binary_obj_boot_bootother_size[];

	if (!cpu_onboot()) {
  101424:	e8 f4 fd ff ff       	call   10121d <cpu_onboot>
  101429:	85 c0                	test   %eax,%eax
  10142b:	75 1f                	jne    10144c <cpu_bootothers+0x2e>
		// Just inform the boot cpu we've booted.
		xchg(&cpu_cur()->booted, 1);
  10142d:	e8 98 fd ff ff       	call   1011ca <cpu_cur>
  101432:	05 b0 00 00 00       	add    $0xb0,%eax
  101437:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10143e:	00 
  10143f:	89 04 24             	mov    %eax,(%esp)
  101442:	e8 69 fd ff ff       	call   1011b0 <xchg>
		return;
  101447:	e9 91 00 00 00       	jmp    1014dd <cpu_bootothers+0xbf>
	}

	// Write bootstrap code to unused memory at 0x1000.
	uint8_t *code = (uint8_t*)0x1000;
  10144c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
	memmove(code, _binary_obj_boot_bootother_start,
  101453:	b8 6a 00 00 00       	mov    $0x6a,%eax
  101458:	89 44 24 08          	mov    %eax,0x8(%esp)
  10145c:	c7 44 24 04 34 85 10 	movl   $0x108534,0x4(%esp)
  101463:	00 
  101464:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101467:	89 04 24             	mov    %eax,(%esp)
  10146a:	e8 31 40 00 00       	call   1054a0 <memmove>
		(uint32_t)_binary_obj_boot_bootother_size);

	cpu *c;
	for(c = &cpu_boot; c; c = c->next){
  10146f:	c7 45 f4 00 70 10 00 	movl   $0x107000,-0xc(%ebp)
  101476:	eb 5f                	jmp    1014d7 <cpu_bootothers+0xb9>
		if(c == cpu_cur())  // We''ve started already.
  101478:	e8 4d fd ff ff       	call   1011ca <cpu_cur>
  10147d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  101480:	74 48                	je     1014ca <cpu_bootothers+0xac>
			continue;

		// Fill in %esp, %eip and start code on cpu.
		*(void**)(code-4) = c->kstackhi;
  101482:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101485:	83 e8 04             	sub    $0x4,%eax
  101488:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10148b:	81 c2 00 10 00 00    	add    $0x1000,%edx
  101491:	89 10                	mov    %edx,(%eax)
		*(void**)(code-8) = init;
  101493:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101496:	83 e8 08             	sub    $0x8,%eax
  101499:	c7 00 93 00 10 00    	movl   $0x100093,(%eax)
		lapic_startcpu(c->id, (uint32_t)code);
  10149f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1014a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1014a5:	0f b6 80 ac 00 00 00 	movzbl 0xac(%eax),%eax
  1014ac:	0f b6 c0             	movzbl %al,%eax
  1014af:	89 54 24 04          	mov    %edx,0x4(%esp)
  1014b3:	89 04 24             	mov    %eax,(%esp)
  1014b6:	e8 81 33 00 00       	call   10483c <lapic_startcpu>

		// Wait for cpu to get through bootstrap.
		while(c->booted == 0)
  1014bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1014be:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  1014c4:	85 c0                	test   %eax,%eax
  1014c6:	74 f3                	je     1014bb <cpu_bootothers+0x9d>
  1014c8:	eb 01                	jmp    1014cb <cpu_bootothers+0xad>
		(uint32_t)_binary_obj_boot_bootother_size);

	cpu *c;
	for(c = &cpu_boot; c; c = c->next){
		if(c == cpu_cur())  // We''ve started already.
			continue;
  1014ca:	90                   	nop
	uint8_t *code = (uint8_t*)0x1000;
	memmove(code, _binary_obj_boot_bootother_start,
		(uint32_t)_binary_obj_boot_bootother_size);

	cpu *c;
	for(c = &cpu_boot; c; c = c->next){
  1014cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1014ce:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  1014d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1014d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1014db:	75 9b                	jne    101478 <cpu_bootothers+0x5a>

		// Wait for cpu to get through bootstrap.
		while(c->booted == 0)
			;
	}
}
  1014dd:	c9                   	leave  
  1014de:	c3                   	ret    
  1014df:	90                   	nop

001014e0 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  1014e0:	55                   	push   %ebp
  1014e1:	89 e5                	mov    %esp,%ebp
  1014e3:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  1014e6:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  1014e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  1014ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1014ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1014f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1014f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  1014fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1014fd:	8b 80 b8 00 00 00    	mov    0xb8(%eax),%eax
  101503:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  101508:	74 24                	je     10152e <cpu_cur+0x4e>
  10150a:	c7 44 24 0c 40 5e 10 	movl   $0x105e40,0xc(%esp)
  101511:	00 
  101512:	c7 44 24 08 56 5e 10 	movl   $0x105e56,0x8(%esp)
  101519:	00 
  10151a:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  101521:	00 
  101522:	c7 04 24 6b 5e 10 00 	movl   $0x105e6b,(%esp)
  101529:	e8 de ee ff ff       	call   10040c <debug_panic>
	return c;
  10152e:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  101531:	c9                   	leave  
  101532:	c3                   	ret    

00101533 <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  101533:	55                   	push   %ebp
  101534:	89 e5                	mov    %esp,%ebp
  101536:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  101539:	e8 a2 ff ff ff       	call   1014e0 <cpu_cur>
  10153e:	3d 00 70 10 00       	cmp    $0x107000,%eax
  101543:	0f 94 c0             	sete   %al
  101546:	0f b6 c0             	movzbl %al,%eax
}
  101549:	c9                   	leave  
  10154a:	c3                   	ret    

0010154b <trap_init_idt>:
};


static void
trap_init_idt(void)
{
  10154b:	55                   	push   %ebp
  10154c:	89 e5                	mov    %esp,%ebp
  10154e:	83 ec 18             	sub    $0x18,%esp
	extern void (*tv49)(void);
	extern void (*tv50)(void);
	extern void (*tv500)(void);
	extern void (*tv501)(void);

	cprintf("initializing idt\n");
  101551:	c7 04 24 78 5e 10 00 	movl   $0x105e78,(%esp)
  101558:	e8 e8 3c 00 00       	call   105245 <cprintf>
	SETGATE(idt[0], 0, CPU_GDT_KCODE, &tv0, 0);
  10155d:	b8 70 26 10 00       	mov    $0x102670,%eax
  101562:	66 a3 c0 97 10 00    	mov    %ax,0x1097c0
  101568:	66 c7 05 c2 97 10 00 	movw   $0x8,0x1097c2
  10156f:	08 00 
  101571:	0f b6 05 c4 97 10 00 	movzbl 0x1097c4,%eax
  101578:	83 e0 e0             	and    $0xffffffe0,%eax
  10157b:	a2 c4 97 10 00       	mov    %al,0x1097c4
  101580:	0f b6 05 c4 97 10 00 	movzbl 0x1097c4,%eax
  101587:	83 e0 1f             	and    $0x1f,%eax
  10158a:	a2 c4 97 10 00       	mov    %al,0x1097c4
  10158f:	0f b6 05 c5 97 10 00 	movzbl 0x1097c5,%eax
  101596:	83 e0 f0             	and    $0xfffffff0,%eax
  101599:	83 c8 0e             	or     $0xe,%eax
  10159c:	a2 c5 97 10 00       	mov    %al,0x1097c5
  1015a1:	0f b6 05 c5 97 10 00 	movzbl 0x1097c5,%eax
  1015a8:	83 e0 ef             	and    $0xffffffef,%eax
  1015ab:	a2 c5 97 10 00       	mov    %al,0x1097c5
  1015b0:	0f b6 05 c5 97 10 00 	movzbl 0x1097c5,%eax
  1015b7:	83 e0 9f             	and    $0xffffff9f,%eax
  1015ba:	a2 c5 97 10 00       	mov    %al,0x1097c5
  1015bf:	0f b6 05 c5 97 10 00 	movzbl 0x1097c5,%eax
  1015c6:	83 c8 80             	or     $0xffffff80,%eax
  1015c9:	a2 c5 97 10 00       	mov    %al,0x1097c5
  1015ce:	b8 70 26 10 00       	mov    $0x102670,%eax
  1015d3:	c1 e8 10             	shr    $0x10,%eax
  1015d6:	66 a3 c6 97 10 00    	mov    %ax,0x1097c6
	SETGATE(idt[2], 0, CPU_GDT_KCODE, &tv2, 0);
  1015dc:	b8 7a 26 10 00       	mov    $0x10267a,%eax
  1015e1:	66 a3 d0 97 10 00    	mov    %ax,0x1097d0
  1015e7:	66 c7 05 d2 97 10 00 	movw   $0x8,0x1097d2
  1015ee:	08 00 
  1015f0:	0f b6 05 d4 97 10 00 	movzbl 0x1097d4,%eax
  1015f7:	83 e0 e0             	and    $0xffffffe0,%eax
  1015fa:	a2 d4 97 10 00       	mov    %al,0x1097d4
  1015ff:	0f b6 05 d4 97 10 00 	movzbl 0x1097d4,%eax
  101606:	83 e0 1f             	and    $0x1f,%eax
  101609:	a2 d4 97 10 00       	mov    %al,0x1097d4
  10160e:	0f b6 05 d5 97 10 00 	movzbl 0x1097d5,%eax
  101615:	83 e0 f0             	and    $0xfffffff0,%eax
  101618:	83 c8 0e             	or     $0xe,%eax
  10161b:	a2 d5 97 10 00       	mov    %al,0x1097d5
  101620:	0f b6 05 d5 97 10 00 	movzbl 0x1097d5,%eax
  101627:	83 e0 ef             	and    $0xffffffef,%eax
  10162a:	a2 d5 97 10 00       	mov    %al,0x1097d5
  10162f:	0f b6 05 d5 97 10 00 	movzbl 0x1097d5,%eax
  101636:	83 e0 9f             	and    $0xffffff9f,%eax
  101639:	a2 d5 97 10 00       	mov    %al,0x1097d5
  10163e:	0f b6 05 d5 97 10 00 	movzbl 0x1097d5,%eax
  101645:	83 c8 80             	or     $0xffffff80,%eax
  101648:	a2 d5 97 10 00       	mov    %al,0x1097d5
  10164d:	b8 7a 26 10 00       	mov    $0x10267a,%eax
  101652:	c1 e8 10             	shr    $0x10,%eax
  101655:	66 a3 d6 97 10 00    	mov    %ax,0x1097d6
	SETGATE(idt[3], 0, CPU_GDT_KCODE, &tv3, 3);
  10165b:	b8 84 26 10 00       	mov    $0x102684,%eax
  101660:	66 a3 d8 97 10 00    	mov    %ax,0x1097d8
  101666:	66 c7 05 da 97 10 00 	movw   $0x8,0x1097da
  10166d:	08 00 
  10166f:	0f b6 05 dc 97 10 00 	movzbl 0x1097dc,%eax
  101676:	83 e0 e0             	and    $0xffffffe0,%eax
  101679:	a2 dc 97 10 00       	mov    %al,0x1097dc
  10167e:	0f b6 05 dc 97 10 00 	movzbl 0x1097dc,%eax
  101685:	83 e0 1f             	and    $0x1f,%eax
  101688:	a2 dc 97 10 00       	mov    %al,0x1097dc
  10168d:	0f b6 05 dd 97 10 00 	movzbl 0x1097dd,%eax
  101694:	83 e0 f0             	and    $0xfffffff0,%eax
  101697:	83 c8 0e             	or     $0xe,%eax
  10169a:	a2 dd 97 10 00       	mov    %al,0x1097dd
  10169f:	0f b6 05 dd 97 10 00 	movzbl 0x1097dd,%eax
  1016a6:	83 e0 ef             	and    $0xffffffef,%eax
  1016a9:	a2 dd 97 10 00       	mov    %al,0x1097dd
  1016ae:	0f b6 05 dd 97 10 00 	movzbl 0x1097dd,%eax
  1016b5:	83 c8 60             	or     $0x60,%eax
  1016b8:	a2 dd 97 10 00       	mov    %al,0x1097dd
  1016bd:	0f b6 05 dd 97 10 00 	movzbl 0x1097dd,%eax
  1016c4:	83 c8 80             	or     $0xffffff80,%eax
  1016c7:	a2 dd 97 10 00       	mov    %al,0x1097dd
  1016cc:	b8 84 26 10 00       	mov    $0x102684,%eax
  1016d1:	c1 e8 10             	shr    $0x10,%eax
  1016d4:	66 a3 de 97 10 00    	mov    %ax,0x1097de
	SETGATE(idt[4], 0, CPU_GDT_KCODE, &tv4, 3);
  1016da:	b8 8e 26 10 00       	mov    $0x10268e,%eax
  1016df:	66 a3 e0 97 10 00    	mov    %ax,0x1097e0
  1016e5:	66 c7 05 e2 97 10 00 	movw   $0x8,0x1097e2
  1016ec:	08 00 
  1016ee:	0f b6 05 e4 97 10 00 	movzbl 0x1097e4,%eax
  1016f5:	83 e0 e0             	and    $0xffffffe0,%eax
  1016f8:	a2 e4 97 10 00       	mov    %al,0x1097e4
  1016fd:	0f b6 05 e4 97 10 00 	movzbl 0x1097e4,%eax
  101704:	83 e0 1f             	and    $0x1f,%eax
  101707:	a2 e4 97 10 00       	mov    %al,0x1097e4
  10170c:	0f b6 05 e5 97 10 00 	movzbl 0x1097e5,%eax
  101713:	83 e0 f0             	and    $0xfffffff0,%eax
  101716:	83 c8 0e             	or     $0xe,%eax
  101719:	a2 e5 97 10 00       	mov    %al,0x1097e5
  10171e:	0f b6 05 e5 97 10 00 	movzbl 0x1097e5,%eax
  101725:	83 e0 ef             	and    $0xffffffef,%eax
  101728:	a2 e5 97 10 00       	mov    %al,0x1097e5
  10172d:	0f b6 05 e5 97 10 00 	movzbl 0x1097e5,%eax
  101734:	83 c8 60             	or     $0x60,%eax
  101737:	a2 e5 97 10 00       	mov    %al,0x1097e5
  10173c:	0f b6 05 e5 97 10 00 	movzbl 0x1097e5,%eax
  101743:	83 c8 80             	or     $0xffffff80,%eax
  101746:	a2 e5 97 10 00       	mov    %al,0x1097e5
  10174b:	b8 8e 26 10 00       	mov    $0x10268e,%eax
  101750:	c1 e8 10             	shr    $0x10,%eax
  101753:	66 a3 e6 97 10 00    	mov    %ax,0x1097e6
	SETGATE(idt[5], 0, CPU_GDT_KCODE, &tv5, 0);
  101759:	b8 98 26 10 00       	mov    $0x102698,%eax
  10175e:	66 a3 e8 97 10 00    	mov    %ax,0x1097e8
  101764:	66 c7 05 ea 97 10 00 	movw   $0x8,0x1097ea
  10176b:	08 00 
  10176d:	0f b6 05 ec 97 10 00 	movzbl 0x1097ec,%eax
  101774:	83 e0 e0             	and    $0xffffffe0,%eax
  101777:	a2 ec 97 10 00       	mov    %al,0x1097ec
  10177c:	0f b6 05 ec 97 10 00 	movzbl 0x1097ec,%eax
  101783:	83 e0 1f             	and    $0x1f,%eax
  101786:	a2 ec 97 10 00       	mov    %al,0x1097ec
  10178b:	0f b6 05 ed 97 10 00 	movzbl 0x1097ed,%eax
  101792:	83 e0 f0             	and    $0xfffffff0,%eax
  101795:	83 c8 0e             	or     $0xe,%eax
  101798:	a2 ed 97 10 00       	mov    %al,0x1097ed
  10179d:	0f b6 05 ed 97 10 00 	movzbl 0x1097ed,%eax
  1017a4:	83 e0 ef             	and    $0xffffffef,%eax
  1017a7:	a2 ed 97 10 00       	mov    %al,0x1097ed
  1017ac:	0f b6 05 ed 97 10 00 	movzbl 0x1097ed,%eax
  1017b3:	83 e0 9f             	and    $0xffffff9f,%eax
  1017b6:	a2 ed 97 10 00       	mov    %al,0x1097ed
  1017bb:	0f b6 05 ed 97 10 00 	movzbl 0x1097ed,%eax
  1017c2:	83 c8 80             	or     $0xffffff80,%eax
  1017c5:	a2 ed 97 10 00       	mov    %al,0x1097ed
  1017ca:	b8 98 26 10 00       	mov    $0x102698,%eax
  1017cf:	c1 e8 10             	shr    $0x10,%eax
  1017d2:	66 a3 ee 97 10 00    	mov    %ax,0x1097ee
	SETGATE(idt[6], 0, CPU_GDT_KCODE, &tv6, 0);
  1017d8:	b8 a2 26 10 00       	mov    $0x1026a2,%eax
  1017dd:	66 a3 f0 97 10 00    	mov    %ax,0x1097f0
  1017e3:	66 c7 05 f2 97 10 00 	movw   $0x8,0x1097f2
  1017ea:	08 00 
  1017ec:	0f b6 05 f4 97 10 00 	movzbl 0x1097f4,%eax
  1017f3:	83 e0 e0             	and    $0xffffffe0,%eax
  1017f6:	a2 f4 97 10 00       	mov    %al,0x1097f4
  1017fb:	0f b6 05 f4 97 10 00 	movzbl 0x1097f4,%eax
  101802:	83 e0 1f             	and    $0x1f,%eax
  101805:	a2 f4 97 10 00       	mov    %al,0x1097f4
  10180a:	0f b6 05 f5 97 10 00 	movzbl 0x1097f5,%eax
  101811:	83 e0 f0             	and    $0xfffffff0,%eax
  101814:	83 c8 0e             	or     $0xe,%eax
  101817:	a2 f5 97 10 00       	mov    %al,0x1097f5
  10181c:	0f b6 05 f5 97 10 00 	movzbl 0x1097f5,%eax
  101823:	83 e0 ef             	and    $0xffffffef,%eax
  101826:	a2 f5 97 10 00       	mov    %al,0x1097f5
  10182b:	0f b6 05 f5 97 10 00 	movzbl 0x1097f5,%eax
  101832:	83 e0 9f             	and    $0xffffff9f,%eax
  101835:	a2 f5 97 10 00       	mov    %al,0x1097f5
  10183a:	0f b6 05 f5 97 10 00 	movzbl 0x1097f5,%eax
  101841:	83 c8 80             	or     $0xffffff80,%eax
  101844:	a2 f5 97 10 00       	mov    %al,0x1097f5
  101849:	b8 a2 26 10 00       	mov    $0x1026a2,%eax
  10184e:	c1 e8 10             	shr    $0x10,%eax
  101851:	66 a3 f6 97 10 00    	mov    %ax,0x1097f6
	SETGATE(idt[7], 0, CPU_GDT_KCODE, &tv7, 0);
  101857:	b8 ac 26 10 00       	mov    $0x1026ac,%eax
  10185c:	66 a3 f8 97 10 00    	mov    %ax,0x1097f8
  101862:	66 c7 05 fa 97 10 00 	movw   $0x8,0x1097fa
  101869:	08 00 
  10186b:	0f b6 05 fc 97 10 00 	movzbl 0x1097fc,%eax
  101872:	83 e0 e0             	and    $0xffffffe0,%eax
  101875:	a2 fc 97 10 00       	mov    %al,0x1097fc
  10187a:	0f b6 05 fc 97 10 00 	movzbl 0x1097fc,%eax
  101881:	83 e0 1f             	and    $0x1f,%eax
  101884:	a2 fc 97 10 00       	mov    %al,0x1097fc
  101889:	0f b6 05 fd 97 10 00 	movzbl 0x1097fd,%eax
  101890:	83 e0 f0             	and    $0xfffffff0,%eax
  101893:	83 c8 0e             	or     $0xe,%eax
  101896:	a2 fd 97 10 00       	mov    %al,0x1097fd
  10189b:	0f b6 05 fd 97 10 00 	movzbl 0x1097fd,%eax
  1018a2:	83 e0 ef             	and    $0xffffffef,%eax
  1018a5:	a2 fd 97 10 00       	mov    %al,0x1097fd
  1018aa:	0f b6 05 fd 97 10 00 	movzbl 0x1097fd,%eax
  1018b1:	83 e0 9f             	and    $0xffffff9f,%eax
  1018b4:	a2 fd 97 10 00       	mov    %al,0x1097fd
  1018b9:	0f b6 05 fd 97 10 00 	movzbl 0x1097fd,%eax
  1018c0:	83 c8 80             	or     $0xffffff80,%eax
  1018c3:	a2 fd 97 10 00       	mov    %al,0x1097fd
  1018c8:	b8 ac 26 10 00       	mov    $0x1026ac,%eax
  1018cd:	c1 e8 10             	shr    $0x10,%eax
  1018d0:	66 a3 fe 97 10 00    	mov    %ax,0x1097fe
	SETGATE(idt[8], 0, CPU_GDT_KCODE, &tv8, 0);
  1018d6:	b8 b6 26 10 00       	mov    $0x1026b6,%eax
  1018db:	66 a3 00 98 10 00    	mov    %ax,0x109800
  1018e1:	66 c7 05 02 98 10 00 	movw   $0x8,0x109802
  1018e8:	08 00 
  1018ea:	0f b6 05 04 98 10 00 	movzbl 0x109804,%eax
  1018f1:	83 e0 e0             	and    $0xffffffe0,%eax
  1018f4:	a2 04 98 10 00       	mov    %al,0x109804
  1018f9:	0f b6 05 04 98 10 00 	movzbl 0x109804,%eax
  101900:	83 e0 1f             	and    $0x1f,%eax
  101903:	a2 04 98 10 00       	mov    %al,0x109804
  101908:	0f b6 05 05 98 10 00 	movzbl 0x109805,%eax
  10190f:	83 e0 f0             	and    $0xfffffff0,%eax
  101912:	83 c8 0e             	or     $0xe,%eax
  101915:	a2 05 98 10 00       	mov    %al,0x109805
  10191a:	0f b6 05 05 98 10 00 	movzbl 0x109805,%eax
  101921:	83 e0 ef             	and    $0xffffffef,%eax
  101924:	a2 05 98 10 00       	mov    %al,0x109805
  101929:	0f b6 05 05 98 10 00 	movzbl 0x109805,%eax
  101930:	83 e0 9f             	and    $0xffffff9f,%eax
  101933:	a2 05 98 10 00       	mov    %al,0x109805
  101938:	0f b6 05 05 98 10 00 	movzbl 0x109805,%eax
  10193f:	83 c8 80             	or     $0xffffff80,%eax
  101942:	a2 05 98 10 00       	mov    %al,0x109805
  101947:	b8 b6 26 10 00       	mov    $0x1026b6,%eax
  10194c:	c1 e8 10             	shr    $0x10,%eax
  10194f:	66 a3 06 98 10 00    	mov    %ax,0x109806
	SETGATE(idt[10], 0, CPU_GDT_KCODE, &tv10, 0);
  101955:	b8 be 26 10 00       	mov    $0x1026be,%eax
  10195a:	66 a3 10 98 10 00    	mov    %ax,0x109810
  101960:	66 c7 05 12 98 10 00 	movw   $0x8,0x109812
  101967:	08 00 
  101969:	0f b6 05 14 98 10 00 	movzbl 0x109814,%eax
  101970:	83 e0 e0             	and    $0xffffffe0,%eax
  101973:	a2 14 98 10 00       	mov    %al,0x109814
  101978:	0f b6 05 14 98 10 00 	movzbl 0x109814,%eax
  10197f:	83 e0 1f             	and    $0x1f,%eax
  101982:	a2 14 98 10 00       	mov    %al,0x109814
  101987:	0f b6 05 15 98 10 00 	movzbl 0x109815,%eax
  10198e:	83 e0 f0             	and    $0xfffffff0,%eax
  101991:	83 c8 0e             	or     $0xe,%eax
  101994:	a2 15 98 10 00       	mov    %al,0x109815
  101999:	0f b6 05 15 98 10 00 	movzbl 0x109815,%eax
  1019a0:	83 e0 ef             	and    $0xffffffef,%eax
  1019a3:	a2 15 98 10 00       	mov    %al,0x109815
  1019a8:	0f b6 05 15 98 10 00 	movzbl 0x109815,%eax
  1019af:	83 e0 9f             	and    $0xffffff9f,%eax
  1019b2:	a2 15 98 10 00       	mov    %al,0x109815
  1019b7:	0f b6 05 15 98 10 00 	movzbl 0x109815,%eax
  1019be:	83 c8 80             	or     $0xffffff80,%eax
  1019c1:	a2 15 98 10 00       	mov    %al,0x109815
  1019c6:	b8 be 26 10 00       	mov    $0x1026be,%eax
  1019cb:	c1 e8 10             	shr    $0x10,%eax
  1019ce:	66 a3 16 98 10 00    	mov    %ax,0x109816
	SETGATE(idt[11], 0, CPU_GDT_KCODE, &tv11, 0);
  1019d4:	b8 c6 26 10 00       	mov    $0x1026c6,%eax
  1019d9:	66 a3 18 98 10 00    	mov    %ax,0x109818
  1019df:	66 c7 05 1a 98 10 00 	movw   $0x8,0x10981a
  1019e6:	08 00 
  1019e8:	0f b6 05 1c 98 10 00 	movzbl 0x10981c,%eax
  1019ef:	83 e0 e0             	and    $0xffffffe0,%eax
  1019f2:	a2 1c 98 10 00       	mov    %al,0x10981c
  1019f7:	0f b6 05 1c 98 10 00 	movzbl 0x10981c,%eax
  1019fe:	83 e0 1f             	and    $0x1f,%eax
  101a01:	a2 1c 98 10 00       	mov    %al,0x10981c
  101a06:	0f b6 05 1d 98 10 00 	movzbl 0x10981d,%eax
  101a0d:	83 e0 f0             	and    $0xfffffff0,%eax
  101a10:	83 c8 0e             	or     $0xe,%eax
  101a13:	a2 1d 98 10 00       	mov    %al,0x10981d
  101a18:	0f b6 05 1d 98 10 00 	movzbl 0x10981d,%eax
  101a1f:	83 e0 ef             	and    $0xffffffef,%eax
  101a22:	a2 1d 98 10 00       	mov    %al,0x10981d
  101a27:	0f b6 05 1d 98 10 00 	movzbl 0x10981d,%eax
  101a2e:	83 e0 9f             	and    $0xffffff9f,%eax
  101a31:	a2 1d 98 10 00       	mov    %al,0x10981d
  101a36:	0f b6 05 1d 98 10 00 	movzbl 0x10981d,%eax
  101a3d:	83 c8 80             	or     $0xffffff80,%eax
  101a40:	a2 1d 98 10 00       	mov    %al,0x10981d
  101a45:	b8 c6 26 10 00       	mov    $0x1026c6,%eax
  101a4a:	c1 e8 10             	shr    $0x10,%eax
  101a4d:	66 a3 1e 98 10 00    	mov    %ax,0x10981e
	SETGATE(idt[12], 0, CPU_GDT_KCODE, &tv12, 0);
  101a53:	b8 ce 26 10 00       	mov    $0x1026ce,%eax
  101a58:	66 a3 20 98 10 00    	mov    %ax,0x109820
  101a5e:	66 c7 05 22 98 10 00 	movw   $0x8,0x109822
  101a65:	08 00 
  101a67:	0f b6 05 24 98 10 00 	movzbl 0x109824,%eax
  101a6e:	83 e0 e0             	and    $0xffffffe0,%eax
  101a71:	a2 24 98 10 00       	mov    %al,0x109824
  101a76:	0f b6 05 24 98 10 00 	movzbl 0x109824,%eax
  101a7d:	83 e0 1f             	and    $0x1f,%eax
  101a80:	a2 24 98 10 00       	mov    %al,0x109824
  101a85:	0f b6 05 25 98 10 00 	movzbl 0x109825,%eax
  101a8c:	83 e0 f0             	and    $0xfffffff0,%eax
  101a8f:	83 c8 0e             	or     $0xe,%eax
  101a92:	a2 25 98 10 00       	mov    %al,0x109825
  101a97:	0f b6 05 25 98 10 00 	movzbl 0x109825,%eax
  101a9e:	83 e0 ef             	and    $0xffffffef,%eax
  101aa1:	a2 25 98 10 00       	mov    %al,0x109825
  101aa6:	0f b6 05 25 98 10 00 	movzbl 0x109825,%eax
  101aad:	83 e0 9f             	and    $0xffffff9f,%eax
  101ab0:	a2 25 98 10 00       	mov    %al,0x109825
  101ab5:	0f b6 05 25 98 10 00 	movzbl 0x109825,%eax
  101abc:	83 c8 80             	or     $0xffffff80,%eax
  101abf:	a2 25 98 10 00       	mov    %al,0x109825
  101ac4:	b8 ce 26 10 00       	mov    $0x1026ce,%eax
  101ac9:	c1 e8 10             	shr    $0x10,%eax
  101acc:	66 a3 26 98 10 00    	mov    %ax,0x109826
	SETGATE(idt[13], 0, CPU_GDT_KCODE, &tv13, 0);
  101ad2:	b8 d6 26 10 00       	mov    $0x1026d6,%eax
  101ad7:	66 a3 28 98 10 00    	mov    %ax,0x109828
  101add:	66 c7 05 2a 98 10 00 	movw   $0x8,0x10982a
  101ae4:	08 00 
  101ae6:	0f b6 05 2c 98 10 00 	movzbl 0x10982c,%eax
  101aed:	83 e0 e0             	and    $0xffffffe0,%eax
  101af0:	a2 2c 98 10 00       	mov    %al,0x10982c
  101af5:	0f b6 05 2c 98 10 00 	movzbl 0x10982c,%eax
  101afc:	83 e0 1f             	and    $0x1f,%eax
  101aff:	a2 2c 98 10 00       	mov    %al,0x10982c
  101b04:	0f b6 05 2d 98 10 00 	movzbl 0x10982d,%eax
  101b0b:	83 e0 f0             	and    $0xfffffff0,%eax
  101b0e:	83 c8 0e             	or     $0xe,%eax
  101b11:	a2 2d 98 10 00       	mov    %al,0x10982d
  101b16:	0f b6 05 2d 98 10 00 	movzbl 0x10982d,%eax
  101b1d:	83 e0 ef             	and    $0xffffffef,%eax
  101b20:	a2 2d 98 10 00       	mov    %al,0x10982d
  101b25:	0f b6 05 2d 98 10 00 	movzbl 0x10982d,%eax
  101b2c:	83 e0 9f             	and    $0xffffff9f,%eax
  101b2f:	a2 2d 98 10 00       	mov    %al,0x10982d
  101b34:	0f b6 05 2d 98 10 00 	movzbl 0x10982d,%eax
  101b3b:	83 c8 80             	or     $0xffffff80,%eax
  101b3e:	a2 2d 98 10 00       	mov    %al,0x10982d
  101b43:	b8 d6 26 10 00       	mov    $0x1026d6,%eax
  101b48:	c1 e8 10             	shr    $0x10,%eax
  101b4b:	66 a3 2e 98 10 00    	mov    %ax,0x10982e
	SETGATE(idt[14], 0, CPU_GDT_KCODE, &tv14, 0);
  101b51:	b8 de 26 10 00       	mov    $0x1026de,%eax
  101b56:	66 a3 30 98 10 00    	mov    %ax,0x109830
  101b5c:	66 c7 05 32 98 10 00 	movw   $0x8,0x109832
  101b63:	08 00 
  101b65:	0f b6 05 34 98 10 00 	movzbl 0x109834,%eax
  101b6c:	83 e0 e0             	and    $0xffffffe0,%eax
  101b6f:	a2 34 98 10 00       	mov    %al,0x109834
  101b74:	0f b6 05 34 98 10 00 	movzbl 0x109834,%eax
  101b7b:	83 e0 1f             	and    $0x1f,%eax
  101b7e:	a2 34 98 10 00       	mov    %al,0x109834
  101b83:	0f b6 05 35 98 10 00 	movzbl 0x109835,%eax
  101b8a:	83 e0 f0             	and    $0xfffffff0,%eax
  101b8d:	83 c8 0e             	or     $0xe,%eax
  101b90:	a2 35 98 10 00       	mov    %al,0x109835
  101b95:	0f b6 05 35 98 10 00 	movzbl 0x109835,%eax
  101b9c:	83 e0 ef             	and    $0xffffffef,%eax
  101b9f:	a2 35 98 10 00       	mov    %al,0x109835
  101ba4:	0f b6 05 35 98 10 00 	movzbl 0x109835,%eax
  101bab:	83 e0 9f             	and    $0xffffff9f,%eax
  101bae:	a2 35 98 10 00       	mov    %al,0x109835
  101bb3:	0f b6 05 35 98 10 00 	movzbl 0x109835,%eax
  101bba:	83 c8 80             	or     $0xffffff80,%eax
  101bbd:	a2 35 98 10 00       	mov    %al,0x109835
  101bc2:	b8 de 26 10 00       	mov    $0x1026de,%eax
  101bc7:	c1 e8 10             	shr    $0x10,%eax
  101bca:	66 a3 36 98 10 00    	mov    %ax,0x109836
	SETGATE(idt[16], 0, CPU_GDT_KCODE, &tv16, 0);
  101bd0:	b8 e6 26 10 00       	mov    $0x1026e6,%eax
  101bd5:	66 a3 40 98 10 00    	mov    %ax,0x109840
  101bdb:	66 c7 05 42 98 10 00 	movw   $0x8,0x109842
  101be2:	08 00 
  101be4:	0f b6 05 44 98 10 00 	movzbl 0x109844,%eax
  101beb:	83 e0 e0             	and    $0xffffffe0,%eax
  101bee:	a2 44 98 10 00       	mov    %al,0x109844
  101bf3:	0f b6 05 44 98 10 00 	movzbl 0x109844,%eax
  101bfa:	83 e0 1f             	and    $0x1f,%eax
  101bfd:	a2 44 98 10 00       	mov    %al,0x109844
  101c02:	0f b6 05 45 98 10 00 	movzbl 0x109845,%eax
  101c09:	83 e0 f0             	and    $0xfffffff0,%eax
  101c0c:	83 c8 0e             	or     $0xe,%eax
  101c0f:	a2 45 98 10 00       	mov    %al,0x109845
  101c14:	0f b6 05 45 98 10 00 	movzbl 0x109845,%eax
  101c1b:	83 e0 ef             	and    $0xffffffef,%eax
  101c1e:	a2 45 98 10 00       	mov    %al,0x109845
  101c23:	0f b6 05 45 98 10 00 	movzbl 0x109845,%eax
  101c2a:	83 e0 9f             	and    $0xffffff9f,%eax
  101c2d:	a2 45 98 10 00       	mov    %al,0x109845
  101c32:	0f b6 05 45 98 10 00 	movzbl 0x109845,%eax
  101c39:	83 c8 80             	or     $0xffffff80,%eax
  101c3c:	a2 45 98 10 00       	mov    %al,0x109845
  101c41:	b8 e6 26 10 00       	mov    $0x1026e6,%eax
  101c46:	c1 e8 10             	shr    $0x10,%eax
  101c49:	66 a3 46 98 10 00    	mov    %ax,0x109846
	SETGATE(idt[17], 0, CPU_GDT_KCODE, &tv17, 0);
  101c4f:	b8 f0 26 10 00       	mov    $0x1026f0,%eax
  101c54:	66 a3 48 98 10 00    	mov    %ax,0x109848
  101c5a:	66 c7 05 4a 98 10 00 	movw   $0x8,0x10984a
  101c61:	08 00 
  101c63:	0f b6 05 4c 98 10 00 	movzbl 0x10984c,%eax
  101c6a:	83 e0 e0             	and    $0xffffffe0,%eax
  101c6d:	a2 4c 98 10 00       	mov    %al,0x10984c
  101c72:	0f b6 05 4c 98 10 00 	movzbl 0x10984c,%eax
  101c79:	83 e0 1f             	and    $0x1f,%eax
  101c7c:	a2 4c 98 10 00       	mov    %al,0x10984c
  101c81:	0f b6 05 4d 98 10 00 	movzbl 0x10984d,%eax
  101c88:	83 e0 f0             	and    $0xfffffff0,%eax
  101c8b:	83 c8 0e             	or     $0xe,%eax
  101c8e:	a2 4d 98 10 00       	mov    %al,0x10984d
  101c93:	0f b6 05 4d 98 10 00 	movzbl 0x10984d,%eax
  101c9a:	83 e0 ef             	and    $0xffffffef,%eax
  101c9d:	a2 4d 98 10 00       	mov    %al,0x10984d
  101ca2:	0f b6 05 4d 98 10 00 	movzbl 0x10984d,%eax
  101ca9:	83 e0 9f             	and    $0xffffff9f,%eax
  101cac:	a2 4d 98 10 00       	mov    %al,0x10984d
  101cb1:	0f b6 05 4d 98 10 00 	movzbl 0x10984d,%eax
  101cb8:	83 c8 80             	or     $0xffffff80,%eax
  101cbb:	a2 4d 98 10 00       	mov    %al,0x10984d
  101cc0:	b8 f0 26 10 00       	mov    $0x1026f0,%eax
  101cc5:	c1 e8 10             	shr    $0x10,%eax
  101cc8:	66 a3 4e 98 10 00    	mov    %ax,0x10984e
	SETGATE(idt[18], 0, CPU_GDT_KCODE, &tv18, 0);
  101cce:	b8 f8 26 10 00       	mov    $0x1026f8,%eax
  101cd3:	66 a3 50 98 10 00    	mov    %ax,0x109850
  101cd9:	66 c7 05 52 98 10 00 	movw   $0x8,0x109852
  101ce0:	08 00 
  101ce2:	0f b6 05 54 98 10 00 	movzbl 0x109854,%eax
  101ce9:	83 e0 e0             	and    $0xffffffe0,%eax
  101cec:	a2 54 98 10 00       	mov    %al,0x109854
  101cf1:	0f b6 05 54 98 10 00 	movzbl 0x109854,%eax
  101cf8:	83 e0 1f             	and    $0x1f,%eax
  101cfb:	a2 54 98 10 00       	mov    %al,0x109854
  101d00:	0f b6 05 55 98 10 00 	movzbl 0x109855,%eax
  101d07:	83 e0 f0             	and    $0xfffffff0,%eax
  101d0a:	83 c8 0e             	or     $0xe,%eax
  101d0d:	a2 55 98 10 00       	mov    %al,0x109855
  101d12:	0f b6 05 55 98 10 00 	movzbl 0x109855,%eax
  101d19:	83 e0 ef             	and    $0xffffffef,%eax
  101d1c:	a2 55 98 10 00       	mov    %al,0x109855
  101d21:	0f b6 05 55 98 10 00 	movzbl 0x109855,%eax
  101d28:	83 e0 9f             	and    $0xffffff9f,%eax
  101d2b:	a2 55 98 10 00       	mov    %al,0x109855
  101d30:	0f b6 05 55 98 10 00 	movzbl 0x109855,%eax
  101d37:	83 c8 80             	or     $0xffffff80,%eax
  101d3a:	a2 55 98 10 00       	mov    %al,0x109855
  101d3f:	b8 f8 26 10 00       	mov    $0x1026f8,%eax
  101d44:	c1 e8 10             	shr    $0x10,%eax
  101d47:	66 a3 56 98 10 00    	mov    %ax,0x109856
	SETGATE(idt[19], 0, CPU_GDT_KCODE, &tv19, 0);
  101d4d:	b8 02 27 10 00       	mov    $0x102702,%eax
  101d52:	66 a3 58 98 10 00    	mov    %ax,0x109858
  101d58:	66 c7 05 5a 98 10 00 	movw   $0x8,0x10985a
  101d5f:	08 00 
  101d61:	0f b6 05 5c 98 10 00 	movzbl 0x10985c,%eax
  101d68:	83 e0 e0             	and    $0xffffffe0,%eax
  101d6b:	a2 5c 98 10 00       	mov    %al,0x10985c
  101d70:	0f b6 05 5c 98 10 00 	movzbl 0x10985c,%eax
  101d77:	83 e0 1f             	and    $0x1f,%eax
  101d7a:	a2 5c 98 10 00       	mov    %al,0x10985c
  101d7f:	0f b6 05 5d 98 10 00 	movzbl 0x10985d,%eax
  101d86:	83 e0 f0             	and    $0xfffffff0,%eax
  101d89:	83 c8 0e             	or     $0xe,%eax
  101d8c:	a2 5d 98 10 00       	mov    %al,0x10985d
  101d91:	0f b6 05 5d 98 10 00 	movzbl 0x10985d,%eax
  101d98:	83 e0 ef             	and    $0xffffffef,%eax
  101d9b:	a2 5d 98 10 00       	mov    %al,0x10985d
  101da0:	0f b6 05 5d 98 10 00 	movzbl 0x10985d,%eax
  101da7:	83 e0 9f             	and    $0xffffff9f,%eax
  101daa:	a2 5d 98 10 00       	mov    %al,0x10985d
  101daf:	0f b6 05 5d 98 10 00 	movzbl 0x10985d,%eax
  101db6:	83 c8 80             	or     $0xffffff80,%eax
  101db9:	a2 5d 98 10 00       	mov    %al,0x10985d
  101dbe:	b8 02 27 10 00       	mov    $0x102702,%eax
  101dc3:	c1 e8 10             	shr    $0x10,%eax
  101dc6:	66 a3 5e 98 10 00    	mov    %ax,0x10985e
	SETGATE(idt[30], 0, CPU_GDT_KCODE, &tv30, 0);
  101dcc:	b8 0c 27 10 00       	mov    $0x10270c,%eax
  101dd1:	66 a3 b0 98 10 00    	mov    %ax,0x1098b0
  101dd7:	66 c7 05 b2 98 10 00 	movw   $0x8,0x1098b2
  101dde:	08 00 
  101de0:	0f b6 05 b4 98 10 00 	movzbl 0x1098b4,%eax
  101de7:	83 e0 e0             	and    $0xffffffe0,%eax
  101dea:	a2 b4 98 10 00       	mov    %al,0x1098b4
  101def:	0f b6 05 b4 98 10 00 	movzbl 0x1098b4,%eax
  101df6:	83 e0 1f             	and    $0x1f,%eax
  101df9:	a2 b4 98 10 00       	mov    %al,0x1098b4
  101dfe:	0f b6 05 b5 98 10 00 	movzbl 0x1098b5,%eax
  101e05:	83 e0 f0             	and    $0xfffffff0,%eax
  101e08:	83 c8 0e             	or     $0xe,%eax
  101e0b:	a2 b5 98 10 00       	mov    %al,0x1098b5
  101e10:	0f b6 05 b5 98 10 00 	movzbl 0x1098b5,%eax
  101e17:	83 e0 ef             	and    $0xffffffef,%eax
  101e1a:	a2 b5 98 10 00       	mov    %al,0x1098b5
  101e1f:	0f b6 05 b5 98 10 00 	movzbl 0x1098b5,%eax
  101e26:	83 e0 9f             	and    $0xffffff9f,%eax
  101e29:	a2 b5 98 10 00       	mov    %al,0x1098b5
  101e2e:	0f b6 05 b5 98 10 00 	movzbl 0x1098b5,%eax
  101e35:	83 c8 80             	or     $0xffffff80,%eax
  101e38:	a2 b5 98 10 00       	mov    %al,0x1098b5
  101e3d:	b8 0c 27 10 00       	mov    $0x10270c,%eax
  101e42:	c1 e8 10             	shr    $0x10,%eax
  101e45:	66 a3 b6 98 10 00    	mov    %ax,0x1098b6
	SETGATE(idt[32], 0, CPU_GDT_KCODE, &tv32, 0);
  101e4b:	b8 16 27 10 00       	mov    $0x102716,%eax
  101e50:	66 a3 c0 98 10 00    	mov    %ax,0x1098c0
  101e56:	66 c7 05 c2 98 10 00 	movw   $0x8,0x1098c2
  101e5d:	08 00 
  101e5f:	0f b6 05 c4 98 10 00 	movzbl 0x1098c4,%eax
  101e66:	83 e0 e0             	and    $0xffffffe0,%eax
  101e69:	a2 c4 98 10 00       	mov    %al,0x1098c4
  101e6e:	0f b6 05 c4 98 10 00 	movzbl 0x1098c4,%eax
  101e75:	83 e0 1f             	and    $0x1f,%eax
  101e78:	a2 c4 98 10 00       	mov    %al,0x1098c4
  101e7d:	0f b6 05 c5 98 10 00 	movzbl 0x1098c5,%eax
  101e84:	83 e0 f0             	and    $0xfffffff0,%eax
  101e87:	83 c8 0e             	or     $0xe,%eax
  101e8a:	a2 c5 98 10 00       	mov    %al,0x1098c5
  101e8f:	0f b6 05 c5 98 10 00 	movzbl 0x1098c5,%eax
  101e96:	83 e0 ef             	and    $0xffffffef,%eax
  101e99:	a2 c5 98 10 00       	mov    %al,0x1098c5
  101e9e:	0f b6 05 c5 98 10 00 	movzbl 0x1098c5,%eax
  101ea5:	83 e0 9f             	and    $0xffffff9f,%eax
  101ea8:	a2 c5 98 10 00       	mov    %al,0x1098c5
  101ead:	0f b6 05 c5 98 10 00 	movzbl 0x1098c5,%eax
  101eb4:	83 c8 80             	or     $0xffffff80,%eax
  101eb7:	a2 c5 98 10 00       	mov    %al,0x1098c5
  101ebc:	b8 16 27 10 00       	mov    $0x102716,%eax
  101ec1:	c1 e8 10             	shr    $0x10,%eax
  101ec4:	66 a3 c6 98 10 00    	mov    %ax,0x1098c6
	SETGATE(idt[48], 0, CPU_GDT_KCODE, &tv48, 3);
  101eca:	b8 20 27 10 00       	mov    $0x102720,%eax
  101ecf:	66 a3 40 99 10 00    	mov    %ax,0x109940
  101ed5:	66 c7 05 42 99 10 00 	movw   $0x8,0x109942
  101edc:	08 00 
  101ede:	0f b6 05 44 99 10 00 	movzbl 0x109944,%eax
  101ee5:	83 e0 e0             	and    $0xffffffe0,%eax
  101ee8:	a2 44 99 10 00       	mov    %al,0x109944
  101eed:	0f b6 05 44 99 10 00 	movzbl 0x109944,%eax
  101ef4:	83 e0 1f             	and    $0x1f,%eax
  101ef7:	a2 44 99 10 00       	mov    %al,0x109944
  101efc:	0f b6 05 45 99 10 00 	movzbl 0x109945,%eax
  101f03:	83 e0 f0             	and    $0xfffffff0,%eax
  101f06:	83 c8 0e             	or     $0xe,%eax
  101f09:	a2 45 99 10 00       	mov    %al,0x109945
  101f0e:	0f b6 05 45 99 10 00 	movzbl 0x109945,%eax
  101f15:	83 e0 ef             	and    $0xffffffef,%eax
  101f18:	a2 45 99 10 00       	mov    %al,0x109945
  101f1d:	0f b6 05 45 99 10 00 	movzbl 0x109945,%eax
  101f24:	83 c8 60             	or     $0x60,%eax
  101f27:	a2 45 99 10 00       	mov    %al,0x109945
  101f2c:	0f b6 05 45 99 10 00 	movzbl 0x109945,%eax
  101f33:	83 c8 80             	or     $0xffffff80,%eax
  101f36:	a2 45 99 10 00       	mov    %al,0x109945
  101f3b:	b8 20 27 10 00       	mov    $0x102720,%eax
  101f40:	c1 e8 10             	shr    $0x10,%eax
  101f43:	66 a3 46 99 10 00    	mov    %ax,0x109946
	SETGATE(idt[49], 0, CPU_GDT_KCODE, &tv49, 0);
  101f49:	b8 2a 27 10 00       	mov    $0x10272a,%eax
  101f4e:	66 a3 48 99 10 00    	mov    %ax,0x109948
  101f54:	66 c7 05 4a 99 10 00 	movw   $0x8,0x10994a
  101f5b:	08 00 
  101f5d:	0f b6 05 4c 99 10 00 	movzbl 0x10994c,%eax
  101f64:	83 e0 e0             	and    $0xffffffe0,%eax
  101f67:	a2 4c 99 10 00       	mov    %al,0x10994c
  101f6c:	0f b6 05 4c 99 10 00 	movzbl 0x10994c,%eax
  101f73:	83 e0 1f             	and    $0x1f,%eax
  101f76:	a2 4c 99 10 00       	mov    %al,0x10994c
  101f7b:	0f b6 05 4d 99 10 00 	movzbl 0x10994d,%eax
  101f82:	83 e0 f0             	and    $0xfffffff0,%eax
  101f85:	83 c8 0e             	or     $0xe,%eax
  101f88:	a2 4d 99 10 00       	mov    %al,0x10994d
  101f8d:	0f b6 05 4d 99 10 00 	movzbl 0x10994d,%eax
  101f94:	83 e0 ef             	and    $0xffffffef,%eax
  101f97:	a2 4d 99 10 00       	mov    %al,0x10994d
  101f9c:	0f b6 05 4d 99 10 00 	movzbl 0x10994d,%eax
  101fa3:	83 e0 9f             	and    $0xffffff9f,%eax
  101fa6:	a2 4d 99 10 00       	mov    %al,0x10994d
  101fab:	0f b6 05 4d 99 10 00 	movzbl 0x10994d,%eax
  101fb2:	83 c8 80             	or     $0xffffff80,%eax
  101fb5:	a2 4d 99 10 00       	mov    %al,0x10994d
  101fba:	b8 2a 27 10 00       	mov    $0x10272a,%eax
  101fbf:	c1 e8 10             	shr    $0x10,%eax
  101fc2:	66 a3 4e 99 10 00    	mov    %ax,0x10994e
	SETGATE(idt[50], 0, CPU_GDT_KCODE, &tv50, 0);
  101fc8:	b8 34 27 10 00       	mov    $0x102734,%eax
  101fcd:	66 a3 50 99 10 00    	mov    %ax,0x109950
  101fd3:	66 c7 05 52 99 10 00 	movw   $0x8,0x109952
  101fda:	08 00 
  101fdc:	0f b6 05 54 99 10 00 	movzbl 0x109954,%eax
  101fe3:	83 e0 e0             	and    $0xffffffe0,%eax
  101fe6:	a2 54 99 10 00       	mov    %al,0x109954
  101feb:	0f b6 05 54 99 10 00 	movzbl 0x109954,%eax
  101ff2:	83 e0 1f             	and    $0x1f,%eax
  101ff5:	a2 54 99 10 00       	mov    %al,0x109954
  101ffa:	0f b6 05 55 99 10 00 	movzbl 0x109955,%eax
  102001:	83 e0 f0             	and    $0xfffffff0,%eax
  102004:	83 c8 0e             	or     $0xe,%eax
  102007:	a2 55 99 10 00       	mov    %al,0x109955
  10200c:	0f b6 05 55 99 10 00 	movzbl 0x109955,%eax
  102013:	83 e0 ef             	and    $0xffffffef,%eax
  102016:	a2 55 99 10 00       	mov    %al,0x109955
  10201b:	0f b6 05 55 99 10 00 	movzbl 0x109955,%eax
  102022:	83 e0 9f             	and    $0xffffff9f,%eax
  102025:	a2 55 99 10 00       	mov    %al,0x109955
  10202a:	0f b6 05 55 99 10 00 	movzbl 0x109955,%eax
  102031:	83 c8 80             	or     $0xffffff80,%eax
  102034:	a2 55 99 10 00       	mov    %al,0x109955
  102039:	b8 34 27 10 00       	mov    $0x102734,%eax
  10203e:	c1 e8 10             	shr    $0x10,%eax
  102041:	66 a3 56 99 10 00    	mov    %ax,0x109956
}
  102047:	c9                   	leave  
  102048:	c3                   	ret    

00102049 <trap_init>:

void
trap_init(void)
{
  102049:	55                   	push   %ebp
  10204a:	89 e5                	mov    %esp,%ebp
  10204c:	83 ec 08             	sub    $0x8,%esp
	// The first time we get called on the bootstrap processor,
	// initialize the IDT.  Other CPUs will share the same IDT.
	if (cpu_onboot())
  10204f:	e8 df f4 ff ff       	call   101533 <cpu_onboot>
  102054:	85 c0                	test   %eax,%eax
  102056:	74 05                	je     10205d <trap_init+0x14>
		trap_init_idt();
  102058:	e8 ee f4 ff ff       	call   10154b <trap_init_idt>

	// Load the IDT into this processor's IDT register.
	asm volatile("lidt %0" : : "m" (idt_pd));
  10205d:	0f 01 1d 04 80 10 00 	lidtl  0x108004

	// Check for the correct IDT and trap handler operation.
	if (cpu_onboot())
  102064:	e8 ca f4 ff ff       	call   101533 <cpu_onboot>
  102069:	85 c0                	test   %eax,%eax
  10206b:	74 05                	je     102072 <trap_init+0x29>
		trap_check_kernel();
  10206d:	e8 c9 02 00 00       	call   10233b <trap_check_kernel>
}
  102072:	c9                   	leave  
  102073:	c3                   	ret    

00102074 <trap_name>:

const char *trap_name(int trapno)
{
  102074:	55                   	push   %ebp
  102075:	89 e5                	mov    %esp,%ebp
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
  102077:	8b 45 08             	mov    0x8(%ebp),%eax
  10207a:	83 f8 13             	cmp    $0x13,%eax
  10207d:	77 0c                	ja     10208b <trap_name+0x17>
		return excnames[trapno];
  10207f:	8b 45 08             	mov    0x8(%ebp),%eax
  102082:	8b 04 85 40 62 10 00 	mov    0x106240(,%eax,4),%eax
  102089:	eb 25                	jmp    1020b0 <trap_name+0x3c>
	if (trapno == T_SYSCALL)
  10208b:	83 7d 08 30          	cmpl   $0x30,0x8(%ebp)
  10208f:	75 07                	jne    102098 <trap_name+0x24>
		return "System call";
  102091:	b8 8a 5e 10 00       	mov    $0x105e8a,%eax
  102096:	eb 18                	jmp    1020b0 <trap_name+0x3c>
	if (trapno >= T_IRQ0 && trapno < T_IRQ0 + 16)
  102098:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  10209c:	7e 0d                	jle    1020ab <trap_name+0x37>
  10209e:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1020a2:	7f 07                	jg     1020ab <trap_name+0x37>
		return "Hardware Interrupt";
  1020a4:	b8 96 5e 10 00       	mov    $0x105e96,%eax
  1020a9:	eb 05                	jmp    1020b0 <trap_name+0x3c>
	return "(unknown trap)";
  1020ab:	b8 a9 5e 10 00       	mov    $0x105ea9,%eax
}
  1020b0:	5d                   	pop    %ebp
  1020b1:	c3                   	ret    

001020b2 <trap_print_regs>:

void
trap_print_regs(pushregs *regs)
{
  1020b2:	55                   	push   %ebp
  1020b3:	89 e5                	mov    %esp,%ebp
  1020b5:	83 ec 18             	sub    $0x18,%esp
	cprintf("  edi  0x%08x\n", regs->edi);
  1020b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1020bb:	8b 00                	mov    (%eax),%eax
  1020bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1020c1:	c7 04 24 b8 5e 10 00 	movl   $0x105eb8,(%esp)
  1020c8:	e8 78 31 00 00       	call   105245 <cprintf>
	cprintf("  esi  0x%08x\n", regs->esi);
  1020cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1020d0:	8b 40 04             	mov    0x4(%eax),%eax
  1020d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1020d7:	c7 04 24 c7 5e 10 00 	movl   $0x105ec7,(%esp)
  1020de:	e8 62 31 00 00       	call   105245 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->ebp);
  1020e3:	8b 45 08             	mov    0x8(%ebp),%eax
  1020e6:	8b 40 08             	mov    0x8(%eax),%eax
  1020e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1020ed:	c7 04 24 d6 5e 10 00 	movl   $0x105ed6,(%esp)
  1020f4:	e8 4c 31 00 00       	call   105245 <cprintf>
//	cprintf("  oesp 0x%08x\n", regs->oesp);	don't print - useless
	cprintf("  ebx  0x%08x\n", regs->ebx);
  1020f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1020fc:	8b 40 10             	mov    0x10(%eax),%eax
  1020ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  102103:	c7 04 24 e5 5e 10 00 	movl   $0x105ee5,(%esp)
  10210a:	e8 36 31 00 00       	call   105245 <cprintf>
	cprintf("  edx  0x%08x\n", regs->edx);
  10210f:	8b 45 08             	mov    0x8(%ebp),%eax
  102112:	8b 40 14             	mov    0x14(%eax),%eax
  102115:	89 44 24 04          	mov    %eax,0x4(%esp)
  102119:	c7 04 24 f4 5e 10 00 	movl   $0x105ef4,(%esp)
  102120:	e8 20 31 00 00       	call   105245 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->ecx);
  102125:	8b 45 08             	mov    0x8(%ebp),%eax
  102128:	8b 40 18             	mov    0x18(%eax),%eax
  10212b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10212f:	c7 04 24 03 5f 10 00 	movl   $0x105f03,(%esp)
  102136:	e8 0a 31 00 00       	call   105245 <cprintf>
	cprintf("  eax  0x%08x\n", regs->eax);
  10213b:	8b 45 08             	mov    0x8(%ebp),%eax
  10213e:	8b 40 1c             	mov    0x1c(%eax),%eax
  102141:	89 44 24 04          	mov    %eax,0x4(%esp)
  102145:	c7 04 24 12 5f 10 00 	movl   $0x105f12,(%esp)
  10214c:	e8 f4 30 00 00       	call   105245 <cprintf>
}
  102151:	c9                   	leave  
  102152:	c3                   	ret    

00102153 <trap_print>:

void
trap_print(trapframe *tf)
{
  102153:	55                   	push   %ebp
  102154:	89 e5                	mov    %esp,%ebp
  102156:	83 ec 18             	sub    $0x18,%esp
	cprintf("TRAP frame at %p\n", tf);
  102159:	8b 45 08             	mov    0x8(%ebp),%eax
  10215c:	89 44 24 04          	mov    %eax,0x4(%esp)
  102160:	c7 04 24 21 5f 10 00 	movl   $0x105f21,(%esp)
  102167:	e8 d9 30 00 00       	call   105245 <cprintf>
	trap_print_regs(&tf->regs);
  10216c:	8b 45 08             	mov    0x8(%ebp),%eax
  10216f:	89 04 24             	mov    %eax,(%esp)
  102172:	e8 3b ff ff ff       	call   1020b2 <trap_print_regs>
	cprintf("  es   0x----%04x\n", tf->es);
  102177:	8b 45 08             	mov    0x8(%ebp),%eax
  10217a:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  10217e:	0f b7 c0             	movzwl %ax,%eax
  102181:	89 44 24 04          	mov    %eax,0x4(%esp)
  102185:	c7 04 24 33 5f 10 00 	movl   $0x105f33,(%esp)
  10218c:	e8 b4 30 00 00       	call   105245 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->ds);
  102191:	8b 45 08             	mov    0x8(%ebp),%eax
  102194:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  102198:	0f b7 c0             	movzwl %ax,%eax
  10219b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10219f:	c7 04 24 46 5f 10 00 	movl   $0x105f46,(%esp)
  1021a6:	e8 9a 30 00 00       	call   105245 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->trapno, trap_name(tf->trapno));
  1021ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1021ae:	8b 40 30             	mov    0x30(%eax),%eax
  1021b1:	89 04 24             	mov    %eax,(%esp)
  1021b4:	e8 bb fe ff ff       	call   102074 <trap_name>
  1021b9:	8b 55 08             	mov    0x8(%ebp),%edx
  1021bc:	8b 52 30             	mov    0x30(%edx),%edx
  1021bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  1021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  1021c7:	c7 04 24 59 5f 10 00 	movl   $0x105f59,(%esp)
  1021ce:	e8 72 30 00 00       	call   105245 <cprintf>
	cprintf("  err  0x%08x\n", tf->err);
  1021d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1021d6:	8b 40 34             	mov    0x34(%eax),%eax
  1021d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1021dd:	c7 04 24 6b 5f 10 00 	movl   $0x105f6b,(%esp)
  1021e4:	e8 5c 30 00 00       	call   105245 <cprintf>
	cprintf("  eip  0x%08x\n", tf->eip);
  1021e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1021ec:	8b 40 38             	mov    0x38(%eax),%eax
  1021ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  1021f3:	c7 04 24 7a 5f 10 00 	movl   $0x105f7a,(%esp)
  1021fa:	e8 46 30 00 00       	call   105245 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->cs);
  1021ff:	8b 45 08             	mov    0x8(%ebp),%eax
  102202:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  102206:	0f b7 c0             	movzwl %ax,%eax
  102209:	89 44 24 04          	mov    %eax,0x4(%esp)
  10220d:	c7 04 24 89 5f 10 00 	movl   $0x105f89,(%esp)
  102214:	e8 2c 30 00 00       	call   105245 <cprintf>
	cprintf("  flag 0x%08x\n", tf->eflags);
  102219:	8b 45 08             	mov    0x8(%ebp),%eax
  10221c:	8b 40 40             	mov    0x40(%eax),%eax
  10221f:	89 44 24 04          	mov    %eax,0x4(%esp)
  102223:	c7 04 24 9c 5f 10 00 	movl   $0x105f9c,(%esp)
  10222a:	e8 16 30 00 00       	call   105245 <cprintf>
	cprintf("  esp  0x%08x\n", tf->esp);
  10222f:	8b 45 08             	mov    0x8(%ebp),%eax
  102232:	8b 40 44             	mov    0x44(%eax),%eax
  102235:	89 44 24 04          	mov    %eax,0x4(%esp)
  102239:	c7 04 24 ab 5f 10 00 	movl   $0x105fab,(%esp)
  102240:	e8 00 30 00 00       	call   105245 <cprintf>
	cprintf("  ss   0x----%04x\n", tf->ss);
  102245:	8b 45 08             	mov    0x8(%ebp),%eax
  102248:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  10224c:	0f b7 c0             	movzwl %ax,%eax
  10224f:	89 44 24 04          	mov    %eax,0x4(%esp)
  102253:	c7 04 24 ba 5f 10 00 	movl   $0x105fba,(%esp)
  10225a:	e8 e6 2f 00 00       	call   105245 <cprintf>
}
  10225f:	c9                   	leave  
  102260:	c3                   	ret    

00102261 <trap>:

void gcc_noreturn
trap(trapframe *tf)
{
  102261:	55                   	push   %ebp
  102262:	89 e5                	mov    %esp,%ebp
  102264:	83 ec 28             	sub    $0x28,%esp
	// The user-level environment may have set the DF flag,
	// and some versions of GCC rely on DF being clear.
	asm volatile("cld" ::: "cc");
  102267:	fc                   	cld    

	// If this trap was anticipated, just use the designated handler.
	cpu *c = cpu_cur();
  102268:	e8 73 f2 ff ff       	call   1014e0 <cpu_cur>
  10226d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	trap_print(tf);
  102270:	8b 45 08             	mov    0x8(%ebp),%eax
  102273:	89 04 24             	mov    %eax,(%esp)
  102276:	e8 d8 fe ff ff       	call   102153 <trap_print>
	if (c->recover)
  10227b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10227e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  102284:	85 c0                	test   %eax,%eax
  102286:	74 1e                	je     1022a6 <trap+0x45>
		c->recover(tf, c->recoverdata);
  102288:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10228b:	8b 90 a0 00 00 00    	mov    0xa0(%eax),%edx
  102291:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102294:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  10229a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10229e:	8b 45 08             	mov    0x8(%ebp),%eax
  1022a1:	89 04 24             	mov    %eax,(%esp)
  1022a4:	ff d2                	call   *%edx

	// Lab 2: your trap handling code here!

	// If we panic while holding the console lock,
	// release it so we don't get into a recursive panic that way.
	if (spinlock_holding(&cons_lock))
  1022a6:	c7 04 24 40 e2 10 00 	movl   $0x10e240,(%esp)
  1022ad:	e8 2f 0a 00 00       	call   102ce1 <spinlock_holding>
  1022b2:	85 c0                	test   %eax,%eax
  1022b4:	74 0c                	je     1022c2 <trap+0x61>
		spinlock_release(&cons_lock);
  1022b6:	c7 04 24 40 e2 10 00 	movl   $0x10e240,(%esp)
  1022bd:	e8 c5 09 00 00       	call   102c87 <spinlock_release>
	trap_print(tf);
  1022c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1022c5:	89 04 24             	mov    %eax,(%esp)
  1022c8:	e8 86 fe ff ff       	call   102153 <trap_print>
	panic("unhandled trap");
  1022cd:	c7 44 24 08 cd 5f 10 	movl   $0x105fcd,0x8(%esp)
  1022d4:	00 
  1022d5:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
  1022dc:	00 
  1022dd:	c7 04 24 dc 5f 10 00 	movl   $0x105fdc,(%esp)
  1022e4:	e8 23 e1 ff ff       	call   10040c <debug_panic>

001022e9 <trap_check_recover>:

// Helper function for trap_check_recover(), below:
// handles "anticipated" traps by simply resuming at a new EIP.
static void gcc_noreturn
trap_check_recover(trapframe *tf, void *recoverdata)
{
  1022e9:	55                   	push   %ebp
  1022ea:	89 e5                	mov    %esp,%ebp
  1022ec:	83 ec 28             	sub    $0x28,%esp
	trap_check_args *args = recoverdata;
  1022ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1022f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	trap_print(tf);
  1022f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1022f8:	89 04 24             	mov    %eax,(%esp)
  1022fb:	e8 53 fe ff ff       	call   102153 <trap_print>
	cprintf("reip = %d\n", args->reip);
  102300:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102303:	8b 00                	mov    (%eax),%eax
  102305:	89 44 24 04          	mov    %eax,0x4(%esp)
  102309:	c7 04 24 e8 5f 10 00 	movl   $0x105fe8,(%esp)
  102310:	e8 30 2f 00 00       	call   105245 <cprintf>
	tf->eip = (uint32_t) args->reip;	// Use recovery EIP on return
  102315:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102318:	8b 00                	mov    (%eax),%eax
  10231a:	89 c2                	mov    %eax,%edx
  10231c:	8b 45 08             	mov    0x8(%ebp),%eax
  10231f:	89 50 38             	mov    %edx,0x38(%eax)
	args->trapno = tf->trapno;		// Return trap number
  102322:	8b 45 08             	mov    0x8(%ebp),%eax
  102325:	8b 40 30             	mov    0x30(%eax),%eax
  102328:	89 c2                	mov    %eax,%edx
  10232a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10232d:	89 50 04             	mov    %edx,0x4(%eax)
	trap_return(tf);
  102330:	8b 45 08             	mov    0x8(%ebp),%eax
  102333:	89 04 24             	mov    %eax,(%esp)
  102336:	e8 35 04 00 00       	call   102770 <trap_return>

0010233b <trap_check_kernel>:

// Check for correct handling of traps from kernel mode.
// Called on the boot CPU after trap_init() and trap_setup().
void
trap_check_kernel(void)
{
  10233b:	55                   	push   %ebp
  10233c:	89 e5                	mov    %esp,%ebp
  10233e:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  102341:	8c 4d f6             	mov    %cs,-0xa(%ebp)
        return cs;
  102344:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
	assert((read_cs() & 3) == 0);	// better be in kernel mode!
  102348:	0f b7 c0             	movzwl %ax,%eax
  10234b:	83 e0 03             	and    $0x3,%eax
  10234e:	85 c0                	test   %eax,%eax
  102350:	74 24                	je     102376 <trap_check_kernel+0x3b>
  102352:	c7 44 24 0c f3 5f 10 	movl   $0x105ff3,0xc(%esp)
  102359:	00 
  10235a:	c7 44 24 08 56 5e 10 	movl   $0x105e56,0x8(%esp)
  102361:	00 
  102362:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
  102369:	00 
  10236a:	c7 04 24 dc 5f 10 00 	movl   $0x105fdc,(%esp)
  102371:	e8 96 e0 ff ff       	call   10040c <debug_panic>

	cpu *c = cpu_cur();
  102376:	e8 65 f1 ff ff       	call   1014e0 <cpu_cur>
  10237b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	c->recover = trap_check_recover;
  10237e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102381:	c7 80 a0 00 00 00 e9 	movl   $0x1022e9,0xa0(%eax)
  102388:	22 10 00 
	trap_check(&c->recoverdata);
  10238b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10238e:	05 a4 00 00 00       	add    $0xa4,%eax
  102393:	89 04 24             	mov    %eax,(%esp)
  102396:	e8 96 00 00 00       	call   102431 <trap_check>
	c->recover = NULL;	// No more mr. nice-guy; traps are real again
  10239b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10239e:	c7 80 a0 00 00 00 00 	movl   $0x0,0xa0(%eax)
  1023a5:	00 00 00 

	cprintf("trap_check_kernel() succeeded!\n");
  1023a8:	c7 04 24 08 60 10 00 	movl   $0x106008,(%esp)
  1023af:	e8 91 2e 00 00       	call   105245 <cprintf>
}
  1023b4:	c9                   	leave  
  1023b5:	c3                   	ret    

001023b6 <trap_check_user>:
// Called from user() in kern/init.c, only in lab 1.
// We assume the "current cpu" is always the boot cpu;
// this true only because lab 1 doesn't start any other CPUs.
void
trap_check_user(void)
{
  1023b6:	55                   	push   %ebp
  1023b7:	89 e5                	mov    %esp,%ebp
  1023b9:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  1023bc:	8c 4d f6             	mov    %cs,-0xa(%ebp)
        return cs;
  1023bf:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
	assert((read_cs() & 3) == 3);	// better be in user mode!
  1023c3:	0f b7 c0             	movzwl %ax,%eax
  1023c6:	83 e0 03             	and    $0x3,%eax
  1023c9:	83 f8 03             	cmp    $0x3,%eax
  1023cc:	74 24                	je     1023f2 <trap_check_user+0x3c>
  1023ce:	c7 44 24 0c 28 60 10 	movl   $0x106028,0xc(%esp)
  1023d5:	00 
  1023d6:	c7 44 24 08 56 5e 10 	movl   $0x105e56,0x8(%esp)
  1023dd:	00 
  1023de:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  1023e5:	00 
  1023e6:	c7 04 24 dc 5f 10 00 	movl   $0x105fdc,(%esp)
  1023ed:	e8 1a e0 ff ff       	call   10040c <debug_panic>

	cpu *c = &cpu_boot;	// cpu_cur doesn't work from user mode!
  1023f2:	c7 45 f0 00 70 10 00 	movl   $0x107000,-0x10(%ebp)
	c->recover = trap_check_recover;
  1023f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1023fc:	c7 80 a0 00 00 00 e9 	movl   $0x1022e9,0xa0(%eax)
  102403:	22 10 00 
	trap_check(&c->recoverdata);
  102406:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102409:	05 a4 00 00 00       	add    $0xa4,%eax
  10240e:	89 04 24             	mov    %eax,(%esp)
  102411:	e8 1b 00 00 00       	call   102431 <trap_check>
	c->recover = NULL;	// No more mr. nice-guy; traps are real again
  102416:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102419:	c7 80 a0 00 00 00 00 	movl   $0x0,0xa0(%eax)
  102420:	00 00 00 

	cprintf("trap_check_user() succeeded!\n");
  102423:	c7 04 24 3d 60 10 00 	movl   $0x10603d,(%esp)
  10242a:	e8 16 2e 00 00       	call   105245 <cprintf>
}
  10242f:	c9                   	leave  
  102430:	c3                   	ret    

00102431 <trap_check>:
void after_priv();

// Multi-purpose trap checking function.
void
trap_check(void **argsp)
{
  102431:	55                   	push   %ebp
  102432:	89 e5                	mov    %esp,%ebp
  102434:	57                   	push   %edi
  102435:	56                   	push   %esi
  102436:	53                   	push   %ebx
  102437:	83 ec 3c             	sub    $0x3c,%esp
	volatile int cookie = 0xfeedface;
  10243a:	c7 45 e0 ce fa ed fe 	movl   $0xfeedface,-0x20(%ebp)
	volatile trap_check_args args;
	*argsp = (void*)&args;	// provide args needed for trap recovery
  102441:	8b 45 08             	mov    0x8(%ebp),%eax
  102444:	8d 55 d8             	lea    -0x28(%ebp),%edx
  102447:	89 10                	mov    %edx,(%eax)

	// Try a divide by zero trap.
	// Be careful when using && to take the address of a label:
	// some versions of GCC (4.4.2 at least) will incorrectly try to
	// eliminate code it thinks is _only_ reachable via such a pointer.
	args.reip = after_div0;
  102449:	c7 45 d8 57 24 10 00 	movl   $0x102457,-0x28(%ebp)
	asm volatile("div %0,%0; after_div0:" : : "r" (0));
  102450:	b8 00 00 00 00       	mov    $0x0,%eax
  102455:	f7 f0                	div    %eax

00102457 <after_div0>:
	assert(args.trapno == T_DIVIDE);
  102457:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10245a:	85 c0                	test   %eax,%eax
  10245c:	74 24                	je     102482 <after_div0+0x2b>
  10245e:	c7 44 24 0c 5b 60 10 	movl   $0x10605b,0xc(%esp)
  102465:	00 
  102466:	c7 44 24 08 56 5e 10 	movl   $0x105e56,0x8(%esp)
  10246d:	00 
  10246e:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  102475:	00 
  102476:	c7 04 24 dc 5f 10 00 	movl   $0x105fdc,(%esp)
  10247d:	e8 8a df ff ff       	call   10040c <debug_panic>

	// Make sure we got our correct stack back with us.
	// The asm ensures gcc uses ebp/esp to get the cookie.
	asm volatile("" : : : "eax","ebx","ecx","edx","esi","edi");
	assert(cookie == 0xfeedface);
  102482:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102485:	3d ce fa ed fe       	cmp    $0xfeedface,%eax
  10248a:	74 24                	je     1024b0 <after_div0+0x59>
  10248c:	c7 44 24 0c 73 60 10 	movl   $0x106073,0xc(%esp)
  102493:	00 
  102494:	c7 44 24 08 56 5e 10 	movl   $0x105e56,0x8(%esp)
  10249b:	00 
  10249c:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  1024a3:	00 
  1024a4:	c7 04 24 dc 5f 10 00 	movl   $0x105fdc,(%esp)
  1024ab:	e8 5c df ff ff       	call   10040c <debug_panic>

	// Breakpoint trap
	args.reip = after_breakpoint;
  1024b0:	c7 45 d8 b8 24 10 00 	movl   $0x1024b8,-0x28(%ebp)
	asm volatile("int3; after_breakpoint:");
  1024b7:	cc                   	int3   

001024b8 <after_breakpoint>:
	assert(args.trapno == T_BRKPT);
  1024b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1024bb:	83 f8 03             	cmp    $0x3,%eax
  1024be:	74 24                	je     1024e4 <after_breakpoint+0x2c>
  1024c0:	c7 44 24 0c 88 60 10 	movl   $0x106088,0xc(%esp)
  1024c7:	00 
  1024c8:	c7 44 24 08 56 5e 10 	movl   $0x105e56,0x8(%esp)
  1024cf:	00 
  1024d0:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  1024d7:	00 
  1024d8:	c7 04 24 dc 5f 10 00 	movl   $0x105fdc,(%esp)
  1024df:	e8 28 df ff ff       	call   10040c <debug_panic>

	// Overflow trap
	args.reip = after_overflow;
  1024e4:	c7 45 d8 f3 24 10 00 	movl   $0x1024f3,-0x28(%ebp)
	asm volatile("addl %0,%0; into; after_overflow:" : : "r" (0x70000000));
  1024eb:	b8 00 00 00 70       	mov    $0x70000000,%eax
  1024f0:	01 c0                	add    %eax,%eax
  1024f2:	ce                   	into   

001024f3 <after_overflow>:
	assert(args.trapno == T_OFLOW);
  1024f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1024f6:	83 f8 04             	cmp    $0x4,%eax
  1024f9:	74 24                	je     10251f <after_overflow+0x2c>
  1024fb:	c7 44 24 0c 9f 60 10 	movl   $0x10609f,0xc(%esp)
  102502:	00 
  102503:	c7 44 24 08 56 5e 10 	movl   $0x105e56,0x8(%esp)
  10250a:	00 
  10250b:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
  102512:	00 
  102513:	c7 04 24 dc 5f 10 00 	movl   $0x105fdc,(%esp)
  10251a:	e8 ed de ff ff       	call   10040c <debug_panic>

	// Bounds trap
	args.reip = after_bound;
  10251f:	c7 45 d8 3c 25 10 00 	movl   $0x10253c,-0x28(%ebp)
	int bounds[2] = { 1, 3 };
  102526:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  10252d:	c7 45 d4 03 00 00 00 	movl   $0x3,-0x2c(%ebp)
	asm volatile("boundl %0,%1; after_bound:" : : "r" (0), "m" (bounds[0]));
  102534:	b8 00 00 00 00       	mov    $0x0,%eax
  102539:	62 45 d0             	bound  %eax,-0x30(%ebp)

0010253c <after_bound>:
	assert(args.trapno == T_BOUND);
  10253c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10253f:	83 f8 05             	cmp    $0x5,%eax
  102542:	74 24                	je     102568 <after_bound+0x2c>
  102544:	c7 44 24 0c b6 60 10 	movl   $0x1060b6,0xc(%esp)
  10254b:	00 
  10254c:	c7 44 24 08 56 5e 10 	movl   $0x105e56,0x8(%esp)
  102553:	00 
  102554:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  10255b:	00 
  10255c:	c7 04 24 dc 5f 10 00 	movl   $0x105fdc,(%esp)
  102563:	e8 a4 de ff ff       	call   10040c <debug_panic>

	// Illegal instruction trap
	args.reip = after_illegal;
  102568:	c7 45 d8 71 25 10 00 	movl   $0x102571,-0x28(%ebp)
	asm volatile("ud2; after_illegal:");	// guaranteed to be undefined
  10256f:	0f 0b                	ud2    

00102571 <after_illegal>:
	assert(args.trapno == T_ILLOP);
  102571:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102574:	83 f8 06             	cmp    $0x6,%eax
  102577:	74 24                	je     10259d <after_illegal+0x2c>
  102579:	c7 44 24 0c cd 60 10 	movl   $0x1060cd,0xc(%esp)
  102580:	00 
  102581:	c7 44 24 08 56 5e 10 	movl   $0x105e56,0x8(%esp)
  102588:	00 
  102589:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  102590:	00 
  102591:	c7 04 24 dc 5f 10 00 	movl   $0x105fdc,(%esp)
  102598:	e8 6f de ff ff       	call   10040c <debug_panic>

	// General protection fault due to invalid segment load
	args.reip = after_gpfault;
  10259d:	c7 45 d8 ab 25 10 00 	movl   $0x1025ab,-0x28(%ebp)
	asm volatile("movl %0,%%fs; after_gpfault:" : : "r" (-1));
  1025a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1025a9:	8e e0                	mov    %eax,%fs

001025ab <after_gpfault>:
	assert(args.trapno == T_GPFLT);
  1025ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1025ae:	83 f8 0d             	cmp    $0xd,%eax
  1025b1:	74 24                	je     1025d7 <after_gpfault+0x2c>
  1025b3:	c7 44 24 0c e4 60 10 	movl   $0x1060e4,0xc(%esp)
  1025ba:	00 
  1025bb:	c7 44 24 08 56 5e 10 	movl   $0x105e56,0x8(%esp)
  1025c2:	00 
  1025c3:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  1025ca:	00 
  1025cb:	c7 04 24 dc 5f 10 00 	movl   $0x105fdc,(%esp)
  1025d2:	e8 35 de ff ff       	call   10040c <debug_panic>

static gcc_inline uint16_t
read_cs(void)
{
        uint16_t cs;
        __asm __volatile("movw %%cs,%0" : "=rm" (cs));
  1025d7:	8c 4d e6             	mov    %cs,-0x1a(%ebp)
        return cs;
  1025da:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax

	// General protection fault due to privilege violation
	if (read_cs() & 3) {
  1025de:	0f b7 c0             	movzwl %ax,%eax
  1025e1:	83 e0 03             	and    $0x3,%eax
  1025e4:	85 c0                	test   %eax,%eax
  1025e6:	74 3a                	je     102622 <after_priv+0x2c>
		args.reip = after_priv;
  1025e8:	c7 45 d8 f6 25 10 00 	movl   $0x1025f6,-0x28(%ebp)
		asm volatile("lidt %0; after_priv:" : : "m" (idt_pd));
  1025ef:	0f 01 1d 04 80 10 00 	lidtl  0x108004

001025f6 <after_priv>:
		assert(args.trapno == T_GPFLT);
  1025f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1025f9:	83 f8 0d             	cmp    $0xd,%eax
  1025fc:	74 24                	je     102622 <after_priv+0x2c>
  1025fe:	c7 44 24 0c e4 60 10 	movl   $0x1060e4,0xc(%esp)
  102605:	00 
  102606:	c7 44 24 08 56 5e 10 	movl   $0x105e56,0x8(%esp)
  10260d:	00 
  10260e:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
  102615:	00 
  102616:	c7 04 24 dc 5f 10 00 	movl   $0x105fdc,(%esp)
  10261d:	e8 ea dd ff ff       	call   10040c <debug_panic>
	}

	// Make sure our stack cookie is still with us
	assert(cookie == 0xfeedface);
  102622:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102625:	3d ce fa ed fe       	cmp    $0xfeedface,%eax
  10262a:	74 24                	je     102650 <after_priv+0x5a>
  10262c:	c7 44 24 0c 73 60 10 	movl   $0x106073,0xc(%esp)
  102633:	00 
  102634:	c7 44 24 08 56 5e 10 	movl   $0x105e56,0x8(%esp)
  10263b:	00 
  10263c:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
  102643:	00 
  102644:	c7 04 24 dc 5f 10 00 	movl   $0x105fdc,(%esp)
  10264b:	e8 bc dd ff ff       	call   10040c <debug_panic>

	*argsp = NULL;	// recovery mechanism not needed anymore
  102650:	8b 45 08             	mov    0x8(%ebp),%eax
  102653:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
  102659:	83 c4 3c             	add    $0x3c,%esp
  10265c:	5b                   	pop    %ebx
  10265d:	5e                   	pop    %esi
  10265e:	5f                   	pop    %edi
  10265f:	5d                   	pop    %ebp
  102660:	c3                   	ret    
  102661:	90                   	nop
  102662:	90                   	nop
  102663:	90                   	nop
  102664:	90                   	nop
  102665:	90                   	nop
  102666:	90                   	nop
  102667:	90                   	nop
  102668:	90                   	nop
  102669:	90                   	nop
  10266a:	90                   	nop
  10266b:	90                   	nop
  10266c:	90                   	nop
  10266d:	90                   	nop
  10266e:	90                   	nop
  10266f:	90                   	nop

00102670 <tv0>:
.text

/*
 * Lab 1: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(tv0, 0);
  102670:	6a 00                	push   $0x0
  102672:	6a 00                	push   $0x0
  102674:	e9 dd 00 00 00       	jmp    102756 <_alltraps>
  102679:	90                   	nop

0010267a <tv2>:
/* TRAPHANDLER_NOEC(trap_debug, 1); */
TRAPHANDLER_NOEC(tv2, 2);
  10267a:	6a 00                	push   $0x0
  10267c:	6a 02                	push   $0x2
  10267e:	e9 d3 00 00 00       	jmp    102756 <_alltraps>
  102683:	90                   	nop

00102684 <tv3>:
TRAPHANDLER_NOEC(tv3, 3);
  102684:	6a 00                	push   $0x0
  102686:	6a 03                	push   $0x3
  102688:	e9 c9 00 00 00       	jmp    102756 <_alltraps>
  10268d:	90                   	nop

0010268e <tv4>:
TRAPHANDLER_NOEC(tv4, 4);
  10268e:	6a 00                	push   $0x0
  102690:	6a 04                	push   $0x4
  102692:	e9 bf 00 00 00       	jmp    102756 <_alltraps>
  102697:	90                   	nop

00102698 <tv5>:
TRAPHANDLER_NOEC(tv5, 5);
  102698:	6a 00                	push   $0x0
  10269a:	6a 05                	push   $0x5
  10269c:	e9 b5 00 00 00       	jmp    102756 <_alltraps>
  1026a1:	90                   	nop

001026a2 <tv6>:
TRAPHANDLER_NOEC(tv6, 6);
  1026a2:	6a 00                	push   $0x0
  1026a4:	6a 06                	push   $0x6
  1026a6:	e9 ab 00 00 00       	jmp    102756 <_alltraps>
  1026ab:	90                   	nop

001026ac <tv7>:
TRAPHANDLER_NOEC(tv7, 7);
  1026ac:	6a 00                	push   $0x0
  1026ae:	6a 07                	push   $0x7
  1026b0:	e9 a1 00 00 00       	jmp    102756 <_alltraps>
  1026b5:	90                   	nop

001026b6 <tv8>:
TRAPHANDLER(tv8, 8);
  1026b6:	6a 08                	push   $0x8
  1026b8:	e9 99 00 00 00       	jmp    102756 <_alltraps>
  1026bd:	90                   	nop

001026be <tv10>:
/* TRAPHANDLER_NOEC(trap_coproc_seg_overrun, 9); */
TRAPHANDLER(tv10, 10);
  1026be:	6a 0a                	push   $0xa
  1026c0:	e9 91 00 00 00       	jmp    102756 <_alltraps>
  1026c5:	90                   	nop

001026c6 <tv11>:
TRAPHANDLER(tv11, 11);
  1026c6:	6a 0b                	push   $0xb
  1026c8:	e9 89 00 00 00       	jmp    102756 <_alltraps>
  1026cd:	90                   	nop

001026ce <tv12>:
TRAPHANDLER(tv12, 12);
  1026ce:	6a 0c                	push   $0xc
  1026d0:	e9 81 00 00 00       	jmp    102756 <_alltraps>
  1026d5:	90                   	nop

001026d6 <tv13>:
TRAPHANDLER(tv13, 13);
  1026d6:	6a 0d                	push   $0xd
  1026d8:	e9 79 00 00 00       	jmp    102756 <_alltraps>
  1026dd:	90                   	nop

001026de <tv14>:
TRAPHANDLER(tv14, 14);
  1026de:	6a 0e                	push   $0xe
  1026e0:	e9 71 00 00 00       	jmp    102756 <_alltraps>
  1026e5:	90                   	nop

001026e6 <tv16>:
/* TRAPHANDLER_NOEC(reserved, 15); */
TRAPHANDLER_NOEC(tv16, 16);
  1026e6:	6a 00                	push   $0x0
  1026e8:	6a 10                	push   $0x10
  1026ea:	e9 67 00 00 00       	jmp    102756 <_alltraps>
  1026ef:	90                   	nop

001026f0 <tv17>:
TRAPHANDLER(tv17, 17);
  1026f0:	6a 11                	push   $0x11
  1026f2:	e9 5f 00 00 00       	jmp    102756 <_alltraps>
  1026f7:	90                   	nop

001026f8 <tv18>:
TRAPHANDLER_NOEC(tv18, 18);
  1026f8:	6a 00                	push   $0x0
  1026fa:	6a 12                	push   $0x12
  1026fc:	e9 55 00 00 00       	jmp    102756 <_alltraps>
  102701:	90                   	nop

00102702 <tv19>:
TRAPHANDLER_NOEC(tv19, 19);
  102702:	6a 00                	push   $0x0
  102704:	6a 13                	push   $0x13
  102706:	e9 4b 00 00 00       	jmp    102756 <_alltraps>
  10270b:	90                   	nop

0010270c <tv30>:
TRAPHANDLER_NOEC(tv30, 30);
  10270c:	6a 00                	push   $0x0
  10270e:	6a 1e                	push   $0x1e
  102710:	e9 41 00 00 00       	jmp    102756 <_alltraps>
  102715:	90                   	nop

00102716 <tv32>:
TRAPHANDLER_NOEC(tv32, 32);
  102716:	6a 00                	push   $0x0
  102718:	6a 20                	push   $0x20
  10271a:	e9 37 00 00 00       	jmp    102756 <_alltraps>
  10271f:	90                   	nop

00102720 <tv48>:
TRAPHANDLER_NOEC(tv48, 48);
  102720:	6a 00                	push   $0x0
  102722:	6a 30                	push   $0x30
  102724:	e9 2d 00 00 00       	jmp    102756 <_alltraps>
  102729:	90                   	nop

0010272a <tv49>:
TRAPHANDLER_NOEC(tv49, 49);
  10272a:	6a 00                	push   $0x0
  10272c:	6a 31                	push   $0x31
  10272e:	e9 23 00 00 00       	jmp    102756 <_alltraps>
  102733:	90                   	nop

00102734 <tv50>:
TRAPHANDLER_NOEC(tv50, 50);
  102734:	6a 00                	push   $0x0
  102736:	6a 32                	push   $0x32
  102738:	e9 19 00 00 00       	jmp    102756 <_alltraps>
  10273d:	90                   	nop

0010273e <tv500>:
TRAPHANDLER_NOEC(tv500, 500);
  10273e:	6a 00                	push   $0x0
  102740:	68 f4 01 00 00       	push   $0x1f4
  102745:	e9 0c 00 00 00       	jmp    102756 <_alltraps>

0010274a <tv501>:
TRAPHANDLER_NOEC(tv501, 501);
  10274a:	6a 00                	push   $0x0
  10274c:	68 f5 01 00 00       	push   $0x1f5
  102751:	e9 00 00 00 00       	jmp    102756 <_alltraps>

00102756 <_alltraps>:
/*
 * Lab 1: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
	pushl %ds
  102756:	1e                   	push   %ds
	pushl %es
  102757:	06                   	push   %es
	pushl %fs
  102758:	0f a0                	push   %fs
	pushl %gs
  10275a:	0f a8                	push   %gs
	pushal
  10275c:	60                   	pusha  

	movw $CPU_GDT_KDATA, %ax
  10275d:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
  102761:	8e d8                	mov    %eax,%ds
	movw %ax, %es
  102763:	8e c0                	mov    %eax,%es

	pushl %esp // passing trapframe addr as parameter
  102765:	54                   	push   %esp
	call trap
  102766:	e8 f6 fa ff ff       	call   102261 <trap>
  10276b:	90                   	nop
  10276c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00102770 <trap_return>:
// replaces the caller's stack pointer and other registers.
.globl	trap_return
.type	trap_return,@function
.p2align 4, 0x90		/* 16-byte alignment, nop filled */
trap_return:
	movl 0x4(%esp), %eax
  102770:	8b 44 24 04          	mov    0x4(%esp),%eax
	movl %eax, %esp // setting stack to trap frame
  102774:	89 c4                	mov    %eax,%esp
	popal
  102776:	61                   	popa   
	popl %gs
  102777:	0f a9                	pop    %gs
	popl %fs
  102779:	0f a1                	pop    %fs
	popl %es
  10277b:	07                   	pop    %es
	popl %ds
  10277c:	1f                   	pop    %ds
	addl $0x8, %esp // trapno and errcode
  10277d:	83 c4 08             	add    $0x8,%esp
	iret
  102780:	cf                   	iret   
  102781:	90                   	nop
  102782:	90                   	nop
  102783:	90                   	nop

00102784 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  102784:	55                   	push   %ebp
  102785:	89 e5                	mov    %esp,%ebp
  102787:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  10278a:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  10278d:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  102790:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102793:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102796:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10279b:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  10279e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1027a1:	8b 80 b8 00 00 00    	mov    0xb8(%eax),%eax
  1027a7:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  1027ac:	74 24                	je     1027d2 <cpu_cur+0x4e>
  1027ae:	c7 44 24 0c 90 62 10 	movl   $0x106290,0xc(%esp)
  1027b5:	00 
  1027b6:	c7 44 24 08 a6 62 10 	movl   $0x1062a6,0x8(%esp)
  1027bd:	00 
  1027be:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  1027c5:	00 
  1027c6:	c7 04 24 bb 62 10 00 	movl   $0x1062bb,(%esp)
  1027cd:	e8 3a dc ff ff       	call   10040c <debug_panic>
	return c;
  1027d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  1027d5:	c9                   	leave  
  1027d6:	c3                   	ret    

001027d7 <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  1027d7:	55                   	push   %ebp
  1027d8:	89 e5                	mov    %esp,%ebp
  1027da:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  1027dd:	e8 a2 ff ff ff       	call   102784 <cpu_cur>
  1027e2:	3d 00 70 10 00       	cmp    $0x107000,%eax
  1027e7:	0f 94 c0             	sete   %al
  1027ea:	0f b6 c0             	movzbl %al,%eax
}
  1027ed:	c9                   	leave  
  1027ee:	c3                   	ret    

001027ef <sum>:
volatile struct ioapic *ioapic;


static uint8_t
sum(uint8_t * addr, int len)
{
  1027ef:	55                   	push   %ebp
  1027f0:	89 e5                	mov    %esp,%ebp
  1027f2:	83 ec 10             	sub    $0x10,%esp
	int i, sum;

	sum = 0;
  1027f5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (i = 0; i < len; i++)
  1027fc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  102803:	eb 13                	jmp    102818 <sum+0x29>
		sum += addr[i];
  102805:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102808:	03 45 08             	add    0x8(%ebp),%eax
  10280b:	0f b6 00             	movzbl (%eax),%eax
  10280e:	0f b6 c0             	movzbl %al,%eax
  102811:	01 45 fc             	add    %eax,-0x4(%ebp)
sum(uint8_t * addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
  102814:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  102818:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10281b:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10281e:	7c e5                	jl     102805 <sum+0x16>
		sum += addr[i];
	return sum;
  102820:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102823:	c9                   	leave  
  102824:	c3                   	ret    

00102825 <mpsearch1>:

//Look for an MP structure in the len bytes at addr.
static struct mp *
mpsearch1(uint8_t * addr, int len)
{
  102825:	55                   	push   %ebp
  102826:	89 e5                	mov    %esp,%ebp
  102828:	83 ec 28             	sub    $0x28,%esp
	uint8_t *e, *p;

	e = addr + len;
  10282b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10282e:	03 45 08             	add    0x8(%ebp),%eax
  102831:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (p = addr; p < e; p += sizeof(struct mp))
  102834:	8b 45 08             	mov    0x8(%ebp),%eax
  102837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10283a:	eb 3f                	jmp    10287b <mpsearch1+0x56>
		if (memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
  10283c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  102843:	00 
  102844:	c7 44 24 04 c8 62 10 	movl   $0x1062c8,0x4(%esp)
  10284b:	00 
  10284c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10284f:	89 04 24             	mov    %eax,(%esp)
  102852:	e8 45 2d 00 00       	call   10559c <memcmp>
  102857:	85 c0                	test   %eax,%eax
  102859:	75 1c                	jne    102877 <mpsearch1+0x52>
  10285b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  102862:	00 
  102863:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102866:	89 04 24             	mov    %eax,(%esp)
  102869:	e8 81 ff ff ff       	call   1027ef <sum>
  10286e:	84 c0                	test   %al,%al
  102870:	75 05                	jne    102877 <mpsearch1+0x52>
			return (struct mp *) p;
  102872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102875:	eb 11                	jmp    102888 <mpsearch1+0x63>
mpsearch1(uint8_t * addr, int len)
{
	uint8_t *e, *p;

	e = addr + len;
	for (p = addr; p < e; p += sizeof(struct mp))
  102877:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
  10287b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10287e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102881:	72 b9                	jb     10283c <mpsearch1+0x17>
		if (memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
			return (struct mp *) p;
	return 0;
  102883:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102888:	c9                   	leave  
  102889:	c3                   	ret    

0010288a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp *
mpsearch(void)
{
  10288a:	55                   	push   %ebp
  10288b:	89 e5                	mov    %esp,%ebp
  10288d:	83 ec 28             	sub    $0x28,%esp
	uint8_t          *bda;
	uint32_t            p;
	struct mp      *mp;

	bda = (uint8_t *) 0x400;
  102890:	c7 45 ec 00 04 00 00 	movl   $0x400,-0x14(%ebp)
	if ((p = ((bda[0x0F] << 8) | bda[0x0E]) << 4)) {
  102897:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10289a:	83 c0 0f             	add    $0xf,%eax
  10289d:	0f b6 00             	movzbl (%eax),%eax
  1028a0:	0f b6 c0             	movzbl %al,%eax
  1028a3:	89 c2                	mov    %eax,%edx
  1028a5:	c1 e2 08             	shl    $0x8,%edx
  1028a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1028ab:	83 c0 0e             	add    $0xe,%eax
  1028ae:	0f b6 00             	movzbl (%eax),%eax
  1028b1:	0f b6 c0             	movzbl %al,%eax
  1028b4:	09 d0                	or     %edx,%eax
  1028b6:	c1 e0 04             	shl    $0x4,%eax
  1028b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1028bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1028c0:	74 21                	je     1028e3 <mpsearch+0x59>
		if ((mp = mpsearch1((uint8_t *) p, 1024)))
  1028c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1028c5:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1028cc:	00 
  1028cd:	89 04 24             	mov    %eax,(%esp)
  1028d0:	e8 50 ff ff ff       	call   102825 <mpsearch1>
  1028d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1028d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1028dc:	74 50                	je     10292e <mpsearch+0xa4>
			return mp;
  1028de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028e1:	eb 5f                	jmp    102942 <mpsearch+0xb8>
	} else {
		p = ((bda[0x14] << 8) | bda[0x13]) * 1024;
  1028e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1028e6:	83 c0 14             	add    $0x14,%eax
  1028e9:	0f b6 00             	movzbl (%eax),%eax
  1028ec:	0f b6 c0             	movzbl %al,%eax
  1028ef:	89 c2                	mov    %eax,%edx
  1028f1:	c1 e2 08             	shl    $0x8,%edx
  1028f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1028f7:	83 c0 13             	add    $0x13,%eax
  1028fa:	0f b6 00             	movzbl (%eax),%eax
  1028fd:	0f b6 c0             	movzbl %al,%eax
  102900:	09 d0                	or     %edx,%eax
  102902:	c1 e0 0a             	shl    $0xa,%eax
  102905:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if ((mp = mpsearch1((uint8_t *) p - 1024, 1024)))
  102908:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10290b:	2d 00 04 00 00       	sub    $0x400,%eax
  102910:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  102917:	00 
  102918:	89 04 24             	mov    %eax,(%esp)
  10291b:	e8 05 ff ff ff       	call   102825 <mpsearch1>
  102920:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102923:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102927:	74 05                	je     10292e <mpsearch+0xa4>
			return mp;
  102929:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10292c:	eb 14                	jmp    102942 <mpsearch+0xb8>
	}
	return mpsearch1((uint8_t *) 0xF0000, 0x10000);
  10292e:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
  102935:	00 
  102936:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
  10293d:	e8 e3 fe ff ff       	call   102825 <mpsearch1>
}
  102942:	c9                   	leave  
  102943:	c3                   	ret    

00102944 <mpconfig>:
// don 't accept the default configurations (physaddr == 0).
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf *
mpconfig(struct mp **pmp) {
  102944:	55                   	push   %ebp
  102945:	89 e5                	mov    %esp,%ebp
  102947:	83 ec 28             	sub    $0x28,%esp
	struct mpconf  *conf;
	struct mp      *mp;

	if ((mp = mpsearch()) == 0 || mp->physaddr == 0)
  10294a:	e8 3b ff ff ff       	call   10288a <mpsearch>
  10294f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102952:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102956:	74 0a                	je     102962 <mpconfig+0x1e>
  102958:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10295b:	8b 40 04             	mov    0x4(%eax),%eax
  10295e:	85 c0                	test   %eax,%eax
  102960:	75 07                	jne    102969 <mpconfig+0x25>
		return 0;
  102962:	b8 00 00 00 00       	mov    $0x0,%eax
  102967:	eb 7b                	jmp    1029e4 <mpconfig+0xa0>
	conf = (struct mpconf *) mp->physaddr;
  102969:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10296c:	8b 40 04             	mov    0x4(%eax),%eax
  10296f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (memcmp(conf, "PCMP", 4) != 0)
  102972:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  102979:	00 
  10297a:	c7 44 24 04 cd 62 10 	movl   $0x1062cd,0x4(%esp)
  102981:	00 
  102982:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102985:	89 04 24             	mov    %eax,(%esp)
  102988:	e8 0f 2c 00 00       	call   10559c <memcmp>
  10298d:	85 c0                	test   %eax,%eax
  10298f:	74 07                	je     102998 <mpconfig+0x54>
		return 0;
  102991:	b8 00 00 00 00       	mov    $0x0,%eax
  102996:	eb 4c                	jmp    1029e4 <mpconfig+0xa0>
	if (conf->version != 1 && conf->version != 4)
  102998:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10299b:	0f b6 40 06          	movzbl 0x6(%eax),%eax
  10299f:	3c 01                	cmp    $0x1,%al
  1029a1:	74 12                	je     1029b5 <mpconfig+0x71>
  1029a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1029a6:	0f b6 40 06          	movzbl 0x6(%eax),%eax
  1029aa:	3c 04                	cmp    $0x4,%al
  1029ac:	74 07                	je     1029b5 <mpconfig+0x71>
		return 0;
  1029ae:	b8 00 00 00 00       	mov    $0x0,%eax
  1029b3:	eb 2f                	jmp    1029e4 <mpconfig+0xa0>
	if (sum((uint8_t *) conf, conf->length) != 0)
  1029b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1029b8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
  1029bc:	0f b7 d0             	movzwl %ax,%edx
  1029bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1029c2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1029c6:	89 04 24             	mov    %eax,(%esp)
  1029c9:	e8 21 fe ff ff       	call   1027ef <sum>
  1029ce:	84 c0                	test   %al,%al
  1029d0:	74 07                	je     1029d9 <mpconfig+0x95>
		return 0;
  1029d2:	b8 00 00 00 00       	mov    $0x0,%eax
  1029d7:	eb 0b                	jmp    1029e4 <mpconfig+0xa0>
       *pmp = mp;
  1029d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1029dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1029df:	89 10                	mov    %edx,(%eax)
	return conf;
  1029e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1029e4:	c9                   	leave  
  1029e5:	c3                   	ret    

001029e6 <mp_init>:

void
mp_init(void)
{
  1029e6:	55                   	push   %ebp
  1029e7:	89 e5                	mov    %esp,%ebp
  1029e9:	83 ec 48             	sub    $0x48,%esp
	struct mp      *mp;
	struct mpconf  *conf;
	struct mpproc  *proc;
	struct mpioapic *mpio;

	if (!cpu_onboot())	// only do once, on the boot CPU
  1029ec:	e8 e6 fd ff ff       	call   1027d7 <cpu_onboot>
  1029f1:	85 c0                	test   %eax,%eax
  1029f3:	0f 84 72 01 00 00    	je     102b6b <mp_init+0x185>
		return;

	if ((conf = mpconfig(&mp)) == 0)
  1029f9:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1029fc:	89 04 24             	mov    %eax,(%esp)
  1029ff:	e8 40 ff ff ff       	call   102944 <mpconfig>
  102a04:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  102a07:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  102a0b:	0f 84 5d 01 00 00    	je     102b6e <mp_init+0x188>
		return; // Not a multiprocessor machine - just use boot CPU.

	ismp = 1;
  102a11:	c7 05 90 e2 10 00 01 	movl   $0x1,0x10e290
  102a18:	00 00 00 
	lapic = (uint32_t *) conf->lapicaddr;
  102a1b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102a1e:	8b 40 24             	mov    0x24(%eax),%eax
  102a21:	a3 48 e9 10 00       	mov    %eax,0x10e948
	for (p = (uint8_t *) (conf + 1), e = (uint8_t *) conf + conf->length;
  102a26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102a29:	83 c0 2c             	add    $0x2c,%eax
  102a2c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  102a2f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102a32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102a35:	0f b7 40 04          	movzwl 0x4(%eax),%eax
  102a39:	0f b7 c0             	movzwl %ax,%eax
  102a3c:	8d 04 02             	lea    (%edx,%eax,1),%eax
  102a3f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102a42:	e9 cc 00 00 00       	jmp    102b13 <mp_init+0x12d>
			p < e;) {
		switch (*p) {
  102a47:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102a4a:	0f b6 00             	movzbl (%eax),%eax
  102a4d:	0f b6 c0             	movzbl %al,%eax
  102a50:	83 f8 04             	cmp    $0x4,%eax
  102a53:	0f 87 90 00 00 00    	ja     102ae9 <mp_init+0x103>
  102a59:	8b 04 85 00 63 10 00 	mov    0x106300(,%eax,4),%eax
  102a60:	ff e0                	jmp    *%eax
		case MPPROC:
			proc = (struct mpproc *) p;
  102a62:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102a65:	89 45 d8             	mov    %eax,-0x28(%ebp)
			p += sizeof(struct mpproc);
  102a68:	83 45 cc 14          	addl   $0x14,-0x34(%ebp)
			if (!(proc->flags & MPENAB))
  102a6c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102a6f:	0f b6 40 03          	movzbl 0x3(%eax),%eax
  102a73:	0f b6 c0             	movzbl %al,%eax
  102a76:	83 e0 01             	and    $0x1,%eax
  102a79:	85 c0                	test   %eax,%eax
  102a7b:	0f 84 91 00 00 00    	je     102b12 <mp_init+0x12c>
				continue;	// processor disabled

			// Get a cpu struct and kernel stack for this CPU.
			cpu *c = (proc->flags & MPBOOT)
  102a81:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102a84:	0f b6 40 03          	movzbl 0x3(%eax),%eax
  102a88:	0f b6 c0             	movzbl %al,%eax
  102a8b:	83 e0 02             	and    $0x2,%eax
					? &cpu_boot : cpu_alloc();
  102a8e:	85 c0                	test   %eax,%eax
  102a90:	75 07                	jne    102a99 <mp_init+0xb3>
  102a92:	e8 d9 e8 ff ff       	call   101370 <cpu_alloc>
  102a97:	eb 05                	jmp    102a9e <mp_init+0xb8>
  102a99:	b8 00 70 10 00       	mov    $0x107000,%eax
  102a9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
			c->id = proc->apicid;
  102aa1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102aa4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  102aa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102aab:	88 90 ac 00 00 00    	mov    %dl,0xac(%eax)
			ncpu++;
  102ab1:	a1 94 e2 10 00       	mov    0x10e294,%eax
  102ab6:	83 c0 01             	add    $0x1,%eax
  102ab9:	a3 94 e2 10 00       	mov    %eax,0x10e294
			continue;
  102abe:	eb 53                	jmp    102b13 <mp_init+0x12d>
		case MPIOAPIC:
			mpio = (struct mpioapic *) p;
  102ac0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102ac3:	89 45 dc             	mov    %eax,-0x24(%ebp)
			p += sizeof(struct mpioapic);
  102ac6:	83 45 cc 08          	addl   $0x8,-0x34(%ebp)
			ioapicid = mpio->apicno;
  102aca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102acd:	0f b6 40 01          	movzbl 0x1(%eax),%eax
  102ad1:	a2 88 e2 10 00       	mov    %al,0x10e288
			ioapic = (struct ioapic *) mpio->addr;
  102ad6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102ad9:	8b 40 04             	mov    0x4(%eax),%eax
  102adc:	a3 8c e2 10 00       	mov    %eax,0x10e28c
			continue;
  102ae1:	eb 30                	jmp    102b13 <mp_init+0x12d>
		case MPBUS:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
  102ae3:	83 45 cc 08          	addl   $0x8,-0x34(%ebp)
			continue;
  102ae7:	eb 2a                	jmp    102b13 <mp_init+0x12d>
		default:
			panic("mpinit: unknown config type %x\n", *p);
  102ae9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102aec:	0f b6 00             	movzbl (%eax),%eax
  102aef:	0f b6 c0             	movzbl %al,%eax
  102af2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102af6:	c7 44 24 08 d4 62 10 	movl   $0x1062d4,0x8(%esp)
  102afd:	00 
  102afe:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
  102b05:	00 
  102b06:	c7 04 24 f4 62 10 00 	movl   $0x1062f4,(%esp)
  102b0d:	e8 fa d8 ff ff       	call   10040c <debug_panic>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *) p;
			p += sizeof(struct mpproc);
			if (!(proc->flags & MPENAB))
				continue;	// processor disabled
  102b12:	90                   	nop
	if ((conf = mpconfig(&mp)) == 0)
		return; // Not a multiprocessor machine - just use boot CPU.

	ismp = 1;
	lapic = (uint32_t *) conf->lapicaddr;
	for (p = (uint8_t *) (conf + 1), e = (uint8_t *) conf + conf->length;
  102b13:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102b16:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102b19:	0f 82 28 ff ff ff    	jb     102a47 <mp_init+0x61>
			continue;
		default:
			panic("mpinit: unknown config type %x\n", *p);
		}
	}
	if (mp->imcrp) {
  102b1f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102b22:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
  102b26:	84 c0                	test   %al,%al
  102b28:	74 45                	je     102b6f <mp_init+0x189>
  102b2a:	c7 45 e8 22 00 00 00 	movl   $0x22,-0x18(%ebp)
  102b31:	c6 45 e7 70          	movb   $0x70,-0x19(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  102b35:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  102b39:	8b 55 e8             	mov    -0x18(%ebp),%edx
  102b3c:	ee                   	out    %al,(%dx)
  102b3d:	c7 45 ec 23 00 00 00 	movl   $0x23,-0x14(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  102b44:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102b47:	89 c2                	mov    %eax,%edx
  102b49:	ec                   	in     (%dx),%al
  102b4a:	88 45 f2             	mov    %al,-0xe(%ebp)
	return data;
  102b4d:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
		// Bochs doesn 't support IMCR, so this doesn' t run on Bochs.
		// But it would on real hardware.
		outb(0x22, 0x70);		// Select IMCR
		outb(0x23, inb(0x23) | 1);	// Mask external interrupts.
  102b51:	83 c8 01             	or     $0x1,%eax
  102b54:	0f b6 c0             	movzbl %al,%eax
  102b57:	c7 45 f4 23 00 00 00 	movl   $0x23,-0xc(%ebp)
  102b5e:	88 45 f3             	mov    %al,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  102b61:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  102b65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102b68:	ee                   	out    %al,(%dx)
  102b69:	eb 04                	jmp    102b6f <mp_init+0x189>
	struct mpconf  *conf;
	struct mpproc  *proc;
	struct mpioapic *mpio;

	if (!cpu_onboot())	// only do once, on the boot CPU
		return;
  102b6b:	90                   	nop
  102b6c:	eb 01                	jmp    102b6f <mp_init+0x189>

	if ((conf = mpconfig(&mp)) == 0)
		return; // Not a multiprocessor machine - just use boot CPU.
  102b6e:	90                   	nop
		// Bochs doesn 't support IMCR, so this doesn' t run on Bochs.
		// But it would on real hardware.
		outb(0x22, 0x70);		// Select IMCR
		outb(0x23, inb(0x23) | 1);	// Mask external interrupts.
	}
}
  102b6f:	c9                   	leave  
  102b70:	c3                   	ret    
  102b71:	90                   	nop
  102b72:	90                   	nop
  102b73:	90                   	nop

00102b74 <xchg>:
}

// Atomically set *addr to newval and return the old value of *addr.
static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
  102b74:	55                   	push   %ebp
  102b75:	89 e5                	mov    %esp,%ebp
  102b77:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
  102b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  102b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  102b83:	f0 87 02             	lock xchg %eax,(%edx)
  102b86:	89 45 fc             	mov    %eax,-0x4(%ebp)
	       "+m" (*addr), "=a" (result) :
	       "1" (newval) :
	       "cc");
	return result;
  102b89:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102b8c:	c9                   	leave  
  102b8d:	c3                   	ret    

00102b8e <pause>:
	return result;
}

static inline void
pause(void)
{
  102b8e:	55                   	push   %ebp
  102b8f:	89 e5                	mov    %esp,%ebp
	asm volatile("pause" : : : "memory");
  102b91:	f3 90                	pause  
}
  102b93:	5d                   	pop    %ebp
  102b94:	c3                   	ret    

00102b95 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  102b95:	55                   	push   %ebp
  102b96:	89 e5                	mov    %esp,%ebp
  102b98:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  102b9b:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  102b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  102ba1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ba4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ba7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102bac:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  102baf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102bb2:	8b 80 b8 00 00 00    	mov    0xb8(%eax),%eax
  102bb8:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  102bbd:	74 24                	je     102be3 <cpu_cur+0x4e>
  102bbf:	c7 44 24 0c 14 63 10 	movl   $0x106314,0xc(%esp)
  102bc6:	00 
  102bc7:	c7 44 24 08 2a 63 10 	movl   $0x10632a,0x8(%esp)
  102bce:	00 
  102bcf:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  102bd6:	00 
  102bd7:	c7 04 24 3f 63 10 00 	movl   $0x10633f,(%esp)
  102bde:	e8 29 d8 ff ff       	call   10040c <debug_panic>
	return c;
  102be3:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  102be6:	c9                   	leave  
  102be7:	c3                   	ret    

00102be8 <spinlock_init_>:
#include <kern/cons.h>


void
spinlock_init_(struct spinlock *lk, const char *file, int line)
{
  102be8:	55                   	push   %ebp
  102be9:	89 e5                	mov    %esp,%ebp
	lk->file = file;
  102beb:	8b 45 08             	mov    0x8(%ebp),%eax
  102bee:	8b 55 0c             	mov    0xc(%ebp),%edx
  102bf1:	89 50 04             	mov    %edx,0x4(%eax)
	lk->line = line;
  102bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  102bf7:	8b 55 10             	mov    0x10(%ebp),%edx
  102bfa:	89 50 08             	mov    %edx,0x8(%eax)
	lk->locked = 0;
  102bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  102c00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	lk->cpu = 0;
  102c06:	8b 45 08             	mov    0x8(%ebp),%eax
  102c09:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  102c10:	5d                   	pop    %ebp
  102c11:	c3                   	ret    

00102c12 <spinlock_acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spinlock_acquire(struct spinlock *lk)
{
  102c12:	55                   	push   %ebp
  102c13:	89 e5                	mov    %esp,%ebp
  102c15:	83 ec 28             	sub    $0x28,%esp
	if (spinlock_holding(lk))
  102c18:	8b 45 08             	mov    0x8(%ebp),%eax
  102c1b:	89 04 24             	mov    %eax,(%esp)
  102c1e:	e8 be 00 00 00       	call   102ce1 <spinlock_holding>
  102c23:	85 c0                	test   %eax,%eax
  102c25:	74 23                	je     102c4a <spinlock_acquire+0x38>
		panic("recursive spinlock acquire");
  102c27:	c7 44 24 08 4c 63 10 	movl   $0x10634c,0x8(%esp)
  102c2e:	00 
  102c2f:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  102c36:	00 
  102c37:	c7 04 24 67 63 10 00 	movl   $0x106367,(%esp)
  102c3e:	e8 c9 d7 ff ff       	call   10040c <debug_panic>
	while (xchg(&lk->locked, 1) != 0)
		pause();
  102c43:	e8 46 ff ff ff       	call   102b8e <pause>
  102c48:	eb 01                	jmp    102c4b <spinlock_acquire+0x39>
void
spinlock_acquire(struct spinlock *lk)
{
	if (spinlock_holding(lk))
		panic("recursive spinlock acquire");
	while (xchg(&lk->locked, 1) != 0)
  102c4a:	90                   	nop
  102c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  102c4e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  102c55:	00 
  102c56:	89 04 24             	mov    %eax,(%esp)
  102c59:	e8 16 ff ff ff       	call   102b74 <xchg>
  102c5e:	85 c0                	test   %eax,%eax
  102c60:	75 e1                	jne    102c43 <spinlock_acquire+0x31>
		pause();
	lk->cpu = cpu_cur();
  102c62:	e8 2e ff ff ff       	call   102b95 <cpu_cur>
  102c67:	8b 55 08             	mov    0x8(%ebp),%edx
  102c6a:	89 42 0c             	mov    %eax,0xc(%edx)
	debug_trace(read_ebp(), lk->eips);
  102c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  102c70:	8d 50 10             	lea    0x10(%eax),%edx

static gcc_inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=rm" (ebp));
  102c73:	89 6d f4             	mov    %ebp,-0xc(%ebp)
        return ebp;
  102c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c79:	89 54 24 04          	mov    %edx,0x4(%esp)
  102c7d:	89 04 24             	mov    %eax,(%esp)
  102c80:	e8 8f d8 ff ff       	call   100514 <debug_trace>
}
  102c85:	c9                   	leave  
  102c86:	c3                   	ret    

00102c87 <spinlock_release>:

// Release the lock.
void
spinlock_release(struct spinlock *lk)
{
  102c87:	55                   	push   %ebp
  102c88:	89 e5                	mov    %esp,%ebp
  102c8a:	83 ec 18             	sub    $0x18,%esp
	if (!spinlock_holding(lk))
  102c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  102c90:	89 04 24             	mov    %eax,(%esp)
  102c93:	e8 49 00 00 00       	call   102ce1 <spinlock_holding>
  102c98:	85 c0                	test   %eax,%eax
  102c9a:	75 1c                	jne    102cb8 <spinlock_release+0x31>
		panic("spinlock_release");
  102c9c:	c7 44 24 08 77 63 10 	movl   $0x106377,0x8(%esp)
  102ca3:	00 
  102ca4:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  102cab:	00 
  102cac:	c7 04 24 67 63 10 00 	movl   $0x106367,(%esp)
  102cb3:	e8 54 d7 ff ff       	call   10040c <debug_panic>
	
	lk->eips[0] = 0;
  102cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  102cbb:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
	lk->cpu = 0;
  102cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  102cc5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)

	xchg(&lk->locked, 0);
  102ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  102ccf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102cd6:	00 
  102cd7:	89 04 24             	mov    %eax,(%esp)
  102cda:	e8 95 fe ff ff       	call   102b74 <xchg>
}
  102cdf:	c9                   	leave  
  102ce0:	c3                   	ret    

00102ce1 <spinlock_holding>:

// Check whether this cpu is holding the lock.
int
spinlock_holding(spinlock *lock)
{
  102ce1:	55                   	push   %ebp
  102ce2:	89 e5                	mov    %esp,%ebp
  102ce4:	53                   	push   %ebx
  102ce5:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == cpu_cur();
  102ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  102ceb:	8b 00                	mov    (%eax),%eax
  102ced:	85 c0                	test   %eax,%eax
  102cef:	74 16                	je     102d07 <spinlock_holding+0x26>
  102cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  102cf4:	8b 58 0c             	mov    0xc(%eax),%ebx
  102cf7:	e8 99 fe ff ff       	call   102b95 <cpu_cur>
  102cfc:	39 c3                	cmp    %eax,%ebx
  102cfe:	75 07                	jne    102d07 <spinlock_holding+0x26>
  102d00:	b8 01 00 00 00       	mov    $0x1,%eax
  102d05:	eb 05                	jmp    102d0c <spinlock_holding+0x2b>
  102d07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102d0c:	83 c4 04             	add    $0x4,%esp
  102d0f:	5b                   	pop    %ebx
  102d10:	5d                   	pop    %ebp
  102d11:	c3                   	ret    

00102d12 <spinlock_godeep>:
// Function that simply recurses to a specified depth.
// The useless return value and volatile parameter are
// so GCC doesn't collapse it via tail-call elimination.
int gcc_noinline
spinlock_godeep(volatile int depth, spinlock* lk)
{
  102d12:	55                   	push   %ebp
  102d13:	89 e5                	mov    %esp,%ebp
  102d15:	83 ec 18             	sub    $0x18,%esp
	if (depth==0) { spinlock_acquire(lk); return 1; }
  102d18:	8b 45 08             	mov    0x8(%ebp),%eax
  102d1b:	85 c0                	test   %eax,%eax
  102d1d:	75 12                	jne    102d31 <spinlock_godeep+0x1f>
  102d1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d22:	89 04 24             	mov    %eax,(%esp)
  102d25:	e8 e8 fe ff ff       	call   102c12 <spinlock_acquire>
  102d2a:	b8 01 00 00 00       	mov    $0x1,%eax
  102d2f:	eb 1b                	jmp    102d4c <spinlock_godeep+0x3a>
	else return spinlock_godeep(depth-1, lk) * depth;
  102d31:	8b 45 08             	mov    0x8(%ebp),%eax
  102d34:	8d 50 ff             	lea    -0x1(%eax),%edx
  102d37:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d3e:	89 14 24             	mov    %edx,(%esp)
  102d41:	e8 cc ff ff ff       	call   102d12 <spinlock_godeep>
  102d46:	8b 55 08             	mov    0x8(%ebp),%edx
  102d49:	0f af c2             	imul   %edx,%eax
}
  102d4c:	c9                   	leave  
  102d4d:	c3                   	ret    

00102d4e <spinlock_check>:

void spinlock_check()
{
  102d4e:	55                   	push   %ebp
  102d4f:	89 e5                	mov    %esp,%ebp
  102d51:	57                   	push   %edi
  102d52:	56                   	push   %esi
  102d53:	53                   	push   %ebx
  102d54:	83 ec 5c             	sub    $0x5c,%esp
  102d57:	89 e0                	mov    %esp,%eax
  102d59:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	const int NUMLOCKS=10;
  102d5c:	c7 45 d0 0a 00 00 00 	movl   $0xa,-0x30(%ebp)
	const int NUMRUNS=5;
  102d63:	c7 45 d4 05 00 00 00 	movl   $0x5,-0x2c(%ebp)
	int i,j,run;
	const char* file = "spinlock_check";
  102d6a:	c7 45 e4 88 63 10 00 	movl   $0x106388,-0x1c(%ebp)
	spinlock locks[NUMLOCKS];
  102d71:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102d74:	83 e8 01             	sub    $0x1,%eax
  102d77:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102d7a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102d7d:	ba 00 00 00 00       	mov    $0x0,%edx
  102d82:	89 c1                	mov    %eax,%ecx
  102d84:	80 e5 ff             	and    $0xff,%ch
  102d87:	89 d3                	mov    %edx,%ebx
  102d89:	83 e3 0f             	and    $0xf,%ebx
  102d8c:	89 c8                	mov    %ecx,%eax
  102d8e:	89 da                	mov    %ebx,%edx
  102d90:	69 da c0 01 00 00    	imul   $0x1c0,%edx,%ebx
  102d96:	6b c8 00             	imul   $0x0,%eax,%ecx
  102d99:	01 cb                	add    %ecx,%ebx
  102d9b:	b9 c0 01 00 00       	mov    $0x1c0,%ecx
  102da0:	f7 e1                	mul    %ecx
  102da2:	01 d3                	add    %edx,%ebx
  102da4:	89 da                	mov    %ebx,%edx
  102da6:	89 c6                	mov    %eax,%esi
  102da8:	83 e6 ff             	and    $0xffffffff,%esi
  102dab:	89 d7                	mov    %edx,%edi
  102dad:	83 e7 0f             	and    $0xf,%edi
  102db0:	89 f0                	mov    %esi,%eax
  102db2:	89 fa                	mov    %edi,%edx
  102db4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102db7:	c1 e0 03             	shl    $0x3,%eax
  102dba:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102dbd:	ba 00 00 00 00       	mov    $0x0,%edx
  102dc2:	89 c1                	mov    %eax,%ecx
  102dc4:	80 e5 ff             	and    $0xff,%ch
  102dc7:	89 4d b8             	mov    %ecx,-0x48(%ebp)
  102dca:	89 d3                	mov    %edx,%ebx
  102dcc:	83 e3 0f             	and    $0xf,%ebx
  102dcf:	89 5d bc             	mov    %ebx,-0x44(%ebp)
  102dd2:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102dd5:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102dd8:	69 ca c0 01 00 00    	imul   $0x1c0,%edx,%ecx
  102dde:	6b d8 00             	imul   $0x0,%eax,%ebx
  102de1:	01 d9                	add    %ebx,%ecx
  102de3:	bb c0 01 00 00       	mov    $0x1c0,%ebx
  102de8:	f7 e3                	mul    %ebx
  102dea:	01 d1                	add    %edx,%ecx
  102dec:	89 ca                	mov    %ecx,%edx
  102dee:	89 c1                	mov    %eax,%ecx
  102df0:	80 e5 ff             	and    $0xff,%ch
  102df3:	89 4d b0             	mov    %ecx,-0x50(%ebp)
  102df6:	89 d3                	mov    %edx,%ebx
  102df8:	83 e3 0f             	and    $0xf,%ebx
  102dfb:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
  102dfe:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102e01:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102e04:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102e07:	c1 e0 03             	shl    $0x3,%eax
  102e0a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  102e11:	89 d1                	mov    %edx,%ecx
  102e13:	29 c1                	sub    %eax,%ecx
  102e15:	89 c8                	mov    %ecx,%eax
  102e17:	83 c0 0f             	add    $0xf,%eax
  102e1a:	83 c0 0f             	add    $0xf,%eax
  102e1d:	c1 e8 04             	shr    $0x4,%eax
  102e20:	c1 e0 04             	shl    $0x4,%eax
  102e23:	29 c4                	sub    %eax,%esp
  102e25:	8d 44 24 10          	lea    0x10(%esp),%eax
  102e29:	83 c0 0f             	add    $0xf,%eax
  102e2c:	c1 e8 04             	shr    $0x4,%eax
  102e2f:	c1 e0 04             	shl    $0x4,%eax
  102e32:	89 45 cc             	mov    %eax,-0x34(%ebp)

	// Initialize the locks
	for(i=0;i<NUMLOCKS;i++) spinlock_init_(&locks[i], file, 0);
  102e35:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  102e3c:	eb 33                	jmp    102e71 <spinlock_check+0x123>
  102e3e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102e41:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102e44:	c1 e0 03             	shl    $0x3,%eax
  102e47:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
  102e4e:	89 cb                	mov    %ecx,%ebx
  102e50:	29 c3                	sub    %eax,%ebx
  102e52:	89 d8                	mov    %ebx,%eax
  102e54:	01 c2                	add    %eax,%edx
  102e56:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  102e5d:	00 
  102e5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102e61:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e65:	89 14 24             	mov    %edx,(%esp)
  102e68:	e8 7b fd ff ff       	call   102be8 <spinlock_init_>
  102e6d:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
  102e71:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102e74:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102e77:	7c c5                	jl     102e3e <spinlock_check+0xf0>
	// Make sure that all locks have CPU set to NULL initially
	for(i=0;i<NUMLOCKS;i++) assert(locks[i].cpu==NULL);
  102e79:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  102e80:	eb 46                	jmp    102ec8 <spinlock_check+0x17a>
  102e82:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102e85:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  102e88:	c1 e0 03             	shl    $0x3,%eax
  102e8b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  102e92:	29 c2                	sub    %eax,%edx
  102e94:	8d 04 11             	lea    (%ecx,%edx,1),%eax
  102e97:	83 c0 0c             	add    $0xc,%eax
  102e9a:	8b 00                	mov    (%eax),%eax
  102e9c:	85 c0                	test   %eax,%eax
  102e9e:	74 24                	je     102ec4 <spinlock_check+0x176>
  102ea0:	c7 44 24 0c 97 63 10 	movl   $0x106397,0xc(%esp)
  102ea7:	00 
  102ea8:	c7 44 24 08 2a 63 10 	movl   $0x10632a,0x8(%esp)
  102eaf:	00 
  102eb0:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  102eb7:	00 
  102eb8:	c7 04 24 67 63 10 00 	movl   $0x106367,(%esp)
  102ebf:	e8 48 d5 ff ff       	call   10040c <debug_panic>
  102ec4:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
  102ec8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102ecb:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102ece:	7c b2                	jl     102e82 <spinlock_check+0x134>
	// Make sure that all locks have the correct debug info.
	for(i=0;i<NUMLOCKS;i++) assert(locks[i].file==file);
  102ed0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  102ed7:	eb 47                	jmp    102f20 <spinlock_check+0x1d2>
  102ed9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102edc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  102edf:	c1 e0 03             	shl    $0x3,%eax
  102ee2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  102ee9:	29 c2                	sub    %eax,%edx
  102eeb:	8d 04 11             	lea    (%ecx,%edx,1),%eax
  102eee:	83 c0 04             	add    $0x4,%eax
  102ef1:	8b 00                	mov    (%eax),%eax
  102ef3:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  102ef6:	74 24                	je     102f1c <spinlock_check+0x1ce>
  102ef8:	c7 44 24 0c aa 63 10 	movl   $0x1063aa,0xc(%esp)
  102eff:	00 
  102f00:	c7 44 24 08 2a 63 10 	movl   $0x10632a,0x8(%esp)
  102f07:	00 
  102f08:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  102f0f:	00 
  102f10:	c7 04 24 67 63 10 00 	movl   $0x106367,(%esp)
  102f17:	e8 f0 d4 ff ff       	call   10040c <debug_panic>
  102f1c:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
  102f20:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102f23:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102f26:	7c b1                	jl     102ed9 <spinlock_check+0x18b>

	for (run=0;run<NUMRUNS;run++) 
  102f28:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102f2f:	e9 12 03 00 00       	jmp    103246 <spinlock_check+0x4f8>
	{
		// Lock all locks
		for(i=0;i<NUMLOCKS;i++)
  102f34:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  102f3b:	eb 2c                	jmp    102f69 <spinlock_check+0x21b>
			spinlock_godeep(i, &locks[i]);
  102f3d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102f40:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102f43:	c1 e0 03             	shl    $0x3,%eax
  102f46:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
  102f4d:	89 cb                	mov    %ecx,%ebx
  102f4f:	29 c3                	sub    %eax,%ebx
  102f51:	89 d8                	mov    %ebx,%eax
  102f53:	8d 04 02             	lea    (%edx,%eax,1),%eax
  102f56:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f5a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102f5d:	89 04 24             	mov    %eax,(%esp)
  102f60:	e8 ad fd ff ff       	call   102d12 <spinlock_godeep>
	for(i=0;i<NUMLOCKS;i++) assert(locks[i].file==file);

	for (run=0;run<NUMRUNS;run++) 
	{
		// Lock all locks
		for(i=0;i<NUMLOCKS;i++)
  102f65:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
  102f69:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102f6c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102f6f:	7c cc                	jl     102f3d <spinlock_check+0x1ef>
			spinlock_godeep(i, &locks[i]);

		// Make sure that all locks have the right CPU
		for(i=0;i<NUMLOCKS;i++)
  102f71:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  102f78:	eb 4b                	jmp    102fc5 <spinlock_check+0x277>
			assert(locks[i].cpu == cpu_cur());
  102f7a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102f7d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  102f80:	c1 e0 03             	shl    $0x3,%eax
  102f83:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  102f8a:	29 c2                	sub    %eax,%edx
  102f8c:	8d 04 11             	lea    (%ecx,%edx,1),%eax
  102f8f:	83 c0 0c             	add    $0xc,%eax
  102f92:	8b 18                	mov    (%eax),%ebx
  102f94:	e8 fc fb ff ff       	call   102b95 <cpu_cur>
  102f99:	39 c3                	cmp    %eax,%ebx
  102f9b:	74 24                	je     102fc1 <spinlock_check+0x273>
  102f9d:	c7 44 24 0c be 63 10 	movl   $0x1063be,0xc(%esp)
  102fa4:	00 
  102fa5:	c7 44 24 08 2a 63 10 	movl   $0x10632a,0x8(%esp)
  102fac:	00 
  102fad:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  102fb4:	00 
  102fb5:	c7 04 24 67 63 10 00 	movl   $0x106367,(%esp)
  102fbc:	e8 4b d4 ff ff       	call   10040c <debug_panic>
		// Lock all locks
		for(i=0;i<NUMLOCKS;i++)
			spinlock_godeep(i, &locks[i]);

		// Make sure that all locks have the right CPU
		for(i=0;i<NUMLOCKS;i++)
  102fc1:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
  102fc5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102fc8:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102fcb:	7c ad                	jl     102f7a <spinlock_check+0x22c>
			assert(locks[i].cpu == cpu_cur());
		// Make sure that all locks have holding correctly implemented.
		for(i=0;i<NUMLOCKS;i++)
  102fcd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  102fd4:	eb 4d                	jmp    103023 <spinlock_check+0x2d5>
			assert(spinlock_holding(&locks[i]) != 0);
  102fd6:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102fd9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102fdc:	c1 e0 03             	shl    $0x3,%eax
  102fdf:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
  102fe6:	89 cb                	mov    %ecx,%ebx
  102fe8:	29 c3                	sub    %eax,%ebx
  102fea:	89 d8                	mov    %ebx,%eax
  102fec:	8d 04 02             	lea    (%edx,%eax,1),%eax
  102fef:	89 04 24             	mov    %eax,(%esp)
  102ff2:	e8 ea fc ff ff       	call   102ce1 <spinlock_holding>
  102ff7:	85 c0                	test   %eax,%eax
  102ff9:	75 24                	jne    10301f <spinlock_check+0x2d1>
  102ffb:	c7 44 24 0c d8 63 10 	movl   $0x1063d8,0xc(%esp)
  103002:	00 
  103003:	c7 44 24 08 2a 63 10 	movl   $0x10632a,0x8(%esp)
  10300a:	00 
  10300b:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  103012:	00 
  103013:	c7 04 24 67 63 10 00 	movl   $0x106367,(%esp)
  10301a:	e8 ed d3 ff ff       	call   10040c <debug_panic>

		// Make sure that all locks have the right CPU
		for(i=0;i<NUMLOCKS;i++)
			assert(locks[i].cpu == cpu_cur());
		// Make sure that all locks have holding correctly implemented.
		for(i=0;i<NUMLOCKS;i++)
  10301f:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
  103023:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103026:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  103029:	7c ab                	jl     102fd6 <spinlock_check+0x288>
			assert(spinlock_holding(&locks[i]) != 0);
		// Make sure that top i frames are somewhere in godeep.
		for(i=0;i<NUMLOCKS;i++) 
  10302b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  103032:	e9 bd 00 00 00       	jmp    1030f4 <spinlock_check+0x3a6>
		{
			for(j=0; j<=i && j < DEBUG_TRACEFRAMES ; j++) 
  103037:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10303e:	e9 9b 00 00 00       	jmp    1030de <spinlock_check+0x390>
			{
				assert(locks[i].eips[j] >=
  103043:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103046:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  103049:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  10304c:	01 c0                	add    %eax,%eax
  10304e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  103055:	29 c2                	sub    %eax,%edx
  103057:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
  10305a:	83 c0 04             	add    $0x4,%eax
  10305d:	8b 14 81             	mov    (%ecx,%eax,4),%edx
  103060:	b8 12 2d 10 00       	mov    $0x102d12,%eax
  103065:	39 c2                	cmp    %eax,%edx
  103067:	73 24                	jae    10308d <spinlock_check+0x33f>
  103069:	c7 44 24 0c fc 63 10 	movl   $0x1063fc,0xc(%esp)
  103070:	00 
  103071:	c7 44 24 08 2a 63 10 	movl   $0x10632a,0x8(%esp)
  103078:	00 
  103079:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
  103080:	00 
  103081:	c7 04 24 67 63 10 00 	movl   $0x106367,(%esp)
  103088:	e8 7f d3 ff ff       	call   10040c <debug_panic>
					(uint32_t)spinlock_godeep);
				assert(locks[i].eips[j] <
  10308d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103090:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  103093:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  103096:	01 c0                	add    %eax,%eax
  103098:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  10309f:	29 c2                	sub    %eax,%edx
  1030a1:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
  1030a4:	83 c0 04             	add    $0x4,%eax
  1030a7:	8b 04 81             	mov    (%ecx,%eax,4),%eax
  1030aa:	ba 12 2d 10 00       	mov    $0x102d12,%edx
  1030af:	83 c2 64             	add    $0x64,%edx
  1030b2:	39 d0                	cmp    %edx,%eax
  1030b4:	72 24                	jb     1030da <spinlock_check+0x38c>
  1030b6:	c7 44 24 0c 2c 64 10 	movl   $0x10642c,0xc(%esp)
  1030bd:	00 
  1030be:	c7 44 24 08 2a 63 10 	movl   $0x10632a,0x8(%esp)
  1030c5:	00 
  1030c6:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  1030cd:	00 
  1030ce:	c7 04 24 67 63 10 00 	movl   $0x106367,(%esp)
  1030d5:	e8 32 d3 ff ff       	call   10040c <debug_panic>
		for(i=0;i<NUMLOCKS;i++)
			assert(spinlock_holding(&locks[i]) != 0);
		// Make sure that top i frames are somewhere in godeep.
		for(i=0;i<NUMLOCKS;i++) 
		{
			for(j=0; j<=i && j < DEBUG_TRACEFRAMES ; j++) 
  1030da:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  1030de:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1030e1:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  1030e4:	7f 0a                	jg     1030f0 <spinlock_check+0x3a2>
  1030e6:	83 7d dc 09          	cmpl   $0x9,-0x24(%ebp)
  1030ea:	0f 8e 53 ff ff ff    	jle    103043 <spinlock_check+0x2f5>
			assert(locks[i].cpu == cpu_cur());
		// Make sure that all locks have holding correctly implemented.
		for(i=0;i<NUMLOCKS;i++)
			assert(spinlock_holding(&locks[i]) != 0);
		// Make sure that top i frames are somewhere in godeep.
		for(i=0;i<NUMLOCKS;i++) 
  1030f0:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
  1030f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1030f7:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1030fa:	0f 8c 37 ff ff ff    	jl     103037 <spinlock_check+0x2e9>
					(uint32_t)spinlock_godeep+100);
			}
		}

		// Release all locks
		for(i=0;i<NUMLOCKS;i++) spinlock_release(&locks[i]);
  103100:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  103107:	eb 25                	jmp    10312e <spinlock_check+0x3e0>
  103109:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10310c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10310f:	c1 e0 03             	shl    $0x3,%eax
  103112:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
  103119:	89 cb                	mov    %ecx,%ebx
  10311b:	29 c3                	sub    %eax,%ebx
  10311d:	89 d8                	mov    %ebx,%eax
  10311f:	8d 04 02             	lea    (%edx,%eax,1),%eax
  103122:	89 04 24             	mov    %eax,(%esp)
  103125:	e8 5d fb ff ff       	call   102c87 <spinlock_release>
  10312a:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
  10312e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103131:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  103134:	7c d3                	jl     103109 <spinlock_check+0x3bb>
		// Make sure that the CPU has been cleared
		for(i=0;i<NUMLOCKS;i++) assert(locks[i].cpu == NULL);
  103136:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  10313d:	eb 46                	jmp    103185 <spinlock_check+0x437>
  10313f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103142:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  103145:	c1 e0 03             	shl    $0x3,%eax
  103148:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  10314f:	29 c2                	sub    %eax,%edx
  103151:	8d 04 11             	lea    (%ecx,%edx,1),%eax
  103154:	83 c0 0c             	add    $0xc,%eax
  103157:	8b 00                	mov    (%eax),%eax
  103159:	85 c0                	test   %eax,%eax
  10315b:	74 24                	je     103181 <spinlock_check+0x433>
  10315d:	c7 44 24 0c 5d 64 10 	movl   $0x10645d,0xc(%esp)
  103164:	00 
  103165:	c7 44 24 08 2a 63 10 	movl   $0x10632a,0x8(%esp)
  10316c:	00 
  10316d:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
  103174:	00 
  103175:	c7 04 24 67 63 10 00 	movl   $0x106367,(%esp)
  10317c:	e8 8b d2 ff ff       	call   10040c <debug_panic>
  103181:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
  103185:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103188:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  10318b:	7c b2                	jl     10313f <spinlock_check+0x3f1>
		for(i=0;i<NUMLOCKS;i++) assert(locks[i].eips[0]==0);
  10318d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  103194:	eb 46                	jmp    1031dc <spinlock_check+0x48e>
  103196:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103199:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  10319c:	c1 e0 03             	shl    $0x3,%eax
  10319f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  1031a6:	29 c2                	sub    %eax,%edx
  1031a8:	8d 04 11             	lea    (%ecx,%edx,1),%eax
  1031ab:	83 c0 10             	add    $0x10,%eax
  1031ae:	8b 00                	mov    (%eax),%eax
  1031b0:	85 c0                	test   %eax,%eax
  1031b2:	74 24                	je     1031d8 <spinlock_check+0x48a>
  1031b4:	c7 44 24 0c 72 64 10 	movl   $0x106472,0xc(%esp)
  1031bb:	00 
  1031bc:	c7 44 24 08 2a 63 10 	movl   $0x10632a,0x8(%esp)
  1031c3:	00 
  1031c4:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  1031cb:	00 
  1031cc:	c7 04 24 67 63 10 00 	movl   $0x106367,(%esp)
  1031d3:	e8 34 d2 ff ff       	call   10040c <debug_panic>
  1031d8:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
  1031dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1031df:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1031e2:	7c b2                	jl     103196 <spinlock_check+0x448>
		// Make sure that all locks have holding correctly implemented.
		for(i=0;i<NUMLOCKS;i++) assert(spinlock_holding(&locks[i]) == 0);
  1031e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  1031eb:	eb 4d                	jmp    10323a <spinlock_check+0x4ec>
  1031ed:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1031f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1031f3:	c1 e0 03             	shl    $0x3,%eax
  1031f6:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
  1031fd:	89 cb                	mov    %ecx,%ebx
  1031ff:	29 c3                	sub    %eax,%ebx
  103201:	89 d8                	mov    %ebx,%eax
  103203:	8d 04 02             	lea    (%edx,%eax,1),%eax
  103206:	89 04 24             	mov    %eax,(%esp)
  103209:	e8 d3 fa ff ff       	call   102ce1 <spinlock_holding>
  10320e:	85 c0                	test   %eax,%eax
  103210:	74 24                	je     103236 <spinlock_check+0x4e8>
  103212:	c7 44 24 0c 88 64 10 	movl   $0x106488,0xc(%esp)
  103219:	00 
  10321a:	c7 44 24 08 2a 63 10 	movl   $0x10632a,0x8(%esp)
  103221:	00 
  103222:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  103229:	00 
  10322a:	c7 04 24 67 63 10 00 	movl   $0x106367,(%esp)
  103231:	e8 d6 d1 ff ff       	call   10040c <debug_panic>
  103236:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
  10323a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10323d:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  103240:	7c ab                	jl     1031ed <spinlock_check+0x49f>
	// Make sure that all locks have CPU set to NULL initially
	for(i=0;i<NUMLOCKS;i++) assert(locks[i].cpu==NULL);
	// Make sure that all locks have the correct debug info.
	for(i=0;i<NUMLOCKS;i++) assert(locks[i].file==file);

	for (run=0;run<NUMRUNS;run++) 
  103242:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  103246:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103249:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  10324c:	0f 8c e2 fc ff ff    	jl     102f34 <spinlock_check+0x1e6>
		for(i=0;i<NUMLOCKS;i++) assert(locks[i].cpu == NULL);
		for(i=0;i<NUMLOCKS;i++) assert(locks[i].eips[0]==0);
		// Make sure that all locks have holding correctly implemented.
		for(i=0;i<NUMLOCKS;i++) assert(spinlock_holding(&locks[i]) == 0);
	}
	cprintf("spinlock_check() succeeded!\n");
  103252:	c7 04 24 a9 64 10 00 	movl   $0x1064a9,(%esp)
  103259:	e8 e7 1f 00 00       	call   105245 <cprintf>
  10325e:	8b 65 c4             	mov    -0x3c(%ebp),%esp
}
  103261:	8d 65 f4             	lea    -0xc(%ebp),%esp
  103264:	83 c4 00             	add    $0x0,%esp
  103267:	5b                   	pop    %ebx
  103268:	5e                   	pop    %esi
  103269:	5f                   	pop    %edi
  10326a:	5d                   	pop    %ebp
  10326b:	c3                   	ret    

0010326c <xchg>:
}

// Atomically set *addr to newval and return the old value of *addr.
static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
  10326c:	55                   	push   %ebp
  10326d:	89 e5                	mov    %esp,%ebp
  10326f:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
  103272:	8b 55 08             	mov    0x8(%ebp),%edx
  103275:	8b 45 0c             	mov    0xc(%ebp),%eax
  103278:	8b 4d 08             	mov    0x8(%ebp),%ecx
  10327b:	f0 87 02             	lock xchg %eax,(%edx)
  10327e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	       "+m" (*addr), "=a" (result) :
	       "1" (newval) :
	       "cc");
	return result;
  103281:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  103284:	c9                   	leave  
  103285:	c3                   	ret    

00103286 <lockadd>:

// Atomically add incr to *addr.
static inline void
lockadd(volatile int32_t *addr, int32_t incr)
{
  103286:	55                   	push   %ebp
  103287:	89 e5                	mov    %esp,%ebp
	asm volatile("lock; addl %1,%0" : "+m" (*addr) : "r" (incr) : "cc");
  103289:	8b 45 08             	mov    0x8(%ebp),%eax
  10328c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10328f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  103292:	f0 01 10             	lock add %edx,(%eax)
}
  103295:	5d                   	pop    %ebp
  103296:	c3                   	ret    

00103297 <pause>:
	return result;
}

static inline void
pause(void)
{
  103297:	55                   	push   %ebp
  103298:	89 e5                	mov    %esp,%ebp
	asm volatile("pause" : : : "memory");
  10329a:	f3 90                	pause  
}
  10329c:	5d                   	pop    %ebp
  10329d:	c3                   	ret    

0010329e <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  10329e:	55                   	push   %ebp
  10329f:	89 e5                	mov    %esp,%ebp
  1032a1:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  1032a4:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  1032a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  1032aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1032ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1032b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1032b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  1032b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032bb:	8b 80 b8 00 00 00    	mov    0xb8(%eax),%eax
  1032c1:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  1032c6:	74 24                	je     1032ec <cpu_cur+0x4e>
  1032c8:	c7 44 24 0c c8 64 10 	movl   $0x1064c8,0xc(%esp)
  1032cf:	00 
  1032d0:	c7 44 24 08 de 64 10 	movl   $0x1064de,0x8(%esp)
  1032d7:	00 
  1032d8:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  1032df:	00 
  1032e0:	c7 04 24 f3 64 10 00 	movl   $0x1064f3,(%esp)
  1032e7:	e8 20 d1 ff ff       	call   10040c <debug_panic>
	return c;
  1032ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  1032ef:	c9                   	leave  
  1032f0:	c3                   	ret    

001032f1 <cpu_onboot>:

// Returns true if we're running on the bootstrap CPU.
static inline int
cpu_onboot() {
  1032f1:	55                   	push   %ebp
  1032f2:	89 e5                	mov    %esp,%ebp
  1032f4:	83 ec 08             	sub    $0x8,%esp
	return cpu_cur() == &cpu_boot;
  1032f7:	e8 a2 ff ff ff       	call   10329e <cpu_cur>
  1032fc:	3d 00 70 10 00       	cmp    $0x107000,%eax
  103301:	0f 94 c0             	sete   %al
  103304:	0f b6 c0             	movzbl %al,%eax
}
  103307:	c9                   	leave  
  103308:	c3                   	ret    

00103309 <proc_init>:
// LAB 2: insert your scheduling data structure declarations here.


void
proc_init(void)
{
  103309:	55                   	push   %ebp
  10330a:	89 e5                	mov    %esp,%ebp
  10330c:	83 ec 08             	sub    $0x8,%esp
	if (!cpu_onboot())
  10330f:	e8 dd ff ff ff       	call   1032f1 <cpu_onboot>
  103314:	85 c0                	test   %eax,%eax
		return;
  103316:	90                   	nop

	// your module initialization code here
}
  103317:	c9                   	leave  
  103318:	c3                   	ret    

00103319 <proc_alloc>:

// Allocate and initialize a new proc as child 'cn' of parent 'p'.
// Returns NULL if no physical memory available.
proc *
proc_alloc(proc *p, uint32_t cn)
{
  103319:	55                   	push   %ebp
  10331a:	89 e5                	mov    %esp,%ebp
  10331c:	83 ec 28             	sub    $0x28,%esp
	pageinfo *pi = mem_alloc();
  10331f:	e8 3f d9 ff ff       	call   100c63 <mem_alloc>
  103324:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (!pi)
  103327:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  10332b:	75 0a                	jne    103337 <proc_alloc+0x1e>
		return NULL;
  10332d:	b8 00 00 00 00       	mov    $0x0,%eax
  103332:	e9 60 01 00 00       	jmp    103497 <proc_alloc+0x17e>
  103337:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10333a:	89 45 f4             	mov    %eax,-0xc(%ebp)

// Atomically increment the reference count on a page.
static gcc_inline void
mem_incref(pageinfo *pi)
{
	assert(pi > &mem_pageinfo[1] && pi < &mem_pageinfo[mem_npage]);
  10333d:	a1 84 e2 10 00       	mov    0x10e284,%eax
  103342:	83 c0 08             	add    $0x8,%eax
  103345:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103348:	76 15                	jbe    10335f <proc_alloc+0x46>
  10334a:	a1 84 e2 10 00       	mov    0x10e284,%eax
  10334f:	8b 15 7c e2 10 00    	mov    0x10e27c,%edx
  103355:	c1 e2 03             	shl    $0x3,%edx
  103358:	01 d0                	add    %edx,%eax
  10335a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10335d:	72 24                	jb     103383 <proc_alloc+0x6a>
  10335f:	c7 44 24 0c 00 65 10 	movl   $0x106500,0xc(%esp)
  103366:	00 
  103367:	c7 44 24 08 de 64 10 	movl   $0x1064de,0x8(%esp)
  10336e:	00 
  10336f:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  103376:	00 
  103377:	c7 04 24 37 65 10 00 	movl   $0x106537,(%esp)
  10337e:	e8 89 d0 ff ff       	call   10040c <debug_panic>
	assert(pi < mem_ptr2pi(start) || pi > mem_ptr2pi(end-1));
  103383:	a1 84 e2 10 00       	mov    0x10e284,%eax
  103388:	ba 0c 00 10 00       	mov    $0x10000c,%edx
  10338d:	c1 ea 0c             	shr    $0xc,%edx
  103390:	c1 e2 03             	shl    $0x3,%edx
  103393:	01 d0                	add    %edx,%eax
  103395:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103398:	72 3b                	jb     1033d5 <proc_alloc+0xbc>
  10339a:	a1 84 e2 10 00       	mov    0x10e284,%eax
  10339f:	ba 4b e9 10 00       	mov    $0x10e94b,%edx
  1033a4:	c1 ea 0c             	shr    $0xc,%edx
  1033a7:	c1 e2 03             	shl    $0x3,%edx
  1033aa:	01 d0                	add    %edx,%eax
  1033ac:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1033af:	77 24                	ja     1033d5 <proc_alloc+0xbc>
  1033b1:	c7 44 24 0c 44 65 10 	movl   $0x106544,0xc(%esp)
  1033b8:	00 
  1033b9:	c7 44 24 08 de 64 10 	movl   $0x1064de,0x8(%esp)
  1033c0:	00 
  1033c1:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  1033c8:	00 
  1033c9:	c7 04 24 37 65 10 00 	movl   $0x106537,(%esp)
  1033d0:	e8 37 d0 ff ff       	call   10040c <debug_panic>

	lockadd(&pi->refcount, 1);
  1033d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033d8:	83 c0 04             	add    $0x4,%eax
  1033db:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1033e2:	00 
  1033e3:	89 04 24             	mov    %eax,(%esp)
  1033e6:	e8 9b fe ff ff       	call   103286 <lockadd>
	mem_incref(pi);

	proc *cp = (proc*)mem_pi2ptr(pi);
  1033eb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1033ee:	a1 84 e2 10 00       	mov    0x10e284,%eax
  1033f3:	89 d1                	mov    %edx,%ecx
  1033f5:	29 c1                	sub    %eax,%ecx
  1033f7:	89 c8                	mov    %ecx,%eax
  1033f9:	c1 f8 03             	sar    $0x3,%eax
  1033fc:	c1 e0 0c             	shl    $0xc,%eax
  1033ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
	memset(cp, 0, sizeof(proc));
  103402:	c7 44 24 08 a0 06 00 	movl   $0x6a0,0x8(%esp)
  103409:	00 
  10340a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103411:	00 
  103412:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103415:	89 04 24             	mov    %eax,(%esp)
  103418:	e8 0f 20 00 00       	call   10542c <memset>
	spinlock_init(&cp->lock);
  10341d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103420:	c7 44 24 08 31 00 00 	movl   $0x31,0x8(%esp)
  103427:	00 
  103428:	c7 44 24 04 75 65 10 	movl   $0x106575,0x4(%esp)
  10342f:	00 
  103430:	89 04 24             	mov    %eax,(%esp)
  103433:	e8 b0 f7 ff ff       	call   102be8 <spinlock_init_>
	cp->parent = p;
  103438:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10343b:	8b 55 08             	mov    0x8(%ebp),%edx
  10343e:	89 50 38             	mov    %edx,0x38(%eax)
	cp->state = PROC_STOP;
  103441:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103444:	c7 80 3c 04 00 00 00 	movl   $0x0,0x43c(%eax)
  10344b:	00 00 00 

	// Integer register state
	cp->sv.tf.ds = CPU_GDT_UDATA | 3;
  10344e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103451:	66 c7 80 7c 04 00 00 	movw   $0x23,0x47c(%eax)
  103458:	23 00 
	cp->sv.tf.es = CPU_GDT_UDATA | 3;
  10345a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10345d:	66 c7 80 78 04 00 00 	movw   $0x23,0x478(%eax)
  103464:	23 00 
	cp->sv.tf.cs = CPU_GDT_UCODE | 3;
  103466:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103469:	66 c7 80 8c 04 00 00 	movw   $0x1b,0x48c(%eax)
  103470:	1b 00 
	cp->sv.tf.ss = CPU_GDT_UDATA | 3;
  103472:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103475:	66 c7 80 98 04 00 00 	movw   $0x23,0x498(%eax)
  10347c:	23 00 


	if (p)
  10347e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103482:	74 10                	je     103494 <proc_alloc+0x17b>
		p->child[cn] = cp;
  103484:	8b 55 0c             	mov    0xc(%ebp),%edx
  103487:	8b 45 08             	mov    0x8(%ebp),%eax
  10348a:	8d 4a 0c             	lea    0xc(%edx),%ecx
  10348d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103490:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
	return cp;
  103494:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  103497:	c9                   	leave  
  103498:	c3                   	ret    

00103499 <proc_ready>:

// Put process p in the ready state and add it to the ready queue.
void
proc_ready(proc *p)
{
  103499:	55                   	push   %ebp
  10349a:	89 e5                	mov    %esp,%ebp
  10349c:	83 ec 18             	sub    $0x18,%esp
	panic("proc_ready not implemented");
  10349f:	c7 44 24 08 81 65 10 	movl   $0x106581,0x8(%esp)
  1034a6:	00 
  1034a7:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  1034ae:	00 
  1034af:	c7 04 24 75 65 10 00 	movl   $0x106575,(%esp)
  1034b6:	e8 51 cf ff ff       	call   10040c <debug_panic>

001034bb <proc_save>:
//	-1	if we entered the kernel via a trap before executing an insn
//	0	if we entered via a syscall and must abort/rollback the syscall
//	1	if we entered via a syscall and are completing the syscall
void
proc_save(proc *p, trapframe *tf, int entry)
{
  1034bb:	55                   	push   %ebp
  1034bc:	89 e5                	mov    %esp,%ebp
}
  1034be:	5d                   	pop    %ebp
  1034bf:	c3                   	ret    

001034c0 <proc_wait>:
// Go to sleep waiting for a given child process to finish running.
// Parent process 'p' must be running and locked on entry.
// The supplied trapframe represents p's register state on syscall entry.
void gcc_noreturn
proc_wait(proc *p, proc *cp, trapframe *tf)
{
  1034c0:	55                   	push   %ebp
  1034c1:	89 e5                	mov    %esp,%ebp
  1034c3:	83 ec 18             	sub    $0x18,%esp
	panic("proc_wait not implemented");
  1034c6:	c7 44 24 08 9c 65 10 	movl   $0x10659c,0x8(%esp)
  1034cd:	00 
  1034ce:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  1034d5:	00 
  1034d6:	c7 04 24 75 65 10 00 	movl   $0x106575,(%esp)
  1034dd:	e8 2a cf ff ff       	call   10040c <debug_panic>

001034e2 <proc_sched>:
}

void gcc_noreturn
proc_sched(void)
{
  1034e2:	55                   	push   %ebp
  1034e3:	89 e5                	mov    %esp,%ebp
  1034e5:	83 ec 18             	sub    $0x18,%esp
	panic("proc_sched not implemented");
  1034e8:	c7 44 24 08 b6 65 10 	movl   $0x1065b6,0x8(%esp)
  1034ef:	00 
  1034f0:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  1034f7:	00 
  1034f8:	c7 04 24 75 65 10 00 	movl   $0x106575,(%esp)
  1034ff:	e8 08 cf ff ff       	call   10040c <debug_panic>

00103504 <proc_run>:
}

// Switch to and run a specified process, which must already be locked.
void gcc_noreturn
proc_run(proc *p)
{
  103504:	55                   	push   %ebp
  103505:	89 e5                	mov    %esp,%ebp
  103507:	83 ec 18             	sub    $0x18,%esp
	panic("proc_run not implemented");
  10350a:	c7 44 24 08 d1 65 10 	movl   $0x1065d1,0x8(%esp)
  103511:	00 
  103512:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  103519:	00 
  10351a:	c7 04 24 75 65 10 00 	movl   $0x106575,(%esp)
  103521:	e8 e6 ce ff ff       	call   10040c <debug_panic>

00103526 <proc_yield>:

// Yield the current CPU to another ready process.
// Called while handling a timer interrupt.
void gcc_noreturn
proc_yield(trapframe *tf)
{
  103526:	55                   	push   %ebp
  103527:	89 e5                	mov    %esp,%ebp
  103529:	83 ec 18             	sub    $0x18,%esp
	panic("proc_yield not implemented");
  10352c:	c7 44 24 08 ea 65 10 	movl   $0x1065ea,0x8(%esp)
  103533:	00 
  103534:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  10353b:	00 
  10353c:	c7 04 24 75 65 10 00 	movl   $0x106575,(%esp)
  103543:	e8 c4 ce ff ff       	call   10040c <debug_panic>

00103548 <proc_ret>:
// Used both when a process calls the SYS_RET system call explicitly,
// and when a process causes an unhandled trap in user mode.
// The 'entry' parameter is as in proc_save().
void gcc_noreturn
proc_ret(trapframe *tf, int entry)
{
  103548:	55                   	push   %ebp
  103549:	89 e5                	mov    %esp,%ebp
  10354b:	83 ec 18             	sub    $0x18,%esp
	panic("proc_ret not implemented");
  10354e:	c7 44 24 08 05 66 10 	movl   $0x106605,0x8(%esp)
  103555:	00 
  103556:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  10355d:	00 
  10355e:	c7 04 24 75 65 10 00 	movl   $0x106575,(%esp)
  103565:	e8 a2 ce ff ff       	call   10040c <debug_panic>

0010356a <proc_check>:
static volatile uint32_t pingpong = 0;
static void *recovargs;

void
proc_check(void)
{
  10356a:	55                   	push   %ebp
  10356b:	89 e5                	mov    %esp,%ebp
  10356d:	57                   	push   %edi
  10356e:	56                   	push   %esi
  10356f:	53                   	push   %ebx
  103570:	81 ec dc 00 00 00    	sub    $0xdc,%esp
	// Spawn 2 child processes, executing on statically allocated stacks.

	int i;
	for (i = 0; i < 4; i++) {
  103576:	c7 85 34 ff ff ff 00 	movl   $0x0,-0xcc(%ebp)
  10357d:	00 00 00 
  103580:	e9 f0 00 00 00       	jmp    103675 <proc_check+0x10b>
		// Setup register state for child
		uint32_t *esp = (uint32_t*) &child_stack[i][PAGESIZE];
  103585:	b8 10 a2 10 00       	mov    $0x10a210,%eax
  10358a:	8b 95 34 ff ff ff    	mov    -0xcc(%ebp),%edx
  103590:	83 c2 01             	add    $0x1,%edx
  103593:	c1 e2 0c             	shl    $0xc,%edx
  103596:	01 d0                	add    %edx,%eax
  103598:	89 85 38 ff ff ff    	mov    %eax,-0xc8(%ebp)
		*--esp = i;	// push argument to child() function
  10359e:	83 ad 38 ff ff ff 04 	subl   $0x4,-0xc8(%ebp)
  1035a5:	8b 95 34 ff ff ff    	mov    -0xcc(%ebp),%edx
  1035ab:	8b 85 38 ff ff ff    	mov    -0xc8(%ebp),%eax
  1035b1:	89 10                	mov    %edx,(%eax)
		*--esp = 0;	// fake return address
  1035b3:	83 ad 38 ff ff ff 04 	subl   $0x4,-0xc8(%ebp)
  1035ba:	8b 85 38 ff ff ff    	mov    -0xc8(%ebp),%eax
  1035c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		child_state.tf.eip = (uint32_t) child;
  1035c6:	b8 4a 3a 10 00       	mov    $0x103a4a,%eax
  1035cb:	a3 f8 9f 10 00       	mov    %eax,0x109ff8
		child_state.tf.esp = (uint32_t) esp;
  1035d0:	8b 85 38 ff ff ff    	mov    -0xc8(%ebp),%eax
  1035d6:	a3 04 a0 10 00       	mov    %eax,0x10a004

		// Use PUT syscall to create each child,
		// but only start the first 2 children for now.
		cprintf("spawning child %d\n", i);
  1035db:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
  1035e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035e5:	c7 04 24 1e 66 10 00 	movl   $0x10661e,(%esp)
  1035ec:	e8 54 1c 00 00       	call   105245 <cprintf>
		sys_put(SYS_REGS | (i < 2 ? SYS_START : 0), i, &child_state,
  1035f1:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
  1035f7:	0f b7 d0             	movzwl %ax,%edx
  1035fa:	83 bd 34 ff ff ff 01 	cmpl   $0x1,-0xcc(%ebp)
  103601:	7f 07                	jg     10360a <proc_check+0xa0>
  103603:	b8 10 10 00 00       	mov    $0x1010,%eax
  103608:	eb 05                	jmp    10360f <proc_check+0xa5>
  10360a:	b8 00 10 00 00       	mov    $0x1000,%eax
  10360f:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
  103615:	66 89 95 52 ff ff ff 	mov    %dx,-0xae(%ebp)
  10361c:	c7 85 4c ff ff ff c0 	movl   $0x109fc0,-0xb4(%ebp)
  103623:	9f 10 00 
  103626:	c7 85 48 ff ff ff 00 	movl   $0x0,-0xb8(%ebp)
  10362d:	00 00 00 
  103630:	c7 85 44 ff ff ff 00 	movl   $0x0,-0xbc(%ebp)
  103637:	00 00 00 
  10363a:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%ebp)
  103641:	00 00 00 
sys_put(uint32_t flags, uint16_t child, procstate *save,
		void *localsrc, void *childdest, size_t size)
{
	asm volatile("int %0" :
		: "i" (T_SYSCALL),
		  "a" (SYS_PUT | flags),
  103644:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  10364a:	83 c8 01             	or     $0x1,%eax

static void gcc_inline
sys_put(uint32_t flags, uint16_t child, procstate *save,
		void *localsrc, void *childdest, size_t size)
{
	asm volatile("int %0" :
  10364d:	8b 9d 4c ff ff ff    	mov    -0xb4(%ebp),%ebx
  103653:	0f b7 95 52 ff ff ff 	movzwl -0xae(%ebp),%edx
  10365a:	8b b5 48 ff ff ff    	mov    -0xb8(%ebp),%esi
  103660:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  103666:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  10366c:	cd 30                	int    $0x30
proc_check(void)
{
	// Spawn 2 child processes, executing on statically allocated stacks.

	int i;
	for (i = 0; i < 4; i++) {
  10366e:	83 85 34 ff ff ff 01 	addl   $0x1,-0xcc(%ebp)
  103675:	83 bd 34 ff ff ff 03 	cmpl   $0x3,-0xcc(%ebp)
  10367c:	0f 8e 03 ff ff ff    	jle    103585 <proc_check+0x1b>
	}

	// Wait for both children to complete.
	// This should complete without preemptive scheduling
	// when we're running on a 2-processor machine.
	for (i = 0; i < 2; i++) {
  103682:	c7 85 34 ff ff ff 00 	movl   $0x0,-0xcc(%ebp)
  103689:	00 00 00 
  10368c:	e9 89 00 00 00       	jmp    10371a <proc_check+0x1b0>
		cprintf("waiting for child %d\n", i);
  103691:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
  103697:	89 44 24 04          	mov    %eax,0x4(%esp)
  10369b:	c7 04 24 31 66 10 00 	movl   $0x106631,(%esp)
  1036a2:	e8 9e 1b 00 00       	call   105245 <cprintf>
		sys_get(SYS_REGS, i, &child_state, NULL, NULL, 0);
  1036a7:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
  1036ad:	0f b7 c0             	movzwl %ax,%eax
  1036b0:	c7 85 6c ff ff ff 00 	movl   $0x1000,-0x94(%ebp)
  1036b7:	10 00 00 
  1036ba:	66 89 85 6a ff ff ff 	mov    %ax,-0x96(%ebp)
  1036c1:	c7 85 64 ff ff ff c0 	movl   $0x109fc0,-0x9c(%ebp)
  1036c8:	9f 10 00 
  1036cb:	c7 85 60 ff ff ff 00 	movl   $0x0,-0xa0(%ebp)
  1036d2:	00 00 00 
  1036d5:	c7 85 5c ff ff ff 00 	movl   $0x0,-0xa4(%ebp)
  1036dc:	00 00 00 
  1036df:	c7 85 58 ff ff ff 00 	movl   $0x0,-0xa8(%ebp)
  1036e6:	00 00 00 
sys_get(uint32_t flags, uint16_t child, procstate *save,
		void *childsrc, void *localdest, size_t size)
{
	asm volatile("int %0" :
		: "i" (T_SYSCALL),
		  "a" (SYS_GET | flags),
  1036e9:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
  1036ef:	83 c8 02             	or     $0x2,%eax

static void gcc_inline
sys_get(uint32_t flags, uint16_t child, procstate *save,
		void *childsrc, void *localdest, size_t size)
{
	asm volatile("int %0" :
  1036f2:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  1036f8:	0f b7 95 6a ff ff ff 	movzwl -0x96(%ebp),%edx
  1036ff:	8b b5 60 ff ff ff    	mov    -0xa0(%ebp),%esi
  103705:	8b bd 5c ff ff ff    	mov    -0xa4(%ebp),%edi
  10370b:	8b 8d 58 ff ff ff    	mov    -0xa8(%ebp),%ecx
  103711:	cd 30                	int    $0x30
	}

	// Wait for both children to complete.
	// This should complete without preemptive scheduling
	// when we're running on a 2-processor machine.
	for (i = 0; i < 2; i++) {
  103713:	83 85 34 ff ff ff 01 	addl   $0x1,-0xcc(%ebp)
  10371a:	83 bd 34 ff ff ff 01 	cmpl   $0x1,-0xcc(%ebp)
  103721:	0f 8e 6a ff ff ff    	jle    103691 <proc_check+0x127>
		cprintf("waiting for child %d\n", i);
		sys_get(SYS_REGS, i, &child_state, NULL, NULL, 0);
	}
	cprintf("proc_check() 2-child test succeeded\n");
  103727:	c7 04 24 48 66 10 00 	movl   $0x106648,(%esp)
  10372e:	e8 12 1b 00 00       	call   105245 <cprintf>

	// (Re)start all four children, and wait for them.
	// This will require preemptive scheduling to complete
	// if we have less than 4 CPUs.
	cprintf("proc_check: spawning 4 children\n");
  103733:	c7 04 24 70 66 10 00 	movl   $0x106670,(%esp)
  10373a:	e8 06 1b 00 00       	call   105245 <cprintf>
	for (i = 0; i < 4; i++) {
  10373f:	c7 85 34 ff ff ff 00 	movl   $0x0,-0xcc(%ebp)
  103746:	00 00 00 
  103749:	eb 7d                	jmp    1037c8 <proc_check+0x25e>
		cprintf("spawning child %d\n", i);
  10374b:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
  103751:	89 44 24 04          	mov    %eax,0x4(%esp)
  103755:	c7 04 24 1e 66 10 00 	movl   $0x10661e,(%esp)
  10375c:	e8 e4 1a 00 00       	call   105245 <cprintf>
		sys_put(SYS_START, i, NULL, NULL, NULL, 0);
  103761:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
  103767:	0f b7 c0             	movzwl %ax,%eax
  10376a:	c7 45 84 10 00 00 00 	movl   $0x10,-0x7c(%ebp)
  103771:	66 89 45 82          	mov    %ax,-0x7e(%ebp)
  103775:	c7 85 7c ff ff ff 00 	movl   $0x0,-0x84(%ebp)
  10377c:	00 00 00 
  10377f:	c7 85 78 ff ff ff 00 	movl   $0x0,-0x88(%ebp)
  103786:	00 00 00 
  103789:	c7 85 74 ff ff ff 00 	movl   $0x0,-0x8c(%ebp)
  103790:	00 00 00 
  103793:	c7 85 70 ff ff ff 00 	movl   $0x0,-0x90(%ebp)
  10379a:	00 00 00 
sys_put(uint32_t flags, uint16_t child, procstate *save,
		void *localsrc, void *childdest, size_t size)
{
	asm volatile("int %0" :
		: "i" (T_SYSCALL),
		  "a" (SYS_PUT | flags),
  10379d:	8b 45 84             	mov    -0x7c(%ebp),%eax
  1037a0:	83 c8 01             	or     $0x1,%eax

static void gcc_inline
sys_put(uint32_t flags, uint16_t child, procstate *save,
		void *localsrc, void *childdest, size_t size)
{
	asm volatile("int %0" :
  1037a3:	8b 9d 7c ff ff ff    	mov    -0x84(%ebp),%ebx
  1037a9:	0f b7 55 82          	movzwl -0x7e(%ebp),%edx
  1037ad:	8b b5 78 ff ff ff    	mov    -0x88(%ebp),%esi
  1037b3:	8b bd 74 ff ff ff    	mov    -0x8c(%ebp),%edi
  1037b9:	8b 8d 70 ff ff ff    	mov    -0x90(%ebp),%ecx
  1037bf:	cd 30                	int    $0x30

	// (Re)start all four children, and wait for them.
	// This will require preemptive scheduling to complete
	// if we have less than 4 CPUs.
	cprintf("proc_check: spawning 4 children\n");
	for (i = 0; i < 4; i++) {
  1037c1:	83 85 34 ff ff ff 01 	addl   $0x1,-0xcc(%ebp)
  1037c8:	83 bd 34 ff ff ff 03 	cmpl   $0x3,-0xcc(%ebp)
  1037cf:	0f 8e 76 ff ff ff    	jle    10374b <proc_check+0x1e1>
		cprintf("spawning child %d\n", i);
		sys_put(SYS_START, i, NULL, NULL, NULL, 0);
	}

	// Wait for all 4 children to complete.
	for (i = 0; i < 4; i++)
  1037d5:	c7 85 34 ff ff ff 00 	movl   $0x0,-0xcc(%ebp)
  1037dc:	00 00 00 
  1037df:	eb 4f                	jmp    103830 <proc_check+0x2c6>
		sys_get(0, i, NULL, NULL, NULL, 0);
  1037e1:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
  1037e7:	0f b7 c0             	movzwl %ax,%eax
  1037ea:	c7 45 9c 00 00 00 00 	movl   $0x0,-0x64(%ebp)
  1037f1:	66 89 45 9a          	mov    %ax,-0x66(%ebp)
  1037f5:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  1037fc:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  103803:	c7 45 8c 00 00 00 00 	movl   $0x0,-0x74(%ebp)
  10380a:	c7 45 88 00 00 00 00 	movl   $0x0,-0x78(%ebp)
sys_get(uint32_t flags, uint16_t child, procstate *save,
		void *childsrc, void *localdest, size_t size)
{
	asm volatile("int %0" :
		: "i" (T_SYSCALL),
		  "a" (SYS_GET | flags),
  103811:	8b 45 9c             	mov    -0x64(%ebp),%eax
  103814:	83 c8 02             	or     $0x2,%eax

static void gcc_inline
sys_get(uint32_t flags, uint16_t child, procstate *save,
		void *childsrc, void *localdest, size_t size)
{
	asm volatile("int %0" :
  103817:	8b 5d 94             	mov    -0x6c(%ebp),%ebx
  10381a:	0f b7 55 9a          	movzwl -0x66(%ebp),%edx
  10381e:	8b 75 90             	mov    -0x70(%ebp),%esi
  103821:	8b 7d 8c             	mov    -0x74(%ebp),%edi
  103824:	8b 4d 88             	mov    -0x78(%ebp),%ecx
  103827:	cd 30                	int    $0x30
		cprintf("spawning child %d\n", i);
		sys_put(SYS_START, i, NULL, NULL, NULL, 0);
	}

	// Wait for all 4 children to complete.
	for (i = 0; i < 4; i++)
  103829:	83 85 34 ff ff ff 01 	addl   $0x1,-0xcc(%ebp)
  103830:	83 bd 34 ff ff ff 03 	cmpl   $0x3,-0xcc(%ebp)
  103837:	7e a8                	jle    1037e1 <proc_check+0x277>
		sys_get(0, i, NULL, NULL, NULL, 0);
	cprintf("proc_check() 4-child test succeeded\n");
  103839:	c7 04 24 94 66 10 00 	movl   $0x106694,(%esp)
  103840:	e8 00 1a 00 00       	call   105245 <cprintf>

	// Now do a trap handling test using all 4 children -
	// but they'll _think_ they're all child 0!
	// (We'll lose the register state of the other children.)
	i = 0;
  103845:	c7 85 34 ff ff ff 00 	movl   $0x0,-0xcc(%ebp)
  10384c:	00 00 00 
	sys_get(SYS_REGS, i, &child_state, NULL, NULL, 0);
  10384f:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
  103855:	0f b7 c0             	movzwl %ax,%eax
  103858:	c7 45 b4 00 10 00 00 	movl   $0x1000,-0x4c(%ebp)
  10385f:	66 89 45 b2          	mov    %ax,-0x4e(%ebp)
  103863:	c7 45 ac c0 9f 10 00 	movl   $0x109fc0,-0x54(%ebp)
  10386a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
  103871:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
  103878:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%ebp)
		: "i" (T_SYSCALL),
		  "a" (SYS_GET | flags),
  10387f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103882:	83 c8 02             	or     $0x2,%eax

static void gcc_inline
sys_get(uint32_t flags, uint16_t child, procstate *save,
		void *childsrc, void *localdest, size_t size)
{
	asm volatile("int %0" :
  103885:	8b 5d ac             	mov    -0x54(%ebp),%ebx
  103888:	0f b7 55 b2          	movzwl -0x4e(%ebp),%edx
  10388c:	8b 75 a8             	mov    -0x58(%ebp),%esi
  10388f:	8b 7d a4             	mov    -0x5c(%ebp),%edi
  103892:	8b 4d a0             	mov    -0x60(%ebp),%ecx
  103895:	cd 30                	int    $0x30
		// get child 0's state
	assert(recovargs == NULL);
  103897:	a1 14 e2 10 00       	mov    0x10e214,%eax
  10389c:	85 c0                	test   %eax,%eax
  10389e:	74 24                	je     1038c4 <proc_check+0x35a>
  1038a0:	c7 44 24 0c b9 66 10 	movl   $0x1066b9,0xc(%esp)
  1038a7:	00 
  1038a8:	c7 44 24 08 de 64 10 	movl   $0x1064de,0x8(%esp)
  1038af:	00 
  1038b0:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
  1038b7:	00 
  1038b8:	c7 04 24 75 65 10 00 	movl   $0x106575,(%esp)
  1038bf:	e8 48 cb ff ff       	call   10040c <debug_panic>
	do {
		sys_put(SYS_REGS | SYS_START, i, &child_state, NULL, NULL, 0);
  1038c4:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
  1038ca:	0f b7 c0             	movzwl %ax,%eax
  1038cd:	c7 45 cc 10 10 00 00 	movl   $0x1010,-0x34(%ebp)
  1038d4:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
  1038d8:	c7 45 c4 c0 9f 10 00 	movl   $0x109fc0,-0x3c(%ebp)
  1038df:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
  1038e6:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
  1038ed:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
sys_put(uint32_t flags, uint16_t child, procstate *save,
		void *localsrc, void *childdest, size_t size)
{
	asm volatile("int %0" :
		: "i" (T_SYSCALL),
		  "a" (SYS_PUT | flags),
  1038f4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1038f7:	83 c8 01             	or     $0x1,%eax

static void gcc_inline
sys_put(uint32_t flags, uint16_t child, procstate *save,
		void *localsrc, void *childdest, size_t size)
{
	asm volatile("int %0" :
  1038fa:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  1038fd:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  103901:	8b 75 c0             	mov    -0x40(%ebp),%esi
  103904:	8b 7d bc             	mov    -0x44(%ebp),%edi
  103907:	8b 4d b8             	mov    -0x48(%ebp),%ecx
  10390a:	cd 30                	int    $0x30
		sys_get(SYS_REGS, i, &child_state, NULL, NULL, 0);
  10390c:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
  103912:	0f b7 c0             	movzwl %ax,%eax
  103915:	c7 45 e4 00 10 00 00 	movl   $0x1000,-0x1c(%ebp)
  10391c:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
  103920:	c7 45 dc c0 9f 10 00 	movl   $0x109fc0,-0x24(%ebp)
  103927:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  10392e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  103935:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
sys_get(uint32_t flags, uint16_t child, procstate *save,
		void *childsrc, void *localdest, size_t size)
{
	asm volatile("int %0" :
		: "i" (T_SYSCALL),
		  "a" (SYS_GET | flags),
  10393c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10393f:	83 c8 02             	or     $0x2,%eax

static void gcc_inline
sys_get(uint32_t flags, uint16_t child, procstate *save,
		void *childsrc, void *localdest, size_t size)
{
	asm volatile("int %0" :
  103942:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  103945:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  103949:	8b 75 d8             	mov    -0x28(%ebp),%esi
  10394c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  10394f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  103952:	cd 30                	int    $0x30
		if (recovargs) {	// trap recovery needed
  103954:	a1 14 e2 10 00       	mov    0x10e214,%eax
  103959:	85 c0                	test   %eax,%eax
  10395b:	74 3f                	je     10399c <proc_check+0x432>
			trap_check_args *args = recovargs;
  10395d:	a1 14 e2 10 00       	mov    0x10e214,%eax
  103962:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
			cprintf("recover from trap %d\n",
  103968:	a1 f0 9f 10 00       	mov    0x109ff0,%eax
  10396d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103971:	c7 04 24 cb 66 10 00 	movl   $0x1066cb,(%esp)
  103978:	e8 c8 18 00 00       	call   105245 <cprintf>
				child_state.tf.trapno);
			child_state.tf.eip = (uint32_t) args->reip;
  10397d:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  103983:	8b 00                	mov    (%eax),%eax
  103985:	a3 f8 9f 10 00       	mov    %eax,0x109ff8
			args->trapno = child_state.tf.trapno;
  10398a:	a1 f0 9f 10 00       	mov    0x109ff0,%eax
  10398f:	89 c2                	mov    %eax,%edx
  103991:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  103997:	89 50 04             	mov    %edx,0x4(%eax)
  10399a:	eb 2e                	jmp    1039ca <proc_check+0x460>
		} else
			assert(child_state.tf.trapno == T_SYSCALL);
  10399c:	a1 f0 9f 10 00       	mov    0x109ff0,%eax
  1039a1:	83 f8 30             	cmp    $0x30,%eax
  1039a4:	74 24                	je     1039ca <proc_check+0x460>
  1039a6:	c7 44 24 0c e4 66 10 	movl   $0x1066e4,0xc(%esp)
  1039ad:	00 
  1039ae:	c7 44 24 08 de 64 10 	movl   $0x1064de,0x8(%esp)
  1039b5:	00 
  1039b6:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
  1039bd:	00 
  1039be:	c7 04 24 75 65 10 00 	movl   $0x106575,(%esp)
  1039c5:	e8 42 ca ff ff       	call   10040c <debug_panic>
		i = (i+1) % 4;	// rotate to next child proc
  1039ca:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
  1039d0:	8d 50 01             	lea    0x1(%eax),%edx
  1039d3:	89 d0                	mov    %edx,%eax
  1039d5:	c1 f8 1f             	sar    $0x1f,%eax
  1039d8:	c1 e8 1e             	shr    $0x1e,%eax
  1039db:	01 c2                	add    %eax,%edx
  1039dd:	83 e2 03             	and    $0x3,%edx
  1039e0:	89 d1                	mov    %edx,%ecx
  1039e2:	29 c1                	sub    %eax,%ecx
  1039e4:	89 c8                	mov    %ecx,%eax
  1039e6:	89 85 34 ff ff ff    	mov    %eax,-0xcc(%ebp)
	} while (child_state.tf.trapno != T_SYSCALL);
  1039ec:	a1 f0 9f 10 00       	mov    0x109ff0,%eax
  1039f1:	83 f8 30             	cmp    $0x30,%eax
  1039f4:	0f 85 ca fe ff ff    	jne    1038c4 <proc_check+0x35a>
	assert(recovargs == NULL);
  1039fa:	a1 14 e2 10 00       	mov    0x10e214,%eax
  1039ff:	85 c0                	test   %eax,%eax
  103a01:	74 24                	je     103a27 <proc_check+0x4bd>
  103a03:	c7 44 24 0c b9 66 10 	movl   $0x1066b9,0xc(%esp)
  103a0a:	00 
  103a0b:	c7 44 24 08 de 64 10 	movl   $0x1064de,0x8(%esp)
  103a12:	00 
  103a13:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
  103a1a:	00 
  103a1b:	c7 04 24 75 65 10 00 	movl   $0x106575,(%esp)
  103a22:	e8 e5 c9 ff ff       	call   10040c <debug_panic>

	cprintf("proc_check() trap reflection test succeeded\n");
  103a27:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103a2e:	e8 12 18 00 00       	call   105245 <cprintf>

	cprintf("proc_check() succeeded!\n");
  103a33:	c7 04 24 35 67 10 00 	movl   $0x106735,(%esp)
  103a3a:	e8 06 18 00 00       	call   105245 <cprintf>
}
  103a3f:	81 c4 dc 00 00 00    	add    $0xdc,%esp
  103a45:	5b                   	pop    %ebx
  103a46:	5e                   	pop    %esi
  103a47:	5f                   	pop    %edi
  103a48:	5d                   	pop    %ebp
  103a49:	c3                   	ret    

00103a4a <child>:

static void child(int n)
{
  103a4a:	55                   	push   %ebp
  103a4b:	89 e5                	mov    %esp,%ebp
  103a4d:	83 ec 28             	sub    $0x28,%esp
	// Only first 2 children participate in first pingpong test
	if (n < 2) {
  103a50:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  103a54:	7f 64                	jg     103aba <child+0x70>
		int i;
		for (i = 0; i < 10; i++) {
  103a56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103a5d:	eb 4e                	jmp    103aad <child+0x63>
			cprintf("in child %d count %d\n", n, i);
  103a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a62:	89 44 24 08          	mov    %eax,0x8(%esp)
  103a66:	8b 45 08             	mov    0x8(%ebp),%eax
  103a69:	89 44 24 04          	mov    %eax,0x4(%esp)
  103a6d:	c7 04 24 4e 67 10 00 	movl   $0x10674e,(%esp)
  103a74:	e8 cc 17 00 00       	call   105245 <cprintf>
			while (pingpong != n)
  103a79:	eb 05                	jmp    103a80 <child+0x36>
				pause();
  103a7b:	e8 17 f8 ff ff       	call   103297 <pause>
	// Only first 2 children participate in first pingpong test
	if (n < 2) {
		int i;
		for (i = 0; i < 10; i++) {
			cprintf("in child %d count %d\n", n, i);
			while (pingpong != n)
  103a80:	8b 55 08             	mov    0x8(%ebp),%edx
  103a83:	a1 10 e2 10 00       	mov    0x10e210,%eax
  103a88:	39 c2                	cmp    %eax,%edx
  103a8a:	75 ef                	jne    103a7b <child+0x31>
				pause();
			xchg(&pingpong, !pingpong);
  103a8c:	a1 10 e2 10 00       	mov    0x10e210,%eax
  103a91:	85 c0                	test   %eax,%eax
  103a93:	0f 94 c0             	sete   %al
  103a96:	0f b6 c0             	movzbl %al,%eax
  103a99:	89 44 24 04          	mov    %eax,0x4(%esp)
  103a9d:	c7 04 24 10 e2 10 00 	movl   $0x10e210,(%esp)
  103aa4:	e8 c3 f7 ff ff       	call   10326c <xchg>
static void child(int n)
{
	// Only first 2 children participate in first pingpong test
	if (n < 2) {
		int i;
		for (i = 0; i < 10; i++) {
  103aa9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  103aad:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  103ab1:	7e ac                	jle    103a5f <child+0x15>
}

static void gcc_inline
sys_ret(void)
{
	asm volatile("int %0" : :
  103ab3:	b8 03 00 00 00       	mov    $0x3,%eax
  103ab8:	cd 30                	int    $0x30
		sys_ret();
	}

	// Second test, round-robin pingpong between all 4 children
	int i;
	for (i = 0; i < 10; i++) {
  103aba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  103ac1:	eb 4c                	jmp    103b0f <child+0xc5>
		cprintf("in child %d count %d\n", n, i);
  103ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103ac6:	89 44 24 08          	mov    %eax,0x8(%esp)
  103aca:	8b 45 08             	mov    0x8(%ebp),%eax
  103acd:	89 44 24 04          	mov    %eax,0x4(%esp)
  103ad1:	c7 04 24 4e 67 10 00 	movl   $0x10674e,(%esp)
  103ad8:	e8 68 17 00 00       	call   105245 <cprintf>
		while (pingpong != n)
  103add:	eb 05                	jmp    103ae4 <child+0x9a>
			pause();
  103adf:	e8 b3 f7 ff ff       	call   103297 <pause>

	// Second test, round-robin pingpong between all 4 children
	int i;
	for (i = 0; i < 10; i++) {
		cprintf("in child %d count %d\n", n, i);
		while (pingpong != n)
  103ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  103ae7:	a1 10 e2 10 00       	mov    0x10e210,%eax
  103aec:	39 c2                	cmp    %eax,%edx
  103aee:	75 ef                	jne    103adf <child+0x95>
			pause();
		xchg(&pingpong, (pingpong + 1) % 4);
  103af0:	a1 10 e2 10 00       	mov    0x10e210,%eax
  103af5:	83 c0 01             	add    $0x1,%eax
  103af8:	83 e0 03             	and    $0x3,%eax
  103afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  103aff:	c7 04 24 10 e2 10 00 	movl   $0x10e210,(%esp)
  103b06:	e8 61 f7 ff ff       	call   10326c <xchg>
		sys_ret();
	}

	// Second test, round-robin pingpong between all 4 children
	int i;
	for (i = 0; i < 10; i++) {
  103b0b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  103b0f:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
  103b13:	7e ae                	jle    103ac3 <child+0x79>
  103b15:	b8 03 00 00 00       	mov    $0x3,%eax
  103b1a:	cd 30                	int    $0x30
		xchg(&pingpong, (pingpong + 1) % 4);
	}
	sys_ret();

	// Only "child 0" (or the proc that thinks it's child 0), trap check...
	if (n == 0) {
  103b1c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103b20:	75 6d                	jne    103b8f <child+0x145>
		assert(recovargs == NULL);
  103b22:	a1 14 e2 10 00       	mov    0x10e214,%eax
  103b27:	85 c0                	test   %eax,%eax
  103b29:	74 24                	je     103b4f <child+0x105>
  103b2b:	c7 44 24 0c b9 66 10 	movl   $0x1066b9,0xc(%esp)
  103b32:	00 
  103b33:	c7 44 24 08 de 64 10 	movl   $0x1064de,0x8(%esp)
  103b3a:	00 
  103b3b:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
  103b42:	00 
  103b43:	c7 04 24 75 65 10 00 	movl   $0x106575,(%esp)
  103b4a:	e8 bd c8 ff ff       	call   10040c <debug_panic>
		trap_check(&recovargs);
  103b4f:	c7 04 24 14 e2 10 00 	movl   $0x10e214,(%esp)
  103b56:	e8 d6 e8 ff ff       	call   102431 <trap_check>
		assert(recovargs == NULL);
  103b5b:	a1 14 e2 10 00       	mov    0x10e214,%eax
  103b60:	85 c0                	test   %eax,%eax
  103b62:	74 24                	je     103b88 <child+0x13e>
  103b64:	c7 44 24 0c b9 66 10 	movl   $0x1066b9,0xc(%esp)
  103b6b:	00 
  103b6c:	c7 44 24 08 de 64 10 	movl   $0x1064de,0x8(%esp)
  103b73:	00 
  103b74:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
  103b7b:	00 
  103b7c:	c7 04 24 75 65 10 00 	movl   $0x106575,(%esp)
  103b83:	e8 84 c8 ff ff       	call   10040c <debug_panic>
  103b88:	b8 03 00 00 00       	mov    $0x3,%eax
  103b8d:	cd 30                	int    $0x30
		sys_ret();
	}

	panic("child(): shouldn't have gotten here");
  103b8f:	c7 44 24 08 64 67 10 	movl   $0x106764,0x8(%esp)
  103b96:	00 
  103b97:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
  103b9e:	00 
  103b9f:	c7 04 24 75 65 10 00 	movl   $0x106575,(%esp)
  103ba6:	e8 61 c8 ff ff       	call   10040c <debug_panic>

00103bab <grandchild>:
}

static void grandchild(int n)
{
  103bab:	55                   	push   %ebp
  103bac:	89 e5                	mov    %esp,%ebp
  103bae:	83 ec 18             	sub    $0x18,%esp
	panic("grandchild(): shouldn't have gotten here");
  103bb1:	c7 44 24 08 88 67 10 	movl   $0x106788,0x8(%esp)
  103bb8:	00 
  103bb9:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  103bc0:	00 
  103bc1:	c7 04 24 75 65 10 00 	movl   $0x106575,(%esp)
  103bc8:	e8 3f c8 ff ff       	call   10040c <debug_panic>
  103bcd:	90                   	nop
  103bce:	90                   	nop
  103bcf:	90                   	nop

00103bd0 <systrap>:
// During a system call, generate a specific processor trap -
// as if the user code's INT 0x30 instruction had caused it -
// and reflect the trap to the parent process as with other traps.
static void gcc_noreturn
systrap(trapframe *utf, int trapno, int err)
{
  103bd0:	55                   	push   %ebp
  103bd1:	89 e5                	mov    %esp,%ebp
  103bd3:	83 ec 18             	sub    $0x18,%esp
	panic("systrap() not implemented.");
  103bd6:	c7 44 24 08 b4 67 10 	movl   $0x1067b4,0x8(%esp)
  103bdd:	00 
  103bde:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  103be5:	00 
  103be6:	c7 04 24 cf 67 10 00 	movl   $0x1067cf,(%esp)
  103bed:	e8 1a c8 ff ff       	call   10040c <debug_panic>

00103bf2 <sysrecover>:
// - Be sure the parent gets the correct trapno, err, and eip values.
// - Be sure to release any spinlocks you were holding during the copyin/out.
//
static void gcc_noreturn
sysrecover(trapframe *ktf, void *recoverdata)
{
  103bf2:	55                   	push   %ebp
  103bf3:	89 e5                	mov    %esp,%ebp
  103bf5:	83 ec 18             	sub    $0x18,%esp
	panic("sysrecover() not implemented.");
  103bf8:	c7 44 24 08 de 67 10 	movl   $0x1067de,0x8(%esp)
  103bff:	00 
  103c00:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  103c07:	00 
  103c08:	c7 04 24 cf 67 10 00 	movl   $0x1067cf,(%esp)
  103c0f:	e8 f8 c7 ff ff       	call   10040c <debug_panic>

00103c14 <checkva>:
//
// Note: Be careful that your arithmetic works correctly
// even if size is very large, e.g., if uva+size wraps around!
//
static void checkva(trapframe *utf, uint32_t uva, size_t size)
{
  103c14:	55                   	push   %ebp
  103c15:	89 e5                	mov    %esp,%ebp
  103c17:	83 ec 18             	sub    $0x18,%esp
	panic("checkva() not implemented.");
  103c1a:	c7 44 24 08 fc 67 10 	movl   $0x1067fc,0x8(%esp)
  103c21:	00 
  103c22:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  103c29:	00 
  103c2a:	c7 04 24 cf 67 10 00 	movl   $0x1067cf,(%esp)
  103c31:	e8 d6 c7 ff ff       	call   10040c <debug_panic>

00103c36 <usercopy>:
// Copy data to/from user space,
// using checkva() above to validate the address range
// and using sysrecover() to recover from any traps during the copy.
void usercopy(trapframe *utf, bool copyout,
			void *kva, uint32_t uva, size_t size)
{
  103c36:	55                   	push   %ebp
  103c37:	89 e5                	mov    %esp,%ebp
  103c39:	83 ec 18             	sub    $0x18,%esp
	checkva(utf, uva, size);
  103c3c:	8b 45 18             	mov    0x18(%ebp),%eax
  103c3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  103c43:	8b 45 14             	mov    0x14(%ebp),%eax
  103c46:	89 44 24 04          	mov    %eax,0x4(%esp)
  103c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  103c4d:	89 04 24             	mov    %eax,(%esp)
  103c50:	e8 bf ff ff ff       	call   103c14 <checkva>

	// Now do the copy, but recover from page faults.
	panic("syscall_usercopy() not implemented.");
  103c55:	c7 44 24 08 18 68 10 	movl   $0x106818,0x8(%esp)
  103c5c:	00 
  103c5d:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
  103c64:	00 
  103c65:	c7 04 24 cf 67 10 00 	movl   $0x1067cf,(%esp)
  103c6c:	e8 9b c7 ff ff       	call   10040c <debug_panic>

00103c71 <do_cputs>:
}

static void
do_cputs(trapframe *tf, uint32_t cmd)
{
  103c71:	55                   	push   %ebp
  103c72:	89 e5                	mov    %esp,%ebp
  103c74:	83 ec 18             	sub    $0x18,%esp
	// Print the string supplied by the user: pointer in EBX
	cprintf("%s", (char*)tf->regs.ebx);
  103c77:	8b 45 08             	mov    0x8(%ebp),%eax
  103c7a:	8b 40 10             	mov    0x10(%eax),%eax
  103c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103c81:	c7 04 24 3c 68 10 00 	movl   $0x10683c,(%esp)
  103c88:	e8 b8 15 00 00       	call   105245 <cprintf>

	trap_return(tf);	// syscall completed
  103c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  103c90:	89 04 24             	mov    %eax,(%esp)
  103c93:	e8 d8 ea ff ff       	call   102770 <trap_return>

00103c98 <syscall>:
// Common function to handle all system calls -
// decode the system call type and call an appropriate handler function.
// Be sure to handle undefined system calls appropriately.
void
syscall(trapframe *tf)
{
  103c98:	55                   	push   %ebp
  103c99:	89 e5                	mov    %esp,%ebp
  103c9b:	83 ec 28             	sub    $0x28,%esp
	// EAX register holds system call command/flags
	uint32_t cmd = tf->regs.eax;
  103c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  103ca1:	8b 40 1c             	mov    0x1c(%eax),%eax
  103ca4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	switch (cmd & SYS_TYPE) {
  103ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103caa:	83 e0 0f             	and    $0xf,%eax
  103cad:	85 c0                	test   %eax,%eax
  103caf:	75 15                	jne    103cc6 <syscall+0x2e>
	case SYS_CPUTS:	return do_cputs(tf, cmd);
  103cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  103cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  103cbb:	89 04 24             	mov    %eax,(%esp)
  103cbe:	e8 ae ff ff ff       	call   103c71 <do_cputs>
  103cc3:	90                   	nop
  103cc4:	eb 01                	jmp    103cc7 <syscall+0x2f>
	// Your implementations of SYS_PUT, SYS_GET, SYS_RET here...
	default:	return;		// handle as a regular trap
  103cc6:	90                   	nop
	}
}
  103cc7:	c9                   	leave  
  103cc8:	c3                   	ret    
  103cc9:	90                   	nop
  103cca:	90                   	nop
  103ccb:	90                   	nop

00103ccc <video_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
video_init(void)
{
  103ccc:	55                   	push   %ebp
  103ccd:	89 e5                	mov    %esp,%ebp
  103ccf:	83 ec 30             	sub    $0x30,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	/* Get a pointer to the memory-mapped text display buffer. */
	cp = (uint16_t*) mem_ptr(CGA_BUF);
  103cd2:	c7 45 d8 00 80 0b 00 	movl   $0xb8000,-0x28(%ebp)
	was = *cp;
  103cd9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103cdc:	0f b7 00             	movzwl (%eax),%eax
  103cdf:	66 89 45 de          	mov    %ax,-0x22(%ebp)
	*cp = (uint16_t) 0xA55A;
  103ce3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103ce6:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
  103ceb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103cee:	0f b7 00             	movzwl (%eax),%eax
  103cf1:	66 3d 5a a5          	cmp    $0xa55a,%ax
  103cf5:	74 13                	je     103d0a <video_init+0x3e>
		cp = (uint16_t*) mem_ptr(MONO_BUF);
  103cf7:	c7 45 d8 00 00 0b 00 	movl   $0xb0000,-0x28(%ebp)
		addr_6845 = MONO_BASE;
  103cfe:	c7 05 18 e2 10 00 b4 	movl   $0x3b4,0x10e218
  103d05:	03 00 00 
  103d08:	eb 14                	jmp    103d1e <video_init+0x52>
	} else {
		*cp = was;
  103d0a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103d0d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  103d11:	66 89 10             	mov    %dx,(%eax)
		addr_6845 = CGA_BASE;
  103d14:	c7 05 18 e2 10 00 d4 	movl   $0x3d4,0x10e218
  103d1b:	03 00 00 
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
  103d1e:	a1 18 e2 10 00       	mov    0x10e218,%eax
  103d23:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103d26:	c6 45 e7 0e          	movb   $0xe,-0x19(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  103d2a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  103d2e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  103d31:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
  103d32:	a1 18 e2 10 00       	mov    0x10e218,%eax
  103d37:	83 c0 01             	add    $0x1,%eax
  103d3a:	89 45 ec             	mov    %eax,-0x14(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  103d3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103d40:	89 c2                	mov    %eax,%edx
  103d42:	ec                   	in     (%dx),%al
  103d43:	88 45 f2             	mov    %al,-0xe(%ebp)
	return data;
  103d46:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
  103d4a:	0f b6 c0             	movzbl %al,%eax
  103d4d:	c1 e0 08             	shl    $0x8,%eax
  103d50:	89 45 e0             	mov    %eax,-0x20(%ebp)
	outb(addr_6845, 15);
  103d53:	a1 18 e2 10 00       	mov    0x10e218,%eax
  103d58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103d5b:	c6 45 f3 0f          	movb   $0xf,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  103d5f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  103d63:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103d66:	ee                   	out    %al,(%dx)
	pos |= inb(addr_6845 + 1);
  103d67:	a1 18 e2 10 00       	mov    0x10e218,%eax
  103d6c:	83 c0 01             	add    $0x1,%eax
  103d6f:	89 45 f8             	mov    %eax,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  103d72:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103d75:	89 c2                	mov    %eax,%edx
  103d77:	ec                   	in     (%dx),%al
  103d78:	88 45 ff             	mov    %al,-0x1(%ebp)
	return data;
  103d7b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
  103d7f:	0f b6 c0             	movzbl %al,%eax
  103d82:	09 45 e0             	or     %eax,-0x20(%ebp)

	crt_buf = (uint16_t*) cp;
  103d85:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103d88:	a3 1c e2 10 00       	mov    %eax,0x10e21c
	crt_pos = pos;
  103d8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103d90:	66 a3 20 e2 10 00    	mov    %ax,0x10e220
}
  103d96:	c9                   	leave  
  103d97:	c3                   	ret    

00103d98 <video_putc>:



void
video_putc(int c)
{
  103d98:	55                   	push   %ebp
  103d99:	89 e5                	mov    %esp,%ebp
  103d9b:	53                   	push   %ebx
  103d9c:	83 ec 44             	sub    $0x44,%esp
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
  103d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  103da2:	b0 00                	mov    $0x0,%al
  103da4:	85 c0                	test   %eax,%eax
  103da6:	75 07                	jne    103daf <video_putc+0x17>
		c |= 0x0700;
  103da8:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)

	switch (c & 0xff) {
  103daf:	8b 45 08             	mov    0x8(%ebp),%eax
  103db2:	25 ff 00 00 00       	and    $0xff,%eax
  103db7:	83 f8 09             	cmp    $0x9,%eax
  103dba:	0f 84 ae 00 00 00    	je     103e6e <video_putc+0xd6>
  103dc0:	83 f8 09             	cmp    $0x9,%eax
  103dc3:	7f 0a                	jg     103dcf <video_putc+0x37>
  103dc5:	83 f8 08             	cmp    $0x8,%eax
  103dc8:	74 14                	je     103dde <video_putc+0x46>
  103dca:	e9 dd 00 00 00       	jmp    103eac <video_putc+0x114>
  103dcf:	83 f8 0a             	cmp    $0xa,%eax
  103dd2:	74 4e                	je     103e22 <video_putc+0x8a>
  103dd4:	83 f8 0d             	cmp    $0xd,%eax
  103dd7:	74 59                	je     103e32 <video_putc+0x9a>
  103dd9:	e9 ce 00 00 00       	jmp    103eac <video_putc+0x114>
	case '\b':
		if (crt_pos > 0) {
  103dde:	0f b7 05 20 e2 10 00 	movzwl 0x10e220,%eax
  103de5:	66 85 c0             	test   %ax,%ax
  103de8:	0f 84 e4 00 00 00    	je     103ed2 <video_putc+0x13a>
			crt_pos--;
  103dee:	0f b7 05 20 e2 10 00 	movzwl 0x10e220,%eax
  103df5:	83 e8 01             	sub    $0x1,%eax
  103df8:	66 a3 20 e2 10 00    	mov    %ax,0x10e220
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
  103dfe:	a1 1c e2 10 00       	mov    0x10e21c,%eax
  103e03:	0f b7 15 20 e2 10 00 	movzwl 0x10e220,%edx
  103e0a:	0f b7 d2             	movzwl %dx,%edx
  103e0d:	01 d2                	add    %edx,%edx
  103e0f:	8d 14 10             	lea    (%eax,%edx,1),%edx
  103e12:	8b 45 08             	mov    0x8(%ebp),%eax
  103e15:	b0 00                	mov    $0x0,%al
  103e17:	83 c8 20             	or     $0x20,%eax
  103e1a:	66 89 02             	mov    %ax,(%edx)
		}
		break;
  103e1d:	e9 b1 00 00 00       	jmp    103ed3 <video_putc+0x13b>
	case '\n':
		crt_pos += CRT_COLS;
  103e22:	0f b7 05 20 e2 10 00 	movzwl 0x10e220,%eax
  103e29:	83 c0 50             	add    $0x50,%eax
  103e2c:	66 a3 20 e2 10 00    	mov    %ax,0x10e220
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
  103e32:	0f b7 1d 20 e2 10 00 	movzwl 0x10e220,%ebx
  103e39:	0f b7 0d 20 e2 10 00 	movzwl 0x10e220,%ecx
  103e40:	0f b7 c1             	movzwl %cx,%eax
  103e43:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  103e49:	c1 e8 10             	shr    $0x10,%eax
  103e4c:	89 c2                	mov    %eax,%edx
  103e4e:	66 c1 ea 06          	shr    $0x6,%dx
  103e52:	89 d0                	mov    %edx,%eax
  103e54:	c1 e0 02             	shl    $0x2,%eax
  103e57:	01 d0                	add    %edx,%eax
  103e59:	c1 e0 04             	shl    $0x4,%eax
  103e5c:	89 ca                	mov    %ecx,%edx
  103e5e:	66 29 c2             	sub    %ax,%dx
  103e61:	89 d8                	mov    %ebx,%eax
  103e63:	66 29 d0             	sub    %dx,%ax
  103e66:	66 a3 20 e2 10 00    	mov    %ax,0x10e220
		break;
  103e6c:	eb 65                	jmp    103ed3 <video_putc+0x13b>
	case '\t':
		video_putc(' ');
  103e6e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  103e75:	e8 1e ff ff ff       	call   103d98 <video_putc>
		video_putc(' ');
  103e7a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  103e81:	e8 12 ff ff ff       	call   103d98 <video_putc>
		video_putc(' ');
  103e86:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  103e8d:	e8 06 ff ff ff       	call   103d98 <video_putc>
		video_putc(' ');
  103e92:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  103e99:	e8 fa fe ff ff       	call   103d98 <video_putc>
		video_putc(' ');
  103e9e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  103ea5:	e8 ee fe ff ff       	call   103d98 <video_putc>
		break;
  103eaa:	eb 27                	jmp    103ed3 <video_putc+0x13b>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
  103eac:	8b 15 1c e2 10 00    	mov    0x10e21c,%edx
  103eb2:	0f b7 05 20 e2 10 00 	movzwl 0x10e220,%eax
  103eb9:	0f b7 c8             	movzwl %ax,%ecx
  103ebc:	01 c9                	add    %ecx,%ecx
  103ebe:	8d 0c 0a             	lea    (%edx,%ecx,1),%ecx
  103ec1:	8b 55 08             	mov    0x8(%ebp),%edx
  103ec4:	66 89 11             	mov    %dx,(%ecx)
  103ec7:	83 c0 01             	add    $0x1,%eax
  103eca:	66 a3 20 e2 10 00    	mov    %ax,0x10e220
  103ed0:	eb 01                	jmp    103ed3 <video_putc+0x13b>
	case '\b':
		if (crt_pos > 0) {
			crt_pos--;
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
		}
		break;
  103ed2:	90                   	nop
		crt_buf[crt_pos++] = c;		/* write the character */
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
  103ed3:	0f b7 05 20 e2 10 00 	movzwl 0x10e220,%eax
  103eda:	66 3d cf 07          	cmp    $0x7cf,%ax
  103ede:	76 5b                	jbe    103f3b <video_putc+0x1a3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS,
  103ee0:	a1 1c e2 10 00       	mov    0x10e21c,%eax
  103ee5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  103eeb:	a1 1c e2 10 00       	mov    0x10e21c,%eax
  103ef0:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  103ef7:	00 
  103ef8:	89 54 24 04          	mov    %edx,0x4(%esp)
  103efc:	89 04 24             	mov    %eax,(%esp)
  103eff:	e8 9c 15 00 00       	call   1054a0 <memmove>
			(CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
  103f04:	c7 45 d4 80 07 00 00 	movl   $0x780,-0x2c(%ebp)
  103f0b:	eb 15                	jmp    103f22 <video_putc+0x18a>
			crt_buf[i] = 0x0700 | ' ';
  103f0d:	a1 1c e2 10 00       	mov    0x10e21c,%eax
  103f12:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103f15:	01 d2                	add    %edx,%edx
  103f17:	01 d0                	add    %edx,%eax
  103f19:	66 c7 00 20 07       	movw   $0x720,(%eax)
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS,
			(CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
  103f1e:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
  103f22:	81 7d d4 cf 07 00 00 	cmpl   $0x7cf,-0x2c(%ebp)
  103f29:	7e e2                	jle    103f0d <video_putc+0x175>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
  103f2b:	0f b7 05 20 e2 10 00 	movzwl 0x10e220,%eax
  103f32:	83 e8 50             	sub    $0x50,%eax
  103f35:	66 a3 20 e2 10 00    	mov    %ax,0x10e220
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
  103f3b:	a1 18 e2 10 00       	mov    0x10e218,%eax
  103f40:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103f43:	c6 45 db 0e          	movb   $0xe,-0x25(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  103f47:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  103f4b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f4e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
  103f4f:	0f b7 05 20 e2 10 00 	movzwl 0x10e220,%eax
  103f56:	66 c1 e8 08          	shr    $0x8,%ax
  103f5a:	0f b6 c0             	movzbl %al,%eax
  103f5d:	8b 15 18 e2 10 00    	mov    0x10e218,%edx
  103f63:	83 c2 01             	add    $0x1,%edx
  103f66:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  103f69:	88 45 e3             	mov    %al,-0x1d(%ebp)
  103f6c:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  103f70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103f73:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
  103f74:	a1 18 e2 10 00       	mov    0x10e218,%eax
  103f79:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103f7c:	c6 45 eb 0f          	movb   $0xf,-0x15(%ebp)
  103f80:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  103f84:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103f87:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos);
  103f88:	0f b7 05 20 e2 10 00 	movzwl 0x10e220,%eax
  103f8f:	0f b6 c0             	movzbl %al,%eax
  103f92:	8b 15 18 e2 10 00    	mov    0x10e218,%edx
  103f98:	83 c2 01             	add    $0x1,%edx
  103f9b:	89 55 f4             	mov    %edx,-0xc(%ebp)
  103f9e:	88 45 f3             	mov    %al,-0xd(%ebp)
  103fa1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  103fa5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103fa8:	ee                   	out    %al,(%dx)
}
  103fa9:	83 c4 44             	add    $0x44,%esp
  103fac:	5b                   	pop    %ebx
  103fad:	5d                   	pop    %ebp
  103fae:	c3                   	ret    
  103faf:	90                   	nop

00103fb0 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
  103fb0:	55                   	push   %ebp
  103fb1:	89 e5                	mov    %esp,%ebp
  103fb3:	83 ec 38             	sub    $0x38,%esp
  103fb6:	c7 45 e4 64 00 00 00 	movl   $0x64,-0x1c(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  103fbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103fc0:	89 c2                	mov    %eax,%edx
  103fc2:	ec                   	in     (%dx),%al
  103fc3:	88 45 eb             	mov    %al,-0x15(%ebp)
	return data;
  103fc6:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
  103fca:	0f b6 c0             	movzbl %al,%eax
  103fcd:	83 e0 01             	and    $0x1,%eax
  103fd0:	85 c0                	test   %eax,%eax
  103fd2:	75 0a                	jne    103fde <kbd_proc_data+0x2e>
		return -1;
  103fd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  103fd9:	e9 5a 01 00 00       	jmp    104138 <kbd_proc_data+0x188>
  103fde:	c7 45 ec 60 00 00 00 	movl   $0x60,-0x14(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  103fe5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103fe8:	89 c2                	mov    %eax,%edx
  103fea:	ec                   	in     (%dx),%al
  103feb:	88 45 f2             	mov    %al,-0xe(%ebp)
	return data;
  103fee:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax

	data = inb(KBDATAP);
  103ff2:	88 45 e3             	mov    %al,-0x1d(%ebp)

	if (data == 0xE0) {
  103ff5:	80 7d e3 e0          	cmpb   $0xe0,-0x1d(%ebp)
  103ff9:	75 17                	jne    104012 <kbd_proc_data+0x62>
		// E0 escape character
		shift |= E0ESC;
  103ffb:	a1 24 e2 10 00       	mov    0x10e224,%eax
  104000:	83 c8 40             	or     $0x40,%eax
  104003:	a3 24 e2 10 00       	mov    %eax,0x10e224
		return 0;
  104008:	b8 00 00 00 00       	mov    $0x0,%eax
  10400d:	e9 26 01 00 00       	jmp    104138 <kbd_proc_data+0x188>
	} else if (data & 0x80) {
  104012:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  104016:	84 c0                	test   %al,%al
  104018:	79 47                	jns    104061 <kbd_proc_data+0xb1>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
  10401a:	a1 24 e2 10 00       	mov    0x10e224,%eax
  10401f:	83 e0 40             	and    $0x40,%eax
  104022:	85 c0                	test   %eax,%eax
  104024:	75 09                	jne    10402f <kbd_proc_data+0x7f>
  104026:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  10402a:	83 e0 7f             	and    $0x7f,%eax
  10402d:	eb 04                	jmp    104033 <kbd_proc_data+0x83>
  10402f:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  104033:	88 45 e3             	mov    %al,-0x1d(%ebp)
		shift &= ~(shiftcode[data] | E0ESC);
  104036:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  10403a:	0f b6 80 20 80 10 00 	movzbl 0x108020(%eax),%eax
  104041:	83 c8 40             	or     $0x40,%eax
  104044:	0f b6 c0             	movzbl %al,%eax
  104047:	f7 d0                	not    %eax
  104049:	89 c2                	mov    %eax,%edx
  10404b:	a1 24 e2 10 00       	mov    0x10e224,%eax
  104050:	21 d0                	and    %edx,%eax
  104052:	a3 24 e2 10 00       	mov    %eax,0x10e224
		return 0;
  104057:	b8 00 00 00 00       	mov    $0x0,%eax
  10405c:	e9 d7 00 00 00       	jmp    104138 <kbd_proc_data+0x188>
	} else if (shift & E0ESC) {
  104061:	a1 24 e2 10 00       	mov    0x10e224,%eax
  104066:	83 e0 40             	and    $0x40,%eax
  104069:	85 c0                	test   %eax,%eax
  10406b:	74 11                	je     10407e <kbd_proc_data+0xce>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
  10406d:	80 4d e3 80          	orb    $0x80,-0x1d(%ebp)
		shift &= ~E0ESC;
  104071:	a1 24 e2 10 00       	mov    0x10e224,%eax
  104076:	83 e0 bf             	and    $0xffffffbf,%eax
  104079:	a3 24 e2 10 00       	mov    %eax,0x10e224
	}

	shift |= shiftcode[data];
  10407e:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  104082:	0f b6 80 20 80 10 00 	movzbl 0x108020(%eax),%eax
  104089:	0f b6 d0             	movzbl %al,%edx
  10408c:	a1 24 e2 10 00       	mov    0x10e224,%eax
  104091:	09 d0                	or     %edx,%eax
  104093:	a3 24 e2 10 00       	mov    %eax,0x10e224
	shift ^= togglecode[data];
  104098:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  10409c:	0f b6 80 20 81 10 00 	movzbl 0x108120(%eax),%eax
  1040a3:	0f b6 d0             	movzbl %al,%edx
  1040a6:	a1 24 e2 10 00       	mov    0x10e224,%eax
  1040ab:	31 d0                	xor    %edx,%eax
  1040ad:	a3 24 e2 10 00       	mov    %eax,0x10e224

	c = charcode[shift & (CTL | SHIFT)][data];
  1040b2:	a1 24 e2 10 00       	mov    0x10e224,%eax
  1040b7:	83 e0 03             	and    $0x3,%eax
  1040ba:	8b 14 85 20 85 10 00 	mov    0x108520(,%eax,4),%edx
  1040c1:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1040c5:	8d 04 02             	lea    (%edx,%eax,1),%eax
  1040c8:	0f b6 00             	movzbl (%eax),%eax
  1040cb:	0f b6 c0             	movzbl %al,%eax
  1040ce:	89 45 dc             	mov    %eax,-0x24(%ebp)
	if (shift & CAPSLOCK) {
  1040d1:	a1 24 e2 10 00       	mov    0x10e224,%eax
  1040d6:	83 e0 08             	and    $0x8,%eax
  1040d9:	85 c0                	test   %eax,%eax
  1040db:	74 22                	je     1040ff <kbd_proc_data+0x14f>
		if ('a' <= c && c <= 'z')
  1040dd:	83 7d dc 60          	cmpl   $0x60,-0x24(%ebp)
  1040e1:	7e 0c                	jle    1040ef <kbd_proc_data+0x13f>
  1040e3:	83 7d dc 7a          	cmpl   $0x7a,-0x24(%ebp)
  1040e7:	7f 06                	jg     1040ef <kbd_proc_data+0x13f>
			c += 'A' - 'a';
  1040e9:	83 6d dc 20          	subl   $0x20,-0x24(%ebp)
	shift |= shiftcode[data];
	shift ^= togglecode[data];

	c = charcode[shift & (CTL | SHIFT)][data];
	if (shift & CAPSLOCK) {
		if ('a' <= c && c <= 'z')
  1040ed:	eb 10                	jmp    1040ff <kbd_proc_data+0x14f>
			c += 'A' - 'a';
		else if ('A' <= c && c <= 'Z')
  1040ef:	83 7d dc 40          	cmpl   $0x40,-0x24(%ebp)
  1040f3:	7e 0a                	jle    1040ff <kbd_proc_data+0x14f>
  1040f5:	83 7d dc 5a          	cmpl   $0x5a,-0x24(%ebp)
  1040f9:	7f 04                	jg     1040ff <kbd_proc_data+0x14f>
			c += 'a' - 'A';
  1040fb:	83 45 dc 20          	addl   $0x20,-0x24(%ebp)
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1040ff:	a1 24 e2 10 00       	mov    0x10e224,%eax
  104104:	f7 d0                	not    %eax
  104106:	83 e0 06             	and    $0x6,%eax
  104109:	85 c0                	test   %eax,%eax
  10410b:	75 28                	jne    104135 <kbd_proc_data+0x185>
  10410d:	81 7d dc e9 00 00 00 	cmpl   $0xe9,-0x24(%ebp)
  104114:	75 1f                	jne    104135 <kbd_proc_data+0x185>
		cprintf("Rebooting!\n");
  104116:	c7 04 24 3f 68 10 00 	movl   $0x10683f,(%esp)
  10411d:	e8 23 11 00 00       	call   105245 <cprintf>
  104122:	c7 45 f4 92 00 00 00 	movl   $0x92,-0xc(%ebp)
  104129:	c6 45 f3 03          	movb   $0x3,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  10412d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  104131:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104134:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
  104135:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
  104138:	c9                   	leave  
  104139:	c3                   	ret    

0010413a <kbd_intr>:

void
kbd_intr(void)
{
  10413a:	55                   	push   %ebp
  10413b:	89 e5                	mov    %esp,%ebp
  10413d:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
  104140:	c7 04 24 b0 3f 10 00 	movl   $0x103fb0,(%esp)
  104147:	e8 f3 c0 ff ff       	call   10023f <cons_intr>
}
  10414c:	c9                   	leave  
  10414d:	c3                   	ret    

0010414e <kbd_init>:

void
kbd_init(void)
{
  10414e:	55                   	push   %ebp
  10414f:	89 e5                	mov    %esp,%ebp
}
  104151:	5d                   	pop    %ebp
  104152:	c3                   	ret    
  104153:	90                   	nop

00104154 <delay>:


// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
  104154:	55                   	push   %ebp
  104155:	89 e5                	mov    %esp,%ebp
  104157:	83 ec 20             	sub    $0x20,%esp
  10415a:	c7 45 e0 84 00 00 00 	movl   $0x84,-0x20(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  104161:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104164:	89 c2                	mov    %eax,%edx
  104166:	ec                   	in     (%dx),%al
  104167:	88 45 e7             	mov    %al,-0x19(%ebp)
	return data;
  10416a:	c7 45 e8 84 00 00 00 	movl   $0x84,-0x18(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  104171:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104174:	89 c2                	mov    %eax,%edx
  104176:	ec                   	in     (%dx),%al
  104177:	88 45 ef             	mov    %al,-0x11(%ebp)
	return data;
  10417a:	c7 45 f0 84 00 00 00 	movl   $0x84,-0x10(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  104181:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104184:	89 c2                	mov    %eax,%edx
  104186:	ec                   	in     (%dx),%al
  104187:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
  10418a:	c7 45 f8 84 00 00 00 	movl   $0x84,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  104191:	8b 45 f8             	mov    -0x8(%ebp),%eax
  104194:	89 c2                	mov    %eax,%edx
  104196:	ec                   	in     (%dx),%al
  104197:	88 45 ff             	mov    %al,-0x1(%ebp)
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
  10419a:	c9                   	leave  
  10419b:	c3                   	ret    

0010419c <serial_proc_data>:

static int
serial_proc_data(void)
{
  10419c:	55                   	push   %ebp
  10419d:	89 e5                	mov    %esp,%ebp
  10419f:	83 ec 10             	sub    $0x10,%esp
  1041a2:	c7 45 f0 fd 03 00 00 	movl   $0x3fd,-0x10(%ebp)
  1041a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1041ac:	89 c2                	mov    %eax,%edx
  1041ae:	ec                   	in     (%dx),%al
  1041af:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
  1041b2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
  1041b6:	0f b6 c0             	movzbl %al,%eax
  1041b9:	83 e0 01             	and    $0x1,%eax
  1041bc:	85 c0                	test   %eax,%eax
  1041be:	75 07                	jne    1041c7 <serial_proc_data+0x2b>
		return -1;
  1041c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1041c5:	eb 17                	jmp    1041de <serial_proc_data+0x42>
  1041c7:	c7 45 f8 f8 03 00 00 	movl   $0x3f8,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1041ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1041d1:	89 c2                	mov    %eax,%edx
  1041d3:	ec                   	in     (%dx),%al
  1041d4:	88 45 ff             	mov    %al,-0x1(%ebp)
	return data;
  1041d7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
	return inb(COM1+COM_RX);
  1041db:	0f b6 c0             	movzbl %al,%eax
}
  1041de:	c9                   	leave  
  1041df:	c3                   	ret    

001041e0 <serial_intr>:

void
serial_intr(void)
{
  1041e0:	55                   	push   %ebp
  1041e1:	89 e5                	mov    %esp,%ebp
  1041e3:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
  1041e6:	a1 44 e9 10 00       	mov    0x10e944,%eax
  1041eb:	85 c0                	test   %eax,%eax
  1041ed:	74 0c                	je     1041fb <serial_intr+0x1b>
		cons_intr(serial_proc_data);
  1041ef:	c7 04 24 9c 41 10 00 	movl   $0x10419c,(%esp)
  1041f6:	e8 44 c0 ff ff       	call   10023f <cons_intr>
}
  1041fb:	c9                   	leave  
  1041fc:	c3                   	ret    

001041fd <serial_putc>:

void
serial_putc(int c)
{
  1041fd:	55                   	push   %ebp
  1041fe:	89 e5                	mov    %esp,%ebp
  104200:	83 ec 10             	sub    $0x10,%esp
	if (!serial_exists)
  104203:	a1 44 e9 10 00       	mov    0x10e944,%eax
  104208:	85 c0                	test   %eax,%eax
  10420a:	74 53                	je     10425f <serial_putc+0x62>
		return;

	int i;
	for (i = 0;
  10420c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  104213:	eb 09                	jmp    10421e <serial_putc+0x21>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
  104215:	e8 3a ff ff ff       	call   104154 <delay>
		return;

	int i;
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
  10421a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  10421e:	c7 45 f4 fd 03 00 00 	movl   $0x3fd,-0xc(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  104225:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104228:	89 c2                	mov    %eax,%edx
  10422a:	ec                   	in     (%dx),%al
  10422b:	88 45 fa             	mov    %al,-0x6(%ebp)
	return data;
  10422e:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
	if (!serial_exists)
		return;

	int i;
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  104232:	0f b6 c0             	movzbl %al,%eax
  104235:	83 e0 20             	and    $0x20,%eax
{
	if (!serial_exists)
		return;

	int i;
	for (i = 0;
  104238:	85 c0                	test   %eax,%eax
  10423a:	75 09                	jne    104245 <serial_putc+0x48>
  10423c:	81 7d f0 ff 31 00 00 	cmpl   $0x31ff,-0x10(%ebp)
  104243:	7e d0                	jle    104215 <serial_putc+0x18>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
  104245:	8b 45 08             	mov    0x8(%ebp),%eax
  104248:	0f b6 c0             	movzbl %al,%eax
  10424b:	c7 45 fc f8 03 00 00 	movl   $0x3f8,-0x4(%ebp)
  104252:	88 45 fb             	mov    %al,-0x5(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  104255:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  104259:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10425c:	ee                   	out    %al,(%dx)
  10425d:	eb 01                	jmp    104260 <serial_putc+0x63>

void
serial_putc(int c)
{
	if (!serial_exists)
		return;
  10425f:	90                   	nop
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
}
  104260:	c9                   	leave  
  104261:	c3                   	ret    

00104262 <serial_init>:

void
serial_init(void)
{
  104262:	55                   	push   %ebp
  104263:	89 e5                	mov    %esp,%ebp
  104265:	83 ec 50             	sub    $0x50,%esp
  104268:	c7 45 b4 fa 03 00 00 	movl   $0x3fa,-0x4c(%ebp)
  10426f:	c6 45 b3 00          	movb   $0x0,-0x4d(%ebp)
  104273:	0f b6 45 b3          	movzbl -0x4d(%ebp),%eax
  104277:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  10427a:	ee                   	out    %al,(%dx)
  10427b:	c7 45 bc fb 03 00 00 	movl   $0x3fb,-0x44(%ebp)
  104282:	c6 45 bb 80          	movb   $0x80,-0x45(%ebp)
  104286:	0f b6 45 bb          	movzbl -0x45(%ebp),%eax
  10428a:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10428d:	ee                   	out    %al,(%dx)
  10428e:	c7 45 c4 f8 03 00 00 	movl   $0x3f8,-0x3c(%ebp)
  104295:	c6 45 c3 0c          	movb   $0xc,-0x3d(%ebp)
  104299:	0f b6 45 c3          	movzbl -0x3d(%ebp),%eax
  10429d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1042a0:	ee                   	out    %al,(%dx)
  1042a1:	c7 45 cc f9 03 00 00 	movl   $0x3f9,-0x34(%ebp)
  1042a8:	c6 45 cb 00          	movb   $0x0,-0x35(%ebp)
  1042ac:	0f b6 45 cb          	movzbl -0x35(%ebp),%eax
  1042b0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1042b3:	ee                   	out    %al,(%dx)
  1042b4:	c7 45 d4 fb 03 00 00 	movl   $0x3fb,-0x2c(%ebp)
  1042bb:	c6 45 d3 03          	movb   $0x3,-0x2d(%ebp)
  1042bf:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
  1042c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1042c6:	ee                   	out    %al,(%dx)
  1042c7:	c7 45 dc fc 03 00 00 	movl   $0x3fc,-0x24(%ebp)
  1042ce:	c6 45 db 00          	movb   $0x0,-0x25(%ebp)
  1042d2:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  1042d6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1042d9:	ee                   	out    %al,(%dx)
  1042da:	c7 45 e4 f9 03 00 00 	movl   $0x3f9,-0x1c(%ebp)
  1042e1:	c6 45 e3 01          	movb   $0x1,-0x1d(%ebp)
  1042e5:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1042e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1042ec:	ee                   	out    %al,(%dx)
  1042ed:	c7 45 e8 fd 03 00 00 	movl   $0x3fd,-0x18(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1042f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1042f7:	89 c2                	mov    %eax,%edx
  1042f9:	ec                   	in     (%dx),%al
  1042fa:	88 45 ef             	mov    %al,-0x11(%ebp)
	return data;
  1042fd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
  104301:	3c ff                	cmp    $0xff,%al
  104303:	0f 95 c0             	setne  %al
  104306:	0f b6 c0             	movzbl %al,%eax
  104309:	a3 44 e9 10 00       	mov    %eax,0x10e944
  10430e:	c7 45 f0 fa 03 00 00 	movl   $0x3fa,-0x10(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  104315:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104318:	89 c2                	mov    %eax,%edx
  10431a:	ec                   	in     (%dx),%al
  10431b:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
  10431e:	c7 45 f8 f8 03 00 00 	movl   $0x3f8,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  104325:	8b 45 f8             	mov    -0x8(%ebp),%eax
  104328:	89 c2                	mov    %eax,%edx
  10432a:	ec                   	in     (%dx),%al
  10432b:	88 45 ff             	mov    %al,-0x1(%ebp)
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);
}
  10432e:	c9                   	leave  
  10432f:	c3                   	ret    

00104330 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
  104330:	55                   	push   %ebp
  104331:	89 e5                	mov    %esp,%ebp
  104333:	81 ec 88 00 00 00    	sub    $0x88,%esp
	if (didinit)		// only do once on bootstrap CPU
  104339:	a1 28 e2 10 00       	mov    0x10e228,%eax
  10433e:	85 c0                	test   %eax,%eax
  104340:	0f 85 35 01 00 00    	jne    10447b <pic_init+0x14b>
		return;
	didinit = 1;
  104346:	c7 05 28 e2 10 00 01 	movl   $0x1,0x10e228
  10434d:	00 00 00 
  104350:	c7 45 8c 21 00 00 00 	movl   $0x21,-0x74(%ebp)
  104357:	c6 45 8b ff          	movb   $0xff,-0x75(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  10435b:	0f b6 45 8b          	movzbl -0x75(%ebp),%eax
  10435f:	8b 55 8c             	mov    -0x74(%ebp),%edx
  104362:	ee                   	out    %al,(%dx)
  104363:	c7 45 94 a1 00 00 00 	movl   $0xa1,-0x6c(%ebp)
  10436a:	c6 45 93 ff          	movb   $0xff,-0x6d(%ebp)
  10436e:	0f b6 45 93          	movzbl -0x6d(%ebp),%eax
  104372:	8b 55 94             	mov    -0x6c(%ebp),%edx
  104375:	ee                   	out    %al,(%dx)
  104376:	c7 45 9c 20 00 00 00 	movl   $0x20,-0x64(%ebp)
  10437d:	c6 45 9b 11          	movb   $0x11,-0x65(%ebp)
  104381:	0f b6 45 9b          	movzbl -0x65(%ebp),%eax
  104385:	8b 55 9c             	mov    -0x64(%ebp),%edx
  104388:	ee                   	out    %al,(%dx)
  104389:	c7 45 a4 21 00 00 00 	movl   $0x21,-0x5c(%ebp)
  104390:	c6 45 a3 20          	movb   $0x20,-0x5d(%ebp)
  104394:	0f b6 45 a3          	movzbl -0x5d(%ebp),%eax
  104398:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  10439b:	ee                   	out    %al,(%dx)
  10439c:	c7 45 ac 21 00 00 00 	movl   $0x21,-0x54(%ebp)
  1043a3:	c6 45 ab 04          	movb   $0x4,-0x55(%ebp)
  1043a7:	0f b6 45 ab          	movzbl -0x55(%ebp),%eax
  1043ab:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1043ae:	ee                   	out    %al,(%dx)
  1043af:	c7 45 b4 21 00 00 00 	movl   $0x21,-0x4c(%ebp)
  1043b6:	c6 45 b3 03          	movb   $0x3,-0x4d(%ebp)
  1043ba:	0f b6 45 b3          	movzbl -0x4d(%ebp),%eax
  1043be:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  1043c1:	ee                   	out    %al,(%dx)
  1043c2:	c7 45 bc a0 00 00 00 	movl   $0xa0,-0x44(%ebp)
  1043c9:	c6 45 bb 11          	movb   $0x11,-0x45(%ebp)
  1043cd:	0f b6 45 bb          	movzbl -0x45(%ebp),%eax
  1043d1:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1043d4:	ee                   	out    %al,(%dx)
  1043d5:	c7 45 c4 a1 00 00 00 	movl   $0xa1,-0x3c(%ebp)
  1043dc:	c6 45 c3 28          	movb   $0x28,-0x3d(%ebp)
  1043e0:	0f b6 45 c3          	movzbl -0x3d(%ebp),%eax
  1043e4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1043e7:	ee                   	out    %al,(%dx)
  1043e8:	c7 45 cc a1 00 00 00 	movl   $0xa1,-0x34(%ebp)
  1043ef:	c6 45 cb 02          	movb   $0x2,-0x35(%ebp)
  1043f3:	0f b6 45 cb          	movzbl -0x35(%ebp),%eax
  1043f7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1043fa:	ee                   	out    %al,(%dx)
  1043fb:	c7 45 d4 a1 00 00 00 	movl   $0xa1,-0x2c(%ebp)
  104402:	c6 45 d3 01          	movb   $0x1,-0x2d(%ebp)
  104406:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
  10440a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10440d:	ee                   	out    %al,(%dx)
  10440e:	c7 45 dc 20 00 00 00 	movl   $0x20,-0x24(%ebp)
  104415:	c6 45 db 68          	movb   $0x68,-0x25(%ebp)
  104419:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  10441d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104420:	ee                   	out    %al,(%dx)
  104421:	c7 45 e4 20 00 00 00 	movl   $0x20,-0x1c(%ebp)
  104428:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
  10442c:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  104430:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104433:	ee                   	out    %al,(%dx)
  104434:	c7 45 ec a0 00 00 00 	movl   $0xa0,-0x14(%ebp)
  10443b:	c6 45 eb 68          	movb   $0x68,-0x15(%ebp)
  10443f:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  104443:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104446:	ee                   	out    %al,(%dx)
  104447:	c7 45 f4 a0 00 00 00 	movl   $0xa0,-0xc(%ebp)
  10444e:	c6 45 f3 0a          	movb   $0xa,-0xd(%ebp)
  104452:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  104456:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104459:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irqmask != 0xFFFF)
  10445a:	0f b7 05 30 85 10 00 	movzwl 0x108530,%eax
  104461:	66 83 f8 ff          	cmp    $0xffff,%ax
  104465:	74 15                	je     10447c <pic_init+0x14c>
		pic_setmask(irqmask);
  104467:	0f b7 05 30 85 10 00 	movzwl 0x108530,%eax
  10446e:	0f b7 c0             	movzwl %ax,%eax
  104471:	89 04 24             	mov    %eax,(%esp)
  104474:	e8 05 00 00 00       	call   10447e <pic_setmask>
  104479:	eb 01                	jmp    10447c <pic_init+0x14c>
/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	if (didinit)		// only do once on bootstrap CPU
		return;
  10447b:	90                   	nop
	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irqmask != 0xFFFF)
		pic_setmask(irqmask);
}
  10447c:	c9                   	leave  
  10447d:	c3                   	ret    

0010447e <pic_setmask>:

void
pic_setmask(uint16_t mask)
{
  10447e:	55                   	push   %ebp
  10447f:	89 e5                	mov    %esp,%ebp
  104481:	83 ec 14             	sub    $0x14,%esp
  104484:	8b 45 08             	mov    0x8(%ebp),%eax
  104487:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
	irqmask = mask;
  10448b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10448f:	66 a3 30 85 10 00    	mov    %ax,0x108530
	outb(IO_PIC1+1, (char)mask);
  104495:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  104499:	0f b6 c0             	movzbl %al,%eax
  10449c:	c7 45 f4 21 00 00 00 	movl   $0x21,-0xc(%ebp)
  1044a3:	88 45 f3             	mov    %al,-0xd(%ebp)
  1044a6:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1044aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1044ad:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
  1044ae:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1044b2:	66 c1 e8 08          	shr    $0x8,%ax
  1044b6:	0f b6 c0             	movzbl %al,%eax
  1044b9:	c7 45 fc a1 00 00 00 	movl   $0xa1,-0x4(%ebp)
  1044c0:	88 45 fb             	mov    %al,-0x5(%ebp)
  1044c3:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  1044c7:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1044ca:	ee                   	out    %al,(%dx)
}
  1044cb:	c9                   	leave  
  1044cc:	c3                   	ret    

001044cd <pic_enable>:

void
pic_enable(int irq)
{
  1044cd:	55                   	push   %ebp
  1044ce:	89 e5                	mov    %esp,%ebp
  1044d0:	53                   	push   %ebx
  1044d1:	83 ec 04             	sub    $0x4,%esp
	pic_setmask(irqmask & ~(1 << irq));
  1044d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1044d7:	ba 01 00 00 00       	mov    $0x1,%edx
  1044dc:	89 d3                	mov    %edx,%ebx
  1044de:	89 c1                	mov    %eax,%ecx
  1044e0:	d3 e3                	shl    %cl,%ebx
  1044e2:	89 d8                	mov    %ebx,%eax
  1044e4:	89 c2                	mov    %eax,%edx
  1044e6:	f7 d2                	not    %edx
  1044e8:	0f b7 05 30 85 10 00 	movzwl 0x108530,%eax
  1044ef:	21 d0                	and    %edx,%eax
  1044f1:	0f b7 c0             	movzwl %ax,%eax
  1044f4:	89 04 24             	mov    %eax,(%esp)
  1044f7:	e8 82 ff ff ff       	call   10447e <pic_setmask>
}
  1044fc:	83 c4 04             	add    $0x4,%esp
  1044ff:	5b                   	pop    %ebx
  104500:	5d                   	pop    %ebp
  104501:	c3                   	ret    
  104502:	90                   	nop
  104503:	90                   	nop

00104504 <nvram_read>:
#include <dev/nvram.h>


unsigned
nvram_read(unsigned reg)
{
  104504:	55                   	push   %ebp
  104505:	89 e5                	mov    %esp,%ebp
  104507:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
  10450a:	8b 45 08             	mov    0x8(%ebp),%eax
  10450d:	0f b6 c0             	movzbl %al,%eax
  104510:	c7 45 f4 70 00 00 00 	movl   $0x70,-0xc(%ebp)
  104517:	88 45 f3             	mov    %al,-0xd(%ebp)
  10451a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10451e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104521:	ee                   	out    %al,(%dx)
  104522:	c7 45 f8 71 00 00 00 	movl   $0x71,-0x8(%ebp)

static gcc_inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  104529:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10452c:	89 c2                	mov    %eax,%edx
  10452e:	ec                   	in     (%dx),%al
  10452f:	88 45 ff             	mov    %al,-0x1(%ebp)
	return data;
  104532:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
	return inb(IO_RTC+1);
  104536:	0f b6 c0             	movzbl %al,%eax
}
  104539:	c9                   	leave  
  10453a:	c3                   	ret    

0010453b <nvram_read16>:

unsigned
nvram_read16(unsigned r)
{
  10453b:	55                   	push   %ebp
  10453c:	89 e5                	mov    %esp,%ebp
  10453e:	53                   	push   %ebx
  10453f:	83 ec 04             	sub    $0x4,%esp
	return nvram_read(r) | (nvram_read(r + 1) << 8);
  104542:	8b 45 08             	mov    0x8(%ebp),%eax
  104545:	89 04 24             	mov    %eax,(%esp)
  104548:	e8 b7 ff ff ff       	call   104504 <nvram_read>
  10454d:	89 c3                	mov    %eax,%ebx
  10454f:	8b 45 08             	mov    0x8(%ebp),%eax
  104552:	83 c0 01             	add    $0x1,%eax
  104555:	89 04 24             	mov    %eax,(%esp)
  104558:	e8 a7 ff ff ff       	call   104504 <nvram_read>
  10455d:	c1 e0 08             	shl    $0x8,%eax
  104560:	09 d8                	or     %ebx,%eax
}
  104562:	83 c4 04             	add    $0x4,%esp
  104565:	5b                   	pop    %ebx
  104566:	5d                   	pop    %ebp
  104567:	c3                   	ret    

00104568 <nvram_write>:

void
nvram_write(unsigned reg, unsigned datum)
{
  104568:	55                   	push   %ebp
  104569:	89 e5                	mov    %esp,%ebp
  10456b:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
  10456e:	8b 45 08             	mov    0x8(%ebp),%eax
  104571:	0f b6 c0             	movzbl %al,%eax
  104574:	c7 45 f4 70 00 00 00 	movl   $0x70,-0xc(%ebp)
  10457b:	88 45 f3             	mov    %al,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  10457e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  104582:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104585:	ee                   	out    %al,(%dx)
	outb(IO_RTC+1, datum);
  104586:	8b 45 0c             	mov    0xc(%ebp),%eax
  104589:	0f b6 c0             	movzbl %al,%eax
  10458c:	c7 45 fc 71 00 00 00 	movl   $0x71,-0x4(%ebp)
  104593:	88 45 fb             	mov    %al,-0x5(%ebp)
  104596:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  10459a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10459d:	ee                   	out    %al,(%dx)
}
  10459e:	c9                   	leave  
  10459f:	c3                   	ret    

001045a0 <cpu_cur>:
#define cpu_disabled(c)		0

// Find the CPU struct representing the current CPU.
// It always resides at the bottom of the page containing the CPU's stack.
static inline cpu *
cpu_cur() {
  1045a0:	55                   	push   %ebp
  1045a1:	89 e5                	mov    %esp,%ebp
  1045a3:	83 ec 28             	sub    $0x28,%esp

static gcc_inline uint32_t
read_esp(void)
{
        uint32_t esp;
        __asm __volatile("movl %%esp,%0" : "=rm" (esp));
  1045a6:	89 65 f4             	mov    %esp,-0xc(%ebp)
        return esp;
  1045a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
	cpu *c = (cpu*)ROUNDDOWN(read_esp(), PAGESIZE);
  1045ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1045af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1045b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1045b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(c->magic == CPU_MAGIC);
  1045ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1045bd:	8b 80 b8 00 00 00    	mov    0xb8(%eax),%eax
  1045c3:	3d 32 54 76 98       	cmp    $0x98765432,%eax
  1045c8:	74 24                	je     1045ee <cpu_cur+0x4e>
  1045ca:	c7 44 24 0c 4b 68 10 	movl   $0x10684b,0xc(%esp)
  1045d1:	00 
  1045d2:	c7 44 24 08 61 68 10 	movl   $0x106861,0x8(%esp)
  1045d9:	00 
  1045da:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  1045e1:	00 
  1045e2:	c7 04 24 76 68 10 00 	movl   $0x106876,(%esp)
  1045e9:	e8 1e be ff ff       	call   10040c <debug_panic>
	return c;
  1045ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  1045f1:	c9                   	leave  
  1045f2:	c3                   	ret    

001045f3 <lapicw>:
volatile uint32_t *lapic;  // Initialized in mp.c


static void
lapicw(int index, int value)
{
  1045f3:	55                   	push   %ebp
  1045f4:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
  1045f6:	a1 48 e9 10 00       	mov    0x10e948,%eax
  1045fb:	8b 55 08             	mov    0x8(%ebp),%edx
  1045fe:	c1 e2 02             	shl    $0x2,%edx
  104601:	8d 14 10             	lea    (%eax,%edx,1),%edx
  104604:	8b 45 0c             	mov    0xc(%ebp),%eax
  104607:	89 02                	mov    %eax,(%edx)
	lapic[ID];  // wait for write to finish, by reading
  104609:	a1 48 e9 10 00       	mov    0x10e948,%eax
  10460e:	83 c0 20             	add    $0x20,%eax
  104611:	8b 00                	mov    (%eax),%eax
}
  104613:	5d                   	pop    %ebp
  104614:	c3                   	ret    

00104615 <lapic_init>:

void
lapic_init()
{
  104615:	55                   	push   %ebp
  104616:	89 e5                	mov    %esp,%ebp
  104618:	83 ec 08             	sub    $0x8,%esp
	if (!lapic) 
  10461b:	a1 48 e9 10 00       	mov    0x10e948,%eax
  104620:	85 c0                	test   %eax,%eax
  104622:	0f 84 82 01 00 00    	je     1047aa <lapic_init+0x195>
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
  104628:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  10462f:	00 
  104630:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
  104637:	e8 b7 ff ff ff       	call   1045f3 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	lapicw(TDCR, X1);
  10463c:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  104643:	00 
  104644:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
  10464b:	e8 a3 ff ff ff       	call   1045f3 <lapicw>
	lapicw(TIMER, PERIODIC | T_LTIMER);
  104650:	c7 44 24 04 31 00 02 	movl   $0x20031,0x4(%esp)
  104657:	00 
  104658:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
  10465f:	e8 8f ff ff ff       	call   1045f3 <lapicw>

	// If we cared more about precise timekeeping,
	// we would calibrate TICR with another time source such as the PIT.
	lapicw(TICR, 10000000);
  104664:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
  10466b:	00 
  10466c:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
  104673:	e8 7b ff ff ff       	call   1045f3 <lapicw>

	// Disable logical interrupt lines.
	lapicw(LINT0, MASKED);
  104678:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
  10467f:	00 
  104680:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
  104687:	e8 67 ff ff ff       	call   1045f3 <lapicw>
	lapicw(LINT1, MASKED);
  10468c:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
  104693:	00 
  104694:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
  10469b:	e8 53 ff ff ff       	call   1045f3 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
  1046a0:	a1 48 e9 10 00       	mov    0x10e948,%eax
  1046a5:	83 c0 30             	add    $0x30,%eax
  1046a8:	8b 00                	mov    (%eax),%eax
  1046aa:	c1 e8 10             	shr    $0x10,%eax
  1046ad:	25 ff 00 00 00       	and    $0xff,%eax
  1046b2:	83 f8 03             	cmp    $0x3,%eax
  1046b5:	76 14                	jbe    1046cb <lapic_init+0xb6>
		lapicw(PCINT, MASKED);
  1046b7:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
  1046be:	00 
  1046bf:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
  1046c6:	e8 28 ff ff ff       	call   1045f3 <lapicw>

	// Map other interrupts to appropriate vectors.
	lapicw(ERROR, T_LERROR);
  1046cb:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  1046d2:	00 
  1046d3:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
  1046da:	e8 14 ff ff ff       	call   1045f3 <lapicw>

	// Set up to lowest-priority, "anycast" interrupts
	lapicw(LDR, 0xff << 24);	// Accept all interrupts
  1046df:	c7 44 24 04 00 00 00 	movl   $0xff000000,0x4(%esp)
  1046e6:	ff 
  1046e7:	c7 04 24 34 00 00 00 	movl   $0x34,(%esp)
  1046ee:	e8 00 ff ff ff       	call   1045f3 <lapicw>
	lapicw(DFR, 0xf << 28);		// Flat model
  1046f3:	c7 44 24 04 00 00 00 	movl   $0xf0000000,0x4(%esp)
  1046fa:	f0 
  1046fb:	c7 04 24 38 00 00 00 	movl   $0x38,(%esp)
  104702:	e8 ec fe ff ff       	call   1045f3 <lapicw>
	lapicw(TPR, 0x00);		// Task priority 0, no intrs masked
  104707:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10470e:	00 
  10470f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  104716:	e8 d8 fe ff ff       	call   1045f3 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
  10471b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104722:	00 
  104723:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
  10472a:	e8 c4 fe ff ff       	call   1045f3 <lapicw>
	lapicw(ESR, 0);
  10472f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104736:	00 
  104737:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
  10473e:	e8 b0 fe ff ff       	call   1045f3 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
  104743:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10474a:	00 
  10474b:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
  104752:	e8 9c fe ff ff       	call   1045f3 <lapicw>

	// Send an Init Level De-Assert to synchronise arbitration ID's.
	lapicw(ICRHI, 0);
  104757:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10475e:	00 
  10475f:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
  104766:	e8 88 fe ff ff       	call   1045f3 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
  10476b:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
  104772:	00 
  104773:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
  10477a:	e8 74 fe ff ff       	call   1045f3 <lapicw>
	while(lapic[ICRLO] & DELIVS)
  10477f:	a1 48 e9 10 00       	mov    0x10e948,%eax
  104784:	05 00 03 00 00       	add    $0x300,%eax
  104789:	8b 00                	mov    (%eax),%eax
  10478b:	25 00 10 00 00       	and    $0x1000,%eax
  104790:	85 c0                	test   %eax,%eax
  104792:	75 eb                	jne    10477f <lapic_init+0x16a>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
  104794:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10479b:	00 
  10479c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1047a3:	e8 4b fe ff ff       	call   1045f3 <lapicw>
  1047a8:	eb 01                	jmp    1047ab <lapic_init+0x196>

void
lapic_init()
{
	if (!lapic) 
		return;
  1047aa:	90                   	nop
	while(lapic[ICRLO] & DELIVS)
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
}
  1047ab:	c9                   	leave  
  1047ac:	c3                   	ret    

001047ad <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
  1047ad:	55                   	push   %ebp
  1047ae:	89 e5                	mov    %esp,%ebp
  1047b0:	83 ec 08             	sub    $0x8,%esp
	if (lapic)
  1047b3:	a1 48 e9 10 00       	mov    0x10e948,%eax
  1047b8:	85 c0                	test   %eax,%eax
  1047ba:	74 14                	je     1047d0 <lapic_eoi+0x23>
		lapicw(EOI, 0);
  1047bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1047c3:	00 
  1047c4:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
  1047cb:	e8 23 fe ff ff       	call   1045f3 <lapicw>
}
  1047d0:	c9                   	leave  
  1047d1:	c3                   	ret    

001047d2 <lapic_errintr>:

void lapic_errintr(void)
{
  1047d2:	55                   	push   %ebp
  1047d3:	89 e5                	mov    %esp,%ebp
  1047d5:	53                   	push   %ebx
  1047d6:	83 ec 24             	sub    $0x24,%esp
	lapic_eoi();	// Acknowledge interrupt
  1047d9:	e8 cf ff ff ff       	call   1047ad <lapic_eoi>
	lapicw(ESR, 0);	// Trigger update of ESR by writing anything
  1047de:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1047e5:	00 
  1047e6:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
  1047ed:	e8 01 fe ff ff       	call   1045f3 <lapicw>
	warn("CPU%d LAPIC error: ESR %x", cpu_cur()->id, lapic[ESR]);
  1047f2:	a1 48 e9 10 00       	mov    0x10e948,%eax
  1047f7:	05 80 02 00 00       	add    $0x280,%eax
  1047fc:	8b 18                	mov    (%eax),%ebx
  1047fe:	e8 9d fd ff ff       	call   1045a0 <cpu_cur>
  104803:	0f b6 80 ac 00 00 00 	movzbl 0xac(%eax),%eax
  10480a:	0f b6 c0             	movzbl %al,%eax
  10480d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  104811:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104815:	c7 44 24 08 83 68 10 	movl   $0x106883,0x8(%esp)
  10481c:	00 
  10481d:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  104824:	00 
  104825:	c7 04 24 9d 68 10 00 	movl   $0x10689d,(%esp)
  10482c:	e8 9a bc ff ff       	call   1004cb <debug_warn>
}
  104831:	83 c4 24             	add    $0x24,%esp
  104834:	5b                   	pop    %ebx
  104835:	5d                   	pop    %ebp
  104836:	c3                   	ret    

00104837 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
  104837:	55                   	push   %ebp
  104838:	89 e5                	mov    %esp,%ebp
}
  10483a:	5d                   	pop    %ebp
  10483b:	c3                   	ret    

0010483c <lapic_startcpu>:

// Start additional processor running bootstrap code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startcpu(uint8_t apicid, uint32_t addr)
{
  10483c:	55                   	push   %ebp
  10483d:	89 e5                	mov    %esp,%ebp
  10483f:	83 ec 2c             	sub    $0x2c,%esp
  104842:	8b 45 08             	mov    0x8(%ebp),%eax
  104845:	88 45 dc             	mov    %al,-0x24(%ebp)
  104848:	c7 45 f4 70 00 00 00 	movl   $0x70,-0xc(%ebp)
  10484f:	c6 45 f3 0f          	movb   $0xf,-0xd(%ebp)
}

static gcc_inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  104853:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  104857:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10485a:	ee                   	out    %al,(%dx)
  10485b:	c7 45 fc 71 00 00 00 	movl   $0x71,-0x4(%ebp)
  104862:	c6 45 fb 0a          	movb   $0xa,-0x5(%ebp)
  104866:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  10486a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10486d:	ee                   	out    %al,(%dx)
	// "The BSP must initialize CMOS shutdown code to 0AH
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t*)(0x40<<4 | 0x67);  // Warm reset vector
  10486e:	c7 45 ec 67 04 00 00 	movl   $0x467,-0x14(%ebp)
	wrv[0] = 0;
  104875:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104878:	66 c7 00 00 00       	movw   $0x0,(%eax)
	wrv[1] = addr >> 4;
  10487d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104880:	8d 50 02             	lea    0x2(%eax),%edx
  104883:	8b 45 0c             	mov    0xc(%ebp),%eax
  104886:	c1 e8 04             	shr    $0x4,%eax
  104889:	66 89 02             	mov    %ax,(%edx)

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid<<24);
  10488c:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  104890:	c1 e0 18             	shl    $0x18,%eax
  104893:	89 44 24 04          	mov    %eax,0x4(%esp)
  104897:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
  10489e:	e8 50 fd ff ff       	call   1045f3 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
  1048a3:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
  1048aa:	00 
  1048ab:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
  1048b2:	e8 3c fd ff ff       	call   1045f3 <lapicw>
	microdelay(200);
  1048b7:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
  1048be:	e8 74 ff ff ff       	call   104837 <microdelay>
	lapicw(ICRLO, INIT | LEVEL);
  1048c3:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
  1048ca:	00 
  1048cb:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
  1048d2:	e8 1c fd ff ff       	call   1045f3 <lapicw>
	microdelay(100);    // should be 10ms, but too slow in Bochs!
  1048d7:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
  1048de:	e8 54 ff ff ff       	call   104837 <microdelay>
	// Send startup IPI (twice!) to enter bootstrap code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for(i = 0; i < 2; i++){
  1048e3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  1048ea:	eb 40                	jmp    10492c <lapic_startcpu+0xf0>
		lapicw(ICRHI, apicid<<24);
  1048ec:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  1048f0:	c1 e0 18             	shl    $0x18,%eax
  1048f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1048f7:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
  1048fe:	e8 f0 fc ff ff       	call   1045f3 <lapicw>
		lapicw(ICRLO, STARTUP | (addr>>12));
  104903:	8b 45 0c             	mov    0xc(%ebp),%eax
  104906:	c1 e8 0c             	shr    $0xc,%eax
  104909:	80 cc 06             	or     $0x6,%ah
  10490c:	89 44 24 04          	mov    %eax,0x4(%esp)
  104910:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
  104917:	e8 d7 fc ff ff       	call   1045f3 <lapicw>
		microdelay(200);
  10491c:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
  104923:	e8 0f ff ff ff       	call   104837 <microdelay>
	// Send startup IPI (twice!) to enter bootstrap code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for(i = 0; i < 2; i++){
  104928:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  10492c:	83 7d e8 01          	cmpl   $0x1,-0x18(%ebp)
  104930:	7e ba                	jle    1048ec <lapic_startcpu+0xb0>
		lapicw(ICRHI, apicid<<24);
		lapicw(ICRLO, STARTUP | (addr>>12));
		microdelay(200);
	}
}
  104932:	c9                   	leave  
  104933:	c3                   	ret    

00104934 <ioapic_read>:
	uint32_t data;
};

static uint32_t
ioapic_read(int reg)
{
  104934:	55                   	push   %ebp
  104935:	89 e5                	mov    %esp,%ebp
	ioapic->reg = reg;
  104937:	a1 8c e2 10 00       	mov    0x10e28c,%eax
  10493c:	8b 55 08             	mov    0x8(%ebp),%edx
  10493f:	89 10                	mov    %edx,(%eax)
	return ioapic->data;
  104941:	a1 8c e2 10 00       	mov    0x10e28c,%eax
  104946:	8b 40 10             	mov    0x10(%eax),%eax
}
  104949:	5d                   	pop    %ebp
  10494a:	c3                   	ret    

0010494b <ioapic_write>:

static void
ioapic_write(int reg, uint32_t data)
{
  10494b:	55                   	push   %ebp
  10494c:	89 e5                	mov    %esp,%ebp
	ioapic->reg = reg;
  10494e:	a1 8c e2 10 00       	mov    0x10e28c,%eax
  104953:	8b 55 08             	mov    0x8(%ebp),%edx
  104956:	89 10                	mov    %edx,(%eax)
	ioapic->data = data;
  104958:	a1 8c e2 10 00       	mov    0x10e28c,%eax
  10495d:	8b 55 0c             	mov    0xc(%ebp),%edx
  104960:	89 50 10             	mov    %edx,0x10(%eax)
}
  104963:	5d                   	pop    %ebp
  104964:	c3                   	ret    

00104965 <ioapic_init>:

void
ioapic_init(void)
{
  104965:	55                   	push   %ebp
  104966:	89 e5                	mov    %esp,%ebp
  104968:	83 ec 38             	sub    $0x38,%esp
	int i, id, maxintr;

	if(!ismp)
  10496b:	a1 90 e2 10 00       	mov    0x10e290,%eax
  104970:	85 c0                	test   %eax,%eax
  104972:	0f 84 fd 00 00 00    	je     104a75 <ioapic_init+0x110>
		return;

	if (ioapic == NULL)
  104978:	a1 8c e2 10 00       	mov    0x10e28c,%eax
  10497d:	85 c0                	test   %eax,%eax
  10497f:	75 0a                	jne    10498b <ioapic_init+0x26>
		ioapic = mem_ptr(IOAPIC);	// assume default address
  104981:	c7 05 8c e2 10 00 00 	movl   $0xfec00000,0x10e28c
  104988:	00 c0 fe 

	maxintr = (ioapic_read(REG_VER) >> 16) & 0xFF;
  10498b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104992:	e8 9d ff ff ff       	call   104934 <ioapic_read>
  104997:	c1 e8 10             	shr    $0x10,%eax
  10499a:	25 ff 00 00 00       	and    $0xff,%eax
  10499f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	id = ioapic_read(REG_ID) >> 24;
  1049a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1049a9:	e8 86 ff ff ff       	call   104934 <ioapic_read>
  1049ae:	c1 e8 18             	shr    $0x18,%eax
  1049b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (id == 0) {
  1049b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1049b8:	75 2a                	jne    1049e4 <ioapic_init+0x7f>
		// I/O APIC ID not initialized yet - have to do it ourselves.
		ioapic_write(REG_ID, ioapicid << 24);
  1049ba:	0f b6 05 88 e2 10 00 	movzbl 0x10e288,%eax
  1049c1:	0f b6 c0             	movzbl %al,%eax
  1049c4:	c1 e0 18             	shl    $0x18,%eax
  1049c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1049cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1049d2:	e8 74 ff ff ff       	call   10494b <ioapic_write>
		id = ioapicid;
  1049d7:	0f b6 05 88 e2 10 00 	movzbl 0x10e288,%eax
  1049de:	0f b6 c0             	movzbl %al,%eax
  1049e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	}
	if (id != ioapicid)
  1049e4:	0f b6 05 88 e2 10 00 	movzbl 0x10e288,%eax
  1049eb:	0f b6 c0             	movzbl %al,%eax
  1049ee:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1049f1:	74 31                	je     104a24 <ioapic_init+0xbf>
		warn("ioapicinit: id %d != ioapicid %d", id, ioapicid);
  1049f3:	0f b6 05 88 e2 10 00 	movzbl 0x10e288,%eax
  1049fa:	0f b6 c0             	movzbl %al,%eax
  1049fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  104a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a04:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104a08:	c7 44 24 08 ac 68 10 	movl   $0x1068ac,0x8(%esp)
  104a0f:	00 
  104a10:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  104a17:	00 
  104a18:	c7 04 24 cd 68 10 00 	movl   $0x1068cd,(%esp)
  104a1f:	e8 a7 ba ff ff       	call   1004cb <debug_warn>

	// Mark all interrupts edge-triggered, active high, disabled,
	// and not routed to any CPUs.
	for (i = 0; i <= maxintr; i++){
  104a24:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  104a2b:	eb 3e                	jmp    104a6b <ioapic_init+0x106>
		ioapic_write(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
  104a2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a30:	83 c0 20             	add    $0x20,%eax
  104a33:	0d 00 00 01 00       	or     $0x10000,%eax
  104a38:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104a3b:	83 c2 08             	add    $0x8,%edx
  104a3e:	01 d2                	add    %edx,%edx
  104a40:	89 44 24 04          	mov    %eax,0x4(%esp)
  104a44:	89 14 24             	mov    %edx,(%esp)
  104a47:	e8 ff fe ff ff       	call   10494b <ioapic_write>
		ioapic_write(REG_TABLE+2*i+1, 0);
  104a4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a4f:	83 c0 08             	add    $0x8,%eax
  104a52:	01 c0                	add    %eax,%eax
  104a54:	83 c0 01             	add    $0x1,%eax
  104a57:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104a5e:	00 
  104a5f:	89 04 24             	mov    %eax,(%esp)
  104a62:	e8 e4 fe ff ff       	call   10494b <ioapic_write>
	if (id != ioapicid)
		warn("ioapicinit: id %d != ioapicid %d", id, ioapicid);

	// Mark all interrupts edge-triggered, active high, disabled,
	// and not routed to any CPUs.
	for (i = 0; i <= maxintr; i++){
  104a67:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  104a6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a6e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104a71:	7e ba                	jle    104a2d <ioapic_init+0xc8>
  104a73:	eb 01                	jmp    104a76 <ioapic_init+0x111>
ioapic_init(void)
{
	int i, id, maxintr;

	if(!ismp)
		return;
  104a75:	90                   	nop
	// and not routed to any CPUs.
	for (i = 0; i <= maxintr; i++){
		ioapic_write(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
		ioapic_write(REG_TABLE+2*i+1, 0);
	}
}
  104a76:	c9                   	leave  
  104a77:	c3                   	ret    

00104a78 <ioapic_enable>:

void
ioapic_enable(int irq)
{
  104a78:	55                   	push   %ebp
  104a79:	89 e5                	mov    %esp,%ebp
  104a7b:	83 ec 08             	sub    $0x8,%esp
	if (!ismp)
  104a7e:	a1 90 e2 10 00       	mov    0x10e290,%eax
  104a83:	85 c0                	test   %eax,%eax
  104a85:	74 3a                	je     104ac1 <ioapic_enable+0x49>
		return;

	// Mark interrupt edge-triggered, active high,
	// enabled, and routed to any CPU.
	ioapic_write(REG_TABLE+2*irq,
			INT_LOGICAL | INT_LOWEST | (T_IRQ0 + irq));
  104a87:	8b 45 08             	mov    0x8(%ebp),%eax
  104a8a:	83 c0 20             	add    $0x20,%eax
  104a8d:	80 cc 09             	or     $0x9,%ah
	if (!ismp)
		return;

	// Mark interrupt edge-triggered, active high,
	// enabled, and routed to any CPU.
	ioapic_write(REG_TABLE+2*irq,
  104a90:	8b 55 08             	mov    0x8(%ebp),%edx
  104a93:	83 c2 08             	add    $0x8,%edx
  104a96:	01 d2                	add    %edx,%edx
  104a98:	89 44 24 04          	mov    %eax,0x4(%esp)
  104a9c:	89 14 24             	mov    %edx,(%esp)
  104a9f:	e8 a7 fe ff ff       	call   10494b <ioapic_write>
			INT_LOGICAL | INT_LOWEST | (T_IRQ0 + irq));
	ioapic_write(REG_TABLE+2*irq+1, 0xff << 24);
  104aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  104aa7:	83 c0 08             	add    $0x8,%eax
  104aaa:	01 c0                	add    %eax,%eax
  104aac:	83 c0 01             	add    $0x1,%eax
  104aaf:	c7 44 24 04 00 00 00 	movl   $0xff000000,0x4(%esp)
  104ab6:	ff 
  104ab7:	89 04 24             	mov    %eax,(%esp)
  104aba:	e8 8c fe ff ff       	call   10494b <ioapic_write>
  104abf:	eb 01                	jmp    104ac2 <ioapic_enable+0x4a>

void
ioapic_enable(int irq)
{
	if (!ismp)
		return;
  104ac1:	90                   	nop
	// Mark interrupt edge-triggered, active high,
	// enabled, and routed to any CPU.
	ioapic_write(REG_TABLE+2*irq,
			INT_LOGICAL | INT_LOWEST | (T_IRQ0 + irq));
	ioapic_write(REG_TABLE+2*irq+1, 0xff << 24);
}
  104ac2:	c9                   	leave  
  104ac3:	c3                   	ret    

00104ac4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static uintmax_t
getuint(printstate *st, va_list *ap)
{
  104ac4:	55                   	push   %ebp
  104ac5:	89 e5                	mov    %esp,%ebp
	if (st->flags & F_LL)
  104ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  104aca:	8b 40 18             	mov    0x18(%eax),%eax
  104acd:	83 e0 02             	and    $0x2,%eax
  104ad0:	85 c0                	test   %eax,%eax
  104ad2:	74 1c                	je     104af0 <getuint+0x2c>
		return va_arg(*ap, unsigned long long);
  104ad4:	8b 45 0c             	mov    0xc(%ebp),%eax
  104ad7:	8b 00                	mov    (%eax),%eax
  104ad9:	8d 50 08             	lea    0x8(%eax),%edx
  104adc:	8b 45 0c             	mov    0xc(%ebp),%eax
  104adf:	89 10                	mov    %edx,(%eax)
  104ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
  104ae4:	8b 00                	mov    (%eax),%eax
  104ae6:	83 e8 08             	sub    $0x8,%eax
  104ae9:	8b 50 04             	mov    0x4(%eax),%edx
  104aec:	8b 00                	mov    (%eax),%eax
  104aee:	eb 47                	jmp    104b37 <getuint+0x73>
	else if (st->flags & F_L)
  104af0:	8b 45 08             	mov    0x8(%ebp),%eax
  104af3:	8b 40 18             	mov    0x18(%eax),%eax
  104af6:	83 e0 01             	and    $0x1,%eax
  104af9:	84 c0                	test   %al,%al
  104afb:	74 1e                	je     104b1b <getuint+0x57>
		return va_arg(*ap, unsigned long);
  104afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b00:	8b 00                	mov    (%eax),%eax
  104b02:	8d 50 04             	lea    0x4(%eax),%edx
  104b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b08:	89 10                	mov    %edx,(%eax)
  104b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b0d:	8b 00                	mov    (%eax),%eax
  104b0f:	83 e8 04             	sub    $0x4,%eax
  104b12:	8b 00                	mov    (%eax),%eax
  104b14:	ba 00 00 00 00       	mov    $0x0,%edx
  104b19:	eb 1c                	jmp    104b37 <getuint+0x73>
	else
		return va_arg(*ap, unsigned int);
  104b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b1e:	8b 00                	mov    (%eax),%eax
  104b20:	8d 50 04             	lea    0x4(%eax),%edx
  104b23:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b26:	89 10                	mov    %edx,(%eax)
  104b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b2b:	8b 00                	mov    (%eax),%eax
  104b2d:	83 e8 04             	sub    $0x4,%eax
  104b30:	8b 00                	mov    (%eax),%eax
  104b32:	ba 00 00 00 00       	mov    $0x0,%edx
}
  104b37:	5d                   	pop    %ebp
  104b38:	c3                   	ret    

00104b39 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static intmax_t
getint(printstate *st, va_list *ap)
{
  104b39:	55                   	push   %ebp
  104b3a:	89 e5                	mov    %esp,%ebp
	if (st->flags & F_LL)
  104b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  104b3f:	8b 40 18             	mov    0x18(%eax),%eax
  104b42:	83 e0 02             	and    $0x2,%eax
  104b45:	85 c0                	test   %eax,%eax
  104b47:	74 1c                	je     104b65 <getint+0x2c>
		return va_arg(*ap, long long);
  104b49:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b4c:	8b 00                	mov    (%eax),%eax
  104b4e:	8d 50 08             	lea    0x8(%eax),%edx
  104b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b54:	89 10                	mov    %edx,(%eax)
  104b56:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b59:	8b 00                	mov    (%eax),%eax
  104b5b:	83 e8 08             	sub    $0x8,%eax
  104b5e:	8b 50 04             	mov    0x4(%eax),%edx
  104b61:	8b 00                	mov    (%eax),%eax
  104b63:	eb 47                	jmp    104bac <getint+0x73>
	else if (st->flags & F_L)
  104b65:	8b 45 08             	mov    0x8(%ebp),%eax
  104b68:	8b 40 18             	mov    0x18(%eax),%eax
  104b6b:	83 e0 01             	and    $0x1,%eax
  104b6e:	84 c0                	test   %al,%al
  104b70:	74 1e                	je     104b90 <getint+0x57>
		return va_arg(*ap, long);
  104b72:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b75:	8b 00                	mov    (%eax),%eax
  104b77:	8d 50 04             	lea    0x4(%eax),%edx
  104b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b7d:	89 10                	mov    %edx,(%eax)
  104b7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b82:	8b 00                	mov    (%eax),%eax
  104b84:	83 e8 04             	sub    $0x4,%eax
  104b87:	8b 00                	mov    (%eax),%eax
  104b89:	89 c2                	mov    %eax,%edx
  104b8b:	c1 fa 1f             	sar    $0x1f,%edx
  104b8e:	eb 1c                	jmp    104bac <getint+0x73>
	else
		return va_arg(*ap, int);
  104b90:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b93:	8b 00                	mov    (%eax),%eax
  104b95:	8d 50 04             	lea    0x4(%eax),%edx
  104b98:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b9b:	89 10                	mov    %edx,(%eax)
  104b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  104ba0:	8b 00                	mov    (%eax),%eax
  104ba2:	83 e8 04             	sub    $0x4,%eax
  104ba5:	8b 00                	mov    (%eax),%eax
  104ba7:	89 c2                	mov    %eax,%edx
  104ba9:	c1 fa 1f             	sar    $0x1f,%edx
}
  104bac:	5d                   	pop    %ebp
  104bad:	c3                   	ret    

00104bae <putpad>:

// Print padding characters, and an optional sign before a number.
static void
putpad(printstate *st)
{
  104bae:	55                   	push   %ebp
  104baf:	89 e5                	mov    %esp,%ebp
  104bb1:	83 ec 18             	sub    $0x18,%esp
	while (--st->width >= 0)
  104bb4:	eb 1a                	jmp    104bd0 <putpad+0x22>
		st->putch(st->padc, st->putdat);
  104bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  104bb9:	8b 08                	mov    (%eax),%ecx
  104bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  104bbe:	8b 50 04             	mov    0x4(%eax),%edx
  104bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  104bc4:	8b 40 08             	mov    0x8(%eax),%eax
  104bc7:	89 54 24 04          	mov    %edx,0x4(%esp)
  104bcb:	89 04 24             	mov    %eax,(%esp)
  104bce:	ff d1                	call   *%ecx

// Print padding characters, and an optional sign before a number.
static void
putpad(printstate *st)
{
	while (--st->width >= 0)
  104bd0:	8b 45 08             	mov    0x8(%ebp),%eax
  104bd3:	8b 40 0c             	mov    0xc(%eax),%eax
  104bd6:	8d 50 ff             	lea    -0x1(%eax),%edx
  104bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  104bdc:	89 50 0c             	mov    %edx,0xc(%eax)
  104bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  104be2:	8b 40 0c             	mov    0xc(%eax),%eax
  104be5:	85 c0                	test   %eax,%eax
  104be7:	79 cd                	jns    104bb6 <putpad+0x8>
		st->putch(st->padc, st->putdat);
}
  104be9:	c9                   	leave  
  104bea:	c3                   	ret    

00104beb <putstr>:

// Print a string with a specified maximum length (-1=unlimited),
// with any appropriate left or right field padding.
static void
putstr(printstate *st, const char *str, int maxlen)
{
  104beb:	55                   	push   %ebp
  104bec:	89 e5                	mov    %esp,%ebp
  104bee:	53                   	push   %ebx
  104bef:	83 ec 24             	sub    $0x24,%esp
	const char *lim;		// find where the string actually ends
	if (maxlen < 0)
  104bf2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  104bf6:	79 18                	jns    104c10 <putstr+0x25>
		lim = strchr(str, 0);	// find the terminating null
  104bf8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104bff:	00 
  104c00:	8b 45 0c             	mov    0xc(%ebp),%eax
  104c03:	89 04 24             	mov    %eax,(%esp)
  104c06:	e8 e9 07 00 00       	call   1053f4 <strchr>
  104c0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104c0e:	eb 2c                	jmp    104c3c <putstr+0x51>
	else if ((lim = memchr(str, 0, maxlen)) == NULL)
  104c10:	8b 45 10             	mov    0x10(%ebp),%eax
  104c13:	89 44 24 08          	mov    %eax,0x8(%esp)
  104c17:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104c1e:	00 
  104c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104c22:	89 04 24             	mov    %eax,(%esp)
  104c25:	e8 ce 09 00 00       	call   1055f8 <memchr>
  104c2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104c2d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104c31:	75 09                	jne    104c3c <putstr+0x51>
		lim = str + maxlen;
  104c33:	8b 45 10             	mov    0x10(%ebp),%eax
  104c36:	03 45 0c             	add    0xc(%ebp),%eax
  104c39:	89 45 f0             	mov    %eax,-0x10(%ebp)
	st->width -= (lim-str);		// deduct string length from field width
  104c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  104c3f:	8b 40 0c             	mov    0xc(%eax),%eax
  104c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  104c45:	8b 55 f0             	mov    -0x10(%ebp),%edx
  104c48:	89 cb                	mov    %ecx,%ebx
  104c4a:	29 d3                	sub    %edx,%ebx
  104c4c:	89 da                	mov    %ebx,%edx
  104c4e:	8d 14 10             	lea    (%eax,%edx,1),%edx
  104c51:	8b 45 08             	mov    0x8(%ebp),%eax
  104c54:	89 50 0c             	mov    %edx,0xc(%eax)

	if (!(st->flags & F_RPAD))	// print left-side padding
  104c57:	8b 45 08             	mov    0x8(%ebp),%eax
  104c5a:	8b 40 18             	mov    0x18(%eax),%eax
  104c5d:	83 e0 10             	and    $0x10,%eax
  104c60:	85 c0                	test   %eax,%eax
  104c62:	75 32                	jne    104c96 <putstr+0xab>
		putpad(st);		// (also leaves st->width == 0)
  104c64:	8b 45 08             	mov    0x8(%ebp),%eax
  104c67:	89 04 24             	mov    %eax,(%esp)
  104c6a:	e8 3f ff ff ff       	call   104bae <putpad>
	while (str < lim) {
  104c6f:	eb 25                	jmp    104c96 <putstr+0xab>
		char ch = *str++;
  104c71:	8b 45 0c             	mov    0xc(%ebp),%eax
  104c74:	0f b6 00             	movzbl (%eax),%eax
  104c77:	88 45 f7             	mov    %al,-0x9(%ebp)
  104c7a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
			st->putch(ch, st->putdat);
  104c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  104c81:	8b 08                	mov    (%eax),%ecx
  104c83:	8b 45 08             	mov    0x8(%ebp),%eax
  104c86:	8b 50 04             	mov    0x4(%eax),%edx
  104c89:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  104c8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  104c91:	89 04 24             	mov    %eax,(%esp)
  104c94:	ff d1                	call   *%ecx
		lim = str + maxlen;
	st->width -= (lim-str);		// deduct string length from field width

	if (!(st->flags & F_RPAD))	// print left-side padding
		putpad(st);		// (also leaves st->width == 0)
	while (str < lim) {
  104c96:	8b 45 0c             	mov    0xc(%ebp),%eax
  104c99:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104c9c:	72 d3                	jb     104c71 <putstr+0x86>
		char ch = *str++;
			st->putch(ch, st->putdat);
	}
	putpad(st);			// print right-side padding
  104c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  104ca1:	89 04 24             	mov    %eax,(%esp)
  104ca4:	e8 05 ff ff ff       	call   104bae <putpad>
}
  104ca9:	83 c4 24             	add    $0x24,%esp
  104cac:	5b                   	pop    %ebx
  104cad:	5d                   	pop    %ebp
  104cae:	c3                   	ret    

00104caf <genint>:

// Generate a number (base <= 16) in reverse order into a string buffer.
static char *
genint(printstate *st, char *p, uintmax_t num)
{
  104caf:	55                   	push   %ebp
  104cb0:	89 e5                	mov    %esp,%ebp
  104cb2:	53                   	push   %ebx
  104cb3:	83 ec 24             	sub    $0x24,%esp
  104cb6:	8b 45 10             	mov    0x10(%ebp),%eax
  104cb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104cbc:	8b 45 14             	mov    0x14(%ebp),%eax
  104cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= st->base)
  104cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  104cc5:	8b 40 1c             	mov    0x1c(%eax),%eax
  104cc8:	89 c2                	mov    %eax,%edx
  104cca:	c1 fa 1f             	sar    $0x1f,%edx
  104ccd:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  104cd0:	77 4e                	ja     104d20 <genint+0x71>
  104cd2:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  104cd5:	72 05                	jb     104cdc <genint+0x2d>
  104cd7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104cda:	77 44                	ja     104d20 <genint+0x71>
		p = genint(st, p, num / st->base);	// output higher digits
  104cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  104cdf:	8b 40 1c             	mov    0x1c(%eax),%eax
  104ce2:	89 c2                	mov    %eax,%edx
  104ce4:	c1 fa 1f             	sar    $0x1f,%edx
  104ce7:	89 44 24 08          	mov    %eax,0x8(%esp)
  104ceb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  104cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104cf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104cf5:	89 04 24             	mov    %eax,(%esp)
  104cf8:	89 54 24 04          	mov    %edx,0x4(%esp)
  104cfc:	e8 3f 09 00 00       	call   105640 <__udivdi3>
  104d01:	89 44 24 08          	mov    %eax,0x8(%esp)
  104d05:	89 54 24 0c          	mov    %edx,0xc(%esp)
  104d09:	8b 45 0c             	mov    0xc(%ebp),%eax
  104d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  104d10:	8b 45 08             	mov    0x8(%ebp),%eax
  104d13:	89 04 24             	mov    %eax,(%esp)
  104d16:	e8 94 ff ff ff       	call   104caf <genint>
  104d1b:	89 45 0c             	mov    %eax,0xc(%ebp)
  104d1e:	eb 1b                	jmp    104d3b <genint+0x8c>
	else if (st->signc >= 0)
  104d20:	8b 45 08             	mov    0x8(%ebp),%eax
  104d23:	8b 40 14             	mov    0x14(%eax),%eax
  104d26:	85 c0                	test   %eax,%eax
  104d28:	78 11                	js     104d3b <genint+0x8c>
		*p++ = st->signc;			// output leading sign
  104d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  104d2d:	8b 40 14             	mov    0x14(%eax),%eax
  104d30:	89 c2                	mov    %eax,%edx
  104d32:	8b 45 0c             	mov    0xc(%ebp),%eax
  104d35:	88 10                	mov    %dl,(%eax)
  104d37:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	*p++ = "0123456789abcdef"[num % st->base];	// output this digit
  104d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  104d3e:	8b 40 1c             	mov    0x1c(%eax),%eax
  104d41:	89 c1                	mov    %eax,%ecx
  104d43:	89 c3                	mov    %eax,%ebx
  104d45:	c1 fb 1f             	sar    $0x1f,%ebx
  104d48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104d4e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104d52:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104d56:	89 04 24             	mov    %eax,(%esp)
  104d59:	89 54 24 04          	mov    %edx,0x4(%esp)
  104d5d:	e8 0e 0a 00 00       	call   105770 <__umoddi3>
  104d62:	05 dc 68 10 00       	add    $0x1068dc,%eax
  104d67:	0f b6 10             	movzbl (%eax),%edx
  104d6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  104d6d:	88 10                	mov    %dl,(%eax)
  104d6f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
	return p;
  104d73:	8b 45 0c             	mov    0xc(%ebp),%eax
}
  104d76:	83 c4 24             	add    $0x24,%esp
  104d79:	5b                   	pop    %ebx
  104d7a:	5d                   	pop    %ebp
  104d7b:	c3                   	ret    

00104d7c <putint>:

// Print an integer with any appropriate field padding.
static void
putint(printstate *st, uintmax_t num, int base)
{
  104d7c:	55                   	push   %ebp
  104d7d:	89 e5                	mov    %esp,%ebp
  104d7f:	83 ec 58             	sub    $0x58,%esp
  104d82:	8b 45 0c             	mov    0xc(%ebp),%eax
  104d85:	89 45 c0             	mov    %eax,-0x40(%ebp)
  104d88:	8b 45 10             	mov    0x10(%ebp),%eax
  104d8b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	char buf[30], *p = buf;		// big enough for any 64-bit int in octal
  104d8e:	8d 45 d6             	lea    -0x2a(%ebp),%eax
  104d91:	89 45 f4             	mov    %eax,-0xc(%ebp)
	st->base = base;		// select base for genint
  104d94:	8b 45 08             	mov    0x8(%ebp),%eax
  104d97:	8b 55 14             	mov    0x14(%ebp),%edx
  104d9a:	89 50 1c             	mov    %edx,0x1c(%eax)
	p = genint(st, p, num);		// output to the string buffer
  104d9d:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104da0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  104da3:	89 44 24 08          	mov    %eax,0x8(%esp)
  104da7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  104dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104dae:	89 44 24 04          	mov    %eax,0x4(%esp)
  104db2:	8b 45 08             	mov    0x8(%ebp),%eax
  104db5:	89 04 24             	mov    %eax,(%esp)
  104db8:	e8 f2 fe ff ff       	call   104caf <genint>
  104dbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	putstr(st, buf, p-buf);		// print it with left/right padding
  104dc0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104dc3:	8d 45 d6             	lea    -0x2a(%ebp),%eax
  104dc6:	89 d1                	mov    %edx,%ecx
  104dc8:	29 c1                	sub    %eax,%ecx
  104dca:	89 c8                	mov    %ecx,%eax
  104dcc:	89 44 24 08          	mov    %eax,0x8(%esp)
  104dd0:	8d 45 d6             	lea    -0x2a(%ebp),%eax
  104dd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  104dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  104dda:	89 04 24             	mov    %eax,(%esp)
  104ddd:	e8 09 fe ff ff       	call   104beb <putstr>
}
  104de2:	c9                   	leave  
  104de3:	c3                   	ret    

00104de4 <vprintfmt>:
#endif	// ! PIOS_KERNEL

// Main function to format and print a string.
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  104de4:	55                   	push   %ebp
  104de5:	89 e5                	mov    %esp,%ebp
  104de7:	53                   	push   %ebx
  104de8:	83 ec 44             	sub    $0x44,%esp
	register int ch, err;

	printstate st = { .putch = putch, .putdat = putdat };
  104deb:	8d 55 c8             	lea    -0x38(%ebp),%edx
  104dee:	b9 00 00 00 00       	mov    $0x0,%ecx
  104df3:	b8 20 00 00 00       	mov    $0x20,%eax
  104df8:	89 c3                	mov    %eax,%ebx
  104dfa:	83 e3 fc             	and    $0xfffffffc,%ebx
  104dfd:	b8 00 00 00 00       	mov    $0x0,%eax
  104e02:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
  104e05:	83 c0 04             	add    $0x4,%eax
  104e08:	39 d8                	cmp    %ebx,%eax
  104e0a:	72 f6                	jb     104e02 <vprintfmt+0x1e>
  104e0c:	01 c2                	add    %eax,%edx
  104e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  104e11:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104e14:	8b 45 0c             	mov    0xc(%ebp),%eax
  104e17:	89 45 cc             	mov    %eax,-0x34(%ebp)
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  104e1a:	eb 17                	jmp    104e33 <vprintfmt+0x4f>
			if (ch == '\0')
  104e1c:	85 db                	test   %ebx,%ebx
  104e1e:	0f 84 52 03 00 00    	je     105176 <vprintfmt+0x392>
				return;
			putch(ch, putdat);
  104e24:	8b 45 0c             	mov    0xc(%ebp),%eax
  104e27:	89 44 24 04          	mov    %eax,0x4(%esp)
  104e2b:	89 1c 24             	mov    %ebx,(%esp)
  104e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  104e31:	ff d0                	call   *%eax
{
	register int ch, err;

	printstate st = { .putch = putch, .putdat = putdat };
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  104e33:	8b 45 10             	mov    0x10(%ebp),%eax
  104e36:	0f b6 00             	movzbl (%eax),%eax
  104e39:	0f b6 d8             	movzbl %al,%ebx
  104e3c:	83 fb 25             	cmp    $0x25,%ebx
  104e3f:	0f 95 c0             	setne  %al
  104e42:	83 45 10 01          	addl   $0x1,0x10(%ebp)
  104e46:	84 c0                	test   %al,%al
  104e48:	75 d2                	jne    104e1c <vprintfmt+0x38>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		st.padc = ' ';
  104e4a:	c7 45 d0 20 00 00 00 	movl   $0x20,-0x30(%ebp)
		st.width = -1;
  104e51:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		st.prec = -1;
  104e58:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		st.signc = -1;
  104e5f:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		st.flags = 0;
  104e66:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		st.base = 10;
  104e6d:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
  104e74:	eb 04                	jmp    104e7a <vprintfmt+0x96>
			goto reswitch;

		case ' ': // prefix signless numeric values with a space
			if (st.signc < 0)	// (but only if no '+' is specified)
				st.signc = ' ';
			goto reswitch;
  104e76:	90                   	nop
  104e77:	eb 01                	jmp    104e7a <vprintfmt+0x96>
		gotprec:
			if (!(st.flags & F_DOT)) {	// haven't seen a '.' yet?
				st.width = st.prec;	// then it's a field width
				st.prec = -1;
			}
			goto reswitch;
  104e79:	90                   	nop
		st.signc = -1;
		st.flags = 0;
		st.base = 10;
		uintmax_t num;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  104e7a:	8b 45 10             	mov    0x10(%ebp),%eax
  104e7d:	0f b6 00             	movzbl (%eax),%eax
  104e80:	0f b6 d8             	movzbl %al,%ebx
  104e83:	89 d8                	mov    %ebx,%eax
  104e85:	83 45 10 01          	addl   $0x1,0x10(%ebp)
  104e89:	83 e8 20             	sub    $0x20,%eax
  104e8c:	83 f8 58             	cmp    $0x58,%eax
  104e8f:	0f 87 b1 02 00 00    	ja     105146 <vprintfmt+0x362>
  104e95:	8b 04 85 f4 68 10 00 	mov    0x1068f4(,%eax,4),%eax
  104e9c:	ff e0                	jmp    *%eax

		// modifier flags
		case '-': // pad on the right instead of the left
			st.flags |= F_RPAD;
  104e9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104ea1:	83 c8 10             	or     $0x10,%eax
  104ea4:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  104ea7:	eb d1                	jmp    104e7a <vprintfmt+0x96>

		case '+': // prefix positive numeric values with a '+' sign
			st.signc = '+';
  104ea9:	c7 45 dc 2b 00 00 00 	movl   $0x2b,-0x24(%ebp)
			goto reswitch;
  104eb0:	eb c8                	jmp    104e7a <vprintfmt+0x96>

		case ' ': // prefix signless numeric values with a space
			if (st.signc < 0)	// (but only if no '+' is specified)
  104eb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104eb5:	85 c0                	test   %eax,%eax
  104eb7:	79 bd                	jns    104e76 <vprintfmt+0x92>
				st.signc = ' ';
  104eb9:	c7 45 dc 20 00 00 00 	movl   $0x20,-0x24(%ebp)
			goto reswitch;
  104ec0:	eb b8                	jmp    104e7a <vprintfmt+0x96>

		// width or precision field
		case '0':
			if (!(st.flags & F_DOT))
  104ec2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104ec5:	83 e0 08             	and    $0x8,%eax
  104ec8:	85 c0                	test   %eax,%eax
  104eca:	75 07                	jne    104ed3 <vprintfmt+0xef>
				st.padc = '0'; // pad with 0's instead of spaces
  104ecc:	c7 45 d0 30 00 00 00 	movl   $0x30,-0x30(%ebp)
		case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9':
			for (st.prec = 0; ; ++fmt) {
  104ed3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
				st.prec = st.prec * 10 + ch - '0';
  104eda:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104edd:	89 d0                	mov    %edx,%eax
  104edf:	c1 e0 02             	shl    $0x2,%eax
  104ee2:	01 d0                	add    %edx,%eax
  104ee4:	01 c0                	add    %eax,%eax
  104ee6:	01 d8                	add    %ebx,%eax
  104ee8:	83 e8 30             	sub    $0x30,%eax
  104eeb:	89 45 d8             	mov    %eax,-0x28(%ebp)
				ch = *fmt;
  104eee:	8b 45 10             	mov    0x10(%ebp),%eax
  104ef1:	0f b6 00             	movzbl (%eax),%eax
  104ef4:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  104ef7:	83 fb 2f             	cmp    $0x2f,%ebx
  104efa:	7e 21                	jle    104f1d <vprintfmt+0x139>
  104efc:	83 fb 39             	cmp    $0x39,%ebx
  104eff:	7f 1f                	jg     104f20 <vprintfmt+0x13c>
		case '0':
			if (!(st.flags & F_DOT))
				st.padc = '0'; // pad with 0's instead of spaces
		case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9':
			for (st.prec = 0; ; ++fmt) {
  104f01:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				st.prec = st.prec * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  104f05:	eb d3                	jmp    104eda <vprintfmt+0xf6>
			goto gotprec;

		case '*':
			st.prec = va_arg(ap, int);
  104f07:	8b 45 14             	mov    0x14(%ebp),%eax
  104f0a:	83 c0 04             	add    $0x4,%eax
  104f0d:	89 45 14             	mov    %eax,0x14(%ebp)
  104f10:	8b 45 14             	mov    0x14(%ebp),%eax
  104f13:	83 e8 04             	sub    $0x4,%eax
  104f16:	8b 00                	mov    (%eax),%eax
  104f18:	89 45 d8             	mov    %eax,-0x28(%ebp)
  104f1b:	eb 04                	jmp    104f21 <vprintfmt+0x13d>
				st.prec = st.prec * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto gotprec;
  104f1d:	90                   	nop
  104f1e:	eb 01                	jmp    104f21 <vprintfmt+0x13d>
  104f20:	90                   	nop

		case '*':
			st.prec = va_arg(ap, int);
		gotprec:
			if (!(st.flags & F_DOT)) {	// haven't seen a '.' yet?
  104f21:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104f24:	83 e0 08             	and    $0x8,%eax
  104f27:	85 c0                	test   %eax,%eax
  104f29:	0f 85 4a ff ff ff    	jne    104e79 <vprintfmt+0x95>
				st.width = st.prec;	// then it's a field width
  104f2f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104f32:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				st.prec = -1;
  104f35:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
			}
			goto reswitch;
  104f3c:	e9 39 ff ff ff       	jmp    104e7a <vprintfmt+0x96>

		case '.':
			st.flags |= F_DOT;
  104f41:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104f44:	83 c8 08             	or     $0x8,%eax
  104f47:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  104f4a:	e9 2b ff ff ff       	jmp    104e7a <vprintfmt+0x96>

		case '#':
			st.flags |= F_ALT;
  104f4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104f52:	83 c8 04             	or     $0x4,%eax
  104f55:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  104f58:	e9 1d ff ff ff       	jmp    104e7a <vprintfmt+0x96>

		// long flag (doubled for long long)
		case 'l':
			st.flags |= (st.flags & F_L) ? F_LL : F_L;
  104f5d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104f60:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104f63:	83 e0 01             	and    $0x1,%eax
  104f66:	84 c0                	test   %al,%al
  104f68:	74 07                	je     104f71 <vprintfmt+0x18d>
  104f6a:	b8 02 00 00 00       	mov    $0x2,%eax
  104f6f:	eb 05                	jmp    104f76 <vprintfmt+0x192>
  104f71:	b8 01 00 00 00       	mov    $0x1,%eax
  104f76:	09 d0                	or     %edx,%eax
  104f78:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto reswitch;
  104f7b:	e9 fa fe ff ff       	jmp    104e7a <vprintfmt+0x96>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  104f80:	8b 45 14             	mov    0x14(%ebp),%eax
  104f83:	83 c0 04             	add    $0x4,%eax
  104f86:	89 45 14             	mov    %eax,0x14(%ebp)
  104f89:	8b 45 14             	mov    0x14(%ebp),%eax
  104f8c:	83 e8 04             	sub    $0x4,%eax
  104f8f:	8b 00                	mov    (%eax),%eax
  104f91:	8b 55 0c             	mov    0xc(%ebp),%edx
  104f94:	89 54 24 04          	mov    %edx,0x4(%esp)
  104f98:	89 04 24             	mov    %eax,(%esp)
  104f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  104f9e:	ff d0                	call   *%eax
			break;
  104fa0:	e9 cb 01 00 00       	jmp    105170 <vprintfmt+0x38c>

		// string
		case 's': {
			const char *s;
			if ((s = va_arg(ap, char *)) == NULL)
  104fa5:	8b 45 14             	mov    0x14(%ebp),%eax
  104fa8:	83 c0 04             	add    $0x4,%eax
  104fab:	89 45 14             	mov    %eax,0x14(%ebp)
  104fae:	8b 45 14             	mov    0x14(%ebp),%eax
  104fb1:	83 e8 04             	sub    $0x4,%eax
  104fb4:	8b 00                	mov    (%eax),%eax
  104fb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104fb9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104fbd:	75 07                	jne    104fc6 <vprintfmt+0x1e2>
				s = "(null)";
  104fbf:	c7 45 f4 ed 68 10 00 	movl   $0x1068ed,-0xc(%ebp)
			putstr(&st, s, st.prec);
  104fc6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104fc9:	89 44 24 08          	mov    %eax,0x8(%esp)
  104fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  104fd4:	8d 45 c8             	lea    -0x38(%ebp),%eax
  104fd7:	89 04 24             	mov    %eax,(%esp)
  104fda:	e8 0c fc ff ff       	call   104beb <putstr>
			break;
  104fdf:	e9 8c 01 00 00       	jmp    105170 <vprintfmt+0x38c>
		    }

		// (signed) decimal
		case 'd':
			num = getint(&st, &ap);
  104fe4:	8d 45 14             	lea    0x14(%ebp),%eax
  104fe7:	89 44 24 04          	mov    %eax,0x4(%esp)
  104feb:	8d 45 c8             	lea    -0x38(%ebp),%eax
  104fee:	89 04 24             	mov    %eax,(%esp)
  104ff1:	e8 43 fb ff ff       	call   104b39 <getint>
  104ff6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104ff9:	89 55 ec             	mov    %edx,-0x14(%ebp)
			if ((intmax_t) num < 0) {
  104ffc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104fff:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105002:	85 d2                	test   %edx,%edx
  105004:	79 1a                	jns    105020 <vprintfmt+0x23c>
				num = -(intmax_t) num;
  105006:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105009:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10500c:	f7 d8                	neg    %eax
  10500e:	83 d2 00             	adc    $0x0,%edx
  105011:	f7 da                	neg    %edx
  105013:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105016:	89 55 ec             	mov    %edx,-0x14(%ebp)
				st.signc = '-';
  105019:	c7 45 dc 2d 00 00 00 	movl   $0x2d,-0x24(%ebp)
			}
			putint(&st, num, 10);
  105020:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  105027:	00 
  105028:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10502b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10502e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105032:	89 54 24 08          	mov    %edx,0x8(%esp)
  105036:	8d 45 c8             	lea    -0x38(%ebp),%eax
  105039:	89 04 24             	mov    %eax,(%esp)
  10503c:	e8 3b fd ff ff       	call   104d7c <putint>
			break;
  105041:	e9 2a 01 00 00       	jmp    105170 <vprintfmt+0x38c>

		// unsigned decimal
		case 'u':
			putint(&st, getuint(&st, &ap), 10);
  105046:	8d 45 14             	lea    0x14(%ebp),%eax
  105049:	89 44 24 04          	mov    %eax,0x4(%esp)
  10504d:	8d 45 c8             	lea    -0x38(%ebp),%eax
  105050:	89 04 24             	mov    %eax,(%esp)
  105053:	e8 6c fa ff ff       	call   104ac4 <getuint>
  105058:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  10505f:	00 
  105060:	89 44 24 04          	mov    %eax,0x4(%esp)
  105064:	89 54 24 08          	mov    %edx,0x8(%esp)
  105068:	8d 45 c8             	lea    -0x38(%ebp),%eax
  10506b:	89 04 24             	mov    %eax,(%esp)
  10506e:	e8 09 fd ff ff       	call   104d7c <putint>
			break;
  105073:	e9 f8 00 00 00       	jmp    105170 <vprintfmt+0x38c>

		// (unsigned) octal
		case 'o':
			putint(&st, getuint(&st, &ap), 8);
  105078:	8d 45 14             	lea    0x14(%ebp),%eax
  10507b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10507f:	8d 45 c8             	lea    -0x38(%ebp),%eax
  105082:	89 04 24             	mov    %eax,(%esp)
  105085:	e8 3a fa ff ff       	call   104ac4 <getuint>
  10508a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  105091:	00 
  105092:	89 44 24 04          	mov    %eax,0x4(%esp)
  105096:	89 54 24 08          	mov    %edx,0x8(%esp)
  10509a:	8d 45 c8             	lea    -0x38(%ebp),%eax
  10509d:	89 04 24             	mov    %eax,(%esp)
  1050a0:	e8 d7 fc ff ff       	call   104d7c <putint>
			break;
  1050a5:	e9 c6 00 00 00       	jmp    105170 <vprintfmt+0x38c>

		// (unsigned) hexadecimal
		case 'x':
			putint(&st, getuint(&st, &ap), 16);
  1050aa:	8d 45 14             	lea    0x14(%ebp),%eax
  1050ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  1050b1:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1050b4:	89 04 24             	mov    %eax,(%esp)
  1050b7:	e8 08 fa ff ff       	call   104ac4 <getuint>
  1050bc:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  1050c3:	00 
  1050c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1050c8:	89 54 24 08          	mov    %edx,0x8(%esp)
  1050cc:	8d 45 c8             	lea    -0x38(%ebp),%eax
  1050cf:	89 04 24             	mov    %eax,(%esp)
  1050d2:	e8 a5 fc ff ff       	call   104d7c <putint>
			break;
  1050d7:	e9 94 00 00 00       	jmp    105170 <vprintfmt+0x38c>

		// pointer
		case 'p':
			putch('0', putdat);
  1050dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1050df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1050e3:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  1050ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1050ed:	ff d0                	call   *%eax
			putch('x', putdat);
  1050ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1050f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1050f6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  1050fd:	8b 45 08             	mov    0x8(%ebp),%eax
  105100:	ff d0                	call   *%eax
			putint(&st, (uintptr_t) va_arg(ap, void *), 16);
  105102:	8b 45 14             	mov    0x14(%ebp),%eax
  105105:	83 c0 04             	add    $0x4,%eax
  105108:	89 45 14             	mov    %eax,0x14(%ebp)
  10510b:	8b 45 14             	mov    0x14(%ebp),%eax
  10510e:	83 e8 04             	sub    $0x4,%eax
  105111:	8b 00                	mov    (%eax),%eax
  105113:	ba 00 00 00 00       	mov    $0x0,%edx
  105118:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  10511f:	00 
  105120:	89 44 24 04          	mov    %eax,0x4(%esp)
  105124:	89 54 24 08          	mov    %edx,0x8(%esp)
  105128:	8d 45 c8             	lea    -0x38(%ebp),%eax
  10512b:	89 04 24             	mov    %eax,(%esp)
  10512e:	e8 49 fc ff ff       	call   104d7c <putint>
			break;
  105133:	eb 3b                	jmp    105170 <vprintfmt+0x38c>
		    }
#endif	// ! PIOS_KERNEL

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  105135:	8b 45 0c             	mov    0xc(%ebp),%eax
  105138:	89 44 24 04          	mov    %eax,0x4(%esp)
  10513c:	89 1c 24             	mov    %ebx,(%esp)
  10513f:	8b 45 08             	mov    0x8(%ebp),%eax
  105142:	ff d0                	call   *%eax
			break;
  105144:	eb 2a                	jmp    105170 <vprintfmt+0x38c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  105146:	8b 45 0c             	mov    0xc(%ebp),%eax
  105149:	89 44 24 04          	mov    %eax,0x4(%esp)
  10514d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105154:	8b 45 08             	mov    0x8(%ebp),%eax
  105157:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  105159:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10515d:	eb 04                	jmp    105163 <vprintfmt+0x37f>
  10515f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105163:	8b 45 10             	mov    0x10(%ebp),%eax
  105166:	83 e8 01             	sub    $0x1,%eax
  105169:	0f b6 00             	movzbl (%eax),%eax
  10516c:	3c 25                	cmp    $0x25,%al
  10516e:	75 ef                	jne    10515f <vprintfmt+0x37b>
				/* do nothing */;
			break;
		}
	}
  105170:	90                   	nop
{
	register int ch, err;

	printstate st = { .putch = putch, .putdat = putdat };
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  105171:	e9 bd fc ff ff       	jmp    104e33 <vprintfmt+0x4f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  105176:	83 c4 44             	add    $0x44,%esp
  105179:	5b                   	pop    %ebx
  10517a:	5d                   	pop    %ebp
  10517b:	c3                   	ret    

0010517c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  10517c:	55                   	push   %ebp
  10517d:	89 e5                	mov    %esp,%ebp
  10517f:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  105182:	8b 45 0c             	mov    0xc(%ebp),%eax
  105185:	8b 00                	mov    (%eax),%eax
  105187:	8b 55 08             	mov    0x8(%ebp),%edx
  10518a:	89 d1                	mov    %edx,%ecx
  10518c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10518f:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
  105193:	8d 50 01             	lea    0x1(%eax),%edx
  105196:	8b 45 0c             	mov    0xc(%ebp),%eax
  105199:	89 10                	mov    %edx,(%eax)
	if (b->idx == CPUTS_MAX-1) {
  10519b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10519e:	8b 00                	mov    (%eax),%eax
  1051a0:	3d ff 00 00 00       	cmp    $0xff,%eax
  1051a5:	75 24                	jne    1051cb <putch+0x4f>
		b->buf[b->idx] = 0;
  1051a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1051aa:	8b 00                	mov    (%eax),%eax
  1051ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  1051af:	c6 44 02 08 00       	movb   $0x0,0x8(%edx,%eax,1)
		cputs(b->buf);
  1051b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1051b7:	83 c0 08             	add    $0x8,%eax
  1051ba:	89 04 24             	mov    %eax,(%esp)
  1051bd:	e8 bf b1 ff ff       	call   100381 <cputs>
		b->idx = 0;
  1051c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1051c5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  1051cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1051ce:	8b 40 04             	mov    0x4(%eax),%eax
  1051d1:	8d 50 01             	lea    0x1(%eax),%edx
  1051d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1051d7:	89 50 04             	mov    %edx,0x4(%eax)
}
  1051da:	c9                   	leave  
  1051db:	c3                   	ret    

001051dc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  1051dc:	55                   	push   %ebp
  1051dd:	89 e5                	mov    %esp,%ebp
  1051df:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  1051e5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  1051ec:	00 00 00 
	b.cnt = 0;
  1051ef:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  1051f6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  1051f9:	b8 7c 51 10 00       	mov    $0x10517c,%eax
  1051fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  105201:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105205:	8b 55 08             	mov    0x8(%ebp),%edx
  105208:	89 54 24 08          	mov    %edx,0x8(%esp)
  10520c:	8d 95 f0 fe ff ff    	lea    -0x110(%ebp),%edx
  105212:	89 54 24 04          	mov    %edx,0x4(%esp)
  105216:	89 04 24             	mov    %eax,(%esp)
  105219:	e8 c6 fb ff ff       	call   104de4 <vprintfmt>

	b.buf[b.idx] = 0;
  10521e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  105224:	c6 84 05 f8 fe ff ff 	movb   $0x0,-0x108(%ebp,%eax,1)
  10522b:	00 
	cputs(b.buf);
  10522c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  105232:	83 c0 08             	add    $0x8,%eax
  105235:	89 04 24             	mov    %eax,(%esp)
  105238:	e8 44 b1 ff ff       	call   100381 <cputs>

	return b.cnt;
  10523d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  105243:	c9                   	leave  
  105244:	c3                   	ret    

00105245 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  105245:	55                   	push   %ebp
  105246:	89 e5                	mov    %esp,%ebp
  105248:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  10524b:	8d 45 08             	lea    0x8(%ebp),%eax
  10524e:	83 c0 04             	add    $0x4,%eax
  105251:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  105254:	8b 45 08             	mov    0x8(%ebp),%eax
  105257:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10525a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10525e:	89 04 24             	mov    %eax,(%esp)
  105261:	e8 76 ff ff ff       	call   1051dc <vcprintf>
  105266:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  105269:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10526c:	c9                   	leave  
  10526d:	c3                   	ret    
  10526e:	90                   	nop
  10526f:	90                   	nop

00105270 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  105270:	55                   	push   %ebp
  105271:	89 e5                	mov    %esp,%ebp
  105273:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  105276:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10527d:	eb 08                	jmp    105287 <strlen+0x17>
		n++;
  10527f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  105283:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105287:	8b 45 08             	mov    0x8(%ebp),%eax
  10528a:	0f b6 00             	movzbl (%eax),%eax
  10528d:	84 c0                	test   %al,%al
  10528f:	75 ee                	jne    10527f <strlen+0xf>
		n++;
	return n;
  105291:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105294:	c9                   	leave  
  105295:	c3                   	ret    

00105296 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  105296:	55                   	push   %ebp
  105297:	89 e5                	mov    %esp,%ebp
  105299:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  10529c:	8b 45 08             	mov    0x8(%ebp),%eax
  10529f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  1052a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1052a5:	0f b6 10             	movzbl (%eax),%edx
  1052a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1052ab:	88 10                	mov    %dl,(%eax)
  1052ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1052b0:	0f b6 00             	movzbl (%eax),%eax
  1052b3:	84 c0                	test   %al,%al
  1052b5:	0f 95 c0             	setne  %al
  1052b8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1052bc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  1052c0:	84 c0                	test   %al,%al
  1052c2:	75 de                	jne    1052a2 <strcpy+0xc>
		/* do nothing */;
	return ret;
  1052c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1052c7:	c9                   	leave  
  1052c8:	c3                   	ret    

001052c9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size)
{
  1052c9:	55                   	push   %ebp
  1052ca:	89 e5                	mov    %esp,%ebp
  1052cc:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  1052cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1052d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (i = 0; i < size; i++) {
  1052d5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  1052dc:	eb 21                	jmp    1052ff <strncpy+0x36>
		*dst++ = *src;
  1052de:	8b 45 0c             	mov    0xc(%ebp),%eax
  1052e1:	0f b6 10             	movzbl (%eax),%edx
  1052e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1052e7:	88 10                	mov    %dl,(%eax)
  1052e9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  1052ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  1052f0:	0f b6 00             	movzbl (%eax),%eax
  1052f3:	84 c0                	test   %al,%al
  1052f5:	74 04                	je     1052fb <strncpy+0x32>
			src++;
  1052f7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
{
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  1052fb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  1052ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105302:	3b 45 10             	cmp    0x10(%ebp),%eax
  105305:	72 d7                	jb     1052de <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  105307:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10530a:	c9                   	leave  
  10530b:	c3                   	ret    

0010530c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  10530c:	55                   	push   %ebp
  10530d:	89 e5                	mov    %esp,%ebp
  10530f:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  105312:	8b 45 08             	mov    0x8(%ebp),%eax
  105315:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  105318:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10531c:	74 2f                	je     10534d <strlcpy+0x41>
		while (--size > 0 && *src != '\0')
  10531e:	eb 13                	jmp    105333 <strlcpy+0x27>
			*dst++ = *src++;
  105320:	8b 45 0c             	mov    0xc(%ebp),%eax
  105323:	0f b6 10             	movzbl (%eax),%edx
  105326:	8b 45 08             	mov    0x8(%ebp),%eax
  105329:	88 10                	mov    %dl,(%eax)
  10532b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10532f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  105333:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105337:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10533b:	74 0a                	je     105347 <strlcpy+0x3b>
  10533d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105340:	0f b6 00             	movzbl (%eax),%eax
  105343:	84 c0                	test   %al,%al
  105345:	75 d9                	jne    105320 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  105347:	8b 45 08             	mov    0x8(%ebp),%eax
  10534a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  10534d:	8b 55 08             	mov    0x8(%ebp),%edx
  105350:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105353:	89 d1                	mov    %edx,%ecx
  105355:	29 c1                	sub    %eax,%ecx
  105357:	89 c8                	mov    %ecx,%eax
}
  105359:	c9                   	leave  
  10535a:	c3                   	ret    

0010535b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  10535b:	55                   	push   %ebp
  10535c:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  10535e:	eb 08                	jmp    105368 <strcmp+0xd>
		p++, q++;
  105360:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105364:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  105368:	8b 45 08             	mov    0x8(%ebp),%eax
  10536b:	0f b6 00             	movzbl (%eax),%eax
  10536e:	84 c0                	test   %al,%al
  105370:	74 10                	je     105382 <strcmp+0x27>
  105372:	8b 45 08             	mov    0x8(%ebp),%eax
  105375:	0f b6 10             	movzbl (%eax),%edx
  105378:	8b 45 0c             	mov    0xc(%ebp),%eax
  10537b:	0f b6 00             	movzbl (%eax),%eax
  10537e:	38 c2                	cmp    %al,%dl
  105380:	74 de                	je     105360 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  105382:	8b 45 08             	mov    0x8(%ebp),%eax
  105385:	0f b6 00             	movzbl (%eax),%eax
  105388:	0f b6 d0             	movzbl %al,%edx
  10538b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10538e:	0f b6 00             	movzbl (%eax),%eax
  105391:	0f b6 c0             	movzbl %al,%eax
  105394:	89 d1                	mov    %edx,%ecx
  105396:	29 c1                	sub    %eax,%ecx
  105398:	89 c8                	mov    %ecx,%eax
}
  10539a:	5d                   	pop    %ebp
  10539b:	c3                   	ret    

0010539c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  10539c:	55                   	push   %ebp
  10539d:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  10539f:	eb 0c                	jmp    1053ad <strncmp+0x11>
		n--, p++, q++;
  1053a1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1053a5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1053a9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  1053ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1053b1:	74 1a                	je     1053cd <strncmp+0x31>
  1053b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1053b6:	0f b6 00             	movzbl (%eax),%eax
  1053b9:	84 c0                	test   %al,%al
  1053bb:	74 10                	je     1053cd <strncmp+0x31>
  1053bd:	8b 45 08             	mov    0x8(%ebp),%eax
  1053c0:	0f b6 10             	movzbl (%eax),%edx
  1053c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053c6:	0f b6 00             	movzbl (%eax),%eax
  1053c9:	38 c2                	cmp    %al,%dl
  1053cb:	74 d4                	je     1053a1 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  1053cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1053d1:	75 07                	jne    1053da <strncmp+0x3e>
		return 0;
  1053d3:	b8 00 00 00 00       	mov    $0x0,%eax
  1053d8:	eb 18                	jmp    1053f2 <strncmp+0x56>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  1053da:	8b 45 08             	mov    0x8(%ebp),%eax
  1053dd:	0f b6 00             	movzbl (%eax),%eax
  1053e0:	0f b6 d0             	movzbl %al,%edx
  1053e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053e6:	0f b6 00             	movzbl (%eax),%eax
  1053e9:	0f b6 c0             	movzbl %al,%eax
  1053ec:	89 d1                	mov    %edx,%ecx
  1053ee:	29 c1                	sub    %eax,%ecx
  1053f0:	89 c8                	mov    %ecx,%eax
}
  1053f2:	5d                   	pop    %ebp
  1053f3:	c3                   	ret    

001053f4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  1053f4:	55                   	push   %ebp
  1053f5:	89 e5                	mov    %esp,%ebp
  1053f7:	83 ec 04             	sub    $0x4,%esp
  1053fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053fd:	88 45 fc             	mov    %al,-0x4(%ebp)
	while (*s != c)
  105400:	eb 1a                	jmp    10541c <strchr+0x28>
		if (*s++ == 0)
  105402:	8b 45 08             	mov    0x8(%ebp),%eax
  105405:	0f b6 00             	movzbl (%eax),%eax
  105408:	84 c0                	test   %al,%al
  10540a:	0f 94 c0             	sete   %al
  10540d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105411:	84 c0                	test   %al,%al
  105413:	74 07                	je     10541c <strchr+0x28>
			return NULL;
  105415:	b8 00 00 00 00       	mov    $0x0,%eax
  10541a:	eb 0e                	jmp    10542a <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	while (*s != c)
  10541c:	8b 45 08             	mov    0x8(%ebp),%eax
  10541f:	0f b6 00             	movzbl (%eax),%eax
  105422:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105425:	75 db                	jne    105402 <strchr+0xe>
		if (*s++ == 0)
			return NULL;
	return (char *) s;
  105427:	8b 45 08             	mov    0x8(%ebp),%eax
}
  10542a:	c9                   	leave  
  10542b:	c3                   	ret    

0010542c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  10542c:	55                   	push   %ebp
  10542d:	89 e5                	mov    %esp,%ebp
  10542f:	57                   	push   %edi
  105430:	83 ec 10             	sub    $0x10,%esp
	char *p;

	if (n == 0)
  105433:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105437:	75 05                	jne    10543e <memset+0x12>
		return v;
  105439:	8b 45 08             	mov    0x8(%ebp),%eax
  10543c:	eb 5c                	jmp    10549a <memset+0x6e>
	if ((int)v%4 == 0 && n%4 == 0) {
  10543e:	8b 45 08             	mov    0x8(%ebp),%eax
  105441:	83 e0 03             	and    $0x3,%eax
  105444:	85 c0                	test   %eax,%eax
  105446:	75 41                	jne    105489 <memset+0x5d>
  105448:	8b 45 10             	mov    0x10(%ebp),%eax
  10544b:	83 e0 03             	and    $0x3,%eax
  10544e:	85 c0                	test   %eax,%eax
  105450:	75 37                	jne    105489 <memset+0x5d>
		c &= 0xFF;
  105452:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  105459:	8b 45 0c             	mov    0xc(%ebp),%eax
  10545c:	89 c2                	mov    %eax,%edx
  10545e:	c1 e2 18             	shl    $0x18,%edx
  105461:	8b 45 0c             	mov    0xc(%ebp),%eax
  105464:	c1 e0 10             	shl    $0x10,%eax
  105467:	09 c2                	or     %eax,%edx
  105469:	8b 45 0c             	mov    0xc(%ebp),%eax
  10546c:	c1 e0 08             	shl    $0x8,%eax
  10546f:	09 d0                	or     %edx,%eax
  105471:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  105474:	8b 45 10             	mov    0x10(%ebp),%eax
  105477:	89 c1                	mov    %eax,%ecx
  105479:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  10547c:	8b 55 08             	mov    0x8(%ebp),%edx
  10547f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105482:	89 d7                	mov    %edx,%edi
  105484:	fc                   	cld    
  105485:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  105487:	eb 0e                	jmp    105497 <memset+0x6b>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  105489:	8b 55 08             	mov    0x8(%ebp),%edx
  10548c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10548f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  105492:	89 d7                	mov    %edx,%edi
  105494:	fc                   	cld    
  105495:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  105497:	8b 45 08             	mov    0x8(%ebp),%eax
}
  10549a:	83 c4 10             	add    $0x10,%esp
  10549d:	5f                   	pop    %edi
  10549e:	5d                   	pop    %ebp
  10549f:	c3                   	ret    

001054a0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  1054a0:	55                   	push   %ebp
  1054a1:	89 e5                	mov    %esp,%ebp
  1054a3:	57                   	push   %edi
  1054a4:	56                   	push   %esi
  1054a5:	53                   	push   %ebx
  1054a6:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;
	
	s = src;
  1054a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
	d = dst;
  1054af:	8b 45 08             	mov    0x8(%ebp),%eax
  1054b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (s < d && s + n > d) {
  1054b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1054b8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1054bb:	73 6e                	jae    10552b <memmove+0x8b>
  1054bd:	8b 45 10             	mov    0x10(%ebp),%eax
  1054c0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1054c3:	8d 04 02             	lea    (%edx,%eax,1),%eax
  1054c6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1054c9:	76 60                	jbe    10552b <memmove+0x8b>
		s += n;
  1054cb:	8b 45 10             	mov    0x10(%ebp),%eax
  1054ce:	01 45 ec             	add    %eax,-0x14(%ebp)
		d += n;
  1054d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1054d4:	01 45 f0             	add    %eax,-0x10(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  1054d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1054da:	83 e0 03             	and    $0x3,%eax
  1054dd:	85 c0                	test   %eax,%eax
  1054df:	75 2f                	jne    105510 <memmove+0x70>
  1054e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054e4:	83 e0 03             	and    $0x3,%eax
  1054e7:	85 c0                	test   %eax,%eax
  1054e9:	75 25                	jne    105510 <memmove+0x70>
  1054eb:	8b 45 10             	mov    0x10(%ebp),%eax
  1054ee:	83 e0 03             	and    $0x3,%eax
  1054f1:	85 c0                	test   %eax,%eax
  1054f3:	75 1b                	jne    105510 <memmove+0x70>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  1054f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054f8:	83 e8 04             	sub    $0x4,%eax
  1054fb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1054fe:	83 ea 04             	sub    $0x4,%edx
  105501:	8b 4d 10             	mov    0x10(%ebp),%ecx
  105504:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  105507:	89 c7                	mov    %eax,%edi
  105509:	89 d6                	mov    %edx,%esi
  10550b:	fd                   	std    
  10550c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  10550e:	eb 18                	jmp    105528 <memmove+0x88>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  105510:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105513:	8d 50 ff             	lea    -0x1(%eax),%edx
  105516:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105519:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  10551c:	8b 45 10             	mov    0x10(%ebp),%eax
  10551f:	89 d7                	mov    %edx,%edi
  105521:	89 de                	mov    %ebx,%esi
  105523:	89 c1                	mov    %eax,%ecx
  105525:	fd                   	std    
  105526:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  105528:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  105529:	eb 45                	jmp    105570 <memmove+0xd0>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  10552b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10552e:	83 e0 03             	and    $0x3,%eax
  105531:	85 c0                	test   %eax,%eax
  105533:	75 2b                	jne    105560 <memmove+0xc0>
  105535:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105538:	83 e0 03             	and    $0x3,%eax
  10553b:	85 c0                	test   %eax,%eax
  10553d:	75 21                	jne    105560 <memmove+0xc0>
  10553f:	8b 45 10             	mov    0x10(%ebp),%eax
  105542:	83 e0 03             	and    $0x3,%eax
  105545:	85 c0                	test   %eax,%eax
  105547:	75 17                	jne    105560 <memmove+0xc0>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  105549:	8b 45 10             	mov    0x10(%ebp),%eax
  10554c:	89 c1                	mov    %eax,%ecx
  10554e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  105551:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105554:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105557:	89 c7                	mov    %eax,%edi
  105559:	89 d6                	mov    %edx,%esi
  10555b:	fc                   	cld    
  10555c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  10555e:	eb 10                	jmp    105570 <memmove+0xd0>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  105560:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105563:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105566:	8b 4d 10             	mov    0x10(%ebp),%ecx
  105569:	89 c7                	mov    %eax,%edi
  10556b:	89 d6                	mov    %edx,%esi
  10556d:	fc                   	cld    
  10556e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  105570:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105573:	83 c4 10             	add    $0x10,%esp
  105576:	5b                   	pop    %ebx
  105577:	5e                   	pop    %esi
  105578:	5f                   	pop    %edi
  105579:	5d                   	pop    %ebp
  10557a:	c3                   	ret    

0010557b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  10557b:	55                   	push   %ebp
  10557c:	89 e5                	mov    %esp,%ebp
  10557e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  105581:	8b 45 10             	mov    0x10(%ebp),%eax
  105584:	89 44 24 08          	mov    %eax,0x8(%esp)
  105588:	8b 45 0c             	mov    0xc(%ebp),%eax
  10558b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10558f:	8b 45 08             	mov    0x8(%ebp),%eax
  105592:	89 04 24             	mov    %eax,(%esp)
  105595:	e8 06 ff ff ff       	call   1054a0 <memmove>
}
  10559a:	c9                   	leave  
  10559b:	c3                   	ret    

0010559c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  10559c:	55                   	push   %ebp
  10559d:	89 e5                	mov    %esp,%ebp
  10559f:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  1055a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1055a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  1055a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1055ab:	89 45 fc             	mov    %eax,-0x4(%ebp)

	while (n-- > 0) {
  1055ae:	eb 32                	jmp    1055e2 <memcmp+0x46>
		if (*s1 != *s2)
  1055b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1055b3:	0f b6 10             	movzbl (%eax),%edx
  1055b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1055b9:	0f b6 00             	movzbl (%eax),%eax
  1055bc:	38 c2                	cmp    %al,%dl
  1055be:	74 1a                	je     1055da <memcmp+0x3e>
			return (int) *s1 - (int) *s2;
  1055c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1055c3:	0f b6 00             	movzbl (%eax),%eax
  1055c6:	0f b6 d0             	movzbl %al,%edx
  1055c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1055cc:	0f b6 00             	movzbl (%eax),%eax
  1055cf:	0f b6 c0             	movzbl %al,%eax
  1055d2:	89 d1                	mov    %edx,%ecx
  1055d4:	29 c1                	sub    %eax,%ecx
  1055d6:	89 c8                	mov    %ecx,%eax
  1055d8:	eb 1c                	jmp    1055f6 <memcmp+0x5a>
		s1++, s2++;
  1055da:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  1055de:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  1055e2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1055e6:	0f 95 c0             	setne  %al
  1055e9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1055ed:	84 c0                	test   %al,%al
  1055ef:	75 bf                	jne    1055b0 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  1055f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1055f6:	c9                   	leave  
  1055f7:	c3                   	ret    

001055f8 <memchr>:

void *
memchr(const void *s, int c, size_t n)
{
  1055f8:	55                   	push   %ebp
  1055f9:	89 e5                	mov    %esp,%ebp
  1055fb:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  1055fe:	8b 45 10             	mov    0x10(%ebp),%eax
  105601:	8b 55 08             	mov    0x8(%ebp),%edx
  105604:	8d 04 02             	lea    (%edx,%eax,1),%eax
  105607:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  10560a:	eb 16                	jmp    105622 <memchr+0x2a>
		if (*(const unsigned char *) s == (unsigned char) c)
  10560c:	8b 45 08             	mov    0x8(%ebp),%eax
  10560f:	0f b6 10             	movzbl (%eax),%edx
  105612:	8b 45 0c             	mov    0xc(%ebp),%eax
  105615:	38 c2                	cmp    %al,%dl
  105617:	75 05                	jne    10561e <memchr+0x26>
			return (void *) s;
  105619:	8b 45 08             	mov    0x8(%ebp),%eax
  10561c:	eb 11                	jmp    10562f <memchr+0x37>

void *
memchr(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  10561e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105622:	8b 45 08             	mov    0x8(%ebp),%eax
  105625:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  105628:	72 e2                	jb     10560c <memchr+0x14>
		if (*(const unsigned char *) s == (unsigned char) c)
			return (void *) s;
	return NULL;
  10562a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10562f:	c9                   	leave  
  105630:	c3                   	ret    
  105631:	90                   	nop
  105632:	90                   	nop
  105633:	90                   	nop
  105634:	90                   	nop
  105635:	90                   	nop
  105636:	90                   	nop
  105637:	90                   	nop
  105638:	90                   	nop
  105639:	90                   	nop
  10563a:	90                   	nop
  10563b:	90                   	nop
  10563c:	90                   	nop
  10563d:	90                   	nop
  10563e:	90                   	nop
  10563f:	90                   	nop

00105640 <__udivdi3>:
  105640:	55                   	push   %ebp
  105641:	89 e5                	mov    %esp,%ebp
  105643:	57                   	push   %edi
  105644:	56                   	push   %esi
  105645:	83 ec 10             	sub    $0x10,%esp
  105648:	8b 45 14             	mov    0x14(%ebp),%eax
  10564b:	8b 55 08             	mov    0x8(%ebp),%edx
  10564e:	8b 75 10             	mov    0x10(%ebp),%esi
  105651:	8b 7d 0c             	mov    0xc(%ebp),%edi
  105654:	85 c0                	test   %eax,%eax
  105656:	89 55 f0             	mov    %edx,-0x10(%ebp)
  105659:	75 35                	jne    105690 <__udivdi3+0x50>
  10565b:	39 fe                	cmp    %edi,%esi
  10565d:	77 61                	ja     1056c0 <__udivdi3+0x80>
  10565f:	85 f6                	test   %esi,%esi
  105661:	75 0b                	jne    10566e <__udivdi3+0x2e>
  105663:	b8 01 00 00 00       	mov    $0x1,%eax
  105668:	31 d2                	xor    %edx,%edx
  10566a:	f7 f6                	div    %esi
  10566c:	89 c6                	mov    %eax,%esi
  10566e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105671:	31 d2                	xor    %edx,%edx
  105673:	89 f8                	mov    %edi,%eax
  105675:	f7 f6                	div    %esi
  105677:	89 c7                	mov    %eax,%edi
  105679:	89 c8                	mov    %ecx,%eax
  10567b:	f7 f6                	div    %esi
  10567d:	89 c1                	mov    %eax,%ecx
  10567f:	89 fa                	mov    %edi,%edx
  105681:	89 c8                	mov    %ecx,%eax
  105683:	83 c4 10             	add    $0x10,%esp
  105686:	5e                   	pop    %esi
  105687:	5f                   	pop    %edi
  105688:	5d                   	pop    %ebp
  105689:	c3                   	ret    
  10568a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  105690:	39 f8                	cmp    %edi,%eax
  105692:	77 1c                	ja     1056b0 <__udivdi3+0x70>
  105694:	0f bd d0             	bsr    %eax,%edx
  105697:	83 f2 1f             	xor    $0x1f,%edx
  10569a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10569d:	75 39                	jne    1056d8 <__udivdi3+0x98>
  10569f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  1056a2:	0f 86 a0 00 00 00    	jbe    105748 <__udivdi3+0x108>
  1056a8:	39 f8                	cmp    %edi,%eax
  1056aa:	0f 82 98 00 00 00    	jb     105748 <__udivdi3+0x108>
  1056b0:	31 ff                	xor    %edi,%edi
  1056b2:	31 c9                	xor    %ecx,%ecx
  1056b4:	89 c8                	mov    %ecx,%eax
  1056b6:	89 fa                	mov    %edi,%edx
  1056b8:	83 c4 10             	add    $0x10,%esp
  1056bb:	5e                   	pop    %esi
  1056bc:	5f                   	pop    %edi
  1056bd:	5d                   	pop    %ebp
  1056be:	c3                   	ret    
  1056bf:	90                   	nop
  1056c0:	89 d1                	mov    %edx,%ecx
  1056c2:	89 fa                	mov    %edi,%edx
  1056c4:	89 c8                	mov    %ecx,%eax
  1056c6:	31 ff                	xor    %edi,%edi
  1056c8:	f7 f6                	div    %esi
  1056ca:	89 c1                	mov    %eax,%ecx
  1056cc:	89 fa                	mov    %edi,%edx
  1056ce:	89 c8                	mov    %ecx,%eax
  1056d0:	83 c4 10             	add    $0x10,%esp
  1056d3:	5e                   	pop    %esi
  1056d4:	5f                   	pop    %edi
  1056d5:	5d                   	pop    %ebp
  1056d6:	c3                   	ret    
  1056d7:	90                   	nop
  1056d8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  1056dc:	89 f2                	mov    %esi,%edx
  1056de:	d3 e0                	shl    %cl,%eax
  1056e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1056e3:	b8 20 00 00 00       	mov    $0x20,%eax
  1056e8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  1056eb:	89 c1                	mov    %eax,%ecx
  1056ed:	d3 ea                	shr    %cl,%edx
  1056ef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  1056f3:	0b 55 ec             	or     -0x14(%ebp),%edx
  1056f6:	d3 e6                	shl    %cl,%esi
  1056f8:	89 c1                	mov    %eax,%ecx
  1056fa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  1056fd:	89 fe                	mov    %edi,%esi
  1056ff:	d3 ee                	shr    %cl,%esi
  105701:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  105705:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105708:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10570b:	d3 e7                	shl    %cl,%edi
  10570d:	89 c1                	mov    %eax,%ecx
  10570f:	d3 ea                	shr    %cl,%edx
  105711:	09 d7                	or     %edx,%edi
  105713:	89 f2                	mov    %esi,%edx
  105715:	89 f8                	mov    %edi,%eax
  105717:	f7 75 ec             	divl   -0x14(%ebp)
  10571a:	89 d6                	mov    %edx,%esi
  10571c:	89 c7                	mov    %eax,%edi
  10571e:	f7 65 e8             	mull   -0x18(%ebp)
  105721:	39 d6                	cmp    %edx,%esi
  105723:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105726:	72 30                	jb     105758 <__udivdi3+0x118>
  105728:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10572b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  10572f:	d3 e2                	shl    %cl,%edx
  105731:	39 c2                	cmp    %eax,%edx
  105733:	73 05                	jae    10573a <__udivdi3+0xfa>
  105735:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  105738:	74 1e                	je     105758 <__udivdi3+0x118>
  10573a:	89 f9                	mov    %edi,%ecx
  10573c:	31 ff                	xor    %edi,%edi
  10573e:	e9 71 ff ff ff       	jmp    1056b4 <__udivdi3+0x74>
  105743:	90                   	nop
  105744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  105748:	31 ff                	xor    %edi,%edi
  10574a:	b9 01 00 00 00       	mov    $0x1,%ecx
  10574f:	e9 60 ff ff ff       	jmp    1056b4 <__udivdi3+0x74>
  105754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  105758:	8d 4f ff             	lea    -0x1(%edi),%ecx
  10575b:	31 ff                	xor    %edi,%edi
  10575d:	89 c8                	mov    %ecx,%eax
  10575f:	89 fa                	mov    %edi,%edx
  105761:	83 c4 10             	add    $0x10,%esp
  105764:	5e                   	pop    %esi
  105765:	5f                   	pop    %edi
  105766:	5d                   	pop    %ebp
  105767:	c3                   	ret    
  105768:	90                   	nop
  105769:	90                   	nop
  10576a:	90                   	nop
  10576b:	90                   	nop
  10576c:	90                   	nop
  10576d:	90                   	nop
  10576e:	90                   	nop
  10576f:	90                   	nop

00105770 <__umoddi3>:
  105770:	55                   	push   %ebp
  105771:	89 e5                	mov    %esp,%ebp
  105773:	57                   	push   %edi
  105774:	56                   	push   %esi
  105775:	83 ec 20             	sub    $0x20,%esp
  105778:	8b 55 14             	mov    0x14(%ebp),%edx
  10577b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  10577e:	8b 7d 10             	mov    0x10(%ebp),%edi
  105781:	8b 75 0c             	mov    0xc(%ebp),%esi
  105784:	85 d2                	test   %edx,%edx
  105786:	89 c8                	mov    %ecx,%eax
  105788:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  10578b:	75 13                	jne    1057a0 <__umoddi3+0x30>
  10578d:	39 f7                	cmp    %esi,%edi
  10578f:	76 3f                	jbe    1057d0 <__umoddi3+0x60>
  105791:	89 f2                	mov    %esi,%edx
  105793:	f7 f7                	div    %edi
  105795:	89 d0                	mov    %edx,%eax
  105797:	31 d2                	xor    %edx,%edx
  105799:	83 c4 20             	add    $0x20,%esp
  10579c:	5e                   	pop    %esi
  10579d:	5f                   	pop    %edi
  10579e:	5d                   	pop    %ebp
  10579f:	c3                   	ret    
  1057a0:	39 f2                	cmp    %esi,%edx
  1057a2:	77 4c                	ja     1057f0 <__umoddi3+0x80>
  1057a4:	0f bd ca             	bsr    %edx,%ecx
  1057a7:	83 f1 1f             	xor    $0x1f,%ecx
  1057aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  1057ad:	75 51                	jne    105800 <__umoddi3+0x90>
  1057af:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  1057b2:	0f 87 e0 00 00 00    	ja     105898 <__umoddi3+0x128>
  1057b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1057bb:	29 f8                	sub    %edi,%eax
  1057bd:	19 d6                	sbb    %edx,%esi
  1057bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1057c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1057c5:	89 f2                	mov    %esi,%edx
  1057c7:	83 c4 20             	add    $0x20,%esp
  1057ca:	5e                   	pop    %esi
  1057cb:	5f                   	pop    %edi
  1057cc:	5d                   	pop    %ebp
  1057cd:	c3                   	ret    
  1057ce:	66 90                	xchg   %ax,%ax
  1057d0:	85 ff                	test   %edi,%edi
  1057d2:	75 0b                	jne    1057df <__umoddi3+0x6f>
  1057d4:	b8 01 00 00 00       	mov    $0x1,%eax
  1057d9:	31 d2                	xor    %edx,%edx
  1057db:	f7 f7                	div    %edi
  1057dd:	89 c7                	mov    %eax,%edi
  1057df:	89 f0                	mov    %esi,%eax
  1057e1:	31 d2                	xor    %edx,%edx
  1057e3:	f7 f7                	div    %edi
  1057e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1057e8:	f7 f7                	div    %edi
  1057ea:	eb a9                	jmp    105795 <__umoddi3+0x25>
  1057ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  1057f0:	89 c8                	mov    %ecx,%eax
  1057f2:	89 f2                	mov    %esi,%edx
  1057f4:	83 c4 20             	add    $0x20,%esp
  1057f7:	5e                   	pop    %esi
  1057f8:	5f                   	pop    %edi
  1057f9:	5d                   	pop    %ebp
  1057fa:	c3                   	ret    
  1057fb:	90                   	nop
  1057fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  105800:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  105804:	d3 e2                	shl    %cl,%edx
  105806:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105809:	ba 20 00 00 00       	mov    $0x20,%edx
  10580e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  105811:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105814:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  105818:	89 fa                	mov    %edi,%edx
  10581a:	d3 ea                	shr    %cl,%edx
  10581c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  105820:	0b 55 f4             	or     -0xc(%ebp),%edx
  105823:	d3 e7                	shl    %cl,%edi
  105825:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  105829:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10582c:	89 f2                	mov    %esi,%edx
  10582e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  105831:	89 c7                	mov    %eax,%edi
  105833:	d3 ea                	shr    %cl,%edx
  105835:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  105839:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10583c:	89 c2                	mov    %eax,%edx
  10583e:	d3 e6                	shl    %cl,%esi
  105840:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  105844:	d3 ea                	shr    %cl,%edx
  105846:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  10584a:	09 d6                	or     %edx,%esi
  10584c:	89 f0                	mov    %esi,%eax
  10584e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  105851:	d3 e7                	shl    %cl,%edi
  105853:	89 f2                	mov    %esi,%edx
  105855:	f7 75 f4             	divl   -0xc(%ebp)
  105858:	89 d6                	mov    %edx,%esi
  10585a:	f7 65 e8             	mull   -0x18(%ebp)
  10585d:	39 d6                	cmp    %edx,%esi
  10585f:	72 2b                	jb     10588c <__umoddi3+0x11c>
  105861:	39 c7                	cmp    %eax,%edi
  105863:	72 23                	jb     105888 <__umoddi3+0x118>
  105865:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  105869:	29 c7                	sub    %eax,%edi
  10586b:	19 d6                	sbb    %edx,%esi
  10586d:	89 f0                	mov    %esi,%eax
  10586f:	89 f2                	mov    %esi,%edx
  105871:	d3 ef                	shr    %cl,%edi
  105873:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  105877:	d3 e0                	shl    %cl,%eax
  105879:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  10587d:	09 f8                	or     %edi,%eax
  10587f:	d3 ea                	shr    %cl,%edx
  105881:	83 c4 20             	add    $0x20,%esp
  105884:	5e                   	pop    %esi
  105885:	5f                   	pop    %edi
  105886:	5d                   	pop    %ebp
  105887:	c3                   	ret    
  105888:	39 d6                	cmp    %edx,%esi
  10588a:	75 d9                	jne    105865 <__umoddi3+0xf5>
  10588c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  10588f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  105892:	eb d1                	jmp    105865 <__umoddi3+0xf5>
  105894:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  105898:	39 f2                	cmp    %esi,%edx
  10589a:	0f 82 18 ff ff ff    	jb     1057b8 <__umoddi3+0x48>
  1058a0:	e9 1d ff ff ff       	jmp    1057c2 <__umoddi3+0x52>
