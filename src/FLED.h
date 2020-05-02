#pragma once

#include <iostream>
#include <vector>
#include <bitset>
#include <algorithm>
#include <fstream>

#include "Node_FC.h"
#include "definition.h"
#include "LinkMatrix.h"
#include "EllipseConstraint.h"

#define dIDX(i,j) i*dCOLS+j
#define iIDX(i,j) i*iCOLS+j
#define OutOfRange(x,y) (x < 0 || y < 0 || x >= iROWS || y >= iCOLS)

#define MIN_DP_CONTOUR_NUM 3

#define VALIDATION_NUMBER 360

//#define MAX_COMBINATION_ARCS 8

//t1 = cv::getTickCount();
//t2 = (double)cv::getTickCount();
//sum_time += 1;// (t2 - t1) * 1000 / cv::getTickFrequency();



using cv::Mat;
using cv::Point;
using cv::Point2f;

using std::vector;
using std::string;
using std::cout;
using std::endl;


class FLED
{
public:
	FLED(int drows, int dcols);
	void SetParameters(double theta_fsa, double length_fsa, double T_val);
	vector<cv::RotatedRect> detEllipses;



	void SetParameters(double T_dp, double theta_fsa, double length_fsa, double T_val, int grad_num);
	void initFrame();
	void release();// release data;
	void run_FLED(Mat Img_G);
	void run_AAMED_WithoutCanny(Mat Img_G);
public:// Draw Data and Write Information Functions
	void drawEdgeContours();
	void drawDPContours();
	void drawFSA_ArcContours();
	void drawEllipses();
	void drawFLED(Mat ImgC, double use_time = -1);
	void drawFLED(Mat ImgG, string savepath);
	void writeFLED(string filepath, string filename, double useTime);
	void showDetailBreakdown(cv::Vec<double, 10> &detDetailTime, int needDisplay = 1);
	void showDatasetBreakdown();
	void writeDetailData();
public: 
	void calCannyThreshold(cv::Mat &ImgG, int &low, int &high); // Adaptive Canny thresholds


public: // The public functions that used for Python.
	int run_FLED(unsigned char* _img_G, int irows, int icols)
	{
		Mat Img_G(irows, icols, CV_8UC1, _img_G);
		run_FLED(Img_G);
		return detEllipses.size();
	}
	void UpdateResults(float* _data)
	{
		for (int i = 0; i < detEllipses.size(); i++)
		{
			_data[i * 6 + 0] = detEllipses[i].center.x;
			_data[i * 6 + 1] = detEllipses[i].center.y;
			_data[i * 6 + 2] = detEllipses[i].size.width;
			_data[i * 6 + 3] = detEllipses[i].size.height;
			_data[i * 6 + 4] = detEllipses[i].angle;
			_data[i * 6 + 5] = detEllipseScore[i];
		}
	}
	void drawAAMED(unsigned char* _img_G, int irows, int icols)
	{
		Mat img_G = Mat(irows, icols, CV_8UC1, _img_G).clone();
		cvtColor(img_G, img_G, cv::COLOR_GRAY2BGR);
		drawFLED(img_G, 0);
		cv::waitKey(0);
	}
	void drawAAMED(unsigned char* _img_G, int irows, int icols, cv::Vec3b *_outImg)
	{
		Mat img_G = Mat(irows, icols, CV_8UC1, _img_G).clone();
		Mat img_O = Mat(irows, icols, CV_8UC3, _outImg);
		cvtColor(img_G, img_G, cv::COLOR_GRAY2BGR);
		drawFLED(img_G, 0);
		cv::waitKey(0);
	}
protected:
	void findContours(uchar *_edge);
	void BoldEdge(uchar *_edge, const vector< vector<Point> > &edge_Contours);
	void FSA_Segment(vector<Point> &dpContour);


	void Arcs_Grouping(vector< vector<Point> > &fsaarcs);
	void CreateArcSearchRegion(vector< vector<Point> > &fsaarcs);

	vector< vector<Point> > edgeContours, dpContours, FSA_ArcContours;
	
	vector<double> detEllipseScore;

	vector<ArcSearchRegion> asrs;


	void SegmentAnArc(vector<Point> &AdpContour);
	vector< vector<Point> > StrongArcs;
	vector< vector<Point> > WeakArcs;
	void SortArcs(vector<vector<Point>> &detArcs);

private: //The list of parameters.
	double _T_dp; // Useless
	double _theta_fsa;
	double _length_fsa;
	double _T_val;
	double _T_gradnum; // Useless
	// The list of adaptive parameters
	double _T_edge_num; //Independent of image size
	double _T_min_minor; //Independent of image size

private:
	double sum_time;
	int fitnum;
	int case_stat[4];
	char isBIDIR;


