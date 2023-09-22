# Lab 1

#### 练习 1: 理解内核启动中的程序入口操作

>阅读 kern/init/entry.S内容代码，结合操作系统内核启动流程,说明指令 la sp, bootstacktop 完成了什么操作，目的是什么？ tail kern_init 完成了什么操作，目的是什么？

* `la sp, bootstacktop`指令的作用是将`bootstacktop`(内核栈栈顶指针)中的值赋值给`sp`(当前栈顶指针)，作用是分配好内核栈，开辟内核栈的栈帧空间。
* `tail kern_init` 表示跳转到 `kern_init` 标签处执行，并在执行完 `kern_init` 后返回到 `kern_entry` 函数的调用点。此处采用的调用方式是尾调用，这种函数调用是在函数的最后一条语句中进行的，而且没有需要在函数返回时执行的后续操作。由于没有后续操作，因此在尾调用时可以优化函数调用的开销，而不需要保留函数调用的调用栈帧，优点是减少递归函数的调用栈深度，从而降低了内存使用，减少了潜在的栈溢出风险。  



#### 练习 2：完善中断处理 （需要编程）

>请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写kern/trap/trap.c函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”，在打印完10行后调用sbi.h中的shut_down()函数关机。  
要求完成问题1提出的相关函数实现，提交改进后的源代码包（可以编译执行），并在实验报告中简要说明实现过程和定时器中断中断处理的流程。实现要求的部分代码后，运行整个系统，大约每1秒会输出一次”100 ticks”，输出10行。  

**实现代码如下：**  
```
clock_set_next_event();
ticks++;
if(ticks==TICK_NUM){
    num++;
    ticks-=TICK_NUM;
    print_ticks();
    if(num==10) sbi_shutdown();
}
break;
```

**输出结果如下**
```
Special kernel symbols:
  entry  0x000000008020000c (virtual)
  etext  0x00000000802009de (virtual)
  edata  0x0000000080204010 (virtual)
  end    0x0000000080204028 (virtual)
Kernel executable memory footprint: 17KB
++ setup timer interrupts
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
```

**实现过程:**   
在trap.c的interrupt_handler对应位置按照要求编写好触发中断后的输出代码。 

**定时器中断中断处理的流程：**  

1. 中断向量表基址存入寄存器：在`init.c`中,调用中断初始化函数`idt_init()`将&__alltraps（中断向量表基址）写入stvec寄存器
2. 设置第一个触发时间中断事件：调用函数`clock_init()`初始化中断事件，其中的函数`clock_set_next_event()`设置了第一个时钟中断事件
3. 设置中断使能位。
4. 中断的检测与处理：当中断发生时，硬件检测到中断发生，跳转到stvec寄存的&__alltraps（中断向量表基址）开始执行，在`SAVE_ALL`（存储上下文）之后，`jal trap`跳转到在trap()中，并调用trapdispatch()区分中断和异常，进一步根据原因区分中断的类型，运行时间中断对应的处理函数
5. 处理完后返回alltraps中进行trapret恢复中断前上下文，中断结束



#### 扩展练习 Challenge1：描述与理解中断流程

>回答：描述ucore中处理中断异常的流程（从异常的产生开始），其中mov a0，sp的目的是什么？SAVE_ALL中寄寄存器保存在栈中的位置是什么确定的？对于任何中断，__alltraps 中都需要保存所有寄存器吗？请说明理由。  

**ucore中处理中断异常的流程**
* set_sbi_timer()通过OpenSBI的时钟事件触发一个中断，跳转到kern/trap/trapentry.S的__alltraps标记   
* 保存当前执行流的上下文，并通过函数调用，切换为kern/trap/trap.c的中断处理函数trap()的上下文，进入trap()的执行流。切换前的上下文作为一个结构体，传递给trap()作为函数参数   
* kern/trap/trap.c按照中断类型进行分发(trap_dispatch(), interrupt_handler())  * 执行时钟中断对应的处理语句，累加计数器，设置下一次时钟中断->完成处理，返回到kern/trap/trapentry.S  
* 恢复原先的上下文，中断处理结束   

`mov a0,sp` 这条指令将当前栈指针 sp 的值存储在寄存器 a0 中。这个操作的目的是将栈指针的值传递给中断处理程序，以便异常处理程序可以访问当前的栈上内容。  
`SAVE_ALL`  寄存器保存在栈中的位置是由sp的偏移地址决定的。  
`__alltraps` 中不一定需要保存所有寄存器。实际的寄存器保存和恢复操作通常取决于中断或异常处理程序的需求。有些寄存器可能在处理过程中不需要保存，因为它们的值可以不变地传递给异常处理程序，而有些寄存器可能需要保存，以便确保程序的正确执行。处理中断时，常见的做法是保存被破坏的寄存器和状态信息，以便在处理完成后能够恢复到先前的状态。然而，不是所有的寄存器都需要在每个异常或中断中保存，这取决于具体的处理逻辑和性能需求。  



#### 扩增练习 Challenge2：理解上下文切换机制

>回答：在trapentry.S中汇编代码 csrw sscratch, sp；csrrw s0, sscratch, x0实现了什么操作，目的是什么？save all里面保存了stval scause这些csr，而在restore all里面却不还原它们？那这样store的意义何在呢？  

