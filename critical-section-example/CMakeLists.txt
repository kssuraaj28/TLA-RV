cmake_minimum_required(VERSION 3.1)
project(mutual_exclusion)

add_executable(nolock critical_section.cpp)
add_executable(mutex critical_section.cpp)
target_compile_definitions(mutex PRIVATE ENABLE_MUTEX)
