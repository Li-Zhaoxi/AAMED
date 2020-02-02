clc;clear;close all;
mex mexElliFit.cpp -I'D:\opencv3.1\opencv\build\include' -L'D:\opencv3.1\opencv\build\x64\vc14\lib' -lopencv_world310
mex mexFitCircle.cpp -I'D:\opencv3.1\opencv\build\include' -L'D:\opencv3.1\opencv\build\x64\vc14\lib' -lopencv_world310