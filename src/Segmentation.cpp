#include "FLED.h"
#include <numeric>


void FLED::FSA_Segment(vector<Point> &dpContour)
{
	
	const double Theta_fsa = _theta_fsa, Length_fsa = _length_fsa, Length_fsa_inv = 1 / _length_fsa;

	
	cv::Vec4i temp_line;
	Point Ai[3], ni[2];
	cv::Point2f FSA;
	float tp[3], l_Ai_1Ai;
	int dir;
	const int dpContourNum = dpContour.size();
	const double Length_fsa2 = Length_fsa*Length_fsa, Length_fsa_inv2 = Length_fsa_inv*Length_fsa_inv;

	for (int i = 1; i < dpContourNum; i++)
	{
		oneContour.clear();
		Ai[0] = dpContour[i - 1]; Ai[1] = dpContour[i];
		ni[0] = Ai[1] - Ai[0];
		l_Ai_1Ai = ni[0].x*ni[0].x + ni[0].y*ni[0].y;
		if (l_Ai_1Ai < 5)
			continue;
		if (i + 1 >= dpContour.size())
		{
			continue;
		}
		Ai[2] = dpContour[i + 1];
		ni[1] = Ai[2] - Ai[1];
		dir = ni[0].x*ni[1].y - ni[0].y*ni[1].x;
		FSA.x = (ni[0].x*ni[1].x + ni[0].y*ni[1].y) / l_Ai_1Ai; FSA.y = abs(dir) / l_Ai_1Ai;
		tp[0] = FSA.x - tan(CV_PI / 2 - Theta_fsa)*FSA.y;
		tp[1] = FSA.y / sin(Theta_fsa);
		tp[2] = FSA.x*FSA.x + FSA.y*FSA.y;
		if (tp[0] <= 0 || tp[1] <= 0 || tp[2]<Length_fsa_inv2 || tp[2]>Length_fsa2)
		{
			continue;
		}
		dir = dir > 0 ? 1 : -1;
		i++;
		oneContour.push_back(Ai[0]), oneContour.push_back(Ai[1]), oneContour.push_back(Ai[2]);
		for (int j = i + 1; j < dpContour.size(); j++, i = j - 1)
		{
			ni[0] = ni[1];
			l_Ai_1Ai = ni[0].x*ni[0].x + ni[0].y*ni[0].y;
			ni[1] = dpContour[j] - dpContour[j - 1];
			FSA.x = (ni[0].x*ni[1].x + ni[0].y*ni[1].y) / l_Ai_1Ai;
			FSA.y = dir*(ni[0].x*ni[1].y - ni[0].y*ni[1].x) / l_Ai_1Ai;
			tp[0] = FSA.x - tan(CV_PI / 2 - Theta_fsa)*FSA.y;
			tp[1] = FSA.y / sin(Theta_fsa);
			tp[2] = FSA.x*FSA.x + FSA.y*FSA.y;
			if (tp[0] > 0 && tp[1] > 0 && tp[2] > Length_fsa_inv2 &&tp[2] < Length_fsa2)
			{
				oneContour.push_back(dpContour[j]);
				continue;
			}
			else
				break;
		}
		if (oneContour.size() < MIN_DP_CONTOUR_NUM)
			continue;
		if (dir > 0)
			clockwiseContour(oneContour);

		Point st, ed;
		st = oneContour[0], ed = oneContour.back();
		int arc_edge_num = data[dIDX(ed.x, ed.y)].edgeID - data[dIDX(st.x, st.y)].edgeID;
		if (arc_edge_num < _T_edge_num/2*oneContour.size())
			continue;
		FSA_ArcContours.push_back(oneContour);
	}
}




