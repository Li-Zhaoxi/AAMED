#pragma once

#include <vector>
#include <opencv2/opencv.hpp>

void adaptApproximateContours(const std::vector<cv::Point> &pts, std::vector<cv::Point> &approx);
void adaptApproxPolyDP(std::vector<cv::Point> &pts, std::vector<cv::Point> &approx); // 结果一样，更快
