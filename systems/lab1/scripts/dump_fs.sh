#!/bin/bash

FS=fs_modified.fat

echo "=============CONTENTS OF $FS===================="
mdir -i $FS
echo "================================================"

echo "Dumping fft.pgm"
mcopy -i $FS ::FFT.PGM fft.pgm
echo "Dumping ifft.pgm"
mcopy -i $FS ::IFFT.PGM ifft.pgm
echo "Dumping highpass.pgm"
mcopy -i $FS ::HIGHPASS.PGM highpass.pgm
