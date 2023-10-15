### lab 2 物理内存和页表

+++

[TOC]



------



#### 实验目的

- 理解页表的建立和使用方法
- 理解物理内存的管理方法
- 理解页面分配算法



#### 实验内容

##### 练习1：理解first-fit 连续物理内存分配算法（思考题）

> first-fit 连续物理内存分配算法作为物理内存分配一个很基础的方法，需要同学们理解它的实现过程。请大家仔细阅读实验手册的教程并结合`kern/mm/default_pmm.c`中的相关代码，认真分析`default_init`，`default_init_memmap`，`default_alloc_pages`， `default_free_pages`等相关函数，并描述程序在进行物理内存分配的过程以及各个函数的作用。 请在实验报告中简要说明你的设计实现过程。请回答如下问题：
>
> - 你的first fit算法是否有进一步的改进空间？

###### first-fit算法

`First-fit`算法是连续物理内存分配算法的一种，将空闲内存块按照地址从小到大的方式连起来，具体实现时使用了双向链表的方式。当分配内存时，从链表头开始向后找，这意味着从低地址向高地址查找，一旦找到可以满足要求的内存块，即将该内存块分配出去即可。

###### `default_init`

```c
static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;//nr_free可以理解为在这里可以使用的一个全局变量，记录可用的物理页面数
}
```

在free_area的位置初始化一个**双向链表指针**，以便未来进一步管理；同时将nr_free初始化为0，来**统计物理页面数目**。

`default_init`在系统或模块启动时初始化一个链表对象（`free_list`），用于管理可用的物理页面，并将可用物理页面数量的全局变量（`nr_free`）初始化为0。这为后续的物理页面管理提供了一个初始状态。在系统运行时，`free_list` 将用于跟踪可用的物理页面，而 `nr_free` 变量将随着物理页面的分配和释放而动态更新，以反映可用页面的数量。

###### `default_init_memmap`

```c
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);//此处使用断言，确保初始化的页面数量是合法的
    struct Page *p = base;//初始化指针p，令其为连续地址的空闲块的起始页。
    //将base之后的n个page的属性置零（它们不是free block的开头）
    for (; p != base + n; p ++) {        
        assert(PageReserved(p));//检查页面p的PG_Reserved是否为1，表示空闲可分配。否则退出程序。
        p->flags = p->property = 0;
        set_page_ref(p, 0);//将p的ref置0，表明此页现在空闲，没有引用。
    }
    //将base设定为这片连续free block的开头
    base->property = n;//将第一个页面（base）的property字段设置为n，表示这是一个连续的可用内存块，该块包含了n个页面。
    SetPageProperty(base);
    nr_free += n;//可用物理页总数+n
    //将base加入到按地址排序的free_list中
    
    //如果链表free_list为空，表示它是第一个可用内存块，将使用list_add将base添加到链表中。否则，会遍历free_list中的元素，找到合适的位置将base插入到链表中，以保持链表中页面按地址排序。
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
}
```

详细注释在代码段中有所体现，此处不再赘述。该函数将物理内存对应的页进行初始化，即修改page属性，将一串连续的页归为以base开头的空闲内存块；实际使用中，我们将可用物理内存初始化为一整块的free block.

###### `default_alloc_pages`

```c
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    //如果请求的页面数量n超过了当前的可用页面数量nr_free，则返回NULL。
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;//初始化
    list_entry_t *le = &free_list;
    //循环一次free_list找到第一块满足大小需求的free block，并返回
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    //返回后，将free block的块取出后，进行划分，并将剩余空闲块重新加到free_list当中，对free_area中的参数更新
    if (page != NULL) {
        list_entry_t* prev = list_prev(&(page->page_link));
        list_del(&(page->page_link));
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);
            list_add(prev, &(p->page_link));
        }
        nr_free -= n;
        ClearPageProperty(page);
    }
    //返回 target page的地址
    return page;
}
```

firstfit需要从空闲链表头开始查找最小的地址，通过`list_next`找到下一个空闲块元素，通过le2page宏可以由链表元素获得对应的Page指针p。通过`p->property`可以了解此空闲块的大小。如果`p->property >= n`，这就找到了！如果`p->property < n`，则`list_next`，继续查找。直到`list_next == &free_list`，这表示找完了一遍了。找到后，就要从新组织空闲块，然后把找到的page返回。

###### `default_free_pages`

