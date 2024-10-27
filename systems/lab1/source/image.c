#include "image.h"

image_t image_read(const char *path) {
    image_t image;
    FILE *fp = fopen(path, "r");
    // Assume that its a valid 64x64 pgm, max value of 255
    fseek(fp, 13, SEEK_CUR);
    fread(image.pixels, 1, FFT_N * FFT_N, fp);
    return image;
}

void image_write(image_t *image, const char *path) {
    FILE *fp = fopen(path, "w");
    fwrite("P5\n64 64\n255\n", 1, 13, fp);
    fwrite(image->pixels, 1, FFT_N * FFT_N, fp);
}

uint8_t **image_buf(image_t *image) {
    return (uint8_t **)&image->pixels;
}
