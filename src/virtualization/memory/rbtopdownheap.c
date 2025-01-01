#include "virtualization/memory/heap.h"
#if defined(USE_RBTOPDOWN_ALLOCATOR)

uint8_t init(void *heap_start, size_t heap_size);
void *malloc(size_t SizeWanted);
void *calloc(size_t NumberOfElements, size_t ElementSize);
void *realloc(void* ptr, size_t NewSizeWanted);
void free(void *ptr);

#endif