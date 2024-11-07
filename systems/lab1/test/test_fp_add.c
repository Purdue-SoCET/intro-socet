#include "../source/fp.h"
#include "format.h"

#define NUM_TESTS 5

fixed_point_t test_inputs[2 * NUM_TESTS] = {
    // 2.5 + 0
    {.whol = 2, .frac = .5 * 256},
    {.whol = 0, .frac = 0 * 256},

    // 0 + 2.5
    {.whol = 0, .frac = 0 * 256},
    {.whol = 2, .frac = .5 * 256},

    // -1 + 1
    {.whol = -1, .frac = 0 * 256},
    {.whol = 1, .frac = 0 * 256},

    // 2.5 + 0.5
    {.whol = 2, .frac = .5 * 256},
    {.whol = 0, .frac = .5 * 256},

    // 2.0 + (-2.0)
    {.whol = 2, .frac = 0 * 256},
    {.whol = -2, .frac = 0x00},
};

fixed_point_t test_outputs[NUM_TESTS] = {
    {.whol = 2, .frac = .5 * 256}, {.whol = 2, .frac = .5 * 256}, {.whol = 0, .frac = 0 * 256},
    {.whol = 3, .frac = 0 * 256},  {.whol = 0, .frac = 0 * 256},
};

int main(void) {
    print("Testing fp_add!\n");
    int fails = 0;
    for (int i = 0; i < NUM_TESTS; i++) {
        fixed_point_t a = test_inputs[2 * i];
        fixed_point_t b = test_inputs[2 * i + 1];
        fixed_point_t c = fp_add(a, b);
        if (u32_from_fp(test_outputs[i]) != u32_from_fp(c)) {
            print("Test case %d failed: ", i);
            fp_print(a);
            print(" + ");
            fp_print(b);
            print(" = ");
            fp_print(test_outputs[i]);
            print(", found ");
            fp_print(c);
            print("\n");
            fails++;
        } else {
            print("Test case %d passed: ", i);
            fp_print(a);
            print(" + ");
            fp_print(b);
            print(" = ");
            fp_print(test_outputs[i]);
            print("\n");
        }
    }
    print("Number of failures: %d\n", fails);

    return fails;
}
