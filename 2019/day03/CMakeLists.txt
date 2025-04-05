cmake_minimum_required(VERSION 4.0)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_EXPORT_COMPILE_COMMANDS True)

project(Day)

add_executable(main src/main.cpp)
target_compile_options(main PRIVATE -Wall -Wextra -Wpedantic -Werror -O3)
