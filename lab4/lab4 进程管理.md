# lab4 进程管理

[TOC]



## 实验目的

- 了解内核线程创建/执行的管理过程

- 了解内核线程的切换和基本调度过程

  

## 实验内容

#### 练习0：填写已有实验

> 本实验依赖实验2/3。请把你做的实验2/3的代码填入本实验中代码中有“LAB2”,“LAB3”的注释相应部分。

本实验需要填写kern/mm/vmm.c中do_pgfault()函数。

#### 练习1：分配并初始化一个进程控制块（需要编码）

> alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程
>
> > 【提示】在alloc_proc函数的实现中，需要初始化的proc_struct结构中的成员变量至少包括：state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name。
>
> 请在实验报告中简要说明你的设计实现过程。请回答如下问题：
>
> - 请说明proc_struct中`struct context context`和`struct trapframe *tf`成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

alloc_proc()函数补充如下：

```c
alloc_proc(void) {
    //创建一个PCB结构体的指针，为其动态分配内存
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
        proc->state = PROC_UNINIT;  //设置进程为未初始化状态
        //PROC_UNINIT // 未初始状态
        //PROC_SLEEPING // 睡眠（阻塞）状态
        //PROC_RUNNABLE // 运行与就绪态
        //PROC_ZOMBIE // 僵死状态
        proc->pid = -1;             //未初始化的的进程id为-1
        proc->runs = 0;             //初始化时间片
        proc->kstack = 0;           //内存栈的地址
        //对于内核线程：运行时使用的栈
        //对于普通进程：发生特权级改变的时候使保存被打断的硬件信息用的栈
        proc->need_resched = 0;     //是否需要调度设为不需要
        proc->parent = NULL;        //父节点设为空
        proc->mm = NULL;            //虚拟内存设为空
        memset(&(proc->context), 0, sizeof(struct context));//上下文的初始化
        proc->tf = NULL;            //中断帧指针置为空
        proc->cr3 = boot_cr3;       //页目录设为内核页目录表的基址
        //因为所有内核线程从属于同一个唯一的内核进程，共享同一个内核地址空间
        proc->flags = 0;            //标志位
        memset(proc->name, 0, PROC_NAME_LEN);//进程名

    }
    return proc;
}
```

该函数创建了一个PCB结构体，并对其属性进行了初始化。

##### struct context context

该结构体存储了ra, sp, s0 ~ s11 共十四个寄存器用于保存进程运行的上下文信息。因此，在进行进程之间的调度与切换时，可以将原先的上下文信息保存，以便后续恢复。

在该结构体中仅保存了被调用者保存寄存器，因为在线程切换时，编译器会自动保存调用者保存寄存器的代码。

##### struct trapframe *tf

如果进程之间发生了调度，切换进程是使用中断返回的方式进行的，因此需要构造出一个伪造的中断返回现场 trapframe ，用于保存中断信息，使得进程切换可以顺利执行。

#### 练习2：为新创建的内核线程分配资源（需要编码）

> 创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用**do_fork**函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们**实际需要"fork"的东西就是stack和trapframe**。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：
>
> - 调用alloc_proc，首先获得一块用户信息块。
> - 为进程分配一个内核栈。
> - 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
> - 复制原进程上下文到新进程
> - 将新进程添加到进程列表
> - 唤醒新进程
> - 返回新进程号
>
> 请在实验报告中简要说明你的设计实现过程。请回答如下问题：
>
> - 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。

程序从init.c开始执行，执行完proc_init()函数，创建idle进程后，使用kernel_thread()函数创建新进程initproc，创建过程中使用do_fork()函数从idle进程中fork出init进程。

do_fork()函数中完成了如下功能：

##### 1、分配并初始化进程控制块

```c
int ret = -E_NO_FREE_PROC;
struct proc_struct *proc;
if (nr_process >= MAX_PROCESS) {
    goto fork_out;
}
ret = -E_NO_MEM;
if ((proc = alloc_proc()) == NULL) { //调用 alloc_proc() 函数申请内存块，如果失败，直接返回处理
    goto fork_out;//返回
}
fork_out: //已分配进程数大于 4096
    return ret;
```

在该部分，先将ret设置为宏`-E_NO_FREE_PROC`，若创建的进程数大于MAX_PROCESS，则返回无可用进程。此处将ret设置为宏`-E_NO_MEM`，若通过alloc_proc函数未能分配到进程控制块，则返回无可用内存。

