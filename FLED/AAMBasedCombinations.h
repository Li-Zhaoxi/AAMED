#pragma once

#include <iostream>
#include <vector>
#include <opencv2\opencv.hpp>

class AAMBasedCombinations
{
public:
	AAMBasedCombinations()
	{
		_AAM = NULL;
		_AAM_rows = 0;

		PostArcsCombs.reserve(50);
		AntArcsCombs.reserve(50);
		ArcFitMat.reserve(200);

	}
	//¿½±´Arcs Adjacency Matrix
	void AAMClone(char *src, int rows)
	{
		if (_AAM != NULL)
			delete[] _AAM;
		_AAM = new char[rows*rows];
		_AAM_rows = rows;
		memcpy(_AAM, src, rows*rows * sizeof(char));
	}

	void PosteriorArcsSearch(int rootidx);



	std::vector<int> PostArcsCombs; // Save the Posterior Arcs searched candidate combinations
	std::vector<int> AntArcsCombs;  // Save the anterior arcs searched candidate combinations
	std::vector< cv::Vec<double, 15> > ArcFitMat;

protected:
	
private:
	char *_AAM;
	int _AAM_rows;
	std::vector<int> TempArcsComb;
};