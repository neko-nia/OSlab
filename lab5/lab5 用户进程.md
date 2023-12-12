# lab5 用户进程

[TOC]

## 实验目的

- 了解第一个用户进程创建过程
- 了解系统调用框架的实现机制
- 了解ucore如何实现系统调用sys_fork/sys_exec/sys_exit/sys_wait来进行进程管理

## 实验内容

#### 练习0：填写已有实验

> 本实验依赖实验1/2/3/4。请把你做的实验1/2/3/4的代码填入本实验中代码中有“LAB1”/“LAB2”/“LAB3”/“LAB4”的注释相应部分。注意：为了能够正确执行lab5的测试应用程序，可能需对已完成的实验1/2/3/4的代码进行进一步改进。

对比lab4的代码，我们需要对函数`alloc_proc`与`do_fork`进行修改补充：

`alloc_proc`新增进程控制块属性:

```C
proc->wait_state = 0;  //初始化进程等待状态  
proc->cptr = proc->optr = proc->yptr = NULL;//进程相关指针初始化 
```

`do_fork`使用`set_links`函数:

```C
bool intr_flag;
local_intr_save(intr_flag); //屏蔽中断，intr_flag 置为 1
{
    proc->pid = get_pid(); //获取当前进程 PID
    hash_proc(proc); //建立 hash 映射
    set_links(proc);   //新增执行set_links函数，实现设置相关进程链接
}
local_intr_restore(intr_flag); //恢复中断
```

以及补充部分lab3的代码，练习0完成。

#### 练习1: 加载应用程序并执行（需要编码）

> **do_execv**函数调用`load_icode`（位于kern/process/proc.c中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序。你需要补充`load_icode`的第6步，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好`proc_struct`结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。
>
> 请在实验报告中简要说明你的设计实现过程。
>
> - 请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。

该函数主要完成以下功能：

1. 调用 mm_create 函数来申请进程的内存管理数据结构 mm 所需内存空间,并对 mm 进行初始化;

   ```c
   //(1) create a new mm for current process
   if ((mm = mm_create()) == NULL) {
       goto bad_mm;
   }
   ```

2. 调用 setup_pgdir 来申请一个页目录表所需的一个页大小的内存空间，并把描述 ucore 内核虚空间映射的内核页表( boot_pgdir 所指)的内容拷贝到此新目录表中，最后让 mm->pgdir 指向此页目录表，这就是进程新的页目录表了，且能够正确映射内核虚空间;

   ```c
   //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
   if (setup_pgdir(mm) != 0) {
       goto bad_pgdir_cleanup_mm;
   }
   ```

3. 接下来将解析已经被载入内存的ELF格式的用户代码。解析ELF header，找到用户程序中program section headers。随后通过调用`mm_map`将不同段的起始地址和长度记录到虚拟内存空间管理的数据结构`vma`中去。接下来根据program section的header中的信息，找到每个program section，并将其中的内容拷贝到用户进程的内存中（包括BSS section和TEXT/DATA section）

   ```c
   //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
   struct Page *page;
   //(3.1) get the file header of the bianry program (ELF format)
   struct elfhdr *elf = (struct elfhdr *)binary;
   //(3.2) get the entry of the program section headers of the bianry program (ELF format)
   struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
   //(3.3) This program is valid?
   if (elf->e_magic != ELF_MAGIC) {
       ret = -E_INVAL_ELF;
       goto bad_elf_cleanup_pgdir;
   }
   
   uint32_t vm_flags, perm;
   struct proghdr *ph_end = ph + elf->e_phnum;
   for (; ph < ph_end; ph ++) {
   //(3.4) find every program section headers
       if (ph->p_type != ELF_PT_LOAD) {
           continue ;
       }
       if (ph->p_filesz > ph->p_memsz) {
           ret = -E_INVAL_ELF;
           goto bad_cleanup_mmap;
       }
       if (ph->p_filesz == 0) {
           continue ;
       }
   //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
       vm_flags = 0, perm = PTE_U;
       if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
       if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
       if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
       if (vm_flags & VM_WRITE) perm |= PTE_W;
       if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
           goto bad_cleanup_mmap;
       }
       unsigned char *from = binary + ph->p_offset;
       size_t off, size;
       uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
   
       ret = -E_NO_MEM;
   
    //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
       end = ph->p_va + ph->p_filesz;
    //(3.6.1) copy TEXT/DATA section of bianry program
       while (start < end) {
           if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
               goto bad_cleanup_mmap;
           }
           off = start - la, size = PGSIZE - off, la += PGSIZE;
           if (end < la) {
               size -= la - end;
           }
           memcpy(page2kva(page) + off, from, size);
           start += size, from += size;
       }
   
     //(3.6.2) build BSS section of binary program
       end = ph->p_va + ph->p_memsz;
       if (start < la) {
           /* ph->p_memsz == ph->p_filesz */
           if (start == end) {
               continue ;
           }
           off = start + PGSIZE - la, size = PGSIZE - off;
           if (end < la) {
               size -= la - end;
           }
           memset(page2kva(page) + off, 0, size);
           start += size;
           assert((end < la && start == end) || (end >= la && start == la));
       }
       while (start < end) {
           if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
               goto bad_cleanup_mmap;
           }
           off = start - la, size = PGSIZE - off, la += PGSIZE;
           if (end < la) {
               size -= la - end;
           }
           memset(page2kva(page) + off, 0, size);
           start += size;
       }
   }
   ```