```c
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    //在确认page是可以被修改的前提下，将已分配的块重新初始化
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        //在每次迭代中，确保页面p既不是保留页面（PageReserved）也不是属性页面（PageProperty）。
        p->flags = 0;//清除所有标志位
        set_page_ref(p, 0);//将页面p的引用计数设置为0，表示该页面没有被引用。
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
	//把这块空闲块加入free_list中
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
	//检测空闲块是否可以和前后空闲块合并
    //前
    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
        }
    }
	//后
    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
    }
}
```

###### 改进

在`first_fit`算法中，如果需要分配内存，则需要从物理内存的起始内存地址开始依次访问直到找到合适大小的内存位置。这种方式会随着内存空间的分配使得物理内存的前端产生很多小碎片，这些小碎片内次都会被遍历到但是却大概率用不上，使算法性能大大下降，查找开销也会逐渐变大。

为了改善这种情况，可以使用下列思路去修改：

- 用双向链表存储可用内存块，这样的好处在于插入删除结点时较为容易

- 找到可用块后，如果可用块大小大于所需(通常情况下均为此情况)，则将可用块分配前部分使得正好满足所需，而后半部分继续插入到可用块的链表中，可以避免内部碎片的产生，当然会产生外部碎片。
- 释放内存块时，需要查看要释放的内存块是否和相邻的块可以合并，如果可以合并，则将其合并为一个大块并放入可用内存块队列。判断较为容易，因为是按照地址排序的，所以只需要查看地址排列是否首位相接即可。
  

first_fit 算法在进一步改进的时候可以维护一个根据空闲块大小排序的二维列表，这样搜索的复杂度降到了O（1）



##### 练习2：实现 Best-Fit 连续物理内存分配算法（需要编程）

> 在完成练习一后，参考`kern/mm/default_pmm.c`对First Fit算法的实现，编程实现Best Fit页面分配算法，算法的时空复杂度不做要求，能通过测试即可。 请在实验报告中简要说明你的设计实现过程，阐述代码是如何对物理内存进行分配和释放，并回答如下问题：
>
> - 你的 Best-Fit 算法是否有进一步的改进空间？

###### Best-Fit算法

将空闲分区链中的空闲分区按照空闲分区由小到大的顺序排序，从而形成空闲分区链。每次从链首进行查找合适的空闲分区为作业分配内存，这样每次找到的空闲分区是和作业大小最接近的，所谓“最佳”。

###### 实现

1. 除了在分配空闲块的时候需要重新实现外，在其他函数（如初始化，回收以及合并等函数）不变；
2. 实现`best_fit_pmm.c`后，在`pmm.c`中，将`pmm_manager`指向`&best_fit_pmm_manager`,即可采取Best-Fit 连续物理内存分配的策略。

###### `default_alloc_pages`

```c
static struct Page *
best_fit_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    size_t min_size = nr_free + 1;
     /*LAB2 EXERCISE 2: YOUR CODE*/ 
    // 下面的代码是first-fit的部分代码，请修改下面的代码改为best-fit
    // 遍历空闲链表，查找满足需求的空闲页框
    // 如果找到满足需求的页面，记录该页面以及当前找到的最小连续空闲页框数量
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n&&p->property<min_size) {
            page = p;
			min_size=p->property;
            continue;
        }
    }
    //利用一个min_size遍历整个列表找到第一个best fit block
    
/*----------------------------------其他保持不变--------------------------------*/
    if (page != NULL) {
    	list_entry_t* prev = list_prev(&(page->page_link));
    	list_del(&(page->page_link));
    	if (page->property > n) {
        	struct Page *p = page + n;
        	p->property = page->property - n;
       	 	SetPageProperty(p);
        	list_add(prev, &(p->page_link));
    	}
    	nr_free -= n;
    	ClearPageProperty(page);
	}
 	return page;
}
```
更换策略后运行结果：

![更换策略后运行结果](H:\Desktop\oslab\lab2\best_fit_pmm_result_cap.JPG)

###### 分析

参考first_fit的代码思路

###### 改进

best_fit 算法在进一步改进的时候可以维护一个根据空闲块大小排序的二维列表，这样搜索的复杂度降到了O（1）

##### 扩展练习Challenge：buddy system（伙伴系统）分配算法（需要编程）

>Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128...
>
>- 参考[伙伴分配器的一个极简实现](http://coolshell.cn/articles/10427.html)， 在ucore中实现buddy system分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

###### buddy system

`buddy system`是内核中用来管理物理内存的一种算法。当分配内存时，会优先从需要分配的内存块链表上查找空闲内存块，当发现对应大小的内存块都已经被使用后，那么会从更大一级的内存块上分配一块内存，并且分成一半给我们使用，剩余的一半释放到对应大小的内存块链表上。当释放内存时，会扫描对应大小的内存块链表，查看是否存在地址能够连续在一起的内存块，如果发现有，那么就合并两个内存块放置到更大一级的内存块链表上，以此类推。

###### 实现思路

我们可以构建一个**空闲链表数组**来作为我们的伙伴堆存储结构。其中，数组的每一项存储着一个空闲链表头，指向一条空闲链表，每条链表将其所在数组下标所对应大小的空闲块链接起来（一条链表中的空闲块大小相同）。即，数组的第 i个元素所指向的链表中，链接了所有大小为 2^i  页的块。

![88a152a79dc09a7af3c7a1191510180](C:\Users\花花\AppData\Local\Temp\WeChat Files\88a152a79dc09a7af3c7a1191510180.jpg)

###### 代码分析

```c++
// mm/memlayout.h

#define MAX_BUDDY_ORDER 20
/* buddy system 的结构体 */
typedef struct {
    unsigned int max_order;                           // 实际最大块的大小
    list_entry_t free_array[MAX_BUDDY_ORDER + 1];     // 伙伴堆数组
    unsigned int nr_free;                             // 伙伴系统中剩余的空闲块
} free_buddy_t;
```

我们在memlayout.h中定义了free_buddy_t结构体。

```c++
static int IS_POWER_OF_2(size_t n) {
    if (n & (n - 1)) {
        return 0;
    }
    else {
        return 1;
    }
}

static unsigned int getOrderOf2(size_t n) {
    unsigned int order = 0;
    while (n >> 1) {
        n >>= 1;
        order++;
    }
    return order;
}

static size_t ROUNDDOWN2(size_t n) {
    size_t res = 1;
    if (!IS_POWER_OF_2(n)) {
        while (n) {
            n = n >> 1;
            res = res << 1;
        }
        return res >> 1;
    }
    else {
        return n;
    }
}

static size_t ROUNDUP2(size_t n) {
    size_t res = 1;
    if (!IS_POWER_OF_2(n)) {
        while (n) {
            n = n >> 1;
            res = res << 1;
        }
        return res;
    }
    else {
        return n;
    }
}
```

定义一些基础函数。

```c++
static void
show_buddy_array(void) {
    cprintf("[!]BS: Printing buddy array:\n");
    for (int i = 0; i < max_order + 1; i++) {
        cprintf("%d layer: ", i);
        list_entry_t* le = &(buddy_array[i]);
        while ((le = list_next(le)) != &(buddy_array[i])) {
            struct Page* p = le2page(le, page_link);
            cprintf("%d ", 1 << (p->property));
        }
        cprintf("\n");
    }
    cprintf("---------------------------\n");
    return;
}
```

通过遍历空闲链表头（即链表数组），输出该空闲链表头指向链表的页面的块大小。

```c++
/* 初始化buddy结构体 */
static void buddy_init(void) {
    // 初始化链表数组中的每个free_list头
    for (int i = 0; i < MAX_BUDDY_ORDER; i++) {
        list_init(buddy_array + i);
    }
    max_order = 0;
    nr_free = 0;
    return;
}

```

该函数通过初始化每个链表数组的前后指针，使其都指向自己。同时设置`max_order = 0;` ` nr_free = 0;` 。

```c++
/* 获取以page页为头页的块的伙伴块 */
static struct Page* buddy_get_buddy(struct Page* page) {
    unsigned int order = page->property;
    unsigned int buddy_ppn = first_ppn + ((1 << order) ^ (page2ppn(page) - first_ppn));
    cprintf("[!]BS: Page NO.%d 's buddy page on order %d is: %d\n", page2ppn(page), order, buddy_ppn);
    if (buddy_ppn > page2ppn(page)) {
        return page + (buddy_ppn - page2ppn(page));
    }
    else {
        return page - (page2ppn(page) - buddy_ppn);
    }

}
```

在此函数中，`order`是当前页的块大小，`buddy_ppn`通过将当前物理页号`page2ppn(page)`减去第一个物理页的页号，表示给定页面相对于第一个物理页的偏移量，再将该偏移量与当前页的块大小左移一位进行异或操作以计算出伙伴页面的物理页号。

检查伙伴页面的页号是否大于给定页面的页号，如果伙伴页面的页号大于给定页面的页号，将给定页面的指针增加一个偏移量，这个偏移量是伙伴页面的页号减去给定页面的页号，否则，将给定页面的指针减去给定页面的页号减去伙伴页面的页号。

综上，该函数用于计算给定页面的伙伴页面，并返回指向伙伴页面的指针。

```c++
static void
buddy_init_memmap(struct Page* base, size_t n) {
    assert(n > 0);
    size_t pnum; //存储buddy_system所管理的页面数量
    unsigned int order;
    pnum = ROUNDDOWN2(n);       // 将页数向下取整为2的幂
    order = getOrderOf2(pnum);   // 求出页数对应的2的幂
    cprintf("[!]BS: AVA Page num after rounding down to powers of 2: %d = 2^%d\n", pnum, order);
    struct Page* p = base;
    // 初始化pages数组中范围内的每个Page
    for (; p != base + pnum; p++) {
        assert(PageReserved(p));  //确保页面 p 是保留的
        p->flags = 0;  //将页面 p 的标志位清零
        p->property = -1;   // 全部初始化为非头页
        set_page_ref(p, 0);  //调用 set_page_ref 函数，将页面 p 的引用计数设置为0
    }
    max_order = order;
    nr_free = pnum;
    list_add(&(buddy_array[max_order]), &(base->page_link)); // 将第一页base插入数组的最后一个链表，作为初始化的最大块的头页
    base->property = max_order;                       // 将第一页base的property设为最大块的2幂

    return;
}

```

该函数初始化伙伴系统的内存映射，包括设置页面的标志位、属性、引用计数等，并将第一个页面插入到伙伴数组中。

```c++
// 默认分裂数组中第n条链表的第一块
static void buddy_split(size_t n) {
    assert(n > 0 && n <= max_order);  //确保 n 大于0且不超过最大伙伴块的级别 max_order
    assert(!list_empty(&(buddy_array[n])));  //确保指定级别的伙伴块链表不为空，即还有块可供分裂
    cprintf("[!]BS: SPLITTING!\n");
    struct Page* page_a;
    struct Page* page_b;

    page_a = le2page(list_next(&(buddy_array[n])), page_link);
    //从第 n 级链表中取出下一个可用的伙伴块，将其赋值给 page_a
    page_b = page_a + (1 << (n - 1));
    //计算新的伙伴块 page_b 的地址，这个地址位于 page_a 的右侧，所以将 page_a 的地址加上 2^(n-1) 来得到 page_b
    page_a->property = n - 1;
    page_b->property = n - 1;
    SetPageProperty(page_a);
    SetPageProperty(page_b);

    list_del(list_next(&(buddy_array[n])));
    //从第 n 级链表中删除 page_a，因为它将被分裂
    list_add(&(buddy_array[n - 1]), &(page_a->page_link));
    //将 page_a 插入到第 n-1 级链表中
    list_add(&(page_a->page_link), &(page_b->page_link));
    //将 page_a 插入到 page_b 后面，这将它们链接在一起，成为新的伙伴块

    return;
}
```

该函数实现了buddy_system内存管理中的分裂操作。它将指定级别的伙伴块分成两块，其中一个保留在原级别，另一个降级到更低的级别。

```c++
static struct Page*
buddy_alloc_pages(size_t n) {
    // require n > 0, or panic
    assert(n > 0);

    // if the number of required pages beyond what we have currently, return NULL
    if (n > nr_free) {
        return NULL;
    }

    struct Page* page = NULL;
    size_t pnum = ROUNDUP2(n);  // 处理所要分配的页数，向上取整至2的幂
    size_t order = 0;

    order = getOrderOf2(pnum);  // 求出所需页数对应的幂pow
    cprintf("[!]BS: Allocating %d-->%d = 2^%d pages ...\n", n, pnum, order);
    cprintf("[!]BS: Buddy array before ALLOC:\n");
    show_buddy_array();
find:
    // 若pow对应的链表中含有空闲块，则直接分配
    if (!list_empty(&(buddy_array[order]))) {
        page = le2page(list_next(&(buddy_array[order])), page_link);
        list_del(list_next(&(buddy_array[order])));
        ClearPageProperty(page); // 将分配块的头页设置为已被占用
        cprintf("[!]BS: Buddy array after ALLOC NO.%d page:\n", page2ppn(page));
        show_buddy_array();
        goto done;
    }
    else {
        for (int i = order; i < max_order + 1; i++) {
            // 找到pow后第一个非空链表，分裂空闲块
            if (!list_empty(&(buddy_array[i]))) {
                buddy_split(i);
                cprintf("[!]BS: Buddy array after SPLITT:\n");
                show_buddy_array();
                goto find;      // 重新检查现在是否可以分配
            }
        }
    }

done:
    nr_free -= pnum;
    cprintf("[!]BS: nr_free: %d\n", nr_free);
    return page;
}
```

该函数实现伙伴系统内存分配，首先检查可用的伙伴块链表是否为空，如果为空则尝试分裂更大的伙伴块，直到找到一个可以分配的伙伴块。如果没有足够的伙伴块可供分配，将返回 `NULL`。如果成功分配，将返回一个指向分配的页的指针。

```c++
static void
buddy_free_pages(struct Page* base, size_t n) {
    assert(n > 0);
    unsigned int pnum = 1 << (base->property);
    assert(ROUNDUP2(n) == pnum);
    cprintf("[!]BS: Freeing NO.%d page leading %d pages block: \n", page2ppn(base), pnum);
    struct Page* left_block = base;
    struct Page* buddy = NULL;
    struct Page* tmp = NULL;

    buddy = buddy_get_buddy(left_block);  //获取要释放的页面块伙伴页面块，将其存储在 buddy 中
    list_add(&(buddy_array[left_block->property]), &(left_block->page_link));  //这行代码将 left_block 添加到与其大小相对应的链表中，表示该页面块已经被释放
    cprintf("[!]BS: add to list\n");
    show_buddy_array();
    // 当伙伴块空闲，且当前块不为最大块时
    while (PageProperty(buddy) && left_block->property < max_order) {
        cprintf("[!]BS: Buddy free, MERGING!\n");
        if (left_block > buddy) { // 若当前左块为更大块的右块
            left_block->property = -1;
            SetPageProperty(left_block);  //将回收的块的属性标记为空闲
            tmp = left_block;
            left_block = buddy;
            buddy = tmp;
        }
        list_del(&(left_block->page_link));
        list_del(&(buddy->page_link));
        left_block->property += 1;
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 头插入相应链表
        show_buddy_array();
        buddy = buddy_get_buddy(left_block);
    }
    cprintf("[!]BS: Buddy array after FREE:\n");
    SetPageProperty(left_block); // 将回收块的头页设置为空闲
    nr_free += pnum;  //增加了可用的空闲页面块数量
    show_buddy_array();

    cprintf("[!]BS: nr_free: %d\n", nr_free);
    return;
}

```

该函数在buddy_system中释放一块内存页面，同时合并相邻的空闲伙伴块以维护伙伴系统的内存管理结构。

###### 总结

该内存分配系统首先会在buddy_init内初始化一个链表数组，一直初始化到MAX_BUDDY_ORDER，该数组内所有项都指向一个双向链表，但双向链表为空，都指向自身。

接下来，在buddy_inti_memmap内按照内存分配需求，指定MAX_BUDDY_ORDER，同时为i<=MAX_ORDER的数组项指向的双向链表分配内存空间。

然后在buddy_alloc_pages函数中，按照伙伴分配原则，分配合适大小的内存。

最后，在buddy_free_pages函数回收内存，同时若有相同大小的相邻空闲内存块（通过buddy_get_buddy函数获取），则合并两个块。

##### 扩展练习Challenge：任意大小的内存单元slub分配算法（需要编程）

>slub算法，实现两层架构的高效内存单元分配，第一层是基于页大小的内存分配，第二层是在第一层基础上实现基于任意大小的内存分配。可简化实现，能够体现其主体思想即可。
>
>- 参考[linux的slub分配算法/](http://www.ibm.com/developerworks/cn/linux/l-cn-slub/)，在ucore中实现slub分配算法。要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

##### 扩展练习Challenge：硬件的可用物理内存范围的获取方法（思考题）

> - 如果 OS 无法提前知道当前硬件的可用物理内存范围，请问你有何办法让 OS 获取可用物理内存范围？

通过查询资料，我们了解到在Linux系统中，获取内存容量的方式都需要调用BIOS终端的`0x15`来实现。

中断`0x15`中包括三个子功能：`0xe820`，`0xe801`，`0x88`。其中返回信息最为丰富的是`0xe820`，下面将着重讲解`0xe820`。

`0xe820`能够获取系统的内存布局，并按照内存类型返回内存信息。返回的内存信息包含多个属性字段，其构成如下。

| 字节偏移量 | 属性名称     | 描述                       |
| ---------- | ------------ | -------------------------- |
| 0          | BaseAddrLow  | 基地址的低32位             |
| 4          | BaseAddrHigh | 基地址的高32位             |
| 8          | LengthLow    | 内存长度的低32位，单位字节 |
| 12         | LengthHigh   | 内存长度的高32位，单位字节 |
| 16         | Type         | 本段内存的类型             |

其中，Type字段为1表示这段内存可以被操作系统使用，为2则表示内存使用中或者被系统保留，操作系统不可以用此内存。

因此我们可以通过该功能返回的内存信息，查看其中Type字段为1的内存，即为可用内存。

