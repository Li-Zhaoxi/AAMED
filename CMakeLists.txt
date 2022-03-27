cmake_minimum_required(VERSION 3.17)
project(AAMED VERSION 1.0)
set(CMAKE_CXX_STANDARD 11)

find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})
link_libraries(${OpenCV_LIBS})

include_directories("src")
file(GLOB_RECURSE PROJECT_SOURCES "src/*.cpp")
list(REMOVE_ITEM PROJECT_SOURCES "src/main.cpp")


add_executable(AAMEDemo ${PROJECT_SOURCES} "src/main.cpp")
add_library(${PROJECT_NAME} ${PROJECT_SOURCES})

