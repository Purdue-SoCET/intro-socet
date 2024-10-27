#include "filter.h"

void apply_filter(filter_fn f) {
    for (int i = 0; i < FFT_N; i++) {
        for (int j = 0; j < FFT_N; j++) {
            fft_data[i][j] = f(i, j, fft_data[i][j]);
        }
    }
}
