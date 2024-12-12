#ifndef COMPOS_MATH_H_
#define COMPOS_MATH_H_

#include "types.h"

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

#define FastExponentiation(base, exp, result)                                  \
  do {                                                                         \
    result = 1;                                                                \
    unsigned int _e = (unsigned int)(exp);                                     \
    int _b = (base);                                                           \
    while (_e > 0) {                                                           \
      if (_e & 1)                                                              \
        result *= _b; /* If exp is odd */                                      \
      _b *= _b;                                                                \
      _e >>= 1; /* Divide exp by 2 */                                          \
    }                                                                          \
  } while (0)

/*
 * FastMultiplication and FastDivision are optimized for power of 2 values.
 */
#define FastMultiplication(x, y, result)                                       \
  do {                                                                         \
    if ((y) & ((y) - 1)) {                                                     \
      result = (x) * (y); /* Fallback to normal */                             \
    } else {                                                                   \
      result = (x) << __builtin_ctz(y); /* Power of 2 */                       \
    }                                                                          \
  } while (0)

#define FastDivision(x, y, result)                                             \
  do {                                                                         \
    if ((y) & ((y) - 1)) {                                                     \
      result = (x) / (y); /* Fallback to normal */                             \
    } else {                                                                   \
      result = (x) >> __builtin_ctz(y); /* Power of 2 */                       \
    }                                                                          \
  } while (0)

#endif
