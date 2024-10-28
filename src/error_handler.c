#include "error_handler.h"

extern uint32_t fibonnaci(uint32_t n);

uint32_t display(uint32_t n) {
  uint32_t result = fibonnaci(n);
  return result;
}
