#include "EllipseNonMaximumSuppression.h"
#include <numeric>


void EllipseNonMaximumSuppression(std::vector<cv::RotatedRect> &detElps, std::vector<double> &detEllipseScore, double T_iou)
{
	int elps_num = detElps.size();
	double *_overlaps = new double[elps_num * elps_num];



	// Calculate the IoUs of all ellipses
	for (int i = 0; i < elps_num - 1; i++)
	{
		_overlaps[i*elps_num + i] = 0;
		for (int j = i + 1; j < elps_num; j++)
		{
			_overlaps[j*elps_num + i] = _overlaps[i*elps_num + j] = EllipseOverlap(detElps[i], detElps[j]);
		}
	}

	//cv::Mat olp(elps_num, elps_num, CV_64FC1, _overlaps);
	//std::cout << olp << std::endl;
	// Get the sorted results.
	std::vector<int> sort_idx(elps_num);
	std::iota(sort_idx.begin(), sort_idx.end(), 0);
	sort(sort_idx.begin(), sort_idx.end(),
		[&detEllipseScore](int i1, int i2) {return detEllipseScore[i1] > detEllipseScore[i2]; });


	// NMS
	std::vector<unsigned char> isValid(elps_num, 1);
	std::vector<cv::RotatedRect> clusterELlipse;
	for (int i = 0; i < elps_num; i++)
	{
		int select_idx = sort_idx[i]; 
		if (isValid[select_idx] == 0) continue; 

		double* _sel_overlaps = _overlaps + select_idx*elps_num;
		for (int k = 0; k < elps_num; k++)
		{
			if (isValid[k] && _sel_overlaps[k] > T_iou)
				isValid[k] = 0;
		}
		clusterELlipse.push_back(detElps[select_idx]);
		isValid[select_idx] = 0;
	}
	detElps = clusterELlipse;
	delete[] _overlaps;
}





// convert shape parameters to general equation parameters
static void ELPShape2Equation(double *elpshape, double *outparms)
{
	double xc, yc, a, b, theta;
	xc = elpshape[0], yc = elpshape[1], a = elpshape[2], b = elpshape[3], theta = elpshape[4];

	double parm[6];

	double cos_theta = cos(theta), sin_theta = sin(theta), sin_2theta = sin(2 * theta);
	double pow_cos_theta = pow(cos_theta, 2), pow_sin_theta = pow(sin_theta, 2);
	double aa_inv = 1 / (a*a), bb_inv = 1 / (b*b);
	double tmp1, tmp2;

	parm[0] = pow_cos_theta*aa_inv + pow_sin_theta*bb_inv;
	parm[1] = -0.5 * sin_2theta*(bb_inv - aa_inv);
	parm[2] = pow_cos_theta*bb_inv + pow_sin_theta*aa_inv;
	parm[3] = (-xc*pow_sin_theta + yc*sin_2theta / 2)*bb_inv - (xc*pow_cos_theta + yc*sin_2theta / 2)*aa_inv;
	parm[4] = (-yc*pow_cos_theta + xc*sin_2theta / 2)*bb_inv - (yc*pow_sin_theta + xc*sin_2theta / 2)*aa_inv;
	tmp1 = (xc*cos_theta + yc*sin_theta) / a, tmp2 = (yc*cos_theta - xc*sin_theta) / b;
	parm[5] = pow(tmp1, 2) + pow(tmp2, 2) - 1;


	//parm[0] = pow(cos(theta) / a, 2) + pow(sin(theta) / b, 2);
	//parm[1] = -(sin(2 * theta) / 2)*(pow(b, -2) - pow(a, -2));
	//parm[2] = pow(cos(theta) / b, 2) + pow(sin(theta) / a, 2);
	//parm[3] = (-xc*pow(sin(theta), 2) + yc*sin(2 * theta) / 2) / (b*b) - (xc*pow(cos(theta), 2) + yc*sin(2 * theta) / 2) / (a*a);
	//parm[4] = (-yc*pow(cos(theta), 2) + xc*sin(2 * theta) / 2) / (b*b) - (yc*pow(sin(theta), 2) + xc*sin(2 * theta) / 2) / (a*a);
	//parm[5] = pow((xc*cos(theta) + yc*sin(theta)) / a, 2) + pow((yc*cos(theta) - xc*sin(theta)) / b, 2) - 1;

	double k = parm[0] * parm[2] - parm[1] * parm[1];
	k = 1 / sqrt(abs(k));

	for (int i = 0; i < 6; i++)
		outparms[i] = parm[i] * k;

}


