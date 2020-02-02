#include "adaptApproximateContours.h"

using namespace std;
using namespace cv;


static inline double Get_del_phi_max(double s, double phi)
{
	const int num_del_phi = 8;
	const double cos_phi = cos(phi), sin_phi = sin(phi);
	const double s_pow_2 = pow(s, 2), s_pow_3 = pow(s, 3);
	

	double A[num_del_phi], B[num_del_phi];
	double lst_del_phi[num_del_phi], del_phi, max_del_phi(-1);
	
	A[0] = fabs(sin_phi + cos_phi), A[1] = fabs(sin_phi - cos_phi);
	A[2] = A[4] = A[6] = A[0], A[3] = A[5] = A[7] = A[1];

	B[0] = B[1] = cos_phi + sin_phi;
	B[2] = B[3] = -cos_phi + sin_phi;
	B[4] = B[5] = cos_phi - sin_phi;
	B[6] = B[7] = -cos_phi - sin_phi;

	for (int n = 0; n < num_del_phi; n++)
	{
		del_phi = A[n] * (s_pow_2 - s * B[n] + pow(B[n], 2));
		//del_phi = A[n] * (s_pow_2 + B[n] * (B[n] - s));
		//del_phi = A[n] * (pow(B[n] - s, 2) - s * B[n]);
		if (del_phi > max_del_phi)
			max_del_phi = del_phi;
	}

	return max_del_phi / s_pow_2;
}


static bool getValidpMax(vector<Point> &pts, int P1, int Pn, int &pMax)
{
	pMax = 0;

	Point* _data = pts.data();
	Point n1, n2;
	int d, dMax(-1);
	double phi, s, dTol;
	// Get Max Deviation and index: dMax, pMax
	n1.x = _data[Pn].x - _data[P1].x, n1.y = _data[Pn].y - _data[P1].y;
	

	for (int idx = P1; idx < Pn; idx++)
	{
		n2.x = _data[idx].x - _data[P1].x;
		n2.y = _data[idx].y - _data[P1].y;
		d = abs(n1.x*n2.y - n1.y*n2.x);

		if (d >= dMax)
			dMax = d, pMax = idx;
	}
	if (pMax == 0)
		return false;


	s = sqrt(double(n1.x*n1.x + n1.y*n1.y));
	if (n1.x == 0 || n1.y == 0)
		dTol = 1;
	else
	{
		phi = atan(double(n1.x) / double(n1.y));
		dTol = Get_del_phi_max(s, phi);
	}

	if (dMax > dTol*s && pMax != 0)
		return true;
	else
		return false;
}


static void LRDP_Max(vector<Point> &pts, int P1, int Pn, vector<int> &DominantPointsIdx)
{
	double dMax(0), d(0), dTol(0), phi(0), s(0), m(0);
	const double eps = 1e-8;
	int pMax(0);


	bool isValid = getValidpMax(pts, P1, Pn, pMax);
	if (isValid)
	{
		DominantPointsIdx.push_back(pMax);
		LRDP_Max(pts, P1, pMax, DominantPointsIdx);
		LRDP_Max(pts, pMax, Pn, DominantPointsIdx);
	}
}


void adaptApproxPolyDP(std::vector<cv::Point> &pts, std::vector<cv::Point> &DominantPoints)
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
	for (int i = 0; i < DominantPointsIdx.size(); i++)
		DominantPoints.push_back(pts[DominantPointsIdx[i]]);

}