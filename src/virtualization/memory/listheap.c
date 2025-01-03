/**
 * @file listheap.c
 * @brief O1Heap-based Memory Allocator
 *
 * Inspired by the O1Heap algorithm, this implementation provides a memory allocator
 * with the following features:
 *
 * - O(1) allocation and deallocation
 * - Low overhead per allocation
 * - Good cache locality
 *
 * @note Configuration:
 * - O1HEAP_ALIGNMENT: Memory alignment (16 bytes)
 * - FRAGMENT_SIZE_MIN: Minimum fragment size (32 bytes)
 * - FRAGMENT_SIZE_MAX: Maximum fragment size (2^31 bytes)
 * - NUM_BINS_MAX: Maximum number of bins (32)
 */
#include "virtualization/memory/heap.h"

#ifdef USE_LIST_ALLOCATOR

#include "types.h"
#include <string.h>
#include <limits.h>
#include <stdint.h>

#define O1HEAP_ALIGNMENT 16
#define FRAGMENT_SIZE_MIN (O1HEAP_ALIGNMENT * 2U)
#define FRAGMENT_SIZE_MAX ((SIZE_MAX >> 1U) + 1U)
#define NUM_BINS_MAX (sizeof(size_t) * CHAR_BIT)
#define INSTANCE_SIZE_PADDED ((sizeof(O1HeapInstance) + O1HEAP_ALIGNMENT - 1U) & ~(O1HEAP_ALIGNMENT - 1U))

typedef struct Fragment Fragment;

typedef struct FragmentHeader {
    Fragment* next;
    Fragment* prev;
    size_t    size;
    int      used;
} FragmentHeader;

struct Fragment {
    FragmentHeader header;
    Fragment* next_free;
    Fragment* prev_free;
};

typedef struct O1HeapInstance {
    Fragment* bins[NUM_BINS_MAX];
    size_t    nonempty_bin_mask;
    struct {
        size_t capacity;
        size_t allocated;
        size_t peak_allocated;
        size_t peak_request_size;
        size_t oom_count;
    } diagnostics;
} O1HeapInstance;

// Global variables
static O1HeapInstance* heap = NULL;
static void* heap_start = NULL;
static size_t heap_size = 0;

static inline uint_fast8_t clz(const size_t x) {
    size_t t = ((size_t)1U) << ((sizeof(size_t) * CHAR_BIT) - 1U);
    uint_fast8_t r = 0;
    while ((x & t) == 0) {
        t >>= 1U;
        r++;
    }
    return r;
}

static inline uint_fast8_t log2Floor(const size_t x) {
    return (uint_fast8_t)(((sizeof(size_t) * CHAR_BIT) - 1U) - clz(x));
}

static inline uint_fast8_t log2Ceil(const size_t x) {
    return (x <= 1U) ? 0U : (uint_fast8_t)((sizeof(x) * CHAR_BIT) - clz(x - 1U));
}

static inline size_t pow2(const uint_fast8_t power) {
    return ((size_t)1U) << power;
}

static inline size_t roundUpToAlignment(size_t x, size_t alignment) {
    return ((x + alignment - 1) / alignment) * alignment;
}

static inline size_t roundUpToPowerOf2(const size_t x) {
    if (x <= FRAGMENT_SIZE_MIN) return FRAGMENT_SIZE_MIN;
    return pow2(log2Ceil(x));
}

static inline void interlink(Fragment* const left, Fragment* const right) {
    if (left != NULL) {
        left->header.next = right;
    }
    if (right != NULL) {
        right->header.prev = left;
    }
}

static void rebin(O1HeapInstance* const handle, Fragment* const fragment) {
    const uint_fast8_t bin_index = log2Floor(fragment->header.size / FRAGMENT_SIZE_MIN);
    if (bin_index >= NUM_BINS_MAX) {
        return;
    }

    // Add to free list
    fragment->next_free = handle->bins[bin_index];
    fragment->prev_free = NULL;
    if (handle->bins[bin_index] != NULL) {
        handle->bins[bin_index]->prev_free = fragment;
    }
    handle->bins[bin_index] = fragment;
    handle->nonempty_bin_mask |= ((size_t)1U) << bin_index;
}

