#include "ff.h"
#include "image.h"

image_t image_read(const char *path) {
    image_t image;
    FIL fp;
    f_open(&fp, path, 'r');
    // Assume that its a valid 64x64 pgm, max value of 255
    f_lseek(&fp, 13);
    UINT nread;
    f_read(&fp, image.pixels, FFT_N * FFT_N, &nread);
    return image;
}

void image_write(image_t *image, const char *path) {
    FIL fp;
    f_open(&fp, path, 'w');
    UINT nwrite;
    f_write(&fp, "P5\n64 64\n255\n", 13, &nwrite);
    f_write(&fp, image->pixels, FFT_N * FFT_N, &nwrite);
}

uint8_t **image_buf(image_t *image) {
    return (uint8_t **)&image->pixels;
}
