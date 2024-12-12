#ifndef COMPOS_CONFIG_H_
#define COMPOS_CONFIG_H_

#include "assert.h"
#include "types.h"

// ! Functions meant to be overriden by the user

/**
 * @brief Default PanicHandler.
 * Users can provide their own implementation to override this.
 */
__attribute__((weak)) void PanicHandler(void) {
  while (1)
    ;
}

/**
 * @brief Default PanicHandlerWithInfo.
 * Provides file, line, and condition details.
 * Users can override this with their own implementation.
 */
__attribute__((weak)) void PanicHandlerWithInfo(const char *file, int line,
                                                const char *condition) {
  UNUSED(file);
  UNUSED(line);
  UNUSED(condition);

  while (1)
    ;
}

#endif
