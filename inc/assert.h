#ifndef COMPOS_ASSERT_H_
#define COMPOS_ASSERT_H_

/**
 * @brief Marks unused parameters to avoid compiler warnings.
 */
#define UNUSED(x) (void)(x)

/**
 * @brief Custom ASSERT macro with debug information.
 * @param condition Expression to check.
 */
#define ASSERT(condition)                                                      \
  do {                                                                         \
    if (!(condition)) {                                                        \
      PanicHandlerWithInfo(__FILE__, __LINE__, #condition);                    \
    }                                                                          \
  } while (0)

#endif /* COMPOS_ASSERT_H_ */
