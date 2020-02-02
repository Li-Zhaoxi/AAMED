#include "mex.h"
#include "MeasureTools.h"


void mexFunction(int nlhs,       mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])        
{
    if(nlhs!=4)
    {
        mexErrMsgTxt("输入参数个数必须为4个.");
    }
    if(nrhs!=1)
    {
        mexErrMsgTxt("输入参数个数必须为1个.");
    }
    
    // Get the data;
    double *elpparm = (double *)mxGetPr(prhs[0]);
    
    // Outputdata
    //mexPrintf("%d, %d\n", ng, nf);
    for(int i = 0; i < nlhs; i++)
    {
        plhs[i] = mxCreateDoubleMatrix(1,1,mxREAL);
    }
    
    double*_x_min = (double *)mxGetPr(plhs[2]);
    double*_x_max = (double *)mxGetPr(plhs[3]);
    double*_y_min = (double *)mxGetPr(plhs[0]);
    double*_y_max = (double *)mxGetPr(plhs[1]);

    CalculateRangeOfY(elpparm, _x_min, _x_max, _y_min, _y_max);    
    
}