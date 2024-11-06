#include "fp.h"
#include <stdio.h>

fixed_point_t fp_from_u32(uint32_t a) {
    uint8_t frac = a & 0xFF;
    uint32_t whol = a >> 8;
    fixed_point_t fp = {.frac = frac, .whol = whol};
    return fp;
}

int32_t i32_from_fp(fixed_point_t a) {
    return a.whol << 8 | a.frac;
}

uint32_t u32_from_fp(fixed_point_t a) {
    uint32_t whol = a.whol;
    uint32_t frac = a.frac & 0xFF;
    return whol << 8 | frac;
}

fixed_point_t fp_add(fixed_point_t a, fixed_point_t b) {
    int32_t a_casted = i32_from_fp(a);
    int32_t b_casted = i32_from_fp(b);
    return fp_from_u32(a_casted + b_casted);
}

fixed_point_t fp_sub(fixed_point_t a, fixed_point_t b) {
    int32_t a_casted = i32_from_fp(a);
    int32_t b_casted = i32_from_fp(b);
    return fp_from_u32(a_casted - b_casted);
}

fixed_point_t fp_mul(fixed_point_t a, fixed_point_t b) {
    int32_t a_casted = i32_from_fp(a);
    int32_t b_casted = i32_from_fp(b);
    int64_t c = ((int32_t)a_casted * (int32_t)b_casted) >> 8;
    int64_t d = ((int32_t)a_casted * (int32_t)b_casted) >> 7;
    int64_t adjustment = d & 0x1;
    int64_t corrected = c + adjustment;
    return fp_from_u32(corrected & 0xFFFFFFFF);
}

fixed_point_t fp_div(fixed_point_t a, fixed_point_t b) {
    int64_t a_casted = i32_from_fp(a);
    int64_t b_casted = i32_from_fp(b);
    int64_t c = (a_casted * (1 << FP_FRAC_SIZE)) / b_casted;
    return fp_from_u32(c & 0xFFFFFFFF);
}

fixed_point_t fp_div_scalar(fixed_point_t a, uint32_t b) {
    int64_t a_casted = i32_from_fp(a);
    int64_t c = a_casted / b;
    return fp_from_u32(c & 0xFFFFFFFF);
}

fixed_point_t fp_sqrt(fixed_point_t a) {
    uint32_t x = 1 << FP_FRAC_SIZE;
    uint64_t a_casted = (uint64_t)u32_from_fp(a) << FP_FRAC_SIZE;
    while (1) {
        uint64_t x_old = x;
        x = (x + a_casted / x) / 2;
        if ((x - x_old == 1) || (x_old - x == 1) || x_old == x)
            break;
    }
    fixed_point_t res = fp_from_u32(x & 0xffffffff);
    return res;
}

// From: https://github.com/dmoulding/log2fix
fixed_point_t fp_log2(fixed_point_t a) {
    uint32_t x = u32_from_fp(a);
    int32_t b = 1U << (FP_FRAC_SIZE - 1);
    int32_t y = 0;

    while (x < 1U << FP_FRAC_SIZE) {
        x <<= 1;
        y -= 1U << FP_FRAC_SIZE;
    }

    while (x >= 2U << FP_FRAC_SIZE) {
        x >>= 1;
        y += 1U << FP_FRAC_SIZE;
    }

    uint64_t z = x;

    for (size_t i = 0; i < FP_FRAC_SIZE; i++) {
        z = z * z >> FP_FRAC_SIZE;
        if (z >= 2U << (uint64_t)FP_FRAC_SIZE) {
            z >>= 1;
            y += b;
        }
        b >>= 1;
    }

    return fp_from_u32(y);
}

fixed_point_t fp_max(fixed_point_t a, fixed_point_t b) {
    if (a.whol > b.whol) {
        return a;
    } else if (a.whol == b.whol && a.frac > b.frac) {
        return a;
    } else {
        return b;
    }
}
