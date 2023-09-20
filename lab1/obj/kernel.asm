
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	01460613          	addi	a2,a2,20 # 80204028 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	235000ef          	jal	ra,80200a58 <memset>

    cons_init();  // init the console
    80200028:	13c000ef          	jal	ra,80200164 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a4458593          	addi	a1,a1,-1468 # 80200a70 <etext+0x6>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a5c50513          	addi	a0,a0,-1444 # 80200a90 <etext+0x26>
    8020003c:	030000ef          	jal	ra,8020006c <cprintf>

    print_kerninfo();
    80200040:	060000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	130000ef          	jal	ra,80200174 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200048:	0e8000ef          	jal	ra,80200130 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004c:	122000ef          	jal	ra,8020016e <intr_enable>
    
     //__asm__ __volatile__("mret");
    //__asm__ __volatile__("ebreak");
    while (1)
        ;
    80200050:	a001                	j	80200050 <kern_init+0x44>

0000000080200052 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200052:	1141                	addi	sp,sp,-16
    80200054:	e022                	sd	s0,0(sp)
    80200056:	e406                	sd	ra,8(sp)
    80200058:	842e                	mv	s0,a1
    cons_putc(c);
    8020005a:	10c000ef          	jal	ra,80200166 <cons_putc>
    (*cnt)++;
    8020005e:	401c                	lw	a5,0(s0)
}
    80200060:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200062:	2785                	addiw	a5,a5,1
    80200064:	c01c                	sw	a5,0(s0)
}
    80200066:	6402                	ld	s0,0(sp)
    80200068:	0141                	addi	sp,sp,16
    8020006a:	8082                	ret

000000008020006c <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006e:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	862a                	mv	a2,a0
    8020007a:	004c                	addi	a1,sp,4
    8020007c:	00000517          	auipc	a0,0x0
    80200080:	fd650513          	addi	a0,a0,-42 # 80200052 <cputch>
    80200084:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	5be000ef          	jal	ra,80200652 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	9f650513          	addi	a0,a0,-1546 # 80200a98 <etext+0x2e>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5c58593          	addi	a1,a1,-164 # 8020000c <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	a0050513          	addi	a0,a0,-1536 # 80200ab8 <etext+0x4e>
    802000c0:	fadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	9a658593          	addi	a1,a1,-1626 # 80200a6a <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	a0c50513          	addi	a0,a0,-1524 # 80200ad8 <etext+0x6e>
    802000d4:	f99ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <edata>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	a1850513          	addi	a0,a0,-1512 # 80200af8 <etext+0x8e>
    802000e8:	f85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	a2450513          	addi	a0,a0,-1500 # 80200b18 <etext+0xae>
    802000fc:	f71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0478793          	addi	a5,a5,-252 # 8020000c <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	a1650513          	addi	a0,a0,-1514 # 80200b38 <etext+0xce>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	f41ff06f          	j	8020006c <cprintf>

0000000080200130 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200130:	1141                	addi	sp,sp,-16
    80200132:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200134:	02000793          	li	a5,32
    80200138:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013c:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200140:	67e1                	lui	a5,0x18
    80200142:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200146:	953e                	add	a0,a0,a5
    80200148:	0b3000ef          	jal	ra,802009fa <sbi_set_timer>
}
    8020014c:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014e:	00004797          	auipc	a5,0x4
    80200152:	ec07b923          	sd	zero,-302(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200156:	00001517          	auipc	a0,0x1
    8020015a:	a1250513          	addi	a0,a0,-1518 # 80200b68 <etext+0xfe>
}
    8020015e:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200160:	f0dff06f          	j	8020006c <cprintf>

0000000080200164 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200164:	8082                	ret

0000000080200166 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200166:	0ff57513          	andi	a0,a0,255
    8020016a:	0750006f          	j	802009de <sbi_console_putchar>

000000008020016e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020016e:	100167f3          	csrrsi	a5,sstatus,2
    80200172:	8082                	ret

0000000080200174 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200174:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200178:	00000797          	auipc	a5,0x0
    8020017c:	3b878793          	addi	a5,a5,952 # 80200530 <__alltraps>
    80200180:	10579073          	csrw	stvec,a5
}
    80200184:	8082                	ret

0000000080200186 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200186:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200188:	1141                	addi	sp,sp,-16
    8020018a:	e022                	sd	s0,0(sp)
    8020018c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020018e:	00001517          	auipc	a0,0x1
    80200192:	b6a50513          	addi	a0,a0,-1174 # 80200cf8 <etext+0x28e>
