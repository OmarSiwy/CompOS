// File to handle errors during run_time

#ifndef ERROR_HANDLER_H_
#define ERROR_HANDLER_H_

#include <stdint.h>

/**
 * @brief Function to handle errors during run_time, prints the error message and exits the program
 *
 * @param condition The condition to check, if true then the error message is printed and the program exits
 * @param error_message The error message to print
 */

/******************************************************************************
 * A brief history of JavaDoc-style (C-style) banner comments.
 *
 * This is the typical JavaDoc-style C-style "banner" comment. It starts with
 * a forward slash followed by some number, n, of asterisks, where n > 2. It's
 * written this way to be more "visible" to developers who are reading the
 * source code.
 *
 * Often, developers are unaware that this is not (by default) a valid Doxygen
 * comment block!
 *
 * However, as long as JAVADOC_BANNER = YES is added to the Doxyfile, it will
 * work as expected.
 *
 * This style of commenting behaves well with clang-format.
 *
 * @param theory Even if there is only one possible unified theory. it is just a
 *               set of rules and equations.
 ******************************************************************************/

// Works to comment as well
extern uint32_t display(uint32_t n);

#endif