void FLED::SegmentAnArc(vector<Point> &dpContour)
{
	const double Theta_fsa = _theta_fsa, Length_fsa = _length_fsa, Length_fsa_inv = 1 / _length_fsa;
	const int StrongPointNum = 4;

	cv::Vec4i temp_line;
	Point Ai[3], ni[2];
	cv::Point2f FSA;
	float tp[3], l_Ai_1Ai;
	int dir;
	const int dpContourNum = dpContour.size();
	const double Length_fsa2 = Length_fsa*Length_fsa, Length_fsa_inv2 = Length_fsa_inv*Length_fsa_inv;

	
	vector< vector<Point> > tmpAllSegmentArcs;
	vector<int> tmpArcsDir;
	for (int i = 1; i < dpContourNum; i++)
	{
		oneContour.clear();
		Ai[0] = dpContour[i - 1]; Ai[1] = dpContour[i];
		oneContour.push_back(Ai[0]), oneContour.push_back(Ai[1]);

		ni[0] = Ai[1] - Ai[0];
		l_Ai_1Ai = ni[0].x*ni[0].x + ni[0].y*ni[0].y;
		if (i + 1 >= dpContour.size())
		{
			tmpAllSegmentArcs.push_back(oneContour), tmpArcsDir.push_back(0);
			continue;
		}

		Ai[2] = dpContour[i + 1];
		ni[1] = Ai[2] - Ai[1];
		dir = ni[0].x*ni[1].y - ni[0].y*ni[1].x;
		FSA.x = (ni[0].x*ni[1].x + ni[0].y*ni[1].y) / l_Ai_1Ai; FSA.y = abs(dir) / l_Ai_1Ai;
		tp[0] = FSA.x - tan(CV_PI / 2 - Theta_fsa)*FSA.y;
		tp[1] = FSA.y / sin(Theta_fsa);
		tp[2] = FSA.x*FSA.x + FSA.y*FSA.y;

		if (tp[0] <= 0 || tp[1] <= 0 || tp[2]<Length_fsa_inv2 || tp[2]>Length_fsa2) 
		{
			tmpAllSegmentArcs.push_back(oneContour), tmpArcsDir.push_back(0);
			continue;
		}

		dir = dir > 0 ? 1 : -1;
		i++;
		oneContour.push_back(Ai[2]);
		for (int j = i + 1; j < dpContour.size(); j++, i = j - 1)
		{
			ni[0] = ni[1];
			l_Ai_1Ai = ni[0].x*ni[0].x + ni[0].y*ni[0].y;
			ni[1] = dpContour[j] - dpContour[j - 1];
			FSA.x = (ni[0].x*ni[1].x + ni[0].y*ni[1].y) / l_Ai_1Ai;
			FSA.y = dir*(ni[0].x*ni[1].y - ni[0].y*ni[1].x) / l_Ai_1Ai;
			tp[0] = FSA.x - tan(CV_PI / 2 - Theta_fsa)*FSA.y;
			tp[1] = FSA.y / sin(Theta_fsa);
			tp[2] = FSA.x*FSA.x + FSA.y*FSA.y;
			if (tp[0] > 0 && tp[1] > 0 && tp[2] > Length_fsa_inv2 &&tp[2] < Length_fsa2)
			{
				oneContour.push_back(dpContour[j]);
				continue;
			}
			else
				break;
		}
		tmpAllSegmentArcs.push_back(oneContour), tmpArcsDir.push_back(dir);
	}





}





void FLED::SortArcs(vector<vector<Point>> &detArcs)
{
	int arc_num = detArcs.size();
	vector<int> arcs_edge_num(arc_num);
	Point st, ed;
	for (int i = 0; i < arc_num; i++)
	{
		st = detArcs[i][0];
		ed = detArcs[i].back();
		arcs_edge_num[i] = data[dIDX(ed.x, ed.y)].edgeID - data[dIDX(st.x, st.y)].edgeID;
	}


	Node_FC *_tmpdata = data;
	int tmpdCols = dCOLS;
	sort(detArcs.begin(), detArcs.end(),
		[&_tmpdata, &tmpdCols](vector<Point> &a1, vector<Point> &a2) 
	{
		Point st, ed;
		st = a1[0], ed = a1.back();
		int arc1_edge_num = _tmpdata[ed.x*tmpdCols+ed.y].edgeID - _tmpdata[st.x*tmpdCols + st.y].edgeID;

		st = a2[0], ed = a2.back();
		int arc2_edge_num = _tmpdata[ed.x*tmpdCols + ed.y].edgeID - _tmpdata[st.x*tmpdCols + st.y].edgeID;

		return arc1_edge_num > arc2_edge_num;
	}
	);

	//for (int i = 0; i < arc_num; i++)
	//{
	//	if(arcs_edge_num[i] < _T_edge_num)
	//		detArcs[i].clear();
	//}

}

