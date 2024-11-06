#ifndef FP_H
#define FP_H

#include <stdint.h>

#define FP_FRAC_SIZE 8
#define FP_WHOL_SIZE 24

// Q24.8 floating point value
typedef struct {
    uint32_t frac : 8;
    int32_t whol : 24;
} fixed_point_t;

fixed_point_t fp_from_u32(uint32_t a);
int32_t i32_from_fp(fixed_point_t a);
uint32_t u32_from_fp(fixed_point_t a);
extern fixed_point_t fp_add(fixed_point_t a, fixed_point_t b);
fixed_point_t fp_sub(fixed_point_t a, fixed_point_t b);
extern fixed_point_t fp_mul(fixed_point_t a, fixed_point_t b);
fixed_point_t fp_div(fixed_point_t a, fixed_point_t b);
fixed_point_t fp_div_scalar(fixed_point_t a, uint32_t b);
fixed_point_t fp_sqrt(fixed_point_t a);
fixed_point_t fp_log2(fixed_point_t a);
fixed_point_t fp_max(fixed_point_t a, fixed_point_t b);

#endif