static void unbin(O1HeapInstance* const handle, const Fragment* const fragment) {
    const uint_fast8_t idx = log2Floor(fragment->header.size / FRAGMENT_SIZE_MIN);
    if (fragment->next_free != NULL) {
        fragment->next_free->prev_free = fragment->prev_free;
    }
    if (fragment->prev_free != NULL) {
        fragment->prev_free->next_free = fragment->next_free;
    }
    if (handle->bins[idx] == fragment) {
        handle->bins[idx] = fragment->next_free;
        if (handle->bins[idx] == NULL) {
            handle->nonempty_bin_mask &= ~pow2(idx);
        }
    }
}

uint8_t AllocatorInit(void* const base, const size_t size) {
    if (base == NULL || (((size_t)base) % O1HEAP_ALIGNMENT) != 0 || 
        size < (INSTANCE_SIZE_PADDED + FRAGMENT_SIZE_MIN)) {
        return 0;
    }

    heap_start = base;
    heap_size = size;
    heap = (O1HeapInstance*)base;
    memset(heap, 0, sizeof(O1HeapInstance));  // Zero out the heap instance
    
    // Calculate usable capacity
    size_t capacity = size - INSTANCE_SIZE_PADDED;
    if (capacity > FRAGMENT_SIZE_MAX) {
        capacity = FRAGMENT_SIZE_MAX;
    }
    // Round down to multiple of FRAGMENT_SIZE_MIN to ensure alignment
    capacity = (capacity / FRAGMENT_SIZE_MIN) * FRAGMENT_SIZE_MIN;

    // Initialize the first fragment
    Fragment* const frag = (Fragment*)(void*)(((char*)base) + INSTANCE_SIZE_PADDED);
    frag->header.next = NULL;
    frag->header.prev = NULL;
    frag->header.size = capacity;
    frag->header.used = 0;
    frag->next_free = NULL;
    frag->prev_free = NULL;
    
    // Add to appropriate bin
    rebin(heap, frag);

    // Initialize diagnostics
    heap->diagnostics.capacity = capacity;
    heap->diagnostics.allocated = 0;
    heap->diagnostics.peak_allocated = 0;
    heap->diagnostics.peak_request_size = 0;
    heap->diagnostics.oom_count = 0;

    return 1;
}

void* malloc(size_t amount) {
    if (heap == NULL || amount == 0 || amount > (heap->diagnostics.capacity - O1HEAP_ALIGNMENT)) {
        return NULL;
    }

    // Calculate required size and ensure alignment
    const size_t fragment_size = roundUpToAlignment(amount + O1HEAP_ALIGNMENT, FRAGMENT_SIZE_MIN);
    if (fragment_size > FRAGMENT_SIZE_MAX || fragment_size < FRAGMENT_SIZE_MIN) {
        return NULL;
    }

    // Simple first-fit strategy
    Fragment* best_fit = NULL;
    Fragment* current = heap->bins[0];  // Start with first bin
    
    // Search through all free blocks
    while (current != NULL) {
        if (current->header.size >= fragment_size) {
            best_fit = current;
            break;
        }
        current = current->next_free;
    }

    if (best_fit == NULL) {
        if (heap->diagnostics.peak_request_size < amount) {
            heap->diagnostics.peak_request_size = amount;
        }
        heap->diagnostics.oom_count++;
        return NULL;
    }

    // Remove from free list
    unbin(heap, best_fit);
    
    // Split if possible
    const size_t leftover = best_fit->header.size - fragment_size;
    if (leftover >= FRAGMENT_SIZE_MIN) {
        Fragment* const new_frag = (Fragment*)(void*)(((char*)best_fit) + fragment_size);
        new_frag->header.size = leftover;
        new_frag->header.used = 0;
        new_frag->next_free = NULL;
        new_frag->prev_free = NULL;
        interlink(new_frag, best_fit->header.next);
        interlink(best_fit, new_frag);
        rebin(heap, new_frag);
        
        best_fit->header.size = fragment_size;
    }

    heap->diagnostics.allocated += best_fit->header.size;
    if (heap->diagnostics.peak_allocated < heap->diagnostics.allocated) {
        heap->diagnostics.peak_allocated = heap->diagnostics.allocated;
    }

    best_fit->header.used = 1;
    return (void*)(((char*)best_fit) + O1HEAP_ALIGNMENT);
}

