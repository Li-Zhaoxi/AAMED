#include "mex.h"
#include "MeasureTools.h"


#include "iostream"
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
    double *elpparm = (double *)mxGetPr(prhs[0]);
    double *_y = (double *)mxGetPr(prhs[1]);
    
    // Outputdata
    //mexPrintf("%d, %d\n", ng, nf);
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
    
    double *x1 = (double *)mxGetPr(plhs[0]);
    double *x2 = (double *)mxGetPr(plhs[1]);
    
    CalculateRangeAtY(elpparm, *_y, x1, x2);
    
}