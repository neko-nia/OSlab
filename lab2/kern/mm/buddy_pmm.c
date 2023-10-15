#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>

free_buddy_t buddy_s;

#define buddy_array (buddy_s.free_array)
#define max_order (buddy_s.max_order)
#define nr_free (buddy_s.nr_free)

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

/*
 *  ³õÊŒ»¯buddyœá¹¹Ìå
 */
static void
buddy_init(void) {
    for (int i = 0; i < MAX_BUDDY_ORDER; i++) {
        list_init(buddy_array + i);
    }
    max_order = 0;
    nr_free = 0;
    return;
}


static struct Page*
buddy_get_buddy(struct Page* page) {
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

static void
buddy_init_memmap(struct Page* base, size_t n) {
    assert(n > 0);
    size_t pnum;
    unsigned int order;
    pnum = ROUNDDOWN2(n);   
    order = getOrderOf2(pnum);   
    cprintf("[!]BS: AVA Page num after rounding down to powers of 2: %d = 2^%d\n", pnum, order);
    struct Page* p = base;
    for (; p != base + pnum; p++) {
        assert(PageReserved(p));
        p->flags = 0;
        p->property = -1;
        set_page_ref(p, 0);
    }
    max_order = order;
    nr_free = pnum;
    list_add(&(buddy_array[max_order]), &(base->page_link)); 
    base->property = max_order;     

    return;
}


static void buddy_split(size_t n) {
    assert(n > 0 && n <= max_order);
    assert(!list_empty(&(buddy_array[n])));
    cprintf("[!]BS: SPLITTING!\n");
    struct Page* page_a;
    struct Page* page_b;

    page_a = le2page(list_next(&(buddy_array[n])), page_link);
    page_b = page_a + (1 << (n - 1));
    page_a->property = n - 1;
    page_b->property = n - 1;
    SetPageProperty(page_a);
    SetPageProperty(page_b);
    cprintf("%d\n",page2ppn(page_a));
    cprintf("%d\n",page2ppn(page_b));
    list_del(list_next(&(buddy_array[n])));
    list_add(&(buddy_array[n - 1]), &(page_a->page_link));
    list_add(&(page_a->page_link), &(page_b->page_link));

    return;
}

static struct Page*
buddy_alloc_pages(size_t n) {
    // require n > 0, or panic
    assert(n > 0);

    // if the number of required pages beyond what we have currently, return NULL
    if (n > nr_free) {
        return NULL;
    }

    struct Page* page = NULL;
    size_t pnum = ROUNDUP2(n); 
    size_t order = 0;

    order = getOrderOf2(pnum); 
    cprintf("[!]BS: Allocating %d-->%d = 2^%d pages ...\n", n, pnum, order);
    cprintf("[!]BS: Buddy array before ALLOC:\n");
    show_buddy_array();
find:
    if (!list_empty(&(buddy_array[order]))) {
        page = le2page(list_next(&(buddy_array[order])), page_link);
        list_del(list_next(&(buddy_array[order])));
        ClearPageProperty(page);
        cprintf("[!]BS: Buddy array after ALLOC NO.%d page:\n", page2ppn(page));
        show_buddy_array();
        goto done;
    }
    else {
        for (int i = order; i < max_order + 1; i++) {
           
            if (!list_empty(&(buddy_array[i]))) {
                buddy_split(i);
                cprintf("[!]BS: Buddy array after SPLITT:\n");
                show_buddy_array();
                goto find;      
            }
        }
    }

done:
    nr_free -= pnum;
    cprintf("[!]BS: nr_free: %d\n", nr_free);
    return page;
}

static void
buddy_free_pages(struct Page* base, size_t n) {
    assert(n > 0);
    unsigned int pnum = 1 << (base->property);
    assert(ROUNDUP2(n) == pnum);
    cprintf("[!]BS: Freeing NO.%d page leading %d pages block: \n", page2ppn(base), pnum);
    struct Page* left_block = base;
    struct Page* buddy = NULL;
    struct Page* tmp = NULL;

    buddy = buddy_get_buddy(left_block);
    list_add(&(buddy_array[left_block->property]), &(left_block->page_link));
    cprintf("[!]BS: add to list\n");
    show_buddy_array();
    // µ±»ï°é¿é¿ÕÏÐ£¬ÇÒµ±Ç°¿é²»Îª×îŽó¿éÊ±
    while (PageProperty(buddy) && left_block->property < max_order) {
        cprintf("[!]BS: Buddy free, MERGING!\n");
        if (left_block > buddy) { 
            left_block->property = -1;
            SetPageProperty(left_block);
            tmp = left_block;
            left_block = buddy;
            buddy = tmp;
        }
        list_del(&(left_block->page_link));
        list_del(&(buddy->page_link));
        left_block->property += 1;
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); 
        show_buddy_array();
        buddy = buddy_get_buddy(left_block);
    }
    cprintf("[!]BS: Buddy array after FREE:\n");
    SetPageProperty(left_block); 
    nr_free += pnum;
    show_buddy_array();

    cprintf("[!]BS: nr_free: %d\n", nr_free);
    return;
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}


static void
basic_check(void) {
    struct Page* p0, * p1, * p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);
    free_page(p0);
    free_page(p1);
    free_page(p2);
    
    //show_buddy_array();

    /*assert((p0 = alloc_pages(4)) != NULL);
    assert((p1 = alloc_pages(2)) != NULL);
    assert((p2 = alloc_pages(1)) != NULL);
    
    free_pages(p0, 4);
    //free_pages(p1, 2);
    free_pages(p2, 1);
    show_buddy_array();

    assert((p0 = alloc_pages(3)) != NULL);
    assert((p1 = alloc_pages(3)) != NULL);
    //free_pages(p0, 3);
    free_pages(p1, 3);
    

    show_buddy_array();*/
    
}

/*
static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}
*/
static void
buddy_check(void) {
    //basic_check();
}
// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
/*
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
    assert(alloc_pages(4) == NULL);
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
    assert((p1 = alloc_pages(3)) != NULL);
    assert(alloc_page() == NULL);
    assert(p0 + 2 == p1);

    p2 = p0 + 1;
    free_page(p0);
    free_pages(p1, 3);
    assert(PageProperty(p0) && p0->property == 1);
    assert(PageProperty(p1) && p1->property == 3);

    assert((p0 = alloc_page()) == p2 - 1);
    free_page(p0);
    assert((p0 = alloc_pages(2)) == p2 + 1);
    free_pages(p0, 2);
    free_page(p2);

    assert((p0 = alloc_pages(5)) != NULL);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}
*/
const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = basic_check,
};
