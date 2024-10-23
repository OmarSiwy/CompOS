#include "error_handler.h"
#include <stdio.h>

int add(int a, int b) {
  return a + b;
}

int array() {
    // Get the precomputed array from Zig
    const unsigned int* array = get_precomputed_array();

    // Print the array values
    printf("Precomputed array: \n");
    for (int i = 0; i < 10; ++i) {
        printf("%u ", array[i]);
    }
    printf("\n");

    return 0;
}

int comptimereflection() {
    // Get the number of fields in MyStruct from Zig
    unsigned long field_count = get_struct_field_count();
    printf("MyStruct has %lu fields\n", field_count);

    return 0;
}
