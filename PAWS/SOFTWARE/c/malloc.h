// Based on https://github.com/andrestc/linux-prog/blob/master/ch7/malloc.c

typedef struct block {
	size_t		size;
	struct block   *next;
	struct block   *prev;
}		block_t;

#ifndef ALLOC_UNIT
#define ALLOC_UNIT 1024 * 1024
#endif

#define BLOCK_MEM(ptr) ((void *)((unsigned long)ptr + sizeof(block_t)))
#define BLOCK_HEADER(ptr) ((void *)((unsigned long)ptr - sizeof(block_t)))

static block_t *head = NULL;

/* fl_remove removes a block from the free list
 * and adjusts the head accordingly */
void
fl_remove(block_t * b)
{
	if (!b->prev) {
		if (b->next) {
			head = b->next;
		} else {
			head = NULL;
		}
	} else {
		b->prev->next = b->next;
	}
	if (b->next) {
		b->next->prev = b->prev;
	}
}

/* fl_add adds a block to the free list keeping
 * the list sorted by the block begin address,
 * this helps when scanning for continuous blocks */
void
fl_add(block_t * b)
{
	b->prev = NULL;
	b->next = NULL;
	if (!head || (unsigned long)head > (unsigned long)b) {
		if (head) {
			head->prev = b;
		}
		b->next = head;
		head = b;
	} else {
		block_t        *curr = head;
		while (curr->next
		       && (unsigned long)curr->next < (unsigned long)b) {
			curr = curr->next;
		}
		b->next = curr->next;
		curr->next = b;
	}
}

/* scan_merge scans the free list in order to find
 * continuous free blocks that can be merged and also
 * checks if our last free block ends where the program
 * break is. If it does, and the free block is larger then
 * MIN_DEALLOC then the block is released to the OS, by
 * calling brk to set the program break to the begin of
 * the block */
void
scan_merge()
{
	block_t        *curr = head;
	unsigned long	header_curr, header_next;
	while (curr->next) {
		header_curr = (unsigned long)curr;
		header_next = (unsigned long)curr->next;
		if (header_curr + curr->size + sizeof(block_t) == header_next) {
			/* found two continuous addressed blocks, merge them
			 * and create a new block with the sum of their sizes */
			curr->size += curr->next->size + sizeof(block_t);
			curr->next = curr->next->next;
			if (curr->next) {
				curr->next->prev = curr;
			} else {
				break;
			}
		}
		curr = curr->next;
	}
	header_curr = (unsigned long)curr;
}

/* splits the block b by creating a new block after size bytes,
 * this new block is returned */
block_t * split(block_t * b, size_t size)
{
	void           *mem_block = BLOCK_MEM(b);
	block_t        *newptr = (block_t *) ((unsigned long)mem_block + size);
	newptr->size = b->size - (size + sizeof(block_t));
	b->size = size;
	return newptr;
}

void           *
malloc(size_t size)
{
	void           *block_mem;
	block_t        *ptr, *newptr;
	size_t		alloc_size = size >= ALLOC_UNIT ? size + sizeof(block_t)
		: ALLOC_UNIT;
	ptr = head;
	while (ptr) {
		if (ptr->size >= size + sizeof(block_t)) {
			block_mem = BLOCK_MEM(ptr);
			fl_remove(ptr);
			if (ptr->size == size) {
				// we found a perfect sized block, return it
				return block_mem;
			}
			// our block is bigger then requested, split it and add
			// the spare to our free list
			newptr = split(ptr, size);
			fl_add(newptr);
			return block_mem;
		} else {
			ptr = ptr->next;
		}
	}
	/* We are unable to find a free block on our free list, so we
	 * should ask the OS for memory using sbrk. We will alloc
	 * more alloc_size bytes (probably way more than requested) and then
	 * split the newly allocated block to keep the spare space on our free
	 * list */
	ptr = (block_t *)memoryspace(alloc_size);
	if (!ptr) {
		return NULL;
	}
	ptr->next = NULL;
	ptr->prev = NULL;
	ptr->size = alloc_size - sizeof(block_t);
	if (alloc_size > size + sizeof(block_t)) {
		newptr = split(ptr, size);
		fl_add(newptr);
	}
	return BLOCK_MEM(ptr);
}

void
free(void *ptr)
{
	fl_add(BLOCK_HEADER(ptr));
	scan_merge();
}

void
_cleanup()
{
	head = NULL;
}
