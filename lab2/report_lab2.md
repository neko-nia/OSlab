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

###### `default_init`

```c
static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;//nr_free可以理解为在这里可以使用的一个全局变量，记录可用的物理页面数
}
```

在free_area的位置初始化一个双向链表指针，以便未来进一步管理；同时将nr_free初始化为0，来统计物理页面数目

###### `default_init_memmap`

```c
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    //将base之后的n个page的属性置零（它们不是free block的开头）
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    
    //将base设定为这片连续free block的开头
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    //将base加入到按地址排序的free_list中
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

将物理内存对应的页进行初始化，即修改page属性，将一串连续的页归为以base开头的空闲内存块；实际使用中，我们将可用物理内存初始化为一整块的free block

###### `default_alloc_pages`

```c
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
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

###### `default_free_pages`

```c
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    //在确认page是可以被修改的前提下，将已分配的块重新初始化
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
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

first_fit 算法在进一步改进的时候可以维护一个根据空闲块大小排序的二维列表，这样搜索的复杂度降到了O（1）



##### 练习2：实现 Best-Fit 连续物理内存分配算法（需要编程）

> 在完成练习一后，参考`kern/mm/default_pmm.c`对First Fit算法的实现，编程实现Best Fit页面分配算法，算法的时空复杂度不做要求，能通过测试即可。 请在实验报告中简要说明你的设计实现过程，阐述代码是如何对物理内存进行分配和释放，并回答如下问题：
>
> - 你的 Best-Fit 算法是否有进一步的改进空间？

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