	int dROWS, dCOLS, iROWS, iCOLS;
	// Part of Canny
	Mat imgCanny;
	// Part of FindContours
	void findContour(const int Wise[8][2], const int antiWise[8][2], uchar *Edge, int x, int y);

	void clockwiseContour(vector<Point> &antiContour);

	vector<Point> oneContour;
	vector<Point> oneContourOpp;

	Node_FC *data;
	// KD-Trees. KD is used for high speed
	void getArcs_KDTrees(vector< vector<Point> > & arcs);

	vector< float > query_arcs;
	Mat source_arcs, indices_arcs, dist_arcs;

	// Ellipse Fitting Varaies
	Mat dls_C, dls_D, dls_V, dls_D2, dls_V2, dls_X;
	void fitEllipse(double *data, double &error, cv::RotatedRect &res);
	void ElliFit(double *data, double &error, cv::RotatedRect &res);

	// The part of arc adjacency matrix (AAM)
	GroupPart<char> LinkMatrix;
	struct linkArc
	{
		int idx;
		vector<int> idx_linking;
		vector<int> idx_linked;
		vector<int> idx_notlink;
		void clear()
		{
			idx_linking.clear();
			idx_linked.clear();
			idx_notlink.clear();
		}
		int findNextLinking(int idx_start)
		{
			int linking_num = (int)idx_linking.size();
			return idx_start + 1 < linking_num ? idx_start + 1 : -1;
		}
		int findNextLinked(int idx_start)
		{
			int linked_num = (int)idx_linked.size();
			return idx_start + 1 < linked_num ? idx_start + 1 : -1;
		}
	};
	GroupPart<linkArc> lA;
	void getlinkArcs(const char *_linkMatrix, int arc_num);



	// Extracting the arc combinations according to the adjacency matrix 
	vector<int> temp;
	std::vector<unsigned char> _arc_grouped_label; // If the value of ith is 1, the ith arc has been combined in an arc combination
	cv::Vec<double, MAT_NUMBER> fitArcTemp;
	
	vector< vector<int> > search_group[2];
	vector < cv::Vec<double, MAT_NUMBER> > search_arcMats[2];
	void init_fitmat(double *basic_fitmat, double *init_fitmat, int num);
	void push_fitmat(double *basic_fitmat, double *add_fitmat, int num); 
	void pop_fitmat(double *basic_fitmat, double *minus_fitmat, int num);


	GroupPart<unsigned char> visited;// The ith value represent whether ith arc is visited or not.
	GroupPart<unsigned char> searched;

	vector< cv::Vec<double, MAT_NUMBER> > ArcFitMat;
	void GetArcMat(vector< cv::Vec<double, MAT_NUMBER> > &arcfitmat, vector< vector<Point> > &fsa_arc);

	GroupPart<SORTDATA> fitComb_LR; 
	typedef GroupPart<SORTDATA> GPSD;
	void sortCombine(GPSD &fitComb, vector < cv::Vec<double, MAT_NUMBER> > arcMats[2], vector< vector<int> > s_group[2]);
	
	// PAS, AAS, BCV
	void PosteriorArcsSearch(int point_idx); //Step: Search Linking
	void AnteriorArcsSearch(int point_idx);  //Step: Search Linked
	void BiDirectionVerification(GPSD &fitComb, vector < cv::Vec<double, MAT_NUMBER> > fitMats[2], vector< vector<int> > link_group[2], vector<unsigned char> &arc_grouped); //Step: Find Valid Combination

	void PosteriorArcsSearch2(int point_idx); //Step: Search Linking
	void AnteriorArcsSearch2(int point_idx);  //Step: Search Linked


	bool FittingConstraint(double *_linkingMat, double *_linkedMat, cv::RotatedRect &fitres);
	bool Validation(cv::RotatedRect &res, double *detScore);
	bool fastValidation(cv::RotatedRect &res, double *detScore);
	double vld_use_time;