4. 需要给用户进程设置用户栈，为此调用 mm_mmap 函数建立用户栈的 vma 结构,明确用户栈的位置在用户虚空间的顶端，大小为 256 个页，即 1MB，并分配一定数量的物理内存且建立好栈的虚地址物理地址映射关系;

   ```c
   //(4) build user stack memory
   vm_flags = VM_READ | VM_WRITE | VM_STACK;
   if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
       goto bad_cleanup_mmap;
   }
   assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
   assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
   assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
   assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
   ```

5. 至此，进程内的内存管理 vma 和 mm 数据结构已经建立完成，于是把 mm->pgdir 赋值到 cr3 寄存器中，即更新了用户进程的虚拟内存空间，此时的 init 已经被 exit 的代码和数据覆盖，成为了第一个用户进程，但此时这个用户进程的执行现场还没建立好;

   ```c
   //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
   mm_count_inc(mm);
   current->mm = mm;
   current->cr3 = PADDR(mm->pgdir);
   lcr3(PADDR(mm->pgdir));
   ```

6. 先清空进程的中断帧,再重新设置进程的中断帧，使得在执行中断返回指令 iret 后，能够让 CPU 转到用户态特权级，并回到用户态内存空间，使用用户态的代码段、数据段和堆栈，且能够跳转到用户进程的第一条指令执行，并确保在用户态能够响应中断;

   ```c
   //补充代码部分
   tf->gpr.sp = USTACKTOP;
   tf->epc = elf->e_entry;
   tf->status = (sstatus) & ~(SSTATUS_SPP| SSTATUS_SPIE);
   ```

