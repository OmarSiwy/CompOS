#ifndef COMPOS_STDINT_H_
#define COMPOS_STDINT_H_

/* --------------------------------------------------------------------------
 * Architecture Detection
 * -------------------------------------------------------------------------- */

/* Detect system architecture (bits) */
#if defined(__x86_64__) || defined(_M_X64) || defined(__aarch64__) ||          \
    defined(_M_ARM64)
#define ARCH_BITS 64
#elif defined(__i386__) || defined(_M_IX86) || defined(__arm__) ||             \
    defined(__thumb__) || defined(_M_ARM)
#define ARCH_BITS 32
#elif defined(__AVR__)
#define ARCH_BITS 8
#else
#error                                                                         \
    "Unsupported architecture. Only 8-bit, 32-bit, and 64-bit systems are supported."
#endif

/* --------------------------------------------------------------------------
 * Type Definitions
 * -------------------------------------------------------------------------- */

#if ARCH_BITS == 8
typedef unsigned char uint8_t;
typedef signed char int8_t;
typedef unsigned short uint16_t;
typedef signed short int16_t;
typedef unsigned long uint32_t;
typedef signed long int32_t;
typedef unsigned long long uint64_t;
typedef signed long long int64_t;
typedef uint16_t size_t;

#elif ARCH_BITS == 32
typedef unsigned char uint8_t;
typedef signed char int8_t;
typedef unsigned short uint16_t;
typedef signed short int16_t;
typedef unsigned int uint32_t;
typedef signed int int32_t;
typedef unsigned long long uint64_t;
typedef signed long long int64_t;
typedef uint32_t size_t;

#elif ARCH_BITS == 64
typedef unsigned char uint8_t;
typedef signed char int8_t;
typedef unsigned short uint16_t;
typedef signed short int16_t;
typedef unsigned int uint32_t;
typedef signed int int32_t;
typedef unsigned long uint64_t;
typedef signed long int64_t;
typedef uint64_t size_t;

#else
#error "Unknown architecture detected. Cannot define standard types."
#endif

/* --------------------------------------------------------------------------
 * Boolean Type Definition (if unavailable)
 * -------------------------------------------------------------------------- */
#ifndef __cplusplus
#if !defined(bool) && !defined(__bool_true_false_are_defined)
typedef _Bool bool;
#define true 1
#define false 0
#define __bool_true_false_are_defined 1
#endif
#endif

/* --------------------------------------------------------------------------
 * Compile-Time Information and Debugging
 * -------------------------------------------------------------------------- */
#if ARCH_BITS == 8
#define PRINT_ARCH() _Pragma("message(\"Detected Architecture: 8-bit system\")")
#elif ARCH_BITS == 32
#define PRINT_ARCH()                                                           \
  _Pragma("message(\"Detected Architecture: 32-bit system\")")
#elif ARCH_BITS == 64
#define PRINT_ARCH()                                                           \
  _Pragma("message(\"Detected Architecture: 64-bit system\")")
#endif

#endif /* COMPOS_STDINT_H_ */
