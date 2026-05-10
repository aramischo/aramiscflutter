cmake_minimum_required(VERSION 3.10.2)
project(native-lib)

# Enforce 16 KB page size
set(CMAKE_ANDROID_ARM_PAGE_SIZE "16384")

add_library(native-lib SHARED native-lib.cpp)
find_library(log-lib log)
target_link_libraries(native-lib ${log-lib})

if (ANDROID)
    target_link_options(native-lib PRIVATE "-Wl,-z,max-page-size=16384")
endif()