* `sscratch`寄存器可以用于保存任务或中断处理程序的临时上下文信息.  
`csrw sscratch, sp`：这是一个`csrw`指令，将栈指针（sp）的值写入`sscratch`寄存器(`sscratch`是一个控制和状态寄存器，用于存储临时数据或上下文信息)。该指令将栈指针的值存储在`sscratch`寄存器中。  
`csrrw s0, sscratch, x0`：这是一个`csrrw`指令，它首先将`sscratch`寄存器的当前值读入`s0`寄存器，然后将`x0`的值写入`sscratch`寄存器。`x0`寄存器是零寄存器，其值始终为零。因此，这个指令的作用是将`sscratch`寄存器的当前值存储在`s0`寄存器中，并将`sscratch`寄存器重置为零。  
上述两行代码将栈指针的值存储在`sscratch`寄存器中，并将`sscratch`寄存器的值存储在`s0`寄存器中，同时将`sscratch`寄存器重置为零。于是存储在`sscratch`中的上下文信息就被存储到了栈中，并且`sscratch`被置零，方便后续继续存储上下文信息。
* `stval` ：`stval` 寄存器用于存储发生异常或中断时相关存储操作的特定值。它记录了最近一次的存储访问异常或页面错误的虚拟地址.  
`scause`：`scause` 寄存器用于存储导致异常或中断的原因代码。它记录了最近一次发生的异常或中断的类型和原因。
上述提到的两个寄存器均是只读寄存器。通过读取 `stval` 和 `scause` 寄存器的值，软件可以了解到最近发生的异常或中断的详细信息，进而进行相应的处理措施。  
为了更好地理解为什么在存储上下文时保存这些 CSR，但在恢复上下文时没有显式还原它们，我们需要考虑以下几点：  
1. 异常发生时的保存：当中断或异常发生时，保存上下文的目的是记录当前执行状态，以便在处理完中断或异常后能够正确地恢复。此时，将 `stval` 和 `scause` 等 CSR 的值保存下来是为了记录最近发生的异常或中断的相关信息。
2. 中断处理程序的处理：中断处理程序负责处理异常或中断，并根据需要采取相应的操作。在大多数情况下，中断处理程序执行完毕后会通过特定的指令（如 `mret`）来返回到被中断的程序执行。这个过程中，处理器会自动将之前保存的上下文恢复回来，包括之前保存的通用寄存器和其他控制和状态寄存器。
3. 使用恢复的上下文：恢复的上下文中不包括明确的 `stval` 和 `scause` 的还原操作是因为它们是只读 CSR，其值由硬件根据异常或中断的发生自动设置，且不能被软件写入。它们的值主要是供软件读取以了解异常或中断的详细信息。因此，在恢复到之前保存的上下文后，软件可以通过相应的 CSR 读取指令来访问 `stval` 和 `scause` 的值，以获取之前发生的异常或中断的相关信息。 

因此可以得出结论，存储上下文时保存 `stval` 和 `scause` 等 CSR 的值是为了记录异常或中断的相关信息，在中断处理结束后，该信息作用发挥完毕，因此不需要恢复。



#### 扩展练习Challenge3：完善异常中断

>编程完善在触发一条非法指令异常 mret和，在 kern/trap/trap.c的异常处理函数中捕获，并对其进行处理，简单输出异常类型和异常指令触发地址，即“Illegal instruction caught at 0x(地址)”，“ebreak caught at 0x（地址）”与“Exception type:Illegal instruction”，“Exception type: breakpoint”。

**中断代码如下所示(仅展示修改增加部分)**

```
//kern/init.c
int kern_init(void) {
    ...
    // __asm__ __volatile__("mret");//非法指令触发中断
    __asm__ __volatile__("ebreak");//断点触发异常
   ...
}
```
```
//trap/trap.c
void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
        ...
        case CAUSE_ILLEGAL_INSTRUCTION:
             // 非法指令异常处理
             /* LAB1 CHALLENGE3   YOUR CODE :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Illegal instruction caught at 0x%08x\n",tf->epc);
            cprintf("Exception type:Illegal instruction\n");
            tf->epc += 4;
            
            break;
        case CAUSE_BREAKPOINT:
            //断点异常处理
            /* LAB1 CHALLLENGE3   YOUR CODE :  */
            /*(1)输出指令异常类型（ breakpoint）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("ebreak caught at 0x%08x\n",tf->epc);
            cprintf("Exception type:breakpoint\n");
            tf->epc += 2;
            break;
        ...
        }
  }
```
通过内联汇编在`init.c`中添加中断指令，当程序运行至此触发异常自动被异常捕获程序捕获跳转到`trap.c`中处理，按照中断类型进行分发。当触发非法指令或断点异常时，会被编写添加的异常处理程序捕获，其中`epc`寄存器存储了引发异常的指令地址,通过格式占位符输出触发异常的地址。需要注意的是，`mret`指令占用四个字节的长度，因此通过将 `tf->epc` 增加4，可以将程序计数器（PC）移至下一条指令的地址，以便程序在异常处理程序返回后能够继续执行正确的指令，而`ebreak`指令长度为两个字节，因此需要 `tf->epc += 2`。

中断结果如下
```
//ebreak exception
Special kernel symbols:
  entry  0x000000008020000c (virtual)
  etext  0x0000000080200a6e (virtual)
  edata  0x0000000080204010 (virtual)
  end    0x0000000080204028 (virtual)
Kernel executable memory footprint: 17KB
++ setup timer interrupts
ebreak caught at 0x80200050
Exception type:breakpoint
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
```
```
//illegal exception
Special kernel symbols:
  entry  0x000000008020000c (virtual)
  etext  0x0000000080200a6e (virtual)
  edata  0x0000000080204010 (virtual)
  end    0x0000000080204028 (virtual)
Kernel executable memory footprint: 17KB
++ setup timer interrupts
sbi_emulate_csr_read: hartid0: invalid csr_num=0x302
Illegal instruction caught at 0x80200050
Exception type:Illegal instruction
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
```
