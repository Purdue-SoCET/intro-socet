#include "fft.h"
#include "lookup.h"
#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

// Determines whether to use LOGSCALING when determining pixel values for FFT'd data. Uses log2 so
// pretty computationally expensive.
#define LOGSCALING 0

__attribute__((section(".noinit"))) cplx fft_data[FFT_N][FFT_N];

fixed_point_t cplx_abs(cplx z) {
    fixed_point_t real = fp_mul(z.real, z.real);
    fixed_point_t imag = fp_mul(z.imag, z.imag);
    fixed_point_t sum = fp_add(real, imag);
    return fp_sqrt(sum);
}
cplx cplx_add(cplx a, cplx b) {
    cplx z = {.real = fp_add(a.real, b.real), .imag = fp_add(a.imag, b.imag)};
    return z;
}
cplx cplx_sub(cplx a, cplx b) {
    cplx z = {.real = fp_sub(a.real, b.real), .imag = fp_sub(a.imag, b.imag)};
    return z;
}
cplx cplx_mul(cplx a, cplx b) {
    // (a + bi) * (c + di) = (ac-bd) + (ad + bc)j
    cplx z = {.real = fp_sub(fp_mul(a.real, b.real), fp_mul(a.imag, b.imag)),
              .imag = fp_add(fp_mul(a.real, b.imag), fp_mul(a.imag, b.real))};
    return z;
}
cplx cplx_div(cplx a, uint32_t b) {
    cplx z = {.real = fp_div_scalar(a.real, b), .imag = fp_div_scalar(a.imag, b)};
    return z;
}

// Temporary storage that can be used by fft functions in order to reduce stack sizes. Can be
// clobbered across fft/ifft calls
__attribute__((section(".noinit"))) cplx temp[FFT_N][FFT_N];

// TODO:
// remove fp usage, use fixed point
void recursive_fft(cplx buf[], cplx out[], int step, bool inverse) {
    if (step < FFT_N) {
        recursive_fft(out, buf, step * 2, inverse);
        recursive_fft(out + step, buf + step, step * 2, inverse);

        for (int i = 0; i < FFT_N; i += 2 * step) {
            cplx z;
            z.real = fp_from_u32(cos_lookup[i / 2]);
            z.imag = fp_from_u32(-sin_lookup[i / 2]);
            if (inverse)
                z.imag = fp_from_u32(~i32_from_fp(z.imag) + 1);
            cplx t = cplx_mul(z, out[i + step]);
            buf[i / 2] = cplx_add(out[i], t);
            buf[(i + FFT_N) / 2] = cplx_sub(out[i], t);
        }
    }
}

void fft_loop(cplx buf[], bool inverse) {
    cplx out[FFT_N];
    for (int i = 0; i < FFT_N; i++)
        out[i] = buf[i];

    recursive_fft(buf, out, 1, inverse);
}

// In place fft
void fft(uint8_t pixel_buf[FFT_N][FFT_N]) {
    // Create complex values from pixel values and do the FFT for each row
    for (int i = 0; i < FFT_N; i++) {
        for (int j = 0; j < FFT_N; j++) {
            // 256 -> 0x0100
            // 128 -> 0x0080
            // 064 -> 0x0040
            // 032 -> 0x0020
            // 016 -> 0x0010
            // 000 -> 0x0000
            temp[i][j].real = fp_from_u32(pixel_buf[i][j]);
            temp[i][j].imag = fp_from_u32(0);
        }
        fft_loop(temp[i], false);
    }

    // Transpose
    for (int i = 0; i < FFT_N; i++) {
        for (int j = 0; j < FFT_N; j++) {
            fft_data[i][j] = temp[j][i];
        }
    }

    // Do FFT for each column
    for (int i = 0; i < FFT_N; i++) {
        fft_loop(fft_data[i], false);
    }

    fft_to_pixels(pixel_buf);
}

// Convert `fft_data` to pixel values using logarithmic scaling
void fft_to_pixels(uint8_t pixel_buf[FFT_N][FFT_N]) {
#if LOGSCALING
    // Calculate max value
    fixed_point_t r = fp_from_u32(0);
    for (int i = 0; i < FFT_N; i++) {
        for (int j = 0; j < FFT_N; j++) {
            r = fp_max(r, cplx_abs(fft_data[i][j]));
        }
    }
    // c = 255 / log(1+r)
    fixed_point_t max = fp_from_u32(255 << FP_FRAC_SIZE);
    fixed_point_t one = fp_from_u32(1 << FP_FRAC_SIZE);
    fixed_point_t a = fp_add(one, r);
    fixed_point_t c = fp_div(max, fp_log2(a));
    // w(i, j) = c * log(1 + |r|)
    for (int i = 0; i < FFT_N; i++) {
        for (int j = 0; j < FFT_N; j++) {
            fixed_point_t sqr_root = cplx_abs(fft_data[i][j]);
            fixed_point_t a = fp_add(one, sqr_root);
            fixed_point_t log_val = fp_log2(a);
            fixed_point_t val = fp_mul(c, log_val);
            pixel_buf[i][j] = val.whol;
        }
    }
#else
    // Simple absolute value printing
    for (int i = 0; i < FFT_N; i++) {
        for (int j = 0; j < FFT_N; j++) {
            fixed_point_t sqr_root = cplx_abs(fft_data[i][j]);
            pixel_buf[i][j] = sqr_root.whol;
        }
    }
#endif
}

void ifft(uint8_t pixel_buf[FFT_N][FFT_N]) {
    // Do FFT of each row
    for (int i = 0; i < FFT_N; i++) {
        fft_loop(fft_data[i], true);
    }

    // Transpose and do the FFT of each column
    for (int i = 0; i < FFT_N; i++) {
        for (int j = 0; j < FFT_N; j++) {
            temp[i][j] = fft_data[j][i];
        }
        fft_loop(temp[i], true);
    }

    // Scale by FFT_N*FFT_N
    for (int i = 0; i < FFT_N; i++) {
        for (int j = 0; j < FFT_N; j++) {
            temp[i][j] = cplx_div(temp[i][j], FFT_N * FFT_N);
        }
    }

    // Calculate pixel values
    fixed_point_t max = fp_from_u32(256 << FP_FRAC_SIZE);
    for (int i = 0; i < FFT_N; i++) {
        for (int j = 0; j < FFT_N; j++) {
            fixed_point_t a = cplx_abs(temp[i][j]);
            fixed_point_t mul = fp_mul(a, max);
            pixel_buf[i][j] = mul.whol;
        }
    }
}
