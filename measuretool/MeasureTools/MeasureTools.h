#pragma once
#include <vector>


//椭圆形状参数转换为一般方程参数
void ELPShape2Equation(double *elpshape, double *outparms);

// 计算椭圆一般方程当y值已知时，计算出的两个交点，如果不存在则为空集
void CalculateRangeAtY(double *elpparm, double y, double *x1, double *x2);



// 计算椭圆的重合度
void CalculateOverlap(double *elp1, double *elp2, double *ration, std::vector<double> *overlapdot);

// 给定一个椭圆，计算其y的取值范围
void CalculateRangeOfY(double *elpshape, double *x_min, double *x_max, double *y_min, double *y_max);

// 更快速的计算椭圆overlap的一种方法
void fasterCalculateOverlap(double *elp1, double *elp2, double *ration, std::vector<double> *overlapdot);