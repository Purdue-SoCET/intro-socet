// fixed_point_t fp_add(fixed_point_t a, fixed_point_t b);
// Takes in two fixed_point_t values (Q24.8) and returns their sum.
//
// For a refresher on this algorithm, here's an example from the manual
// (remember that we don't need to convert between decimal and fixed
// point):
// 0.5 + (-0.5)         | Original calculation
// 0b00.10 + (-0b00.10) | Conversion to fixed point
// 0b00.10 + 0b11.10    | Two's complement conversion
// 0b00.00              | Binary addition
// 0                    | Conversion to decimal
.global fp_add
fp_add:
    # TODO
    ret

// fixed_point_t fp_mul(fixed_point_t a, fixed_point_t b);
// Takes in two fixed_point_t values (Q24.8) and returns their product.
//
// For a refresher on this algorithm, here's an example from the manual
// (remember that we don't need to convert between decimal and fixed
// point and two's complement conversion is the implicit format of signed
// values):
// 0  | 1.25 * (-0.5)             | Original calculation
// 1  | 0b01.01 * (-0b00.10)      | Conversion to fixed point
// 2  | 0b01.01 * 0b11.10         | Two's complement conversion
// 3  | 0b000001.01 * 0b111111.10 | Sign extension to Q6.2
// 4  | 0b111101.10               | Binary multiplication
// 5  | 0b111111.01               | Arithmetic right shift by number of fraction bits
// 6  | 0b111110.11               | Arithmetic right shift by number of fraction bits - 1
// 7  | 0b000000.01               | Bitwise & 0x1
// 8  | 0b111111.10               | Rounding correction adding 5 and 7
// 9  | 0b11.10                   | Truncating to original size
// 10 | -0.5                      | Conversion to decimal
.global fp_mul
fp_mul:
    # TODO
    ret
