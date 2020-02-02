#include "MeasureTools.h"
#include "mex.h"

#include <iostream>
#include <vector>
using namespace std;

#define PI 3.14159265358979

void fasterCalculateOverlap(double *elp1, double *elp2, double *ration, vector<double> *overlapdot)
{
	double parm1[6], parm2[6];
	ELPShape2Equation(elp1, parm1);
	ELPShape2Equation(elp2, parm2);
	
	double y1_min, y1_max, y2_min, y2_max, y_min, y_max, ytmp;
    CalculateRangeOfY(elp1, &ytmp, &ytmp, &y1_min, &y1_max);
    CalculateRangeOfY(elp2, &ytmp, &ytmp, &y2_min, &y2_max);
    
    y_min = floor(fmax(y1_min, y2_min));
    y_max = ceil(fmin(y1_max, y2_max));
    
    if(y_min >= y_max)
    {
        *ration = 0;
        return;
    }
    
    double max_iter = 150, min_step = 0.2, iter_step = (y_max - y_min)/(max_iter + 2);
    double search_step = fmax(min_step, iter_step);

	double S12 = 0;

	for (double i = y_min; i <= y_max+1e-6; i = i + search_step)
	{
		double x11, x12, x21, x22;
		CalculateRangeAtY(parm1, i, &x11, &x12);
		CalculateRangeAtY(parm2, i, &x21, &x22);

		//mexPrintf("[%.4f,%.4f],[%.4f,%.4f]\n", x11, x12, x21, x22);

		double rangetemp[3] = { -1,-2,i };
		if (x11 <= x12&& x21 <= x22)
		{
			if (x11 <= x21 && x12 >= x21)
			{
				if (x12 < x22)
				{
					S12 += x12 - x21;
					rangetemp[0] = x12, rangetemp[1] = x21;
				}
				else
				{
					S12 += x22 - x21;
					rangetemp[0] = x22, rangetemp[1] = x21;
				}
			}
			else if (x21 <= x11 && x22 >= x11)
			{
				if (x22 < x12)
				{
					S12 += x22 - x11;
					rangetemp[0] = x22, rangetemp[1] = x11;
				}
				else
				{
					S12 += x12 - x11;
					rangetemp[0] = x12, rangetemp[1] = x11;
				}
			}
		}

		overlapdot[0].push_back(rangetemp[0]);
		overlapdot[1].push_back(rangetemp[1]);
		overlapdot[2].push_back(rangetemp[2]);
	}

	//mexPrintf("%.4f\n", S12);
	*ration = S12 *search_step / (PI*elp1[2] * elp1[3] + PI*elp2[2] * elp2[3] - S12*search_step);

	

}