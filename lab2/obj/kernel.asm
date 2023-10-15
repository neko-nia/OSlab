
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

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


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	58260613          	addi	a2,a2,1410 # ffffffffc02065c0 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	7fc010ef          	jal	ra,ffffffffc020184a <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	80a50513          	addi	a0,a0,-2038 # ffffffffc0201860 <etext+0x4>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	0a4010ef          	jal	ra,ffffffffc020110e <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	292010ef          	jal	ra,ffffffffc020133c <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	25e010ef          	jal	ra,ffffffffc020133c <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00001517          	auipc	a0,0x1
ffffffffc0200144:	77050513          	addi	a0,a0,1904 # ffffffffc02018b0 <etext+0x54>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00001517          	auipc	a0,0x1
ffffffffc020015a:	77a50513          	addi	a0,a0,1914 # ffffffffc02018d0 <etext+0x74>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	6fa58593          	addi	a1,a1,1786 # ffffffffc020185c <etext>
ffffffffc020016a:	00001517          	auipc	a0,0x1
ffffffffc020016e:	78650513          	addi	a0,a0,1926 # ffffffffc02018f0 <etext+0x94>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	79250513          	addi	a0,a0,1938 # ffffffffc0201910 <etext+0xb4>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	43658593          	addi	a1,a1,1078 # ffffffffc02065c0 <end>
ffffffffc0200192:	00001517          	auipc	a0,0x1
ffffffffc0200196:	79e50513          	addi	a0,a0,1950 # ffffffffc0201930 <etext+0xd4>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00007597          	auipc	a1,0x7
ffffffffc02001a2:	82158593          	addi	a1,a1,-2015 # ffffffffc02069bf <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00001517          	auipc	a0,0x1
ffffffffc02001c4:	79050513          	addi	a0,a0,1936 # ffffffffc0201950 <etext+0xf4>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00001617          	auipc	a2,0x1
ffffffffc02001d4:	6b060613          	addi	a2,a2,1712 # ffffffffc0201880 <etext+0x24>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	6bc50513          	addi	a0,a0,1724 # ffffffffc0201898 <etext+0x3c>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00002617          	auipc	a2,0x2
ffffffffc02001f0:	87460613          	addi	a2,a2,-1932 # ffffffffc0201a60 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	88c58593          	addi	a1,a1,-1908 # ffffffffc0201a80 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	88c50513          	addi	a0,a0,-1908 # ffffffffc0201a88 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	88e60613          	addi	a2,a2,-1906 # ffffffffc0201a98 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	8ae58593          	addi	a1,a1,-1874 # ffffffffc0201ac0 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	86e50513          	addi	a0,a0,-1938 # ffffffffc0201a88 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	8aa60613          	addi	a2,a2,-1878 # ffffffffc0201ad0 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	8c258593          	addi	a1,a1,-1854 # ffffffffc0201af0 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	85250513          	addi	a0,a0,-1966 # ffffffffc0201a88 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	75850513          	addi	a0,a0,1880 # ffffffffc02019c8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00001517          	auipc	a0,0x1
ffffffffc0200296:	75e50513          	addi	a0,a0,1886 # ffffffffc02019f0 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	6d8c8c93          	addi	s9,s9,1752 # ffffffffc0201980 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00001997          	auipc	s3,0x1
ffffffffc02002b4:	76898993          	addi	s3,s3,1896 # ffffffffc0201a18 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00001917          	auipc	s2,0x1
ffffffffc02002bc:	76890913          	addi	s2,s2,1896 # ffffffffc0201a20 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00001b17          	auipc	s6,0x1
ffffffffc02002c6:	766b0b13          	addi	s6,s6,1894 # ffffffffc0201a28 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00001a97          	auipc	s5,0x1
ffffffffc02002ce:	7b6a8a93          	addi	s5,s5,1974 # ffffffffc0201a80 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	3f2010ef          	jal	ra,ffffffffc02016c8 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	544010ef          	jal	ra,ffffffffc020182c <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00001d17          	auipc	s10,0x1
ffffffffc0200302:	682d0d13          	addi	s10,s10,1666 # ffffffffc0201980 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	4f6010ef          	jal	ra,ffffffffc0201802 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	4e2010ef          	jal	ra,ffffffffc0201802 <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	4a6010ef          	jal	ra,ffffffffc020182c <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	6aa50513          	addi	a0,a0,1706 # ffffffffc0201a48 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	04f72023          	sw	a5,64(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	72250513          	addi	a0,a0,1826 # ffffffffc0201b00 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00002517          	auipc	a0,0x2
ffffffffc02003f8:	c6c50513          	addi	a0,a0,-916 # ffffffffc0202060 <commands+0x6e0>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	37e010ef          	jal	ra,ffffffffc02017a2 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b723          	sd	zero,14(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	6ee50513          	addi	a0,a0,1774 # ffffffffc0201b20 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	3560106f          	j	ffffffffc02017a2 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	3300106f          	j	ffffffffc0201786 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	3640106f          	j	ffffffffc02017be <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00001517          	auipc	a0,0x1
ffffffffc0200488:	7b450513          	addi	a0,a0,1972 # ffffffffc0201c38 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00001517          	auipc	a0,0x1
ffffffffc0200498:	7bc50513          	addi	a0,a0,1980 # ffffffffc0201c50 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00001517          	auipc	a0,0x1
ffffffffc02004a6:	7c650513          	addi	a0,a0,1990 # ffffffffc0201c68 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00001517          	auipc	a0,0x1
ffffffffc02004b4:	7d050513          	addi	a0,a0,2000 # ffffffffc0201c80 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00001517          	auipc	a0,0x1
ffffffffc02004c2:	7da50513          	addi	a0,a0,2010 # ffffffffc0201c98 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00001517          	auipc	a0,0x1
ffffffffc02004d0:	7e450513          	addi	a0,a0,2020 # ffffffffc0201cb0 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00001517          	auipc	a0,0x1
ffffffffc02004de:	7ee50513          	addi	a0,a0,2030 # ffffffffc0201cc8 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00001517          	auipc	a0,0x1
ffffffffc02004ec:	7f850513          	addi	a0,a0,2040 # ffffffffc0201ce0 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	80250513          	addi	a0,a0,-2046 # ffffffffc0201cf8 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	80c50513          	addi	a0,a0,-2036 # ffffffffc0201d10 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	81650513          	addi	a0,a0,-2026 # ffffffffc0201d28 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	82050513          	addi	a0,a0,-2016 # ffffffffc0201d40 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	82a50513          	addi	a0,a0,-2006 # ffffffffc0201d58 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	83450513          	addi	a0,a0,-1996 # ffffffffc0201d70 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	83e50513          	addi	a0,a0,-1986 # ffffffffc0201d88 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	84850513          	addi	a0,a0,-1976 # ffffffffc0201da0 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	85250513          	addi	a0,a0,-1966 # ffffffffc0201db8 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	85c50513          	addi	a0,a0,-1956 # ffffffffc0201dd0 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	86650513          	addi	a0,a0,-1946 # ffffffffc0201de8 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	87050513          	addi	a0,a0,-1936 # ffffffffc0201e00 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	87a50513          	addi	a0,a0,-1926 # ffffffffc0201e18 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	88450513          	addi	a0,a0,-1916 # ffffffffc0201e30 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	88e50513          	addi	a0,a0,-1906 # ffffffffc0201e48 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	89850513          	addi	a0,a0,-1896 # ffffffffc0201e60 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	8a250513          	addi	a0,a0,-1886 # ffffffffc0201e78 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0201e90 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	8b650513          	addi	a0,a0,-1866 # ffffffffc0201ea8 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	8c050513          	addi	a0,a0,-1856 # ffffffffc0201ec0 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0201ed8 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	8d450513          	addi	a0,a0,-1836 # ffffffffc0201ef0 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	8de50513          	addi	a0,a0,-1826 # ffffffffc0201f08 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	8e450513          	addi	a0,a0,-1820 # ffffffffc0201f20 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	8e650513          	addi	a0,a0,-1818 # ffffffffc0201f38 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	8e650513          	addi	a0,a0,-1818 # ffffffffc0201f50 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0201f68 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0201f80 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0201f98 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	48070713          	addi	a4,a4,1152 # ffffffffc0201b3c <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	50250513          	addi	a0,a0,1282 # ffffffffc0201bd0 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	4d650513          	addi	a0,a0,1238 # ffffffffc0201bb0 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	48a50513          	addi	a0,a0,1162 # ffffffffc0201b70 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	4fe50513          	addi	a0,a0,1278 # ffffffffc0201bf0 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d3278793          	addi	a5,a5,-718 # ffffffffc0206438 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bf23          	sd	a5,-738(a3) # ffffffffc0206438 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	4ee50513          	addi	a0,a0,1262 # ffffffffc0201c18 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	45a50513          	addi	a0,a0,1114 # ffffffffc0201b90 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	4bc50513          	addi	a0,a0,1212 # ffffffffc0201c08 <commands+0x288>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <buddy_init>:
 *  ³õÊŒ»¯buddyœá¹¹Ìå
 */
static void
buddy_init(void) {
    // ³õÊŒ»¯ÁŽ±íÊý×éÖÐµÄÃ¿žöfree_listÍ·
    for (int i = 0; i < MAX_BUDDY_ORDER; i++) {
ffffffffc020082a:	00006797          	auipc	a5,0x6
ffffffffc020082e:	c1e78793          	addi	a5,a5,-994 # ffffffffc0206448 <buddy_s+0x8>
ffffffffc0200832:	00006717          	auipc	a4,0x6
ffffffffc0200836:	d5670713          	addi	a4,a4,-682 # ffffffffc0206588 <buddy_s+0x148>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020083a:	e79c                	sd	a5,8(a5)
ffffffffc020083c:	e39c                	sd	a5,0(a5)
ffffffffc020083e:	07c1                	addi	a5,a5,16
ffffffffc0200840:	fee79de3          	bne	a5,a4,ffffffffc020083a <buddy_init+0x10>
        list_init(buddy_array + i);
    }
    max_order = 0;
ffffffffc0200844:	00006797          	auipc	a5,0x6
ffffffffc0200848:	be07ae23          	sw	zero,-1028(a5) # ffffffffc0206440 <buddy_s>
    nr_free = 0;
ffffffffc020084c:	00006797          	auipc	a5,0x6
ffffffffc0200850:	d407a623          	sw	zero,-692(a5) # ffffffffc0206598 <buddy_s+0x158>
    return;
}
ffffffffc0200854:	8082                	ret

ffffffffc0200856 <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200856:	00006517          	auipc	a0,0x6
ffffffffc020085a:	d4256503          	lwu	a0,-702(a0) # ffffffffc0206598 <buddy_s+0x158>
ffffffffc020085e:	8082                	ret

