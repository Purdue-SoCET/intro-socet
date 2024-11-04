set(CMAKE_C_COMPILER riscv64-unknown-elf-gcc)
set(CMAKE_CXX_COMPILER riscv64-unknown-elf-g++)
set(CMAKE_SYSTEM_NAME Generic)

cmake_minimum_required(VERSION 3.0)
project(intro-socet-system1)

enable_language(ASM)

set(COMMON_COMPILE_OPTIONS
    -march=rv32imc_zicsr_zifencei
    -mabi=ilp32
    -mcmodel=medany
    -O2
    -static
    -nostartfiles
    -ffreestanding
    -ffunction-sections
    -fdata-sections
    -Wall
    -Wextra
    -pedantic
)
set(LINK_OPTIONS
    "-T${CMAKE_CURRENT_SOURCE_DIR}/aft-femtokernel/arch/aftx07/link.ld"
    -Wl,--gc-sections
    -Wl,--warn-constructors
)
add_compile_options(${COMMON_COMPILE_OPTIONS})
add_link_options(${COMMON_COMPILE_OPTIONS} ${LINK_OPTIONS})

include_directories(${PROJECT_SOURCE_DIR})
include_directories(aft-femtokernel/include)
include_directories(aft-femtokernel/fatfs-aft/include)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_COLOR_DIAGNOSTICS ON)

set(SRCS
    source/fft.c
    source/filter.c
    source/image.c
    source/fp.c)
set(FEMTOKERNEL_SRCS
    aft-femtokernel/arch/aftx07/boot.S
    aft-femtokernel/kernel/alloc.c
    aft-femtokernel/kernel/bare.c
    aft-femtokernel/kernel/format.c
    aft-femtokernel/kernel/interrupt.c
    aft-femtokernel/kernel/kernel.c
    aft-femtokernel/kernel/riscv.c)
set(FATFS_LIB_SRCS
    aft-femtokernel/fatfs-aft/source/diskio.c
    aft-femtokernel/fatfs-aft/source/diskio.c
    aft-femtokernel/fatfs-aft/source/diskio_mmc.c
    aft-femtokernel/fatfs-aft/source/diskio_ram.c
    aft-femtokernel/fatfs-aft/source/diskio_usb.c
    aft-femtokernel/fatfs-aft/source/ff.c
    aft-femtokernel/fatfs-aft/source/ffsystem.c
    aft-femtokernel/fatfs-aft/source/ffunicode.c)
set(MAIN_SRCS
    source/main.c ${SRCS} ${FEMTOKERNEL_SRCS} ${FATFS_LIB_SRCS})

add_executable(intro-socet ${MAIN_SRCS})
set_property(TARGET intro-socet PROPERTY C_STANDARD_REQUIRED ON)
set_property(TARGET intro-socet PROPERTY C_STANDARD 11)
add_custom_command(
    TARGET intro-socet
    POST_BUILD
    COMMAND riscv64-unknown-elf-objcopy -O binary intro-socet intro-socet.bin
    COMMAND riscv64-unknown-elf-objdump -d intro-socet > intro-socet.dump
    COMMENT "Generating binary file and objdump"
)
