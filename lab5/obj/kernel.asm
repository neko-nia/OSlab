
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	f1a50513          	addi	a0,a0,-230 # ffffffffc02a0f50 <edata>
ffffffffc020003e:	000ac617          	auipc	a2,0xac
ffffffffc0200042:	4a260613          	addi	a2,a2,1186 # ffffffffc02ac4e0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	140060ef          	jal	ra,ffffffffc020618e <memset>
    cons_init();                // init the console
ffffffffc0200052:	58e000ef          	jal	ra,ffffffffc02005e0 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	57258593          	addi	a1,a1,1394 # ffffffffc02065c8 <etext>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	58a50513          	addi	a0,a0,1418 # ffffffffc02065e8 <etext+0x20>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	25a000ef          	jal	ra,ffffffffc02002c4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	55d030ef          	jal	ra,ffffffffc0203dca <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5e2000ef          	jal	ra,ffffffffc0200654 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5ec000ef          	jal	ra,ffffffffc0200662 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	19c010ef          	jal	ra,ffffffffc0201216 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	51b050ef          	jal	ra,ffffffffc0205d98 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4b0000ef          	jal	ra,ffffffffc0200532 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	0ca020ef          	jal	ra,ffffffffc0202150 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	500000ef          	jal	ra,ffffffffc020058a <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c8000ef          	jal	ra,ffffffffc0200656 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	653050ef          	jal	ra,ffffffffc0205ee4 <cpu_idle>

ffffffffc0200096 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200096:	1141                	addi	sp,sp,-16
ffffffffc0200098:	e022                	sd	s0,0(sp)
ffffffffc020009a:	e406                	sd	ra,8(sp)
ffffffffc020009c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009e:	544000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
    (*cnt) ++;
ffffffffc02000a2:	401c                	lw	a5,0(s0)
}
ffffffffc02000a4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a6:	2785                	addiw	a5,a5,1
ffffffffc02000a8:	c01c                	sw	a5,0(s0)
}
ffffffffc02000aa:	6402                	ld	s0,0(sp)
ffffffffc02000ac:	0141                	addi	sp,sp,16
ffffffffc02000ae:	8082                	ret

ffffffffc02000b0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b0:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	86ae                	mv	a3,a1
ffffffffc02000b4:	862a                	mv	a2,a0
ffffffffc02000b6:	006c                	addi	a1,sp,12
ffffffffc02000b8:	00000517          	auipc	a0,0x0
ffffffffc02000bc:	fde50513          	addi	a0,a0,-34 # ffffffffc0200096 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000c0:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000c2:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c4:	160060ef          	jal	ra,ffffffffc0206224 <vprintfmt>
    return cnt;
}
ffffffffc02000c8:	60e2                	ld	ra,24(sp)
ffffffffc02000ca:	4532                	lw	a0,12(sp)
ffffffffc02000cc:	6105                	addi	sp,sp,32
ffffffffc02000ce:	8082                	ret

ffffffffc02000d0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000d2:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	f42e                	sd	a1,40(sp)
ffffffffc02000d8:	f832                	sd	a2,48(sp)
ffffffffc02000da:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	862a                	mv	a2,a0
ffffffffc02000de:	004c                	addi	a1,sp,4
ffffffffc02000e0:	00000517          	auipc	a0,0x0
ffffffffc02000e4:	fb650513          	addi	a0,a0,-74 # ffffffffc0200096 <cputch>
ffffffffc02000e8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000ea:	ec06                	sd	ra,24(sp)
ffffffffc02000ec:	e0ba                	sd	a4,64(sp)
ffffffffc02000ee:	e4be                	sd	a5,72(sp)
ffffffffc02000f0:	e8c2                	sd	a6,80(sp)
ffffffffc02000f2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f8:	12c060ef          	jal	ra,ffffffffc0206224 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fc:	60e2                	ld	ra,24(sp)
ffffffffc02000fe:	4512                	lw	a0,4(sp)
ffffffffc0200100:	6125                	addi	sp,sp,96
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200104:	4de0006f          	j	ffffffffc02005e2 <cons_putc>

ffffffffc0200108 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200108:	1101                	addi	sp,sp,-32
ffffffffc020010a:	e822                	sd	s0,16(sp)
ffffffffc020010c:	ec06                	sd	ra,24(sp)
ffffffffc020010e:	e426                	sd	s1,8(sp)
ffffffffc0200110:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200112:	00054503          	lbu	a0,0(a0)
ffffffffc0200116:	c51d                	beqz	a0,ffffffffc0200144 <cputs+0x3c>
ffffffffc0200118:	0405                	addi	s0,s0,1
ffffffffc020011a:	4485                	li	s1,1
ffffffffc020011c:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011e:	4c4000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
    (*cnt) ++;
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	fff44503          	lbu	a0,-1(s0)
ffffffffc020012c:	f96d                	bnez	a0,ffffffffc020011e <cputs+0x16>
ffffffffc020012e:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200132:	4529                	li	a0,10
ffffffffc0200134:	4ae000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200138:	8522                	mv	a0,s0
ffffffffc020013a:	60e2                	ld	ra,24(sp)
ffffffffc020013c:	6442                	ld	s0,16(sp)
ffffffffc020013e:	64a2                	ld	s1,8(sp)
ffffffffc0200140:	6105                	addi	sp,sp,32
ffffffffc0200142:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200144:	4405                	li	s0,1
ffffffffc0200146:	b7f5                	j	ffffffffc0200132 <cputs+0x2a>

ffffffffc0200148 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200148:	1141                	addi	sp,sp,-16
ffffffffc020014a:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020014c:	4cc000ef          	jal	ra,ffffffffc0200618 <cons_getc>
ffffffffc0200150:	dd75                	beqz	a0,ffffffffc020014c <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200152:	60a2                	ld	ra,8(sp)
ffffffffc0200154:	0141                	addi	sp,sp,16
ffffffffc0200156:	8082                	ret

ffffffffc0200158 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200158:	715d                	addi	sp,sp,-80
ffffffffc020015a:	e486                	sd	ra,72(sp)
ffffffffc020015c:	e0a2                	sd	s0,64(sp)
ffffffffc020015e:	fc26                	sd	s1,56(sp)
ffffffffc0200160:	f84a                	sd	s2,48(sp)
ffffffffc0200162:	f44e                	sd	s3,40(sp)
ffffffffc0200164:	f052                	sd	s4,32(sp)
ffffffffc0200166:	ec56                	sd	s5,24(sp)
ffffffffc0200168:	e85a                	sd	s6,16(sp)
ffffffffc020016a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020016c:	c901                	beqz	a0,ffffffffc020017c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020016e:	85aa                	mv	a1,a0
ffffffffc0200170:	00006517          	auipc	a0,0x6
ffffffffc0200174:	48050513          	addi	a0,a0,1152 # ffffffffc02065f0 <etext+0x28>
ffffffffc0200178:	f59ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
readline(const char *prompt) {
ffffffffc020017c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020017e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200180:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200182:	4aa9                	li	s5,10
ffffffffc0200184:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200186:	000a1b97          	auipc	s7,0xa1
ffffffffc020018a:	dcab8b93          	addi	s7,s7,-566 # ffffffffc02a0f50 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020018e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200192:	fb7ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc0200196:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200198:	00054b63          	bltz	a0,ffffffffc02001ae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020019c:	00a95b63          	ble	a0,s2,ffffffffc02001b2 <readline+0x5a>
ffffffffc02001a0:	029a5463          	ble	s1,s4,ffffffffc02001c8 <readline+0x70>
        c = getchar();
ffffffffc02001a4:	fa5ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc02001a8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001aa:	fe0559e3          	bgez	a0,ffffffffc020019c <readline+0x44>
            return NULL;
ffffffffc02001ae:	4501                	li	a0,0
ffffffffc02001b0:	a099                	j	ffffffffc02001f6 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02001b2:	03341463          	bne	s0,s3,ffffffffc02001da <readline+0x82>
ffffffffc02001b6:	e8b9                	bnez	s1,ffffffffc020020c <readline+0xb4>
        c = getchar();
ffffffffc02001b8:	f91ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc02001bc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001be:	fe0548e3          	bltz	a0,ffffffffc02001ae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001c2:	fea958e3          	ble	a0,s2,ffffffffc02001b2 <readline+0x5a>
ffffffffc02001c6:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001c8:	8522                	mv	a0,s0
ffffffffc02001ca:	f3bff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i ++] = c;
ffffffffc02001ce:	009b87b3          	add	a5,s7,s1
ffffffffc02001d2:	00878023          	sb	s0,0(a5)
ffffffffc02001d6:	2485                	addiw	s1,s1,1
ffffffffc02001d8:	bf6d                	j	ffffffffc0200192 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02001da:	01540463          	beq	s0,s5,ffffffffc02001e2 <readline+0x8a>
ffffffffc02001de:	fb641ae3          	bne	s0,s6,ffffffffc0200192 <readline+0x3a>
            cputchar(c);
ffffffffc02001e2:	8522                	mv	a0,s0
ffffffffc02001e4:	f21ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i] = '\0';
ffffffffc02001e8:	000a1517          	auipc	a0,0xa1
ffffffffc02001ec:	d6850513          	addi	a0,a0,-664 # ffffffffc02a0f50 <edata>
ffffffffc02001f0:	94aa                	add	s1,s1,a0
ffffffffc02001f2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001f6:	60a6                	ld	ra,72(sp)
ffffffffc02001f8:	6406                	ld	s0,64(sp)
ffffffffc02001fa:	74e2                	ld	s1,56(sp)
ffffffffc02001fc:	7942                	ld	s2,48(sp)
ffffffffc02001fe:	79a2                	ld	s3,40(sp)
ffffffffc0200200:	7a02                	ld	s4,32(sp)
ffffffffc0200202:	6ae2                	ld	s5,24(sp)
ffffffffc0200204:	6b42                	ld	s6,16(sp)
ffffffffc0200206:	6ba2                	ld	s7,8(sp)
ffffffffc0200208:	6161                	addi	sp,sp,80
ffffffffc020020a:	8082                	ret
            cputchar(c);
ffffffffc020020c:	4521                	li	a0,8
ffffffffc020020e:	ef7ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            i --;
ffffffffc0200212:	34fd                	addiw	s1,s1,-1
ffffffffc0200214:	bfbd                	j	ffffffffc0200192 <readline+0x3a>

ffffffffc0200216 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200216:	000ac317          	auipc	t1,0xac
ffffffffc020021a:	13a30313          	addi	t1,t1,314 # ffffffffc02ac350 <is_panic>
ffffffffc020021e:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200222:	715d                	addi	sp,sp,-80
ffffffffc0200224:	ec06                	sd	ra,24(sp)
ffffffffc0200226:	e822                	sd	s0,16(sp)
ffffffffc0200228:	f436                	sd	a3,40(sp)
ffffffffc020022a:	f83a                	sd	a4,48(sp)
ffffffffc020022c:	fc3e                	sd	a5,56(sp)
ffffffffc020022e:	e0c2                	sd	a6,64(sp)
ffffffffc0200230:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200232:	02031c63          	bnez	t1,ffffffffc020026a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200236:	4785                	li	a5,1
ffffffffc0200238:	8432                	mv	s0,a2
ffffffffc020023a:	000ac717          	auipc	a4,0xac
ffffffffc020023e:	10f73b23          	sd	a5,278(a4) # ffffffffc02ac350 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200242:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200244:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200246:	85aa                	mv	a1,a0
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	3b050513          	addi	a0,a0,944 # ffffffffc02065f8 <etext+0x30>
    va_start(ap, fmt);
ffffffffc0200250:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200252:	e7fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200256:	65a2                	ld	a1,8(sp)
ffffffffc0200258:	8522                	mv	a0,s0
ffffffffc020025a:	e57ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020025e:	00008517          	auipc	a0,0x8
ffffffffc0200262:	eba50513          	addi	a0,a0,-326 # ffffffffc0208118 <default_pmm_manager+0x408>
ffffffffc0200266:	e6bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020026a:	4501                	li	a0,0
ffffffffc020026c:	4581                	li	a1,0
ffffffffc020026e:	4601                	li	a2,0
ffffffffc0200270:	48a1                	li	a7,8
ffffffffc0200272:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200276:	3e6000ef          	jal	ra,ffffffffc020065c <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020027a:	4501                	li	a0,0
ffffffffc020027c:	174000ef          	jal	ra,ffffffffc02003f0 <kmonitor>
ffffffffc0200280:	bfed                	j	ffffffffc020027a <__panic+0x64>

ffffffffc0200282 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200282:	715d                	addi	sp,sp,-80
ffffffffc0200284:	e822                	sd	s0,16(sp)
ffffffffc0200286:	fc3e                	sd	a5,56(sp)
ffffffffc0200288:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc020028a:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020028c:	862e                	mv	a2,a1
ffffffffc020028e:	85aa                	mv	a1,a0
ffffffffc0200290:	00006517          	auipc	a0,0x6
ffffffffc0200294:	38850513          	addi	a0,a0,904 # ffffffffc0206618 <etext+0x50>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200298:	ec06                	sd	ra,24(sp)
ffffffffc020029a:	f436                	sd	a3,40(sp)
ffffffffc020029c:	f83a                	sd	a4,48(sp)
ffffffffc020029e:	e0c2                	sd	a6,64(sp)
ffffffffc02002a0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02002a2:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002a4:	e2dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02002a8:	65a2                	ld	a1,8(sp)
ffffffffc02002aa:	8522                	mv	a0,s0
ffffffffc02002ac:	e05ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc02002b0:	00008517          	auipc	a0,0x8
ffffffffc02002b4:	e6850513          	addi	a0,a0,-408 # ffffffffc0208118 <default_pmm_manager+0x408>
ffffffffc02002b8:	e19ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);
}
ffffffffc02002bc:	60e2                	ld	ra,24(sp)
ffffffffc02002be:	6442                	ld	s0,16(sp)
ffffffffc02002c0:	6161                	addi	sp,sp,80
ffffffffc02002c2:	8082                	ret

ffffffffc02002c4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002c4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002c6:	00006517          	auipc	a0,0x6
ffffffffc02002ca:	3a250513          	addi	a0,a0,930 # ffffffffc0206668 <etext+0xa0>
void print_kerninfo(void) {
ffffffffc02002ce:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002d0:	e01ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002d4:	00000597          	auipc	a1,0x0
ffffffffc02002d8:	d6258593          	addi	a1,a1,-670 # ffffffffc0200036 <kern_init>
ffffffffc02002dc:	00006517          	auipc	a0,0x6
ffffffffc02002e0:	3ac50513          	addi	a0,a0,940 # ffffffffc0206688 <etext+0xc0>
ffffffffc02002e4:	dedff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002e8:	00006597          	auipc	a1,0x6
ffffffffc02002ec:	2e058593          	addi	a1,a1,736 # ffffffffc02065c8 <etext>
ffffffffc02002f0:	00006517          	auipc	a0,0x6
ffffffffc02002f4:	3b850513          	addi	a0,a0,952 # ffffffffc02066a8 <etext+0xe0>
ffffffffc02002f8:	dd9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002fc:	000a1597          	auipc	a1,0xa1
ffffffffc0200300:	c5458593          	addi	a1,a1,-940 # ffffffffc02a0f50 <edata>
ffffffffc0200304:	00006517          	auipc	a0,0x6
ffffffffc0200308:	3c450513          	addi	a0,a0,964 # ffffffffc02066c8 <etext+0x100>
ffffffffc020030c:	dc5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200310:	000ac597          	auipc	a1,0xac
ffffffffc0200314:	1d058593          	addi	a1,a1,464 # ffffffffc02ac4e0 <end>
ffffffffc0200318:	00006517          	auipc	a0,0x6
ffffffffc020031c:	3d050513          	addi	a0,a0,976 # ffffffffc02066e8 <etext+0x120>
ffffffffc0200320:	db1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200324:	000ac597          	auipc	a1,0xac
ffffffffc0200328:	5bb58593          	addi	a1,a1,1467 # ffffffffc02ac8df <end+0x3ff>
ffffffffc020032c:	00000797          	auipc	a5,0x0
ffffffffc0200330:	d0a78793          	addi	a5,a5,-758 # ffffffffc0200036 <kern_init>
ffffffffc0200334:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200338:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020033c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020033e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200342:	95be                	add	a1,a1,a5
ffffffffc0200344:	85a9                	srai	a1,a1,0xa
ffffffffc0200346:	00006517          	auipc	a0,0x6
ffffffffc020034a:	3c250513          	addi	a0,a0,962 # ffffffffc0206708 <etext+0x140>
}
ffffffffc020034e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200350:	d81ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200354 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200354:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200356:	00006617          	auipc	a2,0x6
ffffffffc020035a:	2e260613          	addi	a2,a2,738 # ffffffffc0206638 <etext+0x70>
ffffffffc020035e:	04d00593          	li	a1,77
ffffffffc0200362:	00006517          	auipc	a0,0x6
ffffffffc0200366:	2ee50513          	addi	a0,a0,750 # ffffffffc0206650 <etext+0x88>
void print_stackframe(void) {
ffffffffc020036a:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020036c:	eabff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200370 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200370:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200372:	00006617          	auipc	a2,0x6
ffffffffc0200376:	4a660613          	addi	a2,a2,1190 # ffffffffc0206818 <commands+0xe0>
ffffffffc020037a:	00006597          	auipc	a1,0x6
ffffffffc020037e:	4be58593          	addi	a1,a1,1214 # ffffffffc0206838 <commands+0x100>
ffffffffc0200382:	00006517          	auipc	a0,0x6
ffffffffc0200386:	4be50513          	addi	a0,a0,1214 # ffffffffc0206840 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020038a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020038c:	d45ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200390:	00006617          	auipc	a2,0x6
ffffffffc0200394:	4c060613          	addi	a2,a2,1216 # ffffffffc0206850 <commands+0x118>
ffffffffc0200398:	00006597          	auipc	a1,0x6
ffffffffc020039c:	4e058593          	addi	a1,a1,1248 # ffffffffc0206878 <commands+0x140>
ffffffffc02003a0:	00006517          	auipc	a0,0x6
ffffffffc02003a4:	4a050513          	addi	a0,a0,1184 # ffffffffc0206840 <commands+0x108>
ffffffffc02003a8:	d29ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02003ac:	00006617          	auipc	a2,0x6
ffffffffc02003b0:	4dc60613          	addi	a2,a2,1244 # ffffffffc0206888 <commands+0x150>
ffffffffc02003b4:	00006597          	auipc	a1,0x6
ffffffffc02003b8:	4f458593          	addi	a1,a1,1268 # ffffffffc02068a8 <commands+0x170>
ffffffffc02003bc:	00006517          	auipc	a0,0x6
ffffffffc02003c0:	48450513          	addi	a0,a0,1156 # ffffffffc0206840 <commands+0x108>
ffffffffc02003c4:	d0dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    }
    return 0;
}
ffffffffc02003c8:	60a2                	ld	ra,8(sp)
ffffffffc02003ca:	4501                	li	a0,0
ffffffffc02003cc:	0141                	addi	sp,sp,16
ffffffffc02003ce:	8082                	ret

ffffffffc02003d0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003d0:	1141                	addi	sp,sp,-16
ffffffffc02003d2:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003d4:	ef1ff0ef          	jal	ra,ffffffffc02002c4 <print_kerninfo>
    return 0;
}
ffffffffc02003d8:	60a2                	ld	ra,8(sp)
ffffffffc02003da:	4501                	li	a0,0
ffffffffc02003dc:	0141                	addi	sp,sp,16
ffffffffc02003de:	8082                	ret

ffffffffc02003e0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003e0:	1141                	addi	sp,sp,-16
ffffffffc02003e2:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003e4:	f71ff0ef          	jal	ra,ffffffffc0200354 <print_stackframe>
    return 0;
}
ffffffffc02003e8:	60a2                	ld	ra,8(sp)
ffffffffc02003ea:	4501                	li	a0,0
ffffffffc02003ec:	0141                	addi	sp,sp,16
ffffffffc02003ee:	8082                	ret

ffffffffc02003f0 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003f0:	7115                	addi	sp,sp,-224
ffffffffc02003f2:	e962                	sd	s8,144(sp)
ffffffffc02003f4:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003f6:	00006517          	auipc	a0,0x6
ffffffffc02003fa:	38a50513          	addi	a0,a0,906 # ffffffffc0206780 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02003fe:	ed86                	sd	ra,216(sp)
ffffffffc0200400:	e9a2                	sd	s0,208(sp)
ffffffffc0200402:	e5a6                	sd	s1,200(sp)
ffffffffc0200404:	e1ca                	sd	s2,192(sp)
ffffffffc0200406:	fd4e                	sd	s3,184(sp)
ffffffffc0200408:	f952                	sd	s4,176(sp)
ffffffffc020040a:	f556                	sd	s5,168(sp)
ffffffffc020040c:	f15a                	sd	s6,160(sp)
ffffffffc020040e:	ed5e                	sd	s7,152(sp)
ffffffffc0200410:	e566                	sd	s9,136(sp)
ffffffffc0200412:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200414:	cbdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200418:	00006517          	auipc	a0,0x6
ffffffffc020041c:	39050513          	addi	a0,a0,912 # ffffffffc02067a8 <commands+0x70>
ffffffffc0200420:	cb1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200424:	000c0563          	beqz	s8,ffffffffc020042e <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200428:	8562                	mv	a0,s8
ffffffffc020042a:	420000ef          	jal	ra,ffffffffc020084a <print_trapframe>
ffffffffc020042e:	00006c97          	auipc	s9,0x6
ffffffffc0200432:	30ac8c93          	addi	s9,s9,778 # ffffffffc0206738 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200436:	00006997          	auipc	s3,0x6
ffffffffc020043a:	39a98993          	addi	s3,s3,922 # ffffffffc02067d0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043e:	00006917          	auipc	s2,0x6
ffffffffc0200442:	39a90913          	addi	s2,s2,922 # ffffffffc02067d8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200446:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200448:	00006b17          	auipc	s6,0x6
ffffffffc020044c:	398b0b13          	addi	s6,s6,920 # ffffffffc02067e0 <commands+0xa8>
    if (argc == 0) {
ffffffffc0200450:	00006a97          	auipc	s5,0x6
ffffffffc0200454:	3e8a8a93          	addi	s5,s5,1000 # ffffffffc0206838 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200458:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020045a:	854e                	mv	a0,s3
ffffffffc020045c:	cfdff0ef          	jal	ra,ffffffffc0200158 <readline>
ffffffffc0200460:	842a                	mv	s0,a0
ffffffffc0200462:	dd65                	beqz	a0,ffffffffc020045a <kmonitor+0x6a>
ffffffffc0200464:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200468:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020046a:	c999                	beqz	a1,ffffffffc0200480 <kmonitor+0x90>
ffffffffc020046c:	854a                	mv	a0,s2
ffffffffc020046e:	503050ef          	jal	ra,ffffffffc0206170 <strchr>
ffffffffc0200472:	c925                	beqz	a0,ffffffffc02004e2 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200474:	00144583          	lbu	a1,1(s0)
ffffffffc0200478:	00040023          	sb	zero,0(s0)
ffffffffc020047c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020047e:	f5fd                	bnez	a1,ffffffffc020046c <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200480:	dce9                	beqz	s1,ffffffffc020045a <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200482:	6582                	ld	a1,0(sp)
ffffffffc0200484:	00006d17          	auipc	s10,0x6
ffffffffc0200488:	2b4d0d13          	addi	s10,s10,692 # ffffffffc0206738 <commands>
    if (argc == 0) {
ffffffffc020048c:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020048e:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200490:	0d61                	addi	s10,s10,24
ffffffffc0200492:	4b5050ef          	jal	ra,ffffffffc0206146 <strcmp>
ffffffffc0200496:	c919                	beqz	a0,ffffffffc02004ac <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200498:	2405                	addiw	s0,s0,1
ffffffffc020049a:	09740463          	beq	s0,s7,ffffffffc0200522 <kmonitor+0x132>
ffffffffc020049e:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02004a2:	6582                	ld	a1,0(sp)
ffffffffc02004a4:	0d61                	addi	s10,s10,24
ffffffffc02004a6:	4a1050ef          	jal	ra,ffffffffc0206146 <strcmp>
ffffffffc02004aa:	f57d                	bnez	a0,ffffffffc0200498 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02004ac:	00141793          	slli	a5,s0,0x1
ffffffffc02004b0:	97a2                	add	a5,a5,s0
ffffffffc02004b2:	078e                	slli	a5,a5,0x3
ffffffffc02004b4:	97e6                	add	a5,a5,s9
ffffffffc02004b6:	6b9c                	ld	a5,16(a5)
ffffffffc02004b8:	8662                	mv	a2,s8
ffffffffc02004ba:	002c                	addi	a1,sp,8
ffffffffc02004bc:	fff4851b          	addiw	a0,s1,-1
ffffffffc02004c0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02004c2:	f8055ce3          	bgez	a0,ffffffffc020045a <kmonitor+0x6a>
}
ffffffffc02004c6:	60ee                	ld	ra,216(sp)
ffffffffc02004c8:	644e                	ld	s0,208(sp)
ffffffffc02004ca:	64ae                	ld	s1,200(sp)
ffffffffc02004cc:	690e                	ld	s2,192(sp)
ffffffffc02004ce:	79ea                	ld	s3,184(sp)
ffffffffc02004d0:	7a4a                	ld	s4,176(sp)
ffffffffc02004d2:	7aaa                	ld	s5,168(sp)
ffffffffc02004d4:	7b0a                	ld	s6,160(sp)
ffffffffc02004d6:	6bea                	ld	s7,152(sp)
ffffffffc02004d8:	6c4a                	ld	s8,144(sp)
ffffffffc02004da:	6caa                	ld	s9,136(sp)
ffffffffc02004dc:	6d0a                	ld	s10,128(sp)
ffffffffc02004de:	612d                	addi	sp,sp,224
ffffffffc02004e0:	8082                	ret
        if (*buf == '\0') {
ffffffffc02004e2:	00044783          	lbu	a5,0(s0)
ffffffffc02004e6:	dfc9                	beqz	a5,ffffffffc0200480 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02004e8:	03448863          	beq	s1,s4,ffffffffc0200518 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02004ec:	00349793          	slli	a5,s1,0x3
ffffffffc02004f0:	0118                	addi	a4,sp,128
ffffffffc02004f2:	97ba                	add	a5,a5,a4
ffffffffc02004f4:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f8:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004fc:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fe:	e591                	bnez	a1,ffffffffc020050a <kmonitor+0x11a>
ffffffffc0200500:	b749                	j	ffffffffc0200482 <kmonitor+0x92>
            buf ++;
ffffffffc0200502:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
ffffffffc0200508:	ddad                	beqz	a1,ffffffffc0200482 <kmonitor+0x92>
ffffffffc020050a:	854a                	mv	a0,s2
ffffffffc020050c:	465050ef          	jal	ra,ffffffffc0206170 <strchr>
ffffffffc0200510:	d96d                	beqz	a0,ffffffffc0200502 <kmonitor+0x112>
ffffffffc0200512:	00044583          	lbu	a1,0(s0)
ffffffffc0200516:	bf91                	j	ffffffffc020046a <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200518:	45c1                	li	a1,16
ffffffffc020051a:	855a                	mv	a0,s6
ffffffffc020051c:	bb5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200520:	b7f1                	j	ffffffffc02004ec <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200522:	6582                	ld	a1,0(sp)
ffffffffc0200524:	00006517          	auipc	a0,0x6
ffffffffc0200528:	2dc50513          	addi	a0,a0,732 # ffffffffc0206800 <commands+0xc8>
ffffffffc020052c:	ba5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
ffffffffc0200530:	b72d                	j	ffffffffc020045a <kmonitor+0x6a>

ffffffffc0200532 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200534:	00253513          	sltiu	a0,a0,2
ffffffffc0200538:	8082                	ret

ffffffffc020053a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020053a:	03800513          	li	a0,56
ffffffffc020053e:	8082                	ret

ffffffffc0200540 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200540:	000a1797          	auipc	a5,0xa1
ffffffffc0200544:	e1078793          	addi	a5,a5,-496 # ffffffffc02a1350 <ide>
ffffffffc0200548:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020054c:	1141                	addi	sp,sp,-16
ffffffffc020054e:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200550:	95be                	add	a1,a1,a5
ffffffffc0200552:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200556:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200558:	449050ef          	jal	ra,ffffffffc02061a0 <memcpy>
    return 0;
}
ffffffffc020055c:	60a2                	ld	ra,8(sp)
ffffffffc020055e:	4501                	li	a0,0
ffffffffc0200560:	0141                	addi	sp,sp,16
ffffffffc0200562:	8082                	ret

ffffffffc0200564 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200564:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200566:	0095979b          	slliw	a5,a1,0x9
ffffffffc020056a:	000a1517          	auipc	a0,0xa1
ffffffffc020056e:	de650513          	addi	a0,a0,-538 # ffffffffc02a1350 <ide>
                   size_t nsecs) {
ffffffffc0200572:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200574:	00969613          	slli	a2,a3,0x9
ffffffffc0200578:	85ba                	mv	a1,a4
ffffffffc020057a:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020057c:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020057e:	423050ef          	jal	ra,ffffffffc02061a0 <memcpy>
    return 0;
}
ffffffffc0200582:	60a2                	ld	ra,8(sp)
ffffffffc0200584:	4501                	li	a0,0
ffffffffc0200586:	0141                	addi	sp,sp,16
ffffffffc0200588:	8082                	ret

ffffffffc020058a <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020058a:	67e1                	lui	a5,0x18
ffffffffc020058c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdc30>
ffffffffc0200590:	000ac717          	auipc	a4,0xac
ffffffffc0200594:	dcf73423          	sd	a5,-568(a4) # ffffffffc02ac358 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200598:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020059c:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020059e:	953e                	add	a0,a0,a5
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4881                	li	a7,0
ffffffffc02005a4:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02005a8:	02000793          	li	a5,32
ffffffffc02005ac:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02005b0:	00006517          	auipc	a0,0x6
ffffffffc02005b4:	30850513          	addi	a0,a0,776 # ffffffffc02068b8 <commands+0x180>
    ticks = 0;
ffffffffc02005b8:	000ac797          	auipc	a5,0xac
ffffffffc02005bc:	de07bc23          	sd	zero,-520(a5) # ffffffffc02ac3b0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005c0:	b11ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02005c4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005c4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005c8:	000ac797          	auipc	a5,0xac
ffffffffc02005cc:	d9078793          	addi	a5,a5,-624 # ffffffffc02ac358 <timebase>
ffffffffc02005d0:	639c                	ld	a5,0(a5)
ffffffffc02005d2:	4581                	li	a1,0
ffffffffc02005d4:	4601                	li	a2,0
ffffffffc02005d6:	953e                	add	a0,a0,a5
ffffffffc02005d8:	4881                	li	a7,0
ffffffffc02005da:	00000073          	ecall
ffffffffc02005de:	8082                	ret

ffffffffc02005e0 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005e0:	8082                	ret

ffffffffc02005e2 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005e2:	100027f3          	csrr	a5,sstatus
ffffffffc02005e6:	8b89                	andi	a5,a5,2
ffffffffc02005e8:	0ff57513          	andi	a0,a0,255
ffffffffc02005ec:	e799                	bnez	a5,ffffffffc02005fa <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005ee:	4581                	li	a1,0
ffffffffc02005f0:	4601                	li	a2,0
ffffffffc02005f2:	4885                	li	a7,1
ffffffffc02005f4:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005f8:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005fa:	1101                	addi	sp,sp,-32
ffffffffc02005fc:	ec06                	sd	ra,24(sp)
ffffffffc02005fe:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200600:	05c000ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200604:	6522                	ld	a0,8(sp)
ffffffffc0200606:	4581                	li	a1,0
ffffffffc0200608:	4601                	li	a2,0
ffffffffc020060a:	4885                	li	a7,1
ffffffffc020060c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200610:	60e2                	ld	ra,24(sp)
ffffffffc0200612:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200614:	0420006f          	j	ffffffffc0200656 <intr_enable>

ffffffffc0200618 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200618:	100027f3          	csrr	a5,sstatus
ffffffffc020061c:	8b89                	andi	a5,a5,2
ffffffffc020061e:	eb89                	bnez	a5,ffffffffc0200630 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200620:	4501                	li	a0,0
ffffffffc0200622:	4581                	li	a1,0
ffffffffc0200624:	4601                	li	a2,0
ffffffffc0200626:	4889                	li	a7,2
ffffffffc0200628:	00000073          	ecall
ffffffffc020062c:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020062e:	8082                	ret
int cons_getc(void) {
ffffffffc0200630:	1101                	addi	sp,sp,-32
ffffffffc0200632:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200634:	028000ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200638:	4501                	li	a0,0
ffffffffc020063a:	4581                	li	a1,0
ffffffffc020063c:	4601                	li	a2,0
ffffffffc020063e:	4889                	li	a7,2
ffffffffc0200640:	00000073          	ecall
ffffffffc0200644:	2501                	sext.w	a0,a0
ffffffffc0200646:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200648:	00e000ef          	jal	ra,ffffffffc0200656 <intr_enable>
}
ffffffffc020064c:	60e2                	ld	ra,24(sp)
ffffffffc020064e:	6522                	ld	a0,8(sp)
ffffffffc0200650:	6105                	addi	sp,sp,32
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200654:	8082                	ret

ffffffffc0200656 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200656:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020065a:	8082                	ret

ffffffffc020065c <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020065c:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200662:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200666:	00000797          	auipc	a5,0x0
ffffffffc020066a:	67a78793          	addi	a5,a5,1658 # ffffffffc0200ce0 <__alltraps>
ffffffffc020066e:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200672:	000407b7          	lui	a5,0x40
ffffffffc0200676:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020067a:	8082                	ret

ffffffffc020067c <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020067e:	1141                	addi	sp,sp,-16
ffffffffc0200680:	e022                	sd	s0,0(sp)
ffffffffc0200682:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200684:	00006517          	auipc	a0,0x6
ffffffffc0200688:	57c50513          	addi	a0,a0,1404 # ffffffffc0206c00 <commands+0x4c8>
void print_regs(struct pushregs* gpr) {
ffffffffc020068c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020068e:	a43ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200692:	640c                	ld	a1,8(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	58450513          	addi	a0,a0,1412 # ffffffffc0206c18 <commands+0x4e0>
ffffffffc020069c:	a35ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02006a0:	680c                	ld	a1,16(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	58e50513          	addi	a0,a0,1422 # ffffffffc0206c30 <commands+0x4f8>
ffffffffc02006aa:	a27ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006ae:	6c0c                	ld	a1,24(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	59850513          	addi	a0,a0,1432 # ffffffffc0206c48 <commands+0x510>
ffffffffc02006b8:	a19ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006bc:	700c                	ld	a1,32(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	5a250513          	addi	a0,a0,1442 # ffffffffc0206c60 <commands+0x528>
ffffffffc02006c6:	a0bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ca:	740c                	ld	a1,40(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	5ac50513          	addi	a0,a0,1452 # ffffffffc0206c78 <commands+0x540>
ffffffffc02006d4:	9fdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d8:	780c                	ld	a1,48(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	5b650513          	addi	a0,a0,1462 # ffffffffc0206c90 <commands+0x558>
ffffffffc02006e2:	9efff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006e6:	7c0c                	ld	a1,56(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	5c050513          	addi	a0,a0,1472 # ffffffffc0206ca8 <commands+0x570>
ffffffffc02006f0:	9e1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006f4:	602c                	ld	a1,64(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	5ca50513          	addi	a0,a0,1482 # ffffffffc0206cc0 <commands+0x588>
ffffffffc02006fe:	9d3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200702:	642c                	ld	a1,72(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	5d450513          	addi	a0,a0,1492 # ffffffffc0206cd8 <commands+0x5a0>
ffffffffc020070c:	9c5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200710:	682c                	ld	a1,80(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	5de50513          	addi	a0,a0,1502 # ffffffffc0206cf0 <commands+0x5b8>
ffffffffc020071a:	9b7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020071e:	6c2c                	ld	a1,88(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	5e850513          	addi	a0,a0,1512 # ffffffffc0206d08 <commands+0x5d0>
ffffffffc0200728:	9a9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020072c:	702c                	ld	a1,96(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	5f250513          	addi	a0,a0,1522 # ffffffffc0206d20 <commands+0x5e8>
ffffffffc0200736:	99bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020073a:	742c                	ld	a1,104(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	5fc50513          	addi	a0,a0,1532 # ffffffffc0206d38 <commands+0x600>
ffffffffc0200744:	98dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200748:	782c                	ld	a1,112(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	60650513          	addi	a0,a0,1542 # ffffffffc0206d50 <commands+0x618>
ffffffffc0200752:	97fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200756:	7c2c                	ld	a1,120(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	61050513          	addi	a0,a0,1552 # ffffffffc0206d68 <commands+0x630>
ffffffffc0200760:	971ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200764:	604c                	ld	a1,128(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	61a50513          	addi	a0,a0,1562 # ffffffffc0206d80 <commands+0x648>
ffffffffc020076e:	963ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200772:	644c                	ld	a1,136(s0)
ffffffffc0200774:	00006517          	auipc	a0,0x6
ffffffffc0200778:	62450513          	addi	a0,a0,1572 # ffffffffc0206d98 <commands+0x660>
ffffffffc020077c:	955ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200780:	684c                	ld	a1,144(s0)
ffffffffc0200782:	00006517          	auipc	a0,0x6
ffffffffc0200786:	62e50513          	addi	a0,a0,1582 # ffffffffc0206db0 <commands+0x678>
ffffffffc020078a:	947ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020078e:	6c4c                	ld	a1,152(s0)
ffffffffc0200790:	00006517          	auipc	a0,0x6
ffffffffc0200794:	63850513          	addi	a0,a0,1592 # ffffffffc0206dc8 <commands+0x690>
ffffffffc0200798:	939ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020079c:	704c                	ld	a1,160(s0)
ffffffffc020079e:	00006517          	auipc	a0,0x6
ffffffffc02007a2:	64250513          	addi	a0,a0,1602 # ffffffffc0206de0 <commands+0x6a8>
ffffffffc02007a6:	92bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007aa:	744c                	ld	a1,168(s0)
ffffffffc02007ac:	00006517          	auipc	a0,0x6
ffffffffc02007b0:	64c50513          	addi	a0,a0,1612 # ffffffffc0206df8 <commands+0x6c0>
ffffffffc02007b4:	91dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b8:	784c                	ld	a1,176(s0)
ffffffffc02007ba:	00006517          	auipc	a0,0x6
ffffffffc02007be:	65650513          	addi	a0,a0,1622 # ffffffffc0206e10 <commands+0x6d8>
ffffffffc02007c2:	90fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007c6:	7c4c                	ld	a1,184(s0)
ffffffffc02007c8:	00006517          	auipc	a0,0x6
ffffffffc02007cc:	66050513          	addi	a0,a0,1632 # ffffffffc0206e28 <commands+0x6f0>
ffffffffc02007d0:	901ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007d4:	606c                	ld	a1,192(s0)
ffffffffc02007d6:	00006517          	auipc	a0,0x6
ffffffffc02007da:	66a50513          	addi	a0,a0,1642 # ffffffffc0206e40 <commands+0x708>
ffffffffc02007de:	8f3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007e2:	646c                	ld	a1,200(s0)
ffffffffc02007e4:	00006517          	auipc	a0,0x6
ffffffffc02007e8:	67450513          	addi	a0,a0,1652 # ffffffffc0206e58 <commands+0x720>
ffffffffc02007ec:	8e5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007f0:	686c                	ld	a1,208(s0)
ffffffffc02007f2:	00006517          	auipc	a0,0x6
ffffffffc02007f6:	67e50513          	addi	a0,a0,1662 # ffffffffc0206e70 <commands+0x738>
ffffffffc02007fa:	8d7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200800:	00006517          	auipc	a0,0x6
ffffffffc0200804:	68850513          	addi	a0,a0,1672 # ffffffffc0206e88 <commands+0x750>
ffffffffc0200808:	8c9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020080c:	706c                	ld	a1,224(s0)
ffffffffc020080e:	00006517          	auipc	a0,0x6
ffffffffc0200812:	69250513          	addi	a0,a0,1682 # ffffffffc0206ea0 <commands+0x768>
ffffffffc0200816:	8bbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020081a:	746c                	ld	a1,232(s0)
ffffffffc020081c:	00006517          	auipc	a0,0x6
ffffffffc0200820:	69c50513          	addi	a0,a0,1692 # ffffffffc0206eb8 <commands+0x780>
ffffffffc0200824:	8adff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200828:	786c                	ld	a1,240(s0)
ffffffffc020082a:	00006517          	auipc	a0,0x6
ffffffffc020082e:	6a650513          	addi	a0,a0,1702 # ffffffffc0206ed0 <commands+0x798>
ffffffffc0200832:	89fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200838:	6402                	ld	s0,0(sp)
ffffffffc020083a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	6ac50513          	addi	a0,a0,1708 # ffffffffc0206ee8 <commands+0x7b0>
}
ffffffffc0200844:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200846:	88bff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020084a <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	1141                	addi	sp,sp,-16
ffffffffc020084c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084e:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200850:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200852:	00006517          	auipc	a0,0x6
ffffffffc0200856:	6ae50513          	addi	a0,a0,1710 # ffffffffc0206f00 <commands+0x7c8>
print_trapframe(struct trapframe *tf) {
ffffffffc020085a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020085c:	875ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200860:	8522                	mv	a0,s0
ffffffffc0200862:	e1bff0ef          	jal	ra,ffffffffc020067c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200866:	10043583          	ld	a1,256(s0)
ffffffffc020086a:	00006517          	auipc	a0,0x6
ffffffffc020086e:	6ae50513          	addi	a0,a0,1710 # ffffffffc0206f18 <commands+0x7e0>
ffffffffc0200872:	85fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200876:	10843583          	ld	a1,264(s0)
ffffffffc020087a:	00006517          	auipc	a0,0x6
ffffffffc020087e:	6b650513          	addi	a0,a0,1718 # ffffffffc0206f30 <commands+0x7f8>
ffffffffc0200882:	84fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200886:	11043583          	ld	a1,272(s0)
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	6be50513          	addi	a0,a0,1726 # ffffffffc0206f48 <commands+0x810>
ffffffffc0200892:	83fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	11843583          	ld	a1,280(s0)
}
ffffffffc020089a:	6402                	ld	s0,0(sp)
ffffffffc020089c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	00006517          	auipc	a0,0x6
ffffffffc02008a2:	6ba50513          	addi	a0,a0,1722 # ffffffffc0206f58 <commands+0x820>
}
ffffffffc02008a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a8:	829ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02008ac <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ac:	1101                	addi	sp,sp,-32
ffffffffc02008ae:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b0:	000ac497          	auipc	s1,0xac
ffffffffc02008b4:	b0848493          	addi	s1,s1,-1272 # ffffffffc02ac3b8 <check_mm_struct>
ffffffffc02008b8:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ba:	e822                	sd	s0,16(sp)
ffffffffc02008bc:	ec06                	sd	ra,24(sp)
ffffffffc02008be:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008c0:	cbbd                	beqz	a5,ffffffffc0200936 <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c2:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008c6:	11053583          	ld	a1,272(a0)
ffffffffc02008ca:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ce:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008d2:	cba1                	beqz	a5,ffffffffc0200922 <pgfault_handler+0x76>
ffffffffc02008d4:	11843703          	ld	a4,280(s0)
ffffffffc02008d8:	47bd                	li	a5,15
ffffffffc02008da:	05700693          	li	a3,87
ffffffffc02008de:	00f70463          	beq	a4,a5,ffffffffc02008e6 <pgfault_handler+0x3a>
ffffffffc02008e2:	05200693          	li	a3,82
ffffffffc02008e6:	00006517          	auipc	a0,0x6
ffffffffc02008ea:	29a50513          	addi	a0,a0,666 # ffffffffc0206b80 <commands+0x448>
ffffffffc02008ee:	fe2ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008f2:	6088                	ld	a0,0(s1)
ffffffffc02008f4:	c129                	beqz	a0,ffffffffc0200936 <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008f6:	000ac797          	auipc	a5,0xac
ffffffffc02008fa:	a9a78793          	addi	a5,a5,-1382 # ffffffffc02ac390 <current>
ffffffffc02008fe:	6398                	ld	a4,0(a5)
ffffffffc0200900:	000ac797          	auipc	a5,0xac
ffffffffc0200904:	a9878793          	addi	a5,a5,-1384 # ffffffffc02ac398 <idleproc>
ffffffffc0200908:	639c                	ld	a5,0(a5)
ffffffffc020090a:	04f71763          	bne	a4,a5,ffffffffc0200958 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020090e:	11043603          	ld	a2,272(s0)
ffffffffc0200912:	11842583          	lw	a1,280(s0)
}
ffffffffc0200916:	6442                	ld	s0,16(sp)
ffffffffc0200918:	60e2                	ld	ra,24(sp)
ffffffffc020091a:	64a2                	ld	s1,8(sp)
ffffffffc020091c:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020091e:	63f0006f          	j	ffffffffc020175c <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200922:	11843703          	ld	a4,280(s0)
ffffffffc0200926:	47bd                	li	a5,15
ffffffffc0200928:	05500613          	li	a2,85
ffffffffc020092c:	05700693          	li	a3,87
ffffffffc0200930:	faf719e3          	bne	a4,a5,ffffffffc02008e2 <pgfault_handler+0x36>
ffffffffc0200934:	bf4d                	j	ffffffffc02008e6 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200936:	000ac797          	auipc	a5,0xac
ffffffffc020093a:	a5a78793          	addi	a5,a5,-1446 # ffffffffc02ac390 <current>
ffffffffc020093e:	639c                	ld	a5,0(a5)
ffffffffc0200940:	cf85                	beqz	a5,ffffffffc0200978 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200942:	11043603          	ld	a2,272(s0)
ffffffffc0200946:	11842583          	lw	a1,280(s0)
}
ffffffffc020094a:	6442                	ld	s0,16(sp)
ffffffffc020094c:	60e2                	ld	ra,24(sp)
ffffffffc020094e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200950:	7788                	ld	a0,40(a5)
}
ffffffffc0200952:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200954:	6090006f          	j	ffffffffc020175c <do_pgfault>
        assert(current == idleproc);
ffffffffc0200958:	00006697          	auipc	a3,0x6
ffffffffc020095c:	24868693          	addi	a3,a3,584 # ffffffffc0206ba0 <commands+0x468>
ffffffffc0200960:	00006617          	auipc	a2,0x6
ffffffffc0200964:	25860613          	addi	a2,a2,600 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0200968:	06b00593          	li	a1,107
ffffffffc020096c:	00006517          	auipc	a0,0x6
ffffffffc0200970:	26450513          	addi	a0,a0,612 # ffffffffc0206bd0 <commands+0x498>
ffffffffc0200974:	8a3ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            print_trapframe(tf);
ffffffffc0200978:	8522                	mv	a0,s0
ffffffffc020097a:	ed1ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020097e:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200982:	11043583          	ld	a1,272(s0)
ffffffffc0200986:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020098a:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020098e:	e399                	bnez	a5,ffffffffc0200994 <pgfault_handler+0xe8>
ffffffffc0200990:	05500613          	li	a2,85
ffffffffc0200994:	11843703          	ld	a4,280(s0)
ffffffffc0200998:	47bd                	li	a5,15
ffffffffc020099a:	02f70663          	beq	a4,a5,ffffffffc02009c6 <pgfault_handler+0x11a>
ffffffffc020099e:	05200693          	li	a3,82
ffffffffc02009a2:	00006517          	auipc	a0,0x6
ffffffffc02009a6:	1de50513          	addi	a0,a0,478 # ffffffffc0206b80 <commands+0x448>
ffffffffc02009aa:	f26ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009ae:	00006617          	auipc	a2,0x6
ffffffffc02009b2:	23a60613          	addi	a2,a2,570 # ffffffffc0206be8 <commands+0x4b0>
ffffffffc02009b6:	07200593          	li	a1,114
ffffffffc02009ba:	00006517          	auipc	a0,0x6
ffffffffc02009be:	21650513          	addi	a0,a0,534 # ffffffffc0206bd0 <commands+0x498>
ffffffffc02009c2:	855ff0ef          	jal	ra,ffffffffc0200216 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009c6:	05700693          	li	a3,87
ffffffffc02009ca:	bfe1                	j	ffffffffc02009a2 <pgfault_handler+0xf6>

ffffffffc02009cc <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009cc:	11853783          	ld	a5,280(a0)
ffffffffc02009d0:	577d                	li	a4,-1
ffffffffc02009d2:	8305                	srli	a4,a4,0x1
ffffffffc02009d4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009d6:	472d                	li	a4,11
ffffffffc02009d8:	08f76763          	bltu	a4,a5,ffffffffc0200a66 <interrupt_handler+0x9a>
ffffffffc02009dc:	00006717          	auipc	a4,0x6
ffffffffc02009e0:	ef870713          	addi	a4,a4,-264 # ffffffffc02068d4 <commands+0x19c>
ffffffffc02009e4:	078a                	slli	a5,a5,0x2
ffffffffc02009e6:	97ba                	add	a5,a5,a4
ffffffffc02009e8:	439c                	lw	a5,0(a5)
ffffffffc02009ea:	97ba                	add	a5,a5,a4
ffffffffc02009ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	15250513          	addi	a0,a0,338 # ffffffffc0206b40 <commands+0x408>
ffffffffc02009f6:	edaff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	12650513          	addi	a0,a0,294 # ffffffffc0206b20 <commands+0x3e8>
ffffffffc0200a02:	eceff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	0da50513          	addi	a0,a0,218 # ffffffffc0206ae0 <commands+0x3a8>
ffffffffc0200a0e:	ec2ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	0ee50513          	addi	a0,a0,238 # ffffffffc0206b00 <commands+0x3c8>
ffffffffc0200a1a:	eb6ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a1e:	00006517          	auipc	a0,0x6
ffffffffc0200a22:	14250513          	addi	a0,a0,322 # ffffffffc0206b60 <commands+0x428>
ffffffffc0200a26:	eaaff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a2a:	1141                	addi	sp,sp,-16
ffffffffc0200a2c:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a2e:	b97ff0ef          	jal	ra,ffffffffc02005c4 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a32:	000ac797          	auipc	a5,0xac
ffffffffc0200a36:	97e78793          	addi	a5,a5,-1666 # ffffffffc02ac3b0 <ticks>
ffffffffc0200a3a:	639c                	ld	a5,0(a5)
ffffffffc0200a3c:	06400713          	li	a4,100
ffffffffc0200a40:	0785                	addi	a5,a5,1
ffffffffc0200a42:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a46:	000ac697          	auipc	a3,0xac
ffffffffc0200a4a:	96f6b523          	sd	a5,-1686(a3) # ffffffffc02ac3b0 <ticks>
ffffffffc0200a4e:	eb09                	bnez	a4,ffffffffc0200a60 <interrupt_handler+0x94>
ffffffffc0200a50:	000ac797          	auipc	a5,0xac
ffffffffc0200a54:	94078793          	addi	a5,a5,-1728 # ffffffffc02ac390 <current>
ffffffffc0200a58:	639c                	ld	a5,0(a5)
ffffffffc0200a5a:	c399                	beqz	a5,ffffffffc0200a60 <interrupt_handler+0x94>
                current->need_resched = 1;
ffffffffc0200a5c:	4705                	li	a4,1
ffffffffc0200a5e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a60:	60a2                	ld	ra,8(sp)
ffffffffc0200a62:	0141                	addi	sp,sp,16
ffffffffc0200a64:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a66:	de5ff06f          	j	ffffffffc020084a <print_trapframe>

ffffffffc0200a6a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a6a:	11853783          	ld	a5,280(a0)
ffffffffc0200a6e:	473d                	li	a4,15
ffffffffc0200a70:	1af76e63          	bltu	a4,a5,ffffffffc0200c2c <exception_handler+0x1c2>
ffffffffc0200a74:	00006717          	auipc	a4,0x6
ffffffffc0200a78:	e9070713          	addi	a4,a4,-368 # ffffffffc0206904 <commands+0x1cc>
ffffffffc0200a7c:	078a                	slli	a5,a5,0x2
ffffffffc0200a7e:	97ba                	add	a5,a5,a4
ffffffffc0200a80:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a82:	1101                	addi	sp,sp,-32
ffffffffc0200a84:	e822                	sd	s0,16(sp)
ffffffffc0200a86:	ec06                	sd	ra,24(sp)
ffffffffc0200a88:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a8a:	97ba                	add	a5,a5,a4
ffffffffc0200a8c:	842a                	mv	s0,a0
ffffffffc0200a8e:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a90:	00006517          	auipc	a0,0x6
ffffffffc0200a94:	fa850513          	addi	a0,a0,-88 # ffffffffc0206a38 <commands+0x300>
ffffffffc0200a98:	e38ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            tf->epc += 4;
ffffffffc0200a9c:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200aa0:	60e2                	ld	ra,24(sp)
ffffffffc0200aa2:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200aa4:	0791                	addi	a5,a5,4
ffffffffc0200aa6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200aaa:	6442                	ld	s0,16(sp)
ffffffffc0200aac:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aae:	5c20506f          	j	ffffffffc0206070 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	fa650513          	addi	a0,a0,-90 # ffffffffc0206a58 <commands+0x320>
}
ffffffffc0200aba:	6442                	ld	s0,16(sp)
ffffffffc0200abc:	60e2                	ld	ra,24(sp)
ffffffffc0200abe:	64a2                	ld	s1,8(sp)
ffffffffc0200ac0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ac2:	e0eff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ac6:	00006517          	auipc	a0,0x6
ffffffffc0200aca:	fb250513          	addi	a0,a0,-78 # ffffffffc0206a78 <commands+0x340>
ffffffffc0200ace:	b7f5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ad0:	00006517          	auipc	a0,0x6
ffffffffc0200ad4:	fc850513          	addi	a0,a0,-56 # ffffffffc0206a98 <commands+0x360>
ffffffffc0200ad8:	b7cd                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ada:	00006517          	auipc	a0,0x6
ffffffffc0200ade:	fd650513          	addi	a0,a0,-42 # ffffffffc0206ab0 <commands+0x378>
ffffffffc0200ae2:	deeff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae6:	8522                	mv	a0,s0
ffffffffc0200ae8:	dc5ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200aec:	84aa                	mv	s1,a0
ffffffffc0200aee:	14051163          	bnez	a0,ffffffffc0200c30 <exception_handler+0x1c6>
}
ffffffffc0200af2:	60e2                	ld	ra,24(sp)
ffffffffc0200af4:	6442                	ld	s0,16(sp)
ffffffffc0200af6:	64a2                	ld	s1,8(sp)
ffffffffc0200af8:	6105                	addi	sp,sp,32
ffffffffc0200afa:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200afc:	00006517          	auipc	a0,0x6
ffffffffc0200b00:	fcc50513          	addi	a0,a0,-52 # ffffffffc0206ac8 <commands+0x390>
ffffffffc0200b04:	dccff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b08:	8522                	mv	a0,s0
ffffffffc0200b0a:	da3ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200b0e:	84aa                	mv	s1,a0
ffffffffc0200b10:	d16d                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b12:	8522                	mv	a0,s0
ffffffffc0200b14:	d37ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b18:	86a6                	mv	a3,s1
ffffffffc0200b1a:	00006617          	auipc	a2,0x6
ffffffffc0200b1e:	ece60613          	addi	a2,a2,-306 # ffffffffc02069e8 <commands+0x2b0>
ffffffffc0200b22:	0f800593          	li	a1,248
ffffffffc0200b26:	00006517          	auipc	a0,0x6
ffffffffc0200b2a:	0aa50513          	addi	a0,a0,170 # ffffffffc0206bd0 <commands+0x498>
ffffffffc0200b2e:	ee8ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b32:	00006517          	auipc	a0,0x6
ffffffffc0200b36:	e1650513          	addi	a0,a0,-490 # ffffffffc0206948 <commands+0x210>
ffffffffc0200b3a:	b741                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b3c:	00006517          	auipc	a0,0x6
ffffffffc0200b40:	e2c50513          	addi	a0,a0,-468 # ffffffffc0206968 <commands+0x230>
ffffffffc0200b44:	bf9d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	e4250513          	addi	a0,a0,-446 # ffffffffc0206988 <commands+0x250>
ffffffffc0200b4e:	b7b5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b50:	00006517          	auipc	a0,0x6
ffffffffc0200b54:	e5050513          	addi	a0,a0,-432 # ffffffffc02069a0 <commands+0x268>
ffffffffc0200b58:	d78ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b5c:	6458                	ld	a4,136(s0)
ffffffffc0200b5e:	47a9                	li	a5,10
ffffffffc0200b60:	f8f719e3          	bne	a4,a5,ffffffffc0200af2 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b64:	10843783          	ld	a5,264(s0)
ffffffffc0200b68:	0791                	addi	a5,a5,4
ffffffffc0200b6a:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b6e:	502050ef          	jal	ra,ffffffffc0206070 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b72:	000ac797          	auipc	a5,0xac
ffffffffc0200b76:	81e78793          	addi	a5,a5,-2018 # ffffffffc02ac390 <current>
ffffffffc0200b7a:	639c                	ld	a5,0(a5)
ffffffffc0200b7c:	8522                	mv	a0,s0
}
ffffffffc0200b7e:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b80:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b82:	60e2                	ld	ra,24(sp)
ffffffffc0200b84:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b86:	6589                	lui	a1,0x2
ffffffffc0200b88:	95be                	add	a1,a1,a5
}
ffffffffc0200b8a:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b8c:	2220006f          	j	ffffffffc0200dae <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b90:	00006517          	auipc	a0,0x6
ffffffffc0200b94:	e2050513          	addi	a0,a0,-480 # ffffffffc02069b0 <commands+0x278>
ffffffffc0200b98:	b70d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	e3650513          	addi	a0,a0,-458 # ffffffffc02069d0 <commands+0x298>
ffffffffc0200ba2:	d2eff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ba6:	8522                	mv	a0,s0
ffffffffc0200ba8:	d05ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200bac:	84aa                	mv	s1,a0
ffffffffc0200bae:	d131                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bb0:	8522                	mv	a0,s0
ffffffffc0200bb2:	c99ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bb6:	86a6                	mv	a3,s1
ffffffffc0200bb8:	00006617          	auipc	a2,0x6
ffffffffc0200bbc:	e3060613          	addi	a2,a2,-464 # ffffffffc02069e8 <commands+0x2b0>
ffffffffc0200bc0:	0cd00593          	li	a1,205
ffffffffc0200bc4:	00006517          	auipc	a0,0x6
ffffffffc0200bc8:	00c50513          	addi	a0,a0,12 # ffffffffc0206bd0 <commands+0x498>
ffffffffc0200bcc:	e4aff0ef          	jal	ra,ffffffffc0200216 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	e5050513          	addi	a0,a0,-432 # ffffffffc0206a20 <commands+0x2e8>
ffffffffc0200bd8:	cf8ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bdc:	8522                	mv	a0,s0
ffffffffc0200bde:	ccfff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200be2:	84aa                	mv	s1,a0
ffffffffc0200be4:	f00507e3          	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200be8:	8522                	mv	a0,s0
ffffffffc0200bea:	c61ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bee:	86a6                	mv	a3,s1
ffffffffc0200bf0:	00006617          	auipc	a2,0x6
ffffffffc0200bf4:	df860613          	addi	a2,a2,-520 # ffffffffc02069e8 <commands+0x2b0>
ffffffffc0200bf8:	0d700593          	li	a1,215
ffffffffc0200bfc:	00006517          	auipc	a0,0x6
ffffffffc0200c00:	fd450513          	addi	a0,a0,-44 # ffffffffc0206bd0 <commands+0x498>
ffffffffc0200c04:	e12ff0ef          	jal	ra,ffffffffc0200216 <__panic>
}
ffffffffc0200c08:	6442                	ld	s0,16(sp)
ffffffffc0200c0a:	60e2                	ld	ra,24(sp)
ffffffffc0200c0c:	64a2                	ld	s1,8(sp)
ffffffffc0200c0e:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c10:	c3bff06f          	j	ffffffffc020084a <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c14:	00006617          	auipc	a2,0x6
ffffffffc0200c18:	df460613          	addi	a2,a2,-524 # ffffffffc0206a08 <commands+0x2d0>
ffffffffc0200c1c:	0d100593          	li	a1,209
ffffffffc0200c20:	00006517          	auipc	a0,0x6
ffffffffc0200c24:	fb050513          	addi	a0,a0,-80 # ffffffffc0206bd0 <commands+0x498>
ffffffffc0200c28:	deeff0ef          	jal	ra,ffffffffc0200216 <__panic>
            print_trapframe(tf);
ffffffffc0200c2c:	c1fff06f          	j	ffffffffc020084a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c30:	8522                	mv	a0,s0
ffffffffc0200c32:	c19ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c36:	86a6                	mv	a3,s1
ffffffffc0200c38:	00006617          	auipc	a2,0x6
ffffffffc0200c3c:	db060613          	addi	a2,a2,-592 # ffffffffc02069e8 <commands+0x2b0>
ffffffffc0200c40:	0f100593          	li	a1,241
ffffffffc0200c44:	00006517          	auipc	a0,0x6
ffffffffc0200c48:	f8c50513          	addi	a0,a0,-116 # ffffffffc0206bd0 <commands+0x498>
ffffffffc0200c4c:	dcaff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200c50 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c50:	1101                	addi	sp,sp,-32
ffffffffc0200c52:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c54:	000ab417          	auipc	s0,0xab
ffffffffc0200c58:	73c40413          	addi	s0,s0,1852 # ffffffffc02ac390 <current>
ffffffffc0200c5c:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c5e:	ec06                	sd	ra,24(sp)
ffffffffc0200c60:	e426                	sd	s1,8(sp)
ffffffffc0200c62:	e04a                	sd	s2,0(sp)
ffffffffc0200c64:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c68:	cf1d                	beqz	a4,ffffffffc0200ca6 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c6a:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c6e:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c72:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c74:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c78:	0206c463          	bltz	a3,ffffffffc0200ca0 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c7c:	defff0ef          	jal	ra,ffffffffc0200a6a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c80:	601c                	ld	a5,0(s0)
ffffffffc0200c82:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c86:	e499                	bnez	s1,ffffffffc0200c94 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c88:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c8c:	8b05                	andi	a4,a4,1
ffffffffc0200c8e:	e339                	bnez	a4,ffffffffc0200cd4 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c90:	6f9c                	ld	a5,24(a5)
ffffffffc0200c92:	eb95                	bnez	a5,ffffffffc0200cc6 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
ffffffffc0200c96:	6442                	ld	s0,16(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
ffffffffc0200c9e:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200ca0:	d2dff0ef          	jal	ra,ffffffffc02009cc <interrupt_handler>
ffffffffc0200ca4:	bff1                	j	ffffffffc0200c80 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ca6:	0006c963          	bltz	a3,ffffffffc0200cb8 <trap+0x68>
}
ffffffffc0200caa:	6442                	ld	s0,16(sp)
ffffffffc0200cac:	60e2                	ld	ra,24(sp)
ffffffffc0200cae:	64a2                	ld	s1,8(sp)
ffffffffc0200cb0:	6902                	ld	s2,0(sp)
ffffffffc0200cb2:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cb4:	db7ff06f          	j	ffffffffc0200a6a <exception_handler>
}
ffffffffc0200cb8:	6442                	ld	s0,16(sp)
ffffffffc0200cba:	60e2                	ld	ra,24(sp)
ffffffffc0200cbc:	64a2                	ld	s1,8(sp)
ffffffffc0200cbe:	6902                	ld	s2,0(sp)
ffffffffc0200cc0:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cc2:	d0bff06f          	j	ffffffffc02009cc <interrupt_handler>
}
ffffffffc0200cc6:	6442                	ld	s0,16(sp)
ffffffffc0200cc8:	60e2                	ld	ra,24(sp)
ffffffffc0200cca:	64a2                	ld	s1,8(sp)
ffffffffc0200ccc:	6902                	ld	s2,0(sp)
ffffffffc0200cce:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cd0:	2aa0506f          	j	ffffffffc0205f7a <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cd4:	555d                	li	a0,-9
ffffffffc0200cd6:	70c040ef          	jal	ra,ffffffffc02053e2 <do_exit>
ffffffffc0200cda:	601c                	ld	a5,0(s0)
ffffffffc0200cdc:	bf55                	j	ffffffffc0200c90 <trap+0x40>
	...

ffffffffc0200ce0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ce0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ce4:	00011463          	bnez	sp,ffffffffc0200cec <__alltraps+0xc>
ffffffffc0200ce8:	14002173          	csrr	sp,sscratch
ffffffffc0200cec:	712d                	addi	sp,sp,-288
ffffffffc0200cee:	e002                	sd	zero,0(sp)
ffffffffc0200cf0:	e406                	sd	ra,8(sp)
ffffffffc0200cf2:	ec0e                	sd	gp,24(sp)
ffffffffc0200cf4:	f012                	sd	tp,32(sp)
ffffffffc0200cf6:	f416                	sd	t0,40(sp)
ffffffffc0200cf8:	f81a                	sd	t1,48(sp)
ffffffffc0200cfa:	fc1e                	sd	t2,56(sp)
ffffffffc0200cfc:	e0a2                	sd	s0,64(sp)
ffffffffc0200cfe:	e4a6                	sd	s1,72(sp)
ffffffffc0200d00:	e8aa                	sd	a0,80(sp)
ffffffffc0200d02:	ecae                	sd	a1,88(sp)
ffffffffc0200d04:	f0b2                	sd	a2,96(sp)
ffffffffc0200d06:	f4b6                	sd	a3,104(sp)
ffffffffc0200d08:	f8ba                	sd	a4,112(sp)
ffffffffc0200d0a:	fcbe                	sd	a5,120(sp)
ffffffffc0200d0c:	e142                	sd	a6,128(sp)
ffffffffc0200d0e:	e546                	sd	a7,136(sp)
ffffffffc0200d10:	e94a                	sd	s2,144(sp)
ffffffffc0200d12:	ed4e                	sd	s3,152(sp)
ffffffffc0200d14:	f152                	sd	s4,160(sp)
ffffffffc0200d16:	f556                	sd	s5,168(sp)
ffffffffc0200d18:	f95a                	sd	s6,176(sp)
ffffffffc0200d1a:	fd5e                	sd	s7,184(sp)
ffffffffc0200d1c:	e1e2                	sd	s8,192(sp)
ffffffffc0200d1e:	e5e6                	sd	s9,200(sp)
ffffffffc0200d20:	e9ea                	sd	s10,208(sp)
ffffffffc0200d22:	edee                	sd	s11,216(sp)
ffffffffc0200d24:	f1f2                	sd	t3,224(sp)
ffffffffc0200d26:	f5f6                	sd	t4,232(sp)
ffffffffc0200d28:	f9fa                	sd	t5,240(sp)
ffffffffc0200d2a:	fdfe                	sd	t6,248(sp)
ffffffffc0200d2c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d30:	100024f3          	csrr	s1,sstatus
ffffffffc0200d34:	14102973          	csrr	s2,sepc
ffffffffc0200d38:	143029f3          	csrr	s3,stval
ffffffffc0200d3c:	14202a73          	csrr	s4,scause
ffffffffc0200d40:	e822                	sd	s0,16(sp)
ffffffffc0200d42:	e226                	sd	s1,256(sp)
ffffffffc0200d44:	e64a                	sd	s2,264(sp)
ffffffffc0200d46:	ea4e                	sd	s3,272(sp)
ffffffffc0200d48:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d4a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d4c:	f05ff0ef          	jal	ra,ffffffffc0200c50 <trap>

ffffffffc0200d50 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d50:	6492                	ld	s1,256(sp)
ffffffffc0200d52:	6932                	ld	s2,264(sp)
ffffffffc0200d54:	1004f413          	andi	s0,s1,256
ffffffffc0200d58:	e401                	bnez	s0,ffffffffc0200d60 <__trapret+0x10>
ffffffffc0200d5a:	1200                	addi	s0,sp,288
ffffffffc0200d5c:	14041073          	csrw	sscratch,s0
ffffffffc0200d60:	10049073          	csrw	sstatus,s1
ffffffffc0200d64:	14191073          	csrw	sepc,s2
ffffffffc0200d68:	60a2                	ld	ra,8(sp)
ffffffffc0200d6a:	61e2                	ld	gp,24(sp)
ffffffffc0200d6c:	7202                	ld	tp,32(sp)
ffffffffc0200d6e:	72a2                	ld	t0,40(sp)
ffffffffc0200d70:	7342                	ld	t1,48(sp)
ffffffffc0200d72:	73e2                	ld	t2,56(sp)
ffffffffc0200d74:	6406                	ld	s0,64(sp)
ffffffffc0200d76:	64a6                	ld	s1,72(sp)
ffffffffc0200d78:	6546                	ld	a0,80(sp)
ffffffffc0200d7a:	65e6                	ld	a1,88(sp)
ffffffffc0200d7c:	7606                	ld	a2,96(sp)
ffffffffc0200d7e:	76a6                	ld	a3,104(sp)
ffffffffc0200d80:	7746                	ld	a4,112(sp)
ffffffffc0200d82:	77e6                	ld	a5,120(sp)
ffffffffc0200d84:	680a                	ld	a6,128(sp)
ffffffffc0200d86:	68aa                	ld	a7,136(sp)
ffffffffc0200d88:	694a                	ld	s2,144(sp)
ffffffffc0200d8a:	69ea                	ld	s3,152(sp)
ffffffffc0200d8c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d8e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d90:	7b4a                	ld	s6,176(sp)
ffffffffc0200d92:	7bea                	ld	s7,184(sp)
ffffffffc0200d94:	6c0e                	ld	s8,192(sp)
ffffffffc0200d96:	6cae                	ld	s9,200(sp)
ffffffffc0200d98:	6d4e                	ld	s10,208(sp)
ffffffffc0200d9a:	6dee                	ld	s11,216(sp)
ffffffffc0200d9c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d9e:	7eae                	ld	t4,232(sp)
ffffffffc0200da0:	7f4e                	ld	t5,240(sp)
ffffffffc0200da2:	7fee                	ld	t6,248(sp)
ffffffffc0200da4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200da6:	10200073          	sret

ffffffffc0200daa <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200daa:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200dac:	b755                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200dae <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200dae:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7688>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200db2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200db6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200dba:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dbe:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200dc2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dc6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dca:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200dce:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dd2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dd4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dd6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dd8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dda:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200ddc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dde:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200de0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200de2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200de4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200de6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200de8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dea:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dec:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dee:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200df0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200df2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200df4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200df6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200df8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dfa:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dfc:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dfe:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200e00:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200e02:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200e04:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200e06:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200e08:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200e0a:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200e0c:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200e0e:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e10:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e12:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e14:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e16:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e18:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e1a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e1c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e1e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e20:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e22:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e24:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e26:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e28:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e2a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e2c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e2e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e30:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e32:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e34:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e36:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e38:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e3a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e3c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e3e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e40:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e42:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e44:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e46:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e48:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e4a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e4c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e4e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e50:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e52:	812e                	mv	sp,a1
ffffffffc0200e54:	bdf5                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200e56 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e56:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200e58:	00006697          	auipc	a3,0x6
ffffffffc0200e5c:	11868693          	addi	a3,a3,280 # ffffffffc0206f70 <commands+0x838>
ffffffffc0200e60:	00006617          	auipc	a2,0x6
ffffffffc0200e64:	d5860613          	addi	a2,a2,-680 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0200e68:	06d00593          	li	a1,109
ffffffffc0200e6c:	00006517          	auipc	a0,0x6
ffffffffc0200e70:	12450513          	addi	a0,a0,292 # ffffffffc0206f90 <commands+0x858>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e74:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200e76:	ba0ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200e7a <mm_create>:
mm_create(void) {
ffffffffc0200e7a:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e7c:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0200e80:	e022                	sd	s0,0(sp)
ffffffffc0200e82:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e84:	0ec010ef          	jal	ra,ffffffffc0201f70 <kmalloc>
ffffffffc0200e88:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200e8a:	c515                	beqz	a0,ffffffffc0200eb6 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e8c:	000ab797          	auipc	a5,0xab
ffffffffc0200e90:	4ec78793          	addi	a5,a5,1260 # ffffffffc02ac378 <swap_init_ok>
ffffffffc0200e94:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e96:	e408                	sd	a0,8(s0)
ffffffffc0200e98:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200e9a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200e9e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200ea2:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ea6:	2781                	sext.w	a5,a5
ffffffffc0200ea8:	ef81                	bnez	a5,ffffffffc0200ec0 <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc0200eaa:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0200eae:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0200eb2:	02043c23          	sd	zero,56(s0)
}
ffffffffc0200eb6:	8522                	mv	a0,s0
ffffffffc0200eb8:	60a2                	ld	ra,8(sp)
ffffffffc0200eba:	6402                	ld	s0,0(sp)
ffffffffc0200ebc:	0141                	addi	sp,sp,16
ffffffffc0200ebe:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ec0:	211010ef          	jal	ra,ffffffffc02028d0 <swap_init_mm>
ffffffffc0200ec4:	b7ed                	j	ffffffffc0200eae <mm_create+0x34>

ffffffffc0200ec6 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200ec6:	1101                	addi	sp,sp,-32
ffffffffc0200ec8:	e04a                	sd	s2,0(sp)
ffffffffc0200eca:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200ecc:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200ed0:	e822                	sd	s0,16(sp)
ffffffffc0200ed2:	e426                	sd	s1,8(sp)
ffffffffc0200ed4:	ec06                	sd	ra,24(sp)
ffffffffc0200ed6:	84ae                	mv	s1,a1
ffffffffc0200ed8:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200eda:	096010ef          	jal	ra,ffffffffc0201f70 <kmalloc>
    if (vma != NULL) {
ffffffffc0200ede:	c509                	beqz	a0,ffffffffc0200ee8 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200ee0:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200ee4:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200ee6:	cd00                	sw	s0,24(a0)
}
ffffffffc0200ee8:	60e2                	ld	ra,24(sp)
ffffffffc0200eea:	6442                	ld	s0,16(sp)
ffffffffc0200eec:	64a2                	ld	s1,8(sp)
ffffffffc0200eee:	6902                	ld	s2,0(sp)
ffffffffc0200ef0:	6105                	addi	sp,sp,32
ffffffffc0200ef2:	8082                	ret

ffffffffc0200ef4 <find_vma>:
    if (mm != NULL) {
ffffffffc0200ef4:	c51d                	beqz	a0,ffffffffc0200f22 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0200ef6:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200ef8:	c781                	beqz	a5,ffffffffc0200f00 <find_vma+0xc>
ffffffffc0200efa:	6798                	ld	a4,8(a5)
ffffffffc0200efc:	02e5f663          	bleu	a4,a1,ffffffffc0200f28 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0200f00:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200f02:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200f04:	00f50f63          	beq	a0,a5,ffffffffc0200f22 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200f08:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200f0c:	fee5ebe3          	bltu	a1,a4,ffffffffc0200f02 <find_vma+0xe>
ffffffffc0200f10:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200f14:	fee5f7e3          	bleu	a4,a1,ffffffffc0200f02 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0200f18:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0200f1a:	c781                	beqz	a5,ffffffffc0200f22 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0200f1c:	e91c                	sd	a5,16(a0)
}
ffffffffc0200f1e:	853e                	mv	a0,a5
ffffffffc0200f20:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0200f22:	4781                	li	a5,0
}
ffffffffc0200f24:	853e                	mv	a0,a5
ffffffffc0200f26:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200f28:	6b98                	ld	a4,16(a5)
ffffffffc0200f2a:	fce5fbe3          	bleu	a4,a1,ffffffffc0200f00 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0200f2e:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0200f30:	b7fd                	j	ffffffffc0200f1e <find_vma+0x2a>

ffffffffc0200f32 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f32:	6590                	ld	a2,8(a1)
ffffffffc0200f34:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200f38:	1141                	addi	sp,sp,-16
ffffffffc0200f3a:	e406                	sd	ra,8(sp)
ffffffffc0200f3c:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f3e:	01066863          	bltu	a2,a6,ffffffffc0200f4e <insert_vma_struct+0x1c>
ffffffffc0200f42:	a8b9                	j	ffffffffc0200fa0 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200f44:	fe87b683          	ld	a3,-24(a5)
ffffffffc0200f48:	04d66763          	bltu	a2,a3,ffffffffc0200f96 <insert_vma_struct+0x64>
ffffffffc0200f4c:	873e                	mv	a4,a5
ffffffffc0200f4e:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0200f50:	fef51ae3          	bne	a0,a5,ffffffffc0200f44 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200f54:	02a70463          	beq	a4,a0,ffffffffc0200f7c <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200f58:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200f5c:	fe873883          	ld	a7,-24(a4)
ffffffffc0200f60:	08d8f063          	bleu	a3,a7,ffffffffc0200fe0 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f64:	04d66e63          	bltu	a2,a3,ffffffffc0200fc0 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0200f68:	00f50a63          	beq	a0,a5,ffffffffc0200f7c <insert_vma_struct+0x4a>
ffffffffc0200f6c:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f70:	0506e863          	bltu	a3,a6,ffffffffc0200fc0 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0200f74:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200f78:	02c6f263          	bleu	a2,a3,ffffffffc0200f9c <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200f7c:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0200f7e:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200f80:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200f84:	e390                	sd	a2,0(a5)
ffffffffc0200f86:	e710                	sd	a2,8(a4)
}
ffffffffc0200f88:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200f8a:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200f8c:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0200f8e:	2685                	addiw	a3,a3,1
ffffffffc0200f90:	d114                	sw	a3,32(a0)
}
ffffffffc0200f92:	0141                	addi	sp,sp,16
ffffffffc0200f94:	8082                	ret
    if (le_prev != list) {
ffffffffc0200f96:	fca711e3          	bne	a4,a0,ffffffffc0200f58 <insert_vma_struct+0x26>
ffffffffc0200f9a:	bfd9                	j	ffffffffc0200f70 <insert_vma_struct+0x3e>
ffffffffc0200f9c:	ebbff0ef          	jal	ra,ffffffffc0200e56 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200fa0:	00006697          	auipc	a3,0x6
ffffffffc0200fa4:	0e068693          	addi	a3,a3,224 # ffffffffc0207080 <commands+0x948>
ffffffffc0200fa8:	00006617          	auipc	a2,0x6
ffffffffc0200fac:	c1060613          	addi	a2,a2,-1008 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0200fb0:	07400593          	li	a1,116
ffffffffc0200fb4:	00006517          	auipc	a0,0x6
ffffffffc0200fb8:	fdc50513          	addi	a0,a0,-36 # ffffffffc0206f90 <commands+0x858>
ffffffffc0200fbc:	a5aff0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200fc0:	00006697          	auipc	a3,0x6
ffffffffc0200fc4:	10068693          	addi	a3,a3,256 # ffffffffc02070c0 <commands+0x988>
ffffffffc0200fc8:	00006617          	auipc	a2,0x6
ffffffffc0200fcc:	bf060613          	addi	a2,a2,-1040 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0200fd0:	06c00593          	li	a1,108
ffffffffc0200fd4:	00006517          	auipc	a0,0x6
ffffffffc0200fd8:	fbc50513          	addi	a0,a0,-68 # ffffffffc0206f90 <commands+0x858>
ffffffffc0200fdc:	a3aff0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200fe0:	00006697          	auipc	a3,0x6
ffffffffc0200fe4:	0c068693          	addi	a3,a3,192 # ffffffffc02070a0 <commands+0x968>
ffffffffc0200fe8:	00006617          	auipc	a2,0x6
ffffffffc0200fec:	bd060613          	addi	a2,a2,-1072 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0200ff0:	06b00593          	li	a1,107
ffffffffc0200ff4:	00006517          	auipc	a0,0x6
ffffffffc0200ff8:	f9c50513          	addi	a0,a0,-100 # ffffffffc0206f90 <commands+0x858>
ffffffffc0200ffc:	a1aff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201000 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0201000:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0201002:	1141                	addi	sp,sp,-16
ffffffffc0201004:	e406                	sd	ra,8(sp)
ffffffffc0201006:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0201008:	e78d                	bnez	a5,ffffffffc0201032 <mm_destroy+0x32>
ffffffffc020100a:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020100c:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020100e:	00a40c63          	beq	s0,a0,ffffffffc0201026 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201012:	6118                	ld	a4,0(a0)
ffffffffc0201014:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0201016:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201018:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020101a:	e398                	sd	a4,0(a5)
ffffffffc020101c:	010010ef          	jal	ra,ffffffffc020202c <kfree>
    return listelm->next;
ffffffffc0201020:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201022:	fea418e3          	bne	s0,a0,ffffffffc0201012 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0201026:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201028:	6402                	ld	s0,0(sp)
ffffffffc020102a:	60a2                	ld	ra,8(sp)
ffffffffc020102c:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020102e:	7ff0006f          	j	ffffffffc020202c <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0201032:	00006697          	auipc	a3,0x6
ffffffffc0201036:	0ae68693          	addi	a3,a3,174 # ffffffffc02070e0 <commands+0x9a8>
ffffffffc020103a:	00006617          	auipc	a2,0x6
ffffffffc020103e:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201042:	09400593          	li	a1,148
ffffffffc0201046:	00006517          	auipc	a0,0x6
ffffffffc020104a:	f4a50513          	addi	a0,a0,-182 # ffffffffc0206f90 <commands+0x858>
ffffffffc020104e:	9c8ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201052 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201052:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc0201054:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201056:	17fd                	addi	a5,a5,-1
ffffffffc0201058:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc020105a:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020105c:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc0201060:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201062:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc0201064:	fc06                	sd	ra,56(sp)
ffffffffc0201066:	f04a                	sd	s2,32(sp)
ffffffffc0201068:	ec4e                	sd	s3,24(sp)
ffffffffc020106a:	e852                	sd	s4,16(sp)
ffffffffc020106c:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020106e:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc0201072:	002007b7          	lui	a5,0x200
ffffffffc0201076:	01047433          	and	s0,s0,a6
ffffffffc020107a:	06f4e363          	bltu	s1,a5,ffffffffc02010e0 <mm_map+0x8e>
ffffffffc020107e:	0684f163          	bleu	s0,s1,ffffffffc02010e0 <mm_map+0x8e>
ffffffffc0201082:	4785                	li	a5,1
ffffffffc0201084:	07fe                	slli	a5,a5,0x1f
ffffffffc0201086:	0487ed63          	bltu	a5,s0,ffffffffc02010e0 <mm_map+0x8e>
ffffffffc020108a:	89aa                	mv	s3,a0
ffffffffc020108c:	8a3a                	mv	s4,a4
ffffffffc020108e:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0201090:	c931                	beqz	a0,ffffffffc02010e4 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0201092:	85a6                	mv	a1,s1
ffffffffc0201094:	e61ff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc0201098:	c501                	beqz	a0,ffffffffc02010a0 <mm_map+0x4e>
ffffffffc020109a:	651c                	ld	a5,8(a0)
ffffffffc020109c:	0487e263          	bltu	a5,s0,ffffffffc02010e0 <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02010a0:	03000513          	li	a0,48
ffffffffc02010a4:	6cd000ef          	jal	ra,ffffffffc0201f70 <kmalloc>
ffffffffc02010a8:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02010aa:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc02010ac:	02090163          	beqz	s2,ffffffffc02010ce <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02010b0:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02010b2:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02010b6:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02010ba:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02010be:	85ca                	mv	a1,s2
ffffffffc02010c0:	e73ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02010c4:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc02010c6:	000a0463          	beqz	s4,ffffffffc02010ce <mm_map+0x7c>
        *vma_store = vma;
ffffffffc02010ca:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc02010ce:	70e2                	ld	ra,56(sp)
ffffffffc02010d0:	7442                	ld	s0,48(sp)
ffffffffc02010d2:	74a2                	ld	s1,40(sp)
ffffffffc02010d4:	7902                	ld	s2,32(sp)
ffffffffc02010d6:	69e2                	ld	s3,24(sp)
ffffffffc02010d8:	6a42                	ld	s4,16(sp)
ffffffffc02010da:	6aa2                	ld	s5,8(sp)
ffffffffc02010dc:	6121                	addi	sp,sp,64
ffffffffc02010de:	8082                	ret
        return -E_INVAL;
ffffffffc02010e0:	5575                	li	a0,-3
ffffffffc02010e2:	b7f5                	j	ffffffffc02010ce <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc02010e4:	00006697          	auipc	a3,0x6
ffffffffc02010e8:	01468693          	addi	a3,a3,20 # ffffffffc02070f8 <commands+0x9c0>
ffffffffc02010ec:	00006617          	auipc	a2,0x6
ffffffffc02010f0:	acc60613          	addi	a2,a2,-1332 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02010f4:	0a700593          	li	a1,167
ffffffffc02010f8:	00006517          	auipc	a0,0x6
ffffffffc02010fc:	e9850513          	addi	a0,a0,-360 # ffffffffc0206f90 <commands+0x858>
ffffffffc0201100:	916ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201104 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0201104:	7139                	addi	sp,sp,-64
ffffffffc0201106:	fc06                	sd	ra,56(sp)
ffffffffc0201108:	f822                	sd	s0,48(sp)
ffffffffc020110a:	f426                	sd	s1,40(sp)
ffffffffc020110c:	f04a                	sd	s2,32(sp)
ffffffffc020110e:	ec4e                	sd	s3,24(sp)
ffffffffc0201110:	e852                	sd	s4,16(sp)
ffffffffc0201112:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0201114:	c535                	beqz	a0,ffffffffc0201180 <dup_mmap+0x7c>
ffffffffc0201116:	892a                	mv	s2,a0
ffffffffc0201118:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc020111a:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc020111c:	e59d                	bnez	a1,ffffffffc020114a <dup_mmap+0x46>
ffffffffc020111e:	a08d                	j	ffffffffc0201180 <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0201120:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0201122:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5598>
        insert_vma_struct(to, nvma);
ffffffffc0201126:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0201128:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc020112c:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc0201130:	e03ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0201134:	ff043683          	ld	a3,-16(s0)
ffffffffc0201138:	fe843603          	ld	a2,-24(s0)
ffffffffc020113c:	6c8c                	ld	a1,24(s1)
ffffffffc020113e:	01893503          	ld	a0,24(s2)
ffffffffc0201142:	4701                	li	a4,0
ffffffffc0201144:	710030ef          	jal	ra,ffffffffc0204854 <copy_range>
ffffffffc0201148:	e105                	bnez	a0,ffffffffc0201168 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc020114a:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc020114c:	02848863          	beq	s1,s0,ffffffffc020117c <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201150:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0201154:	fe843a83          	ld	s5,-24(s0)
ffffffffc0201158:	ff043a03          	ld	s4,-16(s0)
ffffffffc020115c:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201160:	611000ef          	jal	ra,ffffffffc0201f70 <kmalloc>
ffffffffc0201164:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc0201166:	fd4d                	bnez	a0,ffffffffc0201120 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0201168:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc020116a:	70e2                	ld	ra,56(sp)
ffffffffc020116c:	7442                	ld	s0,48(sp)
ffffffffc020116e:	74a2                	ld	s1,40(sp)
ffffffffc0201170:	7902                	ld	s2,32(sp)
ffffffffc0201172:	69e2                	ld	s3,24(sp)
ffffffffc0201174:	6a42                	ld	s4,16(sp)
ffffffffc0201176:	6aa2                	ld	s5,8(sp)
ffffffffc0201178:	6121                	addi	sp,sp,64
ffffffffc020117a:	8082                	ret
    return 0;
ffffffffc020117c:	4501                	li	a0,0
ffffffffc020117e:	b7f5                	j	ffffffffc020116a <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc0201180:	00006697          	auipc	a3,0x6
ffffffffc0201184:	ec068693          	addi	a3,a3,-320 # ffffffffc0207040 <commands+0x908>
ffffffffc0201188:	00006617          	auipc	a2,0x6
ffffffffc020118c:	a3060613          	addi	a2,a2,-1488 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201190:	0c000593          	li	a1,192
ffffffffc0201194:	00006517          	auipc	a0,0x6
ffffffffc0201198:	dfc50513          	addi	a0,a0,-516 # ffffffffc0206f90 <commands+0x858>
ffffffffc020119c:	87aff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02011a0 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02011a0:	1101                	addi	sp,sp,-32
ffffffffc02011a2:	ec06                	sd	ra,24(sp)
ffffffffc02011a4:	e822                	sd	s0,16(sp)
ffffffffc02011a6:	e426                	sd	s1,8(sp)
ffffffffc02011a8:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02011aa:	c531                	beqz	a0,ffffffffc02011f6 <exit_mmap+0x56>
ffffffffc02011ac:	591c                	lw	a5,48(a0)
ffffffffc02011ae:	84aa                	mv	s1,a0
ffffffffc02011b0:	e3b9                	bnez	a5,ffffffffc02011f6 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02011b2:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02011b4:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02011b8:	02850663          	beq	a0,s0,ffffffffc02011e4 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02011bc:	ff043603          	ld	a2,-16(s0)
ffffffffc02011c0:	fe843583          	ld	a1,-24(s0)
ffffffffc02011c4:	854a                	mv	a0,s2
ffffffffc02011c6:	764020ef          	jal	ra,ffffffffc020392a <unmap_range>
ffffffffc02011ca:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02011cc:	fe8498e3          	bne	s1,s0,ffffffffc02011bc <exit_mmap+0x1c>
ffffffffc02011d0:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc02011d2:	00848c63          	beq	s1,s0,ffffffffc02011ea <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02011d6:	ff043603          	ld	a2,-16(s0)
ffffffffc02011da:	fe843583          	ld	a1,-24(s0)
ffffffffc02011de:	854a                	mv	a0,s2
ffffffffc02011e0:	063020ef          	jal	ra,ffffffffc0203a42 <exit_range>
ffffffffc02011e4:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02011e6:	fe8498e3          	bne	s1,s0,ffffffffc02011d6 <exit_mmap+0x36>
    }
}
ffffffffc02011ea:	60e2                	ld	ra,24(sp)
ffffffffc02011ec:	6442                	ld	s0,16(sp)
ffffffffc02011ee:	64a2                	ld	s1,8(sp)
ffffffffc02011f0:	6902                	ld	s2,0(sp)
ffffffffc02011f2:	6105                	addi	sp,sp,32
ffffffffc02011f4:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02011f6:	00006697          	auipc	a3,0x6
ffffffffc02011fa:	e6a68693          	addi	a3,a3,-406 # ffffffffc0207060 <commands+0x928>
ffffffffc02011fe:	00006617          	auipc	a2,0x6
ffffffffc0201202:	9ba60613          	addi	a2,a2,-1606 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201206:	0d600593          	li	a1,214
ffffffffc020120a:	00006517          	auipc	a0,0x6
ffffffffc020120e:	d8650513          	addi	a0,a0,-634 # ffffffffc0206f90 <commands+0x858>
ffffffffc0201212:	804ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201216 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0201216:	7139                	addi	sp,sp,-64
ffffffffc0201218:	f822                	sd	s0,48(sp)
ffffffffc020121a:	f426                	sd	s1,40(sp)
ffffffffc020121c:	fc06                	sd	ra,56(sp)
ffffffffc020121e:	f04a                	sd	s2,32(sp)
ffffffffc0201220:	ec4e                	sd	s3,24(sp)
ffffffffc0201222:	e852                	sd	s4,16(sp)
ffffffffc0201224:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0201226:	c55ff0ef          	jal	ra,ffffffffc0200e7a <mm_create>
    assert(mm != NULL);
ffffffffc020122a:	842a                	mv	s0,a0
ffffffffc020122c:	03200493          	li	s1,50
ffffffffc0201230:	e919                	bnez	a0,ffffffffc0201246 <vmm_init+0x30>
ffffffffc0201232:	a989                	j	ffffffffc0201684 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0201234:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201236:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201238:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020123c:	14ed                	addi	s1,s1,-5
ffffffffc020123e:	8522                	mv	a0,s0
ffffffffc0201240:	cf3ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0201244:	c88d                	beqz	s1,ffffffffc0201276 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201246:	03000513          	li	a0,48
ffffffffc020124a:	527000ef          	jal	ra,ffffffffc0201f70 <kmalloc>
ffffffffc020124e:	85aa                	mv	a1,a0
ffffffffc0201250:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201254:	f165                	bnez	a0,ffffffffc0201234 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0201256:	00006697          	auipc	a3,0x6
ffffffffc020125a:	12268693          	addi	a3,a3,290 # ffffffffc0207378 <commands+0xc40>
ffffffffc020125e:	00006617          	auipc	a2,0x6
ffffffffc0201262:	95a60613          	addi	a2,a2,-1702 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201266:	11300593          	li	a1,275
ffffffffc020126a:	00006517          	auipc	a0,0x6
ffffffffc020126e:	d2650513          	addi	a0,a0,-730 # ffffffffc0206f90 <commands+0x858>
ffffffffc0201272:	fa5fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0201276:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020127a:	1f900913          	li	s2,505
ffffffffc020127e:	a819                	j	ffffffffc0201294 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0201280:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201282:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201284:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201288:	0495                	addi	s1,s1,5
ffffffffc020128a:	8522                	mv	a0,s0
ffffffffc020128c:	ca7ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201290:	03248a63          	beq	s1,s2,ffffffffc02012c4 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201294:	03000513          	li	a0,48
ffffffffc0201298:	4d9000ef          	jal	ra,ffffffffc0201f70 <kmalloc>
ffffffffc020129c:	85aa                	mv	a1,a0
ffffffffc020129e:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02012a2:	fd79                	bnez	a0,ffffffffc0201280 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02012a4:	00006697          	auipc	a3,0x6
ffffffffc02012a8:	0d468693          	addi	a3,a3,212 # ffffffffc0207378 <commands+0xc40>
ffffffffc02012ac:	00006617          	auipc	a2,0x6
ffffffffc02012b0:	90c60613          	addi	a2,a2,-1780 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02012b4:	11900593          	li	a1,281
ffffffffc02012b8:	00006517          	auipc	a0,0x6
ffffffffc02012bc:	cd850513          	addi	a0,a0,-808 # ffffffffc0206f90 <commands+0x858>
ffffffffc02012c0:	f57fe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc02012c4:	6418                	ld	a4,8(s0)
ffffffffc02012c6:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02012c8:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02012cc:	2ee40063          	beq	s0,a4,ffffffffc02015ac <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02012d0:	fe873603          	ld	a2,-24(a4)
ffffffffc02012d4:	ffe78693          	addi	a3,a5,-2
ffffffffc02012d8:	24d61a63          	bne	a2,a3,ffffffffc020152c <vmm_init+0x316>
ffffffffc02012dc:	ff073683          	ld	a3,-16(a4)
ffffffffc02012e0:	24f69663          	bne	a3,a5,ffffffffc020152c <vmm_init+0x316>
ffffffffc02012e4:	0795                	addi	a5,a5,5
ffffffffc02012e6:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02012e8:	feb792e3          	bne	a5,a1,ffffffffc02012cc <vmm_init+0xb6>
ffffffffc02012ec:	491d                	li	s2,7
ffffffffc02012ee:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02012f0:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02012f4:	85a6                	mv	a1,s1
ffffffffc02012f6:	8522                	mv	a0,s0
ffffffffc02012f8:	bfdff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc02012fc:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc02012fe:	30050763          	beqz	a0,ffffffffc020160c <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0201302:	00148593          	addi	a1,s1,1
ffffffffc0201306:	8522                	mv	a0,s0
ffffffffc0201308:	bedff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc020130c:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020130e:	2c050f63          	beqz	a0,ffffffffc02015ec <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0201312:	85ca                	mv	a1,s2
ffffffffc0201314:	8522                	mv	a0,s0
ffffffffc0201316:	bdfff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
        assert(vma3 == NULL);
ffffffffc020131a:	2a051963          	bnez	a0,ffffffffc02015cc <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020131e:	00348593          	addi	a1,s1,3
ffffffffc0201322:	8522                	mv	a0,s0
ffffffffc0201324:	bd1ff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
        assert(vma4 == NULL);
ffffffffc0201328:	32051263          	bnez	a0,ffffffffc020164c <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020132c:	00448593          	addi	a1,s1,4
ffffffffc0201330:	8522                	mv	a0,s0
ffffffffc0201332:	bc3ff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
        assert(vma5 == NULL);
ffffffffc0201336:	2e051b63          	bnez	a0,ffffffffc020162c <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020133a:	008a3783          	ld	a5,8(s4)
ffffffffc020133e:	20979763          	bne	a5,s1,ffffffffc020154c <vmm_init+0x336>
ffffffffc0201342:	010a3783          	ld	a5,16(s4)
ffffffffc0201346:	21279363          	bne	a5,s2,ffffffffc020154c <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020134a:	0089b783          	ld	a5,8(s3)
ffffffffc020134e:	20979f63          	bne	a5,s1,ffffffffc020156c <vmm_init+0x356>
ffffffffc0201352:	0109b783          	ld	a5,16(s3)
ffffffffc0201356:	21279b63          	bne	a5,s2,ffffffffc020156c <vmm_init+0x356>
ffffffffc020135a:	0495                	addi	s1,s1,5
ffffffffc020135c:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020135e:	f9549be3          	bne	s1,s5,ffffffffc02012f4 <vmm_init+0xde>
ffffffffc0201362:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201364:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0201366:	85a6                	mv	a1,s1
ffffffffc0201368:	8522                	mv	a0,s0
ffffffffc020136a:	b8bff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc020136e:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0201372:	c90d                	beqz	a0,ffffffffc02013a4 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201374:	6914                	ld	a3,16(a0)
ffffffffc0201376:	6510                	ld	a2,8(a0)
ffffffffc0201378:	00006517          	auipc	a0,0x6
ffffffffc020137c:	e9050513          	addi	a0,a0,-368 # ffffffffc0207208 <commands+0xad0>
ffffffffc0201380:	d51fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201384:	00006697          	auipc	a3,0x6
ffffffffc0201388:	eac68693          	addi	a3,a3,-340 # ffffffffc0207230 <commands+0xaf8>
ffffffffc020138c:	00006617          	auipc	a2,0x6
ffffffffc0201390:	82c60613          	addi	a2,a2,-2004 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201394:	13b00593          	li	a1,315
ffffffffc0201398:	00006517          	auipc	a0,0x6
ffffffffc020139c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0206f90 <commands+0x858>
ffffffffc02013a0:	e77fe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc02013a4:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02013a6:	fd2490e3          	bne	s1,s2,ffffffffc0201366 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02013aa:	8522                	mv	a0,s0
ffffffffc02013ac:	c55ff0ef          	jal	ra,ffffffffc0201000 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02013b0:	00006517          	auipc	a0,0x6
ffffffffc02013b4:	e9850513          	addi	a0,a0,-360 # ffffffffc0207248 <commands+0xb10>
ffffffffc02013b8:	d19fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02013bc:	2fa020ef          	jal	ra,ffffffffc02036b6 <nr_free_pages>
ffffffffc02013c0:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02013c2:	ab9ff0ef          	jal	ra,ffffffffc0200e7a <mm_create>
ffffffffc02013c6:	000ab797          	auipc	a5,0xab
ffffffffc02013ca:	fea7b923          	sd	a0,-14(a5) # ffffffffc02ac3b8 <check_mm_struct>
ffffffffc02013ce:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc02013d0:	36050663          	beqz	a0,ffffffffc020173c <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013d4:	000ab797          	auipc	a5,0xab
ffffffffc02013d8:	fac78793          	addi	a5,a5,-84 # ffffffffc02ac380 <boot_pgdir>
ffffffffc02013dc:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02013e0:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013e4:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02013e8:	2c079e63          	bnez	a5,ffffffffc02016c4 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013ec:	03000513          	li	a0,48
ffffffffc02013f0:	381000ef          	jal	ra,ffffffffc0201f70 <kmalloc>
ffffffffc02013f4:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc02013f6:	18050b63          	beqz	a0,ffffffffc020158c <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc02013fa:	002007b7          	lui	a5,0x200
ffffffffc02013fe:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0201400:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0201402:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0201404:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0201406:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0201408:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc020140c:	b27ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0201410:	10000593          	li	a1,256
ffffffffc0201414:	8526                	mv	a0,s1
ffffffffc0201416:	adfff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc020141a:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020141e:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0201422:	2ca41163          	bne	s0,a0,ffffffffc02016e4 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0201426:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5590>
        sum += i;
ffffffffc020142a:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020142c:	fee79de3          	bne	a5,a4,ffffffffc0201426 <vmm_init+0x210>
        sum += i;
ffffffffc0201430:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0201432:	10000793          	li	a5,256
        sum += i;
ffffffffc0201436:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8212>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020143a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020143e:	0007c683          	lbu	a3,0(a5)
ffffffffc0201442:	0785                	addi	a5,a5,1
ffffffffc0201444:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0201446:	fec79ce3          	bne	a5,a2,ffffffffc020143e <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc020144a:	2c071963          	bnez	a4,ffffffffc020171c <vmm_init+0x506>
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc020144e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201452:	000aba97          	auipc	s5,0xab
ffffffffc0201456:	f36a8a93          	addi	s5,s5,-202 # ffffffffc02ac388 <npage>
ffffffffc020145a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020145e:	078a                	slli	a5,a5,0x2
ffffffffc0201460:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201462:	20e7f563          	bleu	a4,a5,ffffffffc020166c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0201466:	00008697          	auipc	a3,0x8
ffffffffc020146a:	82a68693          	addi	a3,a3,-2006 # ffffffffc0208c90 <nbase>
ffffffffc020146e:	0006ba03          	ld	s4,0(a3)
ffffffffc0201472:	414786b3          	sub	a3,a5,s4
ffffffffc0201476:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0201478:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020147a:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020147c:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc020147e:	83b1                	srli	a5,a5,0xc
ffffffffc0201480:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201482:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201484:	28e7f063          	bleu	a4,a5,ffffffffc0201704 <vmm_init+0x4ee>
ffffffffc0201488:	000ab797          	auipc	a5,0xab
ffffffffc020148c:	03078793          	addi	a5,a5,48 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc0201490:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0201492:	4581                	li	a1,0
ffffffffc0201494:	854a                	mv	a0,s2
ffffffffc0201496:	9436                	add	s0,s0,a3
ffffffffc0201498:	001020ef          	jal	ra,ffffffffc0203c98 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020149c:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020149e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014a2:	078a                	slli	a5,a5,0x2
ffffffffc02014a4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014a6:	1ce7f363          	bleu	a4,a5,ffffffffc020166c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02014aa:	000ab417          	auipc	s0,0xab
ffffffffc02014ae:	01e40413          	addi	s0,s0,30 # ffffffffc02ac4c8 <pages>
ffffffffc02014b2:	6008                	ld	a0,0(s0)
ffffffffc02014b4:	414787b3          	sub	a5,a5,s4
ffffffffc02014b8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02014ba:	953e                	add	a0,a0,a5
ffffffffc02014bc:	4585                	li	a1,1
ffffffffc02014be:	1b2020ef          	jal	ra,ffffffffc0203670 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02014c2:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02014c6:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014ca:	078a                	slli	a5,a5,0x2
ffffffffc02014cc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014ce:	18e7ff63          	bleu	a4,a5,ffffffffc020166c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02014d2:	6008                	ld	a0,0(s0)
ffffffffc02014d4:	414787b3          	sub	a5,a5,s4
ffffffffc02014d8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02014da:	4585                	li	a1,1
ffffffffc02014dc:	953e                	add	a0,a0,a5
ffffffffc02014de:	192020ef          	jal	ra,ffffffffc0203670 <free_pages>
    pgdir[0] = 0;
ffffffffc02014e2:	00093023          	sd	zero,0(s2)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc02014e6:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc02014ea:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc02014ee:	8526                	mv	a0,s1
ffffffffc02014f0:	b11ff0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc02014f4:	000ab797          	auipc	a5,0xab
ffffffffc02014f8:	ec07b223          	sd	zero,-316(a5) # ffffffffc02ac3b8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02014fc:	1ba020ef          	jal	ra,ffffffffc02036b6 <nr_free_pages>
ffffffffc0201500:	1aa99263          	bne	s3,a0,ffffffffc02016a4 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0201504:	00006517          	auipc	a0,0x6
ffffffffc0201508:	e3c50513          	addi	a0,a0,-452 # ffffffffc0207340 <commands+0xc08>
ffffffffc020150c:	bc5fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0201510:	7442                	ld	s0,48(sp)
ffffffffc0201512:	70e2                	ld	ra,56(sp)
ffffffffc0201514:	74a2                	ld	s1,40(sp)
ffffffffc0201516:	7902                	ld	s2,32(sp)
ffffffffc0201518:	69e2                	ld	s3,24(sp)
ffffffffc020151a:	6a42                	ld	s4,16(sp)
ffffffffc020151c:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020151e:	00006517          	auipc	a0,0x6
ffffffffc0201522:	e4250513          	addi	a0,a0,-446 # ffffffffc0207360 <commands+0xc28>
}
ffffffffc0201526:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201528:	ba9fe06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020152c:	00006697          	auipc	a3,0x6
ffffffffc0201530:	bf468693          	addi	a3,a3,-1036 # ffffffffc0207120 <commands+0x9e8>
ffffffffc0201534:	00005617          	auipc	a2,0x5
ffffffffc0201538:	68460613          	addi	a2,a2,1668 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020153c:	12200593          	li	a1,290
ffffffffc0201540:	00006517          	auipc	a0,0x6
ffffffffc0201544:	a5050513          	addi	a0,a0,-1456 # ffffffffc0206f90 <commands+0x858>
ffffffffc0201548:	ccffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020154c:	00006697          	auipc	a3,0x6
ffffffffc0201550:	c5c68693          	addi	a3,a3,-932 # ffffffffc02071a8 <commands+0xa70>
ffffffffc0201554:	00005617          	auipc	a2,0x5
ffffffffc0201558:	66460613          	addi	a2,a2,1636 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020155c:	13200593          	li	a1,306
ffffffffc0201560:	00006517          	auipc	a0,0x6
ffffffffc0201564:	a3050513          	addi	a0,a0,-1488 # ffffffffc0206f90 <commands+0x858>
ffffffffc0201568:	caffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020156c:	00006697          	auipc	a3,0x6
ffffffffc0201570:	c6c68693          	addi	a3,a3,-916 # ffffffffc02071d8 <commands+0xaa0>
ffffffffc0201574:	00005617          	auipc	a2,0x5
ffffffffc0201578:	64460613          	addi	a2,a2,1604 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020157c:	13300593          	li	a1,307
ffffffffc0201580:	00006517          	auipc	a0,0x6
ffffffffc0201584:	a1050513          	addi	a0,a0,-1520 # ffffffffc0206f90 <commands+0x858>
ffffffffc0201588:	c8ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(vma != NULL);
ffffffffc020158c:	00006697          	auipc	a3,0x6
ffffffffc0201590:	dec68693          	addi	a3,a3,-532 # ffffffffc0207378 <commands+0xc40>
ffffffffc0201594:	00005617          	auipc	a2,0x5
ffffffffc0201598:	62460613          	addi	a2,a2,1572 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020159c:	15200593          	li	a1,338
ffffffffc02015a0:	00006517          	auipc	a0,0x6
ffffffffc02015a4:	9f050513          	addi	a0,a0,-1552 # ffffffffc0206f90 <commands+0x858>
ffffffffc02015a8:	c6ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02015ac:	00006697          	auipc	a3,0x6
ffffffffc02015b0:	b5c68693          	addi	a3,a3,-1188 # ffffffffc0207108 <commands+0x9d0>
ffffffffc02015b4:	00005617          	auipc	a2,0x5
ffffffffc02015b8:	60460613          	addi	a2,a2,1540 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02015bc:	12000593          	li	a1,288
ffffffffc02015c0:	00006517          	auipc	a0,0x6
ffffffffc02015c4:	9d050513          	addi	a0,a0,-1584 # ffffffffc0206f90 <commands+0x858>
ffffffffc02015c8:	c4ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma3 == NULL);
ffffffffc02015cc:	00006697          	auipc	a3,0x6
ffffffffc02015d0:	bac68693          	addi	a3,a3,-1108 # ffffffffc0207178 <commands+0xa40>
ffffffffc02015d4:	00005617          	auipc	a2,0x5
ffffffffc02015d8:	5e460613          	addi	a2,a2,1508 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02015dc:	12c00593          	li	a1,300
ffffffffc02015e0:	00006517          	auipc	a0,0x6
ffffffffc02015e4:	9b050513          	addi	a0,a0,-1616 # ffffffffc0206f90 <commands+0x858>
ffffffffc02015e8:	c2ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma2 != NULL);
ffffffffc02015ec:	00006697          	auipc	a3,0x6
ffffffffc02015f0:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0207168 <commands+0xa30>
ffffffffc02015f4:	00005617          	auipc	a2,0x5
ffffffffc02015f8:	5c460613          	addi	a2,a2,1476 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02015fc:	12a00593          	li	a1,298
ffffffffc0201600:	00006517          	auipc	a0,0x6
ffffffffc0201604:	99050513          	addi	a0,a0,-1648 # ffffffffc0206f90 <commands+0x858>
ffffffffc0201608:	c0ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma1 != NULL);
ffffffffc020160c:	00006697          	auipc	a3,0x6
ffffffffc0201610:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0207158 <commands+0xa20>
ffffffffc0201614:	00005617          	auipc	a2,0x5
ffffffffc0201618:	5a460613          	addi	a2,a2,1444 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020161c:	12800593          	li	a1,296
ffffffffc0201620:	00006517          	auipc	a0,0x6
ffffffffc0201624:	97050513          	addi	a0,a0,-1680 # ffffffffc0206f90 <commands+0x858>
ffffffffc0201628:	beffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma5 == NULL);
ffffffffc020162c:	00006697          	auipc	a3,0x6
ffffffffc0201630:	b6c68693          	addi	a3,a3,-1172 # ffffffffc0207198 <commands+0xa60>
ffffffffc0201634:	00005617          	auipc	a2,0x5
ffffffffc0201638:	58460613          	addi	a2,a2,1412 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020163c:	13000593          	li	a1,304
ffffffffc0201640:	00006517          	auipc	a0,0x6
ffffffffc0201644:	95050513          	addi	a0,a0,-1712 # ffffffffc0206f90 <commands+0x858>
ffffffffc0201648:	bcffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma4 == NULL);
ffffffffc020164c:	00006697          	auipc	a3,0x6
ffffffffc0201650:	b3c68693          	addi	a3,a3,-1220 # ffffffffc0207188 <commands+0xa50>
ffffffffc0201654:	00005617          	auipc	a2,0x5
ffffffffc0201658:	56460613          	addi	a2,a2,1380 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020165c:	12e00593          	li	a1,302
ffffffffc0201660:	00006517          	auipc	a0,0x6
ffffffffc0201664:	93050513          	addi	a0,a0,-1744 # ffffffffc0206f90 <commands+0x858>
ffffffffc0201668:	baffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020166c:	00006617          	auipc	a2,0x6
ffffffffc0201670:	c5460613          	addi	a2,a2,-940 # ffffffffc02072c0 <commands+0xb88>
ffffffffc0201674:	06200593          	li	a1,98
ffffffffc0201678:	00006517          	auipc	a0,0x6
ffffffffc020167c:	c6850513          	addi	a0,a0,-920 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0201680:	b97fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(mm != NULL);
ffffffffc0201684:	00006697          	auipc	a3,0x6
ffffffffc0201688:	a7468693          	addi	a3,a3,-1420 # ffffffffc02070f8 <commands+0x9c0>
ffffffffc020168c:	00005617          	auipc	a2,0x5
ffffffffc0201690:	52c60613          	addi	a2,a2,1324 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201694:	10c00593          	li	a1,268
ffffffffc0201698:	00006517          	auipc	a0,0x6
ffffffffc020169c:	8f850513          	addi	a0,a0,-1800 # ffffffffc0206f90 <commands+0x858>
ffffffffc02016a0:	b77fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02016a4:	00006697          	auipc	a3,0x6
ffffffffc02016a8:	c7468693          	addi	a3,a3,-908 # ffffffffc0207318 <commands+0xbe0>
ffffffffc02016ac:	00005617          	auipc	a2,0x5
ffffffffc02016b0:	50c60613          	addi	a2,a2,1292 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02016b4:	17000593          	li	a1,368
ffffffffc02016b8:	00006517          	auipc	a0,0x6
ffffffffc02016bc:	8d850513          	addi	a0,a0,-1832 # ffffffffc0206f90 <commands+0x858>
ffffffffc02016c0:	b57fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02016c4:	00006697          	auipc	a3,0x6
ffffffffc02016c8:	bbc68693          	addi	a3,a3,-1092 # ffffffffc0207280 <commands+0xb48>
ffffffffc02016cc:	00005617          	auipc	a2,0x5
ffffffffc02016d0:	4ec60613          	addi	a2,a2,1260 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02016d4:	14f00593          	li	a1,335
ffffffffc02016d8:	00006517          	auipc	a0,0x6
ffffffffc02016dc:	8b850513          	addi	a0,a0,-1864 # ffffffffc0206f90 <commands+0x858>
ffffffffc02016e0:	b37fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02016e4:	00006697          	auipc	a3,0x6
ffffffffc02016e8:	bac68693          	addi	a3,a3,-1108 # ffffffffc0207290 <commands+0xb58>
ffffffffc02016ec:	00005617          	auipc	a2,0x5
ffffffffc02016f0:	4cc60613          	addi	a2,a2,1228 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02016f4:	15700593          	li	a1,343
ffffffffc02016f8:	00006517          	auipc	a0,0x6
ffffffffc02016fc:	89850513          	addi	a0,a0,-1896 # ffffffffc0206f90 <commands+0x858>
ffffffffc0201700:	b17fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201704:	00006617          	auipc	a2,0x6
ffffffffc0201708:	bec60613          	addi	a2,a2,-1044 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc020170c:	06900593          	li	a1,105
ffffffffc0201710:	00006517          	auipc	a0,0x6
ffffffffc0201714:	bd050513          	addi	a0,a0,-1072 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0201718:	afffe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(sum == 0);
ffffffffc020171c:	00006697          	auipc	a3,0x6
ffffffffc0201720:	b9468693          	addi	a3,a3,-1132 # ffffffffc02072b0 <commands+0xb78>
ffffffffc0201724:	00005617          	auipc	a2,0x5
ffffffffc0201728:	49460613          	addi	a2,a2,1172 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020172c:	16300593          	li	a1,355
ffffffffc0201730:	00006517          	auipc	a0,0x6
ffffffffc0201734:	86050513          	addi	a0,a0,-1952 # ffffffffc0206f90 <commands+0x858>
ffffffffc0201738:	adffe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020173c:	00006697          	auipc	a3,0x6
ffffffffc0201740:	b2c68693          	addi	a3,a3,-1236 # ffffffffc0207268 <commands+0xb30>
ffffffffc0201744:	00005617          	auipc	a2,0x5
ffffffffc0201748:	47460613          	addi	a2,a2,1140 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020174c:	14b00593          	li	a1,331
ffffffffc0201750:	00006517          	auipc	a0,0x6
ffffffffc0201754:	84050513          	addi	a0,a0,-1984 # ffffffffc0206f90 <commands+0x858>
ffffffffc0201758:	abffe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020175c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc020175c:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020175e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0201760:	f022                	sd	s0,32(sp)
ffffffffc0201762:	ec26                	sd	s1,24(sp)
ffffffffc0201764:	f406                	sd	ra,40(sp)
ffffffffc0201766:	e84a                	sd	s2,16(sp)
ffffffffc0201768:	8432                	mv	s0,a2
ffffffffc020176a:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020176c:	f88ff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>

    pgfault_num++;
ffffffffc0201770:	000ab797          	auipc	a5,0xab
ffffffffc0201774:	bf078793          	addi	a5,a5,-1040 # ffffffffc02ac360 <pgfault_num>
ffffffffc0201778:	439c                	lw	a5,0(a5)
ffffffffc020177a:	2785                	addiw	a5,a5,1
ffffffffc020177c:	000ab717          	auipc	a4,0xab
ffffffffc0201780:	bef72223          	sw	a5,-1052(a4) # ffffffffc02ac360 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201784:	c551                	beqz	a0,ffffffffc0201810 <do_pgfault+0xb4>
ffffffffc0201786:	651c                	ld	a5,8(a0)
ffffffffc0201788:	08f46463          	bltu	s0,a5,ffffffffc0201810 <do_pgfault+0xb4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020178c:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020178e:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201790:	8b89                	andi	a5,a5,2
ffffffffc0201792:	efb1                	bnez	a5,ffffffffc02017ee <do_pgfault+0x92>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201794:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201796:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201798:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020179a:	85a2                	mv	a1,s0
ffffffffc020179c:	4605                	li	a2,1
ffffffffc020179e:	759010ef          	jal	ra,ffffffffc02036f6 <get_pte>
ffffffffc02017a2:	c941                	beqz	a0,ffffffffc0201832 <do_pgfault+0xd6>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02017a4:	610c                	ld	a1,0(a0)
ffffffffc02017a6:	c5b1                	beqz	a1,ffffffffc02017f2 <do_pgfault+0x96>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02017a8:	000ab797          	auipc	a5,0xab
ffffffffc02017ac:	bd078793          	addi	a5,a5,-1072 # ffffffffc02ac378 <swap_init_ok>
ffffffffc02017b0:	439c                	lw	a5,0(a5)
ffffffffc02017b2:	2781                	sext.w	a5,a5
ffffffffc02017b4:	c7bd                	beqz	a5,ffffffffc0201822 <do_pgfault+0xc6>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm,addr,&page);
ffffffffc02017b6:	85a2                	mv	a1,s0
ffffffffc02017b8:	0030                	addi	a2,sp,8
ffffffffc02017ba:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02017bc:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc02017be:	246010ef          	jal	ra,ffffffffc0202a04 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc02017c2:	65a2                	ld	a1,8(sp)
ffffffffc02017c4:	6c88                	ld	a0,24(s1)
ffffffffc02017c6:	86ca                	mv	a3,s2
ffffffffc02017c8:	8622                	mv	a2,s0
ffffffffc02017ca:	542020ef          	jal	ra,ffffffffc0203d0c <page_insert>
            swap_map_swappable(mm,addr,page,0);
ffffffffc02017ce:	6622                	ld	a2,8(sp)
ffffffffc02017d0:	4681                	li	a3,0
ffffffffc02017d2:	85a2                	mv	a1,s0
ffffffffc02017d4:	8526                	mv	a0,s1
ffffffffc02017d6:	10a010ef          	jal	ra,ffffffffc02028e0 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc02017da:	6722                	ld	a4,8(sp)
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc02017dc:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc02017de:	ff00                	sd	s0,56(a4)
failed:
    return ret;
}
ffffffffc02017e0:	70a2                	ld	ra,40(sp)
ffffffffc02017e2:	7402                	ld	s0,32(sp)
ffffffffc02017e4:	64e2                	ld	s1,24(sp)
ffffffffc02017e6:	6942                	ld	s2,16(sp)
ffffffffc02017e8:	853e                	mv	a0,a5
ffffffffc02017ea:	6145                	addi	sp,sp,48
ffffffffc02017ec:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02017ee:	495d                	li	s2,23
ffffffffc02017f0:	b755                	j	ffffffffc0201794 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02017f2:	6c88                	ld	a0,24(s1)
ffffffffc02017f4:	864a                	mv	a2,s2
ffffffffc02017f6:	85a2                	mv	a1,s0
ffffffffc02017f8:	27a030ef          	jal	ra,ffffffffc0204a72 <pgdir_alloc_page>
   ret = 0;
ffffffffc02017fc:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02017fe:	f16d                	bnez	a0,ffffffffc02017e0 <do_pgfault+0x84>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201800:	00005517          	auipc	a0,0x5
ffffffffc0201804:	7f050513          	addi	a0,a0,2032 # ffffffffc0206ff0 <commands+0x8b8>
ffffffffc0201808:	8c9fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020180c:	57f1                	li	a5,-4
            goto failed;
ffffffffc020180e:	bfc9                	j	ffffffffc02017e0 <do_pgfault+0x84>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0201810:	85a2                	mv	a1,s0
ffffffffc0201812:	00005517          	auipc	a0,0x5
ffffffffc0201816:	78e50513          	addi	a0,a0,1934 # ffffffffc0206fa0 <commands+0x868>
ffffffffc020181a:	8b7fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc020181e:	57f5                	li	a5,-3
        goto failed;
ffffffffc0201820:	b7c1                	j	ffffffffc02017e0 <do_pgfault+0x84>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0201822:	00005517          	auipc	a0,0x5
ffffffffc0201826:	7f650513          	addi	a0,a0,2038 # ffffffffc0207018 <commands+0x8e0>
ffffffffc020182a:	8a7fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020182e:	57f1                	li	a5,-4
            goto failed;
ffffffffc0201830:	bf45                	j	ffffffffc02017e0 <do_pgfault+0x84>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0201832:	00005517          	auipc	a0,0x5
ffffffffc0201836:	79e50513          	addi	a0,a0,1950 # ffffffffc0206fd0 <commands+0x898>
ffffffffc020183a:	897fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020183e:	57f1                	li	a5,-4
        goto failed;
ffffffffc0201840:	b745                	j	ffffffffc02017e0 <do_pgfault+0x84>

ffffffffc0201842 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0201842:	7179                	addi	sp,sp,-48
ffffffffc0201844:	f022                	sd	s0,32(sp)
ffffffffc0201846:	f406                	sd	ra,40(sp)
ffffffffc0201848:	ec26                	sd	s1,24(sp)
ffffffffc020184a:	e84a                	sd	s2,16(sp)
ffffffffc020184c:	e44e                	sd	s3,8(sp)
ffffffffc020184e:	e052                	sd	s4,0(sp)
ffffffffc0201850:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0201852:	c135                	beqz	a0,ffffffffc02018b6 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0201854:	002007b7          	lui	a5,0x200
ffffffffc0201858:	04f5e663          	bltu	a1,a5,ffffffffc02018a4 <user_mem_check+0x62>
ffffffffc020185c:	00c584b3          	add	s1,a1,a2
ffffffffc0201860:	0495f263          	bleu	s1,a1,ffffffffc02018a4 <user_mem_check+0x62>
ffffffffc0201864:	4785                	li	a5,1
ffffffffc0201866:	07fe                	slli	a5,a5,0x1f
ffffffffc0201868:	0297ee63          	bltu	a5,s1,ffffffffc02018a4 <user_mem_check+0x62>
ffffffffc020186c:	892a                	mv	s2,a0
ffffffffc020186e:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201870:	6a05                	lui	s4,0x1
ffffffffc0201872:	a821                	j	ffffffffc020188a <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201874:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201878:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc020187a:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc020187c:	c685                	beqz	a3,ffffffffc02018a4 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc020187e:	c399                	beqz	a5,ffffffffc0201884 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201880:	02e46263          	bltu	s0,a4,ffffffffc02018a4 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0201884:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0201886:	04947663          	bleu	s1,s0,ffffffffc02018d2 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc020188a:	85a2                	mv	a1,s0
ffffffffc020188c:	854a                	mv	a0,s2
ffffffffc020188e:	e66ff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc0201892:	c909                	beqz	a0,ffffffffc02018a4 <user_mem_check+0x62>
ffffffffc0201894:	6518                	ld	a4,8(a0)
ffffffffc0201896:	00e46763          	bltu	s0,a4,ffffffffc02018a4 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc020189a:	4d1c                	lw	a5,24(a0)
ffffffffc020189c:	fc099ce3          	bnez	s3,ffffffffc0201874 <user_mem_check+0x32>
ffffffffc02018a0:	8b85                	andi	a5,a5,1
ffffffffc02018a2:	f3ed                	bnez	a5,ffffffffc0201884 <user_mem_check+0x42>
            return 0;
ffffffffc02018a4:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc02018a6:	70a2                	ld	ra,40(sp)
ffffffffc02018a8:	7402                	ld	s0,32(sp)
ffffffffc02018aa:	64e2                	ld	s1,24(sp)
ffffffffc02018ac:	6942                	ld	s2,16(sp)
ffffffffc02018ae:	69a2                	ld	s3,8(sp)
ffffffffc02018b0:	6a02                	ld	s4,0(sp)
ffffffffc02018b2:	6145                	addi	sp,sp,48
ffffffffc02018b4:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc02018b6:	c02007b7          	lui	a5,0xc0200
ffffffffc02018ba:	4501                	li	a0,0
ffffffffc02018bc:	fef5e5e3          	bltu	a1,a5,ffffffffc02018a6 <user_mem_check+0x64>
ffffffffc02018c0:	962e                	add	a2,a2,a1
ffffffffc02018c2:	fec5f2e3          	bleu	a2,a1,ffffffffc02018a6 <user_mem_check+0x64>
ffffffffc02018c6:	c8000537          	lui	a0,0xc8000
ffffffffc02018ca:	0505                	addi	a0,a0,1
ffffffffc02018cc:	00a63533          	sltu	a0,a2,a0
ffffffffc02018d0:	bfd9                	j	ffffffffc02018a6 <user_mem_check+0x64>
        return 1;
ffffffffc02018d2:	4505                	li	a0,1
ffffffffc02018d4:	bfc9                	j	ffffffffc02018a6 <user_mem_check+0x64>

ffffffffc02018d6 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02018d6:	000ab797          	auipc	a5,0xab
ffffffffc02018da:	aea78793          	addi	a5,a5,-1302 # ffffffffc02ac3c0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc02018de:	f51c                	sd	a5,40(a0)
ffffffffc02018e0:	e79c                	sd	a5,8(a5)
ffffffffc02018e2:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02018e4:	4501                	li	a0,0
ffffffffc02018e6:	8082                	ret

ffffffffc02018e8 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02018e8:	4501                	li	a0,0
ffffffffc02018ea:	8082                	ret

ffffffffc02018ec <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02018ec:	4501                	li	a0,0
ffffffffc02018ee:	8082                	ret

ffffffffc02018f0 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02018f0:	4501                	li	a0,0
ffffffffc02018f2:	8082                	ret

ffffffffc02018f4 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02018f4:	711d                	addi	sp,sp,-96
ffffffffc02018f6:	fc4e                	sd	s3,56(sp)
ffffffffc02018f8:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02018fa:	00006517          	auipc	a0,0x6
ffffffffc02018fe:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0207388 <commands+0xc50>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201902:	698d                	lui	s3,0x3
ffffffffc0201904:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0201906:	e8a2                	sd	s0,80(sp)
ffffffffc0201908:	e4a6                	sd	s1,72(sp)
ffffffffc020190a:	ec86                	sd	ra,88(sp)
ffffffffc020190c:	e0ca                	sd	s2,64(sp)
ffffffffc020190e:	f456                	sd	s5,40(sp)
ffffffffc0201910:	f05a                	sd	s6,32(sp)
ffffffffc0201912:	ec5e                	sd	s7,24(sp)
ffffffffc0201914:	e862                	sd	s8,16(sp)
ffffffffc0201916:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0201918:	000ab417          	auipc	s0,0xab
ffffffffc020191c:	a4840413          	addi	s0,s0,-1464 # ffffffffc02ac360 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201920:	fb0fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201924:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6568>
    assert(pgfault_num==4);
ffffffffc0201928:	4004                	lw	s1,0(s0)
ffffffffc020192a:	4791                	li	a5,4
ffffffffc020192c:	2481                	sext.w	s1,s1
ffffffffc020192e:	14f49963          	bne	s1,a5,ffffffffc0201a80 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201932:	00006517          	auipc	a0,0x6
ffffffffc0201936:	aa650513          	addi	a0,a0,-1370 # ffffffffc02073d8 <commands+0xca0>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020193a:	6a85                	lui	s5,0x1
ffffffffc020193c:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020193e:	f92fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201942:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8568>
    assert(pgfault_num==4);
ffffffffc0201946:	00042903          	lw	s2,0(s0)
ffffffffc020194a:	2901                	sext.w	s2,s2
ffffffffc020194c:	2a991a63          	bne	s2,s1,ffffffffc0201c00 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201950:	00006517          	auipc	a0,0x6
ffffffffc0201954:	ab050513          	addi	a0,a0,-1360 # ffffffffc0207400 <commands+0xcc8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201958:	6b91                	lui	s7,0x4
ffffffffc020195a:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020195c:	f74fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201960:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5568>
    assert(pgfault_num==4);
ffffffffc0201964:	4004                	lw	s1,0(s0)
ffffffffc0201966:	2481                	sext.w	s1,s1
ffffffffc0201968:	27249c63          	bne	s1,s2,ffffffffc0201be0 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020196c:	00006517          	auipc	a0,0x6
ffffffffc0201970:	abc50513          	addi	a0,a0,-1348 # ffffffffc0207428 <commands+0xcf0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201974:	6909                	lui	s2,0x2
ffffffffc0201976:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201978:	f58fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020197c:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7568>
    assert(pgfault_num==4);
ffffffffc0201980:	401c                	lw	a5,0(s0)
ffffffffc0201982:	2781                	sext.w	a5,a5
ffffffffc0201984:	22979e63          	bne	a5,s1,ffffffffc0201bc0 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201988:	00006517          	auipc	a0,0x6
ffffffffc020198c:	ac850513          	addi	a0,a0,-1336 # ffffffffc0207450 <commands+0xd18>
ffffffffc0201990:	f40fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201994:	6795                	lui	a5,0x5
ffffffffc0201996:	4739                	li	a4,14
ffffffffc0201998:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4568>
    assert(pgfault_num==5);
ffffffffc020199c:	4004                	lw	s1,0(s0)
ffffffffc020199e:	4795                	li	a5,5
ffffffffc02019a0:	2481                	sext.w	s1,s1
ffffffffc02019a2:	1ef49f63          	bne	s1,a5,ffffffffc0201ba0 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02019a6:	00006517          	auipc	a0,0x6
ffffffffc02019aa:	a8250513          	addi	a0,a0,-1406 # ffffffffc0207428 <commands+0xcf0>
ffffffffc02019ae:	f22fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02019b2:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc02019b6:	401c                	lw	a5,0(s0)
ffffffffc02019b8:	2781                	sext.w	a5,a5
ffffffffc02019ba:	1c979363          	bne	a5,s1,ffffffffc0201b80 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02019be:	00006517          	auipc	a0,0x6
ffffffffc02019c2:	a1a50513          	addi	a0,a0,-1510 # ffffffffc02073d8 <commands+0xca0>
ffffffffc02019c6:	f0afe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02019ca:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02019ce:	401c                	lw	a5,0(s0)
ffffffffc02019d0:	4719                	li	a4,6
ffffffffc02019d2:	2781                	sext.w	a5,a5
ffffffffc02019d4:	18e79663          	bne	a5,a4,ffffffffc0201b60 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02019d8:	00006517          	auipc	a0,0x6
ffffffffc02019dc:	a5050513          	addi	a0,a0,-1456 # ffffffffc0207428 <commands+0xcf0>
ffffffffc02019e0:	ef0fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02019e4:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc02019e8:	401c                	lw	a5,0(s0)
ffffffffc02019ea:	471d                	li	a4,7
ffffffffc02019ec:	2781                	sext.w	a5,a5
ffffffffc02019ee:	14e79963          	bne	a5,a4,ffffffffc0201b40 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02019f2:	00006517          	auipc	a0,0x6
ffffffffc02019f6:	99650513          	addi	a0,a0,-1642 # ffffffffc0207388 <commands+0xc50>
ffffffffc02019fa:	ed6fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02019fe:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0201a02:	401c                	lw	a5,0(s0)
ffffffffc0201a04:	4721                	li	a4,8
ffffffffc0201a06:	2781                	sext.w	a5,a5
ffffffffc0201a08:	10e79c63          	bne	a5,a4,ffffffffc0201b20 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201a0c:	00006517          	auipc	a0,0x6
ffffffffc0201a10:	9f450513          	addi	a0,a0,-1548 # ffffffffc0207400 <commands+0xcc8>
ffffffffc0201a14:	ebcfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201a18:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0201a1c:	401c                	lw	a5,0(s0)
ffffffffc0201a1e:	4725                	li	a4,9
ffffffffc0201a20:	2781                	sext.w	a5,a5
ffffffffc0201a22:	0ce79f63          	bne	a5,a4,ffffffffc0201b00 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201a26:	00006517          	auipc	a0,0x6
ffffffffc0201a2a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0207450 <commands+0xd18>
ffffffffc0201a2e:	ea2fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201a32:	6795                	lui	a5,0x5
ffffffffc0201a34:	4739                	li	a4,14
ffffffffc0201a36:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4568>
    assert(pgfault_num==10);
ffffffffc0201a3a:	4004                	lw	s1,0(s0)
ffffffffc0201a3c:	47a9                	li	a5,10
ffffffffc0201a3e:	2481                	sext.w	s1,s1
ffffffffc0201a40:	0af49063          	bne	s1,a5,ffffffffc0201ae0 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201a44:	00006517          	auipc	a0,0x6
ffffffffc0201a48:	99450513          	addi	a0,a0,-1644 # ffffffffc02073d8 <commands+0xca0>
ffffffffc0201a4c:	e84fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201a50:	6785                	lui	a5,0x1
ffffffffc0201a52:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8568>
ffffffffc0201a56:	06979563          	bne	a5,s1,ffffffffc0201ac0 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0201a5a:	401c                	lw	a5,0(s0)
ffffffffc0201a5c:	472d                	li	a4,11
ffffffffc0201a5e:	2781                	sext.w	a5,a5
ffffffffc0201a60:	04e79063          	bne	a5,a4,ffffffffc0201aa0 <_fifo_check_swap+0x1ac>
}
ffffffffc0201a64:	60e6                	ld	ra,88(sp)
ffffffffc0201a66:	6446                	ld	s0,80(sp)
ffffffffc0201a68:	64a6                	ld	s1,72(sp)
ffffffffc0201a6a:	6906                	ld	s2,64(sp)
ffffffffc0201a6c:	79e2                	ld	s3,56(sp)
ffffffffc0201a6e:	7a42                	ld	s4,48(sp)
ffffffffc0201a70:	7aa2                	ld	s5,40(sp)
ffffffffc0201a72:	7b02                	ld	s6,32(sp)
ffffffffc0201a74:	6be2                	ld	s7,24(sp)
ffffffffc0201a76:	6c42                	ld	s8,16(sp)
ffffffffc0201a78:	6ca2                	ld	s9,8(sp)
ffffffffc0201a7a:	4501                	li	a0,0
ffffffffc0201a7c:	6125                	addi	sp,sp,96
ffffffffc0201a7e:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0201a80:	00006697          	auipc	a3,0x6
ffffffffc0201a84:	93068693          	addi	a3,a3,-1744 # ffffffffc02073b0 <commands+0xc78>
ffffffffc0201a88:	00005617          	auipc	a2,0x5
ffffffffc0201a8c:	13060613          	addi	a2,a2,304 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201a90:	05100593          	li	a1,81
ffffffffc0201a94:	00006517          	auipc	a0,0x6
ffffffffc0201a98:	92c50513          	addi	a0,a0,-1748 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201a9c:	f7afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==11);
ffffffffc0201aa0:	00006697          	auipc	a3,0x6
ffffffffc0201aa4:	a6068693          	addi	a3,a3,-1440 # ffffffffc0207500 <commands+0xdc8>
ffffffffc0201aa8:	00005617          	auipc	a2,0x5
ffffffffc0201aac:	11060613          	addi	a2,a2,272 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201ab0:	07300593          	li	a1,115
ffffffffc0201ab4:	00006517          	auipc	a0,0x6
ffffffffc0201ab8:	90c50513          	addi	a0,a0,-1780 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201abc:	f5afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201ac0:	00006697          	auipc	a3,0x6
ffffffffc0201ac4:	a1868693          	addi	a3,a3,-1512 # ffffffffc02074d8 <commands+0xda0>
ffffffffc0201ac8:	00005617          	auipc	a2,0x5
ffffffffc0201acc:	0f060613          	addi	a2,a2,240 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201ad0:	07100593          	li	a1,113
ffffffffc0201ad4:	00006517          	auipc	a0,0x6
ffffffffc0201ad8:	8ec50513          	addi	a0,a0,-1812 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201adc:	f3afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==10);
ffffffffc0201ae0:	00006697          	auipc	a3,0x6
ffffffffc0201ae4:	9e868693          	addi	a3,a3,-1560 # ffffffffc02074c8 <commands+0xd90>
ffffffffc0201ae8:	00005617          	auipc	a2,0x5
ffffffffc0201aec:	0d060613          	addi	a2,a2,208 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201af0:	06f00593          	li	a1,111
ffffffffc0201af4:	00006517          	auipc	a0,0x6
ffffffffc0201af8:	8cc50513          	addi	a0,a0,-1844 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201afc:	f1afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==9);
ffffffffc0201b00:	00006697          	auipc	a3,0x6
ffffffffc0201b04:	9b868693          	addi	a3,a3,-1608 # ffffffffc02074b8 <commands+0xd80>
ffffffffc0201b08:	00005617          	auipc	a2,0x5
ffffffffc0201b0c:	0b060613          	addi	a2,a2,176 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201b10:	06c00593          	li	a1,108
ffffffffc0201b14:	00006517          	auipc	a0,0x6
ffffffffc0201b18:	8ac50513          	addi	a0,a0,-1876 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201b1c:	efafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==8);
ffffffffc0201b20:	00006697          	auipc	a3,0x6
ffffffffc0201b24:	98868693          	addi	a3,a3,-1656 # ffffffffc02074a8 <commands+0xd70>
ffffffffc0201b28:	00005617          	auipc	a2,0x5
ffffffffc0201b2c:	09060613          	addi	a2,a2,144 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201b30:	06900593          	li	a1,105
ffffffffc0201b34:	00006517          	auipc	a0,0x6
ffffffffc0201b38:	88c50513          	addi	a0,a0,-1908 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201b3c:	edafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==7);
ffffffffc0201b40:	00006697          	auipc	a3,0x6
ffffffffc0201b44:	95868693          	addi	a3,a3,-1704 # ffffffffc0207498 <commands+0xd60>
ffffffffc0201b48:	00005617          	auipc	a2,0x5
ffffffffc0201b4c:	07060613          	addi	a2,a2,112 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201b50:	06600593          	li	a1,102
ffffffffc0201b54:	00006517          	auipc	a0,0x6
ffffffffc0201b58:	86c50513          	addi	a0,a0,-1940 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201b5c:	ebafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==6);
ffffffffc0201b60:	00006697          	auipc	a3,0x6
ffffffffc0201b64:	92868693          	addi	a3,a3,-1752 # ffffffffc0207488 <commands+0xd50>
ffffffffc0201b68:	00005617          	auipc	a2,0x5
ffffffffc0201b6c:	05060613          	addi	a2,a2,80 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201b70:	06300593          	li	a1,99
ffffffffc0201b74:	00006517          	auipc	a0,0x6
ffffffffc0201b78:	84c50513          	addi	a0,a0,-1972 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201b7c:	e9afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==5);
ffffffffc0201b80:	00006697          	auipc	a3,0x6
ffffffffc0201b84:	8f868693          	addi	a3,a3,-1800 # ffffffffc0207478 <commands+0xd40>
ffffffffc0201b88:	00005617          	auipc	a2,0x5
ffffffffc0201b8c:	03060613          	addi	a2,a2,48 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201b90:	06000593          	li	a1,96
ffffffffc0201b94:	00006517          	auipc	a0,0x6
ffffffffc0201b98:	82c50513          	addi	a0,a0,-2004 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201b9c:	e7afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==5);
ffffffffc0201ba0:	00006697          	auipc	a3,0x6
ffffffffc0201ba4:	8d868693          	addi	a3,a3,-1832 # ffffffffc0207478 <commands+0xd40>
ffffffffc0201ba8:	00005617          	auipc	a2,0x5
ffffffffc0201bac:	01060613          	addi	a2,a2,16 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201bb0:	05d00593          	li	a1,93
ffffffffc0201bb4:	00006517          	auipc	a0,0x6
ffffffffc0201bb8:	80c50513          	addi	a0,a0,-2036 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201bbc:	e5afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc0201bc0:	00005697          	auipc	a3,0x5
ffffffffc0201bc4:	7f068693          	addi	a3,a3,2032 # ffffffffc02073b0 <commands+0xc78>
ffffffffc0201bc8:	00005617          	auipc	a2,0x5
ffffffffc0201bcc:	ff060613          	addi	a2,a2,-16 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201bd0:	05a00593          	li	a1,90
ffffffffc0201bd4:	00005517          	auipc	a0,0x5
ffffffffc0201bd8:	7ec50513          	addi	a0,a0,2028 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201bdc:	e3afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc0201be0:	00005697          	auipc	a3,0x5
ffffffffc0201be4:	7d068693          	addi	a3,a3,2000 # ffffffffc02073b0 <commands+0xc78>
ffffffffc0201be8:	00005617          	auipc	a2,0x5
ffffffffc0201bec:	fd060613          	addi	a2,a2,-48 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201bf0:	05700593          	li	a1,87
ffffffffc0201bf4:	00005517          	auipc	a0,0x5
ffffffffc0201bf8:	7cc50513          	addi	a0,a0,1996 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201bfc:	e1afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc0201c00:	00005697          	auipc	a3,0x5
ffffffffc0201c04:	7b068693          	addi	a3,a3,1968 # ffffffffc02073b0 <commands+0xc78>
ffffffffc0201c08:	00005617          	auipc	a2,0x5
ffffffffc0201c0c:	fb060613          	addi	a2,a2,-80 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201c10:	05400593          	li	a1,84
ffffffffc0201c14:	00005517          	auipc	a0,0x5
ffffffffc0201c18:	7ac50513          	addi	a0,a0,1964 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201c1c:	dfafe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201c20 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201c20:	751c                	ld	a5,40(a0)
{
ffffffffc0201c22:	1141                	addi	sp,sp,-16
ffffffffc0201c24:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0201c26:	cf91                	beqz	a5,ffffffffc0201c42 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0201c28:	ee0d                	bnez	a2,ffffffffc0201c62 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0201c2a:	679c                	ld	a5,8(a5)
}
ffffffffc0201c2c:	60a2                	ld	ra,8(sp)
ffffffffc0201c2e:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0201c30:	6394                	ld	a3,0(a5)
ffffffffc0201c32:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201c34:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0201c38:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0201c3a:	e314                	sd	a3,0(a4)
ffffffffc0201c3c:	e19c                	sd	a5,0(a1)
}
ffffffffc0201c3e:	0141                	addi	sp,sp,16
ffffffffc0201c40:	8082                	ret
         assert(head != NULL);
ffffffffc0201c42:	00006697          	auipc	a3,0x6
ffffffffc0201c46:	8ee68693          	addi	a3,a3,-1810 # ffffffffc0207530 <commands+0xdf8>
ffffffffc0201c4a:	00005617          	auipc	a2,0x5
ffffffffc0201c4e:	f6e60613          	addi	a2,a2,-146 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201c52:	04100593          	li	a1,65
ffffffffc0201c56:	00005517          	auipc	a0,0x5
ffffffffc0201c5a:	76a50513          	addi	a0,a0,1898 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201c5e:	db8fe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(in_tick==0);
ffffffffc0201c62:	00006697          	auipc	a3,0x6
ffffffffc0201c66:	8de68693          	addi	a3,a3,-1826 # ffffffffc0207540 <commands+0xe08>
ffffffffc0201c6a:	00005617          	auipc	a2,0x5
ffffffffc0201c6e:	f4e60613          	addi	a2,a2,-178 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201c72:	04200593          	li	a1,66
ffffffffc0201c76:	00005517          	auipc	a0,0x5
ffffffffc0201c7a:	74a50513          	addi	a0,a0,1866 # ffffffffc02073c0 <commands+0xc88>
ffffffffc0201c7e:	d98fe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201c82 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0201c82:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201c86:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0201c88:	cb09                	beqz	a4,ffffffffc0201c9a <_fifo_map_swappable+0x18>
ffffffffc0201c8a:	cb81                	beqz	a5,ffffffffc0201c9a <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201c8c:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201c8e:	e398                	sd	a4,0(a5)
}
ffffffffc0201c90:	4501                	li	a0,0
ffffffffc0201c92:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0201c94:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0201c96:	f614                	sd	a3,40(a2)
ffffffffc0201c98:	8082                	ret
{
ffffffffc0201c9a:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0201c9c:	00006697          	auipc	a3,0x6
ffffffffc0201ca0:	87468693          	addi	a3,a3,-1932 # ffffffffc0207510 <commands+0xdd8>
ffffffffc0201ca4:	00005617          	auipc	a2,0x5
ffffffffc0201ca8:	f1460613          	addi	a2,a2,-236 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201cac:	03200593          	li	a1,50
ffffffffc0201cb0:	00005517          	auipc	a0,0x5
ffffffffc0201cb4:	71050513          	addi	a0,a0,1808 # ffffffffc02073c0 <commands+0xc88>
{
ffffffffc0201cb8:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0201cba:	d5cfe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201cbe <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201cbe:	c125                	beqz	a0,ffffffffc0201d1e <slob_free+0x60>
		return;

	if (size)
ffffffffc0201cc0:	e1a5                	bnez	a1,ffffffffc0201d20 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201cc2:	100027f3          	csrr	a5,sstatus
ffffffffc0201cc6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201cc8:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201cca:	e3bd                	bnez	a5,ffffffffc0201d30 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201ccc:	0009f797          	auipc	a5,0x9f
ffffffffc0201cd0:	27478793          	addi	a5,a5,628 # ffffffffc02a0f40 <slobfree>
ffffffffc0201cd4:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201cd6:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201cd8:	00a7fa63          	bleu	a0,a5,ffffffffc0201cec <slob_free+0x2e>
ffffffffc0201cdc:	00e56c63          	bltu	a0,a4,ffffffffc0201cf4 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201ce0:	00e7fa63          	bleu	a4,a5,ffffffffc0201cf4 <slob_free+0x36>
    return 0;
ffffffffc0201ce4:	87ba                	mv	a5,a4
ffffffffc0201ce6:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201ce8:	fea7eae3          	bltu	a5,a0,ffffffffc0201cdc <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201cec:	fee7ece3          	bltu	a5,a4,ffffffffc0201ce4 <slob_free+0x26>
ffffffffc0201cf0:	fee57ae3          	bleu	a4,a0,ffffffffc0201ce4 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201cf4:	4110                	lw	a2,0(a0)
ffffffffc0201cf6:	00461693          	slli	a3,a2,0x4
ffffffffc0201cfa:	96aa                	add	a3,a3,a0
ffffffffc0201cfc:	08d70b63          	beq	a4,a3,ffffffffc0201d92 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201d00:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0201d02:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201d04:	00469713          	slli	a4,a3,0x4
ffffffffc0201d08:	973e                	add	a4,a4,a5
ffffffffc0201d0a:	08e50f63          	beq	a0,a4,ffffffffc0201da8 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201d0e:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0201d10:	0009f717          	auipc	a4,0x9f
ffffffffc0201d14:	22f73823          	sd	a5,560(a4) # ffffffffc02a0f40 <slobfree>
    if (flag) {
ffffffffc0201d18:	c199                	beqz	a1,ffffffffc0201d1e <slob_free+0x60>
        intr_enable();
ffffffffc0201d1a:	93dfe06f          	j	ffffffffc0200656 <intr_enable>
ffffffffc0201d1e:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0201d20:	05bd                	addi	a1,a1,15
ffffffffc0201d22:	8191                	srli	a1,a1,0x4
ffffffffc0201d24:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d26:	100027f3          	csrr	a5,sstatus
ffffffffc0201d2a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201d2c:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d2e:	dfd9                	beqz	a5,ffffffffc0201ccc <slob_free+0xe>
{
ffffffffc0201d30:	1101                	addi	sp,sp,-32
ffffffffc0201d32:	e42a                	sd	a0,8(sp)
ffffffffc0201d34:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201d36:	927fe0ef          	jal	ra,ffffffffc020065c <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201d3a:	0009f797          	auipc	a5,0x9f
ffffffffc0201d3e:	20678793          	addi	a5,a5,518 # ffffffffc02a0f40 <slobfree>
ffffffffc0201d42:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201d44:	6522                	ld	a0,8(sp)
ffffffffc0201d46:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201d48:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201d4a:	00a7fa63          	bleu	a0,a5,ffffffffc0201d5e <slob_free+0xa0>
ffffffffc0201d4e:	00e56c63          	bltu	a0,a4,ffffffffc0201d66 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201d52:	00e7fa63          	bleu	a4,a5,ffffffffc0201d66 <slob_free+0xa8>
    return 0;
ffffffffc0201d56:	87ba                	mv	a5,a4
ffffffffc0201d58:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201d5a:	fea7eae3          	bltu	a5,a0,ffffffffc0201d4e <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201d5e:	fee7ece3          	bltu	a5,a4,ffffffffc0201d56 <slob_free+0x98>
ffffffffc0201d62:	fee57ae3          	bleu	a4,a0,ffffffffc0201d56 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201d66:	4110                	lw	a2,0(a0)
ffffffffc0201d68:	00461693          	slli	a3,a2,0x4
ffffffffc0201d6c:	96aa                	add	a3,a3,a0
ffffffffc0201d6e:	04d70763          	beq	a4,a3,ffffffffc0201dbc <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201d72:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201d74:	4394                	lw	a3,0(a5)
ffffffffc0201d76:	00469713          	slli	a4,a3,0x4
ffffffffc0201d7a:	973e                	add	a4,a4,a5
ffffffffc0201d7c:	04e50663          	beq	a0,a4,ffffffffc0201dc8 <slob_free+0x10a>
		cur->next = b;
ffffffffc0201d80:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201d82:	0009f717          	auipc	a4,0x9f
ffffffffc0201d86:	1af73f23          	sd	a5,446(a4) # ffffffffc02a0f40 <slobfree>
    if (flag) {
ffffffffc0201d8a:	e58d                	bnez	a1,ffffffffc0201db4 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201d8c:	60e2                	ld	ra,24(sp)
ffffffffc0201d8e:	6105                	addi	sp,sp,32
ffffffffc0201d90:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201d92:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201d94:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201d96:	9e35                	addw	a2,a2,a3
ffffffffc0201d98:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201d9a:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201d9c:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201d9e:	00469713          	slli	a4,a3,0x4
ffffffffc0201da2:	973e                	add	a4,a4,a5
ffffffffc0201da4:	f6e515e3          	bne	a0,a4,ffffffffc0201d0e <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201da8:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201daa:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201dac:	9eb9                	addw	a3,a3,a4
ffffffffc0201dae:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201db0:	e790                	sd	a2,8(a5)
ffffffffc0201db2:	bfb9                	j	ffffffffc0201d10 <slob_free+0x52>
}
ffffffffc0201db4:	60e2                	ld	ra,24(sp)
ffffffffc0201db6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201db8:	89ffe06f          	j	ffffffffc0200656 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201dbc:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201dbe:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201dc0:	9e35                	addw	a2,a2,a3
ffffffffc0201dc2:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201dc4:	e518                	sd	a4,8(a0)
ffffffffc0201dc6:	b77d                	j	ffffffffc0201d74 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201dc8:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201dca:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201dcc:	9eb9                	addw	a3,a3,a4
ffffffffc0201dce:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201dd0:	e790                	sd	a2,8(a5)
ffffffffc0201dd2:	bf45                	j	ffffffffc0201d82 <slob_free+0xc4>

ffffffffc0201dd4 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201dd4:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201dd6:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201dd8:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ddc:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201dde:	00b010ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
  if(!page)
ffffffffc0201de2:	c139                	beqz	a0,ffffffffc0201e28 <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201de4:	000aa797          	auipc	a5,0xaa
ffffffffc0201de8:	6e478793          	addi	a5,a5,1764 # ffffffffc02ac4c8 <pages>
ffffffffc0201dec:	6394                	ld	a3,0(a5)
ffffffffc0201dee:	00007797          	auipc	a5,0x7
ffffffffc0201df2:	ea278793          	addi	a5,a5,-350 # ffffffffc0208c90 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201df6:	000aa717          	auipc	a4,0xaa
ffffffffc0201dfa:	59270713          	addi	a4,a4,1426 # ffffffffc02ac388 <npage>
    return page - pages + nbase;
ffffffffc0201dfe:	40d506b3          	sub	a3,a0,a3
ffffffffc0201e02:	6388                	ld	a0,0(a5)
ffffffffc0201e04:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201e06:	57fd                	li	a5,-1
ffffffffc0201e08:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201e0a:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201e0c:	83b1                	srli	a5,a5,0xc
ffffffffc0201e0e:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e10:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201e12:	00e7ff63          	bleu	a4,a5,ffffffffc0201e30 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201e16:	000aa797          	auipc	a5,0xaa
ffffffffc0201e1a:	6a278793          	addi	a5,a5,1698 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc0201e1e:	6388                	ld	a0,0(a5)
}
ffffffffc0201e20:	60a2                	ld	ra,8(sp)
ffffffffc0201e22:	9536                	add	a0,a0,a3
ffffffffc0201e24:	0141                	addi	sp,sp,16
ffffffffc0201e26:	8082                	ret
ffffffffc0201e28:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201e2a:	4501                	li	a0,0
}
ffffffffc0201e2c:	0141                	addi	sp,sp,16
ffffffffc0201e2e:	8082                	ret
ffffffffc0201e30:	00005617          	auipc	a2,0x5
ffffffffc0201e34:	4c060613          	addi	a2,a2,1216 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc0201e38:	06900593          	li	a1,105
ffffffffc0201e3c:	00005517          	auipc	a0,0x5
ffffffffc0201e40:	4a450513          	addi	a0,a0,1188 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0201e44:	bd2fe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201e48 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201e48:	7179                	addi	sp,sp,-48
ffffffffc0201e4a:	f406                	sd	ra,40(sp)
ffffffffc0201e4c:	f022                	sd	s0,32(sp)
ffffffffc0201e4e:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201e50:	01050713          	addi	a4,a0,16
ffffffffc0201e54:	6785                	lui	a5,0x1
ffffffffc0201e56:	0cf77b63          	bleu	a5,a4,ffffffffc0201f2c <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201e5a:	00f50413          	addi	s0,a0,15
ffffffffc0201e5e:	8011                	srli	s0,s0,0x4
ffffffffc0201e60:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e62:	10002673          	csrr	a2,sstatus
ffffffffc0201e66:	8a09                	andi	a2,a2,2
ffffffffc0201e68:	ea5d                	bnez	a2,ffffffffc0201f1e <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201e6a:	0009f497          	auipc	s1,0x9f
ffffffffc0201e6e:	0d648493          	addi	s1,s1,214 # ffffffffc02a0f40 <slobfree>
ffffffffc0201e72:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201e74:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201e76:	4398                	lw	a4,0(a5)
ffffffffc0201e78:	0a875763          	ble	s0,a4,ffffffffc0201f26 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201e7c:	00f68a63          	beq	a3,a5,ffffffffc0201e90 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201e80:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201e82:	4118                	lw	a4,0(a0)
ffffffffc0201e84:	02875763          	ble	s0,a4,ffffffffc0201eb2 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201e88:	6094                	ld	a3,0(s1)
ffffffffc0201e8a:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201e8c:	fef69ae3          	bne	a3,a5,ffffffffc0201e80 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0201e90:	ea39                	bnez	a2,ffffffffc0201ee6 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201e92:	4501                	li	a0,0
ffffffffc0201e94:	f41ff0ef          	jal	ra,ffffffffc0201dd4 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201e98:	cd29                	beqz	a0,ffffffffc0201ef2 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201e9a:	6585                	lui	a1,0x1
ffffffffc0201e9c:	e23ff0ef          	jal	ra,ffffffffc0201cbe <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ea0:	10002673          	csrr	a2,sstatus
ffffffffc0201ea4:	8a09                	andi	a2,a2,2
ffffffffc0201ea6:	ea1d                	bnez	a2,ffffffffc0201edc <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201ea8:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201eaa:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201eac:	4118                	lw	a4,0(a0)
ffffffffc0201eae:	fc874de3          	blt	a4,s0,ffffffffc0201e88 <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0201eb2:	04e40663          	beq	s0,a4,ffffffffc0201efe <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201eb6:	00441693          	slli	a3,s0,0x4
ffffffffc0201eba:	96aa                	add	a3,a3,a0
ffffffffc0201ebc:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201ebe:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201ec0:	9f01                	subw	a4,a4,s0
ffffffffc0201ec2:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201ec4:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201ec6:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0201ec8:	0009f717          	auipc	a4,0x9f
ffffffffc0201ecc:	06f73c23          	sd	a5,120(a4) # ffffffffc02a0f40 <slobfree>
    if (flag) {
ffffffffc0201ed0:	ee15                	bnez	a2,ffffffffc0201f0c <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201ed2:	70a2                	ld	ra,40(sp)
ffffffffc0201ed4:	7402                	ld	s0,32(sp)
ffffffffc0201ed6:	64e2                	ld	s1,24(sp)
ffffffffc0201ed8:	6145                	addi	sp,sp,48
ffffffffc0201eda:	8082                	ret
        intr_disable();
ffffffffc0201edc:	f80fe0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0201ee0:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201ee2:	609c                	ld	a5,0(s1)
ffffffffc0201ee4:	b7d9                	j	ffffffffc0201eaa <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201ee6:	f70fe0ef          	jal	ra,ffffffffc0200656 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201eea:	4501                	li	a0,0
ffffffffc0201eec:	ee9ff0ef          	jal	ra,ffffffffc0201dd4 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201ef0:	f54d                	bnez	a0,ffffffffc0201e9a <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201ef2:	70a2                	ld	ra,40(sp)
ffffffffc0201ef4:	7402                	ld	s0,32(sp)
ffffffffc0201ef6:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201ef8:	4501                	li	a0,0
}
ffffffffc0201efa:	6145                	addi	sp,sp,48
ffffffffc0201efc:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201efe:	6518                	ld	a4,8(a0)
ffffffffc0201f00:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0201f02:	0009f717          	auipc	a4,0x9f
ffffffffc0201f06:	02f73f23          	sd	a5,62(a4) # ffffffffc02a0f40 <slobfree>
    if (flag) {
ffffffffc0201f0a:	d661                	beqz	a2,ffffffffc0201ed2 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201f0c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201f0e:	f48fe0ef          	jal	ra,ffffffffc0200656 <intr_enable>
}
ffffffffc0201f12:	70a2                	ld	ra,40(sp)
ffffffffc0201f14:	7402                	ld	s0,32(sp)
ffffffffc0201f16:	6522                	ld	a0,8(sp)
ffffffffc0201f18:	64e2                	ld	s1,24(sp)
ffffffffc0201f1a:	6145                	addi	sp,sp,48
ffffffffc0201f1c:	8082                	ret
        intr_disable();
ffffffffc0201f1e:	f3efe0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0201f22:	4605                	li	a2,1
ffffffffc0201f24:	b799                	j	ffffffffc0201e6a <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201f26:	853e                	mv	a0,a5
ffffffffc0201f28:	87b6                	mv	a5,a3
ffffffffc0201f2a:	b761                	j	ffffffffc0201eb2 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201f2c:	00005697          	auipc	a3,0x5
ffffffffc0201f30:	68468693          	addi	a3,a3,1668 # ffffffffc02075b0 <commands+0xe78>
ffffffffc0201f34:	00005617          	auipc	a2,0x5
ffffffffc0201f38:	c8460613          	addi	a2,a2,-892 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0201f3c:	06400593          	li	a1,100
ffffffffc0201f40:	00005517          	auipc	a0,0x5
ffffffffc0201f44:	69050513          	addi	a0,a0,1680 # ffffffffc02075d0 <commands+0xe98>
ffffffffc0201f48:	acefe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201f4c <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201f4c:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201f4e:	00005517          	auipc	a0,0x5
ffffffffc0201f52:	69a50513          	addi	a0,a0,1690 # ffffffffc02075e8 <commands+0xeb0>
kmalloc_init(void) {
ffffffffc0201f56:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201f58:	978fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201f5c:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201f5e:	00005517          	auipc	a0,0x5
ffffffffc0201f62:	63250513          	addi	a0,a0,1586 # ffffffffc0207590 <commands+0xe58>
}
ffffffffc0201f66:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201f68:	968fe06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0201f6c <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201f6c:	4501                	li	a0,0
ffffffffc0201f6e:	8082                	ret

ffffffffc0201f70 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201f70:	1101                	addi	sp,sp,-32
ffffffffc0201f72:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201f74:	6905                	lui	s2,0x1
{
ffffffffc0201f76:	e822                	sd	s0,16(sp)
ffffffffc0201f78:	ec06                	sd	ra,24(sp)
ffffffffc0201f7a:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201f7c:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8579>
{
ffffffffc0201f80:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201f82:	04a7fc63          	bleu	a0,a5,ffffffffc0201fda <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201f86:	4561                	li	a0,24
ffffffffc0201f88:	ec1ff0ef          	jal	ra,ffffffffc0201e48 <slob_alloc.isra.1.constprop.3>
ffffffffc0201f8c:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201f8e:	cd21                	beqz	a0,ffffffffc0201fe6 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201f90:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201f94:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201f96:	00f95763          	ble	a5,s2,ffffffffc0201fa4 <kmalloc+0x34>
ffffffffc0201f9a:	6705                	lui	a4,0x1
ffffffffc0201f9c:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201f9e:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201fa0:	fef74ee3          	blt	a4,a5,ffffffffc0201f9c <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201fa4:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201fa6:	e2fff0ef          	jal	ra,ffffffffc0201dd4 <__slob_get_free_pages.isra.0>
ffffffffc0201faa:	e488                	sd	a0,8(s1)
ffffffffc0201fac:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201fae:	c935                	beqz	a0,ffffffffc0202022 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201fb0:	100027f3          	csrr	a5,sstatus
ffffffffc0201fb4:	8b89                	andi	a5,a5,2
ffffffffc0201fb6:	e3a1                	bnez	a5,ffffffffc0201ff6 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201fb8:	000aa797          	auipc	a5,0xaa
ffffffffc0201fbc:	3b078793          	addi	a5,a5,944 # ffffffffc02ac368 <bigblocks>
ffffffffc0201fc0:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201fc2:	000aa717          	auipc	a4,0xaa
ffffffffc0201fc6:	3a973323          	sd	s1,934(a4) # ffffffffc02ac368 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201fca:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201fcc:	8522                	mv	a0,s0
ffffffffc0201fce:	60e2                	ld	ra,24(sp)
ffffffffc0201fd0:	6442                	ld	s0,16(sp)
ffffffffc0201fd2:	64a2                	ld	s1,8(sp)
ffffffffc0201fd4:	6902                	ld	s2,0(sp)
ffffffffc0201fd6:	6105                	addi	sp,sp,32
ffffffffc0201fd8:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201fda:	0541                	addi	a0,a0,16
ffffffffc0201fdc:	e6dff0ef          	jal	ra,ffffffffc0201e48 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201fe0:	01050413          	addi	s0,a0,16
ffffffffc0201fe4:	f565                	bnez	a0,ffffffffc0201fcc <kmalloc+0x5c>
ffffffffc0201fe6:	4401                	li	s0,0
}
ffffffffc0201fe8:	8522                	mv	a0,s0
ffffffffc0201fea:	60e2                	ld	ra,24(sp)
ffffffffc0201fec:	6442                	ld	s0,16(sp)
ffffffffc0201fee:	64a2                	ld	s1,8(sp)
ffffffffc0201ff0:	6902                	ld	s2,0(sp)
ffffffffc0201ff2:	6105                	addi	sp,sp,32
ffffffffc0201ff4:	8082                	ret
        intr_disable();
ffffffffc0201ff6:	e66fe0ef          	jal	ra,ffffffffc020065c <intr_disable>
		bb->next = bigblocks;
ffffffffc0201ffa:	000aa797          	auipc	a5,0xaa
ffffffffc0201ffe:	36e78793          	addi	a5,a5,878 # ffffffffc02ac368 <bigblocks>
ffffffffc0202002:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0202004:	000aa717          	auipc	a4,0xaa
ffffffffc0202008:	36973223          	sd	s1,868(a4) # ffffffffc02ac368 <bigblocks>
		bb->next = bigblocks;
ffffffffc020200c:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc020200e:	e48fe0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0202012:	6480                	ld	s0,8(s1)
}
ffffffffc0202014:	60e2                	ld	ra,24(sp)
ffffffffc0202016:	64a2                	ld	s1,8(sp)
ffffffffc0202018:	8522                	mv	a0,s0
ffffffffc020201a:	6442                	ld	s0,16(sp)
ffffffffc020201c:	6902                	ld	s2,0(sp)
ffffffffc020201e:	6105                	addi	sp,sp,32
ffffffffc0202020:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0202022:	45e1                	li	a1,24
ffffffffc0202024:	8526                	mv	a0,s1
ffffffffc0202026:	c99ff0ef          	jal	ra,ffffffffc0201cbe <slob_free>
  return __kmalloc(size, 0);
ffffffffc020202a:	b74d                	j	ffffffffc0201fcc <kmalloc+0x5c>

ffffffffc020202c <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc020202c:	c175                	beqz	a0,ffffffffc0202110 <kfree+0xe4>
{
ffffffffc020202e:	1101                	addi	sp,sp,-32
ffffffffc0202030:	e426                	sd	s1,8(sp)
ffffffffc0202032:	ec06                	sd	ra,24(sp)
ffffffffc0202034:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0202036:	03451793          	slli	a5,a0,0x34
ffffffffc020203a:	84aa                	mv	s1,a0
ffffffffc020203c:	eb8d                	bnez	a5,ffffffffc020206e <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020203e:	100027f3          	csrr	a5,sstatus
ffffffffc0202042:	8b89                	andi	a5,a5,2
ffffffffc0202044:	efc9                	bnez	a5,ffffffffc02020de <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202046:	000aa797          	auipc	a5,0xaa
ffffffffc020204a:	32278793          	addi	a5,a5,802 # ffffffffc02ac368 <bigblocks>
ffffffffc020204e:	6394                	ld	a3,0(a5)
ffffffffc0202050:	ce99                	beqz	a3,ffffffffc020206e <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0202052:	669c                	ld	a5,8(a3)
ffffffffc0202054:	6a80                	ld	s0,16(a3)
ffffffffc0202056:	0af50e63          	beq	a0,a5,ffffffffc0202112 <kfree+0xe6>
    return 0;
ffffffffc020205a:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020205c:	c801                	beqz	s0,ffffffffc020206c <kfree+0x40>
			if (bb->pages == block) {
ffffffffc020205e:	6418                	ld	a4,8(s0)
ffffffffc0202060:	681c                	ld	a5,16(s0)
ffffffffc0202062:	00970f63          	beq	a4,s1,ffffffffc0202080 <kfree+0x54>
ffffffffc0202066:	86a2                	mv	a3,s0
ffffffffc0202068:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020206a:	f875                	bnez	s0,ffffffffc020205e <kfree+0x32>
    if (flag) {
ffffffffc020206c:	e659                	bnez	a2,ffffffffc02020fa <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc020206e:	6442                	ld	s0,16(sp)
ffffffffc0202070:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202072:	ff048513          	addi	a0,s1,-16
}
ffffffffc0202076:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202078:	4581                	li	a1,0
}
ffffffffc020207a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020207c:	c43ff06f          	j	ffffffffc0201cbe <slob_free>
				*last = bb->next;
ffffffffc0202080:	ea9c                	sd	a5,16(a3)
ffffffffc0202082:	e641                	bnez	a2,ffffffffc020210a <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0202084:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0202088:	4018                	lw	a4,0(s0)
ffffffffc020208a:	08f4ea63          	bltu	s1,a5,ffffffffc020211e <kfree+0xf2>
ffffffffc020208e:	000aa797          	auipc	a5,0xaa
ffffffffc0202092:	42a78793          	addi	a5,a5,1066 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc0202096:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202098:	000aa797          	auipc	a5,0xaa
ffffffffc020209c:	2f078793          	addi	a5,a5,752 # ffffffffc02ac388 <npage>
ffffffffc02020a0:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02020a2:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc02020a4:	80b1                	srli	s1,s1,0xc
ffffffffc02020a6:	08f4f963          	bleu	a5,s1,ffffffffc0202138 <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc02020aa:	00007797          	auipc	a5,0x7
ffffffffc02020ae:	be678793          	addi	a5,a5,-1050 # ffffffffc0208c90 <nbase>
ffffffffc02020b2:	639c                	ld	a5,0(a5)
ffffffffc02020b4:	000aa697          	auipc	a3,0xaa
ffffffffc02020b8:	41468693          	addi	a3,a3,1044 # ffffffffc02ac4c8 <pages>
ffffffffc02020bc:	6288                	ld	a0,0(a3)
ffffffffc02020be:	8c9d                	sub	s1,s1,a5
ffffffffc02020c0:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc02020c2:	4585                	li	a1,1
ffffffffc02020c4:	9526                	add	a0,a0,s1
ffffffffc02020c6:	00e595bb          	sllw	a1,a1,a4
ffffffffc02020ca:	5a6010ef          	jal	ra,ffffffffc0203670 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02020ce:	8522                	mv	a0,s0
}
ffffffffc02020d0:	6442                	ld	s0,16(sp)
ffffffffc02020d2:	60e2                	ld	ra,24(sp)
ffffffffc02020d4:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02020d6:	45e1                	li	a1,24
}
ffffffffc02020d8:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02020da:	be5ff06f          	j	ffffffffc0201cbe <slob_free>
        intr_disable();
ffffffffc02020de:	d7efe0ef          	jal	ra,ffffffffc020065c <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02020e2:	000aa797          	auipc	a5,0xaa
ffffffffc02020e6:	28678793          	addi	a5,a5,646 # ffffffffc02ac368 <bigblocks>
ffffffffc02020ea:	6394                	ld	a3,0(a5)
ffffffffc02020ec:	c699                	beqz	a3,ffffffffc02020fa <kfree+0xce>
			if (bb->pages == block) {
ffffffffc02020ee:	669c                	ld	a5,8(a3)
ffffffffc02020f0:	6a80                	ld	s0,16(a3)
ffffffffc02020f2:	00f48763          	beq	s1,a5,ffffffffc0202100 <kfree+0xd4>
        return 1;
ffffffffc02020f6:	4605                	li	a2,1
ffffffffc02020f8:	b795                	j	ffffffffc020205c <kfree+0x30>
        intr_enable();
ffffffffc02020fa:	d5cfe0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc02020fe:	bf85                	j	ffffffffc020206e <kfree+0x42>
				*last = bb->next;
ffffffffc0202100:	000aa797          	auipc	a5,0xaa
ffffffffc0202104:	2687b423          	sd	s0,616(a5) # ffffffffc02ac368 <bigblocks>
ffffffffc0202108:	8436                	mv	s0,a3
ffffffffc020210a:	d4cfe0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc020210e:	bf9d                	j	ffffffffc0202084 <kfree+0x58>
ffffffffc0202110:	8082                	ret
ffffffffc0202112:	000aa797          	auipc	a5,0xaa
ffffffffc0202116:	2487bb23          	sd	s0,598(a5) # ffffffffc02ac368 <bigblocks>
ffffffffc020211a:	8436                	mv	s0,a3
ffffffffc020211c:	b7a5                	j	ffffffffc0202084 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc020211e:	86a6                	mv	a3,s1
ffffffffc0202120:	00005617          	auipc	a2,0x5
ffffffffc0202124:	44860613          	addi	a2,a2,1096 # ffffffffc0207568 <commands+0xe30>
ffffffffc0202128:	06e00593          	li	a1,110
ffffffffc020212c:	00005517          	auipc	a0,0x5
ffffffffc0202130:	1b450513          	addi	a0,a0,436 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0202134:	8e2fe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202138:	00005617          	auipc	a2,0x5
ffffffffc020213c:	18860613          	addi	a2,a2,392 # ffffffffc02072c0 <commands+0xb88>
ffffffffc0202140:	06200593          	li	a1,98
ffffffffc0202144:	00005517          	auipc	a0,0x5
ffffffffc0202148:	19c50513          	addi	a0,a0,412 # ffffffffc02072e0 <commands+0xba8>
ffffffffc020214c:	8cafe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202150 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202150:	7135                	addi	sp,sp,-160
ffffffffc0202152:	ed06                	sd	ra,152(sp)
ffffffffc0202154:	e922                	sd	s0,144(sp)
ffffffffc0202156:	e526                	sd	s1,136(sp)
ffffffffc0202158:	e14a                	sd	s2,128(sp)
ffffffffc020215a:	fcce                	sd	s3,120(sp)
ffffffffc020215c:	f8d2                	sd	s4,112(sp)
ffffffffc020215e:	f4d6                	sd	s5,104(sp)
ffffffffc0202160:	f0da                	sd	s6,96(sp)
ffffffffc0202162:	ecde                	sd	s7,88(sp)
ffffffffc0202164:	e8e2                	sd	s8,80(sp)
ffffffffc0202166:	e4e6                	sd	s9,72(sp)
ffffffffc0202168:	e0ea                	sd	s10,64(sp)
ffffffffc020216a:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc020216c:	19b020ef          	jal	ra,ffffffffc0204b06 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202170:	000aa797          	auipc	a5,0xaa
ffffffffc0202174:	2e878793          	addi	a5,a5,744 # ffffffffc02ac458 <max_swap_offset>
ffffffffc0202178:	6394                	ld	a3,0(a5)
ffffffffc020217a:	010007b7          	lui	a5,0x1000
ffffffffc020217e:	17e1                	addi	a5,a5,-8
ffffffffc0202180:	ff968713          	addi	a4,a3,-7
ffffffffc0202184:	4ae7ee63          	bltu	a5,a4,ffffffffc0202640 <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0202188:	0009f797          	auipc	a5,0x9f
ffffffffc020218c:	d6878793          	addi	a5,a5,-664 # ffffffffc02a0ef0 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202190:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202192:	000aa697          	auipc	a3,0xaa
ffffffffc0202196:	1cf6bf23          	sd	a5,478(a3) # ffffffffc02ac370 <sm>
     int r = sm->init();
ffffffffc020219a:	9702                	jalr	a4
ffffffffc020219c:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc020219e:	c10d                	beqz	a0,ffffffffc02021c0 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02021a0:	60ea                	ld	ra,152(sp)
ffffffffc02021a2:	644a                	ld	s0,144(sp)
ffffffffc02021a4:	8556                	mv	a0,s5
ffffffffc02021a6:	64aa                	ld	s1,136(sp)
ffffffffc02021a8:	690a                	ld	s2,128(sp)
ffffffffc02021aa:	79e6                	ld	s3,120(sp)
ffffffffc02021ac:	7a46                	ld	s4,112(sp)
ffffffffc02021ae:	7aa6                	ld	s5,104(sp)
ffffffffc02021b0:	7b06                	ld	s6,96(sp)
ffffffffc02021b2:	6be6                	ld	s7,88(sp)
ffffffffc02021b4:	6c46                	ld	s8,80(sp)
ffffffffc02021b6:	6ca6                	ld	s9,72(sp)
ffffffffc02021b8:	6d06                	ld	s10,64(sp)
ffffffffc02021ba:	7de2                	ld	s11,56(sp)
ffffffffc02021bc:	610d                	addi	sp,sp,160
ffffffffc02021be:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02021c0:	000aa797          	auipc	a5,0xaa
ffffffffc02021c4:	1b078793          	addi	a5,a5,432 # ffffffffc02ac370 <sm>
ffffffffc02021c8:	639c                	ld	a5,0(a5)
ffffffffc02021ca:	00005517          	auipc	a0,0x5
ffffffffc02021ce:	4b650513          	addi	a0,a0,1206 # ffffffffc0207680 <commands+0xf48>
    return listelm->next;
ffffffffc02021d2:	000aa417          	auipc	s0,0xaa
ffffffffc02021d6:	2c640413          	addi	s0,s0,710 # ffffffffc02ac498 <free_area>
ffffffffc02021da:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02021dc:	4785                	li	a5,1
ffffffffc02021de:	000aa717          	auipc	a4,0xaa
ffffffffc02021e2:	18f72d23          	sw	a5,410(a4) # ffffffffc02ac378 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02021e6:	eebfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02021ea:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02021ec:	36878e63          	beq	a5,s0,ffffffffc0202568 <swap_init+0x418>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02021f0:	ff07b703          	ld	a4,-16(a5)
ffffffffc02021f4:	8305                	srli	a4,a4,0x1
ffffffffc02021f6:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02021f8:	36070c63          	beqz	a4,ffffffffc0202570 <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc02021fc:	4481                	li	s1,0
ffffffffc02021fe:	4901                	li	s2,0
ffffffffc0202200:	a031                	j	ffffffffc020220c <swap_init+0xbc>
ffffffffc0202202:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202206:	8b09                	andi	a4,a4,2
ffffffffc0202208:	36070463          	beqz	a4,ffffffffc0202570 <swap_init+0x420>
        count ++, total += p->property;
ffffffffc020220c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202210:	679c                	ld	a5,8(a5)
ffffffffc0202212:	2905                	addiw	s2,s2,1
ffffffffc0202214:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202216:	fe8796e3          	bne	a5,s0,ffffffffc0202202 <swap_init+0xb2>
ffffffffc020221a:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc020221c:	49a010ef          	jal	ra,ffffffffc02036b6 <nr_free_pages>
ffffffffc0202220:	69351863          	bne	a0,s3,ffffffffc02028b0 <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202224:	8626                	mv	a2,s1
ffffffffc0202226:	85ca                	mv	a1,s2
ffffffffc0202228:	00005517          	auipc	a0,0x5
ffffffffc020222c:	4a050513          	addi	a0,a0,1184 # ffffffffc02076c8 <commands+0xf90>
ffffffffc0202230:	ea1fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202234:	c47fe0ef          	jal	ra,ffffffffc0200e7a <mm_create>
ffffffffc0202238:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc020223a:	60050b63          	beqz	a0,ffffffffc0202850 <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020223e:	000aa797          	auipc	a5,0xaa
ffffffffc0202242:	17a78793          	addi	a5,a5,378 # ffffffffc02ac3b8 <check_mm_struct>
ffffffffc0202246:	639c                	ld	a5,0(a5)
ffffffffc0202248:	62079463          	bnez	a5,ffffffffc0202870 <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020224c:	000aa797          	auipc	a5,0xaa
ffffffffc0202250:	13478793          	addi	a5,a5,308 # ffffffffc02ac380 <boot_pgdir>
ffffffffc0202254:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202258:	000aa797          	auipc	a5,0xaa
ffffffffc020225c:	16a7b023          	sd	a0,352(a5) # ffffffffc02ac3b8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202260:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202264:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202268:	4e079863          	bnez	a5,ffffffffc0202758 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc020226c:	6599                	lui	a1,0x6
ffffffffc020226e:	460d                	li	a2,3
ffffffffc0202270:	6505                	lui	a0,0x1
ffffffffc0202272:	c55fe0ef          	jal	ra,ffffffffc0200ec6 <vma_create>
ffffffffc0202276:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202278:	50050063          	beqz	a0,ffffffffc0202778 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc020227c:	855e                	mv	a0,s7
ffffffffc020227e:	cb5fe0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202282:	00005517          	auipc	a0,0x5
ffffffffc0202286:	48650513          	addi	a0,a0,1158 # ffffffffc0207708 <commands+0xfd0>
ffffffffc020228a:	e47fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc020228e:	018bb503          	ld	a0,24(s7)
ffffffffc0202292:	4605                	li	a2,1
ffffffffc0202294:	6585                	lui	a1,0x1
ffffffffc0202296:	460010ef          	jal	ra,ffffffffc02036f6 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc020229a:	4e050f63          	beqz	a0,ffffffffc0202798 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020229e:	00005517          	auipc	a0,0x5
ffffffffc02022a2:	4ba50513          	addi	a0,a0,1210 # ffffffffc0207758 <commands+0x1020>
ffffffffc02022a6:	000aa997          	auipc	s3,0xaa
ffffffffc02022aa:	12a98993          	addi	s3,s3,298 # ffffffffc02ac3d0 <check_rp>
ffffffffc02022ae:	e23fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02022b2:	000aaa17          	auipc	s4,0xaa
ffffffffc02022b6:	13ea0a13          	addi	s4,s4,318 # ffffffffc02ac3f0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02022ba:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02022bc:	4505                	li	a0,1
ffffffffc02022be:	32a010ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc02022c2:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02022c6:	32050d63          	beqz	a0,ffffffffc0202600 <swap_init+0x4b0>
ffffffffc02022ca:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02022cc:	8b89                	andi	a5,a5,2
ffffffffc02022ce:	30079963          	bnez	a5,ffffffffc02025e0 <swap_init+0x490>
ffffffffc02022d2:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02022d4:	ff4c14e3          	bne	s8,s4,ffffffffc02022bc <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02022d8:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02022da:	000aac17          	auipc	s8,0xaa
ffffffffc02022de:	0f6c0c13          	addi	s8,s8,246 # ffffffffc02ac3d0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02022e2:	ec3e                	sd	a5,24(sp)
ffffffffc02022e4:	641c                	ld	a5,8(s0)
ffffffffc02022e6:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02022e8:	481c                	lw	a5,16(s0)
ffffffffc02022ea:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02022ec:	000aa797          	auipc	a5,0xaa
ffffffffc02022f0:	1a87ba23          	sd	s0,436(a5) # ffffffffc02ac4a0 <free_area+0x8>
ffffffffc02022f4:	000aa797          	auipc	a5,0xaa
ffffffffc02022f8:	1a87b223          	sd	s0,420(a5) # ffffffffc02ac498 <free_area>
     nr_free = 0;
ffffffffc02022fc:	000aa797          	auipc	a5,0xaa
ffffffffc0202300:	1a07a623          	sw	zero,428(a5) # ffffffffc02ac4a8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202304:	000c3503          	ld	a0,0(s8)
ffffffffc0202308:	4585                	li	a1,1
ffffffffc020230a:	0c21                	addi	s8,s8,8
ffffffffc020230c:	364010ef          	jal	ra,ffffffffc0203670 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202310:	ff4c1ae3          	bne	s8,s4,ffffffffc0202304 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202314:	01042c03          	lw	s8,16(s0)
ffffffffc0202318:	4791                	li	a5,4
ffffffffc020231a:	50fc1b63          	bne	s8,a5,ffffffffc0202830 <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020231e:	00005517          	auipc	a0,0x5
ffffffffc0202322:	4c250513          	addi	a0,a0,1218 # ffffffffc02077e0 <commands+0x10a8>
ffffffffc0202326:	dabfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020232a:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020232c:	000aa797          	auipc	a5,0xaa
ffffffffc0202330:	0207aa23          	sw	zero,52(a5) # ffffffffc02ac360 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202334:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202336:	000aa797          	auipc	a5,0xaa
ffffffffc020233a:	02a78793          	addi	a5,a5,42 # ffffffffc02ac360 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020233e:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8568>
     assert(pgfault_num==1);
ffffffffc0202342:	4398                	lw	a4,0(a5)
ffffffffc0202344:	4585                	li	a1,1
ffffffffc0202346:	2701                	sext.w	a4,a4
ffffffffc0202348:	38b71863          	bne	a4,a1,ffffffffc02026d8 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020234c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202350:	4394                	lw	a3,0(a5)
ffffffffc0202352:	2681                	sext.w	a3,a3
ffffffffc0202354:	3ae69263          	bne	a3,a4,ffffffffc02026f8 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202358:	6689                	lui	a3,0x2
ffffffffc020235a:	462d                	li	a2,11
ffffffffc020235c:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7568>
     assert(pgfault_num==2);
ffffffffc0202360:	4398                	lw	a4,0(a5)
ffffffffc0202362:	4589                	li	a1,2
ffffffffc0202364:	2701                	sext.w	a4,a4
ffffffffc0202366:	2eb71963          	bne	a4,a1,ffffffffc0202658 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc020236a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020236e:	4394                	lw	a3,0(a5)
ffffffffc0202370:	2681                	sext.w	a3,a3
ffffffffc0202372:	30e69363          	bne	a3,a4,ffffffffc0202678 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202376:	668d                	lui	a3,0x3
ffffffffc0202378:	4631                	li	a2,12
ffffffffc020237a:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6568>
     assert(pgfault_num==3);
ffffffffc020237e:	4398                	lw	a4,0(a5)
ffffffffc0202380:	458d                	li	a1,3
ffffffffc0202382:	2701                	sext.w	a4,a4
ffffffffc0202384:	30b71a63          	bne	a4,a1,ffffffffc0202698 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202388:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc020238c:	4394                	lw	a3,0(a5)
ffffffffc020238e:	2681                	sext.w	a3,a3
ffffffffc0202390:	32e69463          	bne	a3,a4,ffffffffc02026b8 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202394:	6691                	lui	a3,0x4
ffffffffc0202396:	4635                	li	a2,13
ffffffffc0202398:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5568>
     assert(pgfault_num==4);
ffffffffc020239c:	4398                	lw	a4,0(a5)
ffffffffc020239e:	2701                	sext.w	a4,a4
ffffffffc02023a0:	37871c63          	bne	a4,s8,ffffffffc0202718 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02023a4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02023a8:	439c                	lw	a5,0(a5)
ffffffffc02023aa:	2781                	sext.w	a5,a5
ffffffffc02023ac:	38e79663          	bne	a5,a4,ffffffffc0202738 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02023b0:	481c                	lw	a5,16(s0)
ffffffffc02023b2:	40079363          	bnez	a5,ffffffffc02027b8 <swap_init+0x668>
ffffffffc02023b6:	000aa797          	auipc	a5,0xaa
ffffffffc02023ba:	03a78793          	addi	a5,a5,58 # ffffffffc02ac3f0 <swap_in_seq_no>
ffffffffc02023be:	000aa717          	auipc	a4,0xaa
ffffffffc02023c2:	05a70713          	addi	a4,a4,90 # ffffffffc02ac418 <swap_out_seq_no>
ffffffffc02023c6:	000aa617          	auipc	a2,0xaa
ffffffffc02023ca:	05260613          	addi	a2,a2,82 # ffffffffc02ac418 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02023ce:	56fd                	li	a3,-1
ffffffffc02023d0:	c394                	sw	a3,0(a5)
ffffffffc02023d2:	c314                	sw	a3,0(a4)
ffffffffc02023d4:	0791                	addi	a5,a5,4
ffffffffc02023d6:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02023d8:	fef61ce3          	bne	a2,a5,ffffffffc02023d0 <swap_init+0x280>
ffffffffc02023dc:	000aa697          	auipc	a3,0xaa
ffffffffc02023e0:	09c68693          	addi	a3,a3,156 # ffffffffc02ac478 <check_ptep>
ffffffffc02023e4:	000aa817          	auipc	a6,0xaa
ffffffffc02023e8:	fec80813          	addi	a6,a6,-20 # ffffffffc02ac3d0 <check_rp>
ffffffffc02023ec:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc02023ee:	000aac97          	auipc	s9,0xaa
ffffffffc02023f2:	f9ac8c93          	addi	s9,s9,-102 # ffffffffc02ac388 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02023f6:	00007d97          	auipc	s11,0x7
ffffffffc02023fa:	89ad8d93          	addi	s11,s11,-1894 # ffffffffc0208c90 <nbase>
ffffffffc02023fe:	000aac17          	auipc	s8,0xaa
ffffffffc0202402:	0cac0c13          	addi	s8,s8,202 # ffffffffc02ac4c8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202406:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020240a:	4601                	li	a2,0
ffffffffc020240c:	85ea                	mv	a1,s10
ffffffffc020240e:	855a                	mv	a0,s6
ffffffffc0202410:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202412:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202414:	2e2010ef          	jal	ra,ffffffffc02036f6 <get_pte>
ffffffffc0202418:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc020241a:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020241c:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc020241e:	20050163          	beqz	a0,ffffffffc0202620 <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202422:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202424:	0017f613          	andi	a2,a5,1
ffffffffc0202428:	1a060063          	beqz	a2,ffffffffc02025c8 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc020242c:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202430:	078a                	slli	a5,a5,0x2
ffffffffc0202432:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202434:	14c7fe63          	bleu	a2,a5,ffffffffc0202590 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0202438:	000db703          	ld	a4,0(s11)
ffffffffc020243c:	000c3603          	ld	a2,0(s8)
ffffffffc0202440:	00083583          	ld	a1,0(a6)
ffffffffc0202444:	8f99                	sub	a5,a5,a4
ffffffffc0202446:	079a                	slli	a5,a5,0x6
ffffffffc0202448:	e43a                	sd	a4,8(sp)
ffffffffc020244a:	97b2                	add	a5,a5,a2
ffffffffc020244c:	14f59e63          	bne	a1,a5,ffffffffc02025a8 <swap_init+0x458>
ffffffffc0202450:	6785                	lui	a5,0x1
ffffffffc0202452:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202454:	6795                	lui	a5,0x5
ffffffffc0202456:	06a1                	addi	a3,a3,8
ffffffffc0202458:	0821                	addi	a6,a6,8
ffffffffc020245a:	fafd16e3          	bne	s10,a5,ffffffffc0202406 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020245e:	00005517          	auipc	a0,0x5
ffffffffc0202462:	45250513          	addi	a0,a0,1106 # ffffffffc02078b0 <commands+0x1178>
ffffffffc0202466:	c6bfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc020246a:	000aa797          	auipc	a5,0xaa
ffffffffc020246e:	f0678793          	addi	a5,a5,-250 # ffffffffc02ac370 <sm>
ffffffffc0202472:	639c                	ld	a5,0(a5)
ffffffffc0202474:	7f9c                	ld	a5,56(a5)
ffffffffc0202476:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202478:	40051c63          	bnez	a0,ffffffffc0202890 <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc020247c:	77a2                	ld	a5,40(sp)
ffffffffc020247e:	000aa717          	auipc	a4,0xaa
ffffffffc0202482:	02f72523          	sw	a5,42(a4) # ffffffffc02ac4a8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202486:	67e2                	ld	a5,24(sp)
ffffffffc0202488:	000aa717          	auipc	a4,0xaa
ffffffffc020248c:	00f73823          	sd	a5,16(a4) # ffffffffc02ac498 <free_area>
ffffffffc0202490:	7782                	ld	a5,32(sp)
ffffffffc0202492:	000aa717          	auipc	a4,0xaa
ffffffffc0202496:	00f73723          	sd	a5,14(a4) # ffffffffc02ac4a0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc020249a:	0009b503          	ld	a0,0(s3)
ffffffffc020249e:	4585                	li	a1,1
ffffffffc02024a0:	09a1                	addi	s3,s3,8
ffffffffc02024a2:	1ce010ef          	jal	ra,ffffffffc0203670 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02024a6:	ff499ae3          	bne	s3,s4,ffffffffc020249a <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02024aa:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02024ae:	855e                	mv	a0,s7
ffffffffc02024b0:	b51fe0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02024b4:	000aa797          	auipc	a5,0xaa
ffffffffc02024b8:	ecc78793          	addi	a5,a5,-308 # ffffffffc02ac380 <boot_pgdir>
ffffffffc02024bc:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02024be:	000aa697          	auipc	a3,0xaa
ffffffffc02024c2:	ee06bd23          	sd	zero,-262(a3) # ffffffffc02ac3b8 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc02024c6:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024ca:	6394                	ld	a3,0(a5)
ffffffffc02024cc:	068a                	slli	a3,a3,0x2
ffffffffc02024ce:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024d0:	0ce6f063          	bleu	a4,a3,ffffffffc0202590 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02024d4:	67a2                	ld	a5,8(sp)
ffffffffc02024d6:	000c3503          	ld	a0,0(s8)
ffffffffc02024da:	8e9d                	sub	a3,a3,a5
ffffffffc02024dc:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02024de:	8699                	srai	a3,a3,0x6
ffffffffc02024e0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02024e2:	57fd                	li	a5,-1
ffffffffc02024e4:	83b1                	srli	a5,a5,0xc
ffffffffc02024e6:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02024e8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02024ea:	2ee7f763          	bleu	a4,a5,ffffffffc02027d8 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc02024ee:	000aa797          	auipc	a5,0xaa
ffffffffc02024f2:	fca78793          	addi	a5,a5,-54 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc02024f6:	639c                	ld	a5,0(a5)
ffffffffc02024f8:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02024fa:	629c                	ld	a5,0(a3)
ffffffffc02024fc:	078a                	slli	a5,a5,0x2
ffffffffc02024fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202500:	08e7f863          	bleu	a4,a5,ffffffffc0202590 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0202504:	69a2                	ld	s3,8(sp)
ffffffffc0202506:	4585                	li	a1,1
ffffffffc0202508:	413787b3          	sub	a5,a5,s3
ffffffffc020250c:	079a                	slli	a5,a5,0x6
ffffffffc020250e:	953e                	add	a0,a0,a5
ffffffffc0202510:	160010ef          	jal	ra,ffffffffc0203670 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202514:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202518:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc020251c:	078a                	slli	a5,a5,0x2
ffffffffc020251e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202520:	06e7f863          	bleu	a4,a5,ffffffffc0202590 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0202524:	000c3503          	ld	a0,0(s8)
ffffffffc0202528:	413787b3          	sub	a5,a5,s3
ffffffffc020252c:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020252e:	4585                	li	a1,1
ffffffffc0202530:	953e                	add	a0,a0,a5
ffffffffc0202532:	13e010ef          	jal	ra,ffffffffc0203670 <free_pages>
     pgdir[0] = 0;
ffffffffc0202536:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc020253a:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020253e:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202540:	00878963          	beq	a5,s0,ffffffffc0202552 <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202544:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202548:	679c                	ld	a5,8(a5)
ffffffffc020254a:	397d                	addiw	s2,s2,-1
ffffffffc020254c:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020254e:	fe879be3          	bne	a5,s0,ffffffffc0202544 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc0202552:	28091f63          	bnez	s2,ffffffffc02027f0 <swap_init+0x6a0>
     assert(total==0);
ffffffffc0202556:	2a049d63          	bnez	s1,ffffffffc0202810 <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc020255a:	00005517          	auipc	a0,0x5
ffffffffc020255e:	3a650513          	addi	a0,a0,934 # ffffffffc0207900 <commands+0x11c8>
ffffffffc0202562:	b6ffd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202566:	b92d                	j	ffffffffc02021a0 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202568:	4481                	li	s1,0
ffffffffc020256a:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc020256c:	4981                	li	s3,0
ffffffffc020256e:	b17d                	j	ffffffffc020221c <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202570:	00005697          	auipc	a3,0x5
ffffffffc0202574:	12868693          	addi	a3,a3,296 # ffffffffc0207698 <commands+0xf60>
ffffffffc0202578:	00004617          	auipc	a2,0x4
ffffffffc020257c:	64060613          	addi	a2,a2,1600 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202580:	0bc00593          	li	a1,188
ffffffffc0202584:	00005517          	auipc	a0,0x5
ffffffffc0202588:	0ec50513          	addi	a0,a0,236 # ffffffffc0207670 <commands+0xf38>
ffffffffc020258c:	c8bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202590:	00005617          	auipc	a2,0x5
ffffffffc0202594:	d3060613          	addi	a2,a2,-720 # ffffffffc02072c0 <commands+0xb88>
ffffffffc0202598:	06200593          	li	a1,98
ffffffffc020259c:	00005517          	auipc	a0,0x5
ffffffffc02025a0:	d4450513          	addi	a0,a0,-700 # ffffffffc02072e0 <commands+0xba8>
ffffffffc02025a4:	c73fd0ef          	jal	ra,ffffffffc0200216 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02025a8:	00005697          	auipc	a3,0x5
ffffffffc02025ac:	2e068693          	addi	a3,a3,736 # ffffffffc0207888 <commands+0x1150>
ffffffffc02025b0:	00004617          	auipc	a2,0x4
ffffffffc02025b4:	60860613          	addi	a2,a2,1544 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02025b8:	0fc00593          	li	a1,252
ffffffffc02025bc:	00005517          	auipc	a0,0x5
ffffffffc02025c0:	0b450513          	addi	a0,a0,180 # ffffffffc0207670 <commands+0xf38>
ffffffffc02025c4:	c53fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02025c8:	00005617          	auipc	a2,0x5
ffffffffc02025cc:	29860613          	addi	a2,a2,664 # ffffffffc0207860 <commands+0x1128>
ffffffffc02025d0:	07400593          	li	a1,116
ffffffffc02025d4:	00005517          	auipc	a0,0x5
ffffffffc02025d8:	d0c50513          	addi	a0,a0,-756 # ffffffffc02072e0 <commands+0xba8>
ffffffffc02025dc:	c3bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02025e0:	00005697          	auipc	a3,0x5
ffffffffc02025e4:	1b868693          	addi	a3,a3,440 # ffffffffc0207798 <commands+0x1060>
ffffffffc02025e8:	00004617          	auipc	a2,0x4
ffffffffc02025ec:	5d060613          	addi	a2,a2,1488 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02025f0:	0dd00593          	li	a1,221
ffffffffc02025f4:	00005517          	auipc	a0,0x5
ffffffffc02025f8:	07c50513          	addi	a0,a0,124 # ffffffffc0207670 <commands+0xf38>
ffffffffc02025fc:	c1bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202600:	00005697          	auipc	a3,0x5
ffffffffc0202604:	18068693          	addi	a3,a3,384 # ffffffffc0207780 <commands+0x1048>
ffffffffc0202608:	00004617          	auipc	a2,0x4
ffffffffc020260c:	5b060613          	addi	a2,a2,1456 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202610:	0dc00593          	li	a1,220
ffffffffc0202614:	00005517          	auipc	a0,0x5
ffffffffc0202618:	05c50513          	addi	a0,a0,92 # ffffffffc0207670 <commands+0xf38>
ffffffffc020261c:	bfbfd0ef          	jal	ra,ffffffffc0200216 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202620:	00005697          	auipc	a3,0x5
ffffffffc0202624:	22868693          	addi	a3,a3,552 # ffffffffc0207848 <commands+0x1110>
ffffffffc0202628:	00004617          	auipc	a2,0x4
ffffffffc020262c:	59060613          	addi	a2,a2,1424 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202630:	0fb00593          	li	a1,251
ffffffffc0202634:	00005517          	auipc	a0,0x5
ffffffffc0202638:	03c50513          	addi	a0,a0,60 # ffffffffc0207670 <commands+0xf38>
ffffffffc020263c:	bdbfd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202640:	00005617          	auipc	a2,0x5
ffffffffc0202644:	01060613          	addi	a2,a2,16 # ffffffffc0207650 <commands+0xf18>
ffffffffc0202648:	02800593          	li	a1,40
ffffffffc020264c:	00005517          	auipc	a0,0x5
ffffffffc0202650:	02450513          	addi	a0,a0,36 # ffffffffc0207670 <commands+0xf38>
ffffffffc0202654:	bc3fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==2);
ffffffffc0202658:	00005697          	auipc	a3,0x5
ffffffffc020265c:	1c068693          	addi	a3,a3,448 # ffffffffc0207818 <commands+0x10e0>
ffffffffc0202660:	00004617          	auipc	a2,0x4
ffffffffc0202664:	55860613          	addi	a2,a2,1368 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202668:	09700593          	li	a1,151
ffffffffc020266c:	00005517          	auipc	a0,0x5
ffffffffc0202670:	00450513          	addi	a0,a0,4 # ffffffffc0207670 <commands+0xf38>
ffffffffc0202674:	ba3fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==2);
ffffffffc0202678:	00005697          	auipc	a3,0x5
ffffffffc020267c:	1a068693          	addi	a3,a3,416 # ffffffffc0207818 <commands+0x10e0>
ffffffffc0202680:	00004617          	auipc	a2,0x4
ffffffffc0202684:	53860613          	addi	a2,a2,1336 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202688:	09900593          	li	a1,153
ffffffffc020268c:	00005517          	auipc	a0,0x5
ffffffffc0202690:	fe450513          	addi	a0,a0,-28 # ffffffffc0207670 <commands+0xf38>
ffffffffc0202694:	b83fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==3);
ffffffffc0202698:	00005697          	auipc	a3,0x5
ffffffffc020269c:	19068693          	addi	a3,a3,400 # ffffffffc0207828 <commands+0x10f0>
ffffffffc02026a0:	00004617          	auipc	a2,0x4
ffffffffc02026a4:	51860613          	addi	a2,a2,1304 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02026a8:	09b00593          	li	a1,155
ffffffffc02026ac:	00005517          	auipc	a0,0x5
ffffffffc02026b0:	fc450513          	addi	a0,a0,-60 # ffffffffc0207670 <commands+0xf38>
ffffffffc02026b4:	b63fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==3);
ffffffffc02026b8:	00005697          	auipc	a3,0x5
ffffffffc02026bc:	17068693          	addi	a3,a3,368 # ffffffffc0207828 <commands+0x10f0>
ffffffffc02026c0:	00004617          	auipc	a2,0x4
ffffffffc02026c4:	4f860613          	addi	a2,a2,1272 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02026c8:	09d00593          	li	a1,157
ffffffffc02026cc:	00005517          	auipc	a0,0x5
ffffffffc02026d0:	fa450513          	addi	a0,a0,-92 # ffffffffc0207670 <commands+0xf38>
ffffffffc02026d4:	b43fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==1);
ffffffffc02026d8:	00005697          	auipc	a3,0x5
ffffffffc02026dc:	13068693          	addi	a3,a3,304 # ffffffffc0207808 <commands+0x10d0>
ffffffffc02026e0:	00004617          	auipc	a2,0x4
ffffffffc02026e4:	4d860613          	addi	a2,a2,1240 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02026e8:	09300593          	li	a1,147
ffffffffc02026ec:	00005517          	auipc	a0,0x5
ffffffffc02026f0:	f8450513          	addi	a0,a0,-124 # ffffffffc0207670 <commands+0xf38>
ffffffffc02026f4:	b23fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==1);
ffffffffc02026f8:	00005697          	auipc	a3,0x5
ffffffffc02026fc:	11068693          	addi	a3,a3,272 # ffffffffc0207808 <commands+0x10d0>
ffffffffc0202700:	00004617          	auipc	a2,0x4
ffffffffc0202704:	4b860613          	addi	a2,a2,1208 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202708:	09500593          	li	a1,149
ffffffffc020270c:	00005517          	auipc	a0,0x5
ffffffffc0202710:	f6450513          	addi	a0,a0,-156 # ffffffffc0207670 <commands+0xf38>
ffffffffc0202714:	b03fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==4);
ffffffffc0202718:	00005697          	auipc	a3,0x5
ffffffffc020271c:	c9868693          	addi	a3,a3,-872 # ffffffffc02073b0 <commands+0xc78>
ffffffffc0202720:	00004617          	auipc	a2,0x4
ffffffffc0202724:	49860613          	addi	a2,a2,1176 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202728:	09f00593          	li	a1,159
ffffffffc020272c:	00005517          	auipc	a0,0x5
ffffffffc0202730:	f4450513          	addi	a0,a0,-188 # ffffffffc0207670 <commands+0xf38>
ffffffffc0202734:	ae3fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==4);
ffffffffc0202738:	00005697          	auipc	a3,0x5
ffffffffc020273c:	c7868693          	addi	a3,a3,-904 # ffffffffc02073b0 <commands+0xc78>
ffffffffc0202740:	00004617          	auipc	a2,0x4
ffffffffc0202744:	47860613          	addi	a2,a2,1144 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202748:	0a100593          	li	a1,161
ffffffffc020274c:	00005517          	auipc	a0,0x5
ffffffffc0202750:	f2450513          	addi	a0,a0,-220 # ffffffffc0207670 <commands+0xf38>
ffffffffc0202754:	ac3fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202758:	00005697          	auipc	a3,0x5
ffffffffc020275c:	b2868693          	addi	a3,a3,-1240 # ffffffffc0207280 <commands+0xb48>
ffffffffc0202760:	00004617          	auipc	a2,0x4
ffffffffc0202764:	45860613          	addi	a2,a2,1112 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202768:	0cc00593          	li	a1,204
ffffffffc020276c:	00005517          	auipc	a0,0x5
ffffffffc0202770:	f0450513          	addi	a0,a0,-252 # ffffffffc0207670 <commands+0xf38>
ffffffffc0202774:	aa3fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(vma != NULL);
ffffffffc0202778:	00005697          	auipc	a3,0x5
ffffffffc020277c:	c0068693          	addi	a3,a3,-1024 # ffffffffc0207378 <commands+0xc40>
ffffffffc0202780:	00004617          	auipc	a2,0x4
ffffffffc0202784:	43860613          	addi	a2,a2,1080 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202788:	0cf00593          	li	a1,207
ffffffffc020278c:	00005517          	auipc	a0,0x5
ffffffffc0202790:	ee450513          	addi	a0,a0,-284 # ffffffffc0207670 <commands+0xf38>
ffffffffc0202794:	a83fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202798:	00005697          	auipc	a3,0x5
ffffffffc020279c:	fa868693          	addi	a3,a3,-88 # ffffffffc0207740 <commands+0x1008>
ffffffffc02027a0:	00004617          	auipc	a2,0x4
ffffffffc02027a4:	41860613          	addi	a2,a2,1048 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02027a8:	0d700593          	li	a1,215
ffffffffc02027ac:	00005517          	auipc	a0,0x5
ffffffffc02027b0:	ec450513          	addi	a0,a0,-316 # ffffffffc0207670 <commands+0xf38>
ffffffffc02027b4:	a63fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert( nr_free == 0);         
ffffffffc02027b8:	00005697          	auipc	a3,0x5
ffffffffc02027bc:	08068693          	addi	a3,a3,128 # ffffffffc0207838 <commands+0x1100>
ffffffffc02027c0:	00004617          	auipc	a2,0x4
ffffffffc02027c4:	3f860613          	addi	a2,a2,1016 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02027c8:	0f300593          	li	a1,243
ffffffffc02027cc:	00005517          	auipc	a0,0x5
ffffffffc02027d0:	ea450513          	addi	a0,a0,-348 # ffffffffc0207670 <commands+0xf38>
ffffffffc02027d4:	a43fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc02027d8:	00005617          	auipc	a2,0x5
ffffffffc02027dc:	b1860613          	addi	a2,a2,-1256 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc02027e0:	06900593          	li	a1,105
ffffffffc02027e4:	00005517          	auipc	a0,0x5
ffffffffc02027e8:	afc50513          	addi	a0,a0,-1284 # ffffffffc02072e0 <commands+0xba8>
ffffffffc02027ec:	a2bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(count==0);
ffffffffc02027f0:	00005697          	auipc	a3,0x5
ffffffffc02027f4:	0f068693          	addi	a3,a3,240 # ffffffffc02078e0 <commands+0x11a8>
ffffffffc02027f8:	00004617          	auipc	a2,0x4
ffffffffc02027fc:	3c060613          	addi	a2,a2,960 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202800:	11d00593          	li	a1,285
ffffffffc0202804:	00005517          	auipc	a0,0x5
ffffffffc0202808:	e6c50513          	addi	a0,a0,-404 # ffffffffc0207670 <commands+0xf38>
ffffffffc020280c:	a0bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(total==0);
ffffffffc0202810:	00005697          	auipc	a3,0x5
ffffffffc0202814:	0e068693          	addi	a3,a3,224 # ffffffffc02078f0 <commands+0x11b8>
ffffffffc0202818:	00004617          	auipc	a2,0x4
ffffffffc020281c:	3a060613          	addi	a2,a2,928 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202820:	11e00593          	li	a1,286
ffffffffc0202824:	00005517          	auipc	a0,0x5
ffffffffc0202828:	e4c50513          	addi	a0,a0,-436 # ffffffffc0207670 <commands+0xf38>
ffffffffc020282c:	9ebfd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202830:	00005697          	auipc	a3,0x5
ffffffffc0202834:	f8868693          	addi	a3,a3,-120 # ffffffffc02077b8 <commands+0x1080>
ffffffffc0202838:	00004617          	auipc	a2,0x4
ffffffffc020283c:	38060613          	addi	a2,a2,896 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202840:	0ea00593          	li	a1,234
ffffffffc0202844:	00005517          	auipc	a0,0x5
ffffffffc0202848:	e2c50513          	addi	a0,a0,-468 # ffffffffc0207670 <commands+0xf38>
ffffffffc020284c:	9cbfd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(mm != NULL);
ffffffffc0202850:	00005697          	auipc	a3,0x5
ffffffffc0202854:	8a868693          	addi	a3,a3,-1880 # ffffffffc02070f8 <commands+0x9c0>
ffffffffc0202858:	00004617          	auipc	a2,0x4
ffffffffc020285c:	36060613          	addi	a2,a2,864 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202860:	0c400593          	li	a1,196
ffffffffc0202864:	00005517          	auipc	a0,0x5
ffffffffc0202868:	e0c50513          	addi	a0,a0,-500 # ffffffffc0207670 <commands+0xf38>
ffffffffc020286c:	9abfd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202870:	00005697          	auipc	a3,0x5
ffffffffc0202874:	e8068693          	addi	a3,a3,-384 # ffffffffc02076f0 <commands+0xfb8>
ffffffffc0202878:	00004617          	auipc	a2,0x4
ffffffffc020287c:	34060613          	addi	a2,a2,832 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202880:	0c700593          	li	a1,199
ffffffffc0202884:	00005517          	auipc	a0,0x5
ffffffffc0202888:	dec50513          	addi	a0,a0,-532 # ffffffffc0207670 <commands+0xf38>
ffffffffc020288c:	98bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(ret==0);
ffffffffc0202890:	00005697          	auipc	a3,0x5
ffffffffc0202894:	04868693          	addi	a3,a3,72 # ffffffffc02078d8 <commands+0x11a0>
ffffffffc0202898:	00004617          	auipc	a2,0x4
ffffffffc020289c:	32060613          	addi	a2,a2,800 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02028a0:	10200593          	li	a1,258
ffffffffc02028a4:	00005517          	auipc	a0,0x5
ffffffffc02028a8:	dcc50513          	addi	a0,a0,-564 # ffffffffc0207670 <commands+0xf38>
ffffffffc02028ac:	96bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(total == nr_free_pages());
ffffffffc02028b0:	00005697          	auipc	a3,0x5
ffffffffc02028b4:	df868693          	addi	a3,a3,-520 # ffffffffc02076a8 <commands+0xf70>
ffffffffc02028b8:	00004617          	auipc	a2,0x4
ffffffffc02028bc:	30060613          	addi	a2,a2,768 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02028c0:	0bf00593          	li	a1,191
ffffffffc02028c4:	00005517          	auipc	a0,0x5
ffffffffc02028c8:	dac50513          	addi	a0,a0,-596 # ffffffffc0207670 <commands+0xf38>
ffffffffc02028cc:	94bfd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02028d0 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02028d0:	000aa797          	auipc	a5,0xaa
ffffffffc02028d4:	aa078793          	addi	a5,a5,-1376 # ffffffffc02ac370 <sm>
ffffffffc02028d8:	639c                	ld	a5,0(a5)
ffffffffc02028da:	0107b303          	ld	t1,16(a5)
ffffffffc02028de:	8302                	jr	t1

ffffffffc02028e0 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02028e0:	000aa797          	auipc	a5,0xaa
ffffffffc02028e4:	a9078793          	addi	a5,a5,-1392 # ffffffffc02ac370 <sm>
ffffffffc02028e8:	639c                	ld	a5,0(a5)
ffffffffc02028ea:	0207b303          	ld	t1,32(a5)
ffffffffc02028ee:	8302                	jr	t1

ffffffffc02028f0 <swap_out>:
{
ffffffffc02028f0:	711d                	addi	sp,sp,-96
ffffffffc02028f2:	ec86                	sd	ra,88(sp)
ffffffffc02028f4:	e8a2                	sd	s0,80(sp)
ffffffffc02028f6:	e4a6                	sd	s1,72(sp)
ffffffffc02028f8:	e0ca                	sd	s2,64(sp)
ffffffffc02028fa:	fc4e                	sd	s3,56(sp)
ffffffffc02028fc:	f852                	sd	s4,48(sp)
ffffffffc02028fe:	f456                	sd	s5,40(sp)
ffffffffc0202900:	f05a                	sd	s6,32(sp)
ffffffffc0202902:	ec5e                	sd	s7,24(sp)
ffffffffc0202904:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202906:	cde9                	beqz	a1,ffffffffc02029e0 <swap_out+0xf0>
ffffffffc0202908:	8ab2                	mv	s5,a2
ffffffffc020290a:	892a                	mv	s2,a0
ffffffffc020290c:	8a2e                	mv	s4,a1
ffffffffc020290e:	4401                	li	s0,0
ffffffffc0202910:	000aa997          	auipc	s3,0xaa
ffffffffc0202914:	a6098993          	addi	s3,s3,-1440 # ffffffffc02ac370 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202918:	00005b17          	auipc	s6,0x5
ffffffffc020291c:	068b0b13          	addi	s6,s6,104 # ffffffffc0207980 <commands+0x1248>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202920:	00005b97          	auipc	s7,0x5
ffffffffc0202924:	048b8b93          	addi	s7,s7,72 # ffffffffc0207968 <commands+0x1230>
ffffffffc0202928:	a825                	j	ffffffffc0202960 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020292a:	67a2                	ld	a5,8(sp)
ffffffffc020292c:	8626                	mv	a2,s1
ffffffffc020292e:	85a2                	mv	a1,s0
ffffffffc0202930:	7f94                	ld	a3,56(a5)
ffffffffc0202932:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202934:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202936:	82b1                	srli	a3,a3,0xc
ffffffffc0202938:	0685                	addi	a3,a3,1
ffffffffc020293a:	f96fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020293e:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202940:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202942:	7d1c                	ld	a5,56(a0)
ffffffffc0202944:	83b1                	srli	a5,a5,0xc
ffffffffc0202946:	0785                	addi	a5,a5,1
ffffffffc0202948:	07a2                	slli	a5,a5,0x8
ffffffffc020294a:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc020294e:	523000ef          	jal	ra,ffffffffc0203670 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202952:	01893503          	ld	a0,24(s2)
ffffffffc0202956:	85a6                	mv	a1,s1
ffffffffc0202958:	114020ef          	jal	ra,ffffffffc0204a6c <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc020295c:	048a0d63          	beq	s4,s0,ffffffffc02029b6 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202960:	0009b783          	ld	a5,0(s3)
ffffffffc0202964:	8656                	mv	a2,s5
ffffffffc0202966:	002c                	addi	a1,sp,8
ffffffffc0202968:	7b9c                	ld	a5,48(a5)
ffffffffc020296a:	854a                	mv	a0,s2
ffffffffc020296c:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020296e:	e12d                	bnez	a0,ffffffffc02029d0 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202970:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202972:	01893503          	ld	a0,24(s2)
ffffffffc0202976:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202978:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020297a:	85a6                	mv	a1,s1
ffffffffc020297c:	57b000ef          	jal	ra,ffffffffc02036f6 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202980:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202982:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202984:	8b85                	andi	a5,a5,1
ffffffffc0202986:	cfb9                	beqz	a5,ffffffffc02029e4 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202988:	65a2                	ld	a1,8(sp)
ffffffffc020298a:	7d9c                	ld	a5,56(a1)
ffffffffc020298c:	83b1                	srli	a5,a5,0xc
ffffffffc020298e:	00178513          	addi	a0,a5,1
ffffffffc0202992:	0522                	slli	a0,a0,0x8
ffffffffc0202994:	242020ef          	jal	ra,ffffffffc0204bd6 <swapfs_write>
ffffffffc0202998:	d949                	beqz	a0,ffffffffc020292a <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc020299a:	855e                	mv	a0,s7
ffffffffc020299c:	f34fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02029a0:	0009b783          	ld	a5,0(s3)
ffffffffc02029a4:	6622                	ld	a2,8(sp)
ffffffffc02029a6:	4681                	li	a3,0
ffffffffc02029a8:	739c                	ld	a5,32(a5)
ffffffffc02029aa:	85a6                	mv	a1,s1
ffffffffc02029ac:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02029ae:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02029b0:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02029b2:	fa8a17e3          	bne	s4,s0,ffffffffc0202960 <swap_out+0x70>
}
ffffffffc02029b6:	8522                	mv	a0,s0
ffffffffc02029b8:	60e6                	ld	ra,88(sp)
ffffffffc02029ba:	6446                	ld	s0,80(sp)
ffffffffc02029bc:	64a6                	ld	s1,72(sp)
ffffffffc02029be:	6906                	ld	s2,64(sp)
ffffffffc02029c0:	79e2                	ld	s3,56(sp)
ffffffffc02029c2:	7a42                	ld	s4,48(sp)
ffffffffc02029c4:	7aa2                	ld	s5,40(sp)
ffffffffc02029c6:	7b02                	ld	s6,32(sp)
ffffffffc02029c8:	6be2                	ld	s7,24(sp)
ffffffffc02029ca:	6c42                	ld	s8,16(sp)
ffffffffc02029cc:	6125                	addi	sp,sp,96
ffffffffc02029ce:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02029d0:	85a2                	mv	a1,s0
ffffffffc02029d2:	00005517          	auipc	a0,0x5
ffffffffc02029d6:	f4e50513          	addi	a0,a0,-178 # ffffffffc0207920 <commands+0x11e8>
ffffffffc02029da:	ef6fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc02029de:	bfe1                	j	ffffffffc02029b6 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02029e0:	4401                	li	s0,0
ffffffffc02029e2:	bfd1                	j	ffffffffc02029b6 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02029e4:	00005697          	auipc	a3,0x5
ffffffffc02029e8:	f6c68693          	addi	a3,a3,-148 # ffffffffc0207950 <commands+0x1218>
ffffffffc02029ec:	00004617          	auipc	a2,0x4
ffffffffc02029f0:	1cc60613          	addi	a2,a2,460 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02029f4:	06800593          	li	a1,104
ffffffffc02029f8:	00005517          	auipc	a0,0x5
ffffffffc02029fc:	c7850513          	addi	a0,a0,-904 # ffffffffc0207670 <commands+0xf38>
ffffffffc0202a00:	817fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202a04 <swap_in>:
{
ffffffffc0202a04:	7179                	addi	sp,sp,-48
ffffffffc0202a06:	e84a                	sd	s2,16(sp)
ffffffffc0202a08:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202a0a:	4505                	li	a0,1
{
ffffffffc0202a0c:	ec26                	sd	s1,24(sp)
ffffffffc0202a0e:	e44e                	sd	s3,8(sp)
ffffffffc0202a10:	f406                	sd	ra,40(sp)
ffffffffc0202a12:	f022                	sd	s0,32(sp)
ffffffffc0202a14:	84ae                	mv	s1,a1
ffffffffc0202a16:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202a18:	3d1000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
     assert(result!=NULL);
ffffffffc0202a1c:	c129                	beqz	a0,ffffffffc0202a5e <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202a1e:	842a                	mv	s0,a0
ffffffffc0202a20:	01893503          	ld	a0,24(s2)
ffffffffc0202a24:	4601                	li	a2,0
ffffffffc0202a26:	85a6                	mv	a1,s1
ffffffffc0202a28:	4cf000ef          	jal	ra,ffffffffc02036f6 <get_pte>
ffffffffc0202a2c:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202a2e:	6108                	ld	a0,0(a0)
ffffffffc0202a30:	85a2                	mv	a1,s0
ffffffffc0202a32:	10c020ef          	jal	ra,ffffffffc0204b3e <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202a36:	00093583          	ld	a1,0(s2)
ffffffffc0202a3a:	8626                	mv	a2,s1
ffffffffc0202a3c:	00005517          	auipc	a0,0x5
ffffffffc0202a40:	bd450513          	addi	a0,a0,-1068 # ffffffffc0207610 <commands+0xed8>
ffffffffc0202a44:	81a1                	srli	a1,a1,0x8
ffffffffc0202a46:	e8afd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202a4a:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202a4c:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202a50:	7402                	ld	s0,32(sp)
ffffffffc0202a52:	64e2                	ld	s1,24(sp)
ffffffffc0202a54:	6942                	ld	s2,16(sp)
ffffffffc0202a56:	69a2                	ld	s3,8(sp)
ffffffffc0202a58:	4501                	li	a0,0
ffffffffc0202a5a:	6145                	addi	sp,sp,48
ffffffffc0202a5c:	8082                	ret
     assert(result!=NULL);
ffffffffc0202a5e:	00005697          	auipc	a3,0x5
ffffffffc0202a62:	ba268693          	addi	a3,a3,-1118 # ffffffffc0207600 <commands+0xec8>
ffffffffc0202a66:	00004617          	auipc	a2,0x4
ffffffffc0202a6a:	15260613          	addi	a2,a2,338 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202a6e:	07e00593          	li	a1,126
ffffffffc0202a72:	00005517          	auipc	a0,0x5
ffffffffc0202a76:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0207670 <commands+0xf38>
ffffffffc0202a7a:	f9cfd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202a7e <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202a7e:	000aa797          	auipc	a5,0xaa
ffffffffc0202a82:	a1a78793          	addi	a5,a5,-1510 # ffffffffc02ac498 <free_area>
ffffffffc0202a86:	e79c                	sd	a5,8(a5)
ffffffffc0202a88:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202a8a:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202a8e:	8082                	ret

ffffffffc0202a90 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202a90:	000aa517          	auipc	a0,0xaa
ffffffffc0202a94:	a1856503          	lwu	a0,-1512(a0) # ffffffffc02ac4a8 <free_area+0x10>
ffffffffc0202a98:	8082                	ret

ffffffffc0202a9a <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202a9a:	715d                	addi	sp,sp,-80
ffffffffc0202a9c:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0202a9e:	000aa917          	auipc	s2,0xaa
ffffffffc0202aa2:	9fa90913          	addi	s2,s2,-1542 # ffffffffc02ac498 <free_area>
ffffffffc0202aa6:	00893783          	ld	a5,8(s2)
ffffffffc0202aaa:	e486                	sd	ra,72(sp)
ffffffffc0202aac:	e0a2                	sd	s0,64(sp)
ffffffffc0202aae:	fc26                	sd	s1,56(sp)
ffffffffc0202ab0:	f44e                	sd	s3,40(sp)
ffffffffc0202ab2:	f052                	sd	s4,32(sp)
ffffffffc0202ab4:	ec56                	sd	s5,24(sp)
ffffffffc0202ab6:	e85a                	sd	s6,16(sp)
ffffffffc0202ab8:	e45e                	sd	s7,8(sp)
ffffffffc0202aba:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202abc:	31278463          	beq	a5,s2,ffffffffc0202dc4 <default_check+0x32a>
ffffffffc0202ac0:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202ac4:	8305                	srli	a4,a4,0x1
ffffffffc0202ac6:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202ac8:	30070263          	beqz	a4,ffffffffc0202dcc <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0202acc:	4401                	li	s0,0
ffffffffc0202ace:	4481                	li	s1,0
ffffffffc0202ad0:	a031                	j	ffffffffc0202adc <default_check+0x42>
ffffffffc0202ad2:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202ad6:	8b09                	andi	a4,a4,2
ffffffffc0202ad8:	2e070a63          	beqz	a4,ffffffffc0202dcc <default_check+0x332>
        count ++, total += p->property;
ffffffffc0202adc:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202ae0:	679c                	ld	a5,8(a5)
ffffffffc0202ae2:	2485                	addiw	s1,s1,1
ffffffffc0202ae4:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202ae6:	ff2796e3          	bne	a5,s2,ffffffffc0202ad2 <default_check+0x38>
ffffffffc0202aea:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0202aec:	3cb000ef          	jal	ra,ffffffffc02036b6 <nr_free_pages>
ffffffffc0202af0:	73351e63          	bne	a0,s3,ffffffffc020322c <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202af4:	4505                	li	a0,1
ffffffffc0202af6:	2f3000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202afa:	8a2a                	mv	s4,a0
ffffffffc0202afc:	46050863          	beqz	a0,ffffffffc0202f6c <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202b00:	4505                	li	a0,1
ffffffffc0202b02:	2e7000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202b06:	89aa                	mv	s3,a0
ffffffffc0202b08:	74050263          	beqz	a0,ffffffffc020324c <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202b0c:	4505                	li	a0,1
ffffffffc0202b0e:	2db000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202b12:	8aaa                	mv	s5,a0
ffffffffc0202b14:	4c050c63          	beqz	a0,ffffffffc0202fec <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202b18:	2d3a0a63          	beq	s4,s3,ffffffffc0202dec <default_check+0x352>
ffffffffc0202b1c:	2caa0863          	beq	s4,a0,ffffffffc0202dec <default_check+0x352>
ffffffffc0202b20:	2ca98663          	beq	s3,a0,ffffffffc0202dec <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202b24:	000a2783          	lw	a5,0(s4)
ffffffffc0202b28:	2e079263          	bnez	a5,ffffffffc0202e0c <default_check+0x372>
ffffffffc0202b2c:	0009a783          	lw	a5,0(s3)
ffffffffc0202b30:	2c079e63          	bnez	a5,ffffffffc0202e0c <default_check+0x372>
ffffffffc0202b34:	411c                	lw	a5,0(a0)
ffffffffc0202b36:	2c079b63          	bnez	a5,ffffffffc0202e0c <default_check+0x372>
    return page - pages + nbase;
ffffffffc0202b3a:	000aa797          	auipc	a5,0xaa
ffffffffc0202b3e:	98e78793          	addi	a5,a5,-1650 # ffffffffc02ac4c8 <pages>
ffffffffc0202b42:	639c                	ld	a5,0(a5)
ffffffffc0202b44:	00006717          	auipc	a4,0x6
ffffffffc0202b48:	14c70713          	addi	a4,a4,332 # ffffffffc0208c90 <nbase>
ffffffffc0202b4c:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202b4e:	000aa717          	auipc	a4,0xaa
ffffffffc0202b52:	83a70713          	addi	a4,a4,-1990 # ffffffffc02ac388 <npage>
ffffffffc0202b56:	6314                	ld	a3,0(a4)
ffffffffc0202b58:	40fa0733          	sub	a4,s4,a5
ffffffffc0202b5c:	8719                	srai	a4,a4,0x6
ffffffffc0202b5e:	9732                	add	a4,a4,a2
ffffffffc0202b60:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b62:	0732                	slli	a4,a4,0xc
ffffffffc0202b64:	2cd77463          	bleu	a3,a4,ffffffffc0202e2c <default_check+0x392>
    return page - pages + nbase;
ffffffffc0202b68:	40f98733          	sub	a4,s3,a5
ffffffffc0202b6c:	8719                	srai	a4,a4,0x6
ffffffffc0202b6e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b70:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202b72:	4ed77d63          	bleu	a3,a4,ffffffffc020306c <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0202b76:	40f507b3          	sub	a5,a0,a5
ffffffffc0202b7a:	8799                	srai	a5,a5,0x6
ffffffffc0202b7c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b7e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202b80:	34d7f663          	bleu	a3,a5,ffffffffc0202ecc <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0202b84:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202b86:	00093c03          	ld	s8,0(s2)
ffffffffc0202b8a:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0202b8e:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0202b92:	000aa797          	auipc	a5,0xaa
ffffffffc0202b96:	9127b723          	sd	s2,-1778(a5) # ffffffffc02ac4a0 <free_area+0x8>
ffffffffc0202b9a:	000aa797          	auipc	a5,0xaa
ffffffffc0202b9e:	8f27bf23          	sd	s2,-1794(a5) # ffffffffc02ac498 <free_area>
    nr_free = 0;
ffffffffc0202ba2:	000aa797          	auipc	a5,0xaa
ffffffffc0202ba6:	9007a323          	sw	zero,-1786(a5) # ffffffffc02ac4a8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202baa:	23f000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202bae:	2e051f63          	bnez	a0,ffffffffc0202eac <default_check+0x412>
    free_page(p0);
ffffffffc0202bb2:	4585                	li	a1,1
ffffffffc0202bb4:	8552                	mv	a0,s4
ffffffffc0202bb6:	2bb000ef          	jal	ra,ffffffffc0203670 <free_pages>
    free_page(p1);
ffffffffc0202bba:	4585                	li	a1,1
ffffffffc0202bbc:	854e                	mv	a0,s3
ffffffffc0202bbe:	2b3000ef          	jal	ra,ffffffffc0203670 <free_pages>
    free_page(p2);
ffffffffc0202bc2:	4585                	li	a1,1
ffffffffc0202bc4:	8556                	mv	a0,s5
ffffffffc0202bc6:	2ab000ef          	jal	ra,ffffffffc0203670 <free_pages>
    assert(nr_free == 3);
ffffffffc0202bca:	01092703          	lw	a4,16(s2)
ffffffffc0202bce:	478d                	li	a5,3
ffffffffc0202bd0:	2af71e63          	bne	a4,a5,ffffffffc0202e8c <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202bd4:	4505                	li	a0,1
ffffffffc0202bd6:	213000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202bda:	89aa                	mv	s3,a0
ffffffffc0202bdc:	28050863          	beqz	a0,ffffffffc0202e6c <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202be0:	4505                	li	a0,1
ffffffffc0202be2:	207000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202be6:	8aaa                	mv	s5,a0
ffffffffc0202be8:	3e050263          	beqz	a0,ffffffffc0202fcc <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202bec:	4505                	li	a0,1
ffffffffc0202bee:	1fb000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202bf2:	8a2a                	mv	s4,a0
ffffffffc0202bf4:	3a050c63          	beqz	a0,ffffffffc0202fac <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0202bf8:	4505                	li	a0,1
ffffffffc0202bfa:	1ef000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202bfe:	38051763          	bnez	a0,ffffffffc0202f8c <default_check+0x4f2>
    free_page(p0);
ffffffffc0202c02:	4585                	li	a1,1
ffffffffc0202c04:	854e                	mv	a0,s3
ffffffffc0202c06:	26b000ef          	jal	ra,ffffffffc0203670 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202c0a:	00893783          	ld	a5,8(s2)
ffffffffc0202c0e:	23278f63          	beq	a5,s2,ffffffffc0202e4c <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0202c12:	4505                	li	a0,1
ffffffffc0202c14:	1d5000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202c18:	32a99a63          	bne	s3,a0,ffffffffc0202f4c <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0202c1c:	4505                	li	a0,1
ffffffffc0202c1e:	1cb000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202c22:	30051563          	bnez	a0,ffffffffc0202f2c <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0202c26:	01092783          	lw	a5,16(s2)
ffffffffc0202c2a:	2e079163          	bnez	a5,ffffffffc0202f0c <default_check+0x472>
    free_page(p);
ffffffffc0202c2e:	854e                	mv	a0,s3
ffffffffc0202c30:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202c32:	000aa797          	auipc	a5,0xaa
ffffffffc0202c36:	8787b323          	sd	s8,-1946(a5) # ffffffffc02ac498 <free_area>
ffffffffc0202c3a:	000aa797          	auipc	a5,0xaa
ffffffffc0202c3e:	8777b323          	sd	s7,-1946(a5) # ffffffffc02ac4a0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0202c42:	000aa797          	auipc	a5,0xaa
ffffffffc0202c46:	8767a323          	sw	s6,-1946(a5) # ffffffffc02ac4a8 <free_area+0x10>
    free_page(p);
ffffffffc0202c4a:	227000ef          	jal	ra,ffffffffc0203670 <free_pages>
    free_page(p1);
ffffffffc0202c4e:	4585                	li	a1,1
ffffffffc0202c50:	8556                	mv	a0,s5
ffffffffc0202c52:	21f000ef          	jal	ra,ffffffffc0203670 <free_pages>
    free_page(p2);
ffffffffc0202c56:	4585                	li	a1,1
ffffffffc0202c58:	8552                	mv	a0,s4
ffffffffc0202c5a:	217000ef          	jal	ra,ffffffffc0203670 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202c5e:	4515                	li	a0,5
ffffffffc0202c60:	189000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202c64:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202c66:	28050363          	beqz	a0,ffffffffc0202eec <default_check+0x452>
ffffffffc0202c6a:	651c                	ld	a5,8(a0)
ffffffffc0202c6c:	8385                	srli	a5,a5,0x1
ffffffffc0202c6e:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0202c70:	54079e63          	bnez	a5,ffffffffc02031cc <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202c74:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202c76:	00093b03          	ld	s6,0(s2)
ffffffffc0202c7a:	00893a83          	ld	s5,8(s2)
ffffffffc0202c7e:	000aa797          	auipc	a5,0xaa
ffffffffc0202c82:	8127bd23          	sd	s2,-2022(a5) # ffffffffc02ac498 <free_area>
ffffffffc0202c86:	000aa797          	auipc	a5,0xaa
ffffffffc0202c8a:	8127bd23          	sd	s2,-2022(a5) # ffffffffc02ac4a0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0202c8e:	15b000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202c92:	50051d63          	bnez	a0,ffffffffc02031ac <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202c96:	08098a13          	addi	s4,s3,128
ffffffffc0202c9a:	8552                	mv	a0,s4
ffffffffc0202c9c:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202c9e:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0202ca2:	000aa797          	auipc	a5,0xaa
ffffffffc0202ca6:	8007a323          	sw	zero,-2042(a5) # ffffffffc02ac4a8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202caa:	1c7000ef          	jal	ra,ffffffffc0203670 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202cae:	4511                	li	a0,4
ffffffffc0202cb0:	139000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202cb4:	4c051c63          	bnez	a0,ffffffffc020318c <default_check+0x6f2>
ffffffffc0202cb8:	0889b783          	ld	a5,136(s3)
ffffffffc0202cbc:	8385                	srli	a5,a5,0x1
ffffffffc0202cbe:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202cc0:	4a078663          	beqz	a5,ffffffffc020316c <default_check+0x6d2>
ffffffffc0202cc4:	0909a703          	lw	a4,144(s3)
ffffffffc0202cc8:	478d                	li	a5,3
ffffffffc0202cca:	4af71163          	bne	a4,a5,ffffffffc020316c <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202cce:	450d                	li	a0,3
ffffffffc0202cd0:	119000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202cd4:	8c2a                	mv	s8,a0
ffffffffc0202cd6:	46050b63          	beqz	a0,ffffffffc020314c <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0202cda:	4505                	li	a0,1
ffffffffc0202cdc:	10d000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202ce0:	44051663          	bnez	a0,ffffffffc020312c <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0202ce4:	438a1463          	bne	s4,s8,ffffffffc020310c <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202ce8:	4585                	li	a1,1
ffffffffc0202cea:	854e                	mv	a0,s3
ffffffffc0202cec:	185000ef          	jal	ra,ffffffffc0203670 <free_pages>
    free_pages(p1, 3);
ffffffffc0202cf0:	458d                	li	a1,3
ffffffffc0202cf2:	8552                	mv	a0,s4
ffffffffc0202cf4:	17d000ef          	jal	ra,ffffffffc0203670 <free_pages>
ffffffffc0202cf8:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202cfc:	04098c13          	addi	s8,s3,64
ffffffffc0202d00:	8385                	srli	a5,a5,0x1
ffffffffc0202d02:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202d04:	3e078463          	beqz	a5,ffffffffc02030ec <default_check+0x652>
ffffffffc0202d08:	0109a703          	lw	a4,16(s3)
ffffffffc0202d0c:	4785                	li	a5,1
ffffffffc0202d0e:	3cf71f63          	bne	a4,a5,ffffffffc02030ec <default_check+0x652>
ffffffffc0202d12:	008a3783          	ld	a5,8(s4)
ffffffffc0202d16:	8385                	srli	a5,a5,0x1
ffffffffc0202d18:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202d1a:	3a078963          	beqz	a5,ffffffffc02030cc <default_check+0x632>
ffffffffc0202d1e:	010a2703          	lw	a4,16(s4)
ffffffffc0202d22:	478d                	li	a5,3
ffffffffc0202d24:	3af71463          	bne	a4,a5,ffffffffc02030cc <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202d28:	4505                	li	a0,1
ffffffffc0202d2a:	0bf000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202d2e:	36a99f63          	bne	s3,a0,ffffffffc02030ac <default_check+0x612>
    free_page(p0);
ffffffffc0202d32:	4585                	li	a1,1
ffffffffc0202d34:	13d000ef          	jal	ra,ffffffffc0203670 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202d38:	4509                	li	a0,2
ffffffffc0202d3a:	0af000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202d3e:	34aa1763          	bne	s4,a0,ffffffffc020308c <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0202d42:	4589                	li	a1,2
ffffffffc0202d44:	12d000ef          	jal	ra,ffffffffc0203670 <free_pages>
    free_page(p2);
ffffffffc0202d48:	4585                	li	a1,1
ffffffffc0202d4a:	8562                	mv	a0,s8
ffffffffc0202d4c:	125000ef          	jal	ra,ffffffffc0203670 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202d50:	4515                	li	a0,5
ffffffffc0202d52:	097000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202d56:	89aa                	mv	s3,a0
ffffffffc0202d58:	48050a63          	beqz	a0,ffffffffc02031ec <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0202d5c:	4505                	li	a0,1
ffffffffc0202d5e:	08b000ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0202d62:	2e051563          	bnez	a0,ffffffffc020304c <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0202d66:	01092783          	lw	a5,16(s2)
ffffffffc0202d6a:	2c079163          	bnez	a5,ffffffffc020302c <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202d6e:	4595                	li	a1,5
ffffffffc0202d70:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202d72:	000a9797          	auipc	a5,0xa9
ffffffffc0202d76:	7377ab23          	sw	s7,1846(a5) # ffffffffc02ac4a8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0202d7a:	000a9797          	auipc	a5,0xa9
ffffffffc0202d7e:	7167bf23          	sd	s6,1822(a5) # ffffffffc02ac498 <free_area>
ffffffffc0202d82:	000a9797          	auipc	a5,0xa9
ffffffffc0202d86:	7157bf23          	sd	s5,1822(a5) # ffffffffc02ac4a0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0202d8a:	0e7000ef          	jal	ra,ffffffffc0203670 <free_pages>
    return listelm->next;
ffffffffc0202d8e:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202d92:	01278963          	beq	a5,s2,ffffffffc0202da4 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202d96:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202d9a:	679c                	ld	a5,8(a5)
ffffffffc0202d9c:	34fd                	addiw	s1,s1,-1
ffffffffc0202d9e:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202da0:	ff279be3          	bne	a5,s2,ffffffffc0202d96 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0202da4:	26049463          	bnez	s1,ffffffffc020300c <default_check+0x572>
    assert(total == 0);
ffffffffc0202da8:	46041263          	bnez	s0,ffffffffc020320c <default_check+0x772>
}
ffffffffc0202dac:	60a6                	ld	ra,72(sp)
ffffffffc0202dae:	6406                	ld	s0,64(sp)
ffffffffc0202db0:	74e2                	ld	s1,56(sp)
ffffffffc0202db2:	7942                	ld	s2,48(sp)
ffffffffc0202db4:	79a2                	ld	s3,40(sp)
ffffffffc0202db6:	7a02                	ld	s4,32(sp)
ffffffffc0202db8:	6ae2                	ld	s5,24(sp)
ffffffffc0202dba:	6b42                	ld	s6,16(sp)
ffffffffc0202dbc:	6ba2                	ld	s7,8(sp)
ffffffffc0202dbe:	6c02                	ld	s8,0(sp)
ffffffffc0202dc0:	6161                	addi	sp,sp,80
ffffffffc0202dc2:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202dc4:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0202dc6:	4401                	li	s0,0
ffffffffc0202dc8:	4481                	li	s1,0
ffffffffc0202dca:	b30d                	j	ffffffffc0202aec <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0202dcc:	00005697          	auipc	a3,0x5
ffffffffc0202dd0:	8cc68693          	addi	a3,a3,-1844 # ffffffffc0207698 <commands+0xf60>
ffffffffc0202dd4:	00004617          	auipc	a2,0x4
ffffffffc0202dd8:	de460613          	addi	a2,a2,-540 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202ddc:	0f000593          	li	a1,240
ffffffffc0202de0:	00005517          	auipc	a0,0x5
ffffffffc0202de4:	be050513          	addi	a0,a0,-1056 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202de8:	c2efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202dec:	00005697          	auipc	a3,0x5
ffffffffc0202df0:	c4c68693          	addi	a3,a3,-948 # ffffffffc0207a38 <commands+0x1300>
ffffffffc0202df4:	00004617          	auipc	a2,0x4
ffffffffc0202df8:	dc460613          	addi	a2,a2,-572 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202dfc:	0bd00593          	li	a1,189
ffffffffc0202e00:	00005517          	auipc	a0,0x5
ffffffffc0202e04:	bc050513          	addi	a0,a0,-1088 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202e08:	c0efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202e0c:	00005697          	auipc	a3,0x5
ffffffffc0202e10:	c5468693          	addi	a3,a3,-940 # ffffffffc0207a60 <commands+0x1328>
ffffffffc0202e14:	00004617          	auipc	a2,0x4
ffffffffc0202e18:	da460613          	addi	a2,a2,-604 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202e1c:	0be00593          	li	a1,190
ffffffffc0202e20:	00005517          	auipc	a0,0x5
ffffffffc0202e24:	ba050513          	addi	a0,a0,-1120 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202e28:	beefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202e2c:	00005697          	auipc	a3,0x5
ffffffffc0202e30:	c7468693          	addi	a3,a3,-908 # ffffffffc0207aa0 <commands+0x1368>
ffffffffc0202e34:	00004617          	auipc	a2,0x4
ffffffffc0202e38:	d8460613          	addi	a2,a2,-636 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202e3c:	0c000593          	li	a1,192
ffffffffc0202e40:	00005517          	auipc	a0,0x5
ffffffffc0202e44:	b8050513          	addi	a0,a0,-1152 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202e48:	bcefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202e4c:	00005697          	auipc	a3,0x5
ffffffffc0202e50:	cdc68693          	addi	a3,a3,-804 # ffffffffc0207b28 <commands+0x13f0>
ffffffffc0202e54:	00004617          	auipc	a2,0x4
ffffffffc0202e58:	d6460613          	addi	a2,a2,-668 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202e5c:	0d900593          	li	a1,217
ffffffffc0202e60:	00005517          	auipc	a0,0x5
ffffffffc0202e64:	b6050513          	addi	a0,a0,-1184 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202e68:	baefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202e6c:	00005697          	auipc	a3,0x5
ffffffffc0202e70:	b6c68693          	addi	a3,a3,-1172 # ffffffffc02079d8 <commands+0x12a0>
ffffffffc0202e74:	00004617          	auipc	a2,0x4
ffffffffc0202e78:	d4460613          	addi	a2,a2,-700 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202e7c:	0d200593          	li	a1,210
ffffffffc0202e80:	00005517          	auipc	a0,0x5
ffffffffc0202e84:	b4050513          	addi	a0,a0,-1216 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202e88:	b8efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 3);
ffffffffc0202e8c:	00005697          	auipc	a3,0x5
ffffffffc0202e90:	c8c68693          	addi	a3,a3,-884 # ffffffffc0207b18 <commands+0x13e0>
ffffffffc0202e94:	00004617          	auipc	a2,0x4
ffffffffc0202e98:	d2460613          	addi	a2,a2,-732 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202e9c:	0d000593          	li	a1,208
ffffffffc0202ea0:	00005517          	auipc	a0,0x5
ffffffffc0202ea4:	b2050513          	addi	a0,a0,-1248 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202ea8:	b6efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202eac:	00005697          	auipc	a3,0x5
ffffffffc0202eb0:	c5468693          	addi	a3,a3,-940 # ffffffffc0207b00 <commands+0x13c8>
ffffffffc0202eb4:	00004617          	auipc	a2,0x4
ffffffffc0202eb8:	d0460613          	addi	a2,a2,-764 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202ebc:	0cb00593          	li	a1,203
ffffffffc0202ec0:	00005517          	auipc	a0,0x5
ffffffffc0202ec4:	b0050513          	addi	a0,a0,-1280 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202ec8:	b4efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202ecc:	00005697          	auipc	a3,0x5
ffffffffc0202ed0:	c1468693          	addi	a3,a3,-1004 # ffffffffc0207ae0 <commands+0x13a8>
ffffffffc0202ed4:	00004617          	auipc	a2,0x4
ffffffffc0202ed8:	ce460613          	addi	a2,a2,-796 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202edc:	0c200593          	li	a1,194
ffffffffc0202ee0:	00005517          	auipc	a0,0x5
ffffffffc0202ee4:	ae050513          	addi	a0,a0,-1312 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202ee8:	b2efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 != NULL);
ffffffffc0202eec:	00005697          	auipc	a3,0x5
ffffffffc0202ef0:	c7468693          	addi	a3,a3,-908 # ffffffffc0207b60 <commands+0x1428>
ffffffffc0202ef4:	00004617          	auipc	a2,0x4
ffffffffc0202ef8:	cc460613          	addi	a2,a2,-828 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202efc:	0f800593          	li	a1,248
ffffffffc0202f00:	00005517          	auipc	a0,0x5
ffffffffc0202f04:	ac050513          	addi	a0,a0,-1344 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202f08:	b0efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 0);
ffffffffc0202f0c:	00005697          	auipc	a3,0x5
ffffffffc0202f10:	92c68693          	addi	a3,a3,-1748 # ffffffffc0207838 <commands+0x1100>
ffffffffc0202f14:	00004617          	auipc	a2,0x4
ffffffffc0202f18:	ca460613          	addi	a2,a2,-860 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202f1c:	0df00593          	li	a1,223
ffffffffc0202f20:	00005517          	auipc	a0,0x5
ffffffffc0202f24:	aa050513          	addi	a0,a0,-1376 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202f28:	aeefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202f2c:	00005697          	auipc	a3,0x5
ffffffffc0202f30:	bd468693          	addi	a3,a3,-1068 # ffffffffc0207b00 <commands+0x13c8>
ffffffffc0202f34:	00004617          	auipc	a2,0x4
ffffffffc0202f38:	c8460613          	addi	a2,a2,-892 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202f3c:	0dd00593          	li	a1,221
ffffffffc0202f40:	00005517          	auipc	a0,0x5
ffffffffc0202f44:	a8050513          	addi	a0,a0,-1408 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202f48:	acefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202f4c:	00005697          	auipc	a3,0x5
ffffffffc0202f50:	bf468693          	addi	a3,a3,-1036 # ffffffffc0207b40 <commands+0x1408>
ffffffffc0202f54:	00004617          	auipc	a2,0x4
ffffffffc0202f58:	c6460613          	addi	a2,a2,-924 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202f5c:	0dc00593          	li	a1,220
ffffffffc0202f60:	00005517          	auipc	a0,0x5
ffffffffc0202f64:	a6050513          	addi	a0,a0,-1440 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202f68:	aaefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202f6c:	00005697          	auipc	a3,0x5
ffffffffc0202f70:	a6c68693          	addi	a3,a3,-1428 # ffffffffc02079d8 <commands+0x12a0>
ffffffffc0202f74:	00004617          	auipc	a2,0x4
ffffffffc0202f78:	c4460613          	addi	a2,a2,-956 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202f7c:	0b900593          	li	a1,185
ffffffffc0202f80:	00005517          	auipc	a0,0x5
ffffffffc0202f84:	a4050513          	addi	a0,a0,-1472 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202f88:	a8efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202f8c:	00005697          	auipc	a3,0x5
ffffffffc0202f90:	b7468693          	addi	a3,a3,-1164 # ffffffffc0207b00 <commands+0x13c8>
ffffffffc0202f94:	00004617          	auipc	a2,0x4
ffffffffc0202f98:	c2460613          	addi	a2,a2,-988 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202f9c:	0d600593          	li	a1,214
ffffffffc0202fa0:	00005517          	auipc	a0,0x5
ffffffffc0202fa4:	a2050513          	addi	a0,a0,-1504 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202fa8:	a6efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202fac:	00005697          	auipc	a3,0x5
ffffffffc0202fb0:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0207a18 <commands+0x12e0>
ffffffffc0202fb4:	00004617          	auipc	a2,0x4
ffffffffc0202fb8:	c0460613          	addi	a2,a2,-1020 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202fbc:	0d400593          	li	a1,212
ffffffffc0202fc0:	00005517          	auipc	a0,0x5
ffffffffc0202fc4:	a0050513          	addi	a0,a0,-1536 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202fc8:	a4efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202fcc:	00005697          	auipc	a3,0x5
ffffffffc0202fd0:	a2c68693          	addi	a3,a3,-1492 # ffffffffc02079f8 <commands+0x12c0>
ffffffffc0202fd4:	00004617          	auipc	a2,0x4
ffffffffc0202fd8:	be460613          	addi	a2,a2,-1052 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202fdc:	0d300593          	li	a1,211
ffffffffc0202fe0:	00005517          	auipc	a0,0x5
ffffffffc0202fe4:	9e050513          	addi	a0,a0,-1568 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0202fe8:	a2efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202fec:	00005697          	auipc	a3,0x5
ffffffffc0202ff0:	a2c68693          	addi	a3,a3,-1492 # ffffffffc0207a18 <commands+0x12e0>
ffffffffc0202ff4:	00004617          	auipc	a2,0x4
ffffffffc0202ff8:	bc460613          	addi	a2,a2,-1084 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0202ffc:	0bb00593          	li	a1,187
ffffffffc0203000:	00005517          	auipc	a0,0x5
ffffffffc0203004:	9c050513          	addi	a0,a0,-1600 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203008:	a0efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(count == 0);
ffffffffc020300c:	00005697          	auipc	a3,0x5
ffffffffc0203010:	ca468693          	addi	a3,a3,-860 # ffffffffc0207cb0 <commands+0x1578>
ffffffffc0203014:	00004617          	auipc	a2,0x4
ffffffffc0203018:	ba460613          	addi	a2,a2,-1116 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020301c:	12500593          	li	a1,293
ffffffffc0203020:	00005517          	auipc	a0,0x5
ffffffffc0203024:	9a050513          	addi	a0,a0,-1632 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203028:	9eefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 0);
ffffffffc020302c:	00005697          	auipc	a3,0x5
ffffffffc0203030:	80c68693          	addi	a3,a3,-2036 # ffffffffc0207838 <commands+0x1100>
ffffffffc0203034:	00004617          	auipc	a2,0x4
ffffffffc0203038:	b8460613          	addi	a2,a2,-1148 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020303c:	11a00593          	li	a1,282
ffffffffc0203040:	00005517          	auipc	a0,0x5
ffffffffc0203044:	98050513          	addi	a0,a0,-1664 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203048:	9cefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020304c:	00005697          	auipc	a3,0x5
ffffffffc0203050:	ab468693          	addi	a3,a3,-1356 # ffffffffc0207b00 <commands+0x13c8>
ffffffffc0203054:	00004617          	auipc	a2,0x4
ffffffffc0203058:	b6460613          	addi	a2,a2,-1180 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020305c:	11800593          	li	a1,280
ffffffffc0203060:	00005517          	auipc	a0,0x5
ffffffffc0203064:	96050513          	addi	a0,a0,-1696 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203068:	9aefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020306c:	00005697          	auipc	a3,0x5
ffffffffc0203070:	a5468693          	addi	a3,a3,-1452 # ffffffffc0207ac0 <commands+0x1388>
ffffffffc0203074:	00004617          	auipc	a2,0x4
ffffffffc0203078:	b4460613          	addi	a2,a2,-1212 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020307c:	0c100593          	li	a1,193
ffffffffc0203080:	00005517          	auipc	a0,0x5
ffffffffc0203084:	94050513          	addi	a0,a0,-1728 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203088:	98efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020308c:	00005697          	auipc	a3,0x5
ffffffffc0203090:	be468693          	addi	a3,a3,-1052 # ffffffffc0207c70 <commands+0x1538>
ffffffffc0203094:	00004617          	auipc	a2,0x4
ffffffffc0203098:	b2460613          	addi	a2,a2,-1244 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020309c:	11200593          	li	a1,274
ffffffffc02030a0:	00005517          	auipc	a0,0x5
ffffffffc02030a4:	92050513          	addi	a0,a0,-1760 # ffffffffc02079c0 <commands+0x1288>
ffffffffc02030a8:	96efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02030ac:	00005697          	auipc	a3,0x5
ffffffffc02030b0:	ba468693          	addi	a3,a3,-1116 # ffffffffc0207c50 <commands+0x1518>
ffffffffc02030b4:	00004617          	auipc	a2,0x4
ffffffffc02030b8:	b0460613          	addi	a2,a2,-1276 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02030bc:	11000593          	li	a1,272
ffffffffc02030c0:	00005517          	auipc	a0,0x5
ffffffffc02030c4:	90050513          	addi	a0,a0,-1792 # ffffffffc02079c0 <commands+0x1288>
ffffffffc02030c8:	94efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02030cc:	00005697          	auipc	a3,0x5
ffffffffc02030d0:	b5c68693          	addi	a3,a3,-1188 # ffffffffc0207c28 <commands+0x14f0>
ffffffffc02030d4:	00004617          	auipc	a2,0x4
ffffffffc02030d8:	ae460613          	addi	a2,a2,-1308 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02030dc:	10e00593          	li	a1,270
ffffffffc02030e0:	00005517          	auipc	a0,0x5
ffffffffc02030e4:	8e050513          	addi	a0,a0,-1824 # ffffffffc02079c0 <commands+0x1288>
ffffffffc02030e8:	92efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02030ec:	00005697          	auipc	a3,0x5
ffffffffc02030f0:	b1468693          	addi	a3,a3,-1260 # ffffffffc0207c00 <commands+0x14c8>
ffffffffc02030f4:	00004617          	auipc	a2,0x4
ffffffffc02030f8:	ac460613          	addi	a2,a2,-1340 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02030fc:	10d00593          	li	a1,269
ffffffffc0203100:	00005517          	auipc	a0,0x5
ffffffffc0203104:	8c050513          	addi	a0,a0,-1856 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203108:	90efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020310c:	00005697          	auipc	a3,0x5
ffffffffc0203110:	ae468693          	addi	a3,a3,-1308 # ffffffffc0207bf0 <commands+0x14b8>
ffffffffc0203114:	00004617          	auipc	a2,0x4
ffffffffc0203118:	aa460613          	addi	a2,a2,-1372 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020311c:	10800593          	li	a1,264
ffffffffc0203120:	00005517          	auipc	a0,0x5
ffffffffc0203124:	8a050513          	addi	a0,a0,-1888 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203128:	8eefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020312c:	00005697          	auipc	a3,0x5
ffffffffc0203130:	9d468693          	addi	a3,a3,-1580 # ffffffffc0207b00 <commands+0x13c8>
ffffffffc0203134:	00004617          	auipc	a2,0x4
ffffffffc0203138:	a8460613          	addi	a2,a2,-1404 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020313c:	10700593          	li	a1,263
ffffffffc0203140:	00005517          	auipc	a0,0x5
ffffffffc0203144:	88050513          	addi	a0,a0,-1920 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203148:	8cefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020314c:	00005697          	auipc	a3,0x5
ffffffffc0203150:	a8468693          	addi	a3,a3,-1404 # ffffffffc0207bd0 <commands+0x1498>
ffffffffc0203154:	00004617          	auipc	a2,0x4
ffffffffc0203158:	a6460613          	addi	a2,a2,-1436 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020315c:	10600593          	li	a1,262
ffffffffc0203160:	00005517          	auipc	a0,0x5
ffffffffc0203164:	86050513          	addi	a0,a0,-1952 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203168:	8aefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020316c:	00005697          	auipc	a3,0x5
ffffffffc0203170:	a3468693          	addi	a3,a3,-1484 # ffffffffc0207ba0 <commands+0x1468>
ffffffffc0203174:	00004617          	auipc	a2,0x4
ffffffffc0203178:	a4460613          	addi	a2,a2,-1468 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020317c:	10500593          	li	a1,261
ffffffffc0203180:	00005517          	auipc	a0,0x5
ffffffffc0203184:	84050513          	addi	a0,a0,-1984 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203188:	88efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020318c:	00005697          	auipc	a3,0x5
ffffffffc0203190:	9fc68693          	addi	a3,a3,-1540 # ffffffffc0207b88 <commands+0x1450>
ffffffffc0203194:	00004617          	auipc	a2,0x4
ffffffffc0203198:	a2460613          	addi	a2,a2,-1500 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020319c:	10400593          	li	a1,260
ffffffffc02031a0:	00005517          	auipc	a0,0x5
ffffffffc02031a4:	82050513          	addi	a0,a0,-2016 # ffffffffc02079c0 <commands+0x1288>
ffffffffc02031a8:	86efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02031ac:	00005697          	auipc	a3,0x5
ffffffffc02031b0:	95468693          	addi	a3,a3,-1708 # ffffffffc0207b00 <commands+0x13c8>
ffffffffc02031b4:	00004617          	auipc	a2,0x4
ffffffffc02031b8:	a0460613          	addi	a2,a2,-1532 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02031bc:	0fe00593          	li	a1,254
ffffffffc02031c0:	00005517          	auipc	a0,0x5
ffffffffc02031c4:	80050513          	addi	a0,a0,-2048 # ffffffffc02079c0 <commands+0x1288>
ffffffffc02031c8:	84efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(!PageProperty(p0));
ffffffffc02031cc:	00005697          	auipc	a3,0x5
ffffffffc02031d0:	9a468693          	addi	a3,a3,-1628 # ffffffffc0207b70 <commands+0x1438>
ffffffffc02031d4:	00004617          	auipc	a2,0x4
ffffffffc02031d8:	9e460613          	addi	a2,a2,-1564 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02031dc:	0f900593          	li	a1,249
ffffffffc02031e0:	00004517          	auipc	a0,0x4
ffffffffc02031e4:	7e050513          	addi	a0,a0,2016 # ffffffffc02079c0 <commands+0x1288>
ffffffffc02031e8:	82efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02031ec:	00005697          	auipc	a3,0x5
ffffffffc02031f0:	aa468693          	addi	a3,a3,-1372 # ffffffffc0207c90 <commands+0x1558>
ffffffffc02031f4:	00004617          	auipc	a2,0x4
ffffffffc02031f8:	9c460613          	addi	a2,a2,-1596 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02031fc:	11700593          	li	a1,279
ffffffffc0203200:	00004517          	auipc	a0,0x4
ffffffffc0203204:	7c050513          	addi	a0,a0,1984 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203208:	80efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(total == 0);
ffffffffc020320c:	00005697          	auipc	a3,0x5
ffffffffc0203210:	ab468693          	addi	a3,a3,-1356 # ffffffffc0207cc0 <commands+0x1588>
ffffffffc0203214:	00004617          	auipc	a2,0x4
ffffffffc0203218:	9a460613          	addi	a2,a2,-1628 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020321c:	12600593          	li	a1,294
ffffffffc0203220:	00004517          	auipc	a0,0x4
ffffffffc0203224:	7a050513          	addi	a0,a0,1952 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203228:	feffc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(total == nr_free_pages());
ffffffffc020322c:	00004697          	auipc	a3,0x4
ffffffffc0203230:	47c68693          	addi	a3,a3,1148 # ffffffffc02076a8 <commands+0xf70>
ffffffffc0203234:	00004617          	auipc	a2,0x4
ffffffffc0203238:	98460613          	addi	a2,a2,-1660 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020323c:	0f300593          	li	a1,243
ffffffffc0203240:	00004517          	auipc	a0,0x4
ffffffffc0203244:	78050513          	addi	a0,a0,1920 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203248:	fcffc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020324c:	00004697          	auipc	a3,0x4
ffffffffc0203250:	7ac68693          	addi	a3,a3,1964 # ffffffffc02079f8 <commands+0x12c0>
ffffffffc0203254:	00004617          	auipc	a2,0x4
ffffffffc0203258:	96460613          	addi	a2,a2,-1692 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020325c:	0ba00593          	li	a1,186
ffffffffc0203260:	00004517          	auipc	a0,0x4
ffffffffc0203264:	76050513          	addi	a0,a0,1888 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203268:	faffc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020326c <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020326c:	1141                	addi	sp,sp,-16
ffffffffc020326e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203270:	16058e63          	beqz	a1,ffffffffc02033ec <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0203274:	00659693          	slli	a3,a1,0x6
ffffffffc0203278:	96aa                	add	a3,a3,a0
ffffffffc020327a:	02d50d63          	beq	a0,a3,ffffffffc02032b4 <default_free_pages+0x48>
ffffffffc020327e:	651c                	ld	a5,8(a0)
ffffffffc0203280:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203282:	14079563          	bnez	a5,ffffffffc02033cc <default_free_pages+0x160>
ffffffffc0203286:	651c                	ld	a5,8(a0)
ffffffffc0203288:	8385                	srli	a5,a5,0x1
ffffffffc020328a:	8b85                	andi	a5,a5,1
ffffffffc020328c:	14079063          	bnez	a5,ffffffffc02033cc <default_free_pages+0x160>
ffffffffc0203290:	87aa                	mv	a5,a0
ffffffffc0203292:	a809                	j	ffffffffc02032a4 <default_free_pages+0x38>
ffffffffc0203294:	6798                	ld	a4,8(a5)
ffffffffc0203296:	8b05                	andi	a4,a4,1
ffffffffc0203298:	12071a63          	bnez	a4,ffffffffc02033cc <default_free_pages+0x160>
ffffffffc020329c:	6798                	ld	a4,8(a5)
ffffffffc020329e:	8b09                	andi	a4,a4,2
ffffffffc02032a0:	12071663          	bnez	a4,ffffffffc02033cc <default_free_pages+0x160>
        p->flags = 0;
ffffffffc02032a4:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02032a8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02032ac:	04078793          	addi	a5,a5,64
ffffffffc02032b0:	fed792e3          	bne	a5,a3,ffffffffc0203294 <default_free_pages+0x28>
    base->property = n;
ffffffffc02032b4:	2581                	sext.w	a1,a1
ffffffffc02032b6:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02032b8:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02032bc:	4789                	li	a5,2
ffffffffc02032be:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02032c2:	000a9697          	auipc	a3,0xa9
ffffffffc02032c6:	1d668693          	addi	a3,a3,470 # ffffffffc02ac498 <free_area>
ffffffffc02032ca:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02032cc:	669c                	ld	a5,8(a3)
ffffffffc02032ce:	9db9                	addw	a1,a1,a4
ffffffffc02032d0:	000a9717          	auipc	a4,0xa9
ffffffffc02032d4:	1cb72c23          	sw	a1,472(a4) # ffffffffc02ac4a8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02032d8:	0cd78163          	beq	a5,a3,ffffffffc020339a <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02032dc:	fe878713          	addi	a4,a5,-24
ffffffffc02032e0:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02032e2:	4801                	li	a6,0
ffffffffc02032e4:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02032e8:	00e56a63          	bltu	a0,a4,ffffffffc02032fc <default_free_pages+0x90>
    return listelm->next;
ffffffffc02032ec:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02032ee:	04d70f63          	beq	a4,a3,ffffffffc020334c <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02032f2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02032f4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02032f8:	fee57ae3          	bleu	a4,a0,ffffffffc02032ec <default_free_pages+0x80>
ffffffffc02032fc:	00080663          	beqz	a6,ffffffffc0203308 <default_free_pages+0x9c>
ffffffffc0203300:	000a9817          	auipc	a6,0xa9
ffffffffc0203304:	18b83c23          	sd	a1,408(a6) # ffffffffc02ac498 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203308:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc020330a:	e390                	sd	a2,0(a5)
ffffffffc020330c:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020330e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203310:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0203312:	06d58a63          	beq	a1,a3,ffffffffc0203386 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0203316:	ff85a603          	lw	a2,-8(a1) # ff8 <_binary_obj___user_faultread_out_size-0x8570>
        p = le2page(le, page_link);
ffffffffc020331a:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020331e:	02061793          	slli	a5,a2,0x20
ffffffffc0203322:	83e9                	srli	a5,a5,0x1a
ffffffffc0203324:	97ba                	add	a5,a5,a4
ffffffffc0203326:	04f51b63          	bne	a0,a5,ffffffffc020337c <default_free_pages+0x110>
            p->property += base->property;
ffffffffc020332a:	491c                	lw	a5,16(a0)
ffffffffc020332c:	9e3d                	addw	a2,a2,a5
ffffffffc020332e:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203332:	57f5                	li	a5,-3
ffffffffc0203334:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203338:	01853803          	ld	a6,24(a0)
ffffffffc020333c:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc020333e:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc0203340:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0203344:	659c                	ld	a5,8(a1)
ffffffffc0203346:	01063023          	sd	a6,0(a2)
ffffffffc020334a:	a815                	j	ffffffffc020337e <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc020334c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020334e:	f114                	sd	a3,32(a0)
ffffffffc0203350:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203352:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0203354:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203356:	00d70563          	beq	a4,a3,ffffffffc0203360 <default_free_pages+0xf4>
ffffffffc020335a:	4805                	li	a6,1
ffffffffc020335c:	87ba                	mv	a5,a4
ffffffffc020335e:	bf59                	j	ffffffffc02032f4 <default_free_pages+0x88>
ffffffffc0203360:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0203362:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0203364:	00d78d63          	beq	a5,a3,ffffffffc020337e <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0203368:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc020336c:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0203370:	02061793          	slli	a5,a2,0x20
ffffffffc0203374:	83e9                	srli	a5,a5,0x1a
ffffffffc0203376:	97ba                	add	a5,a5,a4
ffffffffc0203378:	faf509e3          	beq	a0,a5,ffffffffc020332a <default_free_pages+0xbe>
ffffffffc020337c:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020337e:	fe878713          	addi	a4,a5,-24
ffffffffc0203382:	00d78963          	beq	a5,a3,ffffffffc0203394 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0203386:	4910                	lw	a2,16(a0)
ffffffffc0203388:	02061693          	slli	a3,a2,0x20
ffffffffc020338c:	82e9                	srli	a3,a3,0x1a
ffffffffc020338e:	96aa                	add	a3,a3,a0
ffffffffc0203390:	00d70e63          	beq	a4,a3,ffffffffc02033ac <default_free_pages+0x140>
}
ffffffffc0203394:	60a2                	ld	ra,8(sp)
ffffffffc0203396:	0141                	addi	sp,sp,16
ffffffffc0203398:	8082                	ret
ffffffffc020339a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020339c:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02033a0:	e398                	sd	a4,0(a5)
ffffffffc02033a2:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02033a4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02033a6:	ed1c                	sd	a5,24(a0)
}
ffffffffc02033a8:	0141                	addi	sp,sp,16
ffffffffc02033aa:	8082                	ret
            base->property += p->property;
ffffffffc02033ac:	ff87a703          	lw	a4,-8(a5)
ffffffffc02033b0:	ff078693          	addi	a3,a5,-16
ffffffffc02033b4:	9e39                	addw	a2,a2,a4
ffffffffc02033b6:	c910                	sw	a2,16(a0)
ffffffffc02033b8:	5775                	li	a4,-3
ffffffffc02033ba:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02033be:	6398                	ld	a4,0(a5)
ffffffffc02033c0:	679c                	ld	a5,8(a5)
}
ffffffffc02033c2:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02033c4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02033c6:	e398                	sd	a4,0(a5)
ffffffffc02033c8:	0141                	addi	sp,sp,16
ffffffffc02033ca:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02033cc:	00005697          	auipc	a3,0x5
ffffffffc02033d0:	90468693          	addi	a3,a3,-1788 # ffffffffc0207cd0 <commands+0x1598>
ffffffffc02033d4:	00003617          	auipc	a2,0x3
ffffffffc02033d8:	7e460613          	addi	a2,a2,2020 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02033dc:	08300593          	li	a1,131
ffffffffc02033e0:	00004517          	auipc	a0,0x4
ffffffffc02033e4:	5e050513          	addi	a0,a0,1504 # ffffffffc02079c0 <commands+0x1288>
ffffffffc02033e8:	e2ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(n > 0);
ffffffffc02033ec:	00005697          	auipc	a3,0x5
ffffffffc02033f0:	90c68693          	addi	a3,a3,-1780 # ffffffffc0207cf8 <commands+0x15c0>
ffffffffc02033f4:	00003617          	auipc	a2,0x3
ffffffffc02033f8:	7c460613          	addi	a2,a2,1988 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02033fc:	08000593          	li	a1,128
ffffffffc0203400:	00004517          	auipc	a0,0x4
ffffffffc0203404:	5c050513          	addi	a0,a0,1472 # ffffffffc02079c0 <commands+0x1288>
ffffffffc0203408:	e0ffc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020340c <default_alloc_pages>:
    assert(n > 0);
ffffffffc020340c:	c959                	beqz	a0,ffffffffc02034a2 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020340e:	000a9597          	auipc	a1,0xa9
ffffffffc0203412:	08a58593          	addi	a1,a1,138 # ffffffffc02ac498 <free_area>
ffffffffc0203416:	0105a803          	lw	a6,16(a1)
ffffffffc020341a:	862a                	mv	a2,a0
ffffffffc020341c:	02081793          	slli	a5,a6,0x20
ffffffffc0203420:	9381                	srli	a5,a5,0x20
ffffffffc0203422:	00a7ee63          	bltu	a5,a0,ffffffffc020343e <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203426:	87ae                	mv	a5,a1
ffffffffc0203428:	a801                	j	ffffffffc0203438 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020342a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020342e:	02071693          	slli	a3,a4,0x20
ffffffffc0203432:	9281                	srli	a3,a3,0x20
ffffffffc0203434:	00c6f763          	bleu	a2,a3,ffffffffc0203442 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203438:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020343a:	feb798e3          	bne	a5,a1,ffffffffc020342a <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020343e:	4501                	li	a0,0
}
ffffffffc0203440:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0203442:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0203446:	dd6d                	beqz	a0,ffffffffc0203440 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0203448:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020344c:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0203450:	00060e1b          	sext.w	t3,a2
ffffffffc0203454:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0203458:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020345c:	02d67863          	bleu	a3,a2,ffffffffc020348c <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0203460:	061a                	slli	a2,a2,0x6
ffffffffc0203462:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0203464:	41c7073b          	subw	a4,a4,t3
ffffffffc0203468:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020346a:	00860693          	addi	a3,a2,8
ffffffffc020346e:	4709                	li	a4,2
ffffffffc0203470:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203474:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203478:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc020347c:	0105a803          	lw	a6,16(a1)
ffffffffc0203480:	e314                	sd	a3,0(a4)
ffffffffc0203482:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0203486:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0203488:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc020348c:	41c8083b          	subw	a6,a6,t3
ffffffffc0203490:	000a9717          	auipc	a4,0xa9
ffffffffc0203494:	01072c23          	sw	a6,24(a4) # ffffffffc02ac4a8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203498:	5775                	li	a4,-3
ffffffffc020349a:	17c1                	addi	a5,a5,-16
ffffffffc020349c:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02034a0:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02034a2:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02034a4:	00005697          	auipc	a3,0x5
ffffffffc02034a8:	85468693          	addi	a3,a3,-1964 # ffffffffc0207cf8 <commands+0x15c0>
ffffffffc02034ac:	00003617          	auipc	a2,0x3
ffffffffc02034b0:	70c60613          	addi	a2,a2,1804 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02034b4:	06200593          	li	a1,98
ffffffffc02034b8:	00004517          	auipc	a0,0x4
ffffffffc02034bc:	50850513          	addi	a0,a0,1288 # ffffffffc02079c0 <commands+0x1288>
default_alloc_pages(size_t n) {
ffffffffc02034c0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02034c2:	d55fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02034c6 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02034c6:	1141                	addi	sp,sp,-16
ffffffffc02034c8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02034ca:	c1ed                	beqz	a1,ffffffffc02035ac <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc02034cc:	00659693          	slli	a3,a1,0x6
ffffffffc02034d0:	96aa                	add	a3,a3,a0
ffffffffc02034d2:	02d50463          	beq	a0,a3,ffffffffc02034fa <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02034d6:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02034d8:	87aa                	mv	a5,a0
ffffffffc02034da:	8b05                	andi	a4,a4,1
ffffffffc02034dc:	e709                	bnez	a4,ffffffffc02034e6 <default_init_memmap+0x20>
ffffffffc02034de:	a07d                	j	ffffffffc020358c <default_init_memmap+0xc6>
ffffffffc02034e0:	6798                	ld	a4,8(a5)
ffffffffc02034e2:	8b05                	andi	a4,a4,1
ffffffffc02034e4:	c745                	beqz	a4,ffffffffc020358c <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02034e6:	0007a823          	sw	zero,16(a5)
ffffffffc02034ea:	0007b423          	sd	zero,8(a5)
ffffffffc02034ee:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02034f2:	04078793          	addi	a5,a5,64
ffffffffc02034f6:	fed795e3          	bne	a5,a3,ffffffffc02034e0 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02034fa:	2581                	sext.w	a1,a1
ffffffffc02034fc:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02034fe:	4789                	li	a5,2
ffffffffc0203500:	00850713          	addi	a4,a0,8
ffffffffc0203504:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0203508:	000a9697          	auipc	a3,0xa9
ffffffffc020350c:	f9068693          	addi	a3,a3,-112 # ffffffffc02ac498 <free_area>
ffffffffc0203510:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203512:	669c                	ld	a5,8(a3)
ffffffffc0203514:	9db9                	addw	a1,a1,a4
ffffffffc0203516:	000a9717          	auipc	a4,0xa9
ffffffffc020351a:	f8b72923          	sw	a1,-110(a4) # ffffffffc02ac4a8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020351e:	04d78a63          	beq	a5,a3,ffffffffc0203572 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0203522:	fe878713          	addi	a4,a5,-24
ffffffffc0203526:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203528:	4801                	li	a6,0
ffffffffc020352a:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020352e:	00e56a63          	bltu	a0,a4,ffffffffc0203542 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0203532:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203534:	02d70563          	beq	a4,a3,ffffffffc020355e <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203538:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020353a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020353e:	fee57ae3          	bleu	a4,a0,ffffffffc0203532 <default_init_memmap+0x6c>
ffffffffc0203542:	00080663          	beqz	a6,ffffffffc020354e <default_init_memmap+0x88>
ffffffffc0203546:	000a9717          	auipc	a4,0xa9
ffffffffc020354a:	f4b73923          	sd	a1,-174(a4) # ffffffffc02ac498 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020354e:	6398                	ld	a4,0(a5)
}
ffffffffc0203550:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203552:	e390                	sd	a2,0(a5)
ffffffffc0203554:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203556:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203558:	ed18                	sd	a4,24(a0)
ffffffffc020355a:	0141                	addi	sp,sp,16
ffffffffc020355c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020355e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203560:	f114                	sd	a3,32(a0)
ffffffffc0203562:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203564:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0203566:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203568:	00d70e63          	beq	a4,a3,ffffffffc0203584 <default_init_memmap+0xbe>
ffffffffc020356c:	4805                	li	a6,1
ffffffffc020356e:	87ba                	mv	a5,a4
ffffffffc0203570:	b7e9                	j	ffffffffc020353a <default_init_memmap+0x74>
}
ffffffffc0203572:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203574:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0203578:	e398                	sd	a4,0(a5)
ffffffffc020357a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020357c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020357e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0203580:	0141                	addi	sp,sp,16
ffffffffc0203582:	8082                	ret
ffffffffc0203584:	60a2                	ld	ra,8(sp)
ffffffffc0203586:	e290                	sd	a2,0(a3)
ffffffffc0203588:	0141                	addi	sp,sp,16
ffffffffc020358a:	8082                	ret
        assert(PageReserved(p));
ffffffffc020358c:	00004697          	auipc	a3,0x4
ffffffffc0203590:	77468693          	addi	a3,a3,1908 # ffffffffc0207d00 <commands+0x15c8>
ffffffffc0203594:	00003617          	auipc	a2,0x3
ffffffffc0203598:	62460613          	addi	a2,a2,1572 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020359c:	04900593          	li	a1,73
ffffffffc02035a0:	00004517          	auipc	a0,0x4
ffffffffc02035a4:	42050513          	addi	a0,a0,1056 # ffffffffc02079c0 <commands+0x1288>
ffffffffc02035a8:	c6ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(n > 0);
ffffffffc02035ac:	00004697          	auipc	a3,0x4
ffffffffc02035b0:	74c68693          	addi	a3,a3,1868 # ffffffffc0207cf8 <commands+0x15c0>
ffffffffc02035b4:	00003617          	auipc	a2,0x3
ffffffffc02035b8:	60460613          	addi	a2,a2,1540 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02035bc:	04600593          	li	a1,70
ffffffffc02035c0:	00004517          	auipc	a0,0x4
ffffffffc02035c4:	40050513          	addi	a0,a0,1024 # ffffffffc02079c0 <commands+0x1288>
ffffffffc02035c8:	c4ffc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02035cc <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc02035cc:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02035ce:	00004617          	auipc	a2,0x4
ffffffffc02035d2:	cf260613          	addi	a2,a2,-782 # ffffffffc02072c0 <commands+0xb88>
ffffffffc02035d6:	06200593          	li	a1,98
ffffffffc02035da:	00004517          	auipc	a0,0x4
ffffffffc02035de:	d0650513          	addi	a0,a0,-762 # ffffffffc02072e0 <commands+0xba8>
pa2page(uintptr_t pa) {
ffffffffc02035e2:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02035e4:	c33fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02035e8 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02035e8:	715d                	addi	sp,sp,-80
ffffffffc02035ea:	e0a2                	sd	s0,64(sp)
ffffffffc02035ec:	fc26                	sd	s1,56(sp)
ffffffffc02035ee:	f84a                	sd	s2,48(sp)
ffffffffc02035f0:	f44e                	sd	s3,40(sp)
ffffffffc02035f2:	f052                	sd	s4,32(sp)
ffffffffc02035f4:	ec56                	sd	s5,24(sp)
ffffffffc02035f6:	e486                	sd	ra,72(sp)
ffffffffc02035f8:	842a                	mv	s0,a0
ffffffffc02035fa:	000a9497          	auipc	s1,0xa9
ffffffffc02035fe:	eb648493          	addi	s1,s1,-330 # ffffffffc02ac4b0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203602:	4985                	li	s3,1
ffffffffc0203604:	000a9a17          	auipc	s4,0xa9
ffffffffc0203608:	d74a0a13          	addi	s4,s4,-652 # ffffffffc02ac378 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc020360c:	0005091b          	sext.w	s2,a0
ffffffffc0203610:	000a9a97          	auipc	s5,0xa9
ffffffffc0203614:	da8a8a93          	addi	s5,s5,-600 # ffffffffc02ac3b8 <check_mm_struct>
ffffffffc0203618:	a00d                	j	ffffffffc020363a <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc020361a:	609c                	ld	a5,0(s1)
ffffffffc020361c:	6f9c                	ld	a5,24(a5)
ffffffffc020361e:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0203620:	4601                	li	a2,0
ffffffffc0203622:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203624:	ed0d                	bnez	a0,ffffffffc020365e <alloc_pages+0x76>
ffffffffc0203626:	0289ec63          	bltu	s3,s0,ffffffffc020365e <alloc_pages+0x76>
ffffffffc020362a:	000a2783          	lw	a5,0(s4)
ffffffffc020362e:	2781                	sext.w	a5,a5
ffffffffc0203630:	c79d                	beqz	a5,ffffffffc020365e <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0203632:	000ab503          	ld	a0,0(s5)
ffffffffc0203636:	abaff0ef          	jal	ra,ffffffffc02028f0 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020363a:	100027f3          	csrr	a5,sstatus
ffffffffc020363e:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0203640:	8522                	mv	a0,s0
ffffffffc0203642:	dfe1                	beqz	a5,ffffffffc020361a <alloc_pages+0x32>
        intr_disable();
ffffffffc0203644:	818fd0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0203648:	609c                	ld	a5,0(s1)
ffffffffc020364a:	8522                	mv	a0,s0
ffffffffc020364c:	6f9c                	ld	a5,24(a5)
ffffffffc020364e:	9782                	jalr	a5
ffffffffc0203650:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0203652:	804fd0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0203656:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0203658:	4601                	li	a2,0
ffffffffc020365a:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020365c:	d569                	beqz	a0,ffffffffc0203626 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020365e:	60a6                	ld	ra,72(sp)
ffffffffc0203660:	6406                	ld	s0,64(sp)
ffffffffc0203662:	74e2                	ld	s1,56(sp)
ffffffffc0203664:	7942                	ld	s2,48(sp)
ffffffffc0203666:	79a2                	ld	s3,40(sp)
ffffffffc0203668:	7a02                	ld	s4,32(sp)
ffffffffc020366a:	6ae2                	ld	s5,24(sp)
ffffffffc020366c:	6161                	addi	sp,sp,80
ffffffffc020366e:	8082                	ret

ffffffffc0203670 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203670:	100027f3          	csrr	a5,sstatus
ffffffffc0203674:	8b89                	andi	a5,a5,2
ffffffffc0203676:	eb89                	bnez	a5,ffffffffc0203688 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0203678:	000a9797          	auipc	a5,0xa9
ffffffffc020367c:	e3878793          	addi	a5,a5,-456 # ffffffffc02ac4b0 <pmm_manager>
ffffffffc0203680:	639c                	ld	a5,0(a5)
ffffffffc0203682:	0207b303          	ld	t1,32(a5)
ffffffffc0203686:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0203688:	1101                	addi	sp,sp,-32
ffffffffc020368a:	ec06                	sd	ra,24(sp)
ffffffffc020368c:	e822                	sd	s0,16(sp)
ffffffffc020368e:	e426                	sd	s1,8(sp)
ffffffffc0203690:	842a                	mv	s0,a0
ffffffffc0203692:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0203694:	fc9fc0ef          	jal	ra,ffffffffc020065c <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203698:	000a9797          	auipc	a5,0xa9
ffffffffc020369c:	e1878793          	addi	a5,a5,-488 # ffffffffc02ac4b0 <pmm_manager>
ffffffffc02036a0:	639c                	ld	a5,0(a5)
ffffffffc02036a2:	85a6                	mv	a1,s1
ffffffffc02036a4:	8522                	mv	a0,s0
ffffffffc02036a6:	739c                	ld	a5,32(a5)
ffffffffc02036a8:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02036aa:	6442                	ld	s0,16(sp)
ffffffffc02036ac:	60e2                	ld	ra,24(sp)
ffffffffc02036ae:	64a2                	ld	s1,8(sp)
ffffffffc02036b0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02036b2:	fa5fc06f          	j	ffffffffc0200656 <intr_enable>

ffffffffc02036b6 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02036b6:	100027f3          	csrr	a5,sstatus
ffffffffc02036ba:	8b89                	andi	a5,a5,2
ffffffffc02036bc:	eb89                	bnez	a5,ffffffffc02036ce <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02036be:	000a9797          	auipc	a5,0xa9
ffffffffc02036c2:	df278793          	addi	a5,a5,-526 # ffffffffc02ac4b0 <pmm_manager>
ffffffffc02036c6:	639c                	ld	a5,0(a5)
ffffffffc02036c8:	0287b303          	ld	t1,40(a5)
ffffffffc02036cc:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc02036ce:	1141                	addi	sp,sp,-16
ffffffffc02036d0:	e406                	sd	ra,8(sp)
ffffffffc02036d2:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02036d4:	f89fc0ef          	jal	ra,ffffffffc020065c <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02036d8:	000a9797          	auipc	a5,0xa9
ffffffffc02036dc:	dd878793          	addi	a5,a5,-552 # ffffffffc02ac4b0 <pmm_manager>
ffffffffc02036e0:	639c                	ld	a5,0(a5)
ffffffffc02036e2:	779c                	ld	a5,40(a5)
ffffffffc02036e4:	9782                	jalr	a5
ffffffffc02036e6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02036e8:	f6ffc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02036ec:	8522                	mv	a0,s0
ffffffffc02036ee:	60a2                	ld	ra,8(sp)
ffffffffc02036f0:	6402                	ld	s0,0(sp)
ffffffffc02036f2:	0141                	addi	sp,sp,16
ffffffffc02036f4:	8082                	ret

ffffffffc02036f6 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02036f6:	7139                	addi	sp,sp,-64
ffffffffc02036f8:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02036fa:	01e5d493          	srli	s1,a1,0x1e
ffffffffc02036fe:	1ff4f493          	andi	s1,s1,511
ffffffffc0203702:	048e                	slli	s1,s1,0x3
ffffffffc0203704:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203706:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203708:	f04a                	sd	s2,32(sp)
ffffffffc020370a:	ec4e                	sd	s3,24(sp)
ffffffffc020370c:	e852                	sd	s4,16(sp)
ffffffffc020370e:	fc06                	sd	ra,56(sp)
ffffffffc0203710:	f822                	sd	s0,48(sp)
ffffffffc0203712:	e456                	sd	s5,8(sp)
ffffffffc0203714:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203716:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020371a:	892e                	mv	s2,a1
ffffffffc020371c:	8a32                	mv	s4,a2
ffffffffc020371e:	000a9997          	auipc	s3,0xa9
ffffffffc0203722:	c6a98993          	addi	s3,s3,-918 # ffffffffc02ac388 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203726:	e7bd                	bnez	a5,ffffffffc0203794 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203728:	12060c63          	beqz	a2,ffffffffc0203860 <get_pte+0x16a>
ffffffffc020372c:	4505                	li	a0,1
ffffffffc020372e:	ebbff0ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0203732:	842a                	mv	s0,a0
ffffffffc0203734:	12050663          	beqz	a0,ffffffffc0203860 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203738:	000a9b17          	auipc	s6,0xa9
ffffffffc020373c:	d90b0b13          	addi	s6,s6,-624 # ffffffffc02ac4c8 <pages>
ffffffffc0203740:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0203744:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203746:	000a9997          	auipc	s3,0xa9
ffffffffc020374a:	c4298993          	addi	s3,s3,-958 # ffffffffc02ac388 <npage>
    return page - pages + nbase;
ffffffffc020374e:	40a40533          	sub	a0,s0,a0
ffffffffc0203752:	00080ab7          	lui	s5,0x80
ffffffffc0203756:	8519                	srai	a0,a0,0x6
ffffffffc0203758:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020375c:	c01c                	sw	a5,0(s0)
ffffffffc020375e:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0203760:	9556                	add	a0,a0,s5
ffffffffc0203762:	83b1                	srli	a5,a5,0xc
ffffffffc0203764:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203766:	0532                	slli	a0,a0,0xc
ffffffffc0203768:	14e7f363          	bleu	a4,a5,ffffffffc02038ae <get_pte+0x1b8>
ffffffffc020376c:	000a9797          	auipc	a5,0xa9
ffffffffc0203770:	d4c78793          	addi	a5,a5,-692 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc0203774:	639c                	ld	a5,0(a5)
ffffffffc0203776:	6605                	lui	a2,0x1
ffffffffc0203778:	4581                	li	a1,0
ffffffffc020377a:	953e                	add	a0,a0,a5
ffffffffc020377c:	213020ef          	jal	ra,ffffffffc020618e <memset>
    return page - pages + nbase;
ffffffffc0203780:	000b3683          	ld	a3,0(s6)
ffffffffc0203784:	40d406b3          	sub	a3,s0,a3
ffffffffc0203788:	8699                	srai	a3,a3,0x6
ffffffffc020378a:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020378c:	06aa                	slli	a3,a3,0xa
ffffffffc020378e:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0203792:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0203794:	77fd                	lui	a5,0xfffff
ffffffffc0203796:	068a                	slli	a3,a3,0x2
ffffffffc0203798:	0009b703          	ld	a4,0(s3)
ffffffffc020379c:	8efd                	and	a3,a3,a5
ffffffffc020379e:	00c6d793          	srli	a5,a3,0xc
ffffffffc02037a2:	0ce7f163          	bleu	a4,a5,ffffffffc0203864 <get_pte+0x16e>
ffffffffc02037a6:	000a9a97          	auipc	s5,0xa9
ffffffffc02037aa:	d12a8a93          	addi	s5,s5,-750 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc02037ae:	000ab403          	ld	s0,0(s5)
ffffffffc02037b2:	01595793          	srli	a5,s2,0x15
ffffffffc02037b6:	1ff7f793          	andi	a5,a5,511
ffffffffc02037ba:	96a2                	add	a3,a3,s0
ffffffffc02037bc:	00379413          	slli	s0,a5,0x3
ffffffffc02037c0:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc02037c2:	6014                	ld	a3,0(s0)
ffffffffc02037c4:	0016f793          	andi	a5,a3,1
ffffffffc02037c8:	e3ad                	bnez	a5,ffffffffc020382a <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02037ca:	080a0b63          	beqz	s4,ffffffffc0203860 <get_pte+0x16a>
ffffffffc02037ce:	4505                	li	a0,1
ffffffffc02037d0:	e19ff0ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc02037d4:	84aa                	mv	s1,a0
ffffffffc02037d6:	c549                	beqz	a0,ffffffffc0203860 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc02037d8:	000a9b17          	auipc	s6,0xa9
ffffffffc02037dc:	cf0b0b13          	addi	s6,s6,-784 # ffffffffc02ac4c8 <pages>
ffffffffc02037e0:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc02037e4:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc02037e6:	00080a37          	lui	s4,0x80
ffffffffc02037ea:	40a48533          	sub	a0,s1,a0
ffffffffc02037ee:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02037f0:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc02037f4:	c09c                	sw	a5,0(s1)
ffffffffc02037f6:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc02037f8:	9552                	add	a0,a0,s4
ffffffffc02037fa:	83b1                	srli	a5,a5,0xc
ffffffffc02037fc:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02037fe:	0532                	slli	a0,a0,0xc
ffffffffc0203800:	08e7fa63          	bleu	a4,a5,ffffffffc0203894 <get_pte+0x19e>
ffffffffc0203804:	000ab783          	ld	a5,0(s5)
ffffffffc0203808:	6605                	lui	a2,0x1
ffffffffc020380a:	4581                	li	a1,0
ffffffffc020380c:	953e                	add	a0,a0,a5
ffffffffc020380e:	181020ef          	jal	ra,ffffffffc020618e <memset>
    return page - pages + nbase;
ffffffffc0203812:	000b3683          	ld	a3,0(s6)
ffffffffc0203816:	40d486b3          	sub	a3,s1,a3
ffffffffc020381a:	8699                	srai	a3,a3,0x6
ffffffffc020381c:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020381e:	06aa                	slli	a3,a3,0xa
ffffffffc0203820:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0203824:	e014                	sd	a3,0(s0)
ffffffffc0203826:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020382a:	068a                	slli	a3,a3,0x2
ffffffffc020382c:	757d                	lui	a0,0xfffff
ffffffffc020382e:	8ee9                	and	a3,a3,a0
ffffffffc0203830:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203834:	04e7f463          	bleu	a4,a5,ffffffffc020387c <get_pte+0x186>
ffffffffc0203838:	000ab503          	ld	a0,0(s5)
ffffffffc020383c:	00c95793          	srli	a5,s2,0xc
ffffffffc0203840:	1ff7f793          	andi	a5,a5,511
ffffffffc0203844:	96aa                	add	a3,a3,a0
ffffffffc0203846:	00379513          	slli	a0,a5,0x3
ffffffffc020384a:	9536                	add	a0,a0,a3
}
ffffffffc020384c:	70e2                	ld	ra,56(sp)
ffffffffc020384e:	7442                	ld	s0,48(sp)
ffffffffc0203850:	74a2                	ld	s1,40(sp)
ffffffffc0203852:	7902                	ld	s2,32(sp)
ffffffffc0203854:	69e2                	ld	s3,24(sp)
ffffffffc0203856:	6a42                	ld	s4,16(sp)
ffffffffc0203858:	6aa2                	ld	s5,8(sp)
ffffffffc020385a:	6b02                	ld	s6,0(sp)
ffffffffc020385c:	6121                	addi	sp,sp,64
ffffffffc020385e:	8082                	ret
            return NULL;
ffffffffc0203860:	4501                	li	a0,0
ffffffffc0203862:	b7ed                	j	ffffffffc020384c <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0203864:	00004617          	auipc	a2,0x4
ffffffffc0203868:	a8c60613          	addi	a2,a2,-1396 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc020386c:	0e300593          	li	a1,227
ffffffffc0203870:	00004517          	auipc	a0,0x4
ffffffffc0203874:	51050513          	addi	a0,a0,1296 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0203878:	99ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020387c:	00004617          	auipc	a2,0x4
ffffffffc0203880:	a7460613          	addi	a2,a2,-1420 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc0203884:	0ee00593          	li	a1,238
ffffffffc0203888:	00004517          	auipc	a0,0x4
ffffffffc020388c:	4f850513          	addi	a0,a0,1272 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0203890:	987fc0ef          	jal	ra,ffffffffc0200216 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203894:	86aa                	mv	a3,a0
ffffffffc0203896:	00004617          	auipc	a2,0x4
ffffffffc020389a:	a5a60613          	addi	a2,a2,-1446 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc020389e:	0eb00593          	li	a1,235
ffffffffc02038a2:	00004517          	auipc	a0,0x4
ffffffffc02038a6:	4de50513          	addi	a0,a0,1246 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02038aa:	96dfc0ef          	jal	ra,ffffffffc0200216 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02038ae:	86aa                	mv	a3,a0
ffffffffc02038b0:	00004617          	auipc	a2,0x4
ffffffffc02038b4:	a4060613          	addi	a2,a2,-1472 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc02038b8:	0df00593          	li	a1,223
ffffffffc02038bc:	00004517          	auipc	a0,0x4
ffffffffc02038c0:	4c450513          	addi	a0,a0,1220 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02038c4:	953fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02038c8 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02038c8:	1141                	addi	sp,sp,-16
ffffffffc02038ca:	e022                	sd	s0,0(sp)
ffffffffc02038cc:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02038ce:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02038d0:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02038d2:	e25ff0ef          	jal	ra,ffffffffc02036f6 <get_pte>
    if (ptep_store != NULL) {
ffffffffc02038d6:	c011                	beqz	s0,ffffffffc02038da <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02038d8:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02038da:	c129                	beqz	a0,ffffffffc020391c <get_page+0x54>
ffffffffc02038dc:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02038de:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02038e0:	0017f713          	andi	a4,a5,1
ffffffffc02038e4:	e709                	bnez	a4,ffffffffc02038ee <get_page+0x26>
}
ffffffffc02038e6:	60a2                	ld	ra,8(sp)
ffffffffc02038e8:	6402                	ld	s0,0(sp)
ffffffffc02038ea:	0141                	addi	sp,sp,16
ffffffffc02038ec:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02038ee:	000a9717          	auipc	a4,0xa9
ffffffffc02038f2:	a9a70713          	addi	a4,a4,-1382 # ffffffffc02ac388 <npage>
ffffffffc02038f6:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02038f8:	078a                	slli	a5,a5,0x2
ffffffffc02038fa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02038fc:	02e7f563          	bleu	a4,a5,ffffffffc0203926 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203900:	000a9717          	auipc	a4,0xa9
ffffffffc0203904:	bc870713          	addi	a4,a4,-1080 # ffffffffc02ac4c8 <pages>
ffffffffc0203908:	6308                	ld	a0,0(a4)
ffffffffc020390a:	60a2                	ld	ra,8(sp)
ffffffffc020390c:	6402                	ld	s0,0(sp)
ffffffffc020390e:	fff80737          	lui	a4,0xfff80
ffffffffc0203912:	97ba                	add	a5,a5,a4
ffffffffc0203914:	079a                	slli	a5,a5,0x6
ffffffffc0203916:	953e                	add	a0,a0,a5
ffffffffc0203918:	0141                	addi	sp,sp,16
ffffffffc020391a:	8082                	ret
ffffffffc020391c:	60a2                	ld	ra,8(sp)
ffffffffc020391e:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0203920:	4501                	li	a0,0
}
ffffffffc0203922:	0141                	addi	sp,sp,16
ffffffffc0203924:	8082                	ret
ffffffffc0203926:	ca7ff0ef          	jal	ra,ffffffffc02035cc <pa2page.part.4>

ffffffffc020392a <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020392a:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020392c:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203930:	ec86                	sd	ra,88(sp)
ffffffffc0203932:	e8a2                	sd	s0,80(sp)
ffffffffc0203934:	e4a6                	sd	s1,72(sp)
ffffffffc0203936:	e0ca                	sd	s2,64(sp)
ffffffffc0203938:	fc4e                	sd	s3,56(sp)
ffffffffc020393a:	f852                	sd	s4,48(sp)
ffffffffc020393c:	f456                	sd	s5,40(sp)
ffffffffc020393e:	f05a                	sd	s6,32(sp)
ffffffffc0203940:	ec5e                	sd	s7,24(sp)
ffffffffc0203942:	e862                	sd	s8,16(sp)
ffffffffc0203944:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203946:	03479713          	slli	a4,a5,0x34
ffffffffc020394a:	eb71                	bnez	a4,ffffffffc0203a1e <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc020394c:	002007b7          	lui	a5,0x200
ffffffffc0203950:	842e                	mv	s0,a1
ffffffffc0203952:	0af5e663          	bltu	a1,a5,ffffffffc02039fe <unmap_range+0xd4>
ffffffffc0203956:	8932                	mv	s2,a2
ffffffffc0203958:	0ac5f363          	bleu	a2,a1,ffffffffc02039fe <unmap_range+0xd4>
ffffffffc020395c:	4785                	li	a5,1
ffffffffc020395e:	07fe                	slli	a5,a5,0x1f
ffffffffc0203960:	08c7ef63          	bltu	a5,a2,ffffffffc02039fe <unmap_range+0xd4>
ffffffffc0203964:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0203966:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203968:	000a9c97          	auipc	s9,0xa9
ffffffffc020396c:	a20c8c93          	addi	s9,s9,-1504 # ffffffffc02ac388 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203970:	000a9c17          	auipc	s8,0xa9
ffffffffc0203974:	b58c0c13          	addi	s8,s8,-1192 # ffffffffc02ac4c8 <pages>
ffffffffc0203978:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020397c:	00200b37          	lui	s6,0x200
ffffffffc0203980:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0203984:	4601                	li	a2,0
ffffffffc0203986:	85a2                	mv	a1,s0
ffffffffc0203988:	854e                	mv	a0,s3
ffffffffc020398a:	d6dff0ef          	jal	ra,ffffffffc02036f6 <get_pte>
ffffffffc020398e:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0203990:	cd21                	beqz	a0,ffffffffc02039e8 <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc0203992:	611c                	ld	a5,0(a0)
ffffffffc0203994:	e38d                	bnez	a5,ffffffffc02039b6 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc0203996:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203998:	ff2466e3          	bltu	s0,s2,ffffffffc0203984 <unmap_range+0x5a>
}
ffffffffc020399c:	60e6                	ld	ra,88(sp)
ffffffffc020399e:	6446                	ld	s0,80(sp)
ffffffffc02039a0:	64a6                	ld	s1,72(sp)
ffffffffc02039a2:	6906                	ld	s2,64(sp)
ffffffffc02039a4:	79e2                	ld	s3,56(sp)
ffffffffc02039a6:	7a42                	ld	s4,48(sp)
ffffffffc02039a8:	7aa2                	ld	s5,40(sp)
ffffffffc02039aa:	7b02                	ld	s6,32(sp)
ffffffffc02039ac:	6be2                	ld	s7,24(sp)
ffffffffc02039ae:	6c42                	ld	s8,16(sp)
ffffffffc02039b0:	6ca2                	ld	s9,8(sp)
ffffffffc02039b2:	6125                	addi	sp,sp,96
ffffffffc02039b4:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02039b6:	0017f713          	andi	a4,a5,1
ffffffffc02039ba:	df71                	beqz	a4,ffffffffc0203996 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc02039bc:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02039c0:	078a                	slli	a5,a5,0x2
ffffffffc02039c2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02039c4:	06e7fd63          	bleu	a4,a5,ffffffffc0203a3e <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc02039c8:	000c3503          	ld	a0,0(s8)
ffffffffc02039cc:	97de                	add	a5,a5,s7
ffffffffc02039ce:	079a                	slli	a5,a5,0x6
ffffffffc02039d0:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02039d2:	411c                	lw	a5,0(a0)
ffffffffc02039d4:	fff7871b          	addiw	a4,a5,-1
ffffffffc02039d8:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02039da:	cf11                	beqz	a4,ffffffffc02039f6 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02039dc:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02039e0:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02039e4:	9452                	add	s0,s0,s4
ffffffffc02039e6:	bf4d                	j	ffffffffc0203998 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02039e8:	945a                	add	s0,s0,s6
ffffffffc02039ea:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02039ee:	d45d                	beqz	s0,ffffffffc020399c <unmap_range+0x72>
ffffffffc02039f0:	f9246ae3          	bltu	s0,s2,ffffffffc0203984 <unmap_range+0x5a>
ffffffffc02039f4:	b765                	j	ffffffffc020399c <unmap_range+0x72>
            free_page(page);
ffffffffc02039f6:	4585                	li	a1,1
ffffffffc02039f8:	c79ff0ef          	jal	ra,ffffffffc0203670 <free_pages>
ffffffffc02039fc:	b7c5                	j	ffffffffc02039dc <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc02039fe:	00005697          	auipc	a3,0x5
ffffffffc0203a02:	90268693          	addi	a3,a3,-1790 # ffffffffc0208300 <default_pmm_manager+0x5f0>
ffffffffc0203a06:	00003617          	auipc	a2,0x3
ffffffffc0203a0a:	1b260613          	addi	a2,a2,434 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203a0e:	11000593          	li	a1,272
ffffffffc0203a12:	00004517          	auipc	a0,0x4
ffffffffc0203a16:	36e50513          	addi	a0,a0,878 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0203a1a:	ffcfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203a1e:	00005697          	auipc	a3,0x5
ffffffffc0203a22:	8b268693          	addi	a3,a3,-1870 # ffffffffc02082d0 <default_pmm_manager+0x5c0>
ffffffffc0203a26:	00003617          	auipc	a2,0x3
ffffffffc0203a2a:	19260613          	addi	a2,a2,402 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203a2e:	10f00593          	li	a1,271
ffffffffc0203a32:	00004517          	auipc	a0,0x4
ffffffffc0203a36:	34e50513          	addi	a0,a0,846 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0203a3a:	fdcfc0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0203a3e:	b8fff0ef          	jal	ra,ffffffffc02035cc <pa2page.part.4>

ffffffffc0203a42 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203a42:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203a44:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203a48:	fc86                	sd	ra,120(sp)
ffffffffc0203a4a:	f8a2                	sd	s0,112(sp)
ffffffffc0203a4c:	f4a6                	sd	s1,104(sp)
ffffffffc0203a4e:	f0ca                	sd	s2,96(sp)
ffffffffc0203a50:	ecce                	sd	s3,88(sp)
ffffffffc0203a52:	e8d2                	sd	s4,80(sp)
ffffffffc0203a54:	e4d6                	sd	s5,72(sp)
ffffffffc0203a56:	e0da                	sd	s6,64(sp)
ffffffffc0203a58:	fc5e                	sd	s7,56(sp)
ffffffffc0203a5a:	f862                	sd	s8,48(sp)
ffffffffc0203a5c:	f466                	sd	s9,40(sp)
ffffffffc0203a5e:	f06a                	sd	s10,32(sp)
ffffffffc0203a60:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203a62:	03479713          	slli	a4,a5,0x34
ffffffffc0203a66:	1c071163          	bnez	a4,ffffffffc0203c28 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc0203a6a:	002007b7          	lui	a5,0x200
ffffffffc0203a6e:	20f5e563          	bltu	a1,a5,ffffffffc0203c78 <exit_range+0x236>
ffffffffc0203a72:	8b32                	mv	s6,a2
ffffffffc0203a74:	20c5f263          	bleu	a2,a1,ffffffffc0203c78 <exit_range+0x236>
ffffffffc0203a78:	4785                	li	a5,1
ffffffffc0203a7a:	07fe                	slli	a5,a5,0x1f
ffffffffc0203a7c:	1ec7ee63          	bltu	a5,a2,ffffffffc0203c78 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0203a80:	c00009b7          	lui	s3,0xc0000
ffffffffc0203a84:	400007b7          	lui	a5,0x40000
ffffffffc0203a88:	0135f9b3          	and	s3,a1,s3
ffffffffc0203a8c:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0203a8e:	c0000337          	lui	t1,0xc0000
ffffffffc0203a92:	00698933          	add	s2,s3,t1
ffffffffc0203a96:	01e95913          	srli	s2,s2,0x1e
ffffffffc0203a9a:	1ff97913          	andi	s2,s2,511
ffffffffc0203a9e:	8e2a                	mv	t3,a0
ffffffffc0203aa0:	090e                	slli	s2,s2,0x3
ffffffffc0203aa2:	9972                	add	s2,s2,t3
ffffffffc0203aa4:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0203aa8:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0203aac:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc0203aae:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0203ab2:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc0203ab4:	000a9d17          	auipc	s10,0xa9
ffffffffc0203ab8:	8d4d0d13          	addi	s10,s10,-1836 # ffffffffc02ac388 <npage>
    return KADDR(page2pa(page));
ffffffffc0203abc:	00cddd93          	srli	s11,s11,0xc
ffffffffc0203ac0:	000a9717          	auipc	a4,0xa9
ffffffffc0203ac4:	9f870713          	addi	a4,a4,-1544 # ffffffffc02ac4b8 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ac8:	000a9e97          	auipc	t4,0xa9
ffffffffc0203acc:	a00e8e93          	addi	t4,t4,-1536 # ffffffffc02ac4c8 <pages>
        if (pde1&PTE_V){
ffffffffc0203ad0:	e79d                	bnez	a5,ffffffffc0203afe <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc0203ad2:	12098963          	beqz	s3,ffffffffc0203c04 <exit_range+0x1c2>
ffffffffc0203ad6:	400007b7          	lui	a5,0x40000
ffffffffc0203ada:	84ce                	mv	s1,s3
ffffffffc0203adc:	97ce                	add	a5,a5,s3
ffffffffc0203ade:	1369f363          	bleu	s6,s3,ffffffffc0203c04 <exit_range+0x1c2>
ffffffffc0203ae2:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0203ae4:	00698933          	add	s2,s3,t1
ffffffffc0203ae8:	01e95913          	srli	s2,s2,0x1e
ffffffffc0203aec:	1ff97913          	andi	s2,s2,511
ffffffffc0203af0:	090e                	slli	s2,s2,0x3
ffffffffc0203af2:	9972                	add	s2,s2,t3
ffffffffc0203af4:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc0203af8:	001bf793          	andi	a5,s7,1
ffffffffc0203afc:	dbf9                	beqz	a5,ffffffffc0203ad2 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0203afe:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b02:	0b8a                	slli	s7,s7,0x2
ffffffffc0203b04:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b08:	14fbfc63          	bleu	a5,s7,ffffffffc0203c60 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b0c:	fff80ab7          	lui	s5,0xfff80
ffffffffc0203b10:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc0203b12:	000806b7          	lui	a3,0x80
ffffffffc0203b16:	96d6                	add	a3,a3,s5
ffffffffc0203b18:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0203b1c:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc0203b20:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b22:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203b24:	12f67263          	bleu	a5,a2,ffffffffc0203c48 <exit_range+0x206>
ffffffffc0203b28:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0203b2c:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0203b2e:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc0203b32:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc0203b34:	00080837          	lui	a6,0x80
ffffffffc0203b38:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc0203b3a:	00200c37          	lui	s8,0x200
ffffffffc0203b3e:	a801                	j	ffffffffc0203b4e <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc0203b40:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc0203b42:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203b44:	c0d9                	beqz	s1,ffffffffc0203bca <exit_range+0x188>
ffffffffc0203b46:	0934f263          	bleu	s3,s1,ffffffffc0203bca <exit_range+0x188>
ffffffffc0203b4a:	0d64fc63          	bleu	s6,s1,ffffffffc0203c22 <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0203b4e:	0154d413          	srli	s0,s1,0x15
ffffffffc0203b52:	1ff47413          	andi	s0,s0,511
ffffffffc0203b56:	040e                	slli	s0,s0,0x3
ffffffffc0203b58:	9452                	add	s0,s0,s4
ffffffffc0203b5a:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc0203b5c:	0017f693          	andi	a3,a5,1
ffffffffc0203b60:	d2e5                	beqz	a3,ffffffffc0203b40 <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc0203b62:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b66:	00279513          	slli	a0,a5,0x2
ffffffffc0203b6a:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b6c:	0eb57a63          	bleu	a1,a0,ffffffffc0203c60 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b70:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc0203b72:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc0203b76:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc0203b7a:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b7c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203b7e:	0cb7f563          	bleu	a1,a5,ffffffffc0203c48 <exit_range+0x206>
ffffffffc0203b82:	631c                	ld	a5,0(a4)
ffffffffc0203b84:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0203b86:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc0203b8a:	629c                	ld	a5,0(a3)
ffffffffc0203b8c:	8b85                	andi	a5,a5,1
ffffffffc0203b8e:	fbd5                	bnez	a5,ffffffffc0203b42 <exit_range+0x100>
ffffffffc0203b90:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0203b92:	fed59ce3          	bne	a1,a3,ffffffffc0203b8a <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b96:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc0203b9a:	4585                	li	a1,1
ffffffffc0203b9c:	e072                	sd	t3,0(sp)
ffffffffc0203b9e:	953e                	add	a0,a0,a5
ffffffffc0203ba0:	ad1ff0ef          	jal	ra,ffffffffc0203670 <free_pages>
                d0start += PTSIZE;
ffffffffc0203ba4:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203ba6:	00043023          	sd	zero,0(s0)
ffffffffc0203baa:	000a9e97          	auipc	t4,0xa9
ffffffffc0203bae:	91ee8e93          	addi	t4,t4,-1762 # ffffffffc02ac4c8 <pages>
ffffffffc0203bb2:	6e02                	ld	t3,0(sp)
ffffffffc0203bb4:	c0000337          	lui	t1,0xc0000
ffffffffc0203bb8:	fff808b7          	lui	a7,0xfff80
ffffffffc0203bbc:	00080837          	lui	a6,0x80
ffffffffc0203bc0:	000a9717          	auipc	a4,0xa9
ffffffffc0203bc4:	8f870713          	addi	a4,a4,-1800 # ffffffffc02ac4b8 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203bc8:	fcbd                	bnez	s1,ffffffffc0203b46 <exit_range+0x104>
            if (free_pd0) {
ffffffffc0203bca:	f00c84e3          	beqz	s9,ffffffffc0203ad2 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0203bce:	000d3783          	ld	a5,0(s10)
ffffffffc0203bd2:	e072                	sd	t3,0(sp)
ffffffffc0203bd4:	08fbf663          	bleu	a5,s7,ffffffffc0203c60 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203bd8:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0203bdc:	67a2                	ld	a5,8(sp)
ffffffffc0203bde:	4585                	li	a1,1
ffffffffc0203be0:	953e                	add	a0,a0,a5
ffffffffc0203be2:	a8fff0ef          	jal	ra,ffffffffc0203670 <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203be6:	00093023          	sd	zero,0(s2)
ffffffffc0203bea:	000a9717          	auipc	a4,0xa9
ffffffffc0203bee:	8ce70713          	addi	a4,a4,-1842 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc0203bf2:	c0000337          	lui	t1,0xc0000
ffffffffc0203bf6:	6e02                	ld	t3,0(sp)
ffffffffc0203bf8:	000a9e97          	auipc	t4,0xa9
ffffffffc0203bfc:	8d0e8e93          	addi	t4,t4,-1840 # ffffffffc02ac4c8 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc0203c00:	ec099be3          	bnez	s3,ffffffffc0203ad6 <exit_range+0x94>
}
ffffffffc0203c04:	70e6                	ld	ra,120(sp)
ffffffffc0203c06:	7446                	ld	s0,112(sp)
ffffffffc0203c08:	74a6                	ld	s1,104(sp)
ffffffffc0203c0a:	7906                	ld	s2,96(sp)
ffffffffc0203c0c:	69e6                	ld	s3,88(sp)
ffffffffc0203c0e:	6a46                	ld	s4,80(sp)
ffffffffc0203c10:	6aa6                	ld	s5,72(sp)
ffffffffc0203c12:	6b06                	ld	s6,64(sp)
ffffffffc0203c14:	7be2                	ld	s7,56(sp)
ffffffffc0203c16:	7c42                	ld	s8,48(sp)
ffffffffc0203c18:	7ca2                	ld	s9,40(sp)
ffffffffc0203c1a:	7d02                	ld	s10,32(sp)
ffffffffc0203c1c:	6de2                	ld	s11,24(sp)
ffffffffc0203c1e:	6109                	addi	sp,sp,128
ffffffffc0203c20:	8082                	ret
            if (free_pd0) {
ffffffffc0203c22:	ea0c8ae3          	beqz	s9,ffffffffc0203ad6 <exit_range+0x94>
ffffffffc0203c26:	b765                	j	ffffffffc0203bce <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203c28:	00004697          	auipc	a3,0x4
ffffffffc0203c2c:	6a868693          	addi	a3,a3,1704 # ffffffffc02082d0 <default_pmm_manager+0x5c0>
ffffffffc0203c30:	00003617          	auipc	a2,0x3
ffffffffc0203c34:	f8860613          	addi	a2,a2,-120 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203c38:	12000593          	li	a1,288
ffffffffc0203c3c:	00004517          	auipc	a0,0x4
ffffffffc0203c40:	14450513          	addi	a0,a0,324 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0203c44:	dd2fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203c48:	00003617          	auipc	a2,0x3
ffffffffc0203c4c:	6a860613          	addi	a2,a2,1704 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc0203c50:	06900593          	li	a1,105
ffffffffc0203c54:	00003517          	auipc	a0,0x3
ffffffffc0203c58:	68c50513          	addi	a0,a0,1676 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0203c5c:	dbafc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203c60:	00003617          	auipc	a2,0x3
ffffffffc0203c64:	66060613          	addi	a2,a2,1632 # ffffffffc02072c0 <commands+0xb88>
ffffffffc0203c68:	06200593          	li	a1,98
ffffffffc0203c6c:	00003517          	auipc	a0,0x3
ffffffffc0203c70:	67450513          	addi	a0,a0,1652 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0203c74:	da2fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203c78:	00004697          	auipc	a3,0x4
ffffffffc0203c7c:	68868693          	addi	a3,a3,1672 # ffffffffc0208300 <default_pmm_manager+0x5f0>
ffffffffc0203c80:	00003617          	auipc	a2,0x3
ffffffffc0203c84:	f3860613          	addi	a2,a2,-200 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0203c88:	12100593          	li	a1,289
ffffffffc0203c8c:	00004517          	auipc	a0,0x4
ffffffffc0203c90:	0f450513          	addi	a0,a0,244 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0203c94:	d82fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203c98 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203c98:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203c9a:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203c9c:	e426                	sd	s1,8(sp)
ffffffffc0203c9e:	ec06                	sd	ra,24(sp)
ffffffffc0203ca0:	e822                	sd	s0,16(sp)
ffffffffc0203ca2:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203ca4:	a53ff0ef          	jal	ra,ffffffffc02036f6 <get_pte>
    if (ptep != NULL) {
ffffffffc0203ca8:	c511                	beqz	a0,ffffffffc0203cb4 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203caa:	611c                	ld	a5,0(a0)
ffffffffc0203cac:	842a                	mv	s0,a0
ffffffffc0203cae:	0017f713          	andi	a4,a5,1
ffffffffc0203cb2:	e711                	bnez	a4,ffffffffc0203cbe <page_remove+0x26>
}
ffffffffc0203cb4:	60e2                	ld	ra,24(sp)
ffffffffc0203cb6:	6442                	ld	s0,16(sp)
ffffffffc0203cb8:	64a2                	ld	s1,8(sp)
ffffffffc0203cba:	6105                	addi	sp,sp,32
ffffffffc0203cbc:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0203cbe:	000a8717          	auipc	a4,0xa8
ffffffffc0203cc2:	6ca70713          	addi	a4,a4,1738 # ffffffffc02ac388 <npage>
ffffffffc0203cc6:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203cc8:	078a                	slli	a5,a5,0x2
ffffffffc0203cca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203ccc:	02e7fe63          	bleu	a4,a5,ffffffffc0203d08 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0203cd0:	000a8717          	auipc	a4,0xa8
ffffffffc0203cd4:	7f870713          	addi	a4,a4,2040 # ffffffffc02ac4c8 <pages>
ffffffffc0203cd8:	6308                	ld	a0,0(a4)
ffffffffc0203cda:	fff80737          	lui	a4,0xfff80
ffffffffc0203cde:	97ba                	add	a5,a5,a4
ffffffffc0203ce0:	079a                	slli	a5,a5,0x6
ffffffffc0203ce2:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203ce4:	411c                	lw	a5,0(a0)
ffffffffc0203ce6:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203cea:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203cec:	cb11                	beqz	a4,ffffffffc0203d00 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203cee:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203cf2:	12048073          	sfence.vma	s1
}
ffffffffc0203cf6:	60e2                	ld	ra,24(sp)
ffffffffc0203cf8:	6442                	ld	s0,16(sp)
ffffffffc0203cfa:	64a2                	ld	s1,8(sp)
ffffffffc0203cfc:	6105                	addi	sp,sp,32
ffffffffc0203cfe:	8082                	ret
            free_page(page);
ffffffffc0203d00:	4585                	li	a1,1
ffffffffc0203d02:	96fff0ef          	jal	ra,ffffffffc0203670 <free_pages>
ffffffffc0203d06:	b7e5                	j	ffffffffc0203cee <page_remove+0x56>
ffffffffc0203d08:	8c5ff0ef          	jal	ra,ffffffffc02035cc <pa2page.part.4>

ffffffffc0203d0c <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203d0c:	7179                	addi	sp,sp,-48
ffffffffc0203d0e:	e44e                	sd	s3,8(sp)
ffffffffc0203d10:	89b2                	mv	s3,a2
ffffffffc0203d12:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d14:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203d16:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d18:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203d1a:	ec26                	sd	s1,24(sp)
ffffffffc0203d1c:	f406                	sd	ra,40(sp)
ffffffffc0203d1e:	e84a                	sd	s2,16(sp)
ffffffffc0203d20:	e052                	sd	s4,0(sp)
ffffffffc0203d22:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d24:	9d3ff0ef          	jal	ra,ffffffffc02036f6 <get_pte>
    if (ptep == NULL) {
ffffffffc0203d28:	cd49                	beqz	a0,ffffffffc0203dc2 <page_insert+0xb6>
    page->ref += 1;
ffffffffc0203d2a:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0203d2c:	611c                	ld	a5,0(a0)
ffffffffc0203d2e:	892a                	mv	s2,a0
ffffffffc0203d30:	0016871b          	addiw	a4,a3,1
ffffffffc0203d34:	c018                	sw	a4,0(s0)
ffffffffc0203d36:	0017f713          	andi	a4,a5,1
ffffffffc0203d3a:	ef05                	bnez	a4,ffffffffc0203d72 <page_insert+0x66>
ffffffffc0203d3c:	000a8797          	auipc	a5,0xa8
ffffffffc0203d40:	78c78793          	addi	a5,a5,1932 # ffffffffc02ac4c8 <pages>
ffffffffc0203d44:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0203d46:	8c19                	sub	s0,s0,a4
ffffffffc0203d48:	000806b7          	lui	a3,0x80
ffffffffc0203d4c:	8419                	srai	s0,s0,0x6
ffffffffc0203d4e:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203d50:	042a                	slli	s0,s0,0xa
ffffffffc0203d52:	8c45                	or	s0,s0,s1
ffffffffc0203d54:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0203d58:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203d5c:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0203d60:	4501                	li	a0,0
}
ffffffffc0203d62:	70a2                	ld	ra,40(sp)
ffffffffc0203d64:	7402                	ld	s0,32(sp)
ffffffffc0203d66:	64e2                	ld	s1,24(sp)
ffffffffc0203d68:	6942                	ld	s2,16(sp)
ffffffffc0203d6a:	69a2                	ld	s3,8(sp)
ffffffffc0203d6c:	6a02                	ld	s4,0(sp)
ffffffffc0203d6e:	6145                	addi	sp,sp,48
ffffffffc0203d70:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0203d72:	000a8717          	auipc	a4,0xa8
ffffffffc0203d76:	61670713          	addi	a4,a4,1558 # ffffffffc02ac388 <npage>
ffffffffc0203d7a:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203d7c:	078a                	slli	a5,a5,0x2
ffffffffc0203d7e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203d80:	04e7f363          	bleu	a4,a5,ffffffffc0203dc6 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d84:	000a8a17          	auipc	s4,0xa8
ffffffffc0203d88:	744a0a13          	addi	s4,s4,1860 # ffffffffc02ac4c8 <pages>
ffffffffc0203d8c:	000a3703          	ld	a4,0(s4)
ffffffffc0203d90:	fff80537          	lui	a0,0xfff80
ffffffffc0203d94:	953e                	add	a0,a0,a5
ffffffffc0203d96:	051a                	slli	a0,a0,0x6
ffffffffc0203d98:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0203d9a:	00a40a63          	beq	s0,a0,ffffffffc0203dae <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0203d9e:	411c                	lw	a5,0(a0)
ffffffffc0203da0:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203da4:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0203da6:	c691                	beqz	a3,ffffffffc0203db2 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203da8:	12098073          	sfence.vma	s3
ffffffffc0203dac:	bf69                	j	ffffffffc0203d46 <page_insert+0x3a>
ffffffffc0203dae:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203db0:	bf59                	j	ffffffffc0203d46 <page_insert+0x3a>
            free_page(page);
ffffffffc0203db2:	4585                	li	a1,1
ffffffffc0203db4:	8bdff0ef          	jal	ra,ffffffffc0203670 <free_pages>
ffffffffc0203db8:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203dbc:	12098073          	sfence.vma	s3
ffffffffc0203dc0:	b759                	j	ffffffffc0203d46 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0203dc2:	5571                	li	a0,-4
ffffffffc0203dc4:	bf79                	j	ffffffffc0203d62 <page_insert+0x56>
ffffffffc0203dc6:	807ff0ef          	jal	ra,ffffffffc02035cc <pa2page.part.4>

ffffffffc0203dca <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203dca:	00004797          	auipc	a5,0x4
ffffffffc0203dce:	f4678793          	addi	a5,a5,-186 # ffffffffc0207d10 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203dd2:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203dd4:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203dd6:	00004517          	auipc	a0,0x4
ffffffffc0203dda:	fd250513          	addi	a0,a0,-46 # ffffffffc0207da8 <default_pmm_manager+0x98>
void pmm_init(void) {
ffffffffc0203dde:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203de0:	000a8717          	auipc	a4,0xa8
ffffffffc0203de4:	6cf73823          	sd	a5,1744(a4) # ffffffffc02ac4b0 <pmm_manager>
void pmm_init(void) {
ffffffffc0203de8:	e0a2                	sd	s0,64(sp)
ffffffffc0203dea:	fc26                	sd	s1,56(sp)
ffffffffc0203dec:	f84a                	sd	s2,48(sp)
ffffffffc0203dee:	f44e                	sd	s3,40(sp)
ffffffffc0203df0:	f052                	sd	s4,32(sp)
ffffffffc0203df2:	ec56                	sd	s5,24(sp)
ffffffffc0203df4:	e85a                	sd	s6,16(sp)
ffffffffc0203df6:	e45e                	sd	s7,8(sp)
ffffffffc0203df8:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203dfa:	000a8417          	auipc	s0,0xa8
ffffffffc0203dfe:	6b640413          	addi	s0,s0,1718 # ffffffffc02ac4b0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203e02:	acefc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc0203e06:	601c                	ld	a5,0(s0)
ffffffffc0203e08:	000a8497          	auipc	s1,0xa8
ffffffffc0203e0c:	58048493          	addi	s1,s1,1408 # ffffffffc02ac388 <npage>
ffffffffc0203e10:	000a8917          	auipc	s2,0xa8
ffffffffc0203e14:	6b890913          	addi	s2,s2,1720 # ffffffffc02ac4c8 <pages>
ffffffffc0203e18:	679c                	ld	a5,8(a5)
ffffffffc0203e1a:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203e1c:	57f5                	li	a5,-3
ffffffffc0203e1e:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0203e20:	00004517          	auipc	a0,0x4
ffffffffc0203e24:	fa050513          	addi	a0,a0,-96 # ffffffffc0207dc0 <default_pmm_manager+0xb0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203e28:	000a8717          	auipc	a4,0xa8
ffffffffc0203e2c:	68f73823          	sd	a5,1680(a4) # ffffffffc02ac4b8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0203e30:	aa0fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0203e34:	46c5                	li	a3,17
ffffffffc0203e36:	06ee                	slli	a3,a3,0x1b
ffffffffc0203e38:	40100613          	li	a2,1025
ffffffffc0203e3c:	16fd                	addi	a3,a3,-1
ffffffffc0203e3e:	0656                	slli	a2,a2,0x15
ffffffffc0203e40:	07e005b7          	lui	a1,0x7e00
ffffffffc0203e44:	00004517          	auipc	a0,0x4
ffffffffc0203e48:	f9450513          	addi	a0,a0,-108 # ffffffffc0207dd8 <default_pmm_manager+0xc8>
ffffffffc0203e4c:	a84fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203e50:	777d                	lui	a4,0xfffff
ffffffffc0203e52:	000a9797          	auipc	a5,0xa9
ffffffffc0203e56:	68d78793          	addi	a5,a5,1677 # ffffffffc02ad4df <end+0xfff>
ffffffffc0203e5a:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0203e5c:	00088737          	lui	a4,0x88
ffffffffc0203e60:	000a8697          	auipc	a3,0xa8
ffffffffc0203e64:	52e6b423          	sd	a4,1320(a3) # ffffffffc02ac388 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203e68:	000a8717          	auipc	a4,0xa8
ffffffffc0203e6c:	66f73023          	sd	a5,1632(a4) # ffffffffc02ac4c8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203e70:	4701                	li	a4,0
ffffffffc0203e72:	4685                	li	a3,1
ffffffffc0203e74:	fff80837          	lui	a6,0xfff80
ffffffffc0203e78:	a019                	j	ffffffffc0203e7e <pmm_init+0xb4>
ffffffffc0203e7a:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0203e7e:	00671613          	slli	a2,a4,0x6
ffffffffc0203e82:	97b2                	add	a5,a5,a2
ffffffffc0203e84:	07a1                	addi	a5,a5,8
ffffffffc0203e86:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203e8a:	6090                	ld	a2,0(s1)
ffffffffc0203e8c:	0705                	addi	a4,a4,1
ffffffffc0203e8e:	010607b3          	add	a5,a2,a6
ffffffffc0203e92:	fef764e3          	bltu	a4,a5,ffffffffc0203e7a <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203e96:	00093503          	ld	a0,0(s2)
ffffffffc0203e9a:	fe0007b7          	lui	a5,0xfe000
ffffffffc0203e9e:	00661693          	slli	a3,a2,0x6
ffffffffc0203ea2:	97aa                	add	a5,a5,a0
ffffffffc0203ea4:	96be                	add	a3,a3,a5
ffffffffc0203ea6:	c02007b7          	lui	a5,0xc0200
ffffffffc0203eaa:	7af6ed63          	bltu	a3,a5,ffffffffc0204664 <pmm_init+0x89a>
ffffffffc0203eae:	000a8997          	auipc	s3,0xa8
ffffffffc0203eb2:	60a98993          	addi	s3,s3,1546 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc0203eb6:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0203eba:	47c5                	li	a5,17
ffffffffc0203ebc:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203ebe:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0203ec0:	02f6f763          	bleu	a5,a3,ffffffffc0203eee <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203ec4:	6585                	lui	a1,0x1
ffffffffc0203ec6:	15fd                	addi	a1,a1,-1
ffffffffc0203ec8:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0203eca:	00c6d713          	srli	a4,a3,0xc
ffffffffc0203ece:	48c77a63          	bleu	a2,a4,ffffffffc0204362 <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc0203ed2:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203ed4:	75fd                	lui	a1,0xfffff
ffffffffc0203ed6:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0203ed8:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0203eda:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203edc:	40d786b3          	sub	a3,a5,a3
ffffffffc0203ee0:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0203ee2:	00c6d593          	srli	a1,a3,0xc
ffffffffc0203ee6:	953a                	add	a0,a0,a4
ffffffffc0203ee8:	9602                	jalr	a2
ffffffffc0203eea:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203eee:	00004517          	auipc	a0,0x4
ffffffffc0203ef2:	f1250513          	addi	a0,a0,-238 # ffffffffc0207e00 <default_pmm_manager+0xf0>
ffffffffc0203ef6:	9dafc0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203efa:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203efc:	000a8417          	auipc	s0,0xa8
ffffffffc0203f00:	48440413          	addi	s0,s0,1156 # ffffffffc02ac380 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203f04:	7b9c                	ld	a5,48(a5)
ffffffffc0203f06:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203f08:	00004517          	auipc	a0,0x4
ffffffffc0203f0c:	f1050513          	addi	a0,a0,-240 # ffffffffc0207e18 <default_pmm_manager+0x108>
ffffffffc0203f10:	9c0fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203f14:	00007697          	auipc	a3,0x7
ffffffffc0203f18:	0ec68693          	addi	a3,a3,236 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0203f1c:	000a8797          	auipc	a5,0xa8
ffffffffc0203f20:	46d7b223          	sd	a3,1124(a5) # ffffffffc02ac380 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203f24:	c02007b7          	lui	a5,0xc0200
ffffffffc0203f28:	10f6eae3          	bltu	a3,a5,ffffffffc020483c <pmm_init+0xa72>
ffffffffc0203f2c:	0009b783          	ld	a5,0(s3)
ffffffffc0203f30:	8e9d                	sub	a3,a3,a5
ffffffffc0203f32:	000a8797          	auipc	a5,0xa8
ffffffffc0203f36:	58d7b723          	sd	a3,1422(a5) # ffffffffc02ac4c0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0203f3a:	f7cff0ef          	jal	ra,ffffffffc02036b6 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203f3e:	6098                	ld	a4,0(s1)
ffffffffc0203f40:	c80007b7          	lui	a5,0xc8000
ffffffffc0203f44:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0203f46:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203f48:	0ce7eae3          	bltu	a5,a4,ffffffffc020481c <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203f4c:	6008                	ld	a0,0(s0)
ffffffffc0203f4e:	44050463          	beqz	a0,ffffffffc0204396 <pmm_init+0x5cc>
ffffffffc0203f52:	6785                	lui	a5,0x1
ffffffffc0203f54:	17fd                	addi	a5,a5,-1
ffffffffc0203f56:	8fe9                	and	a5,a5,a0
ffffffffc0203f58:	2781                	sext.w	a5,a5
ffffffffc0203f5a:	42079e63          	bnez	a5,ffffffffc0204396 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203f5e:	4601                	li	a2,0
ffffffffc0203f60:	4581                	li	a1,0
ffffffffc0203f62:	967ff0ef          	jal	ra,ffffffffc02038c8 <get_page>
ffffffffc0203f66:	78051b63          	bnez	a0,ffffffffc02046fc <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0203f6a:	4505                	li	a0,1
ffffffffc0203f6c:	e7cff0ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0203f70:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203f72:	6008                	ld	a0,0(s0)
ffffffffc0203f74:	4681                	li	a3,0
ffffffffc0203f76:	4601                	li	a2,0
ffffffffc0203f78:	85d6                	mv	a1,s5
ffffffffc0203f7a:	d93ff0ef          	jal	ra,ffffffffc0203d0c <page_insert>
ffffffffc0203f7e:	7a051f63          	bnez	a0,ffffffffc020473c <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203f82:	6008                	ld	a0,0(s0)
ffffffffc0203f84:	4601                	li	a2,0
ffffffffc0203f86:	4581                	li	a1,0
ffffffffc0203f88:	f6eff0ef          	jal	ra,ffffffffc02036f6 <get_pte>
ffffffffc0203f8c:	78050863          	beqz	a0,ffffffffc020471c <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc0203f90:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203f92:	0017f713          	andi	a4,a5,1
ffffffffc0203f96:	3e070463          	beqz	a4,ffffffffc020437e <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0203f9a:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203f9c:	078a                	slli	a5,a5,0x2
ffffffffc0203f9e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203fa0:	3ce7f163          	bleu	a4,a5,ffffffffc0204362 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0203fa4:	00093683          	ld	a3,0(s2)
ffffffffc0203fa8:	fff80637          	lui	a2,0xfff80
ffffffffc0203fac:	97b2                	add	a5,a5,a2
ffffffffc0203fae:	079a                	slli	a5,a5,0x6
ffffffffc0203fb0:	97b6                	add	a5,a5,a3
ffffffffc0203fb2:	72fa9563          	bne	s5,a5,ffffffffc02046dc <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0203fb6:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8568>
ffffffffc0203fba:	4785                	li	a5,1
ffffffffc0203fbc:	70fb9063          	bne	s7,a5,ffffffffc02046bc <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203fc0:	6008                	ld	a0,0(s0)
ffffffffc0203fc2:	76fd                	lui	a3,0xfffff
ffffffffc0203fc4:	611c                	ld	a5,0(a0)
ffffffffc0203fc6:	078a                	slli	a5,a5,0x2
ffffffffc0203fc8:	8ff5                	and	a5,a5,a3
ffffffffc0203fca:	00c7d613          	srli	a2,a5,0xc
ffffffffc0203fce:	66e67e63          	bleu	a4,a2,ffffffffc020464a <pmm_init+0x880>
ffffffffc0203fd2:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203fd6:	97e2                	add	a5,a5,s8
ffffffffc0203fd8:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8568>
ffffffffc0203fdc:	0b0a                	slli	s6,s6,0x2
ffffffffc0203fde:	00db7b33          	and	s6,s6,a3
ffffffffc0203fe2:	00cb5793          	srli	a5,s6,0xc
ffffffffc0203fe6:	56e7f863          	bleu	a4,a5,ffffffffc0204556 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203fea:	4601                	li	a2,0
ffffffffc0203fec:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203fee:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203ff0:	f06ff0ef          	jal	ra,ffffffffc02036f6 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203ff4:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203ff6:	55651063          	bne	a0,s6,ffffffffc0204536 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0203ffa:	4505                	li	a0,1
ffffffffc0203ffc:	decff0ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0204000:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0204002:	6008                	ld	a0,0(s0)
ffffffffc0204004:	46d1                	li	a3,20
ffffffffc0204006:	6605                	lui	a2,0x1
ffffffffc0204008:	85da                	mv	a1,s6
ffffffffc020400a:	d03ff0ef          	jal	ra,ffffffffc0203d0c <page_insert>
ffffffffc020400e:	50051463          	bnez	a0,ffffffffc0204516 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204012:	6008                	ld	a0,0(s0)
ffffffffc0204014:	4601                	li	a2,0
ffffffffc0204016:	6585                	lui	a1,0x1
ffffffffc0204018:	edeff0ef          	jal	ra,ffffffffc02036f6 <get_pte>
ffffffffc020401c:	4c050d63          	beqz	a0,ffffffffc02044f6 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc0204020:	611c                	ld	a5,0(a0)
ffffffffc0204022:	0107f713          	andi	a4,a5,16
ffffffffc0204026:	4a070863          	beqz	a4,ffffffffc02044d6 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc020402a:	8b91                	andi	a5,a5,4
ffffffffc020402c:	48078563          	beqz	a5,ffffffffc02044b6 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0204030:	6008                	ld	a0,0(s0)
ffffffffc0204032:	611c                	ld	a5,0(a0)
ffffffffc0204034:	8bc1                	andi	a5,a5,16
ffffffffc0204036:	46078063          	beqz	a5,ffffffffc0204496 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc020403a:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5590>
ffffffffc020403e:	43779c63          	bne	a5,s7,ffffffffc0204476 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0204042:	4681                	li	a3,0
ffffffffc0204044:	6605                	lui	a2,0x1
ffffffffc0204046:	85d6                	mv	a1,s5
ffffffffc0204048:	cc5ff0ef          	jal	ra,ffffffffc0203d0c <page_insert>
ffffffffc020404c:	40051563          	bnez	a0,ffffffffc0204456 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc0204050:	000aa703          	lw	a4,0(s5)
ffffffffc0204054:	4789                	li	a5,2
ffffffffc0204056:	3ef71063          	bne	a4,a5,ffffffffc0204436 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc020405a:	000b2783          	lw	a5,0(s6)
ffffffffc020405e:	3a079c63          	bnez	a5,ffffffffc0204416 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204062:	6008                	ld	a0,0(s0)
ffffffffc0204064:	4601                	li	a2,0
ffffffffc0204066:	6585                	lui	a1,0x1
ffffffffc0204068:	e8eff0ef          	jal	ra,ffffffffc02036f6 <get_pte>
ffffffffc020406c:	38050563          	beqz	a0,ffffffffc02043f6 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc0204070:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0204072:	00177793          	andi	a5,a4,1
ffffffffc0204076:	30078463          	beqz	a5,ffffffffc020437e <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc020407a:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020407c:	00271793          	slli	a5,a4,0x2
ffffffffc0204080:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204082:	2ed7f063          	bleu	a3,a5,ffffffffc0204362 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0204086:	00093683          	ld	a3,0(s2)
ffffffffc020408a:	fff80637          	lui	a2,0xfff80
ffffffffc020408e:	97b2                	add	a5,a5,a2
ffffffffc0204090:	079a                	slli	a5,a5,0x6
ffffffffc0204092:	97b6                	add	a5,a5,a3
ffffffffc0204094:	32fa9163          	bne	s5,a5,ffffffffc02043b6 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc0204098:	8b41                	andi	a4,a4,16
ffffffffc020409a:	70071163          	bnez	a4,ffffffffc020479c <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc020409e:	6008                	ld	a0,0(s0)
ffffffffc02040a0:	4581                	li	a1,0
ffffffffc02040a2:	bf7ff0ef          	jal	ra,ffffffffc0203c98 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02040a6:	000aa703          	lw	a4,0(s5)
ffffffffc02040aa:	4785                	li	a5,1
ffffffffc02040ac:	6cf71863          	bne	a4,a5,ffffffffc020477c <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc02040b0:	000b2783          	lw	a5,0(s6)
ffffffffc02040b4:	6a079463          	bnez	a5,ffffffffc020475c <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02040b8:	6008                	ld	a0,0(s0)
ffffffffc02040ba:	6585                	lui	a1,0x1
ffffffffc02040bc:	bddff0ef          	jal	ra,ffffffffc0203c98 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02040c0:	000aa783          	lw	a5,0(s5)
ffffffffc02040c4:	50079363          	bnez	a5,ffffffffc02045ca <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc02040c8:	000b2783          	lw	a5,0(s6)
ffffffffc02040cc:	4c079f63          	bnez	a5,ffffffffc02045aa <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02040d0:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02040d4:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02040d6:	000ab783          	ld	a5,0(s5)
ffffffffc02040da:	078a                	slli	a5,a5,0x2
ffffffffc02040dc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02040de:	28c7f263          	bleu	a2,a5,ffffffffc0204362 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02040e2:	fff80737          	lui	a4,0xfff80
ffffffffc02040e6:	00093503          	ld	a0,0(s2)
ffffffffc02040ea:	97ba                	add	a5,a5,a4
ffffffffc02040ec:	079a                	slli	a5,a5,0x6
ffffffffc02040ee:	00f50733          	add	a4,a0,a5
ffffffffc02040f2:	4314                	lw	a3,0(a4)
ffffffffc02040f4:	4705                	li	a4,1
ffffffffc02040f6:	48e69a63          	bne	a3,a4,ffffffffc020458a <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc02040fa:	8799                	srai	a5,a5,0x6
ffffffffc02040fc:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc0204100:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc0204102:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0204104:	8331                	srli	a4,a4,0xc
ffffffffc0204106:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204108:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020410a:	46c77363          	bleu	a2,a4,ffffffffc0204570 <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020410e:	0009b683          	ld	a3,0(s3)
ffffffffc0204112:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0204114:	639c                	ld	a5,0(a5)
ffffffffc0204116:	078a                	slli	a5,a5,0x2
ffffffffc0204118:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020411a:	24c7f463          	bleu	a2,a5,ffffffffc0204362 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020411e:	416787b3          	sub	a5,a5,s6
ffffffffc0204122:	079a                	slli	a5,a5,0x6
ffffffffc0204124:	953e                	add	a0,a0,a5
ffffffffc0204126:	4585                	li	a1,1
ffffffffc0204128:	d48ff0ef          	jal	ra,ffffffffc0203670 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020412c:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc0204130:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204132:	078a                	slli	a5,a5,0x2
ffffffffc0204134:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204136:	22e7f663          	bleu	a4,a5,ffffffffc0204362 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020413a:	00093503          	ld	a0,0(s2)
ffffffffc020413e:	416787b3          	sub	a5,a5,s6
ffffffffc0204142:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204144:	953e                	add	a0,a0,a5
ffffffffc0204146:	4585                	li	a1,1
ffffffffc0204148:	d28ff0ef          	jal	ra,ffffffffc0203670 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020414c:	601c                	ld	a5,0(s0)
ffffffffc020414e:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0204152:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0204156:	d60ff0ef          	jal	ra,ffffffffc02036b6 <nr_free_pages>
ffffffffc020415a:	68aa1163          	bne	s4,a0,ffffffffc02047dc <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020415e:	00004517          	auipc	a0,0x4
ffffffffc0204162:	fa250513          	addi	a0,a0,-94 # ffffffffc0208100 <default_pmm_manager+0x3f0>
ffffffffc0204166:	f6bfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc020416a:	d4cff0ef          	jal	ra,ffffffffc02036b6 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020416e:	6098                	ld	a4,0(s1)
ffffffffc0204170:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0204174:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0204176:	00c71693          	slli	a3,a4,0xc
ffffffffc020417a:	18d7f563          	bleu	a3,a5,ffffffffc0204304 <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020417e:	83b1                	srli	a5,a5,0xc
ffffffffc0204180:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0204182:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0204186:	1ae7f163          	bleu	a4,a5,ffffffffc0204328 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020418a:	7bfd                	lui	s7,0xfffff
ffffffffc020418c:	6b05                	lui	s6,0x1
ffffffffc020418e:	a029                	j	ffffffffc0204198 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0204190:	00cad713          	srli	a4,s5,0xc
ffffffffc0204194:	18f77a63          	bleu	a5,a4,ffffffffc0204328 <pmm_init+0x55e>
ffffffffc0204198:	0009b583          	ld	a1,0(s3)
ffffffffc020419c:	4601                	li	a2,0
ffffffffc020419e:	95d6                	add	a1,a1,s5
ffffffffc02041a0:	d56ff0ef          	jal	ra,ffffffffc02036f6 <get_pte>
ffffffffc02041a4:	16050263          	beqz	a0,ffffffffc0204308 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02041a8:	611c                	ld	a5,0(a0)
ffffffffc02041aa:	078a                	slli	a5,a5,0x2
ffffffffc02041ac:	0177f7b3          	and	a5,a5,s7
ffffffffc02041b0:	19579963          	bne	a5,s5,ffffffffc0204342 <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02041b4:	609c                	ld	a5,0(s1)
ffffffffc02041b6:	9ada                	add	s5,s5,s6
ffffffffc02041b8:	6008                	ld	a0,0(s0)
ffffffffc02041ba:	00c79713          	slli	a4,a5,0xc
ffffffffc02041be:	fceae9e3          	bltu	s5,a4,ffffffffc0204190 <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02041c2:	611c                	ld	a5,0(a0)
ffffffffc02041c4:	62079c63          	bnez	a5,ffffffffc02047fc <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc02041c8:	4505                	li	a0,1
ffffffffc02041ca:	c1eff0ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc02041ce:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02041d0:	6008                	ld	a0,0(s0)
ffffffffc02041d2:	4699                	li	a3,6
ffffffffc02041d4:	10000613          	li	a2,256
ffffffffc02041d8:	85d6                	mv	a1,s5
ffffffffc02041da:	b33ff0ef          	jal	ra,ffffffffc0203d0c <page_insert>
ffffffffc02041de:	1e051c63          	bnez	a0,ffffffffc02043d6 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc02041e2:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc02041e6:	4785                	li	a5,1
ffffffffc02041e8:	44f71163          	bne	a4,a5,ffffffffc020462a <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02041ec:	6008                	ld	a0,0(s0)
ffffffffc02041ee:	6b05                	lui	s6,0x1
ffffffffc02041f0:	4699                	li	a3,6
ffffffffc02041f2:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8468>
ffffffffc02041f6:	85d6                	mv	a1,s5
ffffffffc02041f8:	b15ff0ef          	jal	ra,ffffffffc0203d0c <page_insert>
ffffffffc02041fc:	40051763          	bnez	a0,ffffffffc020460a <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0204200:	000aa703          	lw	a4,0(s5)
ffffffffc0204204:	4789                	li	a5,2
ffffffffc0204206:	3ef71263          	bne	a4,a5,ffffffffc02045ea <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020420a:	00004597          	auipc	a1,0x4
ffffffffc020420e:	02e58593          	addi	a1,a1,46 # ffffffffc0208238 <default_pmm_manager+0x528>
ffffffffc0204212:	10000513          	li	a0,256
ffffffffc0204216:	71f010ef          	jal	ra,ffffffffc0206134 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020421a:	100b0593          	addi	a1,s6,256
ffffffffc020421e:	10000513          	li	a0,256
ffffffffc0204222:	725010ef          	jal	ra,ffffffffc0206146 <strcmp>
ffffffffc0204226:	44051b63          	bnez	a0,ffffffffc020467c <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc020422a:	00093683          	ld	a3,0(s2)
ffffffffc020422e:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0204232:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0204234:	40da86b3          	sub	a3,s5,a3
ffffffffc0204238:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020423a:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc020423c:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020423e:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0204242:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0204246:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204248:	10f77f63          	bleu	a5,a4,ffffffffc0204366 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020424c:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0204250:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0204254:	96be                	add	a3,a3,a5
ffffffffc0204256:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd52c20>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020425a:	697010ef          	jal	ra,ffffffffc02060f0 <strlen>
ffffffffc020425e:	54051f63          	bnez	a0,ffffffffc02047bc <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0204262:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0204266:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204268:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52b20>
ffffffffc020426c:	068a                	slli	a3,a3,0x2
ffffffffc020426e:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204270:	0ef6f963          	bleu	a5,a3,ffffffffc0204362 <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0204274:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0204278:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020427a:	0efb7663          	bleu	a5,s6,ffffffffc0204366 <pmm_init+0x59c>
ffffffffc020427e:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0204282:	4585                	li	a1,1
ffffffffc0204284:	8556                	mv	a0,s5
ffffffffc0204286:	99b6                	add	s3,s3,a3
ffffffffc0204288:	be8ff0ef          	jal	ra,ffffffffc0203670 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020428c:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0204290:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204292:	078a                	slli	a5,a5,0x2
ffffffffc0204294:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204296:	0ce7f663          	bleu	a4,a5,ffffffffc0204362 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020429a:	00093503          	ld	a0,0(s2)
ffffffffc020429e:	fff809b7          	lui	s3,0xfff80
ffffffffc02042a2:	97ce                	add	a5,a5,s3
ffffffffc02042a4:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02042a6:	953e                	add	a0,a0,a5
ffffffffc02042a8:	4585                	li	a1,1
ffffffffc02042aa:	bc6ff0ef          	jal	ra,ffffffffc0203670 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02042ae:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02042b2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02042b4:	078a                	slli	a5,a5,0x2
ffffffffc02042b6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02042b8:	0ae7f563          	bleu	a4,a5,ffffffffc0204362 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02042bc:	00093503          	ld	a0,0(s2)
ffffffffc02042c0:	97ce                	add	a5,a5,s3
ffffffffc02042c2:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02042c4:	953e                	add	a0,a0,a5
ffffffffc02042c6:	4585                	li	a1,1
ffffffffc02042c8:	ba8ff0ef          	jal	ra,ffffffffc0203670 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02042cc:	601c                	ld	a5,0(s0)
ffffffffc02042ce:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc02042d2:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02042d6:	be0ff0ef          	jal	ra,ffffffffc02036b6 <nr_free_pages>
ffffffffc02042da:	3caa1163          	bne	s4,a0,ffffffffc020469c <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02042de:	00004517          	auipc	a0,0x4
ffffffffc02042e2:	fd250513          	addi	a0,a0,-46 # ffffffffc02082b0 <default_pmm_manager+0x5a0>
ffffffffc02042e6:	debfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc02042ea:	6406                	ld	s0,64(sp)
ffffffffc02042ec:	60a6                	ld	ra,72(sp)
ffffffffc02042ee:	74e2                	ld	s1,56(sp)
ffffffffc02042f0:	7942                	ld	s2,48(sp)
ffffffffc02042f2:	79a2                	ld	s3,40(sp)
ffffffffc02042f4:	7a02                	ld	s4,32(sp)
ffffffffc02042f6:	6ae2                	ld	s5,24(sp)
ffffffffc02042f8:	6b42                	ld	s6,16(sp)
ffffffffc02042fa:	6ba2                	ld	s7,8(sp)
ffffffffc02042fc:	6c02                	ld	s8,0(sp)
ffffffffc02042fe:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0204300:	c4dfd06f          	j	ffffffffc0201f4c <kmalloc_init>
ffffffffc0204304:	6008                	ld	a0,0(s0)
ffffffffc0204306:	bd75                	j	ffffffffc02041c2 <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0204308:	00004697          	auipc	a3,0x4
ffffffffc020430c:	e1868693          	addi	a3,a3,-488 # ffffffffc0208120 <default_pmm_manager+0x410>
ffffffffc0204310:	00003617          	auipc	a2,0x3
ffffffffc0204314:	8a860613          	addi	a2,a2,-1880 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204318:	22900593          	li	a1,553
ffffffffc020431c:	00004517          	auipc	a0,0x4
ffffffffc0204320:	a6450513          	addi	a0,a0,-1436 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204324:	ef3fb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204328:	86d6                	mv	a3,s5
ffffffffc020432a:	00003617          	auipc	a2,0x3
ffffffffc020432e:	fc660613          	addi	a2,a2,-58 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc0204332:	22900593          	li	a1,553
ffffffffc0204336:	00004517          	auipc	a0,0x4
ffffffffc020433a:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc020433e:	ed9fb0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0204342:	00004697          	auipc	a3,0x4
ffffffffc0204346:	e1e68693          	addi	a3,a3,-482 # ffffffffc0208160 <default_pmm_manager+0x450>
ffffffffc020434a:	00003617          	auipc	a2,0x3
ffffffffc020434e:	86e60613          	addi	a2,a2,-1938 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204352:	22a00593          	li	a1,554
ffffffffc0204356:	00004517          	auipc	a0,0x4
ffffffffc020435a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc020435e:	eb9fb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204362:	a6aff0ef          	jal	ra,ffffffffc02035cc <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0204366:	00003617          	auipc	a2,0x3
ffffffffc020436a:	f8a60613          	addi	a2,a2,-118 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc020436e:	06900593          	li	a1,105
ffffffffc0204372:	00003517          	auipc	a0,0x3
ffffffffc0204376:	f6e50513          	addi	a0,a0,-146 # ffffffffc02072e0 <commands+0xba8>
ffffffffc020437a:	e9dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020437e:	00003617          	auipc	a2,0x3
ffffffffc0204382:	4e260613          	addi	a2,a2,1250 # ffffffffc0207860 <commands+0x1128>
ffffffffc0204386:	07400593          	li	a1,116
ffffffffc020438a:	00003517          	auipc	a0,0x3
ffffffffc020438e:	f5650513          	addi	a0,a0,-170 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0204392:	e85fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0204396:	00004697          	auipc	a3,0x4
ffffffffc020439a:	ac268693          	addi	a3,a3,-1342 # ffffffffc0207e58 <default_pmm_manager+0x148>
ffffffffc020439e:	00003617          	auipc	a2,0x3
ffffffffc02043a2:	81a60613          	addi	a2,a2,-2022 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02043a6:	1ed00593          	li	a1,493
ffffffffc02043aa:	00004517          	auipc	a0,0x4
ffffffffc02043ae:	9d650513          	addi	a0,a0,-1578 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02043b2:	e65fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02043b6:	00004697          	auipc	a3,0x4
ffffffffc02043ba:	b6268693          	addi	a3,a3,-1182 # ffffffffc0207f18 <default_pmm_manager+0x208>
ffffffffc02043be:	00002617          	auipc	a2,0x2
ffffffffc02043c2:	7fa60613          	addi	a2,a2,2042 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02043c6:	20900593          	li	a1,521
ffffffffc02043ca:	00004517          	auipc	a0,0x4
ffffffffc02043ce:	9b650513          	addi	a0,a0,-1610 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02043d2:	e45fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02043d6:	00004697          	auipc	a3,0x4
ffffffffc02043da:	dba68693          	addi	a3,a3,-582 # ffffffffc0208190 <default_pmm_manager+0x480>
ffffffffc02043de:	00002617          	auipc	a2,0x2
ffffffffc02043e2:	7da60613          	addi	a2,a2,2010 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02043e6:	23200593          	li	a1,562
ffffffffc02043ea:	00004517          	auipc	a0,0x4
ffffffffc02043ee:	99650513          	addi	a0,a0,-1642 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02043f2:	e25fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02043f6:	00004697          	auipc	a3,0x4
ffffffffc02043fa:	bb268693          	addi	a3,a3,-1102 # ffffffffc0207fa8 <default_pmm_manager+0x298>
ffffffffc02043fe:	00002617          	auipc	a2,0x2
ffffffffc0204402:	7ba60613          	addi	a2,a2,1978 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204406:	20800593          	li	a1,520
ffffffffc020440a:	00004517          	auipc	a0,0x4
ffffffffc020440e:	97650513          	addi	a0,a0,-1674 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204412:	e05fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204416:	00004697          	auipc	a3,0x4
ffffffffc020441a:	c5a68693          	addi	a3,a3,-934 # ffffffffc0208070 <default_pmm_manager+0x360>
ffffffffc020441e:	00002617          	auipc	a2,0x2
ffffffffc0204422:	79a60613          	addi	a2,a2,1946 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204426:	20700593          	li	a1,519
ffffffffc020442a:	00004517          	auipc	a0,0x4
ffffffffc020442e:	95650513          	addi	a0,a0,-1706 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204432:	de5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0204436:	00004697          	auipc	a3,0x4
ffffffffc020443a:	c2268693          	addi	a3,a3,-990 # ffffffffc0208058 <default_pmm_manager+0x348>
ffffffffc020443e:	00002617          	auipc	a2,0x2
ffffffffc0204442:	77a60613          	addi	a2,a2,1914 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204446:	20600593          	li	a1,518
ffffffffc020444a:	00004517          	auipc	a0,0x4
ffffffffc020444e:	93650513          	addi	a0,a0,-1738 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204452:	dc5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0204456:	00004697          	auipc	a3,0x4
ffffffffc020445a:	bd268693          	addi	a3,a3,-1070 # ffffffffc0208028 <default_pmm_manager+0x318>
ffffffffc020445e:	00002617          	auipc	a2,0x2
ffffffffc0204462:	75a60613          	addi	a2,a2,1882 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204466:	20500593          	li	a1,517
ffffffffc020446a:	00004517          	auipc	a0,0x4
ffffffffc020446e:	91650513          	addi	a0,a0,-1770 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204472:	da5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0204476:	00004697          	auipc	a3,0x4
ffffffffc020447a:	b9a68693          	addi	a3,a3,-1126 # ffffffffc0208010 <default_pmm_manager+0x300>
ffffffffc020447e:	00002617          	auipc	a2,0x2
ffffffffc0204482:	73a60613          	addi	a2,a2,1850 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204486:	20300593          	li	a1,515
ffffffffc020448a:	00004517          	auipc	a0,0x4
ffffffffc020448e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204492:	d85fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0204496:	00004697          	auipc	a3,0x4
ffffffffc020449a:	b6268693          	addi	a3,a3,-1182 # ffffffffc0207ff8 <default_pmm_manager+0x2e8>
ffffffffc020449e:	00002617          	auipc	a2,0x2
ffffffffc02044a2:	71a60613          	addi	a2,a2,1818 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02044a6:	20200593          	li	a1,514
ffffffffc02044aa:	00004517          	auipc	a0,0x4
ffffffffc02044ae:	8d650513          	addi	a0,a0,-1834 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02044b2:	d65fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02044b6:	00004697          	auipc	a3,0x4
ffffffffc02044ba:	b3268693          	addi	a3,a3,-1230 # ffffffffc0207fe8 <default_pmm_manager+0x2d8>
ffffffffc02044be:	00002617          	auipc	a2,0x2
ffffffffc02044c2:	6fa60613          	addi	a2,a2,1786 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02044c6:	20100593          	li	a1,513
ffffffffc02044ca:	00004517          	auipc	a0,0x4
ffffffffc02044ce:	8b650513          	addi	a0,a0,-1866 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02044d2:	d45fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02044d6:	00004697          	auipc	a3,0x4
ffffffffc02044da:	b0268693          	addi	a3,a3,-1278 # ffffffffc0207fd8 <default_pmm_manager+0x2c8>
ffffffffc02044de:	00002617          	auipc	a2,0x2
ffffffffc02044e2:	6da60613          	addi	a2,a2,1754 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02044e6:	20000593          	li	a1,512
ffffffffc02044ea:	00004517          	auipc	a0,0x4
ffffffffc02044ee:	89650513          	addi	a0,a0,-1898 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02044f2:	d25fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02044f6:	00004697          	auipc	a3,0x4
ffffffffc02044fa:	ab268693          	addi	a3,a3,-1358 # ffffffffc0207fa8 <default_pmm_manager+0x298>
ffffffffc02044fe:	00002617          	auipc	a2,0x2
ffffffffc0204502:	6ba60613          	addi	a2,a2,1722 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204506:	1ff00593          	li	a1,511
ffffffffc020450a:	00004517          	auipc	a0,0x4
ffffffffc020450e:	87650513          	addi	a0,a0,-1930 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204512:	d05fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0204516:	00004697          	auipc	a3,0x4
ffffffffc020451a:	a5a68693          	addi	a3,a3,-1446 # ffffffffc0207f70 <default_pmm_manager+0x260>
ffffffffc020451e:	00002617          	auipc	a2,0x2
ffffffffc0204522:	69a60613          	addi	a2,a2,1690 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204526:	1fe00593          	li	a1,510
ffffffffc020452a:	00004517          	auipc	a0,0x4
ffffffffc020452e:	85650513          	addi	a0,a0,-1962 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204532:	ce5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204536:	00004697          	auipc	a3,0x4
ffffffffc020453a:	a1268693          	addi	a3,a3,-1518 # ffffffffc0207f48 <default_pmm_manager+0x238>
ffffffffc020453e:	00002617          	auipc	a2,0x2
ffffffffc0204542:	67a60613          	addi	a2,a2,1658 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204546:	1fb00593          	li	a1,507
ffffffffc020454a:	00004517          	auipc	a0,0x4
ffffffffc020454e:	83650513          	addi	a0,a0,-1994 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204552:	cc5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0204556:	86da                	mv	a3,s6
ffffffffc0204558:	00003617          	auipc	a2,0x3
ffffffffc020455c:	d9860613          	addi	a2,a2,-616 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc0204560:	1fa00593          	li	a1,506
ffffffffc0204564:	00004517          	auipc	a0,0x4
ffffffffc0204568:	81c50513          	addi	a0,a0,-2020 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc020456c:	cabfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204570:	86be                	mv	a3,a5
ffffffffc0204572:	00003617          	auipc	a2,0x3
ffffffffc0204576:	d7e60613          	addi	a2,a2,-642 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc020457a:	06900593          	li	a1,105
ffffffffc020457e:	00003517          	auipc	a0,0x3
ffffffffc0204582:	d6250513          	addi	a0,a0,-670 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0204586:	c91fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020458a:	00004697          	auipc	a3,0x4
ffffffffc020458e:	b2e68693          	addi	a3,a3,-1234 # ffffffffc02080b8 <default_pmm_manager+0x3a8>
ffffffffc0204592:	00002617          	auipc	a2,0x2
ffffffffc0204596:	62660613          	addi	a2,a2,1574 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020459a:	21400593          	li	a1,532
ffffffffc020459e:	00003517          	auipc	a0,0x3
ffffffffc02045a2:	7e250513          	addi	a0,a0,2018 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02045a6:	c71fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02045aa:	00004697          	auipc	a3,0x4
ffffffffc02045ae:	ac668693          	addi	a3,a3,-1338 # ffffffffc0208070 <default_pmm_manager+0x360>
ffffffffc02045b2:	00002617          	auipc	a2,0x2
ffffffffc02045b6:	60660613          	addi	a2,a2,1542 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02045ba:	21200593          	li	a1,530
ffffffffc02045be:	00003517          	auipc	a0,0x3
ffffffffc02045c2:	7c250513          	addi	a0,a0,1986 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02045c6:	c51fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02045ca:	00004697          	auipc	a3,0x4
ffffffffc02045ce:	ad668693          	addi	a3,a3,-1322 # ffffffffc02080a0 <default_pmm_manager+0x390>
ffffffffc02045d2:	00002617          	auipc	a2,0x2
ffffffffc02045d6:	5e660613          	addi	a2,a2,1510 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02045da:	21100593          	li	a1,529
ffffffffc02045de:	00003517          	auipc	a0,0x3
ffffffffc02045e2:	7a250513          	addi	a0,a0,1954 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02045e6:	c31fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02045ea:	00004697          	auipc	a3,0x4
ffffffffc02045ee:	c3668693          	addi	a3,a3,-970 # ffffffffc0208220 <default_pmm_manager+0x510>
ffffffffc02045f2:	00002617          	auipc	a2,0x2
ffffffffc02045f6:	5c660613          	addi	a2,a2,1478 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02045fa:	23500593          	li	a1,565
ffffffffc02045fe:	00003517          	auipc	a0,0x3
ffffffffc0204602:	78250513          	addi	a0,a0,1922 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204606:	c11fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020460a:	00004697          	auipc	a3,0x4
ffffffffc020460e:	bd668693          	addi	a3,a3,-1066 # ffffffffc02081e0 <default_pmm_manager+0x4d0>
ffffffffc0204612:	00002617          	auipc	a2,0x2
ffffffffc0204616:	5a660613          	addi	a2,a2,1446 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020461a:	23400593          	li	a1,564
ffffffffc020461e:	00003517          	auipc	a0,0x3
ffffffffc0204622:	76250513          	addi	a0,a0,1890 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204626:	bf1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p) == 1);
ffffffffc020462a:	00004697          	auipc	a3,0x4
ffffffffc020462e:	b9e68693          	addi	a3,a3,-1122 # ffffffffc02081c8 <default_pmm_manager+0x4b8>
ffffffffc0204632:	00002617          	auipc	a2,0x2
ffffffffc0204636:	58660613          	addi	a2,a2,1414 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020463a:	23300593          	li	a1,563
ffffffffc020463e:	00003517          	auipc	a0,0x3
ffffffffc0204642:	74250513          	addi	a0,a0,1858 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204646:	bd1fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020464a:	86be                	mv	a3,a5
ffffffffc020464c:	00003617          	auipc	a2,0x3
ffffffffc0204650:	ca460613          	addi	a2,a2,-860 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc0204654:	1f900593          	li	a1,505
ffffffffc0204658:	00003517          	auipc	a0,0x3
ffffffffc020465c:	72850513          	addi	a0,a0,1832 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204660:	bb7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0204664:	00003617          	auipc	a2,0x3
ffffffffc0204668:	f0460613          	addi	a2,a2,-252 # ffffffffc0207568 <commands+0xe30>
ffffffffc020466c:	07f00593          	li	a1,127
ffffffffc0204670:	00003517          	auipc	a0,0x3
ffffffffc0204674:	71050513          	addi	a0,a0,1808 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204678:	b9ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020467c:	00004697          	auipc	a3,0x4
ffffffffc0204680:	bd468693          	addi	a3,a3,-1068 # ffffffffc0208250 <default_pmm_manager+0x540>
ffffffffc0204684:	00002617          	auipc	a2,0x2
ffffffffc0204688:	53460613          	addi	a2,a2,1332 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020468c:	23900593          	li	a1,569
ffffffffc0204690:	00003517          	auipc	a0,0x3
ffffffffc0204694:	6f050513          	addi	a0,a0,1776 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204698:	b7ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020469c:	00004697          	auipc	a3,0x4
ffffffffc02046a0:	a4468693          	addi	a3,a3,-1468 # ffffffffc02080e0 <default_pmm_manager+0x3d0>
ffffffffc02046a4:	00002617          	auipc	a2,0x2
ffffffffc02046a8:	51460613          	addi	a2,a2,1300 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02046ac:	24500593          	li	a1,581
ffffffffc02046b0:	00003517          	auipc	a0,0x3
ffffffffc02046b4:	6d050513          	addi	a0,a0,1744 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02046b8:	b5ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02046bc:	00004697          	auipc	a3,0x4
ffffffffc02046c0:	87468693          	addi	a3,a3,-1932 # ffffffffc0207f30 <default_pmm_manager+0x220>
ffffffffc02046c4:	00002617          	auipc	a2,0x2
ffffffffc02046c8:	4f460613          	addi	a2,a2,1268 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02046cc:	1f700593          	li	a1,503
ffffffffc02046d0:	00003517          	auipc	a0,0x3
ffffffffc02046d4:	6b050513          	addi	a0,a0,1712 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02046d8:	b3ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02046dc:	00004697          	auipc	a3,0x4
ffffffffc02046e0:	83c68693          	addi	a3,a3,-1988 # ffffffffc0207f18 <default_pmm_manager+0x208>
ffffffffc02046e4:	00002617          	auipc	a2,0x2
ffffffffc02046e8:	4d460613          	addi	a2,a2,1236 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02046ec:	1f600593          	li	a1,502
ffffffffc02046f0:	00003517          	auipc	a0,0x3
ffffffffc02046f4:	69050513          	addi	a0,a0,1680 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02046f8:	b1ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02046fc:	00003697          	auipc	a3,0x3
ffffffffc0204700:	79468693          	addi	a3,a3,1940 # ffffffffc0207e90 <default_pmm_manager+0x180>
ffffffffc0204704:	00002617          	auipc	a2,0x2
ffffffffc0204708:	4b460613          	addi	a2,a2,1204 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020470c:	1ee00593          	li	a1,494
ffffffffc0204710:	00003517          	auipc	a0,0x3
ffffffffc0204714:	67050513          	addi	a0,a0,1648 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204718:	afffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020471c:	00003697          	auipc	a3,0x3
ffffffffc0204720:	7cc68693          	addi	a3,a3,1996 # ffffffffc0207ee8 <default_pmm_manager+0x1d8>
ffffffffc0204724:	00002617          	auipc	a2,0x2
ffffffffc0204728:	49460613          	addi	a2,a2,1172 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020472c:	1f500593          	li	a1,501
ffffffffc0204730:	00003517          	auipc	a0,0x3
ffffffffc0204734:	65050513          	addi	a0,a0,1616 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204738:	adffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020473c:	00003697          	auipc	a3,0x3
ffffffffc0204740:	77c68693          	addi	a3,a3,1916 # ffffffffc0207eb8 <default_pmm_manager+0x1a8>
ffffffffc0204744:	00002617          	auipc	a2,0x2
ffffffffc0204748:	47460613          	addi	a2,a2,1140 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020474c:	1f200593          	li	a1,498
ffffffffc0204750:	00003517          	auipc	a0,0x3
ffffffffc0204754:	63050513          	addi	a0,a0,1584 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204758:	abffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020475c:	00004697          	auipc	a3,0x4
ffffffffc0204760:	91468693          	addi	a3,a3,-1772 # ffffffffc0208070 <default_pmm_manager+0x360>
ffffffffc0204764:	00002617          	auipc	a2,0x2
ffffffffc0204768:	45460613          	addi	a2,a2,1108 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020476c:	20e00593          	li	a1,526
ffffffffc0204770:	00003517          	auipc	a0,0x3
ffffffffc0204774:	61050513          	addi	a0,a0,1552 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204778:	a9ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020477c:	00003697          	auipc	a3,0x3
ffffffffc0204780:	7b468693          	addi	a3,a3,1972 # ffffffffc0207f30 <default_pmm_manager+0x220>
ffffffffc0204784:	00002617          	auipc	a2,0x2
ffffffffc0204788:	43460613          	addi	a2,a2,1076 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020478c:	20d00593          	li	a1,525
ffffffffc0204790:	00003517          	auipc	a0,0x3
ffffffffc0204794:	5f050513          	addi	a0,a0,1520 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204798:	a7ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020479c:	00004697          	auipc	a3,0x4
ffffffffc02047a0:	8ec68693          	addi	a3,a3,-1812 # ffffffffc0208088 <default_pmm_manager+0x378>
ffffffffc02047a4:	00002617          	auipc	a2,0x2
ffffffffc02047a8:	41460613          	addi	a2,a2,1044 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02047ac:	20a00593          	li	a1,522
ffffffffc02047b0:	00003517          	auipc	a0,0x3
ffffffffc02047b4:	5d050513          	addi	a0,a0,1488 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02047b8:	a5ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02047bc:	00004697          	auipc	a3,0x4
ffffffffc02047c0:	acc68693          	addi	a3,a3,-1332 # ffffffffc0208288 <default_pmm_manager+0x578>
ffffffffc02047c4:	00002617          	auipc	a2,0x2
ffffffffc02047c8:	3f460613          	addi	a2,a2,1012 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02047cc:	23c00593          	li	a1,572
ffffffffc02047d0:	00003517          	auipc	a0,0x3
ffffffffc02047d4:	5b050513          	addi	a0,a0,1456 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02047d8:	a3ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02047dc:	00004697          	auipc	a3,0x4
ffffffffc02047e0:	90468693          	addi	a3,a3,-1788 # ffffffffc02080e0 <default_pmm_manager+0x3d0>
ffffffffc02047e4:	00002617          	auipc	a2,0x2
ffffffffc02047e8:	3d460613          	addi	a2,a2,980 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02047ec:	21c00593          	li	a1,540
ffffffffc02047f0:	00003517          	auipc	a0,0x3
ffffffffc02047f4:	59050513          	addi	a0,a0,1424 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02047f8:	a1ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02047fc:	00004697          	auipc	a3,0x4
ffffffffc0204800:	97c68693          	addi	a3,a3,-1668 # ffffffffc0208178 <default_pmm_manager+0x468>
ffffffffc0204804:	00002617          	auipc	a2,0x2
ffffffffc0204808:	3b460613          	addi	a2,a2,948 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020480c:	22e00593          	li	a1,558
ffffffffc0204810:	00003517          	auipc	a0,0x3
ffffffffc0204814:	57050513          	addi	a0,a0,1392 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204818:	9fffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020481c:	00003697          	auipc	a3,0x3
ffffffffc0204820:	61c68693          	addi	a3,a3,1564 # ffffffffc0207e38 <default_pmm_manager+0x128>
ffffffffc0204824:	00002617          	auipc	a2,0x2
ffffffffc0204828:	39460613          	addi	a2,a2,916 # ffffffffc0206bb8 <commands+0x480>
ffffffffc020482c:	1ec00593          	li	a1,492
ffffffffc0204830:	00003517          	auipc	a0,0x3
ffffffffc0204834:	55050513          	addi	a0,a0,1360 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204838:	9dffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020483c:	00003617          	auipc	a2,0x3
ffffffffc0204840:	d2c60613          	addi	a2,a2,-724 # ffffffffc0207568 <commands+0xe30>
ffffffffc0204844:	0c100593          	li	a1,193
ffffffffc0204848:	00003517          	auipc	a0,0x3
ffffffffc020484c:	53850513          	addi	a0,a0,1336 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204850:	9c7fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204854 <copy_range>:
               bool share) {
ffffffffc0204854:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0204856:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc020485a:	f486                	sd	ra,104(sp)
ffffffffc020485c:	f0a2                	sd	s0,96(sp)
ffffffffc020485e:	eca6                	sd	s1,88(sp)
ffffffffc0204860:	e8ca                	sd	s2,80(sp)
ffffffffc0204862:	e4ce                	sd	s3,72(sp)
ffffffffc0204864:	e0d2                	sd	s4,64(sp)
ffffffffc0204866:	fc56                	sd	s5,56(sp)
ffffffffc0204868:	f85a                	sd	s6,48(sp)
ffffffffc020486a:	f45e                	sd	s7,40(sp)
ffffffffc020486c:	f062                	sd	s8,32(sp)
ffffffffc020486e:	ec66                	sd	s9,24(sp)
ffffffffc0204870:	e86a                	sd	s10,16(sp)
ffffffffc0204872:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0204874:	03479713          	slli	a4,a5,0x34
ffffffffc0204878:	1c071a63          	bnez	a4,ffffffffc0204a4c <copy_range+0x1f8>
    assert(USER_ACCESS(start, end));
ffffffffc020487c:	002007b7          	lui	a5,0x200
ffffffffc0204880:	8432                	mv	s0,a2
ffffffffc0204882:	18f66563          	bltu	a2,a5,ffffffffc0204a0c <copy_range+0x1b8>
ffffffffc0204886:	84b6                	mv	s1,a3
ffffffffc0204888:	18d67263          	bleu	a3,a2,ffffffffc0204a0c <copy_range+0x1b8>
ffffffffc020488c:	4785                	li	a5,1
ffffffffc020488e:	07fe                	slli	a5,a5,0x1f
ffffffffc0204890:	16d7ee63          	bltu	a5,a3,ffffffffc0204a0c <copy_range+0x1b8>
ffffffffc0204894:	5a7d                	li	s4,-1
ffffffffc0204896:	8aaa                	mv	s5,a0
ffffffffc0204898:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc020489a:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc020489c:	000a8b97          	auipc	s7,0xa8
ffffffffc02048a0:	aecb8b93          	addi	s7,s7,-1300 # ffffffffc02ac388 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02048a4:	000a8b17          	auipc	s6,0xa8
ffffffffc02048a8:	c24b0b13          	addi	s6,s6,-988 # ffffffffc02ac4c8 <pages>
    return page - pages + nbase;
ffffffffc02048ac:	00080c37          	lui	s8,0x80
    return KADDR(page2pa(page));
ffffffffc02048b0:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02048b4:	4601                	li	a2,0
ffffffffc02048b6:	85a2                	mv	a1,s0
ffffffffc02048b8:	854a                	mv	a0,s2
ffffffffc02048ba:	e3dfe0ef          	jal	ra,ffffffffc02036f6 <get_pte>
ffffffffc02048be:	8caa                	mv	s9,a0
        if (ptep == NULL) {
ffffffffc02048c0:	c569                	beqz	a0,ffffffffc020498a <copy_range+0x136>
        if (*ptep & PTE_V) {
ffffffffc02048c2:	611c                	ld	a5,0(a0)
ffffffffc02048c4:	8b85                	andi	a5,a5,1
ffffffffc02048c6:	e785                	bnez	a5,ffffffffc02048ee <copy_range+0x9a>
        start += PGSIZE;
ffffffffc02048c8:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc02048ca:	fe9465e3          	bltu	s0,s1,ffffffffc02048b4 <copy_range+0x60>
    return 0;
ffffffffc02048ce:	4501                	li	a0,0
}
ffffffffc02048d0:	70a6                	ld	ra,104(sp)
ffffffffc02048d2:	7406                	ld	s0,96(sp)
ffffffffc02048d4:	64e6                	ld	s1,88(sp)
ffffffffc02048d6:	6946                	ld	s2,80(sp)
ffffffffc02048d8:	69a6                	ld	s3,72(sp)
ffffffffc02048da:	6a06                	ld	s4,64(sp)
ffffffffc02048dc:	7ae2                	ld	s5,56(sp)
ffffffffc02048de:	7b42                	ld	s6,48(sp)
ffffffffc02048e0:	7ba2                	ld	s7,40(sp)
ffffffffc02048e2:	7c02                	ld	s8,32(sp)
ffffffffc02048e4:	6ce2                	ld	s9,24(sp)
ffffffffc02048e6:	6d42                	ld	s10,16(sp)
ffffffffc02048e8:	6da2                	ld	s11,8(sp)
ffffffffc02048ea:	6165                	addi	sp,sp,112
ffffffffc02048ec:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc02048ee:	4605                	li	a2,1
ffffffffc02048f0:	85a2                	mv	a1,s0
ffffffffc02048f2:	8556                	mv	a0,s5
ffffffffc02048f4:	e03fe0ef          	jal	ra,ffffffffc02036f6 <get_pte>
ffffffffc02048f8:	c15d                	beqz	a0,ffffffffc020499e <copy_range+0x14a>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02048fa:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc02048fe:	0017f713          	andi	a4,a5,1
ffffffffc0204902:	01f7fc93          	andi	s9,a5,31
ffffffffc0204906:	0e070763          	beqz	a4,ffffffffc02049f4 <copy_range+0x1a0>
    if (PPN(pa) >= npage) {
ffffffffc020490a:	000bb683          	ld	a3,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc020490e:	078a                	slli	a5,a5,0x2
ffffffffc0204910:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204914:	0cd77463          	bleu	a3,a4,ffffffffc02049dc <copy_range+0x188>
    return &pages[PPN(pa) - nbase];
ffffffffc0204918:	000b3783          	ld	a5,0(s6)
ffffffffc020491c:	fff806b7          	lui	a3,0xfff80
ffffffffc0204920:	9736                	add	a4,a4,a3
ffffffffc0204922:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc0204924:	4505                	li	a0,1
ffffffffc0204926:	00e78d33          	add	s10,a5,a4
ffffffffc020492a:	cbffe0ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc020492e:	8daa                	mv	s11,a0
            assert(page != NULL);
ffffffffc0204930:	080d0663          	beqz	s10,ffffffffc02049bc <copy_range+0x168>
            assert(npage != NULL);
ffffffffc0204934:	0e050c63          	beqz	a0,ffffffffc0204a2c <copy_range+0x1d8>
    return page - pages + nbase;
ffffffffc0204938:	000b3703          	ld	a4,0(s6)
    return KADDR(page2pa(page));
ffffffffc020493c:	000bb603          	ld	a2,0(s7)
    return page - pages + nbase;
ffffffffc0204940:	40ed06b3          	sub	a3,s10,a4
ffffffffc0204944:	8699                	srai	a3,a3,0x6
ffffffffc0204946:	96e2                	add	a3,a3,s8
    return KADDR(page2pa(page));
ffffffffc0204948:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc020494c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020494e:	04c7fb63          	bleu	a2,a5,ffffffffc02049a4 <copy_range+0x150>
    return page - pages + nbase;
ffffffffc0204952:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc0204956:	000a8717          	auipc	a4,0xa8
ffffffffc020495a:	b6270713          	addi	a4,a4,-1182 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc020495e:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc0204960:	8799                	srai	a5,a5,0x6
ffffffffc0204962:	97e2                	add	a5,a5,s8
    return KADDR(page2pa(page));
ffffffffc0204964:	0147f733          	and	a4,a5,s4
ffffffffc0204968:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020496c:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020496e:	02c77a63          	bleu	a2,a4,ffffffffc02049a2 <copy_range+0x14e>
            memcpy(kva_dst, kva_src, PGSIZE);
ffffffffc0204972:	6605                	lui	a2,0x1
ffffffffc0204974:	953e                	add	a0,a0,a5
ffffffffc0204976:	02b010ef          	jal	ra,ffffffffc02061a0 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc020497a:	8622                	mv	a2,s0
ffffffffc020497c:	86e6                	mv	a3,s9
ffffffffc020497e:	85ee                	mv	a1,s11
ffffffffc0204980:	8556                	mv	a0,s5
ffffffffc0204982:	b8aff0ef          	jal	ra,ffffffffc0203d0c <page_insert>
        start += PGSIZE;
ffffffffc0204986:	944e                	add	s0,s0,s3
ffffffffc0204988:	b789                	j	ffffffffc02048ca <copy_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020498a:	002007b7          	lui	a5,0x200
ffffffffc020498e:	943e                	add	s0,s0,a5
ffffffffc0204990:	ffe007b7          	lui	a5,0xffe00
ffffffffc0204994:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc0204996:	dc05                	beqz	s0,ffffffffc02048ce <copy_range+0x7a>
ffffffffc0204998:	f0946ee3          	bltu	s0,s1,ffffffffc02048b4 <copy_range+0x60>
ffffffffc020499c:	bf0d                	j	ffffffffc02048ce <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc020499e:	5571                	li	a0,-4
ffffffffc02049a0:	bf05                	j	ffffffffc02048d0 <copy_range+0x7c>
ffffffffc02049a2:	86be                	mv	a3,a5
ffffffffc02049a4:	00003617          	auipc	a2,0x3
ffffffffc02049a8:	94c60613          	addi	a2,a2,-1716 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc02049ac:	06900593          	li	a1,105
ffffffffc02049b0:	00003517          	auipc	a0,0x3
ffffffffc02049b4:	93050513          	addi	a0,a0,-1744 # ffffffffc02072e0 <commands+0xba8>
ffffffffc02049b8:	85ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
            assert(page != NULL);
ffffffffc02049bc:	00003697          	auipc	a3,0x3
ffffffffc02049c0:	3a468693          	addi	a3,a3,932 # ffffffffc0207d60 <default_pmm_manager+0x50>
ffffffffc02049c4:	00002617          	auipc	a2,0x2
ffffffffc02049c8:	1f460613          	addi	a2,a2,500 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02049cc:	17200593          	li	a1,370
ffffffffc02049d0:	00003517          	auipc	a0,0x3
ffffffffc02049d4:	3b050513          	addi	a0,a0,944 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc02049d8:	83ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02049dc:	00003617          	auipc	a2,0x3
ffffffffc02049e0:	8e460613          	addi	a2,a2,-1820 # ffffffffc02072c0 <commands+0xb88>
ffffffffc02049e4:	06200593          	li	a1,98
ffffffffc02049e8:	00003517          	auipc	a0,0x3
ffffffffc02049ec:	8f850513          	addi	a0,a0,-1800 # ffffffffc02072e0 <commands+0xba8>
ffffffffc02049f0:	827fb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02049f4:	00003617          	auipc	a2,0x3
ffffffffc02049f8:	e6c60613          	addi	a2,a2,-404 # ffffffffc0207860 <commands+0x1128>
ffffffffc02049fc:	07400593          	li	a1,116
ffffffffc0204a00:	00003517          	auipc	a0,0x3
ffffffffc0204a04:	8e050513          	addi	a0,a0,-1824 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0204a08:	80ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0204a0c:	00004697          	auipc	a3,0x4
ffffffffc0204a10:	8f468693          	addi	a3,a3,-1804 # ffffffffc0208300 <default_pmm_manager+0x5f0>
ffffffffc0204a14:	00002617          	auipc	a2,0x2
ffffffffc0204a18:	1a460613          	addi	a2,a2,420 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204a1c:	15e00593          	li	a1,350
ffffffffc0204a20:	00003517          	auipc	a0,0x3
ffffffffc0204a24:	36050513          	addi	a0,a0,864 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204a28:	feefb0ef          	jal	ra,ffffffffc0200216 <__panic>
            assert(npage != NULL);
ffffffffc0204a2c:	00003697          	auipc	a3,0x3
ffffffffc0204a30:	34468693          	addi	a3,a3,836 # ffffffffc0207d70 <default_pmm_manager+0x60>
ffffffffc0204a34:	00002617          	auipc	a2,0x2
ffffffffc0204a38:	18460613          	addi	a2,a2,388 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204a3c:	17300593          	li	a1,371
ffffffffc0204a40:	00003517          	auipc	a0,0x3
ffffffffc0204a44:	34050513          	addi	a0,a0,832 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204a48:	fcefb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0204a4c:	00004697          	auipc	a3,0x4
ffffffffc0204a50:	88468693          	addi	a3,a3,-1916 # ffffffffc02082d0 <default_pmm_manager+0x5c0>
ffffffffc0204a54:	00002617          	auipc	a2,0x2
ffffffffc0204a58:	16460613          	addi	a2,a2,356 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204a5c:	15d00593          	li	a1,349
ffffffffc0204a60:	00003517          	auipc	a0,0x3
ffffffffc0204a64:	32050513          	addi	a0,a0,800 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204a68:	faefb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204a6c <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0204a6c:	12058073          	sfence.vma	a1
}
ffffffffc0204a70:	8082                	ret

ffffffffc0204a72 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204a72:	7179                	addi	sp,sp,-48
ffffffffc0204a74:	e84a                	sd	s2,16(sp)
ffffffffc0204a76:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0204a78:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204a7a:	f022                	sd	s0,32(sp)
ffffffffc0204a7c:	ec26                	sd	s1,24(sp)
ffffffffc0204a7e:	e44e                	sd	s3,8(sp)
ffffffffc0204a80:	f406                	sd	ra,40(sp)
ffffffffc0204a82:	84ae                	mv	s1,a1
ffffffffc0204a84:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0204a86:	b63fe0ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0204a8a:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0204a8c:	cd1d                	beqz	a0,ffffffffc0204aca <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0204a8e:	85aa                	mv	a1,a0
ffffffffc0204a90:	86ce                	mv	a3,s3
ffffffffc0204a92:	8626                	mv	a2,s1
ffffffffc0204a94:	854a                	mv	a0,s2
ffffffffc0204a96:	a76ff0ef          	jal	ra,ffffffffc0203d0c <page_insert>
ffffffffc0204a9a:	e121                	bnez	a0,ffffffffc0204ada <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc0204a9c:	000a8797          	auipc	a5,0xa8
ffffffffc0204aa0:	8dc78793          	addi	a5,a5,-1828 # ffffffffc02ac378 <swap_init_ok>
ffffffffc0204aa4:	439c                	lw	a5,0(a5)
ffffffffc0204aa6:	2781                	sext.w	a5,a5
ffffffffc0204aa8:	c38d                	beqz	a5,ffffffffc0204aca <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc0204aaa:	000a8797          	auipc	a5,0xa8
ffffffffc0204aae:	90e78793          	addi	a5,a5,-1778 # ffffffffc02ac3b8 <check_mm_struct>
ffffffffc0204ab2:	6388                	ld	a0,0(a5)
ffffffffc0204ab4:	c919                	beqz	a0,ffffffffc0204aca <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0204ab6:	4681                	li	a3,0
ffffffffc0204ab8:	8622                	mv	a2,s0
ffffffffc0204aba:	85a6                	mv	a1,s1
ffffffffc0204abc:	e25fd0ef          	jal	ra,ffffffffc02028e0 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0204ac0:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0204ac2:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0204ac4:	4785                	li	a5,1
ffffffffc0204ac6:	02f71063          	bne	a4,a5,ffffffffc0204ae6 <pgdir_alloc_page+0x74>
}
ffffffffc0204aca:	8522                	mv	a0,s0
ffffffffc0204acc:	70a2                	ld	ra,40(sp)
ffffffffc0204ace:	7402                	ld	s0,32(sp)
ffffffffc0204ad0:	64e2                	ld	s1,24(sp)
ffffffffc0204ad2:	6942                	ld	s2,16(sp)
ffffffffc0204ad4:	69a2                	ld	s3,8(sp)
ffffffffc0204ad6:	6145                	addi	sp,sp,48
ffffffffc0204ad8:	8082                	ret
            free_page(page);
ffffffffc0204ada:	8522                	mv	a0,s0
ffffffffc0204adc:	4585                	li	a1,1
ffffffffc0204ade:	b93fe0ef          	jal	ra,ffffffffc0203670 <free_pages>
            return NULL;
ffffffffc0204ae2:	4401                	li	s0,0
ffffffffc0204ae4:	b7dd                	j	ffffffffc0204aca <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc0204ae6:	00003697          	auipc	a3,0x3
ffffffffc0204aea:	2aa68693          	addi	a3,a3,682 # ffffffffc0207d90 <default_pmm_manager+0x80>
ffffffffc0204aee:	00002617          	auipc	a2,0x2
ffffffffc0204af2:	0ca60613          	addi	a2,a2,202 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0204af6:	1cd00593          	li	a1,461
ffffffffc0204afa:	00003517          	auipc	a0,0x3
ffffffffc0204afe:	28650513          	addi	a0,a0,646 # ffffffffc0207d80 <default_pmm_manager+0x70>
ffffffffc0204b02:	f14fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204b06 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b06:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b08:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b0a:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b0c:	a29fb0ef          	jal	ra,ffffffffc0200534 <ide_device_valid>
ffffffffc0204b10:	cd01                	beqz	a0,ffffffffc0204b28 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b12:	4505                	li	a0,1
ffffffffc0204b14:	a27fb0ef          	jal	ra,ffffffffc020053a <ide_device_size>
}
ffffffffc0204b18:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b1a:	810d                	srli	a0,a0,0x3
ffffffffc0204b1c:	000a8797          	auipc	a5,0xa8
ffffffffc0204b20:	92a7be23          	sd	a0,-1732(a5) # ffffffffc02ac458 <max_swap_offset>
}
ffffffffc0204b24:	0141                	addi	sp,sp,16
ffffffffc0204b26:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b28:	00003617          	auipc	a2,0x3
ffffffffc0204b2c:	7f060613          	addi	a2,a2,2032 # ffffffffc0208318 <default_pmm_manager+0x608>
ffffffffc0204b30:	45b5                	li	a1,13
ffffffffc0204b32:	00004517          	auipc	a0,0x4
ffffffffc0204b36:	80650513          	addi	a0,a0,-2042 # ffffffffc0208338 <default_pmm_manager+0x628>
ffffffffc0204b3a:	edcfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204b3e <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b3e:	1141                	addi	sp,sp,-16
ffffffffc0204b40:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b42:	00855793          	srli	a5,a0,0x8
ffffffffc0204b46:	cfb9                	beqz	a5,ffffffffc0204ba4 <swapfs_read+0x66>
ffffffffc0204b48:	000a8717          	auipc	a4,0xa8
ffffffffc0204b4c:	91070713          	addi	a4,a4,-1776 # ffffffffc02ac458 <max_swap_offset>
ffffffffc0204b50:	6318                	ld	a4,0(a4)
ffffffffc0204b52:	04e7f963          	bleu	a4,a5,ffffffffc0204ba4 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204b56:	000a8717          	auipc	a4,0xa8
ffffffffc0204b5a:	97270713          	addi	a4,a4,-1678 # ffffffffc02ac4c8 <pages>
ffffffffc0204b5e:	6310                	ld	a2,0(a4)
ffffffffc0204b60:	00004717          	auipc	a4,0x4
ffffffffc0204b64:	13070713          	addi	a4,a4,304 # ffffffffc0208c90 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204b68:	000a8697          	auipc	a3,0xa8
ffffffffc0204b6c:	82068693          	addi	a3,a3,-2016 # ffffffffc02ac388 <npage>
    return page - pages + nbase;
ffffffffc0204b70:	40c58633          	sub	a2,a1,a2
ffffffffc0204b74:	630c                	ld	a1,0(a4)
ffffffffc0204b76:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204b78:	577d                	li	a4,-1
ffffffffc0204b7a:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204b7c:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204b7e:	8331                	srli	a4,a4,0xc
ffffffffc0204b80:	8f71                	and	a4,a4,a2
ffffffffc0204b82:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b86:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204b88:	02d77a63          	bleu	a3,a4,ffffffffc0204bbc <swapfs_read+0x7e>
ffffffffc0204b8c:	000a8797          	auipc	a5,0xa8
ffffffffc0204b90:	92c78793          	addi	a5,a5,-1748 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc0204b94:	639c                	ld	a5,0(a5)
}
ffffffffc0204b96:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b98:	46a1                	li	a3,8
ffffffffc0204b9a:	963e                	add	a2,a2,a5
ffffffffc0204b9c:	4505                	li	a0,1
}
ffffffffc0204b9e:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ba0:	9a1fb06f          	j	ffffffffc0200540 <ide_read_secs>
ffffffffc0204ba4:	86aa                	mv	a3,a0
ffffffffc0204ba6:	00003617          	auipc	a2,0x3
ffffffffc0204baa:	7aa60613          	addi	a2,a2,1962 # ffffffffc0208350 <default_pmm_manager+0x640>
ffffffffc0204bae:	45d1                	li	a1,20
ffffffffc0204bb0:	00003517          	auipc	a0,0x3
ffffffffc0204bb4:	78850513          	addi	a0,a0,1928 # ffffffffc0208338 <default_pmm_manager+0x628>
ffffffffc0204bb8:	e5efb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204bbc:	86b2                	mv	a3,a2
ffffffffc0204bbe:	06900593          	li	a1,105
ffffffffc0204bc2:	00002617          	auipc	a2,0x2
ffffffffc0204bc6:	72e60613          	addi	a2,a2,1838 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc0204bca:	00002517          	auipc	a0,0x2
ffffffffc0204bce:	71650513          	addi	a0,a0,1814 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0204bd2:	e44fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204bd6 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204bd6:	1141                	addi	sp,sp,-16
ffffffffc0204bd8:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bda:	00855793          	srli	a5,a0,0x8
ffffffffc0204bde:	cfb9                	beqz	a5,ffffffffc0204c3c <swapfs_write+0x66>
ffffffffc0204be0:	000a8717          	auipc	a4,0xa8
ffffffffc0204be4:	87870713          	addi	a4,a4,-1928 # ffffffffc02ac458 <max_swap_offset>
ffffffffc0204be8:	6318                	ld	a4,0(a4)
ffffffffc0204bea:	04e7f963          	bleu	a4,a5,ffffffffc0204c3c <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204bee:	000a8717          	auipc	a4,0xa8
ffffffffc0204bf2:	8da70713          	addi	a4,a4,-1830 # ffffffffc02ac4c8 <pages>
ffffffffc0204bf6:	6310                	ld	a2,0(a4)
ffffffffc0204bf8:	00004717          	auipc	a4,0x4
ffffffffc0204bfc:	09870713          	addi	a4,a4,152 # ffffffffc0208c90 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204c00:	000a7697          	auipc	a3,0xa7
ffffffffc0204c04:	78868693          	addi	a3,a3,1928 # ffffffffc02ac388 <npage>
    return page - pages + nbase;
ffffffffc0204c08:	40c58633          	sub	a2,a1,a2
ffffffffc0204c0c:	630c                	ld	a1,0(a4)
ffffffffc0204c0e:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204c10:	577d                	li	a4,-1
ffffffffc0204c12:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204c14:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204c16:	8331                	srli	a4,a4,0xc
ffffffffc0204c18:	8f71                	and	a4,a4,a2
ffffffffc0204c1a:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c1e:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c20:	02d77a63          	bleu	a3,a4,ffffffffc0204c54 <swapfs_write+0x7e>
ffffffffc0204c24:	000a8797          	auipc	a5,0xa8
ffffffffc0204c28:	89478793          	addi	a5,a5,-1900 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc0204c2c:	639c                	ld	a5,0(a5)
}
ffffffffc0204c2e:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c30:	46a1                	li	a3,8
ffffffffc0204c32:	963e                	add	a2,a2,a5
ffffffffc0204c34:	4505                	li	a0,1
}
ffffffffc0204c36:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c38:	92dfb06f          	j	ffffffffc0200564 <ide_write_secs>
ffffffffc0204c3c:	86aa                	mv	a3,a0
ffffffffc0204c3e:	00003617          	auipc	a2,0x3
ffffffffc0204c42:	71260613          	addi	a2,a2,1810 # ffffffffc0208350 <default_pmm_manager+0x640>
ffffffffc0204c46:	45e5                	li	a1,25
ffffffffc0204c48:	00003517          	auipc	a0,0x3
ffffffffc0204c4c:	6f050513          	addi	a0,a0,1776 # ffffffffc0208338 <default_pmm_manager+0x628>
ffffffffc0204c50:	dc6fb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204c54:	86b2                	mv	a3,a2
ffffffffc0204c56:	06900593          	li	a1,105
ffffffffc0204c5a:	00002617          	auipc	a2,0x2
ffffffffc0204c5e:	69660613          	addi	a2,a2,1686 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc0204c62:	00002517          	auipc	a0,0x2
ffffffffc0204c66:	67e50513          	addi	a0,a0,1662 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0204c6a:	dacfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204c6e <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204c6e:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204c70:	9402                	jalr	s0

	jal do_exit
ffffffffc0204c72:	770000ef          	jal	ra,ffffffffc02053e2 <do_exit>

ffffffffc0204c76 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204c76:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204c7a:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204c7e:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204c80:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204c82:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204c86:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204c8a:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204c8e:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204c92:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204c96:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204c9a:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204c9e:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204ca2:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204ca6:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204caa:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204cae:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204cb2:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204cb4:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204cb6:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204cba:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204cbe:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204cc2:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204cc6:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204cca:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204cce:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204cd2:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204cd6:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204cda:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204cde:	8082                	ret

ffffffffc0204ce0 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204ce0:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204ce2:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204ce6:	e022                	sd	s0,0(sp)
ffffffffc0204ce8:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204cea:	a86fd0ef          	jal	ra,ffffffffc0201f70 <kmalloc>
ffffffffc0204cee:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204cf0:	c51d                	beqz	a0,ffffffffc0204d1e <alloc_proc+0x3e>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    memset(proc,0,sizeof(struct proc_struct));    //其他全设为0
ffffffffc0204cf2:	10800613          	li	a2,264
ffffffffc0204cf6:	4581                	li	a1,0
ffffffffc0204cf8:	496010ef          	jal	ra,ffffffffc020618e <memset>
    proc->state = PROC_UNINIT;  //设置进程为未初始化状态
ffffffffc0204cfc:	57fd                	li	a5,-1
ffffffffc0204cfe:	1782                	slli	a5,a5,0x20
ffffffffc0204d00:	e01c                	sd	a5,0(s0)
    proc->pid = -1;             //未初始化的的进程id为-1
    proc->cr3 = boot_cr3;       //页目录设为内核页目录表的基址
ffffffffc0204d02:	000a7797          	auipc	a5,0xa7
ffffffffc0204d06:	7be78793          	addi	a5,a5,1982 # ffffffffc02ac4c0 <boot_cr3>
ffffffffc0204d0a:	639c                	ld	a5,0(a5)
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->wait_state = 0;  //初始化进程等待状态  
ffffffffc0204d0c:	0e042623          	sw	zero,236(s0)
    proc->cptr = proc->optr = proc->yptr = NULL;//进程相关指针初始化 
ffffffffc0204d10:	0e043c23          	sd	zero,248(s0)
    proc->cr3 = boot_cr3;       //页目录设为内核页目录表的基址
ffffffffc0204d14:	f45c                	sd	a5,168(s0)
    proc->cptr = proc->optr = proc->yptr = NULL;//进程相关指针初始化 
ffffffffc0204d16:	10043023          	sd	zero,256(s0)
ffffffffc0204d1a:	0e043823          	sd	zero,240(s0)

    }
    return proc;
}
ffffffffc0204d1e:	8522                	mv	a0,s0
ffffffffc0204d20:	60a2                	ld	ra,8(sp)
ffffffffc0204d22:	6402                	ld	s0,0(sp)
ffffffffc0204d24:	0141                	addi	sp,sp,16
ffffffffc0204d26:	8082                	ret

ffffffffc0204d28 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204d28:	000a7797          	auipc	a5,0xa7
ffffffffc0204d2c:	66878793          	addi	a5,a5,1640 # ffffffffc02ac390 <current>
ffffffffc0204d30:	639c                	ld	a5,0(a5)
ffffffffc0204d32:	73c8                	ld	a0,160(a5)
ffffffffc0204d34:	876fc06f          	j	ffffffffc0200daa <forkrets>

ffffffffc0204d38 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d38:	000a7797          	auipc	a5,0xa7
ffffffffc0204d3c:	65878793          	addi	a5,a5,1624 # ffffffffc02ac390 <current>
ffffffffc0204d40:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204d42:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d44:	00004617          	auipc	a2,0x4
ffffffffc0204d48:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0208760 <default_pmm_manager+0xa50>
ffffffffc0204d4c:	43cc                	lw	a1,4(a5)
ffffffffc0204d4e:	00004517          	auipc	a0,0x4
ffffffffc0204d52:	a2250513          	addi	a0,a0,-1502 # ffffffffc0208770 <default_pmm_manager+0xa60>
user_main(void *arg) {
ffffffffc0204d56:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d58:	b78fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0204d5c:	00004797          	auipc	a5,0x4
ffffffffc0204d60:	a0478793          	addi	a5,a5,-1532 # ffffffffc0208760 <default_pmm_manager+0xa50>
ffffffffc0204d64:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204d68:	56c70713          	addi	a4,a4,1388 # a2d0 <_binary_obj___user_forktest_out_size>
ffffffffc0204d6c:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204d6e:	853e                	mv	a0,a5
ffffffffc0204d70:	00088717          	auipc	a4,0x88
ffffffffc0204d74:	75070713          	addi	a4,a4,1872 # ffffffffc028d4c0 <_binary_obj___user_forktest_out_start>
ffffffffc0204d78:	f03a                	sd	a4,32(sp)
ffffffffc0204d7a:	f43e                	sd	a5,40(sp)
ffffffffc0204d7c:	e802                	sd	zero,16(sp)
ffffffffc0204d7e:	372010ef          	jal	ra,ffffffffc02060f0 <strlen>
ffffffffc0204d82:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204d84:	4511                	li	a0,4
ffffffffc0204d86:	55a2                	lw	a1,40(sp)
ffffffffc0204d88:	4662                	lw	a2,24(sp)
ffffffffc0204d8a:	5682                	lw	a3,32(sp)
ffffffffc0204d8c:	4722                	lw	a4,8(sp)
ffffffffc0204d8e:	48a9                	li	a7,10
ffffffffc0204d90:	9002                	ebreak
ffffffffc0204d92:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204d94:	65c2                	ld	a1,16(sp)
ffffffffc0204d96:	00004517          	auipc	a0,0x4
ffffffffc0204d9a:	a0250513          	addi	a0,a0,-1534 # ffffffffc0208798 <default_pmm_manager+0xa88>
ffffffffc0204d9e:	b32fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204da2:	00004617          	auipc	a2,0x4
ffffffffc0204da6:	a0660613          	addi	a2,a2,-1530 # ffffffffc02087a8 <default_pmm_manager+0xa98>
ffffffffc0204daa:	34d00593          	li	a1,845
ffffffffc0204dae:	00004517          	auipc	a0,0x4
ffffffffc0204db2:	a1a50513          	addi	a0,a0,-1510 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc0204db6:	c60fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204dba <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204dba:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204dbc:	1141                	addi	sp,sp,-16
ffffffffc0204dbe:	e406                	sd	ra,8(sp)
ffffffffc0204dc0:	c02007b7          	lui	a5,0xc0200
ffffffffc0204dc4:	04f6e263          	bltu	a3,a5,ffffffffc0204e08 <put_pgdir+0x4e>
ffffffffc0204dc8:	000a7797          	auipc	a5,0xa7
ffffffffc0204dcc:	6f078793          	addi	a5,a5,1776 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc0204dd0:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204dd2:	000a7797          	auipc	a5,0xa7
ffffffffc0204dd6:	5b678793          	addi	a5,a5,1462 # ffffffffc02ac388 <npage>
ffffffffc0204dda:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204ddc:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204dde:	82b1                	srli	a3,a3,0xc
ffffffffc0204de0:	04f6f063          	bleu	a5,a3,ffffffffc0204e20 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204de4:	00004797          	auipc	a5,0x4
ffffffffc0204de8:	eac78793          	addi	a5,a5,-340 # ffffffffc0208c90 <nbase>
ffffffffc0204dec:	639c                	ld	a5,0(a5)
ffffffffc0204dee:	000a7717          	auipc	a4,0xa7
ffffffffc0204df2:	6da70713          	addi	a4,a4,1754 # ffffffffc02ac4c8 <pages>
ffffffffc0204df6:	6308                	ld	a0,0(a4)
}
ffffffffc0204df8:	60a2                	ld	ra,8(sp)
ffffffffc0204dfa:	8e9d                	sub	a3,a3,a5
ffffffffc0204dfc:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204dfe:	4585                	li	a1,1
ffffffffc0204e00:	9536                	add	a0,a0,a3
}
ffffffffc0204e02:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e04:	86dfe06f          	j	ffffffffc0203670 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e08:	00002617          	auipc	a2,0x2
ffffffffc0204e0c:	76060613          	addi	a2,a2,1888 # ffffffffc0207568 <commands+0xe30>
ffffffffc0204e10:	06e00593          	li	a1,110
ffffffffc0204e14:	00002517          	auipc	a0,0x2
ffffffffc0204e18:	4cc50513          	addi	a0,a0,1228 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0204e1c:	bfafb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e20:	00002617          	auipc	a2,0x2
ffffffffc0204e24:	4a060613          	addi	a2,a2,1184 # ffffffffc02072c0 <commands+0xb88>
ffffffffc0204e28:	06200593          	li	a1,98
ffffffffc0204e2c:	00002517          	auipc	a0,0x2
ffffffffc0204e30:	4b450513          	addi	a0,a0,1204 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0204e34:	be2fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204e38 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e38:	1101                	addi	sp,sp,-32
ffffffffc0204e3a:	e426                	sd	s1,8(sp)
ffffffffc0204e3c:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e3e:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e40:	ec06                	sd	ra,24(sp)
ffffffffc0204e42:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e44:	fa4fe0ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
ffffffffc0204e48:	c125                	beqz	a0,ffffffffc0204ea8 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204e4a:	000a7797          	auipc	a5,0xa7
ffffffffc0204e4e:	67e78793          	addi	a5,a5,1662 # ffffffffc02ac4c8 <pages>
ffffffffc0204e52:	6394                	ld	a3,0(a5)
ffffffffc0204e54:	00004797          	auipc	a5,0x4
ffffffffc0204e58:	e3c78793          	addi	a5,a5,-452 # ffffffffc0208c90 <nbase>
ffffffffc0204e5c:	6380                	ld	s0,0(a5)
ffffffffc0204e5e:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e62:	000a7717          	auipc	a4,0xa7
ffffffffc0204e66:	52670713          	addi	a4,a4,1318 # ffffffffc02ac388 <npage>
    return page - pages + nbase;
ffffffffc0204e6a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204e6c:	57fd                	li	a5,-1
ffffffffc0204e6e:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204e70:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204e72:	83b1                	srli	a5,a5,0xc
ffffffffc0204e74:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e76:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e78:	02e7fa63          	bleu	a4,a5,ffffffffc0204eac <setup_pgdir+0x74>
ffffffffc0204e7c:	000a7797          	auipc	a5,0xa7
ffffffffc0204e80:	63c78793          	addi	a5,a5,1596 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc0204e84:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204e86:	000a7797          	auipc	a5,0xa7
ffffffffc0204e8a:	4fa78793          	addi	a5,a5,1274 # ffffffffc02ac380 <boot_pgdir>
ffffffffc0204e8e:	638c                	ld	a1,0(a5)
ffffffffc0204e90:	9436                	add	s0,s0,a3
ffffffffc0204e92:	6605                	lui	a2,0x1
ffffffffc0204e94:	8522                	mv	a0,s0
ffffffffc0204e96:	30a010ef          	jal	ra,ffffffffc02061a0 <memcpy>
    return 0;
ffffffffc0204e9a:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204e9c:	ec80                	sd	s0,24(s1)
}
ffffffffc0204e9e:	60e2                	ld	ra,24(sp)
ffffffffc0204ea0:	6442                	ld	s0,16(sp)
ffffffffc0204ea2:	64a2                	ld	s1,8(sp)
ffffffffc0204ea4:	6105                	addi	sp,sp,32
ffffffffc0204ea6:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204ea8:	5571                	li	a0,-4
ffffffffc0204eaa:	bfd5                	j	ffffffffc0204e9e <setup_pgdir+0x66>
ffffffffc0204eac:	00002617          	auipc	a2,0x2
ffffffffc0204eb0:	44460613          	addi	a2,a2,1092 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc0204eb4:	06900593          	li	a1,105
ffffffffc0204eb8:	00002517          	auipc	a0,0x2
ffffffffc0204ebc:	42850513          	addi	a0,a0,1064 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0204ec0:	b56fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204ec4 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ec4:	1101                	addi	sp,sp,-32
ffffffffc0204ec6:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ec8:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ecc:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ece:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ed0:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ed2:	8522                	mv	a0,s0
ffffffffc0204ed4:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ed6:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ed8:	2b6010ef          	jal	ra,ffffffffc020618e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204edc:	8522                	mv	a0,s0
}
ffffffffc0204ede:	6442                	ld	s0,16(sp)
ffffffffc0204ee0:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ee2:	85a6                	mv	a1,s1
}
ffffffffc0204ee4:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ee6:	463d                	li	a2,15
}
ffffffffc0204ee8:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204eea:	2b60106f          	j	ffffffffc02061a0 <memcpy>

ffffffffc0204eee <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204eee:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204ef0:	000a7797          	auipc	a5,0xa7
ffffffffc0204ef4:	4a078793          	addi	a5,a5,1184 # ffffffffc02ac390 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204ef8:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204efa:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204efc:	ec06                	sd	ra,24(sp)
ffffffffc0204efe:	e822                	sd	s0,16(sp)
ffffffffc0204f00:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204f02:	02a48b63          	beq	s1,a0,ffffffffc0204f38 <proc_run+0x4a>
ffffffffc0204f06:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f08:	100027f3          	csrr	a5,sstatus
ffffffffc0204f0c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f0e:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f10:	e3a9                	bnez	a5,ffffffffc0204f52 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f12:	745c                	ld	a5,168(s0)
            current = proc; // 将当前进程换为 要切换到的进程
ffffffffc0204f14:	000a7717          	auipc	a4,0xa7
ffffffffc0204f18:	46873e23          	sd	s0,1148(a4) # ffffffffc02ac390 <current>
ffffffffc0204f1c:	577d                	li	a4,-1
ffffffffc0204f1e:	177e                	slli	a4,a4,0x3f
ffffffffc0204f20:	83b1                	srli	a5,a5,0xc
ffffffffc0204f22:	8fd9                	or	a5,a5,a4
ffffffffc0204f24:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context)); // 调用 switch_to 进行上下文的保存与切换，切换到新的线程
ffffffffc0204f28:	03040593          	addi	a1,s0,48
ffffffffc0204f2c:	03048513          	addi	a0,s1,48
ffffffffc0204f30:	d47ff0ef          	jal	ra,ffffffffc0204c76 <switch_to>
    if (flag) {
ffffffffc0204f34:	00091863          	bnez	s2,ffffffffc0204f44 <proc_run+0x56>
}
ffffffffc0204f38:	60e2                	ld	ra,24(sp)
ffffffffc0204f3a:	6442                	ld	s0,16(sp)
ffffffffc0204f3c:	64a2                	ld	s1,8(sp)
ffffffffc0204f3e:	6902                	ld	s2,0(sp)
ffffffffc0204f40:	6105                	addi	sp,sp,32
ffffffffc0204f42:	8082                	ret
ffffffffc0204f44:	6442                	ld	s0,16(sp)
ffffffffc0204f46:	60e2                	ld	ra,24(sp)
ffffffffc0204f48:	64a2                	ld	s1,8(sp)
ffffffffc0204f4a:	6902                	ld	s2,0(sp)
ffffffffc0204f4c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204f4e:	f08fb06f          	j	ffffffffc0200656 <intr_enable>
        intr_disable();
ffffffffc0204f52:	f0afb0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0204f56:	4905                	li	s2,1
ffffffffc0204f58:	bf6d                	j	ffffffffc0204f12 <proc_run+0x24>

ffffffffc0204f5a <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204f5a:	0005071b          	sext.w	a4,a0
ffffffffc0204f5e:	6789                	lui	a5,0x2
ffffffffc0204f60:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204f64:	17f9                	addi	a5,a5,-2
ffffffffc0204f66:	04d7e063          	bltu	a5,a3,ffffffffc0204fa6 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204f6a:	1141                	addi	sp,sp,-16
ffffffffc0204f6c:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f6e:	45a9                	li	a1,10
ffffffffc0204f70:	842a                	mv	s0,a0
ffffffffc0204f72:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204f74:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f76:	63a010ef          	jal	ra,ffffffffc02065b0 <hash32>
ffffffffc0204f7a:	02051693          	slli	a3,a0,0x20
ffffffffc0204f7e:	82f1                	srli	a3,a3,0x1c
ffffffffc0204f80:	000a3517          	auipc	a0,0xa3
ffffffffc0204f84:	3d050513          	addi	a0,a0,976 # ffffffffc02a8350 <hash_list>
ffffffffc0204f88:	96aa                	add	a3,a3,a0
ffffffffc0204f8a:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204f8c:	a029                	j	ffffffffc0204f96 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204f8e:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x763c>
ffffffffc0204f92:	00870c63          	beq	a4,s0,ffffffffc0204faa <find_proc+0x50>
    return listelm->next;
ffffffffc0204f96:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204f98:	fef69be3          	bne	a3,a5,ffffffffc0204f8e <find_proc+0x34>
}
ffffffffc0204f9c:	60a2                	ld	ra,8(sp)
ffffffffc0204f9e:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204fa0:	4501                	li	a0,0
}
ffffffffc0204fa2:	0141                	addi	sp,sp,16
ffffffffc0204fa4:	8082                	ret
    return NULL;
ffffffffc0204fa6:	4501                	li	a0,0
}
ffffffffc0204fa8:	8082                	ret
ffffffffc0204faa:	60a2                	ld	ra,8(sp)
ffffffffc0204fac:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204fae:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204fb2:	0141                	addi	sp,sp,16
ffffffffc0204fb4:	8082                	ret

ffffffffc0204fb6 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fb6:	7159                	addi	sp,sp,-112
ffffffffc0204fb8:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204fba:	000a7a17          	auipc	s4,0xa7
ffffffffc0204fbe:	3eea0a13          	addi	s4,s4,1006 # ffffffffc02ac3a8 <nr_process>
ffffffffc0204fc2:	000a2703          	lw	a4,0(s4)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fc6:	f486                	sd	ra,104(sp)
ffffffffc0204fc8:	f0a2                	sd	s0,96(sp)
ffffffffc0204fca:	eca6                	sd	s1,88(sp)
ffffffffc0204fcc:	e8ca                	sd	s2,80(sp)
ffffffffc0204fce:	e4ce                	sd	s3,72(sp)
ffffffffc0204fd0:	fc56                	sd	s5,56(sp)
ffffffffc0204fd2:	f85a                	sd	s6,48(sp)
ffffffffc0204fd4:	f45e                	sd	s7,40(sp)
ffffffffc0204fd6:	f062                	sd	s8,32(sp)
ffffffffc0204fd8:	ec66                	sd	s9,24(sp)
ffffffffc0204fda:	e86a                	sd	s10,16(sp)
ffffffffc0204fdc:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204fde:	6785                	lui	a5,0x1
ffffffffc0204fe0:	30f75a63          	ble	a5,a4,ffffffffc02052f4 <do_fork+0x33e>
ffffffffc0204fe4:	89aa                	mv	s3,a0
ffffffffc0204fe6:	892e                	mv	s2,a1
ffffffffc0204fe8:	84b2                	mv	s1,a2
   proc = alloc_proc();
ffffffffc0204fea:	cf7ff0ef          	jal	ra,ffffffffc0204ce0 <alloc_proc>
ffffffffc0204fee:	842a                	mv	s0,a0
    if(proc == NULL){
ffffffffc0204ff0:	2e050463          	beqz	a0,ffffffffc02052d8 <do_fork+0x322>
    proc->parent=current;
ffffffffc0204ff4:	000a7c17          	auipc	s8,0xa7
ffffffffc0204ff8:	39cc0c13          	addi	s8,s8,924 # ffffffffc02ac390 <current>
ffffffffc0204ffc:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);
ffffffffc0205000:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x847c>
    proc->parent=current;
ffffffffc0205004:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0205006:	30071563          	bnez	a4,ffffffffc0205310 <do_fork+0x35a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020500a:	4509                	li	a0,2
ffffffffc020500c:	ddcfe0ef          	jal	ra,ffffffffc02035e8 <alloc_pages>
    if (page != NULL) {
ffffffffc0205010:	2c050163          	beqz	a0,ffffffffc02052d2 <do_fork+0x31c>
    return page - pages + nbase;
ffffffffc0205014:	000a7a97          	auipc	s5,0xa7
ffffffffc0205018:	4b4a8a93          	addi	s5,s5,1204 # ffffffffc02ac4c8 <pages>
ffffffffc020501c:	000ab683          	ld	a3,0(s5)
ffffffffc0205020:	00004b17          	auipc	s6,0x4
ffffffffc0205024:	c70b0b13          	addi	s6,s6,-912 # ffffffffc0208c90 <nbase>
ffffffffc0205028:	000b3783          	ld	a5,0(s6)
ffffffffc020502c:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0205030:	000a7b97          	auipc	s7,0xa7
ffffffffc0205034:	358b8b93          	addi	s7,s7,856 # ffffffffc02ac388 <npage>
    return page - pages + nbase;
ffffffffc0205038:	8699                	srai	a3,a3,0x6
ffffffffc020503a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020503c:	000bb703          	ld	a4,0(s7)
ffffffffc0205040:	57fd                	li	a5,-1
ffffffffc0205042:	83b1                	srli	a5,a5,0xc
ffffffffc0205044:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205046:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205048:	2ae7f863          	bleu	a4,a5,ffffffffc02052f8 <do_fork+0x342>
ffffffffc020504c:	000a7c97          	auipc	s9,0xa7
ffffffffc0205050:	46cc8c93          	addi	s9,s9,1132 # ffffffffc02ac4b8 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0205054:	000c3703          	ld	a4,0(s8)
ffffffffc0205058:	000cb783          	ld	a5,0(s9)
ffffffffc020505c:	02873c03          	ld	s8,40(a4)
ffffffffc0205060:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205062:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc0205064:	020c0863          	beqz	s8,ffffffffc0205094 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc0205068:	1009f993          	andi	s3,s3,256
ffffffffc020506c:	1e098163          	beqz	s3,ffffffffc020524e <do_fork+0x298>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205070:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205074:	018c3783          	ld	a5,24(s8)
ffffffffc0205078:	c02006b7          	lui	a3,0xc0200
ffffffffc020507c:	2705                	addiw	a4,a4,1
ffffffffc020507e:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc0205082:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205086:	2ad7e563          	bltu	a5,a3,ffffffffc0205330 <do_fork+0x37a>
ffffffffc020508a:	000cb703          	ld	a4,0(s9)
ffffffffc020508e:	6814                	ld	a3,16(s0)
ffffffffc0205090:	8f99                	sub	a5,a5,a4
ffffffffc0205092:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205094:	6789                	lui	a5,0x2
ffffffffc0205096:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7688>
ffffffffc020509a:	96be                	add	a3,a3,a5
ffffffffc020509c:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc020509e:	87b6                	mv	a5,a3
ffffffffc02050a0:	12048813          	addi	a6,s1,288
ffffffffc02050a4:	6088                	ld	a0,0(s1)
ffffffffc02050a6:	648c                	ld	a1,8(s1)
ffffffffc02050a8:	6890                	ld	a2,16(s1)
ffffffffc02050aa:	6c98                	ld	a4,24(s1)
ffffffffc02050ac:	e388                	sd	a0,0(a5)
ffffffffc02050ae:	e78c                	sd	a1,8(a5)
ffffffffc02050b0:	eb90                	sd	a2,16(a5)
ffffffffc02050b2:	ef98                	sd	a4,24(a5)
ffffffffc02050b4:	02048493          	addi	s1,s1,32
ffffffffc02050b8:	02078793          	addi	a5,a5,32
ffffffffc02050bc:	ff0494e3          	bne	s1,a6,ffffffffc02050a4 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc02050c0:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02050c4:	12090e63          	beqz	s2,ffffffffc0205200 <do_fork+0x24a>
ffffffffc02050c8:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02050cc:	00000797          	auipc	a5,0x0
ffffffffc02050d0:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204d28 <forkret>
ffffffffc02050d4:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02050d6:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050d8:	100027f3          	csrr	a5,sstatus
ffffffffc02050dc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02050de:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050e0:	12079f63          	bnez	a5,ffffffffc020521e <do_fork+0x268>
    if (++ last_pid >= MAX_PID) {
ffffffffc02050e4:	0009c797          	auipc	a5,0x9c
ffffffffc02050e8:	e6478793          	addi	a5,a5,-412 # ffffffffc02a0f48 <last_pid.1691>
ffffffffc02050ec:	439c                	lw	a5,0(a5)
ffffffffc02050ee:	6709                	lui	a4,0x2
ffffffffc02050f0:	0017851b          	addiw	a0,a5,1
ffffffffc02050f4:	0009c697          	auipc	a3,0x9c
ffffffffc02050f8:	e4a6aa23          	sw	a0,-428(a3) # ffffffffc02a0f48 <last_pid.1691>
ffffffffc02050fc:	14e55263          	ble	a4,a0,ffffffffc0205240 <do_fork+0x28a>
    if (last_pid >= next_safe) {
ffffffffc0205100:	0009c797          	auipc	a5,0x9c
ffffffffc0205104:	e4c78793          	addi	a5,a5,-436 # ffffffffc02a0f4c <next_safe.1690>
ffffffffc0205108:	439c                	lw	a5,0(a5)
ffffffffc020510a:	000a7497          	auipc	s1,0xa7
ffffffffc020510e:	3c648493          	addi	s1,s1,966 # ffffffffc02ac4d0 <proc_list>
ffffffffc0205112:	06f54063          	blt	a0,a5,ffffffffc0205172 <do_fork+0x1bc>
        next_safe = MAX_PID;
ffffffffc0205116:	6789                	lui	a5,0x2
ffffffffc0205118:	0009c717          	auipc	a4,0x9c
ffffffffc020511c:	e2f72a23          	sw	a5,-460(a4) # ffffffffc02a0f4c <next_safe.1690>
ffffffffc0205120:	4581                	li	a1,0
ffffffffc0205122:	87aa                	mv	a5,a0
ffffffffc0205124:	000a7497          	auipc	s1,0xa7
ffffffffc0205128:	3ac48493          	addi	s1,s1,940 # ffffffffc02ac4d0 <proc_list>
    repeat:
ffffffffc020512c:	6889                	lui	a7,0x2
ffffffffc020512e:	882e                	mv	a6,a1
ffffffffc0205130:	6609                	lui	a2,0x2
        le = list;
ffffffffc0205132:	000a7697          	auipc	a3,0xa7
ffffffffc0205136:	39e68693          	addi	a3,a3,926 # ffffffffc02ac4d0 <proc_list>
ffffffffc020513a:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc020513c:	00968f63          	beq	a3,s1,ffffffffc020515a <do_fork+0x1a4>
            if (proc->pid == last_pid) {
ffffffffc0205140:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0205144:	0ae78963          	beq	a5,a4,ffffffffc02051f6 <do_fork+0x240>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205148:	fee7d9e3          	ble	a4,a5,ffffffffc020513a <do_fork+0x184>
ffffffffc020514c:	fec757e3          	ble	a2,a4,ffffffffc020513a <do_fork+0x184>
ffffffffc0205150:	6694                	ld	a3,8(a3)
ffffffffc0205152:	863a                	mv	a2,a4
ffffffffc0205154:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0205156:	fe9695e3          	bne	a3,s1,ffffffffc0205140 <do_fork+0x18a>
ffffffffc020515a:	c591                	beqz	a1,ffffffffc0205166 <do_fork+0x1b0>
ffffffffc020515c:	0009c717          	auipc	a4,0x9c
ffffffffc0205160:	def72623          	sw	a5,-532(a4) # ffffffffc02a0f48 <last_pid.1691>
ffffffffc0205164:	853e                	mv	a0,a5
ffffffffc0205166:	00080663          	beqz	a6,ffffffffc0205172 <do_fork+0x1bc>
ffffffffc020516a:	0009c797          	auipc	a5,0x9c
ffffffffc020516e:	dec7a123          	sw	a2,-542(a5) # ffffffffc02a0f4c <next_safe.1690>
        proc->pid = get_pid(); //获取当前进程 PID
ffffffffc0205172:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205174:	45a9                	li	a1,10
ffffffffc0205176:	2501                	sext.w	a0,a0
ffffffffc0205178:	438010ef          	jal	ra,ffffffffc02065b0 <hash32>
ffffffffc020517c:	1502                	slli	a0,a0,0x20
ffffffffc020517e:	000a3797          	auipc	a5,0xa3
ffffffffc0205182:	1d278793          	addi	a5,a5,466 # ffffffffc02a8350 <hash_list>
ffffffffc0205186:	8171                	srli	a0,a0,0x1c
ffffffffc0205188:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020518a:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020518c:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020518e:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc0205192:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205194:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0205196:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205198:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc020519a:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc020519e:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc02051a0:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc02051a2:	e21c                	sd	a5,0(a2)
ffffffffc02051a4:	000a7597          	auipc	a1,0xa7
ffffffffc02051a8:	32f5ba23          	sd	a5,820(a1) # ffffffffc02ac4d8 <proc_list+0x8>
    elm->next = next;
ffffffffc02051ac:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc02051ae:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc02051b0:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051b4:	10e43023          	sd	a4,256(s0)
ffffffffc02051b8:	c311                	beqz	a4,ffffffffc02051bc <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc02051ba:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc02051bc:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc02051c0:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc02051c2:	2785                	addiw	a5,a5,1
ffffffffc02051c4:	000a7717          	auipc	a4,0xa7
ffffffffc02051c8:	1ef72223          	sw	a5,484(a4) # ffffffffc02ac3a8 <nr_process>
    if (flag) {
ffffffffc02051cc:	10091863          	bnez	s2,ffffffffc02052dc <do_fork+0x326>
    wakeup_proc(proc);
ffffffffc02051d0:	8522                	mv	a0,s0
ffffffffc02051d2:	52d000ef          	jal	ra,ffffffffc0205efe <wakeup_proc>
    ret = proc->pid;
ffffffffc02051d6:	4048                	lw	a0,4(s0)
}
ffffffffc02051d8:	70a6                	ld	ra,104(sp)
ffffffffc02051da:	7406                	ld	s0,96(sp)
ffffffffc02051dc:	64e6                	ld	s1,88(sp)
ffffffffc02051de:	6946                	ld	s2,80(sp)
ffffffffc02051e0:	69a6                	ld	s3,72(sp)
ffffffffc02051e2:	6a06                	ld	s4,64(sp)
ffffffffc02051e4:	7ae2                	ld	s5,56(sp)
ffffffffc02051e6:	7b42                	ld	s6,48(sp)
ffffffffc02051e8:	7ba2                	ld	s7,40(sp)
ffffffffc02051ea:	7c02                	ld	s8,32(sp)
ffffffffc02051ec:	6ce2                	ld	s9,24(sp)
ffffffffc02051ee:	6d42                	ld	s10,16(sp)
ffffffffc02051f0:	6da2                	ld	s11,8(sp)
ffffffffc02051f2:	6165                	addi	sp,sp,112
ffffffffc02051f4:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc02051f6:	2785                	addiw	a5,a5,1
ffffffffc02051f8:	0ec7d563          	ble	a2,a5,ffffffffc02052e2 <do_fork+0x32c>
ffffffffc02051fc:	4585                	li	a1,1
ffffffffc02051fe:	bf35                	j	ffffffffc020513a <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205200:	8936                	mv	s2,a3
ffffffffc0205202:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205206:	00000797          	auipc	a5,0x0
ffffffffc020520a:	b2278793          	addi	a5,a5,-1246 # ffffffffc0204d28 <forkret>
ffffffffc020520e:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205210:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205212:	100027f3          	csrr	a5,sstatus
ffffffffc0205216:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205218:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020521a:	ec0785e3          	beqz	a5,ffffffffc02050e4 <do_fork+0x12e>
        intr_disable();
ffffffffc020521e:	c3efb0ef          	jal	ra,ffffffffc020065c <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205222:	0009c797          	auipc	a5,0x9c
ffffffffc0205226:	d2678793          	addi	a5,a5,-730 # ffffffffc02a0f48 <last_pid.1691>
ffffffffc020522a:	439c                	lw	a5,0(a5)
ffffffffc020522c:	6709                	lui	a4,0x2
        return 1;
ffffffffc020522e:	4905                	li	s2,1
ffffffffc0205230:	0017851b          	addiw	a0,a5,1
ffffffffc0205234:	0009c697          	auipc	a3,0x9c
ffffffffc0205238:	d0a6aa23          	sw	a0,-748(a3) # ffffffffc02a0f48 <last_pid.1691>
ffffffffc020523c:	ece542e3          	blt	a0,a4,ffffffffc0205100 <do_fork+0x14a>
        last_pid = 1;
ffffffffc0205240:	4785                	li	a5,1
ffffffffc0205242:	0009c717          	auipc	a4,0x9c
ffffffffc0205246:	d0f72323          	sw	a5,-762(a4) # ffffffffc02a0f48 <last_pid.1691>
ffffffffc020524a:	4505                	li	a0,1
ffffffffc020524c:	b5e9                	j	ffffffffc0205116 <do_fork+0x160>
    if ((mm = mm_create()) == NULL) {
ffffffffc020524e:	c2dfb0ef          	jal	ra,ffffffffc0200e7a <mm_create>
ffffffffc0205252:	8d2a                	mv	s10,a0
ffffffffc0205254:	c539                	beqz	a0,ffffffffc02052a2 <do_fork+0x2ec>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205256:	be3ff0ef          	jal	ra,ffffffffc0204e38 <setup_pgdir>
ffffffffc020525a:	e949                	bnez	a0,ffffffffc02052ec <do_fork+0x336>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc020525c:	038c0d93          	addi	s11,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205260:	4785                	li	a5,1
ffffffffc0205262:	40fdb7af          	amoor.d	a5,a5,(s11)
ffffffffc0205266:	8b85                	andi	a5,a5,1
ffffffffc0205268:	4985                	li	s3,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc020526a:	c799                	beqz	a5,ffffffffc0205278 <do_fork+0x2c2>
        schedule();
ffffffffc020526c:	50f000ef          	jal	ra,ffffffffc0205f7a <schedule>
ffffffffc0205270:	413db7af          	amoor.d	a5,s3,(s11)
ffffffffc0205274:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc0205276:	fbfd                	bnez	a5,ffffffffc020526c <do_fork+0x2b6>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205278:	85e2                	mv	a1,s8
ffffffffc020527a:	856a                	mv	a0,s10
ffffffffc020527c:	e89fb0ef          	jal	ra,ffffffffc0201104 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0205280:	57f9                	li	a5,-2
ffffffffc0205282:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc0205286:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205288:	c3e9                	beqz	a5,ffffffffc020534a <do_fork+0x394>
    if (ret != 0) {
ffffffffc020528a:	8c6a                	mv	s8,s10
ffffffffc020528c:	de0502e3          	beqz	a0,ffffffffc0205070 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc0205290:	856a                	mv	a0,s10
ffffffffc0205292:	f0ffb0ef          	jal	ra,ffffffffc02011a0 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205296:	856a                	mv	a0,s10
ffffffffc0205298:	b23ff0ef          	jal	ra,ffffffffc0204dba <put_pgdir>
    mm_destroy(mm);
ffffffffc020529c:	856a                	mv	a0,s10
ffffffffc020529e:	d63fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02052a2:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02052a4:	c02007b7          	lui	a5,0xc0200
ffffffffc02052a8:	0cf6e963          	bltu	a3,a5,ffffffffc020537a <do_fork+0x3c4>
ffffffffc02052ac:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc02052b0:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc02052b4:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02052b8:	83b1                	srli	a5,a5,0xc
ffffffffc02052ba:	0ae7f463          	bleu	a4,a5,ffffffffc0205362 <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc02052be:	000b3703          	ld	a4,0(s6)
ffffffffc02052c2:	000ab503          	ld	a0,0(s5)
ffffffffc02052c6:	4589                	li	a1,2
ffffffffc02052c8:	8f99                	sub	a5,a5,a4
ffffffffc02052ca:	079a                	slli	a5,a5,0x6
ffffffffc02052cc:	953e                	add	a0,a0,a5
ffffffffc02052ce:	ba2fe0ef          	jal	ra,ffffffffc0203670 <free_pages>
    kfree(proc);
ffffffffc02052d2:	8522                	mv	a0,s0
ffffffffc02052d4:	d59fc0ef          	jal	ra,ffffffffc020202c <kfree>
    ret = -E_NO_MEM;
ffffffffc02052d8:	5571                	li	a0,-4
    return ret;
ffffffffc02052da:	bdfd                	j	ffffffffc02051d8 <do_fork+0x222>
        intr_enable();
ffffffffc02052dc:	b7afb0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc02052e0:	bdc5                	j	ffffffffc02051d0 <do_fork+0x21a>
                    if (last_pid >= MAX_PID) {
ffffffffc02052e2:	0117c363          	blt	a5,a7,ffffffffc02052e8 <do_fork+0x332>
                        last_pid = 1;
ffffffffc02052e6:	4785                	li	a5,1
                    goto repeat;
ffffffffc02052e8:	4585                	li	a1,1
ffffffffc02052ea:	b591                	j	ffffffffc020512e <do_fork+0x178>
    mm_destroy(mm);
ffffffffc02052ec:	856a                	mv	a0,s10
ffffffffc02052ee:	d13fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
    if(r !=0){
ffffffffc02052f2:	bf45                	j	ffffffffc02052a2 <do_fork+0x2ec>
    int ret = -E_NO_FREE_PROC;
ffffffffc02052f4:	556d                	li	a0,-5
ffffffffc02052f6:	b5cd                	j	ffffffffc02051d8 <do_fork+0x222>
    return KADDR(page2pa(page));
ffffffffc02052f8:	00002617          	auipc	a2,0x2
ffffffffc02052fc:	ff860613          	addi	a2,a2,-8 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc0205300:	06900593          	li	a1,105
ffffffffc0205304:	00002517          	auipc	a0,0x2
ffffffffc0205308:	fdc50513          	addi	a0,a0,-36 # ffffffffc02072e0 <commands+0xba8>
ffffffffc020530c:	f0bfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(current->wait_state == 0);
ffffffffc0205310:	00003697          	auipc	a3,0x3
ffffffffc0205314:	22868693          	addi	a3,a3,552 # ffffffffc0208538 <default_pmm_manager+0x828>
ffffffffc0205318:	00002617          	auipc	a2,0x2
ffffffffc020531c:	8a060613          	addi	a2,a2,-1888 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205320:	1ab00593          	li	a1,427
ffffffffc0205324:	00003517          	auipc	a0,0x3
ffffffffc0205328:	4a450513          	addi	a0,a0,1188 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc020532c:	eebfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205330:	86be                	mv	a3,a5
ffffffffc0205332:	00002617          	auipc	a2,0x2
ffffffffc0205336:	23660613          	addi	a2,a2,566 # ffffffffc0207568 <commands+0xe30>
ffffffffc020533a:	15c00593          	li	a1,348
ffffffffc020533e:	00003517          	auipc	a0,0x3
ffffffffc0205342:	48a50513          	addi	a0,a0,1162 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc0205346:	ed1fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("Unlock failed.\n");
ffffffffc020534a:	00003617          	auipc	a2,0x3
ffffffffc020534e:	20e60613          	addi	a2,a2,526 # ffffffffc0208558 <default_pmm_manager+0x848>
ffffffffc0205352:	03100593          	li	a1,49
ffffffffc0205356:	00003517          	auipc	a0,0x3
ffffffffc020535a:	21250513          	addi	a0,a0,530 # ffffffffc0208568 <default_pmm_manager+0x858>
ffffffffc020535e:	eb9fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205362:	00002617          	auipc	a2,0x2
ffffffffc0205366:	f5e60613          	addi	a2,a2,-162 # ffffffffc02072c0 <commands+0xb88>
ffffffffc020536a:	06200593          	li	a1,98
ffffffffc020536e:	00002517          	auipc	a0,0x2
ffffffffc0205372:	f7250513          	addi	a0,a0,-142 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0205376:	ea1fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020537a:	00002617          	auipc	a2,0x2
ffffffffc020537e:	1ee60613          	addi	a2,a2,494 # ffffffffc0207568 <commands+0xe30>
ffffffffc0205382:	06e00593          	li	a1,110
ffffffffc0205386:	00002517          	auipc	a0,0x2
ffffffffc020538a:	f5a50513          	addi	a0,a0,-166 # ffffffffc02072e0 <commands+0xba8>
ffffffffc020538e:	e89fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205392 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205392:	7129                	addi	sp,sp,-320
ffffffffc0205394:	fa22                	sd	s0,304(sp)
ffffffffc0205396:	f626                	sd	s1,296(sp)
ffffffffc0205398:	f24a                	sd	s2,288(sp)
ffffffffc020539a:	84ae                	mv	s1,a1
ffffffffc020539c:	892a                	mv	s2,a0
ffffffffc020539e:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053a0:	4581                	li	a1,0
ffffffffc02053a2:	12000613          	li	a2,288
ffffffffc02053a6:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053a8:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053aa:	5e5000ef          	jal	ra,ffffffffc020618e <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02053ae:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02053b0:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02053b2:	100027f3          	csrr	a5,sstatus
ffffffffc02053b6:	edd7f793          	andi	a5,a5,-291
ffffffffc02053ba:	1207e793          	ori	a5,a5,288
ffffffffc02053be:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053c0:	860a                	mv	a2,sp
ffffffffc02053c2:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053c6:	00000797          	auipc	a5,0x0
ffffffffc02053ca:	8a878793          	addi	a5,a5,-1880 # ffffffffc0204c6e <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053ce:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053d0:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053d2:	be5ff0ef          	jal	ra,ffffffffc0204fb6 <do_fork>
}
ffffffffc02053d6:	70f2                	ld	ra,312(sp)
ffffffffc02053d8:	7452                	ld	s0,304(sp)
ffffffffc02053da:	74b2                	ld	s1,296(sp)
ffffffffc02053dc:	7912                	ld	s2,288(sp)
ffffffffc02053de:	6131                	addi	sp,sp,320
ffffffffc02053e0:	8082                	ret

ffffffffc02053e2 <do_exit>:
do_exit(int error_code) {
ffffffffc02053e2:	7179                	addi	sp,sp,-48
ffffffffc02053e4:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc02053e6:	000a7717          	auipc	a4,0xa7
ffffffffc02053ea:	fb270713          	addi	a4,a4,-78 # ffffffffc02ac398 <idleproc>
ffffffffc02053ee:	000a7917          	auipc	s2,0xa7
ffffffffc02053f2:	fa290913          	addi	s2,s2,-94 # ffffffffc02ac390 <current>
ffffffffc02053f6:	00093783          	ld	a5,0(s2)
ffffffffc02053fa:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc02053fc:	f406                	sd	ra,40(sp)
ffffffffc02053fe:	f022                	sd	s0,32(sp)
ffffffffc0205400:	ec26                	sd	s1,24(sp)
ffffffffc0205402:	e44e                	sd	s3,8(sp)
ffffffffc0205404:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205406:	0ce78c63          	beq	a5,a4,ffffffffc02054de <do_exit+0xfc>
    if (current == initproc) {
ffffffffc020540a:	000a7417          	auipc	s0,0xa7
ffffffffc020540e:	f9640413          	addi	s0,s0,-106 # ffffffffc02ac3a0 <initproc>
ffffffffc0205412:	6018                	ld	a4,0(s0)
ffffffffc0205414:	0ee78b63          	beq	a5,a4,ffffffffc020550a <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc0205418:	7784                	ld	s1,40(a5)
ffffffffc020541a:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc020541c:	c48d                	beqz	s1,ffffffffc0205446 <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc020541e:	000a7797          	auipc	a5,0xa7
ffffffffc0205422:	0a278793          	addi	a5,a5,162 # ffffffffc02ac4c0 <boot_cr3>
ffffffffc0205426:	639c                	ld	a5,0(a5)
ffffffffc0205428:	577d                	li	a4,-1
ffffffffc020542a:	177e                	slli	a4,a4,0x3f
ffffffffc020542c:	83b1                	srli	a5,a5,0xc
ffffffffc020542e:	8fd9                	or	a5,a5,a4
ffffffffc0205430:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205434:	589c                	lw	a5,48(s1)
ffffffffc0205436:	fff7871b          	addiw	a4,a5,-1
ffffffffc020543a:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc020543c:	cf4d                	beqz	a4,ffffffffc02054f6 <do_exit+0x114>
        current->mm = NULL;
ffffffffc020543e:	00093783          	ld	a5,0(s2)
ffffffffc0205442:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205446:	00093783          	ld	a5,0(s2)
ffffffffc020544a:	470d                	li	a4,3
ffffffffc020544c:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc020544e:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205452:	100027f3          	csrr	a5,sstatus
ffffffffc0205456:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205458:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020545a:	e7e1                	bnez	a5,ffffffffc0205522 <do_exit+0x140>
        proc = current->parent;
ffffffffc020545c:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205460:	800007b7          	lui	a5,0x80000
ffffffffc0205464:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0205466:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205468:	0ec52703          	lw	a4,236(a0)
ffffffffc020546c:	0af70f63          	beq	a4,a5,ffffffffc020552a <do_exit+0x148>
ffffffffc0205470:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205474:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205478:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020547a:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc020547c:	7afc                	ld	a5,240(a3)
ffffffffc020547e:	cb95                	beqz	a5,ffffffffc02054b2 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc0205480:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5690>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205484:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc0205486:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205488:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020548a:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020548e:	10e7b023          	sd	a4,256(a5)
ffffffffc0205492:	c311                	beqz	a4,ffffffffc0205496 <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc0205494:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205496:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205498:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc020549a:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020549c:	fe9710e3          	bne	a4,s1,ffffffffc020547c <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054a0:	0ec52783          	lw	a5,236(a0)
ffffffffc02054a4:	fd379ce3          	bne	a5,s3,ffffffffc020547c <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02054a8:	257000ef          	jal	ra,ffffffffc0205efe <wakeup_proc>
ffffffffc02054ac:	00093683          	ld	a3,0(s2)
ffffffffc02054b0:	b7f1                	j	ffffffffc020547c <do_exit+0x9a>
    if (flag) {
ffffffffc02054b2:	020a1363          	bnez	s4,ffffffffc02054d8 <do_exit+0xf6>
    schedule();
ffffffffc02054b6:	2c5000ef          	jal	ra,ffffffffc0205f7a <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02054ba:	00093783          	ld	a5,0(s2)
ffffffffc02054be:	00003617          	auipc	a2,0x3
ffffffffc02054c2:	05a60613          	addi	a2,a2,90 # ffffffffc0208518 <default_pmm_manager+0x808>
ffffffffc02054c6:	20300593          	li	a1,515
ffffffffc02054ca:	43d4                	lw	a3,4(a5)
ffffffffc02054cc:	00003517          	auipc	a0,0x3
ffffffffc02054d0:	2fc50513          	addi	a0,a0,764 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc02054d4:	d43fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        intr_enable();
ffffffffc02054d8:	97efb0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc02054dc:	bfe9                	j	ffffffffc02054b6 <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc02054de:	00003617          	auipc	a2,0x3
ffffffffc02054e2:	01a60613          	addi	a2,a2,26 # ffffffffc02084f8 <default_pmm_manager+0x7e8>
ffffffffc02054e6:	1d700593          	li	a1,471
ffffffffc02054ea:	00003517          	auipc	a0,0x3
ffffffffc02054ee:	2de50513          	addi	a0,a0,734 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc02054f2:	d25fa0ef          	jal	ra,ffffffffc0200216 <__panic>
            exit_mmap(mm);
ffffffffc02054f6:	8526                	mv	a0,s1
ffffffffc02054f8:	ca9fb0ef          	jal	ra,ffffffffc02011a0 <exit_mmap>
            put_pgdir(mm);
ffffffffc02054fc:	8526                	mv	a0,s1
ffffffffc02054fe:	8bdff0ef          	jal	ra,ffffffffc0204dba <put_pgdir>
            mm_destroy(mm);
ffffffffc0205502:	8526                	mv	a0,s1
ffffffffc0205504:	afdfb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
ffffffffc0205508:	bf1d                	j	ffffffffc020543e <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc020550a:	00003617          	auipc	a2,0x3
ffffffffc020550e:	ffe60613          	addi	a2,a2,-2 # ffffffffc0208508 <default_pmm_manager+0x7f8>
ffffffffc0205512:	1da00593          	li	a1,474
ffffffffc0205516:	00003517          	auipc	a0,0x3
ffffffffc020551a:	2b250513          	addi	a0,a0,690 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc020551e:	cf9fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        intr_disable();
ffffffffc0205522:	93afb0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0205526:	4a05                	li	s4,1
ffffffffc0205528:	bf15                	j	ffffffffc020545c <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc020552a:	1d5000ef          	jal	ra,ffffffffc0205efe <wakeup_proc>
ffffffffc020552e:	b789                	j	ffffffffc0205470 <do_exit+0x8e>

ffffffffc0205530 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc0205530:	7139                	addi	sp,sp,-64
ffffffffc0205532:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205534:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc0205538:	f426                	sd	s1,40(sp)
ffffffffc020553a:	f04a                	sd	s2,32(sp)
ffffffffc020553c:	ec4e                	sd	s3,24(sp)
ffffffffc020553e:	e456                	sd	s5,8(sp)
ffffffffc0205540:	e05a                	sd	s6,0(sp)
ffffffffc0205542:	fc06                	sd	ra,56(sp)
ffffffffc0205544:	f822                	sd	s0,48(sp)
ffffffffc0205546:	89aa                	mv	s3,a0
ffffffffc0205548:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc020554a:	000a7917          	auipc	s2,0xa7
ffffffffc020554e:	e4690913          	addi	s2,s2,-442 # ffffffffc02ac390 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205552:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc0205554:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc0205556:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc0205558:	02098f63          	beqz	s3,ffffffffc0205596 <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc020555c:	854e                	mv	a0,s3
ffffffffc020555e:	9fdff0ef          	jal	ra,ffffffffc0204f5a <find_proc>
ffffffffc0205562:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc0205564:	12050063          	beqz	a0,ffffffffc0205684 <do_wait.part.1+0x154>
ffffffffc0205568:	00093703          	ld	a4,0(s2)
ffffffffc020556c:	711c                	ld	a5,32(a0)
ffffffffc020556e:	10e79b63          	bne	a5,a4,ffffffffc0205684 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205572:	411c                	lw	a5,0(a0)
ffffffffc0205574:	02978c63          	beq	a5,s1,ffffffffc02055ac <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc0205578:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc020557c:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205580:	1fb000ef          	jal	ra,ffffffffc0205f7a <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205584:	00093783          	ld	a5,0(s2)
ffffffffc0205588:	0b07a783          	lw	a5,176(a5)
ffffffffc020558c:	8b85                	andi	a5,a5,1
ffffffffc020558e:	d7e9                	beqz	a5,ffffffffc0205558 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc0205590:	555d                	li	a0,-9
ffffffffc0205592:	e51ff0ef          	jal	ra,ffffffffc02053e2 <do_exit>
        proc = current->cptr;
ffffffffc0205596:	00093703          	ld	a4,0(s2)
ffffffffc020559a:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020559c:	e409                	bnez	s0,ffffffffc02055a6 <do_wait.part.1+0x76>
ffffffffc020559e:	a0dd                	j	ffffffffc0205684 <do_wait.part.1+0x154>
ffffffffc02055a0:	10043403          	ld	s0,256(s0)
ffffffffc02055a4:	d871                	beqz	s0,ffffffffc0205578 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055a6:	401c                	lw	a5,0(s0)
ffffffffc02055a8:	fe979ce3          	bne	a5,s1,ffffffffc02055a0 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc02055ac:	000a7797          	auipc	a5,0xa7
ffffffffc02055b0:	dec78793          	addi	a5,a5,-532 # ffffffffc02ac398 <idleproc>
ffffffffc02055b4:	639c                	ld	a5,0(a5)
ffffffffc02055b6:	0c878d63          	beq	a5,s0,ffffffffc0205690 <do_wait.part.1+0x160>
ffffffffc02055ba:	000a7797          	auipc	a5,0xa7
ffffffffc02055be:	de678793          	addi	a5,a5,-538 # ffffffffc02ac3a0 <initproc>
ffffffffc02055c2:	639c                	ld	a5,0(a5)
ffffffffc02055c4:	0cf40663          	beq	s0,a5,ffffffffc0205690 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc02055c8:	000b0663          	beqz	s6,ffffffffc02055d4 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc02055cc:	0e842783          	lw	a5,232(s0)
ffffffffc02055d0:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055d4:	100027f3          	csrr	a5,sstatus
ffffffffc02055d8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055da:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055dc:	e7d5                	bnez	a5,ffffffffc0205688 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc02055de:	6c70                	ld	a2,216(s0)
ffffffffc02055e0:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02055e2:	10043703          	ld	a4,256(s0)
ffffffffc02055e6:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02055e8:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055ea:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02055ec:	6470                	ld	a2,200(s0)
ffffffffc02055ee:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02055f0:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055f2:	e290                	sd	a2,0(a3)
ffffffffc02055f4:	c319                	beqz	a4,ffffffffc02055fa <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc02055f6:	ff7c                	sd	a5,248(a4)
ffffffffc02055f8:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc02055fa:	c3d1                	beqz	a5,ffffffffc020567e <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc02055fc:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205600:	000a7797          	auipc	a5,0xa7
ffffffffc0205604:	da878793          	addi	a5,a5,-600 # ffffffffc02ac3a8 <nr_process>
ffffffffc0205608:	439c                	lw	a5,0(a5)
ffffffffc020560a:	37fd                	addiw	a5,a5,-1
ffffffffc020560c:	000a7717          	auipc	a4,0xa7
ffffffffc0205610:	d8f72e23          	sw	a5,-612(a4) # ffffffffc02ac3a8 <nr_process>
    if (flag) {
ffffffffc0205614:	e1b5                	bnez	a1,ffffffffc0205678 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205616:	6814                	ld	a3,16(s0)
ffffffffc0205618:	c02007b7          	lui	a5,0xc0200
ffffffffc020561c:	0af6e263          	bltu	a3,a5,ffffffffc02056c0 <do_wait.part.1+0x190>
ffffffffc0205620:	000a7797          	auipc	a5,0xa7
ffffffffc0205624:	e9878793          	addi	a5,a5,-360 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc0205628:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020562a:	000a7797          	auipc	a5,0xa7
ffffffffc020562e:	d5e78793          	addi	a5,a5,-674 # ffffffffc02ac388 <npage>
ffffffffc0205632:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205634:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205636:	82b1                	srli	a3,a3,0xc
ffffffffc0205638:	06f6f863          	bleu	a5,a3,ffffffffc02056a8 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc020563c:	00003797          	auipc	a5,0x3
ffffffffc0205640:	65478793          	addi	a5,a5,1620 # ffffffffc0208c90 <nbase>
ffffffffc0205644:	639c                	ld	a5,0(a5)
ffffffffc0205646:	000a7717          	auipc	a4,0xa7
ffffffffc020564a:	e8270713          	addi	a4,a4,-382 # ffffffffc02ac4c8 <pages>
ffffffffc020564e:	6308                	ld	a0,0(a4)
ffffffffc0205650:	8e9d                	sub	a3,a3,a5
ffffffffc0205652:	069a                	slli	a3,a3,0x6
ffffffffc0205654:	9536                	add	a0,a0,a3
ffffffffc0205656:	4589                	li	a1,2
ffffffffc0205658:	818fe0ef          	jal	ra,ffffffffc0203670 <free_pages>
    kfree(proc);
ffffffffc020565c:	8522                	mv	a0,s0
ffffffffc020565e:	9cffc0ef          	jal	ra,ffffffffc020202c <kfree>
    return 0;
ffffffffc0205662:	4501                	li	a0,0
}
ffffffffc0205664:	70e2                	ld	ra,56(sp)
ffffffffc0205666:	7442                	ld	s0,48(sp)
ffffffffc0205668:	74a2                	ld	s1,40(sp)
ffffffffc020566a:	7902                	ld	s2,32(sp)
ffffffffc020566c:	69e2                	ld	s3,24(sp)
ffffffffc020566e:	6a42                	ld	s4,16(sp)
ffffffffc0205670:	6aa2                	ld	s5,8(sp)
ffffffffc0205672:	6b02                	ld	s6,0(sp)
ffffffffc0205674:	6121                	addi	sp,sp,64
ffffffffc0205676:	8082                	ret
        intr_enable();
ffffffffc0205678:	fdffa0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc020567c:	bf69                	j	ffffffffc0205616 <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc020567e:	701c                	ld	a5,32(s0)
ffffffffc0205680:	fbf8                	sd	a4,240(a5)
ffffffffc0205682:	bfbd                	j	ffffffffc0205600 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc0205684:	5579                	li	a0,-2
ffffffffc0205686:	bff9                	j	ffffffffc0205664 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc0205688:	fd5fa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc020568c:	4585                	li	a1,1
ffffffffc020568e:	bf81                	j	ffffffffc02055de <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc0205690:	00003617          	auipc	a2,0x3
ffffffffc0205694:	ef060613          	addi	a2,a2,-272 # ffffffffc0208580 <default_pmm_manager+0x870>
ffffffffc0205698:	2fb00593          	li	a1,763
ffffffffc020569c:	00003517          	auipc	a0,0x3
ffffffffc02056a0:	12c50513          	addi	a0,a0,300 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc02056a4:	b73fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02056a8:	00002617          	auipc	a2,0x2
ffffffffc02056ac:	c1860613          	addi	a2,a2,-1000 # ffffffffc02072c0 <commands+0xb88>
ffffffffc02056b0:	06200593          	li	a1,98
ffffffffc02056b4:	00002517          	auipc	a0,0x2
ffffffffc02056b8:	c2c50513          	addi	a0,a0,-980 # ffffffffc02072e0 <commands+0xba8>
ffffffffc02056bc:	b5bfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02056c0:	00002617          	auipc	a2,0x2
ffffffffc02056c4:	ea860613          	addi	a2,a2,-344 # ffffffffc0207568 <commands+0xe30>
ffffffffc02056c8:	06e00593          	li	a1,110
ffffffffc02056cc:	00002517          	auipc	a0,0x2
ffffffffc02056d0:	c1450513          	addi	a0,a0,-1004 # ffffffffc02072e0 <commands+0xba8>
ffffffffc02056d4:	b43fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02056d8 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02056d8:	1141                	addi	sp,sp,-16
ffffffffc02056da:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02056dc:	fdbfd0ef          	jal	ra,ffffffffc02036b6 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02056e0:	88dfc0ef          	jal	ra,ffffffffc0201f6c <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02056e4:	4601                	li	a2,0
ffffffffc02056e6:	4581                	li	a1,0
ffffffffc02056e8:	fffff517          	auipc	a0,0xfffff
ffffffffc02056ec:	65050513          	addi	a0,a0,1616 # ffffffffc0204d38 <user_main>
ffffffffc02056f0:	ca3ff0ef          	jal	ra,ffffffffc0205392 <kernel_thread>
    if (pid <= 0) {
ffffffffc02056f4:	00a04563          	bgtz	a0,ffffffffc02056fe <init_main+0x26>
ffffffffc02056f8:	a841                	j	ffffffffc0205788 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02056fa:	081000ef          	jal	ra,ffffffffc0205f7a <schedule>
    if (code_store != NULL) {
ffffffffc02056fe:	4581                	li	a1,0
ffffffffc0205700:	4501                	li	a0,0
ffffffffc0205702:	e2fff0ef          	jal	ra,ffffffffc0205530 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205706:	d975                	beqz	a0,ffffffffc02056fa <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205708:	00003517          	auipc	a0,0x3
ffffffffc020570c:	eb850513          	addi	a0,a0,-328 # ffffffffc02085c0 <default_pmm_manager+0x8b0>
ffffffffc0205710:	9c1fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205714:	000a7797          	auipc	a5,0xa7
ffffffffc0205718:	c8c78793          	addi	a5,a5,-884 # ffffffffc02ac3a0 <initproc>
ffffffffc020571c:	639c                	ld	a5,0(a5)
ffffffffc020571e:	7bf8                	ld	a4,240(a5)
ffffffffc0205720:	e721                	bnez	a4,ffffffffc0205768 <init_main+0x90>
ffffffffc0205722:	7ff8                	ld	a4,248(a5)
ffffffffc0205724:	e331                	bnez	a4,ffffffffc0205768 <init_main+0x90>
ffffffffc0205726:	1007b703          	ld	a4,256(a5)
ffffffffc020572a:	ef1d                	bnez	a4,ffffffffc0205768 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc020572c:	000a7717          	auipc	a4,0xa7
ffffffffc0205730:	c7c70713          	addi	a4,a4,-900 # ffffffffc02ac3a8 <nr_process>
ffffffffc0205734:	4314                	lw	a3,0(a4)
ffffffffc0205736:	4709                	li	a4,2
ffffffffc0205738:	0ae69463          	bne	a3,a4,ffffffffc02057e0 <init_main+0x108>
    return listelm->next;
ffffffffc020573c:	000a7697          	auipc	a3,0xa7
ffffffffc0205740:	d9468693          	addi	a3,a3,-620 # ffffffffc02ac4d0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205744:	6698                	ld	a4,8(a3)
ffffffffc0205746:	0c878793          	addi	a5,a5,200
ffffffffc020574a:	06f71b63          	bne	a4,a5,ffffffffc02057c0 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020574e:	629c                	ld	a5,0(a3)
ffffffffc0205750:	04f71863          	bne	a4,a5,ffffffffc02057a0 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc0205754:	00003517          	auipc	a0,0x3
ffffffffc0205758:	f5450513          	addi	a0,a0,-172 # ffffffffc02086a8 <default_pmm_manager+0x998>
ffffffffc020575c:	975fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc0205760:	60a2                	ld	ra,8(sp)
ffffffffc0205762:	4501                	li	a0,0
ffffffffc0205764:	0141                	addi	sp,sp,16
ffffffffc0205766:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205768:	00003697          	auipc	a3,0x3
ffffffffc020576c:	e8068693          	addi	a3,a3,-384 # ffffffffc02085e8 <default_pmm_manager+0x8d8>
ffffffffc0205770:	00001617          	auipc	a2,0x1
ffffffffc0205774:	44860613          	addi	a2,a2,1096 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205778:	36000593          	li	a1,864
ffffffffc020577c:	00003517          	auipc	a0,0x3
ffffffffc0205780:	04c50513          	addi	a0,a0,76 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc0205784:	a93fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("create user_main failed.\n");
ffffffffc0205788:	00003617          	auipc	a2,0x3
ffffffffc020578c:	e1860613          	addi	a2,a2,-488 # ffffffffc02085a0 <default_pmm_manager+0x890>
ffffffffc0205790:	35800593          	li	a1,856
ffffffffc0205794:	00003517          	auipc	a0,0x3
ffffffffc0205798:	03450513          	addi	a0,a0,52 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc020579c:	a7bfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02057a0:	00003697          	auipc	a3,0x3
ffffffffc02057a4:	ed868693          	addi	a3,a3,-296 # ffffffffc0208678 <default_pmm_manager+0x968>
ffffffffc02057a8:	00001617          	auipc	a2,0x1
ffffffffc02057ac:	41060613          	addi	a2,a2,1040 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02057b0:	36300593          	li	a1,867
ffffffffc02057b4:	00003517          	auipc	a0,0x3
ffffffffc02057b8:	01450513          	addi	a0,a0,20 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc02057bc:	a5bfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057c0:	00003697          	auipc	a3,0x3
ffffffffc02057c4:	e8868693          	addi	a3,a3,-376 # ffffffffc0208648 <default_pmm_manager+0x938>
ffffffffc02057c8:	00001617          	auipc	a2,0x1
ffffffffc02057cc:	3f060613          	addi	a2,a2,1008 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02057d0:	36200593          	li	a1,866
ffffffffc02057d4:	00003517          	auipc	a0,0x3
ffffffffc02057d8:	ff450513          	addi	a0,a0,-12 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc02057dc:	a3bfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_process == 2);
ffffffffc02057e0:	00003697          	auipc	a3,0x3
ffffffffc02057e4:	e5868693          	addi	a3,a3,-424 # ffffffffc0208638 <default_pmm_manager+0x928>
ffffffffc02057e8:	00001617          	auipc	a2,0x1
ffffffffc02057ec:	3d060613          	addi	a2,a2,976 # ffffffffc0206bb8 <commands+0x480>
ffffffffc02057f0:	36100593          	li	a1,865
ffffffffc02057f4:	00003517          	auipc	a0,0x3
ffffffffc02057f8:	fd450513          	addi	a0,a0,-44 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc02057fc:	a1bfa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205800 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205800:	7135                	addi	sp,sp,-160
ffffffffc0205802:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205804:	000a7a17          	auipc	s4,0xa7
ffffffffc0205808:	b8ca0a13          	addi	s4,s4,-1140 # ffffffffc02ac390 <current>
ffffffffc020580c:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205810:	e14a                	sd	s2,128(sp)
ffffffffc0205812:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205814:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205818:	fcce                	sd	s3,120(sp)
ffffffffc020581a:	f0da                	sd	s6,96(sp)
ffffffffc020581c:	89aa                	mv	s3,a0
ffffffffc020581e:	842e                	mv	s0,a1
ffffffffc0205820:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) { //检查name的内存空间能否被访问
ffffffffc0205822:	4681                	li	a3,0
ffffffffc0205824:	862e                	mv	a2,a1
ffffffffc0205826:	85aa                	mv	a1,a0
ffffffffc0205828:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020582a:	ed06                	sd	ra,152(sp)
ffffffffc020582c:	e526                	sd	s1,136(sp)
ffffffffc020582e:	f4d6                	sd	s5,104(sp)
ffffffffc0205830:	ecde                	sd	s7,88(sp)
ffffffffc0205832:	e8e2                	sd	s8,80(sp)
ffffffffc0205834:	e4e6                	sd	s9,72(sp)
ffffffffc0205836:	e0ea                	sd	s10,64(sp)
ffffffffc0205838:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) { //检查name的内存空间能否被访问
ffffffffc020583a:	808fc0ef          	jal	ra,ffffffffc0201842 <user_mem_check>
ffffffffc020583e:	40050463          	beqz	a0,ffffffffc0205c46 <do_execve+0x446>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205842:	4641                	li	a2,16
ffffffffc0205844:	4581                	li	a1,0
ffffffffc0205846:	1008                	addi	a0,sp,32
ffffffffc0205848:	147000ef          	jal	ra,ffffffffc020618e <memset>
    memcpy(local_name, name, len);
ffffffffc020584c:	47bd                	li	a5,15
ffffffffc020584e:	8622                	mv	a2,s0
ffffffffc0205850:	0687ee63          	bltu	a5,s0,ffffffffc02058cc <do_execve+0xcc>
ffffffffc0205854:	85ce                	mv	a1,s3
ffffffffc0205856:	1008                	addi	a0,sp,32
ffffffffc0205858:	149000ef          	jal	ra,ffffffffc02061a0 <memcpy>
    if (mm != NULL) {
ffffffffc020585c:	06090f63          	beqz	s2,ffffffffc02058da <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0205860:	00002517          	auipc	a0,0x2
ffffffffc0205864:	89850513          	addi	a0,a0,-1896 # ffffffffc02070f8 <commands+0x9c0>
ffffffffc0205868:	8a1fa0ef          	jal	ra,ffffffffc0200108 <cputs>
        lcr3(boot_cr3);
ffffffffc020586c:	000a7797          	auipc	a5,0xa7
ffffffffc0205870:	c5478793          	addi	a5,a5,-940 # ffffffffc02ac4c0 <boot_cr3>
ffffffffc0205874:	639c                	ld	a5,0(a5)
ffffffffc0205876:	577d                	li	a4,-1
ffffffffc0205878:	177e                	slli	a4,a4,0x3f
ffffffffc020587a:	83b1                	srli	a5,a5,0xc
ffffffffc020587c:	8fd9                	or	a5,a5,a4
ffffffffc020587e:	18079073          	csrw	satp,a5
ffffffffc0205882:	03092783          	lw	a5,48(s2)
ffffffffc0205886:	fff7871b          	addiw	a4,a5,-1
ffffffffc020588a:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc020588e:	28070b63          	beqz	a4,ffffffffc0205b24 <do_execve+0x324>
        current->mm = NULL;
ffffffffc0205892:	000a3783          	ld	a5,0(s4)
ffffffffc0205896:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc020589a:	de0fb0ef          	jal	ra,ffffffffc0200e7a <mm_create>
ffffffffc020589e:	892a                	mv	s2,a0
ffffffffc02058a0:	c135                	beqz	a0,ffffffffc0205904 <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc02058a2:	d96ff0ef          	jal	ra,ffffffffc0204e38 <setup_pgdir>
ffffffffc02058a6:	e931                	bnez	a0,ffffffffc02058fa <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058a8:	000b2703          	lw	a4,0(s6)
ffffffffc02058ac:	464c47b7          	lui	a5,0x464c4
ffffffffc02058b0:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9b0f>
ffffffffc02058b4:	04f70a63          	beq	a4,a5,ffffffffc0205908 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc02058b8:	854a                	mv	a0,s2
ffffffffc02058ba:	d00ff0ef          	jal	ra,ffffffffc0204dba <put_pgdir>
    mm_destroy(mm);
ffffffffc02058be:	854a                	mv	a0,s2
ffffffffc02058c0:	f40fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02058c4:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc02058c6:	854e                	mv	a0,s3
ffffffffc02058c8:	b1bff0ef          	jal	ra,ffffffffc02053e2 <do_exit>
    memcpy(local_name, name, len);
ffffffffc02058cc:	463d                	li	a2,15
ffffffffc02058ce:	85ce                	mv	a1,s3
ffffffffc02058d0:	1008                	addi	a0,sp,32
ffffffffc02058d2:	0cf000ef          	jal	ra,ffffffffc02061a0 <memcpy>
    if (mm != NULL) {
ffffffffc02058d6:	f80915e3          	bnez	s2,ffffffffc0205860 <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc02058da:	000a3783          	ld	a5,0(s4)
ffffffffc02058de:	779c                	ld	a5,40(a5)
ffffffffc02058e0:	dfcd                	beqz	a5,ffffffffc020589a <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02058e2:	00003617          	auipc	a2,0x3
ffffffffc02058e6:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0208370 <default_pmm_manager+0x660>
ffffffffc02058ea:	20d00593          	li	a1,525
ffffffffc02058ee:	00003517          	auipc	a0,0x3
ffffffffc02058f2:	eda50513          	addi	a0,a0,-294 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc02058f6:	921fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    mm_destroy(mm);
ffffffffc02058fa:	854a                	mv	a0,s2
ffffffffc02058fc:	f04fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205900:	59f1                	li	s3,-4
ffffffffc0205902:	b7d1                	j	ffffffffc02058c6 <do_execve+0xc6>
ffffffffc0205904:	59f1                	li	s3,-4
ffffffffc0205906:	b7c1                	j	ffffffffc02058c6 <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205908:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020590c:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205910:	00371793          	slli	a5,a4,0x3
ffffffffc0205914:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205916:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205918:	078e                	slli	a5,a5,0x3
ffffffffc020591a:	97a2                	add	a5,a5,s0
ffffffffc020591c:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc020591e:	02f47b63          	bleu	a5,s0,ffffffffc0205954 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc0205922:	5bfd                	li	s7,-1
ffffffffc0205924:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc0205928:	000a7d97          	auipc	s11,0xa7
ffffffffc020592c:	ba0d8d93          	addi	s11,s11,-1120 # ffffffffc02ac4c8 <pages>
ffffffffc0205930:	00003d17          	auipc	s10,0x3
ffffffffc0205934:	360d0d13          	addi	s10,s10,864 # ffffffffc0208c90 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205938:	e43e                	sd	a5,8(sp)
ffffffffc020593a:	000a7c97          	auipc	s9,0xa7
ffffffffc020593e:	a4ec8c93          	addi	s9,s9,-1458 # ffffffffc02ac388 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205942:	4018                	lw	a4,0(s0)
ffffffffc0205944:	4785                	li	a5,1
ffffffffc0205946:	0ef70d63          	beq	a4,a5,ffffffffc0205a40 <do_execve+0x240>
    for (; ph < ph_end; ph ++) {
ffffffffc020594a:	67e2                	ld	a5,24(sp)
ffffffffc020594c:	03840413          	addi	s0,s0,56
ffffffffc0205950:	fef469e3          	bltu	s0,a5,ffffffffc0205942 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205954:	4701                	li	a4,0
ffffffffc0205956:	46ad                	li	a3,11
ffffffffc0205958:	00100637          	lui	a2,0x100
ffffffffc020595c:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205960:	854a                	mv	a0,s2
ffffffffc0205962:	ef0fb0ef          	jal	ra,ffffffffc0201052 <mm_map>
ffffffffc0205966:	89aa                	mv	s3,a0
ffffffffc0205968:	1a051463          	bnez	a0,ffffffffc0205b10 <do_execve+0x310>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc020596c:	01893503          	ld	a0,24(s2)
ffffffffc0205970:	467d                	li	a2,31
ffffffffc0205972:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205976:	8fcff0ef          	jal	ra,ffffffffc0204a72 <pgdir_alloc_page>
ffffffffc020597a:	36050263          	beqz	a0,ffffffffc0205cde <do_execve+0x4de>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc020597e:	01893503          	ld	a0,24(s2)
ffffffffc0205982:	467d                	li	a2,31
ffffffffc0205984:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205988:	8eaff0ef          	jal	ra,ffffffffc0204a72 <pgdir_alloc_page>
ffffffffc020598c:	32050963          	beqz	a0,ffffffffc0205cbe <do_execve+0x4be>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205990:	01893503          	ld	a0,24(s2)
ffffffffc0205994:	467d                	li	a2,31
ffffffffc0205996:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc020599a:	8d8ff0ef          	jal	ra,ffffffffc0204a72 <pgdir_alloc_page>
ffffffffc020599e:	30050063          	beqz	a0,ffffffffc0205c9e <do_execve+0x49e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02059a2:	01893503          	ld	a0,24(s2)
ffffffffc02059a6:	467d                	li	a2,31
ffffffffc02059a8:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02059ac:	8c6ff0ef          	jal	ra,ffffffffc0204a72 <pgdir_alloc_page>
ffffffffc02059b0:	2c050763          	beqz	a0,ffffffffc0205c7e <do_execve+0x47e>
    mm->mm_count += 1;
ffffffffc02059b4:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc02059b8:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059bc:	01893683          	ld	a3,24(s2)
ffffffffc02059c0:	2785                	addiw	a5,a5,1
ffffffffc02059c2:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc02059c6:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf55b8>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059ca:	c02007b7          	lui	a5,0xc0200
ffffffffc02059ce:	28f6ec63          	bltu	a3,a5,ffffffffc0205c66 <do_execve+0x466>
ffffffffc02059d2:	000a7797          	auipc	a5,0xa7
ffffffffc02059d6:	ae678793          	addi	a5,a5,-1306 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc02059da:	639c                	ld	a5,0(a5)
ffffffffc02059dc:	577d                	li	a4,-1
ffffffffc02059de:	177e                	slli	a4,a4,0x3f
ffffffffc02059e0:	8e9d                	sub	a3,a3,a5
ffffffffc02059e2:	00c6d793          	srli	a5,a3,0xc
ffffffffc02059e6:	f654                	sd	a3,168(a2)
ffffffffc02059e8:	8fd9                	or	a5,a5,a4
ffffffffc02059ea:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02059ee:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059f0:	4581                	li	a1,0
ffffffffc02059f2:	12000613          	li	a2,288
ffffffffc02059f6:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc02059f8:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059fc:	792000ef          	jal	ra,ffffffffc020618e <memset>
    tf->epc = elf->e_entry;
ffffffffc0205a00:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a04:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc0205a06:	000a3503          	ld	a0,0(s4)
    tf->status = (sstatus) & ~(SSTATUS_SPP| SSTATUS_SPIE);
ffffffffc0205a0a:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a0e:	07fe                	slli	a5,a5,0x1f
ffffffffc0205a10:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205a12:	10e43423          	sd	a4,264(s0)
    tf->status = (sstatus) & ~(SSTATUS_SPP| SSTATUS_SPIE);
ffffffffc0205a16:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205a1a:	100c                	addi	a1,sp,32
ffffffffc0205a1c:	ca8ff0ef          	jal	ra,ffffffffc0204ec4 <set_proc_name>
}
ffffffffc0205a20:	60ea                	ld	ra,152(sp)
ffffffffc0205a22:	644a                	ld	s0,144(sp)
ffffffffc0205a24:	854e                	mv	a0,s3
ffffffffc0205a26:	64aa                	ld	s1,136(sp)
ffffffffc0205a28:	690a                	ld	s2,128(sp)
ffffffffc0205a2a:	79e6                	ld	s3,120(sp)
ffffffffc0205a2c:	7a46                	ld	s4,112(sp)
ffffffffc0205a2e:	7aa6                	ld	s5,104(sp)
ffffffffc0205a30:	7b06                	ld	s6,96(sp)
ffffffffc0205a32:	6be6                	ld	s7,88(sp)
ffffffffc0205a34:	6c46                	ld	s8,80(sp)
ffffffffc0205a36:	6ca6                	ld	s9,72(sp)
ffffffffc0205a38:	6d06                	ld	s10,64(sp)
ffffffffc0205a3a:	7de2                	ld	s11,56(sp)
ffffffffc0205a3c:	610d                	addi	sp,sp,160
ffffffffc0205a3e:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205a40:	7410                	ld	a2,40(s0)
ffffffffc0205a42:	701c                	ld	a5,32(s0)
ffffffffc0205a44:	20f66363          	bltu	a2,a5,ffffffffc0205c4a <do_execve+0x44a>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a48:	405c                	lw	a5,4(s0)
ffffffffc0205a4a:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a4e:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a52:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a54:	0e071263          	bnez	a4,ffffffffc0205b38 <do_execve+0x338>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a58:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a5a:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a5c:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a5e:	c789                	beqz	a5,ffffffffc0205a68 <do_execve+0x268>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a60:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a62:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a66:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205a68:	0026f793          	andi	a5,a3,2
ffffffffc0205a6c:	efe1                	bnez	a5,ffffffffc0205b44 <do_execve+0x344>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205a6e:	0046f793          	andi	a5,a3,4
ffffffffc0205a72:	c789                	beqz	a5,ffffffffc0205a7c <do_execve+0x27c>
ffffffffc0205a74:	6782                	ld	a5,0(sp)
ffffffffc0205a76:	0087e793          	ori	a5,a5,8
ffffffffc0205a7a:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205a7c:	680c                	ld	a1,16(s0)
ffffffffc0205a7e:	4701                	li	a4,0
ffffffffc0205a80:	854a                	mv	a0,s2
ffffffffc0205a82:	dd0fb0ef          	jal	ra,ffffffffc0201052 <mm_map>
ffffffffc0205a86:	89aa                	mv	s3,a0
ffffffffc0205a88:	e541                	bnez	a0,ffffffffc0205b10 <do_execve+0x310>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a8a:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a8e:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a92:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a96:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a98:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a9a:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a9c:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205aa0:	053bef63          	bltu	s7,s3,ffffffffc0205afe <do_execve+0x2fe>
ffffffffc0205aa4:	aa79                	j	ffffffffc0205c42 <do_execve+0x442>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205aa6:	6785                	lui	a5,0x1
ffffffffc0205aa8:	418b8533          	sub	a0,s7,s8
ffffffffc0205aac:	9c3e                	add	s8,s8,a5
ffffffffc0205aae:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205ab2:	0189f463          	bleu	s8,s3,ffffffffc0205aba <do_execve+0x2ba>
                size -= la - end;
ffffffffc0205ab6:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205aba:	000db683          	ld	a3,0(s11)
ffffffffc0205abe:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205ac2:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205ac4:	40d486b3          	sub	a3,s1,a3
ffffffffc0205ac8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205aca:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205ace:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205ad0:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ad4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205ad6:	16c5fc63          	bleu	a2,a1,ffffffffc0205c4e <do_execve+0x44e>
ffffffffc0205ada:	000a7797          	auipc	a5,0xa7
ffffffffc0205ade:	9de78793          	addi	a5,a5,-1570 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc0205ae2:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205ae6:	85d6                	mv	a1,s5
ffffffffc0205ae8:	8642                	mv	a2,a6
ffffffffc0205aea:	96c6                	add	a3,a3,a7
ffffffffc0205aec:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205aee:	9bc2                	add	s7,s7,a6
ffffffffc0205af0:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205af2:	6ae000ef          	jal	ra,ffffffffc02061a0 <memcpy>
            start += size, from += size;
ffffffffc0205af6:	6842                	ld	a6,16(sp)
ffffffffc0205af8:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205afa:	053bf863          	bleu	s3,s7,ffffffffc0205b4a <do_execve+0x34a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205afe:	01893503          	ld	a0,24(s2)
ffffffffc0205b02:	6602                	ld	a2,0(sp)
ffffffffc0205b04:	85e2                	mv	a1,s8
ffffffffc0205b06:	f6dfe0ef          	jal	ra,ffffffffc0204a72 <pgdir_alloc_page>
ffffffffc0205b0a:	84aa                	mv	s1,a0
ffffffffc0205b0c:	fd49                	bnez	a0,ffffffffc0205aa6 <do_execve+0x2a6>
        ret = -E_NO_MEM;
ffffffffc0205b0e:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205b10:	854a                	mv	a0,s2
ffffffffc0205b12:	e8efb0ef          	jal	ra,ffffffffc02011a0 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205b16:	854a                	mv	a0,s2
ffffffffc0205b18:	aa2ff0ef          	jal	ra,ffffffffc0204dba <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b1c:	854a                	mv	a0,s2
ffffffffc0205b1e:	ce2fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
    return ret;
ffffffffc0205b22:	b355                	j	ffffffffc02058c6 <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205b24:	854a                	mv	a0,s2
ffffffffc0205b26:	e7afb0ef          	jal	ra,ffffffffc02011a0 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b2a:	854a                	mv	a0,s2
ffffffffc0205b2c:	a8eff0ef          	jal	ra,ffffffffc0204dba <put_pgdir>
            mm_destroy(mm);//把进程当前占用的内存释放，之后重新分配内存
ffffffffc0205b30:	854a                	mv	a0,s2
ffffffffc0205b32:	ccefb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
ffffffffc0205b36:	bbb1                	j	ffffffffc0205892 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b38:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b3c:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b3e:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b40:	f20790e3          	bnez	a5,ffffffffc0205a60 <do_execve+0x260>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b44:	47dd                	li	a5,23
ffffffffc0205b46:	e03e                	sd	a5,0(sp)
ffffffffc0205b48:	b71d                	j	ffffffffc0205a6e <do_execve+0x26e>
ffffffffc0205b4a:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b4e:	7414                	ld	a3,40(s0)
ffffffffc0205b50:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205b52:	098bf163          	bleu	s8,s7,ffffffffc0205bd4 <do_execve+0x3d4>
            if (start == end) {
ffffffffc0205b56:	df798ae3          	beq	s3,s7,ffffffffc020594a <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b5a:	6505                	lui	a0,0x1
ffffffffc0205b5c:	955e                	add	a0,a0,s7
ffffffffc0205b5e:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205b62:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205b66:	0d89fb63          	bleu	s8,s3,ffffffffc0205c3c <do_execve+0x43c>
    return page - pages + nbase;
ffffffffc0205b6a:	000db683          	ld	a3,0(s11)
ffffffffc0205b6e:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205b72:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205b74:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b78:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b7a:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b7e:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b80:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b84:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b86:	0cc5f463          	bleu	a2,a1,ffffffffc0205c4e <do_execve+0x44e>
ffffffffc0205b8a:	000a7617          	auipc	a2,0xa7
ffffffffc0205b8e:	92e60613          	addi	a2,a2,-1746 # ffffffffc02ac4b8 <va_pa_offset>
ffffffffc0205b92:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205b96:	4581                	li	a1,0
ffffffffc0205b98:	8656                	mv	a2,s5
ffffffffc0205b9a:	96c2                	add	a3,a3,a6
ffffffffc0205b9c:	9536                	add	a0,a0,a3
ffffffffc0205b9e:	5f0000ef          	jal	ra,ffffffffc020618e <memset>
            start += size;
ffffffffc0205ba2:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205ba6:	0389f463          	bleu	s8,s3,ffffffffc0205bce <do_execve+0x3ce>
ffffffffc0205baa:	dae980e3          	beq	s3,a4,ffffffffc020594a <do_execve+0x14a>
ffffffffc0205bae:	00002697          	auipc	a3,0x2
ffffffffc0205bb2:	7ea68693          	addi	a3,a3,2026 # ffffffffc0208398 <default_pmm_manager+0x688>
ffffffffc0205bb6:	00001617          	auipc	a2,0x1
ffffffffc0205bba:	00260613          	addi	a2,a2,2 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205bbe:	26200593          	li	a1,610
ffffffffc0205bc2:	00003517          	auipc	a0,0x3
ffffffffc0205bc6:	c0650513          	addi	a0,a0,-1018 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc0205bca:	e4cfa0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0205bce:	ff8710e3          	bne	a4,s8,ffffffffc0205bae <do_execve+0x3ae>
ffffffffc0205bd2:	8be2                	mv	s7,s8
ffffffffc0205bd4:	000a7a97          	auipc	s5,0xa7
ffffffffc0205bd8:	8e4a8a93          	addi	s5,s5,-1820 # ffffffffc02ac4b8 <va_pa_offset>
        while (start < end) {
ffffffffc0205bdc:	053be763          	bltu	s7,s3,ffffffffc0205c2a <do_execve+0x42a>
ffffffffc0205be0:	b3ad                	j	ffffffffc020594a <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205be2:	6785                	lui	a5,0x1
ffffffffc0205be4:	418b8533          	sub	a0,s7,s8
ffffffffc0205be8:	9c3e                	add	s8,s8,a5
ffffffffc0205bea:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205bee:	0189f463          	bleu	s8,s3,ffffffffc0205bf6 <do_execve+0x3f6>
                size -= la - end;
ffffffffc0205bf2:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205bf6:	000db683          	ld	a3,0(s11)
ffffffffc0205bfa:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205bfe:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c00:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c04:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c06:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205c0a:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205c0c:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c10:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c12:	02b87e63          	bleu	a1,a6,ffffffffc0205c4e <do_execve+0x44e>
ffffffffc0205c16:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205c1a:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c1c:	4581                	li	a1,0
ffffffffc0205c1e:	96c2                	add	a3,a3,a6
ffffffffc0205c20:	9536                	add	a0,a0,a3
ffffffffc0205c22:	56c000ef          	jal	ra,ffffffffc020618e <memset>
        while (start < end) {
ffffffffc0205c26:	d33bf2e3          	bleu	s3,s7,ffffffffc020594a <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c2a:	01893503          	ld	a0,24(s2)
ffffffffc0205c2e:	6602                	ld	a2,0(sp)
ffffffffc0205c30:	85e2                	mv	a1,s8
ffffffffc0205c32:	e41fe0ef          	jal	ra,ffffffffc0204a72 <pgdir_alloc_page>
ffffffffc0205c36:	84aa                	mv	s1,a0
ffffffffc0205c38:	f54d                	bnez	a0,ffffffffc0205be2 <do_execve+0x3e2>
ffffffffc0205c3a:	bdd1                	j	ffffffffc0205b0e <do_execve+0x30e>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c3c:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205c40:	b72d                	j	ffffffffc0205b6a <do_execve+0x36a>
        while (start < end) {
ffffffffc0205c42:	89de                	mv	s3,s7
ffffffffc0205c44:	b729                	j	ffffffffc0205b4e <do_execve+0x34e>
        return -E_INVAL;
ffffffffc0205c46:	59f5                	li	s3,-3
ffffffffc0205c48:	bbe1                	j	ffffffffc0205a20 <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205c4a:	59e1                	li	s3,-8
ffffffffc0205c4c:	b5d1                	j	ffffffffc0205b10 <do_execve+0x310>
ffffffffc0205c4e:	00001617          	auipc	a2,0x1
ffffffffc0205c52:	6a260613          	addi	a2,a2,1698 # ffffffffc02072f0 <commands+0xbb8>
ffffffffc0205c56:	06900593          	li	a1,105
ffffffffc0205c5a:	00001517          	auipc	a0,0x1
ffffffffc0205c5e:	68650513          	addi	a0,a0,1670 # ffffffffc02072e0 <commands+0xba8>
ffffffffc0205c62:	db4fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c66:	00002617          	auipc	a2,0x2
ffffffffc0205c6a:	90260613          	addi	a2,a2,-1790 # ffffffffc0207568 <commands+0xe30>
ffffffffc0205c6e:	27d00593          	li	a1,637
ffffffffc0205c72:	00003517          	auipc	a0,0x3
ffffffffc0205c76:	b5650513          	addi	a0,a0,-1194 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc0205c7a:	d9cfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c7e:	00003697          	auipc	a3,0x3
ffffffffc0205c82:	83268693          	addi	a3,a3,-1998 # ffffffffc02084b0 <default_pmm_manager+0x7a0>
ffffffffc0205c86:	00001617          	auipc	a2,0x1
ffffffffc0205c8a:	f3260613          	addi	a2,a2,-206 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205c8e:	27800593          	li	a1,632
ffffffffc0205c92:	00003517          	auipc	a0,0x3
ffffffffc0205c96:	b3650513          	addi	a0,a0,-1226 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc0205c9a:	d7cfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c9e:	00002697          	auipc	a3,0x2
ffffffffc0205ca2:	7ca68693          	addi	a3,a3,1994 # ffffffffc0208468 <default_pmm_manager+0x758>
ffffffffc0205ca6:	00001617          	auipc	a2,0x1
ffffffffc0205caa:	f1260613          	addi	a2,a2,-238 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205cae:	27700593          	li	a1,631
ffffffffc0205cb2:	00003517          	auipc	a0,0x3
ffffffffc0205cb6:	b1650513          	addi	a0,a0,-1258 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc0205cba:	d5cfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cbe:	00002697          	auipc	a3,0x2
ffffffffc0205cc2:	76268693          	addi	a3,a3,1890 # ffffffffc0208420 <default_pmm_manager+0x710>
ffffffffc0205cc6:	00001617          	auipc	a2,0x1
ffffffffc0205cca:	ef260613          	addi	a2,a2,-270 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205cce:	27600593          	li	a1,630
ffffffffc0205cd2:	00003517          	auipc	a0,0x3
ffffffffc0205cd6:	af650513          	addi	a0,a0,-1290 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc0205cda:	d3cfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205cde:	00002697          	auipc	a3,0x2
ffffffffc0205ce2:	6fa68693          	addi	a3,a3,1786 # ffffffffc02083d8 <default_pmm_manager+0x6c8>
ffffffffc0205ce6:	00001617          	auipc	a2,0x1
ffffffffc0205cea:	ed260613          	addi	a2,a2,-302 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205cee:	27500593          	li	a1,629
ffffffffc0205cf2:	00003517          	auipc	a0,0x3
ffffffffc0205cf6:	ad650513          	addi	a0,a0,-1322 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc0205cfa:	d1cfa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205cfe <do_yield>:
    current->need_resched = 1;
ffffffffc0205cfe:	000a6797          	auipc	a5,0xa6
ffffffffc0205d02:	69278793          	addi	a5,a5,1682 # ffffffffc02ac390 <current>
ffffffffc0205d06:	639c                	ld	a5,0(a5)
ffffffffc0205d08:	4705                	li	a4,1
}
ffffffffc0205d0a:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205d0c:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d0e:	8082                	ret

ffffffffc0205d10 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205d10:	1101                	addi	sp,sp,-32
ffffffffc0205d12:	e822                	sd	s0,16(sp)
ffffffffc0205d14:	e426                	sd	s1,8(sp)
ffffffffc0205d16:	ec06                	sd	ra,24(sp)
ffffffffc0205d18:	842e                	mv	s0,a1
ffffffffc0205d1a:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205d1c:	cd81                	beqz	a1,ffffffffc0205d34 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205d1e:	000a6797          	auipc	a5,0xa6
ffffffffc0205d22:	67278793          	addi	a5,a5,1650 # ffffffffc02ac390 <current>
ffffffffc0205d26:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205d28:	4685                	li	a3,1
ffffffffc0205d2a:	4611                	li	a2,4
ffffffffc0205d2c:	7788                	ld	a0,40(a5)
ffffffffc0205d2e:	b15fb0ef          	jal	ra,ffffffffc0201842 <user_mem_check>
ffffffffc0205d32:	c909                	beqz	a0,ffffffffc0205d44 <do_wait+0x34>
ffffffffc0205d34:	85a2                	mv	a1,s0
}
ffffffffc0205d36:	6442                	ld	s0,16(sp)
ffffffffc0205d38:	60e2                	ld	ra,24(sp)
ffffffffc0205d3a:	8526                	mv	a0,s1
ffffffffc0205d3c:	64a2                	ld	s1,8(sp)
ffffffffc0205d3e:	6105                	addi	sp,sp,32
ffffffffc0205d40:	ff0ff06f          	j	ffffffffc0205530 <do_wait.part.1>
ffffffffc0205d44:	60e2                	ld	ra,24(sp)
ffffffffc0205d46:	6442                	ld	s0,16(sp)
ffffffffc0205d48:	64a2                	ld	s1,8(sp)
ffffffffc0205d4a:	5575                	li	a0,-3
ffffffffc0205d4c:	6105                	addi	sp,sp,32
ffffffffc0205d4e:	8082                	ret

ffffffffc0205d50 <do_kill>:
do_kill(int pid) {
ffffffffc0205d50:	1141                	addi	sp,sp,-16
ffffffffc0205d52:	e406                	sd	ra,8(sp)
ffffffffc0205d54:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205d56:	a04ff0ef          	jal	ra,ffffffffc0204f5a <find_proc>
ffffffffc0205d5a:	cd0d                	beqz	a0,ffffffffc0205d94 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205d5c:	0b052703          	lw	a4,176(a0)
ffffffffc0205d60:	00177693          	andi	a3,a4,1
ffffffffc0205d64:	e695                	bnez	a3,ffffffffc0205d90 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d66:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205d6a:	00176713          	ori	a4,a4,1
ffffffffc0205d6e:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205d72:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d74:	0006c763          	bltz	a3,ffffffffc0205d82 <do_kill+0x32>
}
ffffffffc0205d78:	8522                	mv	a0,s0
ffffffffc0205d7a:	60a2                	ld	ra,8(sp)
ffffffffc0205d7c:	6402                	ld	s0,0(sp)
ffffffffc0205d7e:	0141                	addi	sp,sp,16
ffffffffc0205d80:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205d82:	17c000ef          	jal	ra,ffffffffc0205efe <wakeup_proc>
}
ffffffffc0205d86:	8522                	mv	a0,s0
ffffffffc0205d88:	60a2                	ld	ra,8(sp)
ffffffffc0205d8a:	6402                	ld	s0,0(sp)
ffffffffc0205d8c:	0141                	addi	sp,sp,16
ffffffffc0205d8e:	8082                	ret
        return -E_KILLED;
ffffffffc0205d90:	545d                	li	s0,-9
ffffffffc0205d92:	b7dd                	j	ffffffffc0205d78 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205d94:	5475                	li	s0,-3
ffffffffc0205d96:	b7cd                	j	ffffffffc0205d78 <do_kill+0x28>

ffffffffc0205d98 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205d98:	000a6797          	auipc	a5,0xa6
ffffffffc0205d9c:	73878793          	addi	a5,a5,1848 # ffffffffc02ac4d0 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205da0:	1101                	addi	sp,sp,-32
ffffffffc0205da2:	000a6717          	auipc	a4,0xa6
ffffffffc0205da6:	72f73b23          	sd	a5,1846(a4) # ffffffffc02ac4d8 <proc_list+0x8>
ffffffffc0205daa:	000a6717          	auipc	a4,0xa6
ffffffffc0205dae:	72f73323          	sd	a5,1830(a4) # ffffffffc02ac4d0 <proc_list>
ffffffffc0205db2:	ec06                	sd	ra,24(sp)
ffffffffc0205db4:	e822                	sd	s0,16(sp)
ffffffffc0205db6:	e426                	sd	s1,8(sp)
ffffffffc0205db8:	000a2797          	auipc	a5,0xa2
ffffffffc0205dbc:	59878793          	addi	a5,a5,1432 # ffffffffc02a8350 <hash_list>
ffffffffc0205dc0:	000a6717          	auipc	a4,0xa6
ffffffffc0205dc4:	59070713          	addi	a4,a4,1424 # ffffffffc02ac350 <is_panic>
ffffffffc0205dc8:	e79c                	sd	a5,8(a5)
ffffffffc0205dca:	e39c                	sd	a5,0(a5)
ffffffffc0205dcc:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205dce:	fee79de3          	bne	a5,a4,ffffffffc0205dc8 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205dd2:	f0ffe0ef          	jal	ra,ffffffffc0204ce0 <alloc_proc>
ffffffffc0205dd6:	000a6717          	auipc	a4,0xa6
ffffffffc0205dda:	5ca73123          	sd	a0,1474(a4) # ffffffffc02ac398 <idleproc>
ffffffffc0205dde:	000a6497          	auipc	s1,0xa6
ffffffffc0205de2:	5ba48493          	addi	s1,s1,1466 # ffffffffc02ac398 <idleproc>
ffffffffc0205de6:	c559                	beqz	a0,ffffffffc0205e74 <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205de8:	4709                	li	a4,2
ffffffffc0205dea:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205dec:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205dee:	00003717          	auipc	a4,0x3
ffffffffc0205df2:	21270713          	addi	a4,a4,530 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205df6:	00003597          	auipc	a1,0x3
ffffffffc0205dfa:	8ea58593          	addi	a1,a1,-1814 # ffffffffc02086e0 <default_pmm_manager+0x9d0>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205dfe:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e00:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205e02:	8c2ff0ef          	jal	ra,ffffffffc0204ec4 <set_proc_name>
    nr_process ++;
ffffffffc0205e06:	000a6797          	auipc	a5,0xa6
ffffffffc0205e0a:	5a278793          	addi	a5,a5,1442 # ffffffffc02ac3a8 <nr_process>
ffffffffc0205e0e:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205e10:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e12:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205e14:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e16:	4581                	li	a1,0
ffffffffc0205e18:	00000517          	auipc	a0,0x0
ffffffffc0205e1c:	8c050513          	addi	a0,a0,-1856 # ffffffffc02056d8 <init_main>
    nr_process ++;
ffffffffc0205e20:	000a6697          	auipc	a3,0xa6
ffffffffc0205e24:	58f6a423          	sw	a5,1416(a3) # ffffffffc02ac3a8 <nr_process>
    current = idleproc;
ffffffffc0205e28:	000a6797          	auipc	a5,0xa6
ffffffffc0205e2c:	56e7b423          	sd	a4,1384(a5) # ffffffffc02ac390 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e30:	d62ff0ef          	jal	ra,ffffffffc0205392 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205e34:	08a05c63          	blez	a0,ffffffffc0205ecc <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e38:	922ff0ef          	jal	ra,ffffffffc0204f5a <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205e3c:	00003597          	auipc	a1,0x3
ffffffffc0205e40:	8cc58593          	addi	a1,a1,-1844 # ffffffffc0208708 <default_pmm_manager+0x9f8>
    initproc = find_proc(pid);
ffffffffc0205e44:	000a6797          	auipc	a5,0xa6
ffffffffc0205e48:	54a7be23          	sd	a0,1372(a5) # ffffffffc02ac3a0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205e4c:	878ff0ef          	jal	ra,ffffffffc0204ec4 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e50:	609c                	ld	a5,0(s1)
ffffffffc0205e52:	cfa9                	beqz	a5,ffffffffc0205eac <proc_init+0x114>
ffffffffc0205e54:	43dc                	lw	a5,4(a5)
ffffffffc0205e56:	ebb9                	bnez	a5,ffffffffc0205eac <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e58:	000a6797          	auipc	a5,0xa6
ffffffffc0205e5c:	54878793          	addi	a5,a5,1352 # ffffffffc02ac3a0 <initproc>
ffffffffc0205e60:	639c                	ld	a5,0(a5)
ffffffffc0205e62:	c78d                	beqz	a5,ffffffffc0205e8c <proc_init+0xf4>
ffffffffc0205e64:	43dc                	lw	a5,4(a5)
ffffffffc0205e66:	02879363          	bne	a5,s0,ffffffffc0205e8c <proc_init+0xf4>
}
ffffffffc0205e6a:	60e2                	ld	ra,24(sp)
ffffffffc0205e6c:	6442                	ld	s0,16(sp)
ffffffffc0205e6e:	64a2                	ld	s1,8(sp)
ffffffffc0205e70:	6105                	addi	sp,sp,32
ffffffffc0205e72:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205e74:	00003617          	auipc	a2,0x3
ffffffffc0205e78:	85460613          	addi	a2,a2,-1964 # ffffffffc02086c8 <default_pmm_manager+0x9b8>
ffffffffc0205e7c:	37500593          	li	a1,885
ffffffffc0205e80:	00003517          	auipc	a0,0x3
ffffffffc0205e84:	94850513          	addi	a0,a0,-1720 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc0205e88:	b8efa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e8c:	00003697          	auipc	a3,0x3
ffffffffc0205e90:	8ac68693          	addi	a3,a3,-1876 # ffffffffc0208738 <default_pmm_manager+0xa28>
ffffffffc0205e94:	00001617          	auipc	a2,0x1
ffffffffc0205e98:	d2460613          	addi	a2,a2,-732 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205e9c:	38a00593          	li	a1,906
ffffffffc0205ea0:	00003517          	auipc	a0,0x3
ffffffffc0205ea4:	92850513          	addi	a0,a0,-1752 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc0205ea8:	b6efa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205eac:	00003697          	auipc	a3,0x3
ffffffffc0205eb0:	86468693          	addi	a3,a3,-1948 # ffffffffc0208710 <default_pmm_manager+0xa00>
ffffffffc0205eb4:	00001617          	auipc	a2,0x1
ffffffffc0205eb8:	d0460613          	addi	a2,a2,-764 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205ebc:	38900593          	li	a1,905
ffffffffc0205ec0:	00003517          	auipc	a0,0x3
ffffffffc0205ec4:	90850513          	addi	a0,a0,-1784 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc0205ec8:	b4efa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205ecc:	00003617          	auipc	a2,0x3
ffffffffc0205ed0:	81c60613          	addi	a2,a2,-2020 # ffffffffc02086e8 <default_pmm_manager+0x9d8>
ffffffffc0205ed4:	38300593          	li	a1,899
ffffffffc0205ed8:	00003517          	auipc	a0,0x3
ffffffffc0205edc:	8f050513          	addi	a0,a0,-1808 # ffffffffc02087c8 <default_pmm_manager+0xab8>
ffffffffc0205ee0:	b36fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205ee4 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205ee4:	1141                	addi	sp,sp,-16
ffffffffc0205ee6:	e022                	sd	s0,0(sp)
ffffffffc0205ee8:	e406                	sd	ra,8(sp)
ffffffffc0205eea:	000a6417          	auipc	s0,0xa6
ffffffffc0205eee:	4a640413          	addi	s0,s0,1190 # ffffffffc02ac390 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205ef2:	6018                	ld	a4,0(s0)
ffffffffc0205ef4:	6f1c                	ld	a5,24(a4)
ffffffffc0205ef6:	dffd                	beqz	a5,ffffffffc0205ef4 <cpu_idle+0x10>
            schedule();
ffffffffc0205ef8:	082000ef          	jal	ra,ffffffffc0205f7a <schedule>
ffffffffc0205efc:	bfdd                	j	ffffffffc0205ef2 <cpu_idle+0xe>

ffffffffc0205efe <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205efe:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f00:	1101                	addi	sp,sp,-32
ffffffffc0205f02:	ec06                	sd	ra,24(sp)
ffffffffc0205f04:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f06:	478d                	li	a5,3
ffffffffc0205f08:	04f70a63          	beq	a4,a5,ffffffffc0205f5c <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f0c:	100027f3          	csrr	a5,sstatus
ffffffffc0205f10:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205f12:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f14:	ef8d                	bnez	a5,ffffffffc0205f4e <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f16:	4789                	li	a5,2
ffffffffc0205f18:	00f70f63          	beq	a4,a5,ffffffffc0205f36 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205f1c:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205f1e:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205f22:	e409                	bnez	s0,ffffffffc0205f2c <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f24:	60e2                	ld	ra,24(sp)
ffffffffc0205f26:	6442                	ld	s0,16(sp)
ffffffffc0205f28:	6105                	addi	sp,sp,32
ffffffffc0205f2a:	8082                	ret
ffffffffc0205f2c:	6442                	ld	s0,16(sp)
ffffffffc0205f2e:	60e2                	ld	ra,24(sp)
ffffffffc0205f30:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205f32:	f24fa06f          	j	ffffffffc0200656 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205f36:	00003617          	auipc	a2,0x3
ffffffffc0205f3a:	8e260613          	addi	a2,a2,-1822 # ffffffffc0208818 <default_pmm_manager+0xb08>
ffffffffc0205f3e:	45c9                	li	a1,18
ffffffffc0205f40:	00003517          	auipc	a0,0x3
ffffffffc0205f44:	8c050513          	addi	a0,a0,-1856 # ffffffffc0208800 <default_pmm_manager+0xaf0>
ffffffffc0205f48:	b3afa0ef          	jal	ra,ffffffffc0200282 <__warn>
ffffffffc0205f4c:	bfd9                	j	ffffffffc0205f22 <wakeup_proc+0x24>
ffffffffc0205f4e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205f50:	f0cfa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0205f54:	6522                	ld	a0,8(sp)
ffffffffc0205f56:	4405                	li	s0,1
ffffffffc0205f58:	4118                	lw	a4,0(a0)
ffffffffc0205f5a:	bf75                	j	ffffffffc0205f16 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f5c:	00003697          	auipc	a3,0x3
ffffffffc0205f60:	88468693          	addi	a3,a3,-1916 # ffffffffc02087e0 <default_pmm_manager+0xad0>
ffffffffc0205f64:	00001617          	auipc	a2,0x1
ffffffffc0205f68:	c5460613          	addi	a2,a2,-940 # ffffffffc0206bb8 <commands+0x480>
ffffffffc0205f6c:	45a5                	li	a1,9
ffffffffc0205f6e:	00003517          	auipc	a0,0x3
ffffffffc0205f72:	89250513          	addi	a0,a0,-1902 # ffffffffc0208800 <default_pmm_manager+0xaf0>
ffffffffc0205f76:	aa0fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205f7a <schedule>:

void
schedule(void) {
ffffffffc0205f7a:	1141                	addi	sp,sp,-16
ffffffffc0205f7c:	e406                	sd	ra,8(sp)
ffffffffc0205f7e:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f80:	100027f3          	csrr	a5,sstatus
ffffffffc0205f84:	8b89                	andi	a5,a5,2
ffffffffc0205f86:	4401                	li	s0,0
ffffffffc0205f88:	e3d1                	bnez	a5,ffffffffc020600c <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205f8a:	000a6797          	auipc	a5,0xa6
ffffffffc0205f8e:	40678793          	addi	a5,a5,1030 # ffffffffc02ac390 <current>
ffffffffc0205f92:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205f96:	000a6797          	auipc	a5,0xa6
ffffffffc0205f9a:	40278793          	addi	a5,a5,1026 # ffffffffc02ac398 <idleproc>
ffffffffc0205f9e:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0205fa0:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x7550>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fa4:	04a88e63          	beq	a7,a0,ffffffffc0206000 <schedule+0x86>
ffffffffc0205fa8:	0c888693          	addi	a3,a7,200
ffffffffc0205fac:	000a6617          	auipc	a2,0xa6
ffffffffc0205fb0:	52460613          	addi	a2,a2,1316 # ffffffffc02ac4d0 <proc_list>
        le = last;
ffffffffc0205fb4:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205fb6:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205fb8:	4809                	li	a6,2
    return listelm->next;
ffffffffc0205fba:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205fbc:	00c78863          	beq	a5,a2,ffffffffc0205fcc <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205fc0:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205fc4:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205fc8:	01070463          	beq	a4,a6,ffffffffc0205fd0 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205fcc:	fef697e3          	bne	a3,a5,ffffffffc0205fba <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205fd0:	c589                	beqz	a1,ffffffffc0205fda <schedule+0x60>
ffffffffc0205fd2:	4198                	lw	a4,0(a1)
ffffffffc0205fd4:	4789                	li	a5,2
ffffffffc0205fd6:	00f70e63          	beq	a4,a5,ffffffffc0205ff2 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205fda:	451c                	lw	a5,8(a0)
ffffffffc0205fdc:	2785                	addiw	a5,a5,1
ffffffffc0205fde:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205fe0:	00a88463          	beq	a7,a0,ffffffffc0205fe8 <schedule+0x6e>
            proc_run(next);
ffffffffc0205fe4:	f0bfe0ef          	jal	ra,ffffffffc0204eee <proc_run>
    if (flag) {
ffffffffc0205fe8:	e419                	bnez	s0,ffffffffc0205ff6 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205fea:	60a2                	ld	ra,8(sp)
ffffffffc0205fec:	6402                	ld	s0,0(sp)
ffffffffc0205fee:	0141                	addi	sp,sp,16
ffffffffc0205ff0:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205ff2:	852e                	mv	a0,a1
ffffffffc0205ff4:	b7dd                	j	ffffffffc0205fda <schedule+0x60>
}
ffffffffc0205ff6:	6402                	ld	s0,0(sp)
ffffffffc0205ff8:	60a2                	ld	ra,8(sp)
ffffffffc0205ffa:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205ffc:	e5afa06f          	j	ffffffffc0200656 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206000:	000a6617          	auipc	a2,0xa6
ffffffffc0206004:	4d060613          	addi	a2,a2,1232 # ffffffffc02ac4d0 <proc_list>
ffffffffc0206008:	86b2                	mv	a3,a2
ffffffffc020600a:	b76d                	j	ffffffffc0205fb4 <schedule+0x3a>
        intr_disable();
ffffffffc020600c:	e50fa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0206010:	4405                	li	s0,1
ffffffffc0206012:	bfa5                	j	ffffffffc0205f8a <schedule+0x10>

ffffffffc0206014 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206014:	000a6797          	auipc	a5,0xa6
ffffffffc0206018:	37c78793          	addi	a5,a5,892 # ffffffffc02ac390 <current>
ffffffffc020601c:	639c                	ld	a5,0(a5)
}
ffffffffc020601e:	43c8                	lw	a0,4(a5)
ffffffffc0206020:	8082                	ret

ffffffffc0206022 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206022:	4501                	li	a0,0
ffffffffc0206024:	8082                	ret

ffffffffc0206026 <sys_putc>:
    cputchar(c);
ffffffffc0206026:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206028:	1141                	addi	sp,sp,-16
ffffffffc020602a:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020602c:	8d8fa0ef          	jal	ra,ffffffffc0200104 <cputchar>
}
ffffffffc0206030:	60a2                	ld	ra,8(sp)
ffffffffc0206032:	4501                	li	a0,0
ffffffffc0206034:	0141                	addi	sp,sp,16
ffffffffc0206036:	8082                	ret

ffffffffc0206038 <sys_kill>:
    return do_kill(pid);
ffffffffc0206038:	4108                	lw	a0,0(a0)
ffffffffc020603a:	d17ff06f          	j	ffffffffc0205d50 <do_kill>

ffffffffc020603e <sys_yield>:
    return do_yield();
ffffffffc020603e:	cc1ff06f          	j	ffffffffc0205cfe <do_yield>

ffffffffc0206042 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206042:	6d14                	ld	a3,24(a0)
ffffffffc0206044:	6910                	ld	a2,16(a0)
ffffffffc0206046:	650c                	ld	a1,8(a0)
ffffffffc0206048:	6108                	ld	a0,0(a0)
ffffffffc020604a:	fb6ff06f          	j	ffffffffc0205800 <do_execve>

ffffffffc020604e <sys_wait>:
    return do_wait(pid, store);
ffffffffc020604e:	650c                	ld	a1,8(a0)
ffffffffc0206050:	4108                	lw	a0,0(a0)
ffffffffc0206052:	cbfff06f          	j	ffffffffc0205d10 <do_wait>

ffffffffc0206056 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206056:	000a6797          	auipc	a5,0xa6
ffffffffc020605a:	33a78793          	addi	a5,a5,826 # ffffffffc02ac390 <current>
ffffffffc020605e:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc0206060:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0206062:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206064:	6a0c                	ld	a1,16(a2)
ffffffffc0206066:	f51fe06f          	j	ffffffffc0204fb6 <do_fork>

ffffffffc020606a <sys_exit>:
    return do_exit(error_code);
ffffffffc020606a:	4108                	lw	a0,0(a0)
ffffffffc020606c:	b76ff06f          	j	ffffffffc02053e2 <do_exit>

ffffffffc0206070 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0206070:	715d                	addi	sp,sp,-80
ffffffffc0206072:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206074:	000a6497          	auipc	s1,0xa6
ffffffffc0206078:	31c48493          	addi	s1,s1,796 # ffffffffc02ac390 <current>
ffffffffc020607c:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc020607e:	e0a2                	sd	s0,64(sp)
ffffffffc0206080:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206082:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0206084:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206086:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0206088:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020608c:	0327ee63          	bltu	a5,s2,ffffffffc02060c8 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0206090:	00391713          	slli	a4,s2,0x3
ffffffffc0206094:	00002797          	auipc	a5,0x2
ffffffffc0206098:	7ec78793          	addi	a5,a5,2028 # ffffffffc0208880 <syscalls>
ffffffffc020609c:	97ba                	add	a5,a5,a4
ffffffffc020609e:	639c                	ld	a5,0(a5)
ffffffffc02060a0:	c785                	beqz	a5,ffffffffc02060c8 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02060a2:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02060a4:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02060a6:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02060a8:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02060aa:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02060ac:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02060ae:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02060b0:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02060b2:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02060b4:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02060b6:	0028                	addi	a0,sp,8
ffffffffc02060b8:	9782                	jalr	a5
ffffffffc02060ba:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02060bc:	60a6                	ld	ra,72(sp)
ffffffffc02060be:	6406                	ld	s0,64(sp)
ffffffffc02060c0:	74e2                	ld	s1,56(sp)
ffffffffc02060c2:	7942                	ld	s2,48(sp)
ffffffffc02060c4:	6161                	addi	sp,sp,80
ffffffffc02060c6:	8082                	ret
    print_trapframe(tf);
ffffffffc02060c8:	8522                	mv	a0,s0
ffffffffc02060ca:	f80fa0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02060ce:	609c                	ld	a5,0(s1)
ffffffffc02060d0:	86ca                	mv	a3,s2
ffffffffc02060d2:	00002617          	auipc	a2,0x2
ffffffffc02060d6:	76660613          	addi	a2,a2,1894 # ffffffffc0208838 <default_pmm_manager+0xb28>
ffffffffc02060da:	43d8                	lw	a4,4(a5)
ffffffffc02060dc:	06300593          	li	a1,99
ffffffffc02060e0:	0b478793          	addi	a5,a5,180
ffffffffc02060e4:	00002517          	auipc	a0,0x2
ffffffffc02060e8:	78450513          	addi	a0,a0,1924 # ffffffffc0208868 <default_pmm_manager+0xb58>
ffffffffc02060ec:	92afa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02060f0 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02060f0:	00054783          	lbu	a5,0(a0)
ffffffffc02060f4:	cb91                	beqz	a5,ffffffffc0206108 <strlen+0x18>
    size_t cnt = 0;
ffffffffc02060f6:	4781                	li	a5,0
        cnt ++;
ffffffffc02060f8:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02060fa:	00f50733          	add	a4,a0,a5
ffffffffc02060fe:	00074703          	lbu	a4,0(a4)
ffffffffc0206102:	fb7d                	bnez	a4,ffffffffc02060f8 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0206104:	853e                	mv	a0,a5
ffffffffc0206106:	8082                	ret
    size_t cnt = 0;
ffffffffc0206108:	4781                	li	a5,0
}
ffffffffc020610a:	853e                	mv	a0,a5
ffffffffc020610c:	8082                	ret

ffffffffc020610e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020610e:	c185                	beqz	a1,ffffffffc020612e <strnlen+0x20>
ffffffffc0206110:	00054783          	lbu	a5,0(a0)
ffffffffc0206114:	cf89                	beqz	a5,ffffffffc020612e <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0206116:	4781                	li	a5,0
ffffffffc0206118:	a021                	j	ffffffffc0206120 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020611a:	00074703          	lbu	a4,0(a4)
ffffffffc020611e:	c711                	beqz	a4,ffffffffc020612a <strnlen+0x1c>
        cnt ++;
ffffffffc0206120:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206122:	00f50733          	add	a4,a0,a5
ffffffffc0206126:	fef59ae3          	bne	a1,a5,ffffffffc020611a <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020612a:	853e                	mv	a0,a5
ffffffffc020612c:	8082                	ret
    size_t cnt = 0;
ffffffffc020612e:	4781                	li	a5,0
}
ffffffffc0206130:	853e                	mv	a0,a5
ffffffffc0206132:	8082                	ret

ffffffffc0206134 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206134:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206136:	0585                	addi	a1,a1,1
ffffffffc0206138:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020613c:	0785                	addi	a5,a5,1
ffffffffc020613e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206142:	fb75                	bnez	a4,ffffffffc0206136 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206144:	8082                	ret

ffffffffc0206146 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206146:	00054783          	lbu	a5,0(a0)
ffffffffc020614a:	0005c703          	lbu	a4,0(a1)
ffffffffc020614e:	cb91                	beqz	a5,ffffffffc0206162 <strcmp+0x1c>
ffffffffc0206150:	00e79c63          	bne	a5,a4,ffffffffc0206168 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0206154:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206156:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020615a:	0585                	addi	a1,a1,1
ffffffffc020615c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206160:	fbe5                	bnez	a5,ffffffffc0206150 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206162:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206164:	9d19                	subw	a0,a0,a4
ffffffffc0206166:	8082                	ret
ffffffffc0206168:	0007851b          	sext.w	a0,a5
ffffffffc020616c:	9d19                	subw	a0,a0,a4
ffffffffc020616e:	8082                	ret

ffffffffc0206170 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206170:	00054783          	lbu	a5,0(a0)
ffffffffc0206174:	cb91                	beqz	a5,ffffffffc0206188 <strchr+0x18>
        if (*s == c) {
ffffffffc0206176:	00b79563          	bne	a5,a1,ffffffffc0206180 <strchr+0x10>
ffffffffc020617a:	a809                	j	ffffffffc020618c <strchr+0x1c>
ffffffffc020617c:	00b78763          	beq	a5,a1,ffffffffc020618a <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0206180:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206182:	00054783          	lbu	a5,0(a0)
ffffffffc0206186:	fbfd                	bnez	a5,ffffffffc020617c <strchr+0xc>
    }
    return NULL;
ffffffffc0206188:	4501                	li	a0,0
}
ffffffffc020618a:	8082                	ret
ffffffffc020618c:	8082                	ret

ffffffffc020618e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020618e:	ca01                	beqz	a2,ffffffffc020619e <memset+0x10>
ffffffffc0206190:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206192:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0206194:	0785                	addi	a5,a5,1
ffffffffc0206196:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020619a:	fec79de3          	bne	a5,a2,ffffffffc0206194 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020619e:	8082                	ret

ffffffffc02061a0 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02061a0:	ca19                	beqz	a2,ffffffffc02061b6 <memcpy+0x16>
ffffffffc02061a2:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02061a4:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02061a6:	0585                	addi	a1,a1,1
ffffffffc02061a8:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02061ac:	0785                	addi	a5,a5,1
ffffffffc02061ae:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02061b2:	fec59ae3          	bne	a1,a2,ffffffffc02061a6 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02061b6:	8082                	ret

ffffffffc02061b8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02061b8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061bc:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02061be:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061c2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02061c4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061c8:	f022                	sd	s0,32(sp)
ffffffffc02061ca:	ec26                	sd	s1,24(sp)
ffffffffc02061cc:	e84a                	sd	s2,16(sp)
ffffffffc02061ce:	f406                	sd	ra,40(sp)
ffffffffc02061d0:	e44e                	sd	s3,8(sp)
ffffffffc02061d2:	84aa                	mv	s1,a0
ffffffffc02061d4:	892e                	mv	s2,a1
ffffffffc02061d6:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02061da:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02061dc:	03067e63          	bleu	a6,a2,ffffffffc0206218 <printnum+0x60>
ffffffffc02061e0:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02061e2:	00805763          	blez	s0,ffffffffc02061f0 <printnum+0x38>
ffffffffc02061e6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02061e8:	85ca                	mv	a1,s2
ffffffffc02061ea:	854e                	mv	a0,s3
ffffffffc02061ec:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02061ee:	fc65                	bnez	s0,ffffffffc02061e6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061f0:	1a02                	slli	s4,s4,0x20
ffffffffc02061f2:	020a5a13          	srli	s4,s4,0x20
ffffffffc02061f6:	00003797          	auipc	a5,0x3
ffffffffc02061fa:	9aa78793          	addi	a5,a5,-1622 # ffffffffc0208ba0 <error_string+0xc8>
ffffffffc02061fe:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0206200:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206202:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206206:	70a2                	ld	ra,40(sp)
ffffffffc0206208:	69a2                	ld	s3,8(sp)
ffffffffc020620a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020620c:	85ca                	mv	a1,s2
ffffffffc020620e:	8326                	mv	t1,s1
}
ffffffffc0206210:	6942                	ld	s2,16(sp)
ffffffffc0206212:	64e2                	ld	s1,24(sp)
ffffffffc0206214:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206216:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206218:	03065633          	divu	a2,a2,a6
ffffffffc020621c:	8722                	mv	a4,s0
ffffffffc020621e:	f9bff0ef          	jal	ra,ffffffffc02061b8 <printnum>
ffffffffc0206222:	b7f9                	j	ffffffffc02061f0 <printnum+0x38>

ffffffffc0206224 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206224:	7119                	addi	sp,sp,-128
ffffffffc0206226:	f4a6                	sd	s1,104(sp)
ffffffffc0206228:	f0ca                	sd	s2,96(sp)
ffffffffc020622a:	e8d2                	sd	s4,80(sp)
ffffffffc020622c:	e4d6                	sd	s5,72(sp)
ffffffffc020622e:	e0da                	sd	s6,64(sp)
ffffffffc0206230:	fc5e                	sd	s7,56(sp)
ffffffffc0206232:	f862                	sd	s8,48(sp)
ffffffffc0206234:	f06a                	sd	s10,32(sp)
ffffffffc0206236:	fc86                	sd	ra,120(sp)
ffffffffc0206238:	f8a2                	sd	s0,112(sp)
ffffffffc020623a:	ecce                	sd	s3,88(sp)
ffffffffc020623c:	f466                	sd	s9,40(sp)
ffffffffc020623e:	ec6e                	sd	s11,24(sp)
ffffffffc0206240:	892a                	mv	s2,a0
ffffffffc0206242:	84ae                	mv	s1,a1
ffffffffc0206244:	8d32                	mv	s10,a2
ffffffffc0206246:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0206248:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020624a:	00002a17          	auipc	s4,0x2
ffffffffc020624e:	736a0a13          	addi	s4,s4,1846 # ffffffffc0208980 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206252:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206256:	00003c17          	auipc	s8,0x3
ffffffffc020625a:	882c0c13          	addi	s8,s8,-1918 # ffffffffc0208ad8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020625e:	000d4503          	lbu	a0,0(s10)
ffffffffc0206262:	02500793          	li	a5,37
ffffffffc0206266:	001d0413          	addi	s0,s10,1
ffffffffc020626a:	00f50e63          	beq	a0,a5,ffffffffc0206286 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc020626e:	c521                	beqz	a0,ffffffffc02062b6 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206270:	02500993          	li	s3,37
ffffffffc0206274:	a011                	j	ffffffffc0206278 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0206276:	c121                	beqz	a0,ffffffffc02062b6 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0206278:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020627a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020627c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020627e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206282:	ff351ae3          	bne	a0,s3,ffffffffc0206276 <vprintfmt+0x52>
ffffffffc0206286:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020628a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020628e:	4981                	li	s3,0
ffffffffc0206290:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0206292:	5cfd                	li	s9,-1
ffffffffc0206294:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206296:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020629a:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020629c:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02062a0:	0ff6f693          	andi	a3,a3,255
ffffffffc02062a4:	00140d13          	addi	s10,s0,1
ffffffffc02062a8:	20d5e563          	bltu	a1,a3,ffffffffc02064b2 <vprintfmt+0x28e>
ffffffffc02062ac:	068a                	slli	a3,a3,0x2
ffffffffc02062ae:	96d2                	add	a3,a3,s4
ffffffffc02062b0:	4294                	lw	a3,0(a3)
ffffffffc02062b2:	96d2                	add	a3,a3,s4
ffffffffc02062b4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02062b6:	70e6                	ld	ra,120(sp)
ffffffffc02062b8:	7446                	ld	s0,112(sp)
ffffffffc02062ba:	74a6                	ld	s1,104(sp)
ffffffffc02062bc:	7906                	ld	s2,96(sp)
ffffffffc02062be:	69e6                	ld	s3,88(sp)
ffffffffc02062c0:	6a46                	ld	s4,80(sp)
ffffffffc02062c2:	6aa6                	ld	s5,72(sp)
ffffffffc02062c4:	6b06                	ld	s6,64(sp)
ffffffffc02062c6:	7be2                	ld	s7,56(sp)
ffffffffc02062c8:	7c42                	ld	s8,48(sp)
ffffffffc02062ca:	7ca2                	ld	s9,40(sp)
ffffffffc02062cc:	7d02                	ld	s10,32(sp)
ffffffffc02062ce:	6de2                	ld	s11,24(sp)
ffffffffc02062d0:	6109                	addi	sp,sp,128
ffffffffc02062d2:	8082                	ret
    if (lflag >= 2) {
ffffffffc02062d4:	4705                	li	a4,1
ffffffffc02062d6:	008a8593          	addi	a1,s5,8
ffffffffc02062da:	01074463          	blt	a4,a6,ffffffffc02062e2 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02062de:	26080363          	beqz	a6,ffffffffc0206544 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02062e2:	000ab603          	ld	a2,0(s5)
ffffffffc02062e6:	46c1                	li	a3,16
ffffffffc02062e8:	8aae                	mv	s5,a1
ffffffffc02062ea:	a06d                	j	ffffffffc0206394 <vprintfmt+0x170>
            goto reswitch;
ffffffffc02062ec:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02062f0:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062f2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02062f4:	b765                	j	ffffffffc020629c <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02062f6:	000aa503          	lw	a0,0(s5)
ffffffffc02062fa:	85a6                	mv	a1,s1
ffffffffc02062fc:	0aa1                	addi	s5,s5,8
ffffffffc02062fe:	9902                	jalr	s2
            break;
ffffffffc0206300:	bfb9                	j	ffffffffc020625e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206302:	4705                	li	a4,1
ffffffffc0206304:	008a8993          	addi	s3,s5,8
ffffffffc0206308:	01074463          	blt	a4,a6,ffffffffc0206310 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc020630c:	22080463          	beqz	a6,ffffffffc0206534 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0206310:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0206314:	24044463          	bltz	s0,ffffffffc020655c <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0206318:	8622                	mv	a2,s0
ffffffffc020631a:	8ace                	mv	s5,s3
ffffffffc020631c:	46a9                	li	a3,10
ffffffffc020631e:	a89d                	j	ffffffffc0206394 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0206320:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206324:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206326:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0206328:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020632c:	8fb5                	xor	a5,a5,a3
ffffffffc020632e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206332:	1ad74363          	blt	a4,a3,ffffffffc02064d8 <vprintfmt+0x2b4>
ffffffffc0206336:	00369793          	slli	a5,a3,0x3
ffffffffc020633a:	97e2                	add	a5,a5,s8
ffffffffc020633c:	639c                	ld	a5,0(a5)
ffffffffc020633e:	18078d63          	beqz	a5,ffffffffc02064d8 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206342:	86be                	mv	a3,a5
ffffffffc0206344:	00000617          	auipc	a2,0x0
ffffffffc0206348:	2ac60613          	addi	a2,a2,684 # ffffffffc02065f0 <etext+0x28>
ffffffffc020634c:	85a6                	mv	a1,s1
ffffffffc020634e:	854a                	mv	a0,s2
ffffffffc0206350:	240000ef          	jal	ra,ffffffffc0206590 <printfmt>
ffffffffc0206354:	b729                	j	ffffffffc020625e <vprintfmt+0x3a>
            lflag ++;
ffffffffc0206356:	00144603          	lbu	a2,1(s0)
ffffffffc020635a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020635c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020635e:	bf3d                	j	ffffffffc020629c <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0206360:	4705                	li	a4,1
ffffffffc0206362:	008a8593          	addi	a1,s5,8
ffffffffc0206366:	01074463          	blt	a4,a6,ffffffffc020636e <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc020636a:	1e080263          	beqz	a6,ffffffffc020654e <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc020636e:	000ab603          	ld	a2,0(s5)
ffffffffc0206372:	46a1                	li	a3,8
ffffffffc0206374:	8aae                	mv	s5,a1
ffffffffc0206376:	a839                	j	ffffffffc0206394 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0206378:	03000513          	li	a0,48
ffffffffc020637c:	85a6                	mv	a1,s1
ffffffffc020637e:	e03e                	sd	a5,0(sp)
ffffffffc0206380:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206382:	85a6                	mv	a1,s1
ffffffffc0206384:	07800513          	li	a0,120
ffffffffc0206388:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020638a:	0aa1                	addi	s5,s5,8
ffffffffc020638c:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0206390:	6782                	ld	a5,0(sp)
ffffffffc0206392:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206394:	876e                	mv	a4,s11
ffffffffc0206396:	85a6                	mv	a1,s1
ffffffffc0206398:	854a                	mv	a0,s2
ffffffffc020639a:	e1fff0ef          	jal	ra,ffffffffc02061b8 <printnum>
            break;
ffffffffc020639e:	b5c1                	j	ffffffffc020625e <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02063a0:	000ab603          	ld	a2,0(s5)
ffffffffc02063a4:	0aa1                	addi	s5,s5,8
ffffffffc02063a6:	1c060663          	beqz	a2,ffffffffc0206572 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02063aa:	00160413          	addi	s0,a2,1
ffffffffc02063ae:	17b05c63          	blez	s11,ffffffffc0206526 <vprintfmt+0x302>
ffffffffc02063b2:	02d00593          	li	a1,45
ffffffffc02063b6:	14b79263          	bne	a5,a1,ffffffffc02064fa <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02063ba:	00064783          	lbu	a5,0(a2)
ffffffffc02063be:	0007851b          	sext.w	a0,a5
ffffffffc02063c2:	c905                	beqz	a0,ffffffffc02063f2 <vprintfmt+0x1ce>
ffffffffc02063c4:	000cc563          	bltz	s9,ffffffffc02063ce <vprintfmt+0x1aa>
ffffffffc02063c8:	3cfd                	addiw	s9,s9,-1
ffffffffc02063ca:	036c8263          	beq	s9,s6,ffffffffc02063ee <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02063ce:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02063d0:	18098463          	beqz	s3,ffffffffc0206558 <vprintfmt+0x334>
ffffffffc02063d4:	3781                	addiw	a5,a5,-32
ffffffffc02063d6:	18fbf163          	bleu	a5,s7,ffffffffc0206558 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02063da:	03f00513          	li	a0,63
ffffffffc02063de:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02063e0:	0405                	addi	s0,s0,1
ffffffffc02063e2:	fff44783          	lbu	a5,-1(s0)
ffffffffc02063e6:	3dfd                	addiw	s11,s11,-1
ffffffffc02063e8:	0007851b          	sext.w	a0,a5
ffffffffc02063ec:	fd61                	bnez	a0,ffffffffc02063c4 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02063ee:	e7b058e3          	blez	s11,ffffffffc020625e <vprintfmt+0x3a>
ffffffffc02063f2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02063f4:	85a6                	mv	a1,s1
ffffffffc02063f6:	02000513          	li	a0,32
ffffffffc02063fa:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02063fc:	e60d81e3          	beqz	s11,ffffffffc020625e <vprintfmt+0x3a>
ffffffffc0206400:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206402:	85a6                	mv	a1,s1
ffffffffc0206404:	02000513          	li	a0,32
ffffffffc0206408:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020640a:	fe0d94e3          	bnez	s11,ffffffffc02063f2 <vprintfmt+0x1ce>
ffffffffc020640e:	bd81                	j	ffffffffc020625e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206410:	4705                	li	a4,1
ffffffffc0206412:	008a8593          	addi	a1,s5,8
ffffffffc0206416:	01074463          	blt	a4,a6,ffffffffc020641e <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020641a:	12080063          	beqz	a6,ffffffffc020653a <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc020641e:	000ab603          	ld	a2,0(s5)
ffffffffc0206422:	46a9                	li	a3,10
ffffffffc0206424:	8aae                	mv	s5,a1
ffffffffc0206426:	b7bd                	j	ffffffffc0206394 <vprintfmt+0x170>
ffffffffc0206428:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc020642c:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206430:	846a                	mv	s0,s10
ffffffffc0206432:	b5ad                	j	ffffffffc020629c <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0206434:	85a6                	mv	a1,s1
ffffffffc0206436:	02500513          	li	a0,37
ffffffffc020643a:	9902                	jalr	s2
            break;
ffffffffc020643c:	b50d                	j	ffffffffc020625e <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc020643e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0206442:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206446:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206448:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020644a:	e40dd9e3          	bgez	s11,ffffffffc020629c <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020644e:	8de6                	mv	s11,s9
ffffffffc0206450:	5cfd                	li	s9,-1
ffffffffc0206452:	b5a9                	j	ffffffffc020629c <vprintfmt+0x78>
            goto reswitch;
ffffffffc0206454:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0206458:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020645c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020645e:	bd3d                	j	ffffffffc020629c <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0206460:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0206464:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206468:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020646a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020646e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206472:	fcd56ce3          	bltu	a0,a3,ffffffffc020644a <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0206476:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206478:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020647c:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206480:	0196873b          	addw	a4,a3,s9
ffffffffc0206484:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206488:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020648c:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0206490:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0206494:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206498:	fcd57fe3          	bleu	a3,a0,ffffffffc0206476 <vprintfmt+0x252>
ffffffffc020649c:	b77d                	j	ffffffffc020644a <vprintfmt+0x226>
            if (width < 0)
ffffffffc020649e:	fffdc693          	not	a3,s11
ffffffffc02064a2:	96fd                	srai	a3,a3,0x3f
ffffffffc02064a4:	00ddfdb3          	and	s11,s11,a3
ffffffffc02064a8:	00144603          	lbu	a2,1(s0)
ffffffffc02064ac:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064ae:	846a                	mv	s0,s10
ffffffffc02064b0:	b3f5                	j	ffffffffc020629c <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02064b2:	85a6                	mv	a1,s1
ffffffffc02064b4:	02500513          	li	a0,37
ffffffffc02064b8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02064ba:	fff44703          	lbu	a4,-1(s0)
ffffffffc02064be:	02500793          	li	a5,37
ffffffffc02064c2:	8d22                	mv	s10,s0
ffffffffc02064c4:	d8f70de3          	beq	a4,a5,ffffffffc020625e <vprintfmt+0x3a>
ffffffffc02064c8:	02500713          	li	a4,37
ffffffffc02064cc:	1d7d                	addi	s10,s10,-1
ffffffffc02064ce:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02064d2:	fee79de3          	bne	a5,a4,ffffffffc02064cc <vprintfmt+0x2a8>
ffffffffc02064d6:	b361                	j	ffffffffc020625e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02064d8:	00002617          	auipc	a2,0x2
ffffffffc02064dc:	7a860613          	addi	a2,a2,1960 # ffffffffc0208c80 <error_string+0x1a8>
ffffffffc02064e0:	85a6                	mv	a1,s1
ffffffffc02064e2:	854a                	mv	a0,s2
ffffffffc02064e4:	0ac000ef          	jal	ra,ffffffffc0206590 <printfmt>
ffffffffc02064e8:	bb9d                	j	ffffffffc020625e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02064ea:	00002617          	auipc	a2,0x2
ffffffffc02064ee:	78e60613          	addi	a2,a2,1934 # ffffffffc0208c78 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc02064f2:	00002417          	auipc	s0,0x2
ffffffffc02064f6:	78740413          	addi	s0,s0,1927 # ffffffffc0208c79 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064fa:	8532                	mv	a0,a2
ffffffffc02064fc:	85e6                	mv	a1,s9
ffffffffc02064fe:	e032                	sd	a2,0(sp)
ffffffffc0206500:	e43e                	sd	a5,8(sp)
ffffffffc0206502:	c0dff0ef          	jal	ra,ffffffffc020610e <strnlen>
ffffffffc0206506:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020650a:	6602                	ld	a2,0(sp)
ffffffffc020650c:	01b05d63          	blez	s11,ffffffffc0206526 <vprintfmt+0x302>
ffffffffc0206510:	67a2                	ld	a5,8(sp)
ffffffffc0206512:	2781                	sext.w	a5,a5
ffffffffc0206514:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0206516:	6522                	ld	a0,8(sp)
ffffffffc0206518:	85a6                	mv	a1,s1
ffffffffc020651a:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020651c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020651e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206520:	6602                	ld	a2,0(sp)
ffffffffc0206522:	fe0d9ae3          	bnez	s11,ffffffffc0206516 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206526:	00064783          	lbu	a5,0(a2)
ffffffffc020652a:	0007851b          	sext.w	a0,a5
ffffffffc020652e:	e8051be3          	bnez	a0,ffffffffc02063c4 <vprintfmt+0x1a0>
ffffffffc0206532:	b335                	j	ffffffffc020625e <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0206534:	000aa403          	lw	s0,0(s5)
ffffffffc0206538:	bbf1                	j	ffffffffc0206314 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020653a:	000ae603          	lwu	a2,0(s5)
ffffffffc020653e:	46a9                	li	a3,10
ffffffffc0206540:	8aae                	mv	s5,a1
ffffffffc0206542:	bd89                	j	ffffffffc0206394 <vprintfmt+0x170>
ffffffffc0206544:	000ae603          	lwu	a2,0(s5)
ffffffffc0206548:	46c1                	li	a3,16
ffffffffc020654a:	8aae                	mv	s5,a1
ffffffffc020654c:	b5a1                	j	ffffffffc0206394 <vprintfmt+0x170>
ffffffffc020654e:	000ae603          	lwu	a2,0(s5)
ffffffffc0206552:	46a1                	li	a3,8
ffffffffc0206554:	8aae                	mv	s5,a1
ffffffffc0206556:	bd3d                	j	ffffffffc0206394 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0206558:	9902                	jalr	s2
ffffffffc020655a:	b559                	j	ffffffffc02063e0 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020655c:	85a6                	mv	a1,s1
ffffffffc020655e:	02d00513          	li	a0,45
ffffffffc0206562:	e03e                	sd	a5,0(sp)
ffffffffc0206564:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0206566:	8ace                	mv	s5,s3
ffffffffc0206568:	40800633          	neg	a2,s0
ffffffffc020656c:	46a9                	li	a3,10
ffffffffc020656e:	6782                	ld	a5,0(sp)
ffffffffc0206570:	b515                	j	ffffffffc0206394 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0206572:	01b05663          	blez	s11,ffffffffc020657e <vprintfmt+0x35a>
ffffffffc0206576:	02d00693          	li	a3,45
ffffffffc020657a:	f6d798e3          	bne	a5,a3,ffffffffc02064ea <vprintfmt+0x2c6>
ffffffffc020657e:	00002417          	auipc	s0,0x2
ffffffffc0206582:	6fb40413          	addi	s0,s0,1787 # ffffffffc0208c79 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206586:	02800513          	li	a0,40
ffffffffc020658a:	02800793          	li	a5,40
ffffffffc020658e:	bd1d                	j	ffffffffc02063c4 <vprintfmt+0x1a0>

ffffffffc0206590 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206590:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206592:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206596:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206598:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020659a:	ec06                	sd	ra,24(sp)
ffffffffc020659c:	f83a                	sd	a4,48(sp)
ffffffffc020659e:	fc3e                	sd	a5,56(sp)
ffffffffc02065a0:	e0c2                	sd	a6,64(sp)
ffffffffc02065a2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02065a4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065a6:	c7fff0ef          	jal	ra,ffffffffc0206224 <vprintfmt>
}
ffffffffc02065aa:	60e2                	ld	ra,24(sp)
ffffffffc02065ac:	6161                	addi	sp,sp,80
ffffffffc02065ae:	8082                	ret

ffffffffc02065b0 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02065b0:	9e3707b7          	lui	a5,0x9e370
ffffffffc02065b4:	2785                	addiw	a5,a5,1
ffffffffc02065b6:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc02065ba:	02000793          	li	a5,32
ffffffffc02065be:	40b785bb          	subw	a1,a5,a1
}
ffffffffc02065c2:	00b5553b          	srlw	a0,a0,a1
ffffffffc02065c6:	8082                	ret
