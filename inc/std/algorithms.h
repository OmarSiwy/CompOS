#ifndef COMPOS_ALGORITHMS_H_
#define COMPOS_ALGORITHMS_H_

/* --------------------------------------------------------------------------
 * Architecture Detection
 * -------------------------------------------------------------------------- */

/* ARM Cortex-M0 (STM32F030) */
#if defined(__ARM_ARCH_6M__) && defined(__thumb__)
#define TARGET_CORTEX_M0
#define ARCH_BITS 32

/* ARM Cortex-M3 (STM32F103) */
#elif defined(__ARM_ARCH_7M__) && defined(__thumb__)
#define TARGET_CORTEX_M3
#define ARCH_BITS 32

/* ARM Cortex-M4 (STM32F303, STM32F407, STM32L476) */
#elif defined(__ARM_ARCH_7EM__) && defined(__thumb__)
#define TARGET_CORTEX_M4
#define ARCH_BITS 32

/* ARM Cortex-M7 (STM32H743) */
#elif defined(__ARM_ARCH_7EM__) && defined(__thumb__)
#define TARGET_CORTEX_M7
#define ARCH_BITS 32

/* Unsupported Architecture */
#else
#error                                                                         \
    "Unsupported ARM Cortex architecture. Only Cortex-M0, M3, M4, and M7 are supported."
#endif

/* --------------------------------------------------------------------------
 * Type Definitions
 * -------------------------------------------------------------------------- */

#if defined(ARCH_BITS) && ARCH_BITS == 32
#define size_t uint32_t
#define uint8_t unsigned char
#define int8_t signed char
#define uint16_t unsigned short
#define int16_t short
#define uint32_t unsigned int
#define int32_t int
#define uint64_t unsigned long long
#define int64_t long long
#else
#error "Only 32-bit architectures are supported for STM32 targets."
#endif

/* --------------------------------------------------------------------------
 * Compile-Time Information and Debugging
 * -------------------------------------------------------------------------- */
#define PRINT_ARCH()                                                           \
  _Pragma("message(\"Detected Architecture: ARM Cortex-M (32-bit)\")")

/** @brief Swap two values of the same type.
 *  XOR swap is used for efficient swapping of small integer types.
 *  For larger or unsupported types, a temporary variable is used.
 */
#define SWAP(a, b)                                                             \
  do {                                                                         \
    _Static_assert(__builtin_types_compatible_p(typeof(a), typeof(b)),         \
                   "SWAP requires both arguments to be of the same type");     \
    if (__builtin_types_compatible_p(typeof(a), int8_t) ||                     \
        __builtin_types_compatible_p(typeof(a), uint8_t) ||                    \
        __builtin_types_compatible_p(typeof(a), int16_t) ||                    \
        __builtin_types_compatible_p(typeof(a), uint16_t) ||                   \
        __builtin_types_compatible_p(typeof(a), int32_t) ||                    \
        __builtin_types_compatible_p(typeof(a), uint32_t) ||                   \
        __builtin_types_compatible_p(typeof(a), int64_t) ||                    \
        __builtin_types_compatible_p(typeof(a), uint64_t)) {                   \
      a ^= b;                                                                  \
      b ^= a;                                                                  \
      a ^= b;                                                                  \
    } else {                                                                   \
      typeof(a) tmp = a;                                                       \
      a = b;                                                                   \
      b = tmp;                                                                 \
    }                                                                          \
  } while (0)

/** @brief Get the minimum of two values.
 *  Both arguments must be of the same type.
 */
#define MIN(a, b)                                                              \
  ({                                                                           \
    _Static_assert(__builtin_types_compatible_p(typeof(a), typeof(b)),         \
                   "MIN requires both arguments to be of the same type");      \
    (a < b) ? a : b;                                                           \
  })

/** @brief Get the maximum of two values.
 *  Both arguments must be of the same type.
 */
#define MAX(a, b)                                                              \
  ({                                                                           \
    _Static_assert(__builtin_types_compatible_p(typeof(a), typeof(b)),         \
                   "MAX requires both arguments to be of the same type");      \
    (a > b) ? a : b;                                                           \
  })

/** @brief Get the absolute value of an integer.
 *  Works with signed integer types (int8_t, int16_t, int32_t, int64_t).
 */
#define ABS(a)                                                                 \
  ({                                                                           \
    _Static_assert(__builtin_types_compatible_p(typeof(a), int8_t) ||          \
                       __builtin_types_compatible_p(typeof(a), int16_t) ||     \
                       __builtin_types_compatible_p(typeof(a), int32_t) ||     \
                       __builtin_types_compatible_p(typeof(a), int64_t),       \
                   "ABS requires a signed integer type");                      \
    (a < 0) ? -a : a;                                                          \
  })

#endif