	//Validation Data
	float vldBaseData[VALIDATION_NUMBER][2];
	//double vldBaseDataX[VALIDATION_NUMBER], vldBaseDataY[VALIDATION_NUMBER], sample_x[VALIDATION_NUMBER], sample_y[VALIDATION_NUMBER], grad_x[VALIDATION_NUMBER], grad_y[VALIDATION_NUMBER], sample_weight[VALIDATION_NUMBER];
	float vldBaseDataX[VALIDATION_NUMBER], vldBaseDataY[VALIDATION_NUMBER], sample_x[VALIDATION_NUMBER], sample_y[VALIDATION_NUMBER], grad_x[VALIDATION_NUMBER], grad_y[VALIDATION_NUMBER], sample_weight[VALIDATION_NUMBER];


	static void ClusterEllipses(std::vector<cv::RotatedRect> &detElps, vector<double> &detEllipseScore);


private:

	cv::flann::LinearIndexParams  indexParams;
	cv::flann::Index kdTree_Arcs;


protected:
	//the region constraint and curvature constraint are used to calculate Lij in four cases
	char Group4FAnB1_FBmA1(Point vecFet[8], const Point * const *l1, const Point * const *l2, const ArcSearchRegion * const asri, const ArcSearchRegion * const asrk) const
	{
		int linkval[2];



		if (!RegionConstraint(asri, asrk))
			return -1;
		if (!RegionConstraint(asrk, asri))
			return -1;
		return 1;

		//if (!CONSTRAINT_GLOBAL_REGION(vecFet, l1, l2[0]))
		//	return -1;
		//if (!CONSTRAINT_GLOBAL_REGION(vecFet, l1, l2[3]))
		//	return -1;
		vecFet[5].x = l2[3]->x - l2[2]->x; vecFet[5].y = l2[3]->y - l2[2]->y;
		vecFet[4].x = l2[1]->x - l2[0]->x; vecFet[4].y = l2[1]->y - l2[0]->y;

		linkval[0] = CONSTRAINT_GLOABL_CURVATURE(vecFet, 1);
		if (linkval[0] == -1)
			return -1;
		linkval[1] = CONSTRAINT_GLOABL_CURVATURE(vecFet, 2);
		if (linkval[1] == -1)
			return -1;
		if (linkval[0] == 1 || linkval[1] == 1)
			return 1;
		return 0;
	}
	char Group4FAnB1_FBmA1(Point vecFet[8], const Point * const *l1, const Point * const *l2) const 
	{
		int linkval[2];
		if (!CONSTRAINT_GLOBAL_REGION(vecFet, l1, l2[0]))
			return -1;
		if (!CONSTRAINT_GLOBAL_REGION(vecFet, l1, l2[3]))
			return -1;
		vecFet[5].x = l2[3]->x - l2[2]->x; vecFet[5].y = l2[3]->y - l2[2]->y;
		vecFet[4].x = l2[1]->x - l2[0]->x; vecFet[4].y = l2[1]->y - l2[0]->y;

		linkval[0] = CONSTRAINT_GLOABL_CURVATURE(vecFet, 1);
		if (linkval[0] == -1)
			return -1;
		linkval[1] = CONSTRAINT_GLOABL_CURVATURE(vecFet, 2);
		if (linkval[1] == -1)
			return -1;
		if (linkval[0] == 1 || linkval[1] == 1)
			return 1;
		return 0;
	}
	char Group4CAnB1_FBmA1(Point vecFet[8], const Point * const *l1, const Point * const *l2) const
	{
		Point l1_l2_O, vecl[2];
		l1_l2_O.x = (vecFet[3].x >> 1) + l1[3]->x; l1_l2_O.y = (vecFet[3].y >> 1) + l1[3]->y;
		vecl[0].x = l1_l2_O.x - l1[2]->x; vecl[0].y = l1_l2_O.y - l1[2]->y;
		vecl[1].x = l2[1]->x - l1_l2_O.x; vecl[1].y = l2[1]->y - l1_l2_O.y;
		if (!CONSTRAINT_NEIBOR_FSA(vecl))
			return -1;
		vecFet[5].x = l2[3]->x - l2[2]->x; vecFet[5].y = l2[3]->y - l2[2]->y;
		if (!CONSTRAINT_NEIBOR_TAIL(vecFet))
			return -1;
		
		return 1;
	}
	char Group4FAnB1_CBmA1(Point vecFet[8], const Point * const *l1, const Point * const *l2) const
	{
		if (!CONSTRAINT_GLOBAL_REGION(vecFet, l1, l2[0]))
			return -1;
		vecFet[5].x = l2[3]->x - l2[2]->x; vecFet[5].y = l2[3]->y - l2[2]->y;
		vecFet[4].x = l2[1]->x - l2[0]->x; vecFet[4].y = l2[1]->y - l2[0]->y;
		if (CONSTRAINT_GLOABL_CURVATURE(vecFet, 1) == -1)
			return -1;
		return 1;
	}
	char Group4CAnB1_CBmA1(Point vecFet[8], const Point * const *l1, const Point * const *l2) const
	{
		Point l1_l2_O, vecl[2];
		l1_l2_O.x = (vecFet[3].x >> 1) + l1[3]->x; l1_l2_O.y = (vecFet[3].y >> 1) + l1[3]->y;
		vecl[0].x = l1_l2_O.x - l1[2]->x; vecl[0].y = l1_l2_O.y - l1[2]->y;
		vecl[1].x = l2[1]->x - l1_l2_O.x; vecl[1].y = l2[1]->y - l1_l2_O.y;
		if (!CONSTRAINT_NEIBOR_FSA(vecl))// These two arcs do not satisfy the curvature contraint, i.e. Lij = -1;
			return -1;
		else
			return 1;
	}