- 请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。

  在user_main函数中，根据Makefile中定义的TEST的不同，而给函数kernel_execve传递不同的参数。

  ```c
  static int
  kernel_execve(const char *name, unsigned char *binary, size_t size) {
      int64_t ret=0, len = strlen(name);
   //   ret = do_execve(name, len, binary, size);
      asm volatile(
          "li a0, %1\n"
          "lw a1, %2\n"
          "lw a2, %3\n"
          "lw a3, %4\n"
          "lw a4, %5\n"
      	"li a7, 10\n"
          "ebreak\n"
          "sw a0, %0\n"
          : "=m"(ret)
          : "i"(SYS_exec), "m"(name), "m"(len), "m"(binary), "m"(size)
          : "memory");
      cprintf("ret = %d\n", ret);
      return ret;
  }
  ```

  在该函数中，为a0~a7分别赋值为不同参数，此处将a7赋值为10，代表此处要转发到syscall()，接下来的ebreak跳转到trap.c中执行中断处理程序：

  ```c
  case CAUSE_BREAKPOINT:
              cprintf("Breakpoint\n");
              if(tf->gpr.a7 == 10){
                  tf->epc += 4;
                  syscall();
                  kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
              }
              break;
  ```

  随后跳转到syscall执行：

  ```c
  void
  syscall(void) {
      struct trapframe *tf = current->tf;
      uint64_t arg[5];
      int num = tf->gpr.a0;
      if (num >= 0 && num < NUM_SYSCALLS) {
          if (syscalls[num] != NULL) {
              arg[0] = tf->gpr.a1;
              arg[1] = tf->gpr.a2;
              arg[2] = tf->gpr.a3;
              arg[3] = tf->gpr.a4;
              arg[4] = tf->gpr.a5;
              tf->gpr.a0 = syscalls[num](arg);
              return ;
          }
      }
      print_trapframe(tf);
      panic("undefined syscall %d, pid = %d, name = %s.\n",
              num, current->pid, current->name);
  }
  ```

  我们将在kernel_execve中赋值的不同参数值赋值给arg数组，并且给a0赋值为`syscalls[num](arg)`

  ```c
  static int (*syscalls[])(uint64_t arg[]) = {
      [SYS_exit]              sys_exit,
      [SYS_fork]              sys_fork,
      [SYS_wait]              sys_wait,
      [SYS_exec]              sys_exec,
      [SYS_yield]             sys_yield,
      [SYS_kill]              sys_kill,
      [SYS_getpid]            sys_getpid,
      [SYS_putc]              sys_putc,
      [SYS_pgdir]             sys_pgdir,
  };
  ```

  根据传入参数SYS_exec，执行函数sys_exec。sys_exec不创建新进程，而是用新的内容覆盖原来的进程内存空间。在sys_exec中调用函数do_exec。

  在`do_execve`中，首先使用`exit_mmap`、`put_pgdir`、`mm_destroy`来删除并释放掉当前进程内存空间的页表信息、内存管理信息。随后通过`load_icode`将新的用户程序从ELF文件中加载进来执行。如果加载失败，则调用`do_exit`退出当前进程。执行sys_exec后，当前进程的状态保持不变。

  在我们补充的代码中，将tf的epc指向elf->e_entry，即我们要执行的用户态函数的入口。并且修改tf的状态寄存器为(sstatus) & ~(SSTATUS_SPP| SSTATUS_SPIE)，修改为内核态并且禁用中断。

  于是，函数跳转到指定用户态函数的中执行。

#### 练习2: 父进程复制自己的内存空间给子进程（需要编码）

> 创建子进程的函数`do_fork`在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过`copy_range`函数（位于kern/mm/pmm.c中）实现的，请补充`copy_range`的实现，确保能够正确执行。
>
> 请在实验报告中简要说明你的设计实现过程。
>
> - 如何设计实现`Copy on Write`机制？给出概要设计，鼓励给出详细设计。
>
> > Copy-on-write（简称COW）的基本概念是指如果有多个使用者对一个资源A（比如内存块）进行读操作，则每个使用者只需获得一个指向同一个资源A的指针，就可以该资源了。若某使用者需要对这个资源A进行写操作，系统会对该资源进行拷贝操作，从而使得该“写操作”使用者获得一个该资源A的“私有”拷贝—资源B，可对资源B进行写操作。该“写操作”使用者对资源B的改变对于其他的使用者而言是不可见的，因为其他使用者看到的还是资源A。

##### 2.1 copy_range调用前的简要分析

在`proc_init()`函数里调用`kernel_thread`函数新建一个内核进程执行`init_main()`函数，在这个`kernel_thread`函数中，我们返回了`do_fork`函数的调用。

`do_fork`函数将创建进程控制块，之后分配kernel stack，包括分配memory以及虚地址，并将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制，在该函数中调用了`copy_mm`复制父进程的内存信息。

若该`do_fork`是在内核态被调用的，则`copy_mm`函数不会为新进程创建新的虚拟空间，因为在内核中进程共享同一块虚拟内存；若该`do_fork`函数是在用户态被调用的，则`copy_mm`将会为新进程创建新的虚拟空间并调用`dup_mmap`函数（不考虑COW机制），在该函数中首先会遍历虚拟地址空间的所有段，并根据源段信息创建一个新的段，完成新进程内存空间的初始化，然后调用了`copy_range`函数，**该函数将拷贝父进程的内存到新进程**，之后会设置trapframe和context，之后便将新创建好的子进程放到进程队列中去，便可以等待执行。

##### 2.2copy_range函数的实现

