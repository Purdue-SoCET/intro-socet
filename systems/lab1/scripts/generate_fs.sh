#!/bin/bash
#
dd if=/dev/zero of=fs.fat bs=1024 count=16384
mkfs.vfat -F 16 -S 512 fs.fat
mcopy -i fs.fat ../images/cat.pgm ::CAT.PGM
