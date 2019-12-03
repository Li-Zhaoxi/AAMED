#pragma once

#include <opencv2/opencv.hpp>

#define PIXEL_SCALE 100 //数据尺寸，用于提高数值精度

#define MAT_NUMBER 15   //一个6*6矩阵可以用15个参数表示


class Node_FC
{
public:
	Node_FC();
	Node_FC(int x, int y, int scale);
	cv::Point Location;
	Node_FC *nextAddress;// the address of the next point
	Node_FC *lastAddress;// the address of the last point
	int edgeID;
	double nodeMat[MAT_NUMBER];
	double nodesMat[MAT_NUMBER];// The sum of the nodeMat

public://Some Linking Functions
	inline void nextIs(Node_FC *next_dot)// Link to the next point
	{
		if (next_dot != NULL)
		{
			nextAddress = next_dot;
			next_dot->lastAddress = this;
			next_dot->edgeID = this->edgeID + 1;
			for (int k = 0; k < MAT_NUMBER; k++)
			{
				next_dot->nodesMat[k] = nodesMat[k] + next_dot->nodeMat[k];
			}
		}
		else
		{
			nextAddress = NULL;
		}
	}
	inline void lastIs(Node_FC *last_dot)// Link to the last point
	{
		if (last_dot != NULL)
		{
			lastAddress = last_dot;
			last_dot->nextAddress = this;
			last_dot->edgeID = this->edgeID - 1;
			for (int k = 0; k < MAT_NUMBER; k++)
			{
				last_dot->nodesMat[k] = this->nodesMat[k] - last_dot->nodeMat[k];
			}
		}
		else
		{
			lastAddress = NULL;
		}
	}
	inline void negMatrix()
	{
		for (int i = 0; i < MAT_NUMBER; i++)
		{
			nodesMat[i] *= -1;
		}
	}
	inline void setFirst()
	{
		lastAddress = NULL;
		nextAddress = NULL;
		edgeID = 1;
		for (int k = 0; k < MAT_NUMBER; k++)
			nodesMat[k] = nodeMat[k];
	}
	inline void swapLink()
	{
		Node_FC *temp = lastAddress;
		lastAddress = nextAddress;
		nextAddress = temp;
	}

};