ffffffffc0200860 <buddy_get_buddy>:
buddy_get_buddy(struct Page* page) {
ffffffffc0200860:	7179                	addi	sp,sp,-48
ffffffffc0200862:	e052                	sd	s4,0(sp)
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200864:	00006a17          	auipc	s4,0x6
ffffffffc0200868:	d54a0a13          	addi	s4,s4,-684 # ffffffffc02065b8 <pages>
ffffffffc020086c:	000a3583          	ld	a1,0(s4)
ffffffffc0200870:	00002797          	auipc	a5,0x2
ffffffffc0200874:	96078793          	addi	a5,a5,-1696 # ffffffffc02021d0 <commands+0x850>
ffffffffc0200878:	e44e                	sd	s3,8(sp)
ffffffffc020087a:	0007b983          	ld	s3,0(a5)
ffffffffc020087e:	40b505b3          	sub	a1,a0,a1
ffffffffc0200882:	858d                	srai	a1,a1,0x3
ffffffffc0200884:	033585b3          	mul	a1,a1,s3
ffffffffc0200888:	00002797          	auipc	a5,0x2
ffffffffc020088c:	e3078793          	addi	a5,a5,-464 # ffffffffc02026b8 <nbase>
ffffffffc0200890:	ec26                	sd	s1,24(sp)
ffffffffc0200892:	6384                	ld	s1,0(a5)
    unsigned int buddy_ppn = first_ppn + ((1 << order) ^ (page2ppn(page) - first_ppn));
ffffffffc0200894:	00006797          	auipc	a5,0x6
ffffffffc0200898:	b8478793          	addi	a5,a5,-1148 # ffffffffc0206418 <first_ppn>
    unsigned int order = page->property;
ffffffffc020089c:	4910                	lw	a2,16(a0)
buddy_get_buddy(struct Page* page) {
ffffffffc020089e:	f022                	sd	s0,32(sp)
    unsigned int buddy_ppn = first_ppn + ((1 << order) ^ (page2ppn(page) - first_ppn));
ffffffffc02008a0:	4380                	lw	s0,0(a5)
ffffffffc02008a2:	4785                	li	a5,1
ffffffffc02008a4:	00c797bb          	sllw	a5,a5,a2
ffffffffc02008a8:	95a6                	add	a1,a1,s1
ffffffffc02008aa:	4085873b          	subw	a4,a1,s0
ffffffffc02008ae:	8fb9                	xor	a5,a5,a4
ffffffffc02008b0:	9c3d                	addw	s0,s0,a5
buddy_get_buddy(struct Page* page) {
ffffffffc02008b2:	e84a                	sd	s2,16(sp)
    cprintf("[!]BS: Page NO.%d 's buddy page on order %d is: %d\n", page2ppn(page), order, buddy_ppn);
ffffffffc02008b4:	0004069b          	sext.w	a3,s0
buddy_get_buddy(struct Page* page) {
ffffffffc02008b8:	892a                	mv	s2,a0
    cprintf("[!]BS: Page NO.%d 's buddy page on order %d is: %d\n", page2ppn(page), order, buddy_ppn);
ffffffffc02008ba:	00002517          	auipc	a0,0x2
ffffffffc02008be:	91e50513          	addi	a0,a0,-1762 # ffffffffc02021d8 <commands+0x858>
buddy_get_buddy(struct Page* page) {
ffffffffc02008c2:	f406                	sd	ra,40(sp)
    cprintf("[!]BS: Page NO.%d 's buddy page on order %d is: %d\n", page2ppn(page), order, buddy_ppn);
ffffffffc02008c4:	ff2ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02008c8:	000a3783          	ld	a5,0(s4)
    if (buddy_ppn > page2ppn(page)) {
ffffffffc02008cc:	1402                	slli	s0,s0,0x20
ffffffffc02008ce:	9001                	srli	s0,s0,0x20
ffffffffc02008d0:	40f907b3          	sub	a5,s2,a5
ffffffffc02008d4:	878d                	srai	a5,a5,0x3
ffffffffc02008d6:	033787b3          	mul	a5,a5,s3
ffffffffc02008da:	97a6                	add	a5,a5,s1
ffffffffc02008dc:	0287f163          	bleu	s0,a5,ffffffffc02008fe <buddy_get_buddy+0x9e>
        return page + (buddy_ppn - page2ppn(page));
ffffffffc02008e0:	8c1d                	sub	s0,s0,a5
ffffffffc02008e2:	00241513          	slli	a0,s0,0x2
ffffffffc02008e6:	942a                	add	s0,s0,a0
ffffffffc02008e8:	00341513          	slli	a0,s0,0x3
}
ffffffffc02008ec:	70a2                	ld	ra,40(sp)
ffffffffc02008ee:	7402                	ld	s0,32(sp)
        return page + (buddy_ppn - page2ppn(page));
ffffffffc02008f0:	954a                	add	a0,a0,s2
}
ffffffffc02008f2:	64e2                	ld	s1,24(sp)
ffffffffc02008f4:	6942                	ld	s2,16(sp)
ffffffffc02008f6:	69a2                	ld	s3,8(sp)
ffffffffc02008f8:	6a02                	ld	s4,0(sp)
ffffffffc02008fa:	6145                	addi	sp,sp,48
ffffffffc02008fc:	8082                	ret
        return page - (page2ppn(page) - buddy_ppn);
ffffffffc02008fe:	40878433          	sub	s0,a5,s0
ffffffffc0200902:	00241513          	slli	a0,s0,0x2
ffffffffc0200906:	942a                	add	s0,s0,a0
ffffffffc0200908:	00341513          	slli	a0,s0,0x3
}
ffffffffc020090c:	70a2                	ld	ra,40(sp)
ffffffffc020090e:	7402                	ld	s0,32(sp)
        return page - (page2ppn(page) - buddy_ppn);
ffffffffc0200910:	40a90533          	sub	a0,s2,a0
}
ffffffffc0200914:	64e2                	ld	s1,24(sp)
ffffffffc0200916:	6942                	ld	s2,16(sp)
ffffffffc0200918:	69a2                	ld	s3,8(sp)
ffffffffc020091a:	6a02                	ld	s4,0(sp)
ffffffffc020091c:	6145                	addi	sp,sp,48
ffffffffc020091e:	8082                	ret

ffffffffc0200920 <show_buddy_array>:
show_buddy_array(void) {
ffffffffc0200920:	715d                	addi	sp,sp,-80
    cprintf("[!]BS: Printing buddy array:\n");
ffffffffc0200922:	00002517          	auipc	a0,0x2
ffffffffc0200926:	9b650513          	addi	a0,a0,-1610 # ffffffffc02022d8 <buddy_pmm_manager+0x38>
show_buddy_array(void) {
ffffffffc020092a:	ec56                	sd	s5,24(sp)
ffffffffc020092c:	e486                	sd	ra,72(sp)
ffffffffc020092e:	e0a2                	sd	s0,64(sp)
ffffffffc0200930:	fc26                	sd	s1,56(sp)
ffffffffc0200932:	f84a                	sd	s2,48(sp)
ffffffffc0200934:	f44e                	sd	s3,40(sp)
ffffffffc0200936:	f052                	sd	s4,32(sp)
ffffffffc0200938:	e85a                	sd	s6,16(sp)
ffffffffc020093a:	e45e                	sd	s7,8(sp)
    for (int i = 0; i < max_order + 1; i++) {
ffffffffc020093c:	00006a97          	auipc	s5,0x6
ffffffffc0200940:	b04a8a93          	addi	s5,s5,-1276 # ffffffffc0206440 <buddy_s>
    cprintf("[!]BS: Printing buddy array:\n");
ffffffffc0200944:	f72ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    for (int i = 0; i < max_order + 1; i++) {
ffffffffc0200948:	000aa703          	lw	a4,0(s5)
ffffffffc020094c:	57fd                	li	a5,-1
ffffffffc020094e:	04f70f63          	beq	a4,a5,ffffffffc02009ac <show_buddy_array+0x8c>
ffffffffc0200952:	00006497          	auipc	s1,0x6
ffffffffc0200956:	af648493          	addi	s1,s1,-1290 # ffffffffc0206448 <buddy_s+0x8>
ffffffffc020095a:	4a01                	li	s4,0
        cprintf("%d layer: ", i);
ffffffffc020095c:	00002b97          	auipc	s7,0x2
ffffffffc0200960:	99cb8b93          	addi	s7,s7,-1636 # ffffffffc02022f8 <buddy_pmm_manager+0x58>
            cprintf("%d ", 1 << (p->property));
ffffffffc0200964:	4985                	li	s3,1
ffffffffc0200966:	00002917          	auipc	s2,0x2
ffffffffc020096a:	9a290913          	addi	s2,s2,-1630 # ffffffffc0202308 <buddy_pmm_manager+0x68>
        cprintf("\n");
ffffffffc020096e:	00001b17          	auipc	s6,0x1
ffffffffc0200972:	6f2b0b13          	addi	s6,s6,1778 # ffffffffc0202060 <commands+0x6e0>
        cprintf("%d layer: ", i);
ffffffffc0200976:	85d2                	mv	a1,s4
ffffffffc0200978:	855e                	mv	a0,s7
ffffffffc020097a:	f3cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020097e:	6480                	ld	s0,8(s1)
        while ((le = list_next(le)) != &(buddy_array[i])) {
ffffffffc0200980:	00848c63          	beq	s1,s0,ffffffffc0200998 <show_buddy_array+0x78>
            cprintf("%d ", 1 << (p->property));
ffffffffc0200984:	ff842583          	lw	a1,-8(s0)
ffffffffc0200988:	854a                	mv	a0,s2
ffffffffc020098a:	00b995bb          	sllw	a1,s3,a1
ffffffffc020098e:	f28ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200992:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != &(buddy_array[i])) {
ffffffffc0200994:	fe9418e3          	bne	s0,s1,ffffffffc0200984 <show_buddy_array+0x64>
        cprintf("\n");
ffffffffc0200998:	855a                	mv	a0,s6
ffffffffc020099a:	f1cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    for (int i = 0; i < max_order + 1; i++) {
ffffffffc020099e:	000aa783          	lw	a5,0(s5)
ffffffffc02009a2:	2a05                	addiw	s4,s4,1
ffffffffc02009a4:	04c1                	addi	s1,s1,16
ffffffffc02009a6:	2785                	addiw	a5,a5,1
ffffffffc02009a8:	fcfa67e3          	bltu	s4,a5,ffffffffc0200976 <show_buddy_array+0x56>
}
ffffffffc02009ac:	6406                	ld	s0,64(sp)
ffffffffc02009ae:	60a6                	ld	ra,72(sp)
ffffffffc02009b0:	74e2                	ld	s1,56(sp)
ffffffffc02009b2:	7942                	ld	s2,48(sp)
ffffffffc02009b4:	79a2                	ld	s3,40(sp)
ffffffffc02009b6:	7a02                	ld	s4,32(sp)
ffffffffc02009b8:	6ae2                	ld	s5,24(sp)
ffffffffc02009ba:	6b42                	ld	s6,16(sp)
ffffffffc02009bc:	6ba2                	ld	s7,8(sp)
    cprintf("---------------------------\n");
ffffffffc02009be:	00002517          	auipc	a0,0x2
ffffffffc02009c2:	95250513          	addi	a0,a0,-1710 # ffffffffc0202310 <buddy_pmm_manager+0x70>
}
ffffffffc02009c6:	6161                	addi	sp,sp,80
    cprintf("---------------------------\n");
ffffffffc02009c8:	eeeff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02009cc <buddy_init_memmap>:
buddy_init_memmap(struct Page* base, size_t n) {
ffffffffc02009cc:	1101                	addi	sp,sp,-32
ffffffffc02009ce:	ec06                	sd	ra,24(sp)
ffffffffc02009d0:	e822                	sd	s0,16(sp)
ffffffffc02009d2:	e426                	sd	s1,8(sp)
ffffffffc02009d4:	e04a                	sd	s2,0(sp)
    assert(n > 0);
ffffffffc02009d6:	cdf9                	beqz	a1,ffffffffc0200ab4 <buddy_init_memmap+0xe8>
    if (n & (n - 1)) {
ffffffffc02009d8:	fff58793          	addi	a5,a1,-1
ffffffffc02009dc:	8fed                	and	a5,a5,a1
ffffffffc02009de:	842e                	mv	s0,a1
ffffffffc02009e0:	892a                	mv	s2,a0
ffffffffc02009e2:	cb99                	beqz	a5,ffffffffc02009f8 <buddy_init_memmap+0x2c>
    size_t res = 1;
ffffffffc02009e4:	4785                	li	a5,1
ffffffffc02009e6:	a011                	j	ffffffffc02009ea <buddy_init_memmap+0x1e>
            res = res << 1;
ffffffffc02009e8:	87ba                	mv	a5,a4
            n = n >> 1;
ffffffffc02009ea:	8005                	srli	s0,s0,0x1
            res = res << 1;
ffffffffc02009ec:	00179713          	slli	a4,a5,0x1
        while (n) {
ffffffffc02009f0:	fc65                	bnez	s0,ffffffffc02009e8 <buddy_init_memmap+0x1c>
        return res >> 1;
ffffffffc02009f2:	547d                	li	s0,-1
ffffffffc02009f4:	8005                	srli	s0,s0,0x1
ffffffffc02009f6:	8c7d                	and	s0,s0,a5
    while (n >> 1) {
ffffffffc02009f8:	00145793          	srli	a5,s0,0x1
    unsigned int order = 0;
ffffffffc02009fc:	4481                	li	s1,0
    while (n >> 1) {
ffffffffc02009fe:	c781                	beqz	a5,ffffffffc0200a06 <buddy_init_memmap+0x3a>
ffffffffc0200a00:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc0200a02:	2485                	addiw	s1,s1,1
    while (n >> 1) {
ffffffffc0200a04:	fff5                	bnez	a5,ffffffffc0200a00 <buddy_init_memmap+0x34>
    cprintf("[!]BS: AVA Page num after rounding down to powers of 2: %d = 2^%d\n", pnum, order);
ffffffffc0200a06:	8626                	mv	a2,s1
ffffffffc0200a08:	85a2                	mv	a1,s0
ffffffffc0200a0a:	00002517          	auipc	a0,0x2
ffffffffc0200a0e:	83e50513          	addi	a0,a0,-1986 # ffffffffc0202248 <commands+0x8c8>
ffffffffc0200a12:	ea4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    for (; p != base + pnum; p++) {
ffffffffc0200a16:	00241693          	slli	a3,s0,0x2
ffffffffc0200a1a:	96a2                	add	a3,a3,s0
ffffffffc0200a1c:	068e                	slli	a3,a3,0x3
ffffffffc0200a1e:	96ca                	add	a3,a3,s2
ffffffffc0200a20:	02d90563          	beq	s2,a3,ffffffffc0200a4a <buddy_init_memmap+0x7e>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a24:	00893783          	ld	a5,8(s2)
        assert(PageReserved(p));
ffffffffc0200a28:	8b85                	andi	a5,a5,1
ffffffffc0200a2a:	c7ad                	beqz	a5,ffffffffc0200a94 <buddy_init_memmap+0xc8>
ffffffffc0200a2c:	87ca                	mv	a5,s2
        p->property = -1;   // È«²¿³õÊŒ»¯Îª·ÇÍ·Ò³
ffffffffc0200a2e:	567d                	li	a2,-1
ffffffffc0200a30:	a021                	j	ffffffffc0200a38 <buddy_init_memmap+0x6c>
ffffffffc0200a32:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200a34:	8b05                	andi	a4,a4,1
ffffffffc0200a36:	cf39                	beqz	a4,ffffffffc0200a94 <buddy_init_memmap+0xc8>
        p->flags = 0;
ffffffffc0200a38:	0007b423          	sd	zero,8(a5)
        p->property = -1;   // È«²¿³õÊŒ»¯Îª·ÇÍ·Ò³
ffffffffc0200a3c:	cb90                	sw	a2,16(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200a3e:	0007a023          	sw	zero,0(a5)
    for (; p != base + pnum; p++) {
ffffffffc0200a42:	02878793          	addi	a5,a5,40
ffffffffc0200a46:	fed796e3          	bne	a5,a3,ffffffffc0200a32 <buddy_init_memmap+0x66>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a4a:	02049793          	slli	a5,s1,0x20
ffffffffc0200a4e:	9381                	srli	a5,a5,0x20
    max_order = order;
ffffffffc0200a50:	00006697          	auipc	a3,0x6
ffffffffc0200a54:	9f068693          	addi	a3,a3,-1552 # ffffffffc0206440 <buddy_s>
ffffffffc0200a58:	0792                	slli	a5,a5,0x4
ffffffffc0200a5a:	00f68633          	add	a2,a3,a5
ffffffffc0200a5e:	6a18                	ld	a4,16(a2)
    nr_free = pnum;
ffffffffc0200a60:	00006597          	auipc	a1,0x6
ffffffffc0200a64:	b285ac23          	sw	s0,-1224(a1) # ffffffffc0206598 <buddy_s+0x158>
    list_add(&(buddy_array[max_order]), &(base->page_link)); // œ«µÚÒ»Ò³base²åÈëÊý×éµÄ×îºóÒ»žöÁŽ±í£¬×÷Îª³õÊŒ»¯µÄ×îŽó¿é¡ª¡ª16384,µÄÍ·Ò³
ffffffffc0200a68:	01890593          	addi	a1,s2,24
    max_order = order;
ffffffffc0200a6c:	00006517          	auipc	a0,0x6
ffffffffc0200a70:	9c952a23          	sw	s1,-1580(a0) # ffffffffc0206440 <buddy_s>
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200a74:	e30c                	sd	a1,0(a4)
}
ffffffffc0200a76:	60e2                	ld	ra,24(sp)
ffffffffc0200a78:	6442                	ld	s0,16(sp)
    list_add(&(buddy_array[max_order]), &(base->page_link)); // œ«µÚÒ»Ò³base²åÈëÊý×éµÄ×îºóÒ»žöÁŽ±í£¬×÷Îª³õÊŒ»¯µÄ×îŽó¿é¡ª¡ª16384,µÄÍ·Ò³
ffffffffc0200a7a:	07a1                	addi	a5,a5,8
ffffffffc0200a7c:	ea0c                	sd	a1,16(a2)
ffffffffc0200a7e:	97b6                	add	a5,a5,a3
    base->property = max_order;                       // œ«µÚÒ»Ò³baseµÄpropertyÉèÎª×îŽó¿éµÄ2ÃÝ
ffffffffc0200a80:	00992823          	sw	s1,16(s2)
    elm->next = next;
ffffffffc0200a84:	02e93023          	sd	a4,32(s2)
    elm->prev = prev;
ffffffffc0200a88:	00f93c23          	sd	a5,24(s2)
}
ffffffffc0200a8c:	64a2                	ld	s1,8(sp)
ffffffffc0200a8e:	6902                	ld	s2,0(sp)
ffffffffc0200a90:	6105                	addi	sp,sp,32
ffffffffc0200a92:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200a94:	00001697          	auipc	a3,0x1
ffffffffc0200a98:	7fc68693          	addi	a3,a3,2044 # ffffffffc0202290 <commands+0x910>
ffffffffc0200a9c:	00001617          	auipc	a2,0x1
ffffffffc0200aa0:	77c60613          	addi	a2,a2,1916 # ffffffffc0202218 <commands+0x898>
ffffffffc0200aa4:	07600593          	li	a1,118
ffffffffc0200aa8:	00001517          	auipc	a0,0x1
ffffffffc0200aac:	78850513          	addi	a0,a0,1928 # ffffffffc0202230 <commands+0x8b0>
ffffffffc0200ab0:	8fdff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200ab4:	00001697          	auipc	a3,0x1
ffffffffc0200ab8:	75c68693          	addi	a3,a3,1884 # ffffffffc0202210 <commands+0x890>
ffffffffc0200abc:	00001617          	auipc	a2,0x1
ffffffffc0200ac0:	75c60613          	addi	a2,a2,1884 # ffffffffc0202218 <commands+0x898>
ffffffffc0200ac4:	06c00593          	li	a1,108
ffffffffc0200ac8:	00001517          	auipc	a0,0x1
ffffffffc0200acc:	76850513          	addi	a0,a0,1896 # ffffffffc0202230 <commands+0x8b0>
ffffffffc0200ad0:	8ddff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ad4 <buddy_free_pages>:
buddy_free_pages(struct Page* base, size_t n) {
ffffffffc0200ad4:	715d                	addi	sp,sp,-80
ffffffffc0200ad6:	e486                	sd	ra,72(sp)
ffffffffc0200ad8:	e0a2                	sd	s0,64(sp)
ffffffffc0200ada:	fc26                	sd	s1,56(sp)
ffffffffc0200adc:	f84a                	sd	s2,48(sp)
ffffffffc0200ade:	f44e                	sd	s3,40(sp)
ffffffffc0200ae0:	f052                	sd	s4,32(sp)
ffffffffc0200ae2:	ec56                	sd	s5,24(sp)
ffffffffc0200ae4:	e85a                	sd	s6,16(sp)
ffffffffc0200ae6:	e45e                	sd	s7,8(sp)
ffffffffc0200ae8:	e062                	sd	s8,0(sp)
    assert(n > 0);
ffffffffc0200aea:	18058463          	beqz	a1,ffffffffc0200c72 <buddy_free_pages+0x19e>
    unsigned int pnum = 1 << (base->property);
ffffffffc0200aee:	4918                	lw	a4,16(a0)
    if (n & (n - 1)) {
ffffffffc0200af0:	fff58793          	addi	a5,a1,-1
    unsigned int pnum = 1 << (base->property);
ffffffffc0200af4:	4a85                	li	s5,1
ffffffffc0200af6:	00ea9abb          	sllw	s5,s5,a4
    if (n & (n - 1)) {
ffffffffc0200afa:	8fed                	and	a5,a5,a1
ffffffffc0200afc:	842a                	mv	s0,a0
    unsigned int pnum = 1 << (base->property);
ffffffffc0200afe:	000a861b          	sext.w	a2,s5
    if (n & (n - 1)) {
ffffffffc0200b02:	16079263          	bnez	a5,ffffffffc0200c66 <buddy_free_pages+0x192>
    assert(ROUNDUP2(n) == pnum);
ffffffffc0200b06:	020a9793          	slli	a5,s5,0x20
ffffffffc0200b0a:	9381                	srli	a5,a5,0x20
ffffffffc0200b0c:	18b79363          	bne	a5,a1,ffffffffc0200c92 <buddy_free_pages+0x1be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b10:	00006797          	auipc	a5,0x6
ffffffffc0200b14:	aa878793          	addi	a5,a5,-1368 # ffffffffc02065b8 <pages>
ffffffffc0200b18:	639c                	ld	a5,0(a5)
ffffffffc0200b1a:	00001717          	auipc	a4,0x1
ffffffffc0200b1e:	6b670713          	addi	a4,a4,1718 # ffffffffc02021d0 <commands+0x850>
ffffffffc0200b22:	630c                	ld	a1,0(a4)
ffffffffc0200b24:	40f407b3          	sub	a5,s0,a5
ffffffffc0200b28:	878d                	srai	a5,a5,0x3
ffffffffc0200b2a:	02b787b3          	mul	a5,a5,a1
ffffffffc0200b2e:	00002717          	auipc	a4,0x2
ffffffffc0200b32:	b8a70713          	addi	a4,a4,-1142 # ffffffffc02026b8 <nbase>
    cprintf("[!]BS: Freeing NO.%d page leading %d pages block: \n", page2ppn(base), pnum);
ffffffffc0200b36:	630c                	ld	a1,0(a4)
ffffffffc0200b38:	00001517          	auipc	a0,0x1
ffffffffc0200b3c:	5f050513          	addi	a0,a0,1520 # ffffffffc0202128 <commands+0x7a8>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b40:	00006497          	auipc	s1,0x6
ffffffffc0200b44:	90048493          	addi	s1,s1,-1792 # ffffffffc0206440 <buddy_s>
    list_add(&(buddy_array[left_block->property]), &(left_block->page_link));
ffffffffc0200b48:	01840913          	addi	s2,s0,24
ffffffffc0200b4c:	00840993          	addi	s3,s0,8
    cprintf("[!]BS: Freeing NO.%d page leading %d pages block: \n", page2ppn(base), pnum);
ffffffffc0200b50:	95be                	add	a1,a1,a5
ffffffffc0200b52:	d64ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    buddy = buddy_get_buddy(left_block);
ffffffffc0200b56:	8522                	mv	a0,s0
ffffffffc0200b58:	d09ff0ef          	jal	ra,ffffffffc0200860 <buddy_get_buddy>
ffffffffc0200b5c:	01046783          	lwu	a5,16(s0)
ffffffffc0200b60:	8c2a                	mv	s8,a0
    cprintf("[!]BS: add to list\n");
ffffffffc0200b62:	00001517          	auipc	a0,0x1
ffffffffc0200b66:	5fe50513          	addi	a0,a0,1534 # ffffffffc0202160 <commands+0x7e0>
ffffffffc0200b6a:	0792                	slli	a5,a5,0x4
ffffffffc0200b6c:	00f486b3          	add	a3,s1,a5
ffffffffc0200b70:	6a98                	ld	a4,16(a3)
    list_add(&(buddy_array[left_block->property]), &(left_block->page_link));
ffffffffc0200b72:	07a1                	addi	a5,a5,8
ffffffffc0200b74:	97a6                	add	a5,a5,s1
    prev->next = next->prev = elm;
ffffffffc0200b76:	01273023          	sd	s2,0(a4)
ffffffffc0200b7a:	0126b823          	sd	s2,16(a3)
    elm->prev = prev;
ffffffffc0200b7e:	ec1c                	sd	a5,24(s0)
    elm->next = next;
ffffffffc0200b80:	f018                	sd	a4,32(s0)
    cprintf("[!]BS: add to list\n");
ffffffffc0200b82:	d34ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    show_buddy_array();
ffffffffc0200b86:	d9bff0ef          	jal	ra,ffffffffc0200920 <show_buddy_array>
ffffffffc0200b8a:	008c3783          	ld	a5,8(s8)
ffffffffc0200b8e:	8385                	srli	a5,a5,0x1
    while (PageProperty(buddy) && left_block->property < max_order) {
ffffffffc0200b90:	8b85                	andi	a5,a5,1
ffffffffc0200b92:	c7c1                	beqz	a5,ffffffffc0200c1a <buddy_free_pages+0x146>
ffffffffc0200b94:	4818                	lw	a4,16(s0)
ffffffffc0200b96:	409c                	lw	a5,0(s1)
ffffffffc0200b98:	08f77163          	bleu	a5,a4,ffffffffc0200c1a <buddy_free_pages+0x146>
        cprintf("[!]BS: Buddy free, MERGING!\n");
ffffffffc0200b9c:	00001a17          	auipc	s4,0x1
ffffffffc0200ba0:	5dca0a13          	addi	s4,s4,1500 # ffffffffc0202178 <commands+0x7f8>
            left_block->property = -1;
ffffffffc0200ba4:	5bfd                	li	s7,-1
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ba6:	4b09                	li	s6,2
ffffffffc0200ba8:	a029                	j	ffffffffc0200bb2 <buddy_free_pages+0xde>
    while (PageProperty(buddy) && left_block->property < max_order) {
ffffffffc0200baa:	4818                	lw	a4,16(s0)
ffffffffc0200bac:	409c                	lw	a5,0(s1)
ffffffffc0200bae:	06f77663          	bleu	a5,a4,ffffffffc0200c1a <buddy_free_pages+0x146>
        cprintf("[!]BS: Buddy free, MERGING!\n");
ffffffffc0200bb2:	8552                	mv	a0,s4
ffffffffc0200bb4:	d02ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        if (left_block > buddy) { // Èôµ±Ç°×ó¿éÎªžüŽó¿éµÄÓÒ¿é
ffffffffc0200bb8:	008c7d63          	bleu	s0,s8,ffffffffc0200bd2 <buddy_free_pages+0xfe>
            left_block->property = -1;
ffffffffc0200bbc:	01742823          	sw	s7,16(s0)
ffffffffc0200bc0:	4169b02f          	amoor.d	zero,s6,(s3)
ffffffffc0200bc4:	87a2                	mv	a5,s0
ffffffffc0200bc6:	008c0993          	addi	s3,s8,8
ffffffffc0200bca:	8462                	mv	s0,s8
ffffffffc0200bcc:	018c0913          	addi	s2,s8,24
ffffffffc0200bd0:	8c3e                	mv	s8,a5
    __list_del(listelm->prev, listelm->next);
ffffffffc0200bd2:	6c14                	ld	a3,24(s0)
ffffffffc0200bd4:	701c                	ld	a5,32(s0)
        left_block->property += 1;
ffffffffc0200bd6:	4818                	lw	a4,16(s0)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200bd8:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200bda:	e394                	sd	a3,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200bdc:	018c3503          	ld	a0,24(s8)
ffffffffc0200be0:	020c3583          	ld	a1,32(s8)
ffffffffc0200be4:	2705                	addiw	a4,a4,1
    __list_add(elm, listelm, listelm->next);
ffffffffc0200be6:	02071793          	slli	a5,a4,0x20
ffffffffc0200bea:	83f1                	srli	a5,a5,0x1c
    prev->next = next;
ffffffffc0200bec:	e50c                	sd	a1,8(a0)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200bee:	00f48633          	add	a2,s1,a5
ffffffffc0200bf2:	6a14                	ld	a3,16(a2)
    next->prev = prev;
ffffffffc0200bf4:	e188                	sd	a0,0(a1)
ffffffffc0200bf6:	c818                	sw	a4,16(s0)
    prev->next = next->prev = elm;
ffffffffc0200bf8:	0126b023          	sd	s2,0(a3)
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // Í·²åÈëÏàÓŠÁŽ±í
ffffffffc0200bfc:	07a1                	addi	a5,a5,8
ffffffffc0200bfe:	01263823          	sd	s2,16(a2)
ffffffffc0200c02:	97a6                	add	a5,a5,s1
    elm->prev = prev;
ffffffffc0200c04:	ec1c                	sd	a5,24(s0)
    elm->next = next;
ffffffffc0200c06:	f014                	sd	a3,32(s0)
        show_buddy_array();
ffffffffc0200c08:	d19ff0ef          	jal	ra,ffffffffc0200920 <show_buddy_array>
        buddy = buddy_get_buddy(left_block);
ffffffffc0200c0c:	8522                	mv	a0,s0
ffffffffc0200c0e:	c53ff0ef          	jal	ra,ffffffffc0200860 <buddy_get_buddy>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200c12:	651c                	ld	a5,8(a0)
ffffffffc0200c14:	8c2a                	mv	s8,a0
    while (PageProperty(buddy) && left_block->property < max_order) {
ffffffffc0200c16:	8b89                	andi	a5,a5,2
ffffffffc0200c18:	fbc9                	bnez	a5,ffffffffc0200baa <buddy_free_pages+0xd6>
    cprintf("[!]BS: Buddy array after FREE:\n");
ffffffffc0200c1a:	00001517          	auipc	a0,0x1
ffffffffc0200c1e:	57e50513          	addi	a0,a0,1406 # ffffffffc0202198 <commands+0x818>
ffffffffc0200c22:	c94ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200c26:	4789                	li	a5,2
ffffffffc0200c28:	40f9b02f          	amoor.d	zero,a5,(s3)
    nr_free += pnum;
ffffffffc0200c2c:	1584a783          	lw	a5,344(s1)
ffffffffc0200c30:	01578abb          	addw	s5,a5,s5
ffffffffc0200c34:	00006797          	auipc	a5,0x6
ffffffffc0200c38:	9757a223          	sw	s5,-1692(a5) # ffffffffc0206598 <buddy_s+0x158>
    show_buddy_array();
ffffffffc0200c3c:	ce5ff0ef          	jal	ra,ffffffffc0200920 <show_buddy_array>
}
ffffffffc0200c40:	6406                	ld	s0,64(sp)
    cprintf("[!]BS: nr_free: %d\n", nr_free);
ffffffffc0200c42:	1584a583          	lw	a1,344(s1)
}
ffffffffc0200c46:	60a6                	ld	ra,72(sp)
ffffffffc0200c48:	74e2                	ld	s1,56(sp)
ffffffffc0200c4a:	7942                	ld	s2,48(sp)
ffffffffc0200c4c:	79a2                	ld	s3,40(sp)
ffffffffc0200c4e:	7a02                	ld	s4,32(sp)
ffffffffc0200c50:	6ae2                	ld	s5,24(sp)
ffffffffc0200c52:	6b42                	ld	s6,16(sp)
ffffffffc0200c54:	6ba2                	ld	s7,8(sp)
ffffffffc0200c56:	6c02                	ld	s8,0(sp)
    cprintf("[!]BS: nr_free: %d\n", nr_free);
ffffffffc0200c58:	00001517          	auipc	a0,0x1
ffffffffc0200c5c:	56050513          	addi	a0,a0,1376 # ffffffffc02021b8 <commands+0x838>
}
ffffffffc0200c60:	6161                	addi	sp,sp,80
    cprintf("[!]BS: nr_free: %d\n", nr_free);
ffffffffc0200c62:	c54ff06f          	j	ffffffffc02000b6 <cprintf>
    size_t res = 1;
ffffffffc0200c66:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200c68:	8185                	srli	a1,a1,0x1
            res = res << 1;
ffffffffc0200c6a:	0786                	slli	a5,a5,0x1
        while (n) {
ffffffffc0200c6c:	fdf5                	bnez	a1,ffffffffc0200c68 <buddy_free_pages+0x194>
            res = res << 1;
ffffffffc0200c6e:	85be                	mv	a1,a5
ffffffffc0200c70:	bd59                	j	ffffffffc0200b06 <buddy_free_pages+0x32>
    assert(n > 0);
ffffffffc0200c72:	00001697          	auipc	a3,0x1
ffffffffc0200c76:	59e68693          	addi	a3,a3,1438 # ffffffffc0202210 <commands+0x890>
ffffffffc0200c7a:	00001617          	auipc	a2,0x1
ffffffffc0200c7e:	59e60613          	addi	a2,a2,1438 # ffffffffc0202218 <commands+0x898>
ffffffffc0200c82:	0cb00593          	li	a1,203
ffffffffc0200c86:	00001517          	auipc	a0,0x1
ffffffffc0200c8a:	5aa50513          	addi	a0,a0,1450 # ffffffffc0202230 <commands+0x8b0>
ffffffffc0200c8e:	f1eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(ROUNDUP2(n) == pnum);
ffffffffc0200c92:	00001697          	auipc	a3,0x1
ffffffffc0200c96:	47e68693          	addi	a3,a3,1150 # ffffffffc0202110 <commands+0x790>
ffffffffc0200c9a:	00001617          	auipc	a2,0x1
ffffffffc0200c9e:	57e60613          	addi	a2,a2,1406 # ffffffffc0202218 <commands+0x898>
ffffffffc0200ca2:	0cd00593          	li	a1,205
ffffffffc0200ca6:	00001517          	auipc	a0,0x1
ffffffffc0200caa:	58a50513          	addi	a0,a0,1418 # ffffffffc0202230 <commands+0x8b0>
ffffffffc0200cae:	efeff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200cb2 <basic_check>:


static void
basic_check(void) {
ffffffffc0200cb2:	1101                	addi	sp,sp,-32
    struct Page* p0, * p1, * p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cb4:	4505                	li	a0,1
basic_check(void) {
ffffffffc0200cb6:	ec06                	sd	ra,24(sp)
ffffffffc0200cb8:	e822                	sd	s0,16(sp)
ffffffffc0200cba:	e426                	sd	s1,8(sp)
ffffffffc0200cbc:	e04a                	sd	s2,0(sp)
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cbe:	3c6000ef          	jal	ra,ffffffffc0201084 <alloc_pages>
ffffffffc0200cc2:	cd0d                	beqz	a0,ffffffffc0200cfc <basic_check+0x4a>
ffffffffc0200cc4:	842a                	mv	s0,a0
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cc6:	4505                	li	a0,1
ffffffffc0200cc8:	3bc000ef          	jal	ra,ffffffffc0201084 <alloc_pages>
ffffffffc0200ccc:	892a                	mv	s2,a0
ffffffffc0200cce:	c53d                	beqz	a0,ffffffffc0200d3c <basic_check+0x8a>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cd0:	4505                	li	a0,1
ffffffffc0200cd2:	3b2000ef          	jal	ra,ffffffffc0201084 <alloc_pages>
ffffffffc0200cd6:	84aa                	mv	s1,a0
ffffffffc0200cd8:	c131                	beqz	a0,ffffffffc0200d1c <basic_check+0x6a>
    free_page(p0);
ffffffffc0200cda:	8522                	mv	a0,s0
ffffffffc0200cdc:	4585                	li	a1,1
ffffffffc0200cde:	3ea000ef          	jal	ra,ffffffffc02010c8 <free_pages>
    free_page(p1);
ffffffffc0200ce2:	854a                	mv	a0,s2
ffffffffc0200ce4:	4585                	li	a1,1
ffffffffc0200ce6:	3e2000ef          	jal	ra,ffffffffc02010c8 <free_pages>
    free_pages(p1, 3);
    

    show_buddy_array();*/
    
}
ffffffffc0200cea:	6442                	ld	s0,16(sp)
ffffffffc0200cec:	60e2                	ld	ra,24(sp)
ffffffffc0200cee:	6902                	ld	s2,0(sp)
    free_page(p2);
ffffffffc0200cf0:	8526                	mv	a0,s1
}
ffffffffc0200cf2:	64a2                	ld	s1,8(sp)
    free_page(p2);
ffffffffc0200cf4:	4585                	li	a1,1
}
ffffffffc0200cf6:	6105                	addi	sp,sp,32
    free_page(p2);
ffffffffc0200cf8:	3d00006f          	j	ffffffffc02010c8 <free_pages>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cfc:	00001697          	auipc	a3,0x1
ffffffffc0200d00:	2b468693          	addi	a3,a3,692 # ffffffffc0201fb0 <commands+0x630>
ffffffffc0200d04:	00001617          	auipc	a2,0x1
ffffffffc0200d08:	51460613          	addi	a2,a2,1300 # ffffffffc0202218 <commands+0x898>
ffffffffc0200d0c:	0fb00593          	li	a1,251
ffffffffc0200d10:	00001517          	auipc	a0,0x1
ffffffffc0200d14:	52050513          	addi	a0,a0,1312 # ffffffffc0202230 <commands+0x8b0>
ffffffffc0200d18:	e94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d1c:	00001697          	auipc	a3,0x1
ffffffffc0200d20:	2d468693          	addi	a3,a3,724 # ffffffffc0201ff0 <commands+0x670>
ffffffffc0200d24:	00001617          	auipc	a2,0x1
ffffffffc0200d28:	4f460613          	addi	a2,a2,1268 # ffffffffc0202218 <commands+0x898>
ffffffffc0200d2c:	0fd00593          	li	a1,253
ffffffffc0200d30:	00001517          	auipc	a0,0x1
ffffffffc0200d34:	50050513          	addi	a0,a0,1280 # ffffffffc0202230 <commands+0x8b0>
ffffffffc0200d38:	e74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d3c:	00001697          	auipc	a3,0x1
ffffffffc0200d40:	29468693          	addi	a3,a3,660 # ffffffffc0201fd0 <commands+0x650>
ffffffffc0200d44:	00001617          	auipc	a2,0x1
ffffffffc0200d48:	4d460613          	addi	a2,a2,1236 # ffffffffc0202218 <commands+0x898>
ffffffffc0200d4c:	0fc00593          	li	a1,252
ffffffffc0200d50:	00001517          	auipc	a0,0x1
ffffffffc0200d54:	4e050513          	addi	a0,a0,1248 # ffffffffc0202230 <commands+0x8b0>
ffffffffc0200d58:	e54ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200d5c <buddy_alloc_pages>:
buddy_alloc_pages(size_t n) {
ffffffffc0200d5c:	7131                	addi	sp,sp,-192
ffffffffc0200d5e:	fd06                	sd	ra,184(sp)
ffffffffc0200d60:	f922                	sd	s0,176(sp)
ffffffffc0200d62:	f526                	sd	s1,168(sp)
ffffffffc0200d64:	f14a                	sd	s2,160(sp)
ffffffffc0200d66:	ed4e                	sd	s3,152(sp)
ffffffffc0200d68:	e952                	sd	s4,144(sp)
ffffffffc0200d6a:	e556                	sd	s5,136(sp)
ffffffffc0200d6c:	e15a                	sd	s6,128(sp)
ffffffffc0200d6e:	fcde                	sd	s7,120(sp)
ffffffffc0200d70:	f8e2                	sd	s8,112(sp)
ffffffffc0200d72:	f4e6                	sd	s9,104(sp)
ffffffffc0200d74:	f0ea                	sd	s10,96(sp)
ffffffffc0200d76:	ecee                	sd	s11,88(sp)
    assert(n > 0);
ffffffffc0200d78:	2a050663          	beqz	a0,ffffffffc0201024 <buddy_alloc_pages+0x2c8>
    if (n > nr_free) {
ffffffffc0200d7c:	00006797          	auipc	a5,0x6
ffffffffc0200d80:	81c7e783          	lwu	a5,-2020(a5) # ffffffffc0206598 <buddy_s+0x158>
ffffffffc0200d84:	26a7ea63          	bltu	a5,a0,ffffffffc0200ff8 <buddy_alloc_pages+0x29c>
    if (n & (n - 1)) {
ffffffffc0200d88:	fff50793          	addi	a5,a0,-1
ffffffffc0200d8c:	8fe9                	and	a5,a5,a0
ffffffffc0200d8e:	892a                	mv	s2,a0
ffffffffc0200d90:	24079e63          	bnez	a5,ffffffffc0200fec <buddy_alloc_pages+0x290>
    while (n >> 1) {
ffffffffc0200d94:	00195693          	srli	a3,s2,0x1
ffffffffc0200d98:	26068263          	beqz	a3,ffffffffc0200ffc <buddy_alloc_pages+0x2a0>
    unsigned int order = 0;
ffffffffc0200d9c:	4481                	li	s1,0
    while (n >> 1) {
ffffffffc0200d9e:	8285                	srli	a3,a3,0x1
        order++;
ffffffffc0200da0:	2485                	addiw	s1,s1,1
    while (n >> 1) {
ffffffffc0200da2:	fef5                	bnez	a3,ffffffffc0200d9e <buddy_alloc_pages+0x42>
ffffffffc0200da4:	02049693          	slli	a3,s1,0x20
ffffffffc0200da8:	9281                	srli	a3,a3,0x20
ffffffffc0200daa:	00469a93          	slli	s5,a3,0x4
ffffffffc0200dae:	008a8413          	addi	s0,s5,8
    cprintf("[!]BS: Allocating %d-->%d = 2^%d pages ...\n", n, pnum, order);
ffffffffc0200db2:	85aa                	mv	a1,a0
ffffffffc0200db4:	864a                	mv	a2,s2
ffffffffc0200db6:	00001517          	auipc	a0,0x1
ffffffffc0200dba:	25a50513          	addi	a0,a0,602 # ffffffffc0202010 <commands+0x690>
ffffffffc0200dbe:	af8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("[!]BS: Buddy array before ALLOC:\n");
ffffffffc0200dc2:	00001517          	auipc	a0,0x1
ffffffffc0200dc6:	27e50513          	addi	a0,a0,638 # ffffffffc0202040 <commands+0x6c0>
ffffffffc0200dca:	aecff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return list->next == list;
ffffffffc0200dce:	00005997          	auipc	s3,0x5
ffffffffc0200dd2:	67298993          	addi	s3,s3,1650 # ffffffffc0206440 <buddy_s>
    show_buddy_array();
ffffffffc0200dd6:	b4bff0ef          	jal	ra,ffffffffc0200920 <show_buddy_array>
ffffffffc0200dda:	9ace                	add	s5,s5,s3
ffffffffc0200ddc:	010abe03          	ld	t3,16(s5)
    if (!list_empty(&(buddy_array[order]))) {
ffffffffc0200de0:	008987b3          	add	a5,s3,s0
ffffffffc0200de4:	22fe1063          	bne	t3,a5,ffffffffc0201004 <buddy_alloc_pages+0x2a8>
        for (int i = order; i < max_order + 1; i++) {
ffffffffc0200de8:	00048d9b          	sext.w	s11,s1
            if (!list_empty(&(buddy_array[i]))) {
ffffffffc0200dec:	004d9b93          	slli	s7,s11,0x4
ffffffffc0200df0:	002d8b13          	addi	s6,s11,2
ffffffffc0200df4:	008b8813          	addi	a6,s7,8
ffffffffc0200df8:	0b12                	slli	s6,s6,0x4
ffffffffc0200dfa:	984e                	add	a6,a6,s3
ffffffffc0200dfc:	9b4e                	add	s6,s6,s3
ffffffffc0200dfe:	9bce                	add	s7,s7,s3
ffffffffc0200e00:	001d831b          	addiw	t1,s11,1
ffffffffc0200e04:	00002c97          	auipc	s9,0x2
ffffffffc0200e08:	8b4c8c93          	addi	s9,s9,-1868 # ffffffffc02026b8 <nbase>
ffffffffc0200e0c:	00005c17          	auipc	s8,0x5
ffffffffc0200e10:	7acc0c13          	addi	s8,s8,1964 # ffffffffc02065b8 <pages>
ffffffffc0200e14:	00001a17          	auipc	s4,0x1
ffffffffc0200e18:	3bca0a13          	addi	s4,s4,956 # ffffffffc02021d0 <commands+0x850>
ffffffffc0200e1c:	88d6                	mv	a7,s5
        for (int i = order; i < max_order + 1; i++) {
ffffffffc0200e1e:	0009a503          	lw	a0,0(s3)
ffffffffc0200e22:	0015059b          	addiw	a1,a0,1
ffffffffc0200e26:	02b4f663          	bleu	a1,s1,ffffffffc0200e52 <buddy_alloc_pages+0xf6>
            if (!list_empty(&(buddy_array[i]))) {
ffffffffc0200e2a:	010bb783          	ld	a5,16(s7)
ffffffffc0200e2e:	07079163          	bne	a5,a6,ffffffffc0200e90 <buddy_alloc_pages+0x134>
ffffffffc0200e32:	841a                	mv	s0,t1
ffffffffc0200e34:	87da                	mv	a5,s6
ffffffffc0200e36:	a811                	j	ffffffffc0200e4a <buddy_alloc_pages+0xee>
ffffffffc0200e38:	6394                	ld	a3,0(a5)
ffffffffc0200e3a:	ff878713          	addi	a4,a5,-8
ffffffffc0200e3e:	00140613          	addi	a2,s0,1
ffffffffc0200e42:	07c1                	addi	a5,a5,16
ffffffffc0200e44:	04e69763          	bne	a3,a4,ffffffffc0200e92 <buddy_alloc_pages+0x136>
ffffffffc0200e48:	8432                	mv	s0,a2
        for (int i = order; i < max_order + 1; i++) {
ffffffffc0200e4a:	0004071b          	sext.w	a4,s0
ffffffffc0200e4e:	feb765e3          	bltu	a4,a1,ffffffffc0200e38 <buddy_alloc_pages+0xdc>
    struct Page* page = NULL;
ffffffffc0200e52:	4401                	li	s0,0
    nr_free -= pnum;
ffffffffc0200e54:	1589a783          	lw	a5,344(s3)
    cprintf("[!]BS: nr_free: %d\n", nr_free);
ffffffffc0200e58:	00001517          	auipc	a0,0x1
ffffffffc0200e5c:	36050513          	addi	a0,a0,864 # ffffffffc02021b8 <commands+0x838>
    nr_free -= pnum;
ffffffffc0200e60:	412785bb          	subw	a1,a5,s2
ffffffffc0200e64:	00005797          	auipc	a5,0x5
ffffffffc0200e68:	72b7aa23          	sw	a1,1844(a5) # ffffffffc0206598 <buddy_s+0x158>
    cprintf("[!]BS: nr_free: %d\n", nr_free);
ffffffffc0200e6c:	a4aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
}
ffffffffc0200e70:	8522                	mv	a0,s0
ffffffffc0200e72:	70ea                	ld	ra,184(sp)
ffffffffc0200e74:	744a                	ld	s0,176(sp)
ffffffffc0200e76:	74aa                	ld	s1,168(sp)
ffffffffc0200e78:	790a                	ld	s2,160(sp)
ffffffffc0200e7a:	69ea                	ld	s3,152(sp)
ffffffffc0200e7c:	6a4a                	ld	s4,144(sp)
ffffffffc0200e7e:	6aaa                	ld	s5,136(sp)
ffffffffc0200e80:	6b0a                	ld	s6,128(sp)
ffffffffc0200e82:	7be6                	ld	s7,120(sp)
ffffffffc0200e84:	7c46                	ld	s8,112(sp)
ffffffffc0200e86:	7ca6                	ld	s9,104(sp)
ffffffffc0200e88:	7d06                	ld	s10,96(sp)
ffffffffc0200e8a:	6de6                	ld	s11,88(sp)
ffffffffc0200e8c:	6129                	addi	sp,sp,192
ffffffffc0200e8e:	8082                	ret
            if (!list_empty(&(buddy_array[i]))) {
ffffffffc0200e90:	846e                	mv	s0,s11
    assert(n > 0 && n <= max_order);
ffffffffc0200e92:	1a040963          	beqz	s0,ffffffffc0201044 <buddy_alloc_pages+0x2e8>
ffffffffc0200e96:	1502                	slli	a0,a0,0x20
ffffffffc0200e98:	9101                	srli	a0,a0,0x20
ffffffffc0200e9a:	1a856563          	bltu	a0,s0,ffffffffc0201044 <buddy_alloc_pages+0x2e8>
    assert(!list_empty(&(buddy_array[n])));
ffffffffc0200e9e:	00441793          	slli	a5,s0,0x4
ffffffffc0200ea2:	00f98d33          	add	s10,s3,a5
ffffffffc0200ea6:	010d3703          	ld	a4,16(s10)
ffffffffc0200eaa:	07a1                	addi	a5,a5,8
ffffffffc0200eac:	97ce                	add	a5,a5,s3
ffffffffc0200eae:	1af70b63          	beq	a4,a5,ffffffffc0201064 <buddy_alloc_pages+0x308>
    cprintf("[!]BS: SPLITTING!\n");
ffffffffc0200eb2:	00001517          	auipc	a0,0x1
ffffffffc0200eb6:	21e50513          	addi	a0,a0,542 # ffffffffc02020d0 <commands+0x750>
ffffffffc0200eba:	f846                	sd	a7,48(sp)
ffffffffc0200ebc:	f41a                	sd	t1,40(sp)
ffffffffc0200ebe:	f042                	sd	a6,32(sp)
ffffffffc0200ec0:	ec72                	sd	t3,24(sp)
ffffffffc0200ec2:	9f4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    page_b = page_a + (1 << (n - 1));
ffffffffc0200ec6:	fff4059b          	addiw	a1,s0,-1
ffffffffc0200eca:	4785                	li	a5,1
    return listelm->next;
ffffffffc0200ecc:	010d3703          	ld	a4,16(s10)
ffffffffc0200ed0:	00b796bb          	sllw	a3,a5,a1
ffffffffc0200ed4:	00269793          	slli	a5,a3,0x2
ffffffffc0200ed8:	97b6                	add	a5,a5,a3
ffffffffc0200eda:	078e                	slli	a5,a5,0x3
    page_a = le2page(list_next(&(buddy_array[n])), page_link);
ffffffffc0200edc:	fe870693          	addi	a3,a4,-24
    page_b = page_a + (1 << (n - 1));
ffffffffc0200ee0:	00f68ab3          	add	s5,a3,a5
    page_a->property = n - 1;
ffffffffc0200ee4:	feb72c23          	sw	a1,-8(a4)
    page_b->property = n - 1;
ffffffffc0200ee8:	00baa823          	sw	a1,16(s5)
ffffffffc0200eec:	ff070793          	addi	a5,a4,-16
ffffffffc0200ef0:	4589                	li	a1,2
ffffffffc0200ef2:	e83a                	sd	a4,16(sp)
ffffffffc0200ef4:	40b7b02f          	amoor.d	zero,a1,(a5)
ffffffffc0200ef8:	008a8793          	addi	a5,s5,8
ffffffffc0200efc:	40b7b02f          	amoor.d	zero,a1,(a5)
ffffffffc0200f00:	000c3583          	ld	a1,0(s8)
ffffffffc0200f04:	000a3f83          	ld	t6,0(s4)
ffffffffc0200f08:	000cb783          	ld	a5,0(s9)
ffffffffc0200f0c:	40b685b3          	sub	a1,a3,a1
ffffffffc0200f10:	858d                	srai	a1,a1,0x3
ffffffffc0200f12:	03f585b3          	mul	a1,a1,t6
    cprintf("%d\n",page2ppn(page_a));
ffffffffc0200f16:	00001517          	auipc	a0,0x1
ffffffffc0200f1a:	2b250513          	addi	a0,a0,690 # ffffffffc02021c8 <commands+0x848>
ffffffffc0200f1e:	e43e                	sd	a5,8(sp)
ffffffffc0200f20:	e4e6                	sd	s9,72(sp)
ffffffffc0200f22:	fc62                	sd	s8,56(sp)
ffffffffc0200f24:	e0d2                	sd	s4,64(sp)
    list_add(&(buddy_array[n - 1]), &(page_a->page_link));
ffffffffc0200f26:	147d                	addi	s0,s0,-1
    __list_add(elm, listelm, listelm->next);
ffffffffc0200f28:	0412                	slli	s0,s0,0x4
    cprintf("%d\n",page2ppn(page_a));
ffffffffc0200f2a:	95be                	add	a1,a1,a5
ffffffffc0200f2c:	98aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200f30:	000c3583          	ld	a1,0(s8)
ffffffffc0200f34:	00001797          	auipc	a5,0x1
ffffffffc0200f38:	29c78793          	addi	a5,a5,668 # ffffffffc02021d0 <commands+0x850>
ffffffffc0200f3c:	0007bf83          	ld	t6,0(a5)
ffffffffc0200f40:	40ba85b3          	sub	a1,s5,a1
ffffffffc0200f44:	858d                	srai	a1,a1,0x3
ffffffffc0200f46:	03f585b3          	mul	a1,a1,t6
    cprintf("%d\n",page2ppn(page_b));
ffffffffc0200f4a:	67a2                	ld	a5,8(sp)
ffffffffc0200f4c:	00001517          	auipc	a0,0x1
ffffffffc0200f50:	27c50513          	addi	a0,a0,636 # ffffffffc02021c8 <commands+0x848>
ffffffffc0200f54:	95be                	add	a1,a1,a5
ffffffffc0200f56:	960ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return listelm->next;
ffffffffc0200f5a:	010d3683          	ld	a3,16(s10)
    prev->next = next->prev = elm;
ffffffffc0200f5e:	6742                	ld	a4,16(sp)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200f60:	00898633          	add	a2,s3,s0
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f64:	628c                	ld	a1,0(a3)
ffffffffc0200f66:	6694                	ld	a3,8(a3)
    list_add(&(buddy_array[n - 1]), &(page_a->page_link));
ffffffffc0200f68:	0421                	addi	s0,s0,8
ffffffffc0200f6a:	944e                	add	s0,s0,s3
    prev->next = next;
ffffffffc0200f6c:	e594                	sd	a3,8(a1)
    next->prev = prev;
ffffffffc0200f6e:	e28c                	sd	a1,0(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200f70:	6a14                	ld	a3,16(a2)
    prev->next = next->prev = elm;
ffffffffc0200f72:	ea18                	sd	a4,16(a2)
    elm->prev = prev;
ffffffffc0200f74:	e300                	sd	s0,0(a4)
    list_add(&(page_a->page_link), &(page_b->page_link));
ffffffffc0200f76:	018a8613          	addi	a2,s5,24
    prev->next = next->prev = elm;
ffffffffc0200f7a:	e290                	sd	a2,0(a3)
ffffffffc0200f7c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0200f7e:	02dab023          	sd	a3,32(s5)
    elm->prev = prev;
ffffffffc0200f82:	00eabc23          	sd	a4,24(s5)
                cprintf("[!]BS: Buddy array after SPLITT:\n");
ffffffffc0200f86:	00001517          	auipc	a0,0x1
ffffffffc0200f8a:	16250513          	addi	a0,a0,354 # ffffffffc02020e8 <commands+0x768>
ffffffffc0200f8e:	928ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
                show_buddy_array();
ffffffffc0200f92:	98fff0ef          	jal	ra,ffffffffc0200920 <show_buddy_array>
    return list->next == list;
ffffffffc0200f96:	78c2                	ld	a7,48(sp)
    if (!list_empty(&(buddy_array[order]))) {
ffffffffc0200f98:	6e62                	ld	t3,24(sp)
ffffffffc0200f9a:	7802                	ld	a6,32(sp)
ffffffffc0200f9c:	0108b783          	ld	a5,16(a7)
ffffffffc0200fa0:	7322                	ld	t1,40(sp)
ffffffffc0200fa2:	e7c78ee3          	beq	a5,t3,ffffffffc0200e1e <buddy_alloc_pages+0xc2>
ffffffffc0200fa6:	8e3e                	mv	t3,a5
    __list_del(listelm->prev, listelm->next);
ffffffffc0200fa8:	000e3703          	ld	a4,0(t3)
ffffffffc0200fac:	008e3783          	ld	a5,8(t3)
        page = le2page(list_next(&(buddy_array[order])), page_link);
ffffffffc0200fb0:	fe8e0413          	addi	s0,t3,-24
    prev->next = next;
ffffffffc0200fb4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200fb6:	e398                	sd	a4,0(a5)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200fb8:	57f5                	li	a5,-3
ffffffffc0200fba:	ff0e0713          	addi	a4,t3,-16
ffffffffc0200fbe:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc0200fc2:	77e2                	ld	a5,56(sp)
ffffffffc0200fc4:	6706                	ld	a4,64(sp)
ffffffffc0200fc6:	66a6                	ld	a3,72(sp)
ffffffffc0200fc8:	639c                	ld	a5,0(a5)
ffffffffc0200fca:	6318                	ld	a4,0(a4)
ffffffffc0200fcc:	628c                	ld	a1,0(a3)
ffffffffc0200fce:	40f407b3          	sub	a5,s0,a5
ffffffffc0200fd2:	878d                	srai	a5,a5,0x3
ffffffffc0200fd4:	02e787b3          	mul	a5,a5,a4
        cprintf("[!]BS: Buddy array after ALLOC NO.%d page:\n", page2ppn(page));
ffffffffc0200fd8:	00001517          	auipc	a0,0x1
ffffffffc0200fdc:	09050513          	addi	a0,a0,144 # ffffffffc0202068 <commands+0x6e8>
ffffffffc0200fe0:	95be                	add	a1,a1,a5
ffffffffc0200fe2:	8d4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        show_buddy_array();
ffffffffc0200fe6:	93bff0ef          	jal	ra,ffffffffc0200920 <show_buddy_array>
        goto done;
ffffffffc0200fea:	b5ad                	j	ffffffffc0200e54 <buddy_alloc_pages+0xf8>
    if (n & (n - 1)) {
ffffffffc0200fec:	87aa                	mv	a5,a0
    size_t res = 1;
ffffffffc0200fee:	4905                	li	s2,1
            n = n >> 1;
ffffffffc0200ff0:	8385                	srli	a5,a5,0x1
            res = res << 1;
ffffffffc0200ff2:	0906                	slli	s2,s2,0x1
        while (n) {
ffffffffc0200ff4:	fff5                	bnez	a5,ffffffffc0200ff0 <buddy_alloc_pages+0x294>
ffffffffc0200ff6:	bb79                	j	ffffffffc0200d94 <buddy_alloc_pages+0x38>
        return NULL;
ffffffffc0200ff8:	4401                	li	s0,0
ffffffffc0200ffa:	bd9d                	j	ffffffffc0200e70 <buddy_alloc_pages+0x114>
    while (n >> 1) {
ffffffffc0200ffc:	4421                	li	s0,8
    unsigned int order = 0;
ffffffffc0200ffe:	4481                	li	s1,0
ffffffffc0201000:	4a81                	li	s5,0
ffffffffc0201002:	bb45                	j	ffffffffc0200db2 <buddy_alloc_pages+0x56>
ffffffffc0201004:	00005797          	auipc	a5,0x5
ffffffffc0201008:	5b478793          	addi	a5,a5,1460 # ffffffffc02065b8 <pages>
ffffffffc020100c:	fc3e                	sd	a5,56(sp)
ffffffffc020100e:	00001797          	auipc	a5,0x1
ffffffffc0201012:	1c278793          	addi	a5,a5,450 # ffffffffc02021d0 <commands+0x850>
ffffffffc0201016:	e0be                	sd	a5,64(sp)
ffffffffc0201018:	00001797          	auipc	a5,0x1
ffffffffc020101c:	6a078793          	addi	a5,a5,1696 # ffffffffc02026b8 <nbase>
ffffffffc0201020:	e4be                	sd	a5,72(sp)
ffffffffc0201022:	b759                	j	ffffffffc0200fa8 <buddy_alloc_pages+0x24c>
    assert(n > 0);
ffffffffc0201024:	00001697          	auipc	a3,0x1
ffffffffc0201028:	1ec68693          	addi	a3,a3,492 # ffffffffc0202210 <commands+0x890>
ffffffffc020102c:	00001617          	auipc	a2,0x1
ffffffffc0201030:	1ec60613          	addi	a2,a2,492 # ffffffffc0202218 <commands+0x898>
ffffffffc0201034:	09e00593          	li	a1,158
ffffffffc0201038:	00001517          	auipc	a0,0x1
ffffffffc020103c:	1f850513          	addi	a0,a0,504 # ffffffffc0202230 <commands+0x8b0>
ffffffffc0201040:	b6cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0 && n <= max_order);
ffffffffc0201044:	00001697          	auipc	a3,0x1
ffffffffc0201048:	05468693          	addi	a3,a3,84 # ffffffffc0202098 <commands+0x718>
ffffffffc020104c:	00001617          	auipc	a2,0x1
ffffffffc0201050:	1cc60613          	addi	a2,a2,460 # ffffffffc0202218 <commands+0x898>
ffffffffc0201054:	08600593          	li	a1,134
ffffffffc0201058:	00001517          	auipc	a0,0x1
ffffffffc020105c:	1d850513          	addi	a0,a0,472 # ffffffffc0202230 <commands+0x8b0>
ffffffffc0201060:	b4cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&(buddy_array[n])));
ffffffffc0201064:	00001697          	auipc	a3,0x1
ffffffffc0201068:	04c68693          	addi	a3,a3,76 # ffffffffc02020b0 <commands+0x730>
ffffffffc020106c:	00001617          	auipc	a2,0x1
ffffffffc0201070:	1ac60613          	addi	a2,a2,428 # ffffffffc0202218 <commands+0x898>
ffffffffc0201074:	08700593          	li	a1,135
ffffffffc0201078:	00001517          	auipc	a0,0x1
ffffffffc020107c:	1b850513          	addi	a0,a0,440 # ffffffffc0202230 <commands+0x8b0>
ffffffffc0201080:	b2cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201084 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201084:	100027f3          	csrr	a5,sstatus
ffffffffc0201088:	8b89                	andi	a5,a5,2
ffffffffc020108a:	eb89                	bnez	a5,ffffffffc020109c <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020108c:	00005797          	auipc	a5,0x5
ffffffffc0201090:	51c78793          	addi	a5,a5,1308 # ffffffffc02065a8 <pmm_manager>
ffffffffc0201094:	639c                	ld	a5,0(a5)
ffffffffc0201096:	0187b303          	ld	t1,24(a5)
ffffffffc020109a:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc020109c:	1141                	addi	sp,sp,-16
ffffffffc020109e:	e406                	sd	ra,8(sp)
ffffffffc02010a0:	e022                	sd	s0,0(sp)
ffffffffc02010a2:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02010a4:	bc0ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02010a8:	00005797          	auipc	a5,0x5
ffffffffc02010ac:	50078793          	addi	a5,a5,1280 # ffffffffc02065a8 <pmm_manager>
ffffffffc02010b0:	639c                	ld	a5,0(a5)
ffffffffc02010b2:	8522                	mv	a0,s0
ffffffffc02010b4:	6f9c                	ld	a5,24(a5)
ffffffffc02010b6:	9782                	jalr	a5
ffffffffc02010b8:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02010ba:	ba4ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02010be:	8522                	mv	a0,s0
ffffffffc02010c0:	60a2                	ld	ra,8(sp)
ffffffffc02010c2:	6402                	ld	s0,0(sp)
ffffffffc02010c4:	0141                	addi	sp,sp,16
ffffffffc02010c6:	8082                	ret

ffffffffc02010c8 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02010c8:	100027f3          	csrr	a5,sstatus
ffffffffc02010cc:	8b89                	andi	a5,a5,2
ffffffffc02010ce:	eb89                	bnez	a5,ffffffffc02010e0 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02010d0:	00005797          	auipc	a5,0x5
ffffffffc02010d4:	4d878793          	addi	a5,a5,1240 # ffffffffc02065a8 <pmm_manager>
ffffffffc02010d8:	639c                	ld	a5,0(a5)
ffffffffc02010da:	0207b303          	ld	t1,32(a5)
ffffffffc02010de:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc02010e0:	1101                	addi	sp,sp,-32
ffffffffc02010e2:	ec06                	sd	ra,24(sp)
ffffffffc02010e4:	e822                	sd	s0,16(sp)
ffffffffc02010e6:	e426                	sd	s1,8(sp)
ffffffffc02010e8:	842a                	mv	s0,a0
ffffffffc02010ea:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02010ec:	b78ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02010f0:	00005797          	auipc	a5,0x5
ffffffffc02010f4:	4b878793          	addi	a5,a5,1208 # ffffffffc02065a8 <pmm_manager>
ffffffffc02010f8:	639c                	ld	a5,0(a5)
ffffffffc02010fa:	85a6                	mv	a1,s1
ffffffffc02010fc:	8522                	mv	a0,s0
ffffffffc02010fe:	739c                	ld	a5,32(a5)
ffffffffc0201100:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201102:	6442                	ld	s0,16(sp)
ffffffffc0201104:	60e2                	ld	ra,24(sp)
ffffffffc0201106:	64a2                	ld	s1,8(sp)
ffffffffc0201108:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020110a:	b54ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc020110e <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc020110e:	00001797          	auipc	a5,0x1
ffffffffc0201112:	19278793          	addi	a5,a5,402 # ffffffffc02022a0 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201116:	638c                	ld	a1,0(a5)
        first_ppn=mem_begin/PGSIZE;
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201118:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020111a:	00001517          	auipc	a0,0x1
ffffffffc020111e:	22e50513          	addi	a0,a0,558 # ffffffffc0202348 <buddy_pmm_manager+0xa8>
void pmm_init(void) {
ffffffffc0201122:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201124:	00005717          	auipc	a4,0x5
ffffffffc0201128:	48f73223          	sd	a5,1156(a4) # ffffffffc02065a8 <pmm_manager>
void pmm_init(void) {
ffffffffc020112c:	e426                	sd	s1,8(sp)
ffffffffc020112e:	e822                	sd	s0,16(sp)
ffffffffc0201130:	e04a                	sd	s2,0(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201132:	00005497          	auipc	s1,0x5
ffffffffc0201136:	47648493          	addi	s1,s1,1142 # ffffffffc02065a8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020113a:	f7dfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc020113e:	609c                	ld	a5,0(s1)
ffffffffc0201140:	679c                	ld	a5,8(a5)
ffffffffc0201142:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201144:	57f5                	li	a5,-3
ffffffffc0201146:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201148:	00001517          	auipc	a0,0x1
ffffffffc020114c:	21850513          	addi	a0,a0,536 # ffffffffc0202360 <buddy_pmm_manager+0xc0>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201150:	00005717          	auipc	a4,0x5
ffffffffc0201154:	46f73023          	sd	a5,1120(a4) # ffffffffc02065b0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201158:	f5ffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020115c:	46c5                	li	a3,17
ffffffffc020115e:	06ee                	slli	a3,a3,0x1b
ffffffffc0201160:	40100613          	li	a2,1025
ffffffffc0201164:	16fd                	addi	a3,a3,-1
ffffffffc0201166:	0656                	slli	a2,a2,0x15
ffffffffc0201168:	07e005b7          	lui	a1,0x7e00
ffffffffc020116c:	00001517          	auipc	a0,0x1
ffffffffc0201170:	20c50513          	addi	a0,a0,524 # ffffffffc0202378 <buddy_pmm_manager+0xd8>
ffffffffc0201174:	f43fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201178:	777d                	lui	a4,0xfffff
ffffffffc020117a:	00006797          	auipc	a5,0x6
ffffffffc020117e:	44578793          	addi	a5,a5,1093 # ffffffffc02075bf <end+0xfff>
ffffffffc0201182:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201184:	00088737          	lui	a4,0x88
ffffffffc0201188:	00005697          	auipc	a3,0x5
ffffffffc020118c:	28e6bc23          	sd	a4,664(a3) # ffffffffc0206420 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201190:	4601                	li	a2,0
ffffffffc0201192:	00005717          	auipc	a4,0x5
ffffffffc0201196:	42f73323          	sd	a5,1062(a4) # ffffffffc02065b8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020119a:	4681                	li	a3,0
ffffffffc020119c:	00005897          	auipc	a7,0x5
ffffffffc02011a0:	28488893          	addi	a7,a7,644 # ffffffffc0206420 <npage>
ffffffffc02011a4:	00005597          	auipc	a1,0x5
ffffffffc02011a8:	41458593          	addi	a1,a1,1044 # ffffffffc02065b8 <pages>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02011ac:	4805                	li	a6,1
ffffffffc02011ae:	fff80537          	lui	a0,0xfff80
ffffffffc02011b2:	a011                	j	ffffffffc02011b6 <pmm_init+0xa8>
ffffffffc02011b4:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc02011b6:	97b2                	add	a5,a5,a2
ffffffffc02011b8:	07a1                	addi	a5,a5,8
ffffffffc02011ba:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011be:	0008b703          	ld	a4,0(a7)
ffffffffc02011c2:	0685                	addi	a3,a3,1
ffffffffc02011c4:	02860613          	addi	a2,a2,40
ffffffffc02011c8:	00a707b3          	add	a5,a4,a0
ffffffffc02011cc:	fef6e4e3          	bltu	a3,a5,ffffffffc02011b4 <pmm_init+0xa6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011d0:	6190                	ld	a2,0(a1)
ffffffffc02011d2:	00271793          	slli	a5,a4,0x2
ffffffffc02011d6:	97ba                	add	a5,a5,a4
ffffffffc02011d8:	fec006b7          	lui	a3,0xfec00
ffffffffc02011dc:	078e                	slli	a5,a5,0x3
ffffffffc02011de:	96b2                	add	a3,a3,a2
ffffffffc02011e0:	96be                	add	a3,a3,a5
ffffffffc02011e2:	c02007b7          	lui	a5,0xc0200
ffffffffc02011e6:	0af6e163          	bltu	a3,a5,ffffffffc0201288 <pmm_init+0x17a>
ffffffffc02011ea:	00005917          	auipc	s2,0x5
ffffffffc02011ee:	3c690913          	addi	s2,s2,966 # ffffffffc02065b0 <va_pa_offset>
ffffffffc02011f2:	00093783          	ld	a5,0(s2)
    if (freemem < mem_end) {
ffffffffc02011f6:	45c5                	li	a1,17
ffffffffc02011f8:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011fa:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc02011fc:	04b6eb63          	bltu	a3,a1,ffffffffc0201252 <pmm_init+0x144>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201200:	609c                	ld	a5,0(s1)
ffffffffc0201202:	7b9c                	ld	a5,48(a5)
ffffffffc0201204:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201206:	00001517          	auipc	a0,0x1
ffffffffc020120a:	20a50513          	addi	a0,a0,522 # ffffffffc0202410 <buddy_pmm_manager+0x170>
ffffffffc020120e:	ea9fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201212:	00004697          	auipc	a3,0x4
ffffffffc0201216:	dee68693          	addi	a3,a3,-530 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020121a:	00005797          	auipc	a5,0x5
ffffffffc020121e:	20d7b723          	sd	a3,526(a5) # ffffffffc0206428 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201222:	c02007b7          	lui	a5,0xc0200
ffffffffc0201226:	06f6ed63          	bltu	a3,a5,ffffffffc02012a0 <pmm_init+0x192>
ffffffffc020122a:	00093783          	ld	a5,0(s2)
}
ffffffffc020122e:	6442                	ld	s0,16(sp)
ffffffffc0201230:	60e2                	ld	ra,24(sp)
ffffffffc0201232:	64a2                	ld	s1,8(sp)
ffffffffc0201234:	6902                	ld	s2,0(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201236:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0201238:	8e9d                	sub	a3,a3,a5
ffffffffc020123a:	00005797          	auipc	a5,0x5
ffffffffc020123e:	36d7b323          	sd	a3,870(a5) # ffffffffc02065a0 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201242:	00001517          	auipc	a0,0x1
ffffffffc0201246:	1ee50513          	addi	a0,a0,494 # ffffffffc0202430 <buddy_pmm_manager+0x190>
ffffffffc020124a:	8636                	mv	a2,a3
}
ffffffffc020124c:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020124e:	e69fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201252:	6405                	lui	s0,0x1
ffffffffc0201254:	147d                	addi	s0,s0,-1
ffffffffc0201256:	9436                	add	s0,s0,a3
ffffffffc0201258:	76fd                	lui	a3,0xfffff
ffffffffc020125a:	8ee1                	and	a3,a3,s0
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020125c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201260:	04e7fc63          	bleu	a4,a5,ffffffffc02012b8 <pmm_init+0x1aa>
    pmm_manager->init_memmap(base, n);
ffffffffc0201264:	6098                	ld	a4,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201266:	97aa                	add	a5,a5,a0
ffffffffc0201268:	00279513          	slli	a0,a5,0x2
ffffffffc020126c:	953e                	add	a0,a0,a5
ffffffffc020126e:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201270:	8d95                	sub	a1,a1,a3
ffffffffc0201272:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201274:	81b1                	srli	a1,a1,0xc
ffffffffc0201276:	9532                	add	a0,a0,a2
ffffffffc0201278:	9782                	jalr	a5
        first_ppn=mem_begin/PGSIZE;
ffffffffc020127a:	00c45693          	srli	a3,s0,0xc
ffffffffc020127e:	00005797          	auipc	a5,0x5
ffffffffc0201282:	18d7bd23          	sd	a3,410(a5) # ffffffffc0206418 <first_ppn>
ffffffffc0201286:	bfad                	j	ffffffffc0201200 <pmm_init+0xf2>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201288:	00001617          	auipc	a2,0x1
ffffffffc020128c:	12060613          	addi	a2,a2,288 # ffffffffc02023a8 <buddy_pmm_manager+0x108>
ffffffffc0201290:	06f00593          	li	a1,111
ffffffffc0201294:	00001517          	auipc	a0,0x1
ffffffffc0201298:	13c50513          	addi	a0,a0,316 # ffffffffc02023d0 <buddy_pmm_manager+0x130>
ffffffffc020129c:	910ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02012a0:	00001617          	auipc	a2,0x1
ffffffffc02012a4:	10860613          	addi	a2,a2,264 # ffffffffc02023a8 <buddy_pmm_manager+0x108>
ffffffffc02012a8:	08b00593          	li	a1,139
ffffffffc02012ac:	00001517          	auipc	a0,0x1
ffffffffc02012b0:	12450513          	addi	a0,a0,292 # ffffffffc02023d0 <buddy_pmm_manager+0x130>
ffffffffc02012b4:	8f8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02012b8:	00001617          	auipc	a2,0x1
ffffffffc02012bc:	12860613          	addi	a2,a2,296 # ffffffffc02023e0 <buddy_pmm_manager+0x140>
ffffffffc02012c0:	06c00593          	li	a1,108
ffffffffc02012c4:	00001517          	auipc	a0,0x1
ffffffffc02012c8:	13c50513          	addi	a0,a0,316 # ffffffffc0202400 <buddy_pmm_manager+0x160>
ffffffffc02012cc:	8e0ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02012d0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02012d0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012d4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02012d6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012da:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02012dc:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012e0:	f022                	sd	s0,32(sp)
ffffffffc02012e2:	ec26                	sd	s1,24(sp)
ffffffffc02012e4:	e84a                	sd	s2,16(sp)
ffffffffc02012e6:	f406                	sd	ra,40(sp)
ffffffffc02012e8:	e44e                	sd	s3,8(sp)
ffffffffc02012ea:	84aa                	mv	s1,a0
ffffffffc02012ec:	892e                	mv	s2,a1
ffffffffc02012ee:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02012f2:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02012f4:	03067e63          	bleu	a6,a2,ffffffffc0201330 <printnum+0x60>
ffffffffc02012f8:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02012fa:	00805763          	blez	s0,ffffffffc0201308 <printnum+0x38>
ffffffffc02012fe:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201300:	85ca                	mv	a1,s2
ffffffffc0201302:	854e                	mv	a0,s3
ffffffffc0201304:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201306:	fc65                	bnez	s0,ffffffffc02012fe <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201308:	1a02                	slli	s4,s4,0x20
ffffffffc020130a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020130e:	00001797          	auipc	a5,0x1
ffffffffc0201312:	2f278793          	addi	a5,a5,754 # ffffffffc0202600 <error_string+0x38>
ffffffffc0201316:	9a3e                	add	s4,s4,a5
}
ffffffffc0201318:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020131a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020131e:	70a2                	ld	ra,40(sp)
ffffffffc0201320:	69a2                	ld	s3,8(sp)
ffffffffc0201322:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201324:	85ca                	mv	a1,s2
ffffffffc0201326:	8326                	mv	t1,s1
}
ffffffffc0201328:	6942                	ld	s2,16(sp)
ffffffffc020132a:	64e2                	ld	s1,24(sp)
ffffffffc020132c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020132e:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201330:	03065633          	divu	a2,a2,a6
ffffffffc0201334:	8722                	mv	a4,s0
ffffffffc0201336:	f9bff0ef          	jal	ra,ffffffffc02012d0 <printnum>
ffffffffc020133a:	b7f9                	j	ffffffffc0201308 <printnum+0x38>

ffffffffc020133c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020133c:	7119                	addi	sp,sp,-128
ffffffffc020133e:	f4a6                	sd	s1,104(sp)
ffffffffc0201340:	f0ca                	sd	s2,96(sp)
ffffffffc0201342:	e8d2                	sd	s4,80(sp)
ffffffffc0201344:	e4d6                	sd	s5,72(sp)
ffffffffc0201346:	e0da                	sd	s6,64(sp)
ffffffffc0201348:	fc5e                	sd	s7,56(sp)
ffffffffc020134a:	f862                	sd	s8,48(sp)
ffffffffc020134c:	f06a                	sd	s10,32(sp)
ffffffffc020134e:	fc86                	sd	ra,120(sp)
ffffffffc0201350:	f8a2                	sd	s0,112(sp)
ffffffffc0201352:	ecce                	sd	s3,88(sp)
ffffffffc0201354:	f466                	sd	s9,40(sp)
ffffffffc0201356:	ec6e                	sd	s11,24(sp)
ffffffffc0201358:	892a                	mv	s2,a0
ffffffffc020135a:	84ae                	mv	s1,a1
ffffffffc020135c:	8d32                	mv	s10,a2
ffffffffc020135e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201360:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201362:	00001a17          	auipc	s4,0x1
ffffffffc0201366:	10ea0a13          	addi	s4,s4,270 # ffffffffc0202470 <buddy_pmm_manager+0x1d0>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020136a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020136e:	00001c17          	auipc	s8,0x1
ffffffffc0201372:	25ac0c13          	addi	s8,s8,602 # ffffffffc02025c8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201376:	000d4503          	lbu	a0,0(s10)
ffffffffc020137a:	02500793          	li	a5,37
ffffffffc020137e:	001d0413          	addi	s0,s10,1
ffffffffc0201382:	00f50e63          	beq	a0,a5,ffffffffc020139e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201386:	c521                	beqz	a0,ffffffffc02013ce <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201388:	02500993          	li	s3,37
ffffffffc020138c:	a011                	j	ffffffffc0201390 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020138e:	c121                	beqz	a0,ffffffffc02013ce <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201390:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201392:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201394:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201396:	fff44503          	lbu	a0,-1(s0) # fff <BASE_ADDRESS-0xffffffffc01ff001>
ffffffffc020139a:	ff351ae3          	bne	a0,s3,ffffffffc020138e <vprintfmt+0x52>
ffffffffc020139e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02013a2:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02013a6:	4981                	li	s3,0
ffffffffc02013a8:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02013aa:	5cfd                	li	s9,-1
ffffffffc02013ac:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013ae:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02013b2:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013b4:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02013b8:	0ff6f693          	andi	a3,a3,255
ffffffffc02013bc:	00140d13          	addi	s10,s0,1
ffffffffc02013c0:	20d5e563          	bltu	a1,a3,ffffffffc02015ca <vprintfmt+0x28e>
ffffffffc02013c4:	068a                	slli	a3,a3,0x2
ffffffffc02013c6:	96d2                	add	a3,a3,s4
ffffffffc02013c8:	4294                	lw	a3,0(a3)
ffffffffc02013ca:	96d2                	add	a3,a3,s4
ffffffffc02013cc:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02013ce:	70e6                	ld	ra,120(sp)
ffffffffc02013d0:	7446                	ld	s0,112(sp)
ffffffffc02013d2:	74a6                	ld	s1,104(sp)
ffffffffc02013d4:	7906                	ld	s2,96(sp)
ffffffffc02013d6:	69e6                	ld	s3,88(sp)
ffffffffc02013d8:	6a46                	ld	s4,80(sp)
ffffffffc02013da:	6aa6                	ld	s5,72(sp)
ffffffffc02013dc:	6b06                	ld	s6,64(sp)
ffffffffc02013de:	7be2                	ld	s7,56(sp)
ffffffffc02013e0:	7c42                	ld	s8,48(sp)
ffffffffc02013e2:	7ca2                	ld	s9,40(sp)
ffffffffc02013e4:	7d02                	ld	s10,32(sp)
ffffffffc02013e6:	6de2                	ld	s11,24(sp)
ffffffffc02013e8:	6109                	addi	sp,sp,128
ffffffffc02013ea:	8082                	ret
    if (lflag >= 2) {
ffffffffc02013ec:	4705                	li	a4,1
ffffffffc02013ee:	008a8593          	addi	a1,s5,8
ffffffffc02013f2:	01074463          	blt	a4,a6,ffffffffc02013fa <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02013f6:	26080363          	beqz	a6,ffffffffc020165c <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02013fa:	000ab603          	ld	a2,0(s5)
ffffffffc02013fe:	46c1                	li	a3,16
ffffffffc0201400:	8aae                	mv	s5,a1
ffffffffc0201402:	a06d                	j	ffffffffc02014ac <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201404:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201408:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020140a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020140c:	b765                	j	ffffffffc02013b4 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc020140e:	000aa503          	lw	a0,0(s5)
ffffffffc0201412:	85a6                	mv	a1,s1
ffffffffc0201414:	0aa1                	addi	s5,s5,8
ffffffffc0201416:	9902                	jalr	s2
            break;
ffffffffc0201418:	bfb9                	j	ffffffffc0201376 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020141a:	4705                	li	a4,1
ffffffffc020141c:	008a8993          	addi	s3,s5,8
ffffffffc0201420:	01074463          	blt	a4,a6,ffffffffc0201428 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0201424:	22080463          	beqz	a6,ffffffffc020164c <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0201428:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020142c:	24044463          	bltz	s0,ffffffffc0201674 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0201430:	8622                	mv	a2,s0
ffffffffc0201432:	8ace                	mv	s5,s3
ffffffffc0201434:	46a9                	li	a3,10
ffffffffc0201436:	a89d                	j	ffffffffc02014ac <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0201438:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020143c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020143e:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0201440:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201444:	8fb5                	xor	a5,a5,a3
ffffffffc0201446:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020144a:	1ad74363          	blt	a4,a3,ffffffffc02015f0 <vprintfmt+0x2b4>
ffffffffc020144e:	00369793          	slli	a5,a3,0x3
ffffffffc0201452:	97e2                	add	a5,a5,s8
ffffffffc0201454:	639c                	ld	a5,0(a5)
ffffffffc0201456:	18078d63          	beqz	a5,ffffffffc02015f0 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc020145a:	86be                	mv	a3,a5
ffffffffc020145c:	00001617          	auipc	a2,0x1
ffffffffc0201460:	25460613          	addi	a2,a2,596 # ffffffffc02026b0 <error_string+0xe8>
ffffffffc0201464:	85a6                	mv	a1,s1
ffffffffc0201466:	854a                	mv	a0,s2
ffffffffc0201468:	240000ef          	jal	ra,ffffffffc02016a8 <printfmt>
ffffffffc020146c:	b729                	j	ffffffffc0201376 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020146e:	00144603          	lbu	a2,1(s0)
ffffffffc0201472:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201474:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201476:	bf3d                	j	ffffffffc02013b4 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201478:	4705                	li	a4,1
ffffffffc020147a:	008a8593          	addi	a1,s5,8
ffffffffc020147e:	01074463          	blt	a4,a6,ffffffffc0201486 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201482:	1e080263          	beqz	a6,ffffffffc0201666 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201486:	000ab603          	ld	a2,0(s5)
ffffffffc020148a:	46a1                	li	a3,8
ffffffffc020148c:	8aae                	mv	s5,a1
ffffffffc020148e:	a839                	j	ffffffffc02014ac <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201490:	03000513          	li	a0,48
ffffffffc0201494:	85a6                	mv	a1,s1
ffffffffc0201496:	e03e                	sd	a5,0(sp)
ffffffffc0201498:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020149a:	85a6                	mv	a1,s1
ffffffffc020149c:	07800513          	li	a0,120
ffffffffc02014a0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02014a2:	0aa1                	addi	s5,s5,8
ffffffffc02014a4:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02014a8:	6782                	ld	a5,0(sp)
ffffffffc02014aa:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02014ac:	876e                	mv	a4,s11
ffffffffc02014ae:	85a6                	mv	a1,s1
ffffffffc02014b0:	854a                	mv	a0,s2
ffffffffc02014b2:	e1fff0ef          	jal	ra,ffffffffc02012d0 <printnum>
            break;
ffffffffc02014b6:	b5c1                	j	ffffffffc0201376 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02014b8:	000ab603          	ld	a2,0(s5)
ffffffffc02014bc:	0aa1                	addi	s5,s5,8
ffffffffc02014be:	1c060663          	beqz	a2,ffffffffc020168a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02014c2:	00160413          	addi	s0,a2,1
ffffffffc02014c6:	17b05c63          	blez	s11,ffffffffc020163e <vprintfmt+0x302>
ffffffffc02014ca:	02d00593          	li	a1,45
ffffffffc02014ce:	14b79263          	bne	a5,a1,ffffffffc0201612 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014d2:	00064783          	lbu	a5,0(a2)
ffffffffc02014d6:	0007851b          	sext.w	a0,a5
ffffffffc02014da:	c905                	beqz	a0,ffffffffc020150a <vprintfmt+0x1ce>
ffffffffc02014dc:	000cc563          	bltz	s9,ffffffffc02014e6 <vprintfmt+0x1aa>
ffffffffc02014e0:	3cfd                	addiw	s9,s9,-1
ffffffffc02014e2:	036c8263          	beq	s9,s6,ffffffffc0201506 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02014e6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02014e8:	18098463          	beqz	s3,ffffffffc0201670 <vprintfmt+0x334>
ffffffffc02014ec:	3781                	addiw	a5,a5,-32
ffffffffc02014ee:	18fbf163          	bleu	a5,s7,ffffffffc0201670 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02014f2:	03f00513          	li	a0,63
ffffffffc02014f6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014f8:	0405                	addi	s0,s0,1
ffffffffc02014fa:	fff44783          	lbu	a5,-1(s0)
ffffffffc02014fe:	3dfd                	addiw	s11,s11,-1
ffffffffc0201500:	0007851b          	sext.w	a0,a5
ffffffffc0201504:	fd61                	bnez	a0,ffffffffc02014dc <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201506:	e7b058e3          	blez	s11,ffffffffc0201376 <vprintfmt+0x3a>
ffffffffc020150a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020150c:	85a6                	mv	a1,s1
ffffffffc020150e:	02000513          	li	a0,32
ffffffffc0201512:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201514:	e60d81e3          	beqz	s11,ffffffffc0201376 <vprintfmt+0x3a>
ffffffffc0201518:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020151a:	85a6                	mv	a1,s1
ffffffffc020151c:	02000513          	li	a0,32
ffffffffc0201520:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201522:	fe0d94e3          	bnez	s11,ffffffffc020150a <vprintfmt+0x1ce>
ffffffffc0201526:	bd81                	j	ffffffffc0201376 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201528:	4705                	li	a4,1
ffffffffc020152a:	008a8593          	addi	a1,s5,8
ffffffffc020152e:	01074463          	blt	a4,a6,ffffffffc0201536 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0201532:	12080063          	beqz	a6,ffffffffc0201652 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201536:	000ab603          	ld	a2,0(s5)
ffffffffc020153a:	46a9                	li	a3,10
ffffffffc020153c:	8aae                	mv	s5,a1
ffffffffc020153e:	b7bd                	j	ffffffffc02014ac <vprintfmt+0x170>
ffffffffc0201540:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201544:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201548:	846a                	mv	s0,s10
ffffffffc020154a:	b5ad                	j	ffffffffc02013b4 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020154c:	85a6                	mv	a1,s1
ffffffffc020154e:	02500513          	li	a0,37
ffffffffc0201552:	9902                	jalr	s2
            break;
ffffffffc0201554:	b50d                	j	ffffffffc0201376 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201556:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020155a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020155e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201560:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201562:	e40dd9e3          	bgez	s11,ffffffffc02013b4 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201566:	8de6                	mv	s11,s9
ffffffffc0201568:	5cfd                	li	s9,-1
ffffffffc020156a:	b5a9                	j	ffffffffc02013b4 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020156c:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201570:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201574:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201576:	bd3d                	j	ffffffffc02013b4 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201578:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020157c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201580:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201582:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201586:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020158a:	fcd56ce3          	bltu	a0,a3,ffffffffc0201562 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020158e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201590:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201594:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201598:	0196873b          	addw	a4,a3,s9
ffffffffc020159c:	0017171b          	slliw	a4,a4,0x1
ffffffffc02015a0:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02015a4:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02015a8:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02015ac:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015b0:	fcd57fe3          	bleu	a3,a0,ffffffffc020158e <vprintfmt+0x252>
ffffffffc02015b4:	b77d                	j	ffffffffc0201562 <vprintfmt+0x226>
            if (width < 0)
ffffffffc02015b6:	fffdc693          	not	a3,s11
ffffffffc02015ba:	96fd                	srai	a3,a3,0x3f
ffffffffc02015bc:	00ddfdb3          	and	s11,s11,a3
ffffffffc02015c0:	00144603          	lbu	a2,1(s0)
ffffffffc02015c4:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015c6:	846a                	mv	s0,s10
ffffffffc02015c8:	b3f5                	j	ffffffffc02013b4 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02015ca:	85a6                	mv	a1,s1
ffffffffc02015cc:	02500513          	li	a0,37
ffffffffc02015d0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02015d2:	fff44703          	lbu	a4,-1(s0)
ffffffffc02015d6:	02500793          	li	a5,37
ffffffffc02015da:	8d22                	mv	s10,s0
ffffffffc02015dc:	d8f70de3          	beq	a4,a5,ffffffffc0201376 <vprintfmt+0x3a>
ffffffffc02015e0:	02500713          	li	a4,37
ffffffffc02015e4:	1d7d                	addi	s10,s10,-1
ffffffffc02015e6:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02015ea:	fee79de3          	bne	a5,a4,ffffffffc02015e4 <vprintfmt+0x2a8>
ffffffffc02015ee:	b361                	j	ffffffffc0201376 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02015f0:	00001617          	auipc	a2,0x1
ffffffffc02015f4:	0b060613          	addi	a2,a2,176 # ffffffffc02026a0 <error_string+0xd8>
ffffffffc02015f8:	85a6                	mv	a1,s1
ffffffffc02015fa:	854a                	mv	a0,s2
ffffffffc02015fc:	0ac000ef          	jal	ra,ffffffffc02016a8 <printfmt>
ffffffffc0201600:	bb9d                	j	ffffffffc0201376 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201602:	00001617          	auipc	a2,0x1
ffffffffc0201606:	09660613          	addi	a2,a2,150 # ffffffffc0202698 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020160a:	00001417          	auipc	s0,0x1
ffffffffc020160e:	08f40413          	addi	s0,s0,143 # ffffffffc0202699 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201612:	8532                	mv	a0,a2
ffffffffc0201614:	85e6                	mv	a1,s9
ffffffffc0201616:	e032                	sd	a2,0(sp)
ffffffffc0201618:	e43e                	sd	a5,8(sp)
ffffffffc020161a:	1c2000ef          	jal	ra,ffffffffc02017dc <strnlen>
ffffffffc020161e:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201622:	6602                	ld	a2,0(sp)
ffffffffc0201624:	01b05d63          	blez	s11,ffffffffc020163e <vprintfmt+0x302>
ffffffffc0201628:	67a2                	ld	a5,8(sp)
ffffffffc020162a:	2781                	sext.w	a5,a5
ffffffffc020162c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020162e:	6522                	ld	a0,8(sp)
ffffffffc0201630:	85a6                	mv	a1,s1
ffffffffc0201632:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201634:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201636:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201638:	6602                	ld	a2,0(sp)
ffffffffc020163a:	fe0d9ae3          	bnez	s11,ffffffffc020162e <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020163e:	00064783          	lbu	a5,0(a2)
ffffffffc0201642:	0007851b          	sext.w	a0,a5
ffffffffc0201646:	e8051be3          	bnez	a0,ffffffffc02014dc <vprintfmt+0x1a0>
ffffffffc020164a:	b335                	j	ffffffffc0201376 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020164c:	000aa403          	lw	s0,0(s5)
ffffffffc0201650:	bbf1                	j	ffffffffc020142c <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0201652:	000ae603          	lwu	a2,0(s5)
ffffffffc0201656:	46a9                	li	a3,10
ffffffffc0201658:	8aae                	mv	s5,a1
ffffffffc020165a:	bd89                	j	ffffffffc02014ac <vprintfmt+0x170>
ffffffffc020165c:	000ae603          	lwu	a2,0(s5)
ffffffffc0201660:	46c1                	li	a3,16
ffffffffc0201662:	8aae                	mv	s5,a1
ffffffffc0201664:	b5a1                	j	ffffffffc02014ac <vprintfmt+0x170>
ffffffffc0201666:	000ae603          	lwu	a2,0(s5)
ffffffffc020166a:	46a1                	li	a3,8
ffffffffc020166c:	8aae                	mv	s5,a1
ffffffffc020166e:	bd3d                	j	ffffffffc02014ac <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201670:	9902                	jalr	s2
ffffffffc0201672:	b559                	j	ffffffffc02014f8 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201674:	85a6                	mv	a1,s1
ffffffffc0201676:	02d00513          	li	a0,45
ffffffffc020167a:	e03e                	sd	a5,0(sp)
ffffffffc020167c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020167e:	8ace                	mv	s5,s3
ffffffffc0201680:	40800633          	neg	a2,s0
ffffffffc0201684:	46a9                	li	a3,10
ffffffffc0201686:	6782                	ld	a5,0(sp)
ffffffffc0201688:	b515                	j	ffffffffc02014ac <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020168a:	01b05663          	blez	s11,ffffffffc0201696 <vprintfmt+0x35a>
ffffffffc020168e:	02d00693          	li	a3,45
ffffffffc0201692:	f6d798e3          	bne	a5,a3,ffffffffc0201602 <vprintfmt+0x2c6>
ffffffffc0201696:	00001417          	auipc	s0,0x1
ffffffffc020169a:	00340413          	addi	s0,s0,3 # ffffffffc0202699 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020169e:	02800513          	li	a0,40
ffffffffc02016a2:	02800793          	li	a5,40
ffffffffc02016a6:	bd1d                	j	ffffffffc02014dc <vprintfmt+0x1a0>

ffffffffc02016a8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016a8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02016aa:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016ae:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02016b0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016b2:	ec06                	sd	ra,24(sp)
ffffffffc02016b4:	f83a                	sd	a4,48(sp)
ffffffffc02016b6:	fc3e                	sd	a5,56(sp)
ffffffffc02016b8:	e0c2                	sd	a6,64(sp)
ffffffffc02016ba:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02016bc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02016be:	c7fff0ef          	jal	ra,ffffffffc020133c <vprintfmt>
}
ffffffffc02016c2:	60e2                	ld	ra,24(sp)
ffffffffc02016c4:	6161                	addi	sp,sp,80
ffffffffc02016c6:	8082                	ret

ffffffffc02016c8 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02016c8:	715d                	addi	sp,sp,-80
ffffffffc02016ca:	e486                	sd	ra,72(sp)
ffffffffc02016cc:	e0a2                	sd	s0,64(sp)
ffffffffc02016ce:	fc26                	sd	s1,56(sp)
ffffffffc02016d0:	f84a                	sd	s2,48(sp)
ffffffffc02016d2:	f44e                	sd	s3,40(sp)
ffffffffc02016d4:	f052                	sd	s4,32(sp)
ffffffffc02016d6:	ec56                	sd	s5,24(sp)
ffffffffc02016d8:	e85a                	sd	s6,16(sp)
ffffffffc02016da:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02016dc:	c901                	beqz	a0,ffffffffc02016ec <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02016de:	85aa                	mv	a1,a0
ffffffffc02016e0:	00001517          	auipc	a0,0x1
ffffffffc02016e4:	fd050513          	addi	a0,a0,-48 # ffffffffc02026b0 <error_string+0xe8>
ffffffffc02016e8:	9cffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc02016ec:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016ee:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02016f0:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02016f2:	4aa9                	li	s5,10
ffffffffc02016f4:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02016f6:	00005b97          	auipc	s7,0x5
ffffffffc02016fa:	91ab8b93          	addi	s7,s7,-1766 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016fe:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201702:	a2dfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201706:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201708:	00054b63          	bltz	a0,ffffffffc020171e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020170c:	00a95b63          	ble	a0,s2,ffffffffc0201722 <readline+0x5a>
ffffffffc0201710:	029a5463          	ble	s1,s4,ffffffffc0201738 <readline+0x70>
        c = getchar();
ffffffffc0201714:	a1bfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201718:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020171a:	fe0559e3          	bgez	a0,ffffffffc020170c <readline+0x44>
            return NULL;
ffffffffc020171e:	4501                	li	a0,0
ffffffffc0201720:	a099                	j	ffffffffc0201766 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201722:	03341463          	bne	s0,s3,ffffffffc020174a <readline+0x82>
ffffffffc0201726:	e8b9                	bnez	s1,ffffffffc020177c <readline+0xb4>
        c = getchar();
ffffffffc0201728:	a07fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020172c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020172e:	fe0548e3          	bltz	a0,ffffffffc020171e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201732:	fea958e3          	ble	a0,s2,ffffffffc0201722 <readline+0x5a>
ffffffffc0201736:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201738:	8522                	mv	a0,s0
ffffffffc020173a:	9b1fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc020173e:	009b87b3          	add	a5,s7,s1
ffffffffc0201742:	00878023          	sb	s0,0(a5)
ffffffffc0201746:	2485                	addiw	s1,s1,1
ffffffffc0201748:	bf6d                	j	ffffffffc0201702 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020174a:	01540463          	beq	s0,s5,ffffffffc0201752 <readline+0x8a>
ffffffffc020174e:	fb641ae3          	bne	s0,s6,ffffffffc0201702 <readline+0x3a>
            cputchar(c);
ffffffffc0201752:	8522                	mv	a0,s0
ffffffffc0201754:	997fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201758:	00005517          	auipc	a0,0x5
ffffffffc020175c:	8b850513          	addi	a0,a0,-1864 # ffffffffc0206010 <edata>
ffffffffc0201760:	94aa                	add	s1,s1,a0
ffffffffc0201762:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201766:	60a6                	ld	ra,72(sp)
ffffffffc0201768:	6406                	ld	s0,64(sp)
ffffffffc020176a:	74e2                	ld	s1,56(sp)
ffffffffc020176c:	7942                	ld	s2,48(sp)
ffffffffc020176e:	79a2                	ld	s3,40(sp)
ffffffffc0201770:	7a02                	ld	s4,32(sp)
ffffffffc0201772:	6ae2                	ld	s5,24(sp)
ffffffffc0201774:	6b42                	ld	s6,16(sp)
ffffffffc0201776:	6ba2                	ld	s7,8(sp)
ffffffffc0201778:	6161                	addi	sp,sp,80
ffffffffc020177a:	8082                	ret
            cputchar(c);
ffffffffc020177c:	4521                	li	a0,8
ffffffffc020177e:	96dfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201782:	34fd                	addiw	s1,s1,-1
ffffffffc0201784:	bfbd                	j	ffffffffc0201702 <readline+0x3a>

ffffffffc0201786 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201786:	00005797          	auipc	a5,0x5
ffffffffc020178a:	88278793          	addi	a5,a5,-1918 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc020178e:	6398                	ld	a4,0(a5)
ffffffffc0201790:	4781                	li	a5,0
ffffffffc0201792:	88ba                	mv	a7,a4
ffffffffc0201794:	852a                	mv	a0,a0
ffffffffc0201796:	85be                	mv	a1,a5
ffffffffc0201798:	863e                	mv	a2,a5
ffffffffc020179a:	00000073          	ecall
ffffffffc020179e:	87aa                	mv	a5,a0
}
ffffffffc02017a0:	8082                	ret

ffffffffc02017a2 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc02017a2:	00005797          	auipc	a5,0x5
ffffffffc02017a6:	c8e78793          	addi	a5,a5,-882 # ffffffffc0206430 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc02017aa:	6398                	ld	a4,0(a5)
ffffffffc02017ac:	4781                	li	a5,0
ffffffffc02017ae:	88ba                	mv	a7,a4
ffffffffc02017b0:	852a                	mv	a0,a0
ffffffffc02017b2:	85be                	mv	a1,a5
ffffffffc02017b4:	863e                	mv	a2,a5
ffffffffc02017b6:	00000073          	ecall
ffffffffc02017ba:	87aa                	mv	a5,a0
}
ffffffffc02017bc:	8082                	ret

ffffffffc02017be <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02017be:	00005797          	auipc	a5,0x5
ffffffffc02017c2:	84278793          	addi	a5,a5,-1982 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc02017c6:	639c                	ld	a5,0(a5)
ffffffffc02017c8:	4501                	li	a0,0
ffffffffc02017ca:	88be                	mv	a7,a5
ffffffffc02017cc:	852a                	mv	a0,a0
ffffffffc02017ce:	85aa                	mv	a1,a0
ffffffffc02017d0:	862a                	mv	a2,a0
ffffffffc02017d2:	00000073          	ecall
ffffffffc02017d6:	852a                	mv	a0,a0
ffffffffc02017d8:	2501                	sext.w	a0,a0
ffffffffc02017da:	8082                	ret

ffffffffc02017dc <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02017dc:	c185                	beqz	a1,ffffffffc02017fc <strnlen+0x20>
ffffffffc02017de:	00054783          	lbu	a5,0(a0)
ffffffffc02017e2:	cf89                	beqz	a5,ffffffffc02017fc <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02017e4:	4781                	li	a5,0
ffffffffc02017e6:	a021                	j	ffffffffc02017ee <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02017e8:	00074703          	lbu	a4,0(a4)
ffffffffc02017ec:	c711                	beqz	a4,ffffffffc02017f8 <strnlen+0x1c>
        cnt ++;
ffffffffc02017ee:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02017f0:	00f50733          	add	a4,a0,a5
ffffffffc02017f4:	fef59ae3          	bne	a1,a5,ffffffffc02017e8 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02017f8:	853e                	mv	a0,a5
ffffffffc02017fa:	8082                	ret
    size_t cnt = 0;
ffffffffc02017fc:	4781                	li	a5,0
}
ffffffffc02017fe:	853e                	mv	a0,a5
ffffffffc0201800:	8082                	ret

ffffffffc0201802 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201802:	00054783          	lbu	a5,0(a0)
ffffffffc0201806:	0005c703          	lbu	a4,0(a1)
ffffffffc020180a:	cb91                	beqz	a5,ffffffffc020181e <strcmp+0x1c>
ffffffffc020180c:	00e79c63          	bne	a5,a4,ffffffffc0201824 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201810:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201812:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201816:	0585                	addi	a1,a1,1
ffffffffc0201818:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020181c:	fbe5                	bnez	a5,ffffffffc020180c <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020181e:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201820:	9d19                	subw	a0,a0,a4
ffffffffc0201822:	8082                	ret
ffffffffc0201824:	0007851b          	sext.w	a0,a5
ffffffffc0201828:	9d19                	subw	a0,a0,a4
ffffffffc020182a:	8082                	ret

ffffffffc020182c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020182c:	00054783          	lbu	a5,0(a0)
ffffffffc0201830:	cb91                	beqz	a5,ffffffffc0201844 <strchr+0x18>
        if (*s == c) {
ffffffffc0201832:	00b79563          	bne	a5,a1,ffffffffc020183c <strchr+0x10>
ffffffffc0201836:	a809                	j	ffffffffc0201848 <strchr+0x1c>
ffffffffc0201838:	00b78763          	beq	a5,a1,ffffffffc0201846 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020183c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020183e:	00054783          	lbu	a5,0(a0)
ffffffffc0201842:	fbfd                	bnez	a5,ffffffffc0201838 <strchr+0xc>
    }
    return NULL;
ffffffffc0201844:	4501                	li	a0,0
}
ffffffffc0201846:	8082                	ret
ffffffffc0201848:	8082                	ret

ffffffffc020184a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020184a:	ca01                	beqz	a2,ffffffffc020185a <memset+0x10>
ffffffffc020184c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020184e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201850:	0785                	addi	a5,a5,1
ffffffffc0201852:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201856:	fec79de3          	bne	a5,a2,ffffffffc0201850 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020185a:	8082                	ret
