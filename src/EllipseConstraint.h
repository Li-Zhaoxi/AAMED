#pragma once

#include <opencv2/opencv.hpp>

// 给定4个点可以确定一个搜索区间，
class ArcSearchRegion
{
public:
	//创建搜索区间
	void create(cv::Point *l1, cv::Point *l2, cv::Point *l3, cv::Point *l4)
	{
		A_1 = *l1, A_2 = *l2, A__2 = *l3, A__1 = *l4;
		l_12 = A_1 - A_2, l__11 = A__1 - A_1, l_1_2 = A__1 - A__2;
	}
	bool isInSearchRegion(const cv::Point *dst_point) const
	{
		cv::Point l_t;

		l_t.x = dst_point->x - A_1.x, l_t.y = dst_point->y - A_1.y;
		if (l_12.x*l_t.y - l_12.y*l_t.x < 0)
			return false;
		if (l_t.x*l__11.y - l_t.y*l__11.x < 0)
			return false;

		l_t.x = dst_point->x - A__1.x, l_t.y = dst_point->y - A__1.y;
		if (l_t.x*l_1_2.y - l_t.y*l_1_2.x < 0)
			return false;
		return true;
	}
	bool isInSearchRegion(ArcSearchRegion *dst_asr) const 
	{
		if (!isInSearchRegion(&dst_asr->A_1))
			return false;
		if (!isInSearchRegion(&dst_asr->A__1))
			return false;
		return true;
	}

	// return the length of (A_1 - A_2), the distance is L-1 norm.
	int length_l_12_L1()        
	{
		return abs(l_12.x) + abs(l_12.y);
	}

	// return the length of (A_{-1} - A_1), the distance is L-1 norm.
	int length_l__11_L1()
	{
		return abs(l__11.x) + abs(l__11.y);
	}

	// return the length of (A_{-1} - A_{-2}), the distance is L-1 norm.
	int length_l_1_2_L1()
	{
		return abs(l_1_2.x) + abs(l_1_2.y);
	}
public:
	cv::Point A_1;    // A_1 
	cv::Point A_2;    // A_2
	cv::Point A__2;   // A_{-2}
	cv::Point A__1;   // A_{-1}

	cv::Point l_12;   // A_1 - A_2 
	cv::Point l__11;  // A_{-1} - A_1
	cv::Point l_1_2;  // A_{-1} - A_{-2}
};
