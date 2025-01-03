/**
 * @file compos_heap.h
 * @brief Header file for heap memory allocator configurations and declarations.
 *
 * Provides initialization and memory allocation functions for various
 * heap allocator implementations. Supports multiple allocator strategies
 * such as list allocator, red-black tree allocators, and others.
 */

#ifndef COMPOS_HEAP_H_
#define COMPOS_HEAP_H_

#include "config.h"
#include "types.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @defgroup AllocatorConfig Allocator Configuration
 * @brief Configuration macros for selecting an allocator implementation.
 */

/**
 * @brief Verifies that exactly one allocator option is defined.
 *
 * At compile time, ensures that one and only one allocator option is defined.
 * If not, a warning is generated. Supported options are:
 * - USE_LIST_ALLOCATOR
 * - USE_RBTOPDOWN_ALLOCATOR
 * - USE_RBLINKED_ALLOCATOR
 * - USE_ZIG_ALLOCATOR
 * - NO_ALLOCATOR
 * - USE_CLANG_ALLOCATOR
 */
#if defined(USE_LIST_ALLOCATOR) + defined(USE_ZIG_ALLOCATOR) +         \
        defined(NO_ALLOCATOR) + defined(USE_CLANG_ALLOCATOR) !=                \
    1
#error                                                                         \
    "Exactly one allocator option must be defined. Define one of: USE_LIST_ALLOCATOR, USE_RBTOPDOWN_ALLOCATOR, USE_RBLINKED_ALLOCATOR, USE_ZIG_ALLOCATOR, or NO_ALLOCATOR, or USE_CLANG_ALLOCATOR."
#endif
#if defined(USE_LIST_ALLOCATOR)
// #pragma message("Allocator Option: List Allocator")
#elif defined(USE_ZIG_ALLOCATOR)
// #pragma message("Allocator Option: Zig Allocator")
#elif defined(NO_ALLOCATOR)
// #pragma message("Allocator Option: No Allocator")
#elif defined(USE_CLANG_ALLOCATOR)
// #pragma message("Allocator Option: Clang Allocator")
#else
#pragma message("No Allocator Picked, Please go fix that")
#endif

/**
 * @brief Includes standard library memory functions when using CLANG allocator.
 */
#if defined(USE_CLANG_ALLOCATOR)
uint8_t AllocatorInit(void *heap_start, size_t heap_size) {
    return 1;
}

void AllocatorDeinit() {
    return;
}
#include <stdlib.h>
#else

/**
 * @brief Memory allocation API declarations.
 *
 * These functions are only defined when NO_ALLOCATOR and USE_CLANG_ALLOCATOR
 * are not set. Implementations are provided based on the selected allocator
 * strategy.
 */

/**
 * @brief Initializes the heap allocator.
 *
 * @param heap_start A pointer to the start of the heap memory region.
 * @param heap_size The total size of the heap memory region.
 * @return `1` if initialization is successful, `0` otherwise.
 */
extern uint8_t AllocatorInit(void *heap_start, size_t heap_size);

/**
 * @brief Allocates a block of memory from the heap.
 *
 * @param SizeWanted The size of the memory block to allocate in bytes.
 * @return A pointer to the allocated memory block, or `NULL` if allocation
 * fails.
 */
extern void *malloc(size_t SizeWanted);

/**
 * @brief Allocates and initializes a block of memory.
 *
 * @param NumberOfElements The number of elements to allocate.
 * @param ElementSize The size of each element in bytes.
 * @return A pointer to the allocated and zero-initialized memory block,
 *         or `NULL` if allocation fails.
 */
extern void *calloc(size_t NumberOfElements, size_t ElementSize);

/**
 * @brief Resizes a previously allocated memory block.
 *
 * @param ptr A pointer to the previously allocated memory block.
 * @param NewSizeWanted The new size of the memory block in bytes.
 * @return A pointer to the resized memory block, or `NULL` if reallocation
 * fails.
 */
extern void *realloc(void *ptr, size_t NewSizeWanted);

/**
 * @brief Frees a previously allocated memory block.
 *
 * @param ptr A pointer to the memory block to free.
 *        If `NULL`, no action is taken.
 */
extern void free(void *ptr);

/**
 * @brief Deinitializes the heap allocator.
 */
extern void AllocatorDeinit();

#endif
#ifdef __cplusplus
}
#endif
#endif /* COMPOS_HEAP_H_ */
