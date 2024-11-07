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

__attribute__((section(".noinit"))) cplx fftd_data[FFT_N][FFT_N];

int main(void) {
    FATFS fs;
    f_mount(&fs, "", 0);

    print("Starting image processing!\n");
    image_t image = image_read("0:CAT.PGM");
    print("Read in image!\n");
    print("Calculating FFT...\n");
    fft(image.pixels);
    for (int i = 0; i < FFT_N; i++) {
        for (int j = 0; j < FFT_N; j++) {
            fftd_data[i][j] = fft_data[i][j];
        }
    }
    print("Calculated FFT\n");
    image_write(&image, "0:FFT.PGM");
    print("Wrote FFT'd data!\n");
    print("Calculating iFFT...\n");
    ifft(image.pixels);
    print("Calculated iFFT\n");
    image_write(&image, "0:IFFT.PGM");
    print("Wrote image back!\n");
    // TODO: ideas for examples
    // 1. Create low pass filter
    // 2. Create high pass filter
    for (int i = 0; i < FFT_N; i++) {
        for (int j = 0; j < FFT_N; j++) {
            fft_data[i][j] = fftd_data[i][j];
        }
    }
    print("Applying filter...\n");
    apply_filter(high_pass);
    fft_to_pixels(image.pixels);
    print("Applied high pass filter!\n");
    image_write(&image, "0:HP.PGM");
    print("Wrote high pass FFT!\n");
    print("Calculating iFFT...\n");
    ifft(image.pixels);
    print("Calculated high pass iFFT\n");
    image_write(&image, "0:HPIFFT.PGM");
    print("Wrote high pass image back!\n");
    // 3. Create bandpass pass filter

    f_unmount("");
    return 0;
}
