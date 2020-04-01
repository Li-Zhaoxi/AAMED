#include "mex.h"
#include "../src/FLED.h"
#include <iostream>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])        
{
    if(nrhs!=1)
    {
        mexErrMsgTxt("There is only 1 input AAMED pointer.");
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
    _aamed->release();
    //delete[] _aamed;

}