	//Neighbor Grouping: FSA Constraint
	bool CONSTRAINT_NEIBOR_FSA(const Point ni[2]) const
	{
		const double Theta_fsa = _theta_fsa, Length_fsa = _length_fsa, Length_fsa_inv = 1 / _length_fsa;

		cv::Point2d FSA;
		double l_Ai_1Ai = ni[0].x*ni[0].x + ni[0].y*ni[0].y, tp[3];
		FSA.x = (ni[0].x*ni[1].x + ni[0].y*ni[1].y) / l_Ai_1Ai;
		FSA.y = (ni[1].x*ni[0].y - ni[1].y*ni[0].x) / l_Ai_1Ai;
		tp[0] = FSA.x - tan(CV_PI / 2 - Theta_fsa)*FSA.y;
		tp[1] = FSA.y / sin(Theta_fsa);
		tp[2] = FSA.x*FSA.x + FSA.y*FSA.y;
		if (tp[0] > 0 && tp[1] > 0 && tp[2] > Length_fsa_inv*Length_fsa_inv&&tp[2] < Length_fsa*Length_fsa)
			return true;
		else
			return false;
	}
	bool CONSTRAINT_NEIBOR_TAIL(const Point AB[8]) const
	{
		int res = AB[5].x*AB[7].y - AB[5].y*AB[7].x;
		if (res > 0)
			return false;
		res = AB[7].x*AB[0].y - AB[7].y*AB[0].x;
		if (res > 0)
			return false;
		return true;
	}
	bool CONSTRAINT_GLOBAL_REGION(const Point vecFet[8], const Point * const *l1, const Point *checkPoint) const 
	{
		Point checkVec;
		int checkVal;
		checkVec.x = checkPoint->x - l1[0]->x; checkVec.y = checkPoint->y - l1[0]->y;
		checkVal = -checkVec.x*vecFet[0].y + checkVec.y*vecFet[0].x;
		if (checkVal > 0)
			return false;
		checkVal = checkVec.x*vecFet[2].y - checkVec.y*vecFet[2].x;
		if (checkVal < 0)
			return false;
		checkVec.x = checkPoint->x - l1[3]->x; checkVec.y = checkPoint->y - l1[3]->y;
		checkVal = checkVec.x*vecFet[1].y - checkVec.y*vecFet[1].x;
		if (checkVal < 0)
			return false;
		return true;
	}
	int CONSTRAINT_GLOABL_CURVATURE(const Point vecFet[8], const int flag) const
	{
		int val[3];
		if (flag == 1)
		{
			val[1] = vecFet[1].x*vecFet[3].y - vecFet[1].y*vecFet[3].x;
			if (val[1] > 0)
				return -1;
			val[2] = vecFet[3].x*vecFet[4].y - vecFet[3].y*vecFet[4].x;
			if (val[2] > 0)
				return -1;
			val[0] = vecFet[1].x*vecFet[4].y - vecFet[1].y*vecFet[4].x;
			if (abs(val[0]) < 1e-8)
			{
				val[0] = vecFet[1].x*vecFet[4].x + vecFet[1].y*vecFet[4].y;
				if (val[0] > 0)
					return -1;
				else
					return 0;
			}
			else
			{
				if (val[0] < 0)
					return 1;
				else
				{
					if (val[0] + val[1] < 0 && val[0] + val[2] < 0)
						return 0;
					else
						return -1;
				}
			}
			return 0;
		}
		else
		{
			val[1] = vecFet[5].x*vecFet[7].y - vecFet[5].y*vecFet[7].x;
			if (val[1] > 0)
				return -1;
			val[2] = vecFet[7].x*vecFet[0].y - vecFet[7].y*vecFet[0].x;
			if (val[2] > 0)
				return -1;
			val[0] = vecFet[5].x*vecFet[0].y - vecFet[5].y*vecFet[0].x;
			if (abs(val[0]) < 1e-8)
			{
				val[0] = vecFet[5].x*vecFet[0].x + vecFet[5].y*vecFet[0].y;
				if (val[0] > 0)
					return -1;
				else
					return 0;
			}
			else
			{
				if (val[0] < 0)
					return 1;
				else
				{
					if (val[0] + val[1] < 0 && val[0] + val[2] < 0)
						return 0;
					else
						return -1;
				}
			}
			return 0;
		}
	}
	int CONSTRAINT_GLOABL_CURVATURE(const Point arc_n[3]) const
	{
		int val[3];
		val[1] = arc_n[0].x*arc_n[2].y - arc_n[0].y*arc_n[2].x;
		if (val[1] > 0)
			return -1;
		val[2] = arc_n[2].x*arc_n[1].y - arc_n[2].y*arc_n[1].x;
		if (val[2] > 0)
			return -1;
		val[0] = arc_n[0].x*arc_n[1].y - arc_n[0].y*arc_n[1].x;
		if (abs(val[0]) < 1e-8)
		{
			val[0] = arc_n[0].x*arc_n[1].x + arc_n[0].y*arc_n[1].y;
			if (val[0] > 0)
				return -1;
			else
				return 0;
		}
		else
		{
			if (val[0] < 0)
				return 1;
			else
			{
				if (val[0] + val[1] < 0 && val[0] + val[2] < 0)
					return 0;
				else
					return -1;
			}
		}
		return 0;
	}