`copy_range`函数的作用是把实际的代码段和数据段搬到新的子进程里面去，再设置好页表的相关内容，使得子进程有自己的内存管理架构。具体代码如下：

```c++
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end,
               bool share) {
    // 确保start和end可以整除PGSIZE
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    // 以页为单位进行复制
    // copy content by page unit.
    do {
        // 得到A&B的pte地址
        // call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        // call get_pte to find process B's pte according to the addr start. If
        // pte is NULL, just alloc a PT
        if (*ptep & PTE_V) {
            if ((nptep = get_pte(to, start, 1)) == NULL) {
                return -E_NO_MEM;
            }
            uint32_t perm = (*ptep & PTE_USER);
            // get page from ptep
            struct Page *page = pte2page(*ptep);
            // alloc a page for process B
            //为B分一个页的空间
            struct Page *npage = alloc_page();
            assert(page != NULL);
            assert(npage != NULL);
            int ret = 0;
            /* LAB5:EXERCISE2 YOUR CODE
             * replicate content of page to npage, build the map of phy addr of
             * nage with the linear addr start
             *
             * Some Useful MACROs and DEFINEs, you can use them in below
             * implementation.
             * MACROs or Functions:
             *    page2kva(struct Page *page): return the kernel vritual addr of
             * memory which page managed (SEE pmm.h)
             *    page_insert: build the map of phy addr of an Page with the
             * linear addr la
             *    memcpy: typical memory copy function
             *
             * (1) find src_kvaddr: the kernel virtual address of page
             * (2) find dst_kvaddr: the kernel virtual address of npage
             * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
             * (4) build the map of phy addr of  nage with the linear addr start
             */
            //1.找寻父进程的内核虚拟页地址
            void * kva_src = page2kva(page);
            //2.找寻子进程的内核虚拟页地址   
            void * kva_dst = page2kva(npage);
            //3.复制父进程内容到子进程 
            memcpy(kva_dst, kva_src, PGSIZE);
            //4.建立物理地址与子进程的页地址起始位置的映射关系
            ret = page_insert(to, npage, start, perm);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}
```

因此我们补充代码的实现过程为，首先找寻父进程的和子进程的内核虚拟页地址，然后复制父进程的内容到子进程，最后建立物理地址与子进程的页地址起始位置的映射关系，代码如上。

##### 2.3`Copy on Write`机制设计

> Copy-on-write（简称COW）的基本概念是指如果有多个使用者对一个资源A（比如内存块）进行读操作，则每个使用者只需获得一个指向同一个资源A的指针，就可以该资源了。若某使用者需要对这个资源A进行写操作，系统会对该资源进行拷贝操作，从而使得该“写操作”使用者获得一个该资源A的“私有”拷贝—资源B，可对资源B进行写操作。该“写操作”使用者对资源B的改变对于其他的使用者而言是不可见的，因为其他使用者看到的还是资源A。

由上述可知如果复制的对象只是对内容进行"读"操作，其实不需要真正复制，这个指向源对象的指针就能完成任务，这样便节省了复制的时间并且节省了内存。但是问题在于，如果复制的对象需要对内容进行写的话，单单一个指针可能满足不了要求，因为这样对内容的修改会影响其他进程的正确执行，所以就需要将这块区域复制一下，当然不需要全部复制，只需要将需要修改的部分区域复制即可，这样做大大节约了内存并提高效率。

因此如果设置原先的内容为只可读，则在对这段内容进行写操作时候便会引发Page Fault，这时候我们便知道这段内容是需要去写的，在Page Fault中进行相应处理即可。也就是说利用Page Fault来实现权限的判断，或者说是真正复制的标志。

基于原理和之前的用户进程创建、复制、运行等机制进行分析，设计思想：

- 设置一个标记位，用来标记某块内存是否共享，实际上dup_mmap函数中有对share的设置，因此首先需要将share设为1,表示可以共享。

- 在pmm.c中为copy_range添加对共享页的处理，如果share为1，那么将子进程的页面映射到父进程的页面即可。由于两个进程共享一个页面之后，无论任何一个进程修改页面，都会影响另外一个页面，所以需要子进程和父进程对于这个共享页面都保持只读。

