#include "mex.h"
#include "MeasureTools.h"


#include <iostream>
#include <vector>
using namespace std;



void mexFunction(int nlhs,       mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])        
{
    if(nlhs!=2)
    {
        mexErrMsgTxt("输出参数个数必须为2个.");
    }
    if(nrhs!=2)
    {
        mexErrMsgTxt("输入参数个数必须为2个.");
    }
    
    // Get the data;
    double *elp1 = (double *)mxGetPr(prhs[0]);
    double *elp2 = (double *)mxGetPr(prhs[1]);
    
    // Outputdata
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    double *ration = (double *)mxGetPr(plhs[0]);
    
    vector<double> overlapdot[3];
    fasterCalculateOverlap(elp1, elp2, ration, overlapdot);
    
    plhs[1] = mxCreateDoubleMatrix(overlapdot[0].size(),3,mxREAL);
    double *_overlap = (double *)mxGetPr(plhs[1]);
    for(int i=0;i<overlapdot[0].size();i++)
        _overlap[i] = overlapdot[0][i];
    for(int i=0;i<overlapdot[1].size();i++)
        _overlap[i + overlapdot[0].size()] = overlapdot[1][i];
    for(int i=0;i<overlapdot[2].size();i++)
        _overlap[i + 2 * overlapdot[0].size()] = overlapdot[2][i];
    
    
}