void print_regs(struct pushregs *gpr) {
    80200196:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200198:	ed5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    8020019c:	640c                	ld	a1,8(s0)
    8020019e:	00001517          	auipc	a0,0x1
    802001a2:	b7250513          	addi	a0,a0,-1166 # 80200d10 <etext+0x2a6>
    802001a6:	ec7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001aa:	680c                	ld	a1,16(s0)
    802001ac:	00001517          	auipc	a0,0x1
    802001b0:	b7c50513          	addi	a0,a0,-1156 # 80200d28 <etext+0x2be>
    802001b4:	eb9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001b8:	6c0c                	ld	a1,24(s0)
    802001ba:	00001517          	auipc	a0,0x1
    802001be:	b8650513          	addi	a0,a0,-1146 # 80200d40 <etext+0x2d6>
    802001c2:	eabff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001c6:	700c                	ld	a1,32(s0)
    802001c8:	00001517          	auipc	a0,0x1
    802001cc:	b9050513          	addi	a0,a0,-1136 # 80200d58 <etext+0x2ee>
    802001d0:	e9dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001d4:	740c                	ld	a1,40(s0)
    802001d6:	00001517          	auipc	a0,0x1
    802001da:	b9a50513          	addi	a0,a0,-1126 # 80200d70 <etext+0x306>
    802001de:	e8fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001e2:	780c                	ld	a1,48(s0)
    802001e4:	00001517          	auipc	a0,0x1
    802001e8:	ba450513          	addi	a0,a0,-1116 # 80200d88 <etext+0x31e>
    802001ec:	e81ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001f0:	7c0c                	ld	a1,56(s0)
    802001f2:	00001517          	auipc	a0,0x1
    802001f6:	bae50513          	addi	a0,a0,-1106 # 80200da0 <etext+0x336>
    802001fa:	e73ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    802001fe:	602c                	ld	a1,64(s0)
    80200200:	00001517          	auipc	a0,0x1
    80200204:	bb850513          	addi	a0,a0,-1096 # 80200db8 <etext+0x34e>
    80200208:	e65ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020020c:	642c                	ld	a1,72(s0)
    8020020e:	00001517          	auipc	a0,0x1
    80200212:	bc250513          	addi	a0,a0,-1086 # 80200dd0 <etext+0x366>
    80200216:	e57ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020021a:	682c                	ld	a1,80(s0)
    8020021c:	00001517          	auipc	a0,0x1
    80200220:	bcc50513          	addi	a0,a0,-1076 # 80200de8 <etext+0x37e>
    80200224:	e49ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200228:	6c2c                	ld	a1,88(s0)
    8020022a:	00001517          	auipc	a0,0x1
    8020022e:	bd650513          	addi	a0,a0,-1066 # 80200e00 <etext+0x396>
    80200232:	e3bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200236:	702c                	ld	a1,96(s0)
    80200238:	00001517          	auipc	a0,0x1
    8020023c:	be050513          	addi	a0,a0,-1056 # 80200e18 <etext+0x3ae>
    80200240:	e2dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200244:	742c                	ld	a1,104(s0)
    80200246:	00001517          	auipc	a0,0x1
    8020024a:	bea50513          	addi	a0,a0,-1046 # 80200e30 <etext+0x3c6>
    8020024e:	e1fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200252:	782c                	ld	a1,112(s0)
    80200254:	00001517          	auipc	a0,0x1
    80200258:	bf450513          	addi	a0,a0,-1036 # 80200e48 <etext+0x3de>
    8020025c:	e11ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200260:	7c2c                	ld	a1,120(s0)
    80200262:	00001517          	auipc	a0,0x1
    80200266:	bfe50513          	addi	a0,a0,-1026 # 80200e60 <etext+0x3f6>
    8020026a:	e03ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020026e:	604c                	ld	a1,128(s0)
    80200270:	00001517          	auipc	a0,0x1
    80200274:	c0850513          	addi	a0,a0,-1016 # 80200e78 <etext+0x40e>
    80200278:	df5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020027c:	644c                	ld	a1,136(s0)
    8020027e:	00001517          	auipc	a0,0x1
    80200282:	c1250513          	addi	a0,a0,-1006 # 80200e90 <etext+0x426>
    80200286:	de7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020028a:	684c                	ld	a1,144(s0)
    8020028c:	00001517          	auipc	a0,0x1
    80200290:	c1c50513          	addi	a0,a0,-996 # 80200ea8 <etext+0x43e>
    80200294:	dd9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    80200298:	6c4c                	ld	a1,152(s0)
    8020029a:	00001517          	auipc	a0,0x1
    8020029e:	c2650513          	addi	a0,a0,-986 # 80200ec0 <etext+0x456>
    802002a2:	dcbff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002a6:	704c                	ld	a1,160(s0)
    802002a8:	00001517          	auipc	a0,0x1
    802002ac:	c3050513          	addi	a0,a0,-976 # 80200ed8 <etext+0x46e>
    802002b0:	dbdff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002b4:	744c                	ld	a1,168(s0)
    802002b6:	00001517          	auipc	a0,0x1
    802002ba:	c3a50513          	addi	a0,a0,-966 # 80200ef0 <etext+0x486>
    802002be:	dafff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002c2:	784c                	ld	a1,176(s0)
    802002c4:	00001517          	auipc	a0,0x1
    802002c8:	c4450513          	addi	a0,a0,-956 # 80200f08 <etext+0x49e>
    802002cc:	da1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002d0:	7c4c                	ld	a1,184(s0)
    802002d2:	00001517          	auipc	a0,0x1
    802002d6:	c4e50513          	addi	a0,a0,-946 # 80200f20 <etext+0x4b6>
    802002da:	d93ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002de:	606c                	ld	a1,192(s0)
    802002e0:	00001517          	auipc	a0,0x1
    802002e4:	c5850513          	addi	a0,a0,-936 # 80200f38 <etext+0x4ce>
    802002e8:	d85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002ec:	646c                	ld	a1,200(s0)
    802002ee:	00001517          	auipc	a0,0x1
    802002f2:	c6250513          	addi	a0,a0,-926 # 80200f50 <etext+0x4e6>
    802002f6:	d77ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    802002fa:	686c                	ld	a1,208(s0)
    802002fc:	00001517          	auipc	a0,0x1
    80200300:	c6c50513          	addi	a0,a0,-916 # 80200f68 <etext+0x4fe>
    80200304:	d69ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200308:	6c6c                	ld	a1,216(s0)
    8020030a:	00001517          	auipc	a0,0x1
    8020030e:	c7650513          	addi	a0,a0,-906 # 80200f80 <etext+0x516>
    80200312:	d5bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200316:	706c                	ld	a1,224(s0)
    80200318:	00001517          	auipc	a0,0x1
    8020031c:	c8050513          	addi	a0,a0,-896 # 80200f98 <etext+0x52e>
    80200320:	d4dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200324:	746c                	ld	a1,232(s0)
    80200326:	00001517          	auipc	a0,0x1
    8020032a:	c8a50513          	addi	a0,a0,-886 # 80200fb0 <etext+0x546>
    8020032e:	d3fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200332:	786c                	ld	a1,240(s0)
    80200334:	00001517          	auipc	a0,0x1
    80200338:	c9450513          	addi	a0,a0,-876 # 80200fc8 <etext+0x55e>
    8020033c:	d31ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200340:	7c6c                	ld	a1,248(s0)
}
    80200342:	6402                	ld	s0,0(sp)
    80200344:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200346:	00001517          	auipc	a0,0x1
    8020034a:	c9a50513          	addi	a0,a0,-870 # 80200fe0 <etext+0x576>
}
    8020034e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	d1dff06f          	j	8020006c <cprintf>

0000000080200354 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200354:	1141                	addi	sp,sp,-16
    80200356:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200358:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020035a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020035c:	00001517          	auipc	a0,0x1
    80200360:	c9c50513          	addi	a0,a0,-868 # 80200ff8 <etext+0x58e>
