#include "fft.h"
#include "filter.h"
#include "format.h"
#include "image.h"
#include <math.h>

cplx high_pass(uint32_t x, uint32_t y, cplx curr) {
    int32_t center = -32;
    int32_t offset_x = x + center;
    int32_t offset_y = y + center;
    int32_t square_x = offset_x * offset_x;
    int32_t square_y = offset_y * offset_y;
    cplx z;
    if ((square_x + square_y) < (32 * 32)) {
        z.real = fp_from_u32(0);
        z.imag = fp_from_u32(0);
    } else {
        z = curr;
    }
    return z;
}

int main(void) {
    image_t image = image_read("../images/cat.pgm");
    fft(image.pixels);
    image_write(&image, "fft.pgm");
    // TODO: ideas for examples
    // 1. Create low pass filter
    // 2. Create high pass filter
    // apply_filter(high_pass);
    // fft_to_pixels(image.pixels);
    // image_write(&image, "high_pass.pgm");
    // 3. Create bandpass pass filter
    ifft(image.pixels);
    image_write(&image, "ifft.pgm");
    return 0;
}
