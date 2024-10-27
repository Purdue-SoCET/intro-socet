cmake_minimum_required(VERSION 3.0)
project(intro-socet-system1)

add_compile_options(-Wall -Wextra -Wpedantic -Werror -pedantic-errors -fsanitize=address -fstack-usage)
add_link_options(-fsanitize=address)
include_directories(${PROJECT_SOURCE_DIR})
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_COLOR_DIAGNOSTICS ON)

set(SRCS
    source/fft.c
    source/filter.c
    source/image.c
    source/fp.c)
set(MAIN_SRCS
    source/main.c ${SRCS})

add_executable(intro-socet ${MAIN_SRCS})
set_property(TARGET intro-socet PROPERTY C_STANDARD_REQUIRED ON)
set_property(TARGET intro-socet PROPERTY C_STANDARD 11)