void* realloc(void* ptr, size_t new_size) {
    if (ptr == NULL) {
        return malloc(new_size);
    }

    if (new_size == 0) {
        free(ptr);
        return NULL;
    }

    Fragment* frag = (Fragment*)(void*)(((char*)ptr) - O1HEAP_ALIGNMENT);
    if (!frag->header.used) {
        return NULL;
    }

    // Calculate actual sizes
    size_t current_fragment_size = frag->header.size;
    size_t current_usable_size = current_fragment_size - O1HEAP_ALIGNMENT;
    size_t required_fragment_size = roundUpToAlignment(new_size + O1HEAP_ALIGNMENT, FRAGMENT_SIZE_MIN);

    // If new size fits in current block with some room to spare, split it
    if (required_fragment_size + FRAGMENT_SIZE_MIN <= current_fragment_size) {
        size_t remaining_size = current_fragment_size - required_fragment_size;
        Fragment* split = (Fragment*)(void*)(((char*)frag) + required_fragment_size);
        
        // Initialize split block
        split->header.size = remaining_size;
        split->header.used = 0;
        split->next_free = NULL;
        split->prev_free = NULL;
        
        // Link split block
        split->header.next = frag->header.next;
        split->header.prev = frag;
        if (frag->header.next) {
            frag->header.next->header.prev = split;
        }
        frag->header.next = split;
        
        // Update original block and diagnostics
        frag->header.size = required_fragment_size;
        heap->diagnostics.allocated -= remaining_size;
        
        // Add split to free list
        rebin(heap, split);
        return ptr;
    }
    // If new size fits exactly or leaves too little space to split, just use the current block
    else if (required_fragment_size <= current_fragment_size) {
        return ptr;
    }

    // Need to allocate new block
    void* new_ptr = malloc(new_size);
    if (!new_ptr) {
        return NULL;
    }

    // Copy data and free old block
    size_t copy_size = (new_size < current_usable_size) ? new_size : current_usable_size;
    memcpy(new_ptr, ptr, copy_size);
    if (copy_size < new_size) {
        memset(((char*)new_ptr) + copy_size, 0, new_size - copy_size);
    }
    free(ptr);

    return new_ptr;
}

void* calloc(size_t num_elements, size_t element_size) {
    size_t total_size;
    if (__builtin_mul_overflow(num_elements, element_size, &total_size)) {
        return NULL;
    }
    
    void* ptr = malloc(total_size);
    if (ptr != NULL) {
        memset(ptr, 0, total_size);
    }
    return ptr;
}

void free(void* ptr) {
    if (ptr == NULL) {
        return;
    }

    Fragment* frag = (Fragment*)(void*)(((char*)ptr) - O1HEAP_ALIGNMENT);
    if (!frag->header.used) {
        return;
    }

    heap->diagnostics.allocated -= frag->header.size;
    frag->header.used = 0;

    // Try to merge with next block if it's free
    Fragment* next = frag->header.next;
    if (next != NULL && !next->header.used) {
        // Remove next from free list
        unbin(heap, next);
        
        // Merge blocks
        frag->header.size += next->header.size;
        frag->header.next = next->header.next;
        if (next->header.next) {
            next->header.next->header.prev = frag;
        }
    }

    // Try to merge with previous block if it's free
    Fragment* prev = frag->header.prev;
    if (prev != NULL && !prev->header.used) {
        // Remove prev from free list
        unbin(heap, prev);
        
        // Merge blocks
        prev->header.size += frag->header.size;
        prev->header.next = frag->header.next;
        if (frag->header.next) {
            frag->header.next->header.prev = prev;
        }
        
        // Use prev instead of frag for binning
        frag = prev;
    }

    // Add merged block to free list
    rebin(heap, frag);
}

void AllocatorDeinit() {
    heap = NULL;
    heap_start = NULL;
    heap_size = 0;
}

#endif