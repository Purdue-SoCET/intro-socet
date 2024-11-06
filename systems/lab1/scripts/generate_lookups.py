import math

n = 64
header = f'''\
//
// Sine and cosine wave lookup table. Generated by scripts/generate_lookup.py. DO NOT MODIFY.
//
#ifndef LOOKUP_H
#define LOOKUP_H

#include <stdint.h>

#define N_WAVE {n}

const int32_t sin_lookup[N_WAVE / 2] = {{
'''

midder = """\
};

const int32_t cos_lookup[N_WAVE / 2] = {
"""

footer = """\
};

#endif
"""

def s32(value):
    if value < 0:
        return (1 << 32) + int(value)
    else:
        return int(value)

def main():
    out_file = "source/lookup.h"
    with open(out_file, "w") as f:
        f.write(header)
        for i in range(0, n, 2):
            val = # TODO
            sin_value = # TODO
            sin_fp = # TODO
            f.write(f'    0x{sin_fp:x},\n')
        f.write(midder)
        for i in range(0, n, 2):
            val = # TODO
            cos_value = # TODO
            cos_fp = # TODO
            f.write(f'    0x{cos_fp:x},\n')
        f.write(footer)
        f.flush()

if __name__ == "__main__":
    main()
