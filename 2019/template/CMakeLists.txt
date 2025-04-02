cmake_minimum_required(VERSION 4.0)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_EXPORT_COMPILE_COMMANDS True)

project(Template)

add_executable(template src/main.cpp)

include(FetchContent)
FetchContent_Declare(cpr GIT_REPOSITORY https://github.com/libcpr/cpr.git GIT_TAG 1.11.2) 
FetchContent_MakeAvailable(cpr)
target_link_libraries(template PRIVATE cpr::cpr)