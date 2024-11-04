#ifndef FFT_H
#define FFT_H

#include "fp.h"
#include <complex.h>
#include <stdint.h>

#define FFT_N 64

typedef struct {
    fixed_point_t real;
    fixed_point_t imag;
} cplx;

fixed_point_t cplx_abs(cplx z);
cplx cplx_add(cplx a, cplx b);
cplx cplx_sub(cplx a, cplx b);
cplx cplx_mul(cplx a, cplx b);
cplx cplx_div(cplx a, uint32_t b);

// Calculates the Fourier transform of an FFT_NxFFT_N image at *pixel_buf (row-major order). The
// result is put back into *pixel_buf.
void fft(uint8_t pixel_buf[FFT_N][FFT_N]);
void ifft(uint8_t pixel_buf[FFT_N][FFT_N]);
void fft_to_pixels(uint8_t pixel_buf[FFT_N][FFT_N]);

// Access to the fft'd/ifft'd data
extern cplx fft_data[FFT_N][FFT_N];

#endif
