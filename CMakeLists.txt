cmake_minimum_required(VERSION 2.8)

project(AAMED)


set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_CXX_FLAGS "-std=c++11 -O3")




include_directories("src")

find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

add_executable(${PROJECT_NAME} "src/main.cpp"
                               "src/adaptApproximateContours.cpp"
                               "src/adaptApproxPolyDP.cpp"
                               "src/Contours.cpp"
                               "src/EllipseNonMaximumSuppression.cpp"
                               "src/FLED.cpp"
                               "src/FLED_drawAndWriteFunctions.cpp"
                               "src/FLED_PrivateFunctions.cpp"
                               "src/Group.cpp"
                               "src/LinkMatrix.cpp"
                               "src/Node_FC.cpp"
                               "src/Segmentation.cpp"
                               "src/Validation.cpp"
                               "src/FLED_Initialization.cpp")

target_link_libraries(${PROJECT_NAME} ${OpenCV_LIBS})
