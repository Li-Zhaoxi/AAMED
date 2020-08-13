#include "mex.h"
#include "../src/FLED.h"
#include <iostream>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])        
{
    if(nrhs!=1)
    {
        mexErrMsgTxt("There only needs the AAMED pointer.");
    }
    if(nlhs!=0)
    {
        mexErrMsgTxt("No return value.");
    }
    
    // Get the data;
    AAMED *_aamed = NULL;
    if(mxGetNumberOfElements(prhs[0]) != sizeof(_aamed))
        mexErrMsgTxt("Wrong AAMED Pointer.");
    
    unsigned char *_pt = (unsigned char *)mxGetPr(prhs[0]);
    
    int pointer_size = sizeof(_aamed);
    unsigned char *_pt_aamed = (unsigned char *)&_aamed;
    for(int i = 0; i < pointer_size; i++)
    {
        _pt_aamed[i] = _pt[i];
    }
    if(_aamed == 0)
        mexWarnMsgTxt("input parm is a null pointer(0)");
    else
    {
        delete _aamed;
        for(int i = 0; i < pointer_size; i++)
        {
            _pt[i] = 0;
        }
    }
    

}