- 当程序尝试修改只读的内存页面的时候，将触发Page Fault中断，这时候我们可以检测出是超出权限访问导致的中断，说明进程访问了共享的页面且要进行修改，因此内核此时需要重新为进程分配页面、拷贝页面内容、建立映射关系


#### 练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不需要编码）

> 请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题：
>
> - 请分析fork/exec/wait/exit的执行流程。重点关注哪些操作是在用户态完成，哪些是在内核态完成？内核态与用户态程序是如何交错执行的？内核态执行结果是如何返回给用户程序的？
> - 请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）
>
> 执行：make grade。如果所显示的应用程序检测都输出ok，则基本正确。（使用的是qemu-1.0.1）

在内核态与用户态中均存在syscall函数，我们分别说明两种状态中sys系列函数执行过程。

内核态：

在内核态中，若发生ebreak且要转发到syscall函数时，则会根据传入参数的不同去调用不同的sys函数（内核态），根据不同函数去执行相应代码操作或者调用对应do系列函数。

用户态：

在用户态中，若要使用系统调用函数，则会通过对应函数调用sys系列函数（用户态），在sys函数中调用syscall函数并传入不同的参数（用户态），接下来在syscall函数中发生ecall中断，此处切换至内核态，在中断处理程序中调用内核态的syscall函数，并根据传入参数的不同执行对应内核态sys函数，其余过程与内核态相同。在执行完内核态的函数执行后，根据中断处理程序中的epc再返回用户态，传入内核态处理结果。

接下来我们讲解fork/exec/wait/exit的执行流程。

##### 3.1 fork

内核态：

```c
sys_fork(uint64_t arg[]) {
    struct trapframe *tf = current->tf;
    uintptr_t stack = tf->gpr.sp;
    return do_fork(0, stack, tf);
}
```

用户态：

```c
sys_fork(void) {
    return syscall(SYS_fork);
}
```

内核态的sys_fork函数新建一个tf结构体后指向当前进程的tf，并且新建stack指向tf的sp寄存器，用于复制新线程的栈空间。

```c
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    
    proc = alloc_proc();
    if(proc == NULL){
        goto fork_out;
    }
    proc->parent=current;
    //确保当前进程正在等待
    assert(current->wait_state == 0);
    // 2.设置内存栈
    int r = setup_kstack(proc);
    if(r !=0){
        goto bad_fork_cleanup_proc;
    };
    // 3.复制父进程的内存信息
    r = copy_mm(clone_flags,proc);
    if(r !=0){
        goto bad_fork_cleanup_kstack;
    };
    // 4.复制父进程的中断帧和上下文信息
    copy_thread(proc,stack,tf);
    // 5.将这个新进程加入链表中
    bool intr_flag;
    local_intr_save(intr_flag); //屏蔽中断，intr_flag 置为 1
    {
        proc->pid = get_pid(); //获取当前进程 PID
        hash_proc(proc); //建立 hash 映射
        set_links(proc);   //执行set_links函数，实现设置相关进程链接
    }
    local_intr_restore(intr_flag); //恢复中断
    // 6.唤醒子进程
    wakeup_proc(proc);
    // 返回pid
    ret = proc->pid;
 
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```

do_fork函数执行的内容与lab4相同，此处不太赘述，不同处在于其中copy_mm函数在本次实验中实现了扩充。

```c 
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    struct mm_struct *mm, *oldmm = current->mm;

    /* current is a kernel thread */
    if (oldmm == NULL) {
        return 0;
    }
    if (clone_flags & CLONE_VM) {
        //若子进程与父进程共享地址空间，直接将子进程的 mm 指针指向父进程的 mm
        mm = oldmm;
        goto good_mm;
    }
    int ret = -E_NO_MEM;
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }
    //锁定父进程的内存管理结构
    //调用 dup_mmap 函数复制父进程的内存映射到子进程
    //复制完成后解锁父进程的内存管理结构。
    lock_mm(oldmm);
    {
        ret = dup_mmap(mm, oldmm);
    }
    unlock_mm(oldmm);

    if (ret != 0) {
        goto bad_dup_cleanup_mmap;
    }

good_mm:
    mm_count_inc(mm);
    proc->mm = mm;
    proc->cr3 = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    return ret;
}
```

