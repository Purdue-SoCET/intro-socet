#ifndef FILTER_H
#define FILTER_H

#include "fft.h"

// Takes in the x and y coordinates and the current value of the pixel, and returns the pixel which
// should replace it
typedef cplx (*filter_fn)(uint32_t x, uint32_t y, cplx curr);

void apply_filter(filter_fn f);

#endif