static bool CalculateRangeAtY(double *elpparm, double y, double *x1, double *x2)
{
	double A, B, C, D, E, F, t1, t2, Delta;
	A = elpparm[0], B = elpparm[1], C = elpparm[2];
	D = elpparm[3], E = elpparm[4], F = elpparm[5];

	Delta = pow(B*y + D, 2) - A*(C*y*y + 2 * E*y + F);
	*x1 = -10, *x2 = -20;
	if (Delta < 0)
		return false;
	else
	{
		t1 = (-(B*y + D) - sqrt(Delta)) / A;
		t2 = (-(B*y + D) + sqrt(Delta)) / A;

		if (t2 < t1)
			std::swap(t1, t2);

		*x1 = t1;
		*x2 = t2;

		return true;
	}
}



static void CalculateRangeOfY(double *elp_equ, double *x_min, double *x_max, double *y_min, double *y_max)
{

	double B, C;
	B = elp_equ[1] * elp_equ[3] - elp_equ[0] * elp_equ[4];
	C = elp_equ[3] * elp_equ[3] - elp_equ[0] * elp_equ[5];

	double tx_min, tx_max, ty_min, ty_max;

	ty_min = B - sqrt(B*B + C);
	ty_max = B + sqrt(B*B + C);

	tx_min = -(elp_equ[1] * ty_min + elp_equ[3]) / elp_equ[0];
	tx_max = -(elp_equ[1] * ty_max + elp_equ[3]) / elp_equ[0];

	*x_min = tx_min;
	*x_max = tx_max;
	*y_min = ty_min;
	*y_max = ty_max;
}




double EllipseOverlap(cv::RotatedRect &ellipse1, cv::RotatedRect &ellipse2)
{
	double t1, t2;


	double elp1[5], elp2[5];
	elp1[0] = ellipse1.center.x, elp1[1] = ellipse1.center.y;
	elp1[2] = ellipse1.size.width / 2, elp1[3] = ellipse1.size.height / 2;
	elp1[4] = ellipse1.angle / 180 * CV_PI;

	elp2[0] = ellipse2.center.x, elp2[1] = ellipse2.center.y;
	elp2[2] = ellipse2.size.width / 2, elp2[3] = ellipse2.size.height / 2;
	elp2[4] = ellipse2.angle / 180 * CV_PI;

	//t1 = cv::getTickCount();
	double parm1[6], parm2[6];
	ELPShape2Equation(elp1, parm1);
	ELPShape2Equation(elp2, parm2);
	//t2 = cv::getTickCount();
	double y1_min, y1_max, y2_min, y2_max, y_min, y_max, ytmp;
	CalculateRangeOfY(parm1, &ytmp, &ytmp, &y1_min, &y1_max);
	CalculateRangeOfY(parm2, &ytmp, &ytmp, &y2_min, &y2_max);

	y_min = floor(fmax(y1_min, y2_min));
	y_max = ceil(fmin(y1_max, y2_max));

	double ration;

	if (y_min >= y_max)
	{
		ration = 0;
		return ration;
	}

	double max_iter = 150, min_step = 0.2, iter_step = (y_max - y_min) / (max_iter + 2);
	double search_step = fmax(min_step, iter_step);

	double S12 = 0, x11, x12, x21, x22, x_min, x_max;

	//cout << "sub Use time (ms): " << (t2 - t1) * 1000 / cv::getTickFrequency() << endl;
	for (double i = y_min; i <= y_max + 1e-6; i = i + search_step)
	{
		CalculateRangeAtY(parm1, i, &x11, &x12);
		CalculateRangeAtY(parm2, i, &x21, &x22);

		x_min = fmax(x11, x21), x_max = fmin(x12, x22);
		if (x_min < x_max)
			S12 += x_max - x_min;

	}

	ration = S12 *search_step / (CV_PI*elp1[2] * elp1[3] + CV_PI*elp2[2] * elp2[3] - S12*search_step);
	return ration;
}