void print_trapframe(struct trapframe *tf) {
    80200364:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200366:	d07ff0ef          	jal	ra,8020006c <cprintf>
    print_regs(&tf->gpr);
    8020036a:	8522                	mv	a0,s0
    8020036c:	e1bff0ef          	jal	ra,80200186 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200370:	10043583          	ld	a1,256(s0)
    80200374:	00001517          	auipc	a0,0x1
    80200378:	c9c50513          	addi	a0,a0,-868 # 80201010 <etext+0x5a6>
    8020037c:	cf1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200380:	10843583          	ld	a1,264(s0)
    80200384:	00001517          	auipc	a0,0x1
    80200388:	ca450513          	addi	a0,a0,-860 # 80201028 <etext+0x5be>
    8020038c:	ce1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    80200390:	11043583          	ld	a1,272(s0)
    80200394:	00001517          	auipc	a0,0x1
    80200398:	cac50513          	addi	a0,a0,-852 # 80201040 <etext+0x5d6>
    8020039c:	cd1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a0:	11843583          	ld	a1,280(s0)
}
    802003a4:	6402                	ld	s0,0(sp)
    802003a6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a8:	00001517          	auipc	a0,0x1
    802003ac:	cb050513          	addi	a0,a0,-848 # 80201058 <etext+0x5ee>
}
    802003b0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b2:	cbbff06f          	j	8020006c <cprintf>

00000000802003b6 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003b6:	11853783          	ld	a5,280(a0)
    802003ba:	577d                	li	a4,-1
    802003bc:	8305                	srli	a4,a4,0x1
    802003be:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003c0:	472d                	li	a4,11
    802003c2:	06f76963          	bltu	a4,a5,80200434 <interrupt_handler+0x7e>
    802003c6:	00000717          	auipc	a4,0x0
    802003ca:	7be70713          	addi	a4,a4,1982 # 80200b84 <etext+0x11a>
    802003ce:	078a                	slli	a5,a5,0x2
    802003d0:	97ba                	add	a5,a5,a4
    802003d2:	439c                	lw	a5,0(a5)
    802003d4:	97ba                	add	a5,a5,a4
    802003d6:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003d8:	00001517          	auipc	a0,0x1
    802003dc:	8d050513          	addi	a0,a0,-1840 # 80200ca8 <etext+0x23e>
    802003e0:	c8dff06f          	j	8020006c <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e4:	00001517          	auipc	a0,0x1
    802003e8:	8a450513          	addi	a0,a0,-1884 # 80200c88 <etext+0x21e>
    802003ec:	c81ff06f          	j	8020006c <cprintf>
            cprintf("User software interrupt\n");
    802003f0:	00001517          	auipc	a0,0x1
    802003f4:	85850513          	addi	a0,a0,-1960 # 80200c48 <etext+0x1de>
    802003f8:	c75ff06f          	j	8020006c <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	86c50513          	addi	a0,a0,-1940 # 80200c68 <etext+0x1fe>
    80200404:	c69ff06f          	j	8020006c <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    80200408:	00001517          	auipc	a0,0x1
    8020040c:	8d050513          	addi	a0,a0,-1840 # 80200cd8 <etext+0x26e>
    80200410:	c5dff06f          	j	8020006c <cprintf>
            ticks++;
    80200414:	00004717          	auipc	a4,0x4
    80200418:	c0c70713          	addi	a4,a4,-1012 # 80204020 <ticks>
    8020041c:	631c                	ld	a5,0(a4)
            if(ticks==TICK_NUM){
    8020041e:	06400693          	li	a3,100
            ticks++;
    80200422:	0785                	addi	a5,a5,1
    80200424:	00004617          	auipc	a2,0x4
    80200428:	bef63e23          	sd	a5,-1028(a2) # 80204020 <ticks>
            if(ticks==TICK_NUM){
    8020042c:	631c                	ld	a5,0(a4)
    8020042e:	00d78563          	beq	a5,a3,80200438 <interrupt_handler+0x82>
    80200432:	8082                	ret
            break;
        case IRQ_M_EXT:
            cprintf("Machine software interrupt\n");
            break;
        default:
            print_trapframe(tf);
    80200434:	f21ff06f          	j	80200354 <print_trapframe>
void interrupt_handler(struct trapframe *tf) {
    80200438:	1141                	addi	sp,sp,-16
    8020043a:	e022                	sd	s0,0(sp)
            	num++;
    8020043c:	00004417          	auipc	s0,0x4
    80200440:	bd440413          	addi	s0,s0,-1068 # 80204010 <edata>
    80200444:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
    80200446:	06400593          	li	a1,100
    8020044a:	00001517          	auipc	a0,0x1
    8020044e:	87e50513          	addi	a0,a0,-1922 # 80200cc8 <etext+0x25e>
            	num++;
    80200452:	0785                	addi	a5,a5,1
    80200454:	00004697          	auipc	a3,0x4
    80200458:	baf6be23          	sd	a5,-1092(a3) # 80204010 <edata>
            	ticks-=TICK_NUM;
    8020045c:	631c                	ld	a5,0(a4)
void interrupt_handler(struct trapframe *tf) {
    8020045e:	e406                	sd	ra,8(sp)
            	ticks-=TICK_NUM;
    80200460:	f9c78793          	addi	a5,a5,-100
    80200464:	00004717          	auipc	a4,0x4
    80200468:	baf73e23          	sd	a5,-1092(a4) # 80204020 <ticks>
    cprintf("%d ticks\n", TICK_NUM);
    8020046c:	c01ff0ef          	jal	ra,8020006c <cprintf>
            	if(num==10) sbi_shutdown();
    80200470:	6018                	ld	a4,0(s0)
    80200472:	47a9                	li	a5,10
    80200474:	00f70663          	beq	a4,a5,80200480 <interrupt_handler+0xca>
            break;
    }
}
    80200478:	60a2                	ld	ra,8(sp)
    8020047a:	6402                	ld	s0,0(sp)
    8020047c:	0141                	addi	sp,sp,16
    8020047e:	8082                	ret
    80200480:	6402                	ld	s0,0(sp)
    80200482:	60a2                	ld	ra,8(sp)
    80200484:	0141                	addi	sp,sp,16
            	if(num==10) sbi_shutdown();
    80200486:	5900006f          	j	80200a16 <sbi_shutdown>

000000008020048a <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020048a:	11853783          	ld	a5,280(a0)
    8020048e:	472d                	li	a4,11
    80200490:	02f76863          	bltu	a4,a5,802004c0 <exception_handler+0x36>
    80200494:	4705                	li	a4,1
    80200496:	00f71733          	sll	a4,a4,a5
    8020049a:	6785                	lui	a5,0x1
    8020049c:	17cd                	addi	a5,a5,-13
    8020049e:	8ff9                	and	a5,a5,a4
    802004a0:	ef99                	bnez	a5,802004be <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004a2:	1141                	addi	sp,sp,-16
    802004a4:	e022                	sd	s0,0(sp)
    802004a6:	e406                	sd	ra,8(sp)
    802004a8:	00877793          	andi	a5,a4,8
    802004ac:	842a                	mv	s0,a0
    802004ae:	e3b1                	bnez	a5,802004f2 <exception_handler+0x68>
    802004b0:	8b11                	andi	a4,a4,4
    802004b2:	eb09                	bnez	a4,802004c4 <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004b4:	6402                	ld	s0,0(sp)
    802004b6:	60a2                	ld	ra,8(sp)
    802004b8:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004ba:	e9bff06f          	j	80200354 <print_trapframe>
    802004be:	8082                	ret
    802004c0:	e95ff06f          	j	80200354 <print_trapframe>
            cprintf("Illegal instruction caught at 0x%08x\n",tf->epc);
    802004c4:	10853583          	ld	a1,264(a0)
    802004c8:	00000517          	auipc	a0,0x0
    802004cc:	6f050513          	addi	a0,a0,1776 # 80200bb8 <etext+0x14e>
    802004d0:	b9dff0ef          	jal	ra,8020006c <cprintf>
            cprintf("Exception type:Illegal instruction\n");
    802004d4:	00000517          	auipc	a0,0x0
    802004d8:	70c50513          	addi	a0,a0,1804 # 80200be0 <etext+0x176>
    802004dc:	b91ff0ef          	jal	ra,8020006c <cprintf>
            tf->epc += 4;
    802004e0:	10843783          	ld	a5,264(s0)
}
    802004e4:	60a2                	ld	ra,8(sp)
            tf->epc += 4;
    802004e6:	0791                	addi	a5,a5,4
    802004e8:	10f43423          	sd	a5,264(s0)
}
    802004ec:	6402                	ld	s0,0(sp)
    802004ee:	0141                	addi	sp,sp,16
    802004f0:	8082                	ret
            cprintf("ebreak caught at 0x%08x\n",tf->epc);
    802004f2:	10853583          	ld	a1,264(a0)
    802004f6:	00000517          	auipc	a0,0x0
    802004fa:	71250513          	addi	a0,a0,1810 # 80200c08 <etext+0x19e>
    802004fe:	b6fff0ef          	jal	ra,8020006c <cprintf>
            cprintf("Exception type:breakpoint\n");
    80200502:	00000517          	auipc	a0,0x0
    80200506:	72650513          	addi	a0,a0,1830 # 80200c28 <etext+0x1be>
    8020050a:	b63ff0ef          	jal	ra,8020006c <cprintf>
            tf->epc += 2;
    8020050e:	10843783          	ld	a5,264(s0)
}
    80200512:	60a2                	ld	ra,8(sp)
            tf->epc += 2;
    80200514:	0789                	addi	a5,a5,2
    80200516:	10f43423          	sd	a5,264(s0)
}
    8020051a:	6402                	ld	s0,0(sp)
    8020051c:	0141                	addi	sp,sp,16
    8020051e:	8082                	ret