##### 2、分配并初始化内核栈，为内核进程（线程） 建立栈空间（ setup_stack 函数）

```c
proc->parent = current; //将子进程的父节点设置为当前进程idle

if (setup_kstack(proc) != 0) { //调用 setup_stack() 函数为进程分配一个内核栈
    goto bad_fork_cleanup_proc; //返回
}
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```

该部分为内核进程建立栈空间。

```c
setup_kstack(struct proc_struct *proc) {
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL) {
        proc->kstack = (uintptr_t)page2kva(page);
        return 0;
    }
    return -E_NO_MEM;
}
```

在setup_kstack函数中，为当前内核进程栈分配了两个页面大小，若分配失败，则返回无可用内存。

##### 3、根据 clone_flag 标志复制或共享进程内存管理结构（ copy_mm 函数）

```c
if (copy_mm(clone_flags, proc) != 0) { //调用 copy_mm() 函数复制父进程的内存信息到子进程
    goto bad_fork_cleanup_kstack; //返回
}
```

当前函数将父进程的内存信息复制到子进程，但本实验中copy_mm函数中未进行任何操作。

```c
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    assert(current->mm == NULL);
    /* do nothing in this project */
    return 0;
}
```

##### 4、设置进程的中断帧和执行上下文 （ copy_thread 函数）

```c
copy_thread(proc, stack, tf); //调用 copy_thread() 函数复制父进程的中断帧和上下文信息
```

```c
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    //分配一片空间保存新进程的trapframe
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
    //新进程的tf初始化为源进程相同
    *(proc->tf) = *tf;

    // Set a0 to 0 so a child process knows it's just forked
    proc->tf->gpr.a0 = 0;
    //将新进程的 tf 结构体中的栈指针寄存器 sp 的值设置为 esp（如果 esp 不为0）
    //否则设置为 tf 结构体的地址
    //用于指定新进程的栈指针
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
    //将新进程的上下文结构 context 中的返回地址寄存器 ra 设置为 forkret 函数的地址
    //用于指定当新进程执行完毕后要返回的地址
    proc->context.ra = (uintptr_t)forkret;
    //将新进程的上下文结构 context 中的栈指针寄存器 sp 设置为新进程的 tf 结构体的地址
    //表示新进程的栈指针
    proc->context.sp = (uintptr_t)(proc->tf);
}
```

在copy_thread函数中，复制了原进程的trapframe与上下文信息。其中，上下文信息中的a0寄存器设置为0，表示该进程为复制得来；将新进程的上下文结构 context 中的返回地址寄存器 ra 设置为 forkret 函数的地址，用于指定当新进程执行完毕后要返回的地址；将新进程的上下文结构 context 中的栈指针寄存器 sp 设置为新进程的 tf 结构体的地址，表示新进程的栈指针。

##### 5、把设置好的进程控制块放入 hash_list 和 proc_list 两个全局进程链表中

```c
bool intr_flag;
local_intr_save(intr_flag); //屏蔽中断，intr_flag 置为 1
{
    proc->pid = get_pid(); //获取当前进程 PID
    hash_proc(proc); //建立 hash 映射
    list_add(&proc_list, &(proc->list_link)); //将进程加入到进程的链表中
    nr_process++; //进程数加 1
}
local_intr_restore(intr_flag); //恢复中断
```

该过程需要使用关中断保证该操作不被打断。hash_link通过pid链入hash_list，list_link链入proc_list。

##### 6、将新建的进程设为就绪态

```c
wakeup_proc(proc); //一切就绪，唤醒子进程
```

```c
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}
```

##### 7、将返回值设为线程id

```c
ret = proc->pid; //返回子进程的 pid
```



- 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。

可以。

get_pid函数原型如下：

```c
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    //last_pid :保存上一次分配的PID
    //next_safe : next_safe 和 last_pid 一起表示一段可以使用的 PID 取值范围

    //检查 last_pid 是否已经达到了 MAX_PID
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            //确保了不存在任何进程的 pid 与 last_pid 重合
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            //保证了不存在任何已经存在的 pid 满足：last_pid < pid < next_safe
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}
```

在该函数中定义了两个变量 next_safe与last_pid 。last_pid 用于保存上一次分配的PID，next_safe 和 last_pid 一起表示一段可以使用的 PID 取值范围。

