#include "mex.h"
#include "../src/FLED.h"
#include <iostream>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])        
{
    if(nrhs!=2)
    {
        mexErrMsgTxt("There are only 2 input parameters (drows, dcols),drows (dcols) must be larger than the rows (cols) of all used images.");
    }
    if(nlhs!=1)
    {
        mexErrMsgTxt("Output parameter is AAMED class pointer only.");
    }
    
    // Get the data;
    double drows = *(double *)mxGetPr(prhs[0]);
    double dcols = *(double *)mxGetPr(prhs[1]);
    
    AAMED *_aamed = new AAMED(std::round(drows), std::round(dcols));
    int pointer_size = sizeof(_aamed);
    
    plhs[0] = mxCreateNumericMatrix(1, pointer_size, mxUINT8_CLASS, mxREAL);
    unsigned char *_pt = (unsigned char *)mxGetPr(plhs[0]);
    unsigned char *_pt_aamed = (unsigned char *)&_aamed;
    for(int i = 0; i < pointer_size; i++)
    {
        _pt[i] = _pt_aamed[i];
    }
}