	bool RegionConstraint(const ArcSearchRegion * const asri, const ArcSearchRegion * const asrk) const
	{
		if (!(asri->isInSearchRegion(&asrk->A_1)))
			return false;
		if (!(asrk->isInSearchRegion(&asri->A__1)))
			return false;
		return true;
	}
	bool FSAConstraint(const ArcSearchRegion * const asri, const ArcSearchRegion * const asrk) const
	{
		const double theta_fsa = _theta_fsa, length_fsa = _length_fsa, length_fsa_inv = 1 / _length_fsa;

		cv::Point2d vi, A0_ik, ni, n_i_1;
		double lni2, t, p, lvi;
		A0_ik.x = (asri->A__1.x + asrk->A_1.x) / 2.0, A0_ik.y = (asri->A__1.y + asrk->A_1.y) / 2.0;
		ni.x = A0_ik.x - asri->A__2.x, ni.y = A0_ik.y - asri->A__2.y;
		n_i_1.x = asrk->A_2.x - A0_ik.x, n_i_1.y = asrk->A_2.y - A0_ik.y;

		lni2 = ni.x*ni.x + ni.y*ni.y;
		vi.x = (ni.x*n_i_1.x + ni.y*n_i_1.y) / lni2;
		vi.y = -(ni.x*n_i_1.y - ni.y*n_i_1.x) / lni2;
		t = vi.x - tan(CV_PI / 2 - theta_fsa)*vi.y;
		p = vi.y / sin(theta_fsa);
		if (t <= 0 || p <= 0)
			return false;
		lvi = vi.x*vi.x + vi.y*vi.y;
		if (lvi <= length_fsa_inv*length_fsa_inv || lvi >= length_fsa*length_fsa)
			return false;
		return true;
	}
	// l_ik >= T_ik && l_ki >= T_ki
	char CASE_1(const ArcSearchRegion * const asri, const ArcSearchRegion * const asrk) const
	{
		if (!RegionConstraint(asri, asrk))
			return -1;
		if (!RegionConstraint(asrk, asri))
			return -1;
		return 1;
	}
	// l_ik >= T_ik && l_ki < T_ki
	char CASE_2(const ArcSearchRegion * const asri, const ArcSearchRegion * const asrk) const
	{
		if (!RegionConstraint(asri, asrk))
			return -1;
		return 1;
	}


#ifdef DETAIL_BREAKDOWN
	double t_preprocess, t_arcsegment, t_cluster, t_allgrouping, t_allfitting, t_allvalidation;
	int fitting_time, valitation_time;
	
	double ds_t_preprocess, ds_t_arcsegment, ds_t_cluster, ds_t_allgrouping, ds_t_allfitting, ds_t_allvalidation, dt_time;
	int ds_fitting_time, ds_valitation_time, ds_num;
#endif

};

typedef FLED AAMED;