# Lab 0.5

#### 练习 1: 使用GDB验证启动流程

为了熟悉使用qemu和gdb进行调试工作,使用gdb调试QEMU模拟的RISC-V计算机加电开始运行到执行操作系统的第一条指令（即跳转到0x80200000）这个阶段的执行过程，说明RISC-V硬件加电后的几条指令在哪里？完成了哪些功能？要求在报告中简要写出练习过程和回答。

> **tips:**
>
> - 可以使用示例代码 Makefile 中的 make debug和make gdb 指令。
> - 一些可能用到的 gdb 指令：
>   - x/10i 0x80000000 : 显示 0x80000000 处的10条汇编指令。
>   - x/10i $pc : 显示即将执行的10条汇编指令。
>   - x/10xw 0x80000000 : 显示 0x80000000 处的10条数据，格式为16进制32bit。
>   - info register: 显示当前所有寄存器信息。
>   - info r t0: 显示 t0 寄存器的值。
>   - break funcname: 在目标函数第一条指令处设置断点。
>   - break *0x80200000: 在 0x80200000 处设置断点。
>   - continue: 执行直到碰到断点。
>   - si: 单步执行一条汇编指令。

++++

### 执行过程

0. 编译ucore的kernel后，在linux命令行里输入`make qemu`，检测opensbi是否可以被qemu正常模拟

    ```  
    OpenSBI v0.6
        ____                    _____ ____ _____
       / __ \                  / ____|  _ \_   _|
      | |  | |_ __   ___ _ __ | (___ | |_) || |
      | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
      | |__| | |_) |  __/ | | |____) | |_) || |_
       \____/| .__/ \___|_| |_|_____/|____/_____|
             | |
             |_|
    
     Platform Name          : QEMU Virt Machine
     Platform HART Features : RV64ACDFIMSU
     Platform Max HARTs     : 8
     Current Hart           : 0
     Firmware Base          : 0x80000000
     Firmware Size          : 120 KB
     Runtime SBI Version    : 0.2
    
     MIDELEG : 0x0000000000000222
     MEDELEG : 0x000000000000b109
     PMP0    : 0x0000000080000000-0x000000008001ffff (A)
     PMP1    : 0x0000000000000000-0xffffffffffffffff (A,R,W,X)
    ```

    

1. 正常模拟后，通过`make debug`，我们让qemu运行到上电开始时的命令；通过`make gdb`，我们使用gdb对qemu进行远程调试

   ``` 
   riscv64-unknown-elf-gdb \
       -ex 'file bin/kernel' \
       -ex 'set arch riscv:rv64' \
       -ex 'target remote localhost:1234'
   GNU gdb (GDB) 8.0.50.20170724-git
   Copyright (C) 2017 Free Software Foundation, Inc.
   License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
   This is free software: you are free to change and redistribute it.
   There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
   and "show warranty" for details.
   This GDB was configured as "--host=x86_64-linux-gnu --target=riscv64-unknown-elf".
   Type "show configuration" for configuration details.
   For bug reporting instructions, please see:
   <http://www.gnu.org/software/gdb/bugs/>.
   Find the GDB manual and other documentation resources online at:
   <http://www.gnu.org/software/gdb/documentation/>.
   For help, type "help".
   Type "apropos word" to search for commands related to "word".
   Reading symbols from bin/kernel...done.
   The target architecture is assumed to be riscv:rv64
   Remote debugging using localhost:1234
   0x0000000000001000 in ?? ()
   (gdb) 
   ```

   

2. #### 调试过程：

   0. 查看当前地址：pc指向复位向量地址`0x1000`，并在加载一定数据后（如线程等）跳到openSBI固件预先导入的bootloader地址`0x80000000`

   1. 引导启动程序准备完成后，跳转到openSBI固件预先导入的ucore内核地址`0x80200000`

      >  最小可执行内核里, 我们主要完成两件事:
      >
      > 1. 内核的内存布局和入口点设置
      > 2. 通过sbi封装好输入输出函数

   2. 在`tools/kernel.ld`中，`BASE_ADDRESS`被赋值为`0x80200000`，后又将程序的入口定义为了`kern_entry`。

      ``` 
      //tool/kernel.ld
      BASE_ADDRESS = 0x80200000;
      SECTIONS
      {
      /* Load the kernel at this address: "." means the current address */
       . = BASE_ADDRESS;
       .text : {
           *(.text.kern_entry .text .stub .text.* .gnu.linkonce.t.*)
             }
      ···
      }
      ```

   3. 我们在`kern/init/entry.s`中编写一段代码，定义`kern_entry`符号，作为整个内核的入口。

      ``` 
       //kern/init/entry.s
        
           .section .text,"ax",%progbits
           .globl kern_entry
       kern_entry:
           la sp, bootstacktop
           tail kern_init
      ```

      这段代码作为入口点，作用是分配好内核栈，最终跳向`kern_init`函数.

   4. 当代码执行到`la sp, bootstacktop`时，根据`makefile`依赖的`tools/function.mk`中代码，启动加载内核。

     5. 我们在`kern/init/init.c`编写函数`kern_init`, 作为“真正的”内核入口点。在函数内，我们令其进行格式化输出，但由于C语言标准库中的`glibc`没有移植到ucore中，openSBI提供了字符的输入输出封装接口，为了与原来的函数进行区分，在这里我们命名为`cprintf()`

        ``` 
         // kern/init/init.c
         #include <stdio.h>
         #include <string.h>
         //这里include的头文件， 并不是C语言的标准库，而是我们自己编写的！
        
         //noreturn 告诉编译器这个函数不会返回
         int kern_init(void) __attribute__((noreturn));
        
         int kern_init(void) {
             extern char edata[], end[]; 
             //这里声明的两个符号，实际上由链接器ld在链接过程中定义, 所以加了extern关键字
             memset(edata, 0, end - edata); 
             //内核运行的时候并没有c标准库可以使用，memset函数是我们自己在string.h定义的
        
             const char *message = "(THU.CST) os is loading ...\n";
             cprintf("%s\n\n", message); //cprintf是我们自己定义的格式化输出函数
             while (1)
                 ;
         }
        ```


 运行结束可以看到屏幕输出`(THU.CST) os is loading ...`，查看汇编可以发现该指令一直在向自身跳转，陷入死循环。