若当前进程不为内核进程则根据传入的标志位判断子进程与父进程是否共享地址空间，如果是则直接将当前地址空间赋值给新进程的内存地址空间，否则就开辟新的地址空间，建立新的页表，并且使用dup_mmap函数将父进程的内存映射到子进程中，接下来的执行过程与练习二相同，此处不再赘述。

##### 3.2exec

``` c
static int
sys_exec(uint64_t arg[]) {
    const char *name = (const char *)arg[0];
    size_t len = (size_t)arg[1];
    unsigned char *binary = (unsigned char *)arg[2];
    size_t size = (size_t)arg[3];
    return do_execve(name, len, binary, size);
}
```

内核态中使用sys_exec函数，初始化name等变量后调用do_execve函数。其后过程与练习一相同，此处不再赘述。

##### 3.3wait

内核态：

```c
static int
sys_wait(uint64_t arg[]) {
    int pid = (int)arg[0];
    int *store = (int *)arg[1];
    return do_wait(pid, store);
}
```

```c
int
do_wait(int pid, int *code_store) {
    //参数pid=0  code_store=NULL
    struct mm_struct *mm = current->mm;//获取当前进程的mm
    if (code_store != NULL) {
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
            //验证内存空间是否存在异常
            return -E_INVAL;
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    if (pid != 0) {
        proc = find_proc(pid);
        if (proc != NULL && proc->parent == current) {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    else {
        //遍历当前进程的子进程链表
        //如果找到状态为 PROC_ZOMBIE 的子进程，跳转到标签 found
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    //如果存在子进程，将当前进程状态置为 PROC_SLEEPING
    //如果当前进程正在退出,则调用 do_exit 函数退出
    //然后跳转到标签 repeat 继续重复检查
    if (haskid) {
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
        schedule();
        if (current->flags & PF_EXITING) {
            do_exit(-E_KILLED);
        }
        goto repeat;
    }
    return -E_BAD_PROC;

found:
    if (proc == idleproc || proc == initproc) {
        panic("wait idleproc or initproc.\n");
    }
    if (code_store != NULL) {
        *code_store = proc->exit_code;
    }
    local_intr_save(intr_flag);
    {
        unhash_proc(proc);//将进程从进程表中移除
        remove_links(proc);//移除进程的链接
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);//释放进程的内核栈
    kfree(proc);//释放进程
    return 0;
}
```

在do_wait函数中，我们等待一个处于zombie态的子进程并回收其内存空间，调用新进程上处理机运行。

##### 3.4exit

```c
static int
sys_exit(uint64_t arg[]) {
    int error_code = (int)arg[0];
    return do_exit(error_code);
}
```

```c
int
do_exit(int error_code) {
    if (current == idleproc) {
        panic("idleproc exit.\n");
    }
    if (current == initproc) {
        panic("initproc exit.\n");
    }
    struct mm_struct *mm = current->mm;
    if (mm != NULL) {
        lcr3(boot_cr3);//切换页表为内核页表
        if (mm_count_dec(mm) == 0) {
            exit_mmap(mm);//关闭当前进程的内存映射
            put_pgdir(mm);//减少对页目录的引用计数
            mm_destroy(mm);//销毁内存管理结构
        }
        current->mm = NULL;
    }
    current->state = PROC_ZOMBIE;//设置当前进程状态为 PROC_ZOMBIE
    current->exit_code = error_code;
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        proc = current->parent;
        //如果父进程正在等待子进程退出，则唤醒父进程
        if (proc->wait_state == WT_CHILD) {
            wakeup_proc(proc);
        }
        //遍历当前进程的所有子进程
        while (current->cptr != NULL) {
            proc = current->cptr;
            current->cptr = proc->optr;
    
            proc->yptr = NULL;
            if ((proc->optr = initproc->cptr) != NULL) {
                initproc->cptr->yptr = proc;
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE) {
                if (initproc->wait_state == WT_CHILD) {
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    schedule();
    panic("do_exit will not return!! %d.\n", current->pid);
}
```

在该函数中，首先释放掉该进程占用的内存，然后将该进程标记为僵尸进程。如果它的父进程处于等待子进程退出的状态，则唤醒父进程，将自己的子进程交给initproc处理，并进行进程调度。

##### 用户态进程的执行状态生命周期图

![image-20231210150908727](assets/image-20231210150908727.png)