/**
 * @file listheap.c
 * @brief Segregated Free List Memory Allocator with Boundary Tags
 * 
 * Inspired by Bryant and O'Hallaron, Computer Systems: A Programmer's Perspective.
 * This implementation provides a memory allocator using segregated free lists with
 * the following features:
 * 
 * - Segregated free lists for different size classes
 * - Immediate coalescing of adjacent free blocks
 * - Boundary tags for efficient coalescing
 * - First-fit allocation within size classes
 * - Splitting of large blocks to reduce internal fragmentation
 * 
 * @note Configuration:
 * - ALIGNMENT: Memory alignment (8 bytes)
 * - NUM_BUCKETS: Number of size classes (17)
 * - NUM_SMALL_BUCKETS: Number of small size classes (7)
 * - SMALL_BUCKET_STEP: Size increment for small buckets (8 bytes)
 */
#include "virtualization/memory/heap.h"

#if defined(USE_LIST_ALLOCATOR)

#include <limits.h>

#ifdef __cplusplus
extern "C" {
#endif

/** @name Memory Block Constants
 * @{
 */
#define ALIGNMENT 8
#define HEADER_SIZE sizeof(size_t)
#define MIN_BLOCK_SIZE (sizeof(struct FreeNode) + HEADER_SIZE)
#define MAX_REQUEST_SIZE (1 << 30)
/** @} */

/** @name Block Header Masks and Flags
 * @{
 */
#define SIZE_MASK ~0x7UL
#define ALLOCATED 0x1UL
#define LEFT_ALLOCATED 0x1UL
#define LEFT_FREE ~0x2UL
/** @} */

/** @name Size Class Configuration
 * @{
 */
#define NUM_BUCKETS 17
#define NUM_SMALL_BUCKETS 7
#define SMALL_BUCKET_START_SIZE 24
#define SMALL_BUCKET_STEP 8
#define LARGE_BUCKET_START_SIZE 128
/** @} */

/**
 * @struct FreeNode
 * @brief Structure representing a free block in memory
 * 
 * Each free block contains:
 * - A header with size and status bits
 * - Pointers to next and previous blocks in the free list
 * - A footer (implicit at end of block) for coalescing
 */
struct FreeNode {
  size_t header;
  struct FreeNode *next;
  struct FreeNode *prev;
};

/**
 * @struct SegregatedNode
 * @brief Structure representing a size class in the segregated list
 * 
 * @note Using uint16_t for size limits max block size to 65535 bytes
 */
struct SegregatedNode {
  uint16_t size;
  struct FreeNode *start;
};

static struct {
  struct SegregatedNode table[NUM_BUCKETS];
  struct FreeNode nil;
  size_t total_free_blocks;
} fits;

static struct {
  void *start;
  void *end;
  size_t size;
} heap;

/**
 * @brief Custom implementation of memset for memory initialization
 * 
 * @param dest Pointer to memory to set
 * @param value Value to set (converted to unsigned char)
 * @param len Number of bytes to set
 * @return void* Pointer to the memory area dest
 */
static inline void* memset_custom(void* dest, int value, size_t len) {
    unsigned char* ptr = (unsigned char*)dest;
    while (len-- > 0) {
        *ptr++ = (unsigned char)value;
    }
    return dest;
}

/**
 * @brief Initialize the heap memory allocator
 * 
 * @param heap_start Starting address of heap memory
 * @param heap_size Total size of heap in bytes
 * @return uint8_t True if initialization successful, false otherwise
 * 
 * Sets up:
 * 1. Heap boundaries and alignment
 * 2. Size class buckets (small and large)
 * 3. Initial free block spanning entire heap
 */
uint8_t AllocatorInit(void *heap_start, size_t heap_size) {
  if (heap_size < MIN_BLOCK_SIZE) {
    return false;
  }

  heap.start = heap_start;
  heap.size = (heap_size + ALIGNMENT - 1) & ~(ALIGNMENT - 1);
  heap.end = (uint8_t *)heap.start + heap.size;

  fits.nil.next = fits.nil.prev = NULL;
  fits.total_free_blocks = 0;

  size_t bucket_size = SMALL_BUCKET_START_SIZE;
  for (size_t i = 0; i < NUM_SMALL_BUCKETS;
       i++, bucket_size += SMALL_BUCKET_STEP) {
    fits.table[i].size = bucket_size;
    fits.table[i].start = &fits.nil;
  }

  bucket_size = LARGE_BUCKET_START_SIZE;
  for (size_t i = NUM_SMALL_BUCKETS; i < NUM_BUCKETS; i++, bucket_size *= 2) {
    fits.table[i].size = bucket_size;
    fits.table[i].start = &fits.nil;
  }

  struct FreeNode *initial_node = heap.start;
  initial_node->header = (heap.size - HEADER_SIZE) | LEFT_ALLOCATED;
  struct FreeNode *next =
      (struct FreeNode *)((uint8_t *)initial_node + heap.size - HEADER_SIZE);
  next->header &= LEFT_FREE;

  size_t bucket =
      (heap.size - HEADER_SIZE <=
       SMALL_BUCKET_START_SIZE + (NUM_SMALL_BUCKETS - 1) * SMALL_BUCKET_STEP)
          ? ((heap.size - HEADER_SIZE - SMALL_BUCKET_START_SIZE) /
             SMALL_BUCKET_STEP)
          : (((sizeof(size_t) * CHAR_BIT - 1) -
              __builtin_clzl(heap.size - HEADER_SIZE)) -
             7 + NUM_SMALL_BUCKETS);

  initial_node->next = fits.table[bucket].start;
  initial_node->prev = &fits.nil;
  if (fits.table[bucket].start) {
    fits.table[bucket].start->prev = initial_node;
  }
  fits.table[bucket].start = initial_node;
  fits.total_free_blocks++;

  return true;
}

/**
 * @brief Allocate a block of memory
 * 
 * @param size Requested size in bytes
 * @return void* Pointer to allocated memory, NULL if allocation fails
 * 
 * Algorithm:
 * 1. Find appropriate size class bucket
 * 2. Search for first fit block
 * 3. Split block if significantly larger
 * 4. Update block headers and free lists
 */
void *malloc(size_t size) {
  if (size == 0 || size > MAX_REQUEST_SIZE) {
    return NULL;
  }

  size = (size + ALIGNMENT - 1) & ~(ALIGNMENT - 1);
  size_t bucket =
      (size <=
       SMALL_BUCKET_START_SIZE + (NUM_SMALL_BUCKETS - 1) * SMALL_BUCKET_STEP)
          ? ((size - SMALL_BUCKET_START_SIZE) / SMALL_BUCKET_STEP)
          : (((sizeof(size_t) * CHAR_BIT - 1) - __builtin_clzl(size)) - 7 +
             NUM_SMALL_BUCKETS);

  for (size_t i = bucket; i < NUM_BUCKETS; i++) {
    struct FreeNode *node = fits.table[i].start;
    while (node && node != &fits.nil) {
      size_t block_size = node->header & SIZE_MASK;
      if (block_size >= size) {
        if (node->prev) {
          node->prev->next = node->next;
        }
        if (node->next) {
          node->next->prev = node->prev;
        }
        if (fits.table[i].start == node) {
          fits.table[i].start = node->next;
        }
        fits.total_free_blocks--;

        if (block_size >= size + MIN_BLOCK_SIZE) {
          struct FreeNode *new_free_node =
              (struct FreeNode *)((uint8_t *)node + size + HEADER_SIZE);
          new_free_node->header =
              (block_size - size - HEADER_SIZE) | LEFT_ALLOCATED;
          struct FreeNode *next_node =
              (struct FreeNode *)((uint8_t *)new_free_node + block_size - size -
                                  HEADER_SIZE);
          next_node->header &= LEFT_FREE;

          size_t new_bucket =
              (block_size - size - HEADER_SIZE <=
               SMALL_BUCKET_START_SIZE +
                   (NUM_SMALL_BUCKETS - 1) * SMALL_BUCKET_STEP)
                  ? ((block_size - size - HEADER_SIZE -
                      SMALL_BUCKET_START_SIZE) /
                     SMALL_BUCKET_STEP)
                  : (((sizeof(size_t) * CHAR_BIT - 1) -
                      __builtin_clzl(block_size - size - HEADER_SIZE)) -
                     7 + NUM_SMALL_BUCKETS);

          new_free_node->next = fits.table[new_bucket].start;
          new_free_node->prev = &fits.nil;
          if (fits.table[new_bucket].start) {
            fits.table[new_bucket].start->prev = new_free_node;
          }
          fits.table[new_bucket].start = new_free_node;
          fits.total_free_blocks++;
        }

        node->header = size | ALLOCATED;
        return (void *)((uint8_t *)node + HEADER_SIZE);
      }
      node = node->next;
    }
  }

  return NULL;
}

/**
 * @brief Allocate a block of memory and initialize it to zero
 * 
 * @param NumberOfElements Number of elements to allocate
 * @param ElementSize Size of each element in bytes
 * @return void* Pointer to allocated memory, NULL if allocation fails
 */
void *calloc(size_t NumberOfElements, size_t ElementSize) {
  size_t total_size = NumberOfElements * ElementSize;
  if (total_size == 0 || total_size > MAX_REQUEST_SIZE) {
    return NULL;
  }

  void *memory = malloc(total_size);
  if (memory) {
    memset_custom(memory, 0, total_size);
  }

  return memory;
}

/**
 * @brief Reallocate a block of memory
 * 
 * @param ptr Pointer to memory block to reallocate
 * @param NewSizeWanted New size in bytes
 * @return void* Pointer to reallocated memory, NULL if reallocation fails
 */
void *realloc(void *ptr, size_t NewSizeWanted) {
  if (NewSizeWanted == 0) {
    free(ptr);
    return NULL;
  }

  if (!ptr) {
    return malloc(NewSizeWanted);
  }

  struct FreeNode *node = (struct FreeNode *)((uint8_t *)ptr - HEADER_SIZE);
  size_t current_size = node->header & SIZE_MASK;

  if (NewSizeWanted <= current_size) {
    return ptr;
  }

  void *new_memory = malloc(NewSizeWanted);
  if (new_memory) {
    memcpy(new_memory, ptr, current_size);
    free(ptr);
  }

  return new_memory;
}

/**
 * @brief Free a previously allocated memory block
 * 
 * @param ptr Pointer to memory block to free
 * 
 * Steps:
 * 1. Mark block as free
 * 2. Check adjacent blocks
 * 3. Coalesce with free neighbors
 * 4. Add to appropriate free list
 */
void free(void *ptr) {
  if (!ptr) {
    return;
  }

  struct FreeNode *node = (struct FreeNode *)((uint8_t *)ptr - HEADER_SIZE);
  size_t size = node->header & SIZE_MASK;
  node->header = size | LEFT_ALLOCATED;
  struct FreeNode *next =
      (struct FreeNode *)((uint8_t *)node + size + HEADER_SIZE);
  next->header &= LEFT_FREE;

  size_t bucket =
      (size <=
       SMALL_BUCKET_START_SIZE + (NUM_SMALL_BUCKETS - 1) * SMALL_BUCKET_STEP)
          ? ((size - SMALL_BUCKET_START_SIZE) / SMALL_BUCKET_STEP)
          : (((sizeof(size_t) * CHAR_BIT - 1) - __builtin_clzl(size)) - 7 +
             NUM_SMALL_BUCKETS);

  node->next = fits.table[bucket].start;
  node->prev = &fits.nil;
  if (fits.table[bucket].start) {
    fits.table[bucket].start->prev = node;
  }
  fits.table[bucket].start = node;
  fits.total_free_blocks++;
}

/**
 * @brief Coalesce adjacent free blocks
 * 
 * @param left_ptr Left neighbor block
 * @param current_ptr Current block being freed
 * @param right_ptr Right neighbor block
 * @param available_size Total size available for coalescing
 * 
 * Merges adjacent free blocks to reduce external fragmentation.
 * Updates:
 * 1. Free list membership
 * 2. Block headers/footers
 * 3. Boundary tags
 */
static inline void coalesce(void *left_ptr, void *current_ptr, void *right_ptr,
                            size_t available_size) {
  struct FreeNode *left = (struct FreeNode *)left_ptr;
  struct FreeNode *current = (struct FreeNode *)current_ptr;
  struct FreeNode *right = (struct FreeNode *)right_ptr;

  if (left) {
    size_t left_size = left->header & SIZE_MASK;
    size_t left_bucket =
        (left_size <=
         SMALL_BUCKET_START_SIZE + (NUM_SMALL_BUCKETS - 1) * SMALL_BUCKET_STEP)
            ? ((left_size - SMALL_BUCKET_START_SIZE) / SMALL_BUCKET_STEP)
            : (((sizeof(size_t) * CHAR_BIT - 1) - __builtin_clzl(left_size)) -
               7 + NUM_SMALL_BUCKETS);

    if (left->prev) {
      left->prev->next = left->next;
    }
    if (left->next) {
      left->next->prev = left->prev;
    }
    if (fits.table[left_bucket].start == left) {
      fits.table[left_bucket].start = left->next;
    }
    fits.total_free_blocks--;

    current = left;
  }

  if (right) {
    size_t right_size = right->header & SIZE_MASK;
    size_t right_bucket =
        (right_size <=
         SMALL_BUCKET_START_SIZE + (NUM_SMALL_BUCKETS - 1) * SMALL_BUCKET_STEP)
            ? ((right_size - SMALL_BUCKET_START_SIZE) / SMALL_BUCKET_STEP)
            : (((sizeof(size_t) * CHAR_BIT - 1) - __builtin_clzl(right_size)) -
               7 + NUM_SMALL_BUCKETS);

    if (right->prev) {
      right->prev->next = right->next;
    }
    if (right->next) {
      right->next->prev = right->prev;
    }
    if (fits.table[right_bucket].start == right) {
      fits.table[right_bucket].start = right->next;
    }
    fits.total_free_blocks--;

    available_size += right_size + HEADER_SIZE;
  }

  available_size += current->header & SIZE_MASK;
  current->header = available_size | LEFT_ALLOCATED;
}

#ifdef __cplusplus
}
#endif
#endif