0000000080200520 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200520:	11853783          	ld	a5,280(a0)
    80200524:	0007c463          	bltz	a5,8020052c <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200528:	f63ff06f          	j	8020048a <exception_handler>
        interrupt_handler(tf);
    8020052c:	e8bff06f          	j	802003b6 <interrupt_handler>

0000000080200530 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200530:	14011073          	csrw	sscratch,sp
    80200534:	712d                	addi	sp,sp,-288
    80200536:	e002                	sd	zero,0(sp)
    80200538:	e406                	sd	ra,8(sp)
    8020053a:	ec0e                	sd	gp,24(sp)
    8020053c:	f012                	sd	tp,32(sp)
    8020053e:	f416                	sd	t0,40(sp)
    80200540:	f81a                	sd	t1,48(sp)
    80200542:	fc1e                	sd	t2,56(sp)
    80200544:	e0a2                	sd	s0,64(sp)
    80200546:	e4a6                	sd	s1,72(sp)
    80200548:	e8aa                	sd	a0,80(sp)
    8020054a:	ecae                	sd	a1,88(sp)
    8020054c:	f0b2                	sd	a2,96(sp)
    8020054e:	f4b6                	sd	a3,104(sp)
    80200550:	f8ba                	sd	a4,112(sp)
    80200552:	fcbe                	sd	a5,120(sp)
    80200554:	e142                	sd	a6,128(sp)
    80200556:	e546                	sd	a7,136(sp)
    80200558:	e94a                	sd	s2,144(sp)
    8020055a:	ed4e                	sd	s3,152(sp)
    8020055c:	f152                	sd	s4,160(sp)
    8020055e:	f556                	sd	s5,168(sp)
    80200560:	f95a                	sd	s6,176(sp)
    80200562:	fd5e                	sd	s7,184(sp)
    80200564:	e1e2                	sd	s8,192(sp)
    80200566:	e5e6                	sd	s9,200(sp)
    80200568:	e9ea                	sd	s10,208(sp)
    8020056a:	edee                	sd	s11,216(sp)
    8020056c:	f1f2                	sd	t3,224(sp)
    8020056e:	f5f6                	sd	t4,232(sp)
    80200570:	f9fa                	sd	t5,240(sp)
    80200572:	fdfe                	sd	t6,248(sp)
    80200574:	14001473          	csrrw	s0,sscratch,zero
    80200578:	100024f3          	csrr	s1,sstatus
    8020057c:	14102973          	csrr	s2,sepc
    80200580:	143029f3          	csrr	s3,stval
    80200584:	14202a73          	csrr	s4,scause
    80200588:	e822                	sd	s0,16(sp)
    8020058a:	e226                	sd	s1,256(sp)
    8020058c:	e64a                	sd	s2,264(sp)
    8020058e:	ea4e                	sd	s3,272(sp)
    80200590:	ee52                	sd	s4,280(sp)

    move  a0, sp
    80200592:	850a                	mv	a0,sp
    jal trap
    80200594:	f8dff0ef          	jal	ra,80200520 <trap>

0000000080200598 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200598:	6492                	ld	s1,256(sp)
    8020059a:	6932                	ld	s2,264(sp)
    8020059c:	10049073          	csrw	sstatus,s1
    802005a0:	14191073          	csrw	sepc,s2
    802005a4:	60a2                	ld	ra,8(sp)
    802005a6:	61e2                	ld	gp,24(sp)
    802005a8:	7202                	ld	tp,32(sp)
    802005aa:	72a2                	ld	t0,40(sp)
    802005ac:	7342                	ld	t1,48(sp)
    802005ae:	73e2                	ld	t2,56(sp)
    802005b0:	6406                	ld	s0,64(sp)
    802005b2:	64a6                	ld	s1,72(sp)
    802005b4:	6546                	ld	a0,80(sp)
    802005b6:	65e6                	ld	a1,88(sp)
    802005b8:	7606                	ld	a2,96(sp)
    802005ba:	76a6                	ld	a3,104(sp)
    802005bc:	7746                	ld	a4,112(sp)
    802005be:	77e6                	ld	a5,120(sp)
    802005c0:	680a                	ld	a6,128(sp)
    802005c2:	68aa                	ld	a7,136(sp)
    802005c4:	694a                	ld	s2,144(sp)
    802005c6:	69ea                	ld	s3,152(sp)
    802005c8:	7a0a                	ld	s4,160(sp)
    802005ca:	7aaa                	ld	s5,168(sp)
    802005cc:	7b4a                	ld	s6,176(sp)
    802005ce:	7bea                	ld	s7,184(sp)
    802005d0:	6c0e                	ld	s8,192(sp)
    802005d2:	6cae                	ld	s9,200(sp)
    802005d4:	6d4e                	ld	s10,208(sp)
    802005d6:	6dee                	ld	s11,216(sp)
    802005d8:	7e0e                	ld	t3,224(sp)
    802005da:	7eae                	ld	t4,232(sp)
    802005dc:	7f4e                	ld	t5,240(sp)
    802005de:	7fee                	ld	t6,248(sp)
    802005e0:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005e2:	10200073          	sret

00000000802005e6 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005e6:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005ea:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005ec:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005f0:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005f2:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005f6:	f022                	sd	s0,32(sp)
    802005f8:	ec26                	sd	s1,24(sp)
    802005fa:	e84a                	sd	s2,16(sp)
    802005fc:	f406                	sd	ra,40(sp)
    802005fe:	e44e                	sd	s3,8(sp)
    80200600:	84aa                	mv	s1,a0
    80200602:	892e                	mv	s2,a1
    80200604:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200608:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    8020060a:	03067e63          	bleu	a6,a2,80200646 <printnum+0x60>
    8020060e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200610:	00805763          	blez	s0,8020061e <printnum+0x38>
    80200614:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    80200616:	85ca                	mv	a1,s2
    80200618:	854e                	mv	a0,s3
    8020061a:	9482                	jalr	s1
        while (-- width > 0)
    8020061c:	fc65                	bnez	s0,80200614 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    8020061e:	1a02                	slli	s4,s4,0x20
    80200620:	020a5a13          	srli	s4,s4,0x20
    80200624:	00001797          	auipc	a5,0x1
    80200628:	bdc78793          	addi	a5,a5,-1060 # 80201200 <error_string+0x38>
    8020062c:	9a3e                	add	s4,s4,a5
}
    8020062e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200630:	000a4503          	lbu	a0,0(s4)
}
    80200634:	70a2                	ld	ra,40(sp)
    80200636:	69a2                	ld	s3,8(sp)
    80200638:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020063a:	85ca                	mv	a1,s2
    8020063c:	8326                	mv	t1,s1
}
    8020063e:	6942                	ld	s2,16(sp)
    80200640:	64e2                	ld	s1,24(sp)
    80200642:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200644:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    80200646:	03065633          	divu	a2,a2,a6
    8020064a:	8722                	mv	a4,s0
    8020064c:	f9bff0ef          	jal	ra,802005e6 <printnum>
    80200650:	b7f9                	j	8020061e <printnum+0x38>

