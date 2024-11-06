#include "ff.h"
#include "fft.h"
#include "filter.h"
#include "format.h"
#include "image.h"

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
    FATFS fs;
    f_mount(&fs, "", 0);

    print("Starting image processing!\n");
    image_t image = image_read("0:CAT.PGM");
    print("Read in image!\n");
    fft(image.pixels);
    print("Calculated FFT\n");
    image_write(&image, "0:FFT.PGM");
    print("Wrote FFT'd data!\n");
    // TODO: ideas for examples
    // 1. Create low pass filter
    // 2. Create high pass filter
    apply_filter(high_pass);
    print("Applied high pass filter!\n");
    fft_to_pixels(image.pixels);
    image_write(&image, "0:HIGHPASS.PGM");
    print("Wrote high pass fft!\n");
    // 3. Create bandpass pass filter
    ifft(image.pixels);
    print("Calculated iFFT\n");
    image_write(&image, "0:IFFT.PGM");
    print("Wrote image back!\n");

    f_unmount("");
    return 0;
}