该函数通过遍历所有进程的pid，不断修改next_safe与last_pid，确保新进程不会分配到之前进程的进程号。 if (proc->pid == last_pid) 确保了不存在任何进程的 pid 与 last_pid 重合，else if (proc->pid > last_pid && next_safe > proc->pid)保证了不存在任何已经存在的 pid 满足last_pid < pid < next_safe，通过不断缩小范围，最终确定新分配的pid。

#### 练习3：编写proc_run 函数（需要编码）

>proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：
>
>- 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
>- 禁用中断。你可以使用`/kern/sync/sync.h`中定义好的宏`local_intr_save(x)`和`local_intr_restore(x)`来实现关、开中断。
>- 切换当前进程为要运行的进程。
>- 切换页表，以便使用新进程的地址空间。`/libs/riscv.h`中提供了`lcr3(unsigned int cr3)`函数，可实现修改CR3寄存器值的功能。
>- 实现上下文切换。`/kern/process`中已经预先编写好了`switch.S`，其中定义了`switch_to()`函数。可实现两个进程的context切换。
>- 允许中断。
>
>请回答如下问题：
>
>- 在本实验的执行过程中，创建且运行了几个内核线程？
>

在init.c的最后，使用cpu_idle函数，完成进程的调度，在进程调度成功后，便使用proc_run函数运行进程。

```c
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        bool intr_flag;
        struct proc_struct* prev = current, * next = proc;
        local_intr_save(intr_flag); // 关闭中断
        {
            current = proc; // 将当前进程换为要切换到的进程
            lcr3(next->cr3); // 重新加载 cr3 寄存器(页目录表基址) 进行进程间的页表切换，修改当前的 cr3 寄存器成需要运行线程（进程）的页目录表
            switch_to(&(prev->context), &(next->context)); // 调用 switch_to 进行上下文的保存与切换，切换到新的线程
        }
        local_intr_restore(intr_flag);
    }
}
```

该函数首先关闭中断，并进行进程切换，重新加载 cr3 寄存器(页目录表基址) 进行进程间的页表切换，修改当前的 cr3 寄存器成需要运行线程（进程）的页目录表，调用 switch_to 进行上下文的保存与切换，切换到新的线程，最后启用中断。

- 在本实验的执行过程中，创建且运行了几个内核线程？

总共创建了两个内核线程，分别为：

**idle_proc**：第 0 个内核线程，在完成新的内核线程的创建以及各种初始化工作之后，进入死循环，用于调度其他进程或线程。

**init_proc**：被创建用于打印 "Hello World" 的线程。本次实验的内核线程，只用来打印字符串。

#### 扩展练习 Challenge

> - 说明语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`是如何实现开关中断的？

我们以关中断`local_intr_save(intr_flag)`函数为例，观察一下其跳转过程：

（开启中断函数跳转过程附文末，正文不赘述）

- 调用函数`local_intr_save(intr_flag)`

—>sync.h中的宏定义#define local_intr_save(x)

```c
#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
```
—>sync.h中的函数static inline bool __intr_save(void)

```c
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}
```

—>intr.c中的函数void intr_disable(void)

```c
void intr_disable(void) { 
	clear_csr(sstatus, SSTATUS_SIE); 
}
```

可以看到，该禁用中断过程是通过判断状态位SSTATUS_SIE的值，来判断是否启用关中断；使用对SSTATUS_SIE的设置来启用关中断。

那我们是什么时候需要用到关中断的呢？

通过阅读代码，发现在两处使用了关闭与开启中断

1、 do_fork函数中为新建线程分配PID、建立哈希映射、加入进程控制块的过程。

2、 proc_run函数中，线程切换完成后，为新线程进行页表切换和上下文切换时。

因此，我们可以发现，当为新线程进行属性设置与内存分配以及进程切换时，我们不希望该过程被打断。想要关闭中断，首先需要对SSTATUS_SIE位进行判断，判断其是否满足关闭中断条件；接下来通过对SSTATUS_SIE位的设置，实现关闭中断。开启中断过程类似。



开启中断函数跳转过程：

- 调用函数`local_intr_restore(intr_flag)`

—>sync.h中的宏定义#define local_intr_restore(x)

```c
#define local_intr_restore(x) __intr_restore(x);
```

—>sync.h中的函数static inline void __intr_restore(bool flag)

```c
static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}
```

—>intr.c中的函数void intr_enable(void)

```c
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
```