0000000080200652 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200652:	7119                	addi	sp,sp,-128
    80200654:	f4a6                	sd	s1,104(sp)
    80200656:	f0ca                	sd	s2,96(sp)
    80200658:	e8d2                	sd	s4,80(sp)
    8020065a:	e4d6                	sd	s5,72(sp)
    8020065c:	e0da                	sd	s6,64(sp)
    8020065e:	fc5e                	sd	s7,56(sp)
    80200660:	f862                	sd	s8,48(sp)
    80200662:	f06a                	sd	s10,32(sp)
    80200664:	fc86                	sd	ra,120(sp)
    80200666:	f8a2                	sd	s0,112(sp)
    80200668:	ecce                	sd	s3,88(sp)
    8020066a:	f466                	sd	s9,40(sp)
    8020066c:	ec6e                	sd	s11,24(sp)
    8020066e:	892a                	mv	s2,a0
    80200670:	84ae                	mv	s1,a1
    80200672:	8d32                	mv	s10,a2
    80200674:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    80200676:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    80200678:	00001a17          	auipc	s4,0x1
    8020067c:	9f4a0a13          	addi	s4,s4,-1548 # 8020106c <etext+0x602>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    80200680:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200684:	00001c17          	auipc	s8,0x1
    80200688:	b44c0c13          	addi	s8,s8,-1212 # 802011c8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020068c:	000d4503          	lbu	a0,0(s10)
    80200690:	02500793          	li	a5,37
    80200694:	001d0413          	addi	s0,s10,1
    80200698:	00f50e63          	beq	a0,a5,802006b4 <vprintfmt+0x62>
            if (ch == '\0') {
    8020069c:	c521                	beqz	a0,802006e4 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020069e:	02500993          	li	s3,37
    802006a2:	a011                	j	802006a6 <vprintfmt+0x54>
            if (ch == '\0') {
    802006a4:	c121                	beqz	a0,802006e4 <vprintfmt+0x92>
            putch(ch, putdat);
    802006a6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006a8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006aa:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006ac:	fff44503          	lbu	a0,-1(s0)
    802006b0:	ff351ae3          	bne	a0,s3,802006a4 <vprintfmt+0x52>
    802006b4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006b8:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006bc:	4981                	li	s3,0
    802006be:	4801                	li	a6,0
        width = precision = -1;
    802006c0:	5cfd                	li	s9,-1
    802006c2:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    802006c4:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    802006c8:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006ca:	fdd6069b          	addiw	a3,a2,-35
    802006ce:	0ff6f693          	andi	a3,a3,255
    802006d2:	00140d13          	addi	s10,s0,1
    802006d6:	20d5e563          	bltu	a1,a3,802008e0 <vprintfmt+0x28e>
    802006da:	068a                	slli	a3,a3,0x2
    802006dc:	96d2                	add	a3,a3,s4
    802006de:	4294                	lw	a3,0(a3)
    802006e0:	96d2                	add	a3,a3,s4
    802006e2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006e4:	70e6                	ld	ra,120(sp)
    802006e6:	7446                	ld	s0,112(sp)
    802006e8:	74a6                	ld	s1,104(sp)
    802006ea:	7906                	ld	s2,96(sp)
    802006ec:	69e6                	ld	s3,88(sp)
    802006ee:	6a46                	ld	s4,80(sp)
    802006f0:	6aa6                	ld	s5,72(sp)
    802006f2:	6b06                	ld	s6,64(sp)
    802006f4:	7be2                	ld	s7,56(sp)
    802006f6:	7c42                	ld	s8,48(sp)
    802006f8:	7ca2                	ld	s9,40(sp)
    802006fa:	7d02                	ld	s10,32(sp)
    802006fc:	6de2                	ld	s11,24(sp)
    802006fe:	6109                	addi	sp,sp,128
    80200700:	8082                	ret
    if (lflag >= 2) {
    80200702:	4705                	li	a4,1
    80200704:	008a8593          	addi	a1,s5,8
    80200708:	01074463          	blt	a4,a6,80200710 <vprintfmt+0xbe>
    else if (lflag) {
    8020070c:	26080363          	beqz	a6,80200972 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200710:	000ab603          	ld	a2,0(s5)
    80200714:	46c1                	li	a3,16
    80200716:	8aae                	mv	s5,a1
    80200718:	a06d                	j	802007c2 <vprintfmt+0x170>
            goto reswitch;
    8020071a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    8020071e:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200720:	846a                	mv	s0,s10
            goto reswitch;
    80200722:	b765                	j	802006ca <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    80200724:	000aa503          	lw	a0,0(s5)
    80200728:	85a6                	mv	a1,s1
    8020072a:	0aa1                	addi	s5,s5,8
    8020072c:	9902                	jalr	s2
            break;
    8020072e:	bfb9                	j	8020068c <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200730:	4705                	li	a4,1
    80200732:	008a8993          	addi	s3,s5,8
    80200736:	01074463          	blt	a4,a6,8020073e <vprintfmt+0xec>
    else if (lflag) {
    8020073a:	22080463          	beqz	a6,80200962 <vprintfmt+0x310>
        return va_arg(*ap, long);
    8020073e:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    80200742:	24044463          	bltz	s0,8020098a <vprintfmt+0x338>
            num = getint(&ap, lflag);
    80200746:	8622                	mv	a2,s0
    80200748:	8ace                	mv	s5,s3
    8020074a:	46a9                	li	a3,10
    8020074c:	a89d                	j	802007c2 <vprintfmt+0x170>
            err = va_arg(ap, int);
    8020074e:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200752:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200754:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    80200756:	41f7d69b          	sraiw	a3,a5,0x1f
    8020075a:	8fb5                	xor	a5,a5,a3
    8020075c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200760:	1ad74363          	blt	a4,a3,80200906 <vprintfmt+0x2b4>
    80200764:	00369793          	slli	a5,a3,0x3
    80200768:	97e2                	add	a5,a5,s8
    8020076a:	639c                	ld	a5,0(a5)
    8020076c:	18078d63          	beqz	a5,80200906 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    80200770:	86be                	mv	a3,a5
    80200772:	00001617          	auipc	a2,0x1
    80200776:	b3e60613          	addi	a2,a2,-1218 # 802012b0 <error_string+0xe8>
    8020077a:	85a6                	mv	a1,s1
    8020077c:	854a                	mv	a0,s2
    8020077e:	240000ef          	jal	ra,802009be <printfmt>
    80200782:	b729                	j	8020068c <vprintfmt+0x3a>
            lflag ++;
    80200784:	00144603          	lbu	a2,1(s0)
    80200788:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020078a:	846a                	mv	s0,s10
            goto reswitch;
    8020078c:	bf3d                	j	802006ca <vprintfmt+0x78>
    if (lflag >= 2) {
    8020078e:	4705                	li	a4,1
    80200790:	008a8593          	addi	a1,s5,8
    80200794:	01074463          	blt	a4,a6,8020079c <vprintfmt+0x14a>
    else if (lflag) {
    80200798:	1e080263          	beqz	a6,8020097c <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    8020079c:	000ab603          	ld	a2,0(s5)
    802007a0:	46a1                	li	a3,8
    802007a2:	8aae                	mv	s5,a1
    802007a4:	a839                	j	802007c2 <vprintfmt+0x170>
            putch('0', putdat);
    802007a6:	03000513          	li	a0,48
    802007aa:	85a6                	mv	a1,s1
    802007ac:	e03e                	sd	a5,0(sp)
    802007ae:	9902                	jalr	s2
            putch('x', putdat);
    802007b0:	85a6                	mv	a1,s1
    802007b2:	07800513          	li	a0,120
    802007b6:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007b8:	0aa1                	addi	s5,s5,8
    802007ba:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802007be:	6782                	ld	a5,0(sp)
    802007c0:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    802007c2:	876e                	mv	a4,s11
    802007c4:	85a6                	mv	a1,s1
    802007c6:	854a                	mv	a0,s2
    802007c8:	e1fff0ef          	jal	ra,802005e6 <printnum>
            break;
    802007cc:	b5c1                	j	8020068c <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007ce:	000ab603          	ld	a2,0(s5)
    802007d2:	0aa1                	addi	s5,s5,8
    802007d4:	1c060663          	beqz	a2,802009a0 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    802007d8:	00160413          	addi	s0,a2,1
    802007dc:	17b05c63          	blez	s11,80200954 <vprintfmt+0x302>
    802007e0:	02d00593          	li	a1,45
    802007e4:	14b79263          	bne	a5,a1,80200928 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007e8:	00064783          	lbu	a5,0(a2)
    802007ec:	0007851b          	sext.w	a0,a5
    802007f0:	c905                	beqz	a0,80200820 <vprintfmt+0x1ce>
    802007f2:	000cc563          	bltz	s9,802007fc <vprintfmt+0x1aa>
    802007f6:	3cfd                	addiw	s9,s9,-1
    802007f8:	036c8263          	beq	s9,s6,8020081c <vprintfmt+0x1ca>
                    putch('?', putdat);
    802007fc:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    802007fe:	18098463          	beqz	s3,80200986 <vprintfmt+0x334>
    80200802:	3781                	addiw	a5,a5,-32
    80200804:	18fbf163          	bleu	a5,s7,80200986 <vprintfmt+0x334>
                    putch('?', putdat);
    80200808:	03f00513          	li	a0,63
    8020080c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020080e:	0405                	addi	s0,s0,1
    80200810:	fff44783          	lbu	a5,-1(s0)
    80200814:	3dfd                	addiw	s11,s11,-1
    80200816:	0007851b          	sext.w	a0,a5
    8020081a:	fd61                	bnez	a0,802007f2 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    8020081c:	e7b058e3          	blez	s11,8020068c <vprintfmt+0x3a>
    80200820:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200822:	85a6                	mv	a1,s1
    80200824:	02000513          	li	a0,32
    80200828:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020082a:	e60d81e3          	beqz	s11,8020068c <vprintfmt+0x3a>
    8020082e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200830:	85a6                	mv	a1,s1
    80200832:	02000513          	li	a0,32
    80200836:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200838:	fe0d94e3          	bnez	s11,80200820 <vprintfmt+0x1ce>
    8020083c:	bd81                	j	8020068c <vprintfmt+0x3a>
    if (lflag >= 2) {
    8020083e:	4705                	li	a4,1
    80200840:	008a8593          	addi	a1,s5,8
    80200844:	01074463          	blt	a4,a6,8020084c <vprintfmt+0x1fa>
    else if (lflag) {
    80200848:	12080063          	beqz	a6,80200968 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    8020084c:	000ab603          	ld	a2,0(s5)
    80200850:	46a9                	li	a3,10
    80200852:	8aae                	mv	s5,a1
    80200854:	b7bd                	j	802007c2 <vprintfmt+0x170>
    80200856:	00144603          	lbu	a2,1(s0)
            padc = '-';
    8020085a:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    8020085e:	846a                	mv	s0,s10
    80200860:	b5ad                	j	802006ca <vprintfmt+0x78>
            putch(ch, putdat);
    80200862:	85a6                	mv	a1,s1
    80200864:	02500513          	li	a0,37
    80200868:	9902                	jalr	s2
            break;
    8020086a:	b50d                	j	8020068c <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    8020086c:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    80200870:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200874:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    80200876:	846a                	mv	s0,s10
            if (width < 0)
    80200878:	e40dd9e3          	bgez	s11,802006ca <vprintfmt+0x78>
                width = precision, precision = -1;
    8020087c:	8de6                	mv	s11,s9
    8020087e:	5cfd                	li	s9,-1
    80200880:	b5a9                	j	802006ca <vprintfmt+0x78>
            goto reswitch;
    80200882:	00144603          	lbu	a2,1(s0)
            padc = '0';
    80200886:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    8020088a:	846a                	mv	s0,s10
            goto reswitch;
    8020088c:	bd3d                	j	802006ca <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    8020088e:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    80200892:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    80200896:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200898:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    8020089c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008a0:	fcd56ce3          	bltu	a0,a3,80200878 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    802008a4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802008a6:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    802008aa:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802008ae:	0196873b          	addw	a4,a3,s9
    802008b2:	0017171b          	slliw	a4,a4,0x1
    802008b6:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802008ba:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802008be:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802008c2:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008c6:	fcd57fe3          	bleu	a3,a0,802008a4 <vprintfmt+0x252>
    802008ca:	b77d                	j	80200878 <vprintfmt+0x226>
            if (width < 0)
    802008cc:	fffdc693          	not	a3,s11
    802008d0:	96fd                	srai	a3,a3,0x3f
    802008d2:	00ddfdb3          	and	s11,s11,a3
    802008d6:	00144603          	lbu	a2,1(s0)
    802008da:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    802008dc:	846a                	mv	s0,s10
    802008de:	b3f5                	j	802006ca <vprintfmt+0x78>
            putch('%', putdat);
    802008e0:	85a6                	mv	a1,s1
    802008e2:	02500513          	li	a0,37
    802008e6:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802008e8:	fff44703          	lbu	a4,-1(s0)
    802008ec:	02500793          	li	a5,37
    802008f0:	8d22                	mv	s10,s0
    802008f2:	d8f70de3          	beq	a4,a5,8020068c <vprintfmt+0x3a>
    802008f6:	02500713          	li	a4,37
    802008fa:	1d7d                	addi	s10,s10,-1
    802008fc:	fffd4783          	lbu	a5,-1(s10)
    80200900:	fee79de3          	bne	a5,a4,802008fa <vprintfmt+0x2a8>
    80200904:	b361                	j	8020068c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    80200906:	00001617          	auipc	a2,0x1
    8020090a:	99a60613          	addi	a2,a2,-1638 # 802012a0 <error_string+0xd8>
    8020090e:	85a6                	mv	a1,s1
    80200910:	854a                	mv	a0,s2
    80200912:	0ac000ef          	jal	ra,802009be <printfmt>
    80200916:	bb9d                	j	8020068c <vprintfmt+0x3a>
                p = "(null)";
    80200918:	00001617          	auipc	a2,0x1
    8020091c:	98060613          	addi	a2,a2,-1664 # 80201298 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200920:	00001417          	auipc	s0,0x1
    80200924:	97940413          	addi	s0,s0,-1671 # 80201299 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200928:	8532                	mv	a0,a2
    8020092a:	85e6                	mv	a1,s9
    8020092c:	e032                	sd	a2,0(sp)
    8020092e:	e43e                	sd	a5,8(sp)
    80200930:	102000ef          	jal	ra,80200a32 <strnlen>
    80200934:	40ad8dbb          	subw	s11,s11,a0
    80200938:	6602                	ld	a2,0(sp)
    8020093a:	01b05d63          	blez	s11,80200954 <vprintfmt+0x302>
    8020093e:	67a2                	ld	a5,8(sp)
    80200940:	2781                	sext.w	a5,a5
    80200942:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    80200944:	6522                	ld	a0,8(sp)
    80200946:	85a6                	mv	a1,s1
    80200948:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020094a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    8020094c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020094e:	6602                	ld	a2,0(sp)
    80200950:	fe0d9ae3          	bnez	s11,80200944 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200954:	00064783          	lbu	a5,0(a2)
    80200958:	0007851b          	sext.w	a0,a5
    8020095c:	e8051be3          	bnez	a0,802007f2 <vprintfmt+0x1a0>
    80200960:	b335                	j	8020068c <vprintfmt+0x3a>
        return va_arg(*ap, int);
    80200962:	000aa403          	lw	s0,0(s5)
    80200966:	bbf1                	j	80200742 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    80200968:	000ae603          	lwu	a2,0(s5)
    8020096c:	46a9                	li	a3,10
    8020096e:	8aae                	mv	s5,a1
    80200970:	bd89                	j	802007c2 <vprintfmt+0x170>
    80200972:	000ae603          	lwu	a2,0(s5)
    80200976:	46c1                	li	a3,16
    80200978:	8aae                	mv	s5,a1
    8020097a:	b5a1                	j	802007c2 <vprintfmt+0x170>
    8020097c:	000ae603          	lwu	a2,0(s5)
    80200980:	46a1                	li	a3,8
    80200982:	8aae                	mv	s5,a1
    80200984:	bd3d                	j	802007c2 <vprintfmt+0x170>
                    putch(ch, putdat);
    80200986:	9902                	jalr	s2
    80200988:	b559                	j	8020080e <vprintfmt+0x1bc>
                putch('-', putdat);
    8020098a:	85a6                	mv	a1,s1
    8020098c:	02d00513          	li	a0,45
    80200990:	e03e                	sd	a5,0(sp)
    80200992:	9902                	jalr	s2
                num = -(long long)num;
    80200994:	8ace                	mv	s5,s3
    80200996:	40800633          	neg	a2,s0
    8020099a:	46a9                	li	a3,10
    8020099c:	6782                	ld	a5,0(sp)
    8020099e:	b515                	j	802007c2 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    802009a0:	01b05663          	blez	s11,802009ac <vprintfmt+0x35a>
    802009a4:	02d00693          	li	a3,45
    802009a8:	f6d798e3          	bne	a5,a3,80200918 <vprintfmt+0x2c6>
    802009ac:	00001417          	auipc	s0,0x1
    802009b0:	8ed40413          	addi	s0,s0,-1811 # 80201299 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009b4:	02800513          	li	a0,40
    802009b8:	02800793          	li	a5,40
    802009bc:	bd1d                	j	802007f2 <vprintfmt+0x1a0>

00000000802009be <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009be:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009c0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009c4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009c6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009c8:	ec06                	sd	ra,24(sp)
    802009ca:	f83a                	sd	a4,48(sp)
    802009cc:	fc3e                	sd	a5,56(sp)
    802009ce:	e0c2                	sd	a6,64(sp)
    802009d0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009d2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009d4:	c7fff0ef          	jal	ra,80200652 <vprintfmt>
}
    802009d8:	60e2                	ld	ra,24(sp)
    802009da:	6161                	addi	sp,sp,80
    802009dc:	8082                	ret

00000000802009de <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    802009de:	00003797          	auipc	a5,0x3
    802009e2:	62278793          	addi	a5,a5,1570 # 80204000 <bootstacktop>
    __asm__ volatile (
    802009e6:	6398                	ld	a4,0(a5)
    802009e8:	4781                	li	a5,0
    802009ea:	88ba                	mv	a7,a4
    802009ec:	852a                	mv	a0,a0
    802009ee:	85be                	mv	a1,a5
    802009f0:	863e                	mv	a2,a5
    802009f2:	00000073          	ecall
    802009f6:	87aa                	mv	a5,a0
}
    802009f8:	8082                	ret

00000000802009fa <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    802009fa:	00003797          	auipc	a5,0x3
    802009fe:	61e78793          	addi	a5,a5,1566 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    80200a02:	6398                	ld	a4,0(a5)
    80200a04:	4781                	li	a5,0
    80200a06:	88ba                	mv	a7,a4
    80200a08:	852a                	mv	a0,a0
    80200a0a:	85be                	mv	a1,a5
    80200a0c:	863e                	mv	a2,a5
    80200a0e:	00000073          	ecall
    80200a12:	87aa                	mv	a5,a0
}
    80200a14:	8082                	ret

0000000080200a16 <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a16:	00003797          	auipc	a5,0x3
    80200a1a:	5f278793          	addi	a5,a5,1522 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200a1e:	6398                	ld	a4,0(a5)
    80200a20:	4781                	li	a5,0
    80200a22:	88ba                	mv	a7,a4
    80200a24:	853e                	mv	a0,a5
    80200a26:	85be                	mv	a1,a5
    80200a28:	863e                	mv	a2,a5
    80200a2a:	00000073          	ecall
    80200a2e:	87aa                	mv	a5,a0
    80200a30:	8082                	ret

0000000080200a32 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200a32:	c185                	beqz	a1,80200a52 <strnlen+0x20>
    80200a34:	00054783          	lbu	a5,0(a0)
    80200a38:	cf89                	beqz	a5,80200a52 <strnlen+0x20>
    size_t cnt = 0;
    80200a3a:	4781                	li	a5,0
    80200a3c:	a021                	j	80200a44 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200a3e:	00074703          	lbu	a4,0(a4)
    80200a42:	c711                	beqz	a4,80200a4e <strnlen+0x1c>
        cnt ++;
    80200a44:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a46:	00f50733          	add	a4,a0,a5
    80200a4a:	fef59ae3          	bne	a1,a5,80200a3e <strnlen+0xc>
    }
    return cnt;
}
    80200a4e:	853e                	mv	a0,a5
    80200a50:	8082                	ret
    size_t cnt = 0;
    80200a52:	4781                	li	a5,0
}
    80200a54:	853e                	mv	a0,a5
    80200a56:	8082                	ret

0000000080200a58 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a58:	ca01                	beqz	a2,80200a68 <memset+0x10>
    80200a5a:	962a                	add	a2,a2,a0
    char *p = s;
    80200a5c:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a5e:	0785                	addi	a5,a5,1
    80200a60:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a64:	fec79de3          	bne	a5,a2,80200a5e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a68:	8082                	ret
