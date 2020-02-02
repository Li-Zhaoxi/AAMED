#include "adaptApproximateContours.h"

using namespace std;
using namespace cv;

inline static double getDeviation(Point pt1, Point pt2, Point pt)
{
	double tmp1, tmp2;

	//Point n1(pt2 - pt), n2(pt2 - pt1);

	//tmp1 = double(n1.x*n2.y - n1.y*n2.x);
	tmp1 = double(pt1.x * pt2.y + pt2.x * pt.y + pt.x * pt1.y - pt2.x * pt1.y - pt.x * pt2.y - pt1.x * pt.y);

	tmp1 = fabs(tmp1);

	tmp2 = pow(pt1.x - pt2.x, 2) + pow(pt1.y - pt2.y, 2);
	tmp2 = sqrt(tmp2);

	return tmp1 / tmp2;
}



double static Get_del_phi_max(double s, double phi)
{
	const double cos_phi = cos(phi), sin_phi = sin(phi);
	const int num_del_phi = 8;
	
	double A, B, del_phi, lst_del_phi[num_del_phi];
	for (int n = 1; n <= 8; n++)
	{
		switch (n)
		{
		case 1:
		{
			A = fabs(sin_phi + cos_phi);
			B = cos_phi + sin_phi;
			break;
		}
		case 2:
		{
			A = fabs(sin_phi - cos_phi);
			B = cos_phi + sin_phi;
			break;
		}
		case 3:
		{
			A = fabs(sin_phi + cos_phi);
			B = -cos_phi + sin(phi);
			break;
		}
		case 4:
		{
			A = fabs(sin_phi - cos_phi);
			B = -cos_phi + sin(phi);
			break;
		}
		case 5:
		{
			A = fabs(sin_phi + cos_phi);
			B = cos_phi - sin(phi);
			break;
		}
		case 6:
		{
			A = fabs(sin_phi - cos_phi);
			B = cos_phi - sin(phi);
			break;
		}
		case 7:
		{
			A = fabs(sin_phi + cos_phi);
			B = -cos_phi - sin(phi);
			break;
		}
		case 8:
		{
			A = fabs(sin_phi - cos_phi);
			B = -cos_phi - sin(phi);
			break;
		}
		default:
			break;
		}

		del_phi = A * (pow(s, 2) - s * B + pow(B, 2)) / pow(s, 3);
		lst_del_phi[n - 1] = del_phi;
	}

	double max_lst = lst_del_phi[0];
	for (int i = 1; i < num_del_phi; i++)
	{
		if (lst_del_phi[i] > max_lst)
			max_lst = lst_del_phi[i];
	}

	return max_lst*s;
}



void static LRDP_Max(const vector<Point> &pts, int P1, int Pn, vector<int> &DominantPointsIdx)
{
	double dMax(0), d(0), dTol(0), phi(0), s(0), m(0);
	const double eps = 1e-8;
	int pMax(0);


	for (int idx = P1; idx <= Pn - 1; idx++)
	{
		d = getDeviation(pts[P1], pts[Pn], pts[idx]);
		if (d >= dMax)
			dMax = d, pMax = idx;
	}

	s = sqrt(pow(pts[Pn].x - pts[P1].x, 2) + pow(pts[Pn].y - pts[P1].y, 2));
	m = double(pts[Pn].x - pts[P1].x) / double(pts[Pn].y - pts[P1].y);
	if (fabs(pts[Pn].y - pts[P1].y) < eps || fabs(pts[Pn].x - pts[P1].x) < eps)
		dTol = 1;
	else
	{
		phi = atan(m);
		//phi = pow(tan(m), -1);
		dTol = Get_del_phi_max(s, phi);
	}

	//recursive selection of dominant points
	if (dMax > dTol && pMax != 0)
	{
		DominantPointsIdx.push_back(pMax);
		LRDP_Max(pts, P1, pMax, DominantPointsIdx);
		LRDP_Max(pts, pMax, Pn, DominantPointsIdx);
	}
}


void adaptApproximateContours(const std::vector<cv::Point> &pts, std::vector<cv::Point> &DominantPoints)
{
	DominantPoints.clear();
	int P1 = 0, Pn = pts.size() - 1;

	vector<int> DominantPointsIdx;

	if (pts.size() < 3)
	{
		DominantPoints = pts;
		return;
	}

	DominantPointsIdx.push_back(P1);
	DominantPointsIdx.push_back(Pn);
	while (pts[P1] == pts[Pn])
		Pn -= 1;

	LRDP_Max(pts, P1, Pn, DominantPointsIdx);

	//deduplicate and sort Dominant Points indices
	DominantPointsIdx.erase(unique(DominantPointsIdx.begin(), DominantPointsIdx.end()), DominantPointsIdx.end());

	sort(DominantPointsIdx.begin(), DominantPointsIdx.end(), less<int>());//Éý

	//generate list of dominant points
	int count = 1;
	int lastindex = 0;
	for (int i = 0; i < DominantPointsIdx.size(); i++)
		DominantPoints.push_back(pts[DominantPointsIdx[i]]);

}