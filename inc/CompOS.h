#ifndef COMPOS_UTILITY_H_
#define COMPOS_UTILITY_H_

/**
 * @brief User-defined panic handler function.
 *
 * The user must implement this function in their application.
 * It should handle assertion failures by halting the system, logging errors,
 * or taking other appropriate actions.
 */
extern void PanicHandler(void);

/**
 * @brief Custom ASSERT macro for debugging.
 * @param condition Expression to check.
 * @param message   Optional message (not used in this minimal version).
 *
 * If the condition is false, the ASSERT macro triggers the PanicHandler.
 */
#define ASSERT(condition, message)                                             \
  do {                                                                         \
    if (!(condition)) {                                                        \
      PanicHandler();                                                          \
    }                                                                          \
  } while (0)

/**
 * @brief Align a given value to the nearest multiple of alignment.
 * @param value     The value to align.
 * @param alignment The alignment boundary (must be a power of 2).
 * @return Aligned value.
 */
#define ALIGN(value, alignment) ((value + (alignment - 1)) & ~(alignment - 1))

/**
 * @brief Macro to mark unused parameters (avoid compiler warnings).
 * @param x Parameter to mark as unused.
 */
#define UNUSED(x) (void)(x)

#endif // COMPOS_UTILITY_H_
