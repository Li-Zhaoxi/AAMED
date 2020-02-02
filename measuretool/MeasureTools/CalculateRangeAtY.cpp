#include "MeasureTools.h"

#include <iostream>

using namespace std;

void CalculateRangeAtY(double *elpparm, double y, double *x1, double *x2)
{
	double A, B, C, D, E, F;
	A = elpparm[0], B = elpparm[1], C = elpparm[2];
	D = elpparm[3], E = elpparm[4], F = elpparm[5];

	double Delta = pow(B*y + D, 2) - A*(C*y*y + 2 * E*y + F);

	if (Delta < 0)
		*x1 = -10, *x2 = -20;
	else
	{
        double t1, t2;
		t1 = (-(B*y + D) - sqrt(Delta)) / A;
		t2 = (-(B*y + D) + sqrt(Delta)) / A;
		
		if (t2 < t1)
			swap(t1, t2);
        
        *x1 = t1;
        *x2 = t2;
	}



}