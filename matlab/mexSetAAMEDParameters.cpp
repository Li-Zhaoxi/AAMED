#include "mex.h"
#include "../src/FLED.h"
#include <iostream>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])        
{
    if(nrhs!=4)
    {
        mexErrMsgTxt("There are only 4 input parameters (obj, theta_arc, lambda_arc, T_val).");
    }
    if(nlhs!=0)
    {
        mexErrMsgTxt("No return value.");
    }
    
    // Get the data;
    unsigned char *_pt = (unsigned char *)mxGetPr(prhs[0]);
    AAMED *_aamed = NULL;
    int pointer_size = sizeof(_aamed);
    unsigned char *_pt_aamed = (unsigned char *)&_aamed;
    for(int i = 0; i < pointer_size; i++)
    {
        _pt_aamed[i] = _pt[i];
    }
    
    double theta_arc = *(double*)mxGetPr(prhs[1]);
    double lambda_arc = *(double*)mxGetPr(prhs[2]);
    double T_val = *(double*)mxGetPr(prhs[3]);
    
    _aamed->SetParameters(theta_arc, lambda_arc, T_val); 

}