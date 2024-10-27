#ifndef IMAGE_H
#define IMAGE_H

#include "fft.h"
#include <stdint.h>
#include <stdio.h>

typedef struct {
    uint8_t pixels[FFT_N][FFT_N];
} image_t;

// Reads a file at `path` as a pgm file. Assumes file to be valid FFT_NxFFT_N pgm image
image_t image_read(const char *path);

// Writes to `path` as a pgm file.
void image_write(image_t *image, const char *path);

// Returns a 2D array representing the pixel buffer of the image.
uint8_t **image_buf(image_t *image);

#endif
