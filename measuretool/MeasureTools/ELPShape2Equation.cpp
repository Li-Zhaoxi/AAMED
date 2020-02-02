#include "MeasureTools.h"


#include <iostream>

using namespace std;

void ELPShape2Equation(double *elpshape, double *outparms)
{
	double xc, yc, a, b, theta;
	xc = elpshape[0], yc = elpshape[1], a = elpshape[2], b = elpshape[3], theta = elpshape[4];

	double parm[6];

	parm[0] = cos(theta)*cos(theta) / (a*a) + pow(sin(theta), 2) / (b*b);
	parm[1] = -(sin(2 * theta)*(a*a - b*b)) / (2 * a*a*b*b);
	parm[2] = pow(cos(theta), 2) / (b*b) + pow(sin(theta), 2) / (a*a);
	parm[3] = (-a*a*xc*pow(sin(theta), 2) + a*a*yc*sin(2 * theta) / 2) / (a*a*b*b) - (xc*pow(cos(theta), 2) + yc*sin(2 * theta) / 2) / (a*a);
	parm[4] = (-a*a*yc*pow(cos(theta), 2) + a*a*xc*sin(2 * theta) / 2) / (a*a*b*b) - (yc*pow(sin(theta), 2) + xc*sin(2 * theta) / 2) / (a*a);
	parm[5] = pow(xc*cos(theta) + yc*sin(theta), 2) / (a*a) + pow(yc*cos(theta) - xc*sin(theta), 2) / (b*b) - 1;

	double k = parm[0] * parm[2] - parm[1] * parm[1];


	for (int i = 0; i < 6; i++)
		outparms[i] = parm[i] / sqrt(abs(k));



}