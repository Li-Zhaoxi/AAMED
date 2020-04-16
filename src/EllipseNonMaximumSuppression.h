#pragma once

#include <vector>
#include <opencv2/opencv.hpp>



// RotatedRect: 中心点，长短轴，旋转角(角度)
double EllipseOverlap(cv::RotatedRect &ellipse1, cv::RotatedRect &ellipse2);


void EllipseNonMaximumSuppression(std::vector<cv::RotatedRect> &detElps, std::vector<double> &detEllipseScore, double T_iou);
