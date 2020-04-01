#include "mex.h"
#include "../src/FLED.h"
#include <iostream>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])        
{
    if(nrhs!=2)
    {
        mexErrMsgTxt("There are only 2 input parameters (obj, uint8 gray image).");
    }
    if(nlhs!=1)
    {
        mexErrMsgTxt("There is only 1 output parameter(detected ellipses).");
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
    unsigned char * _imgmatlab = (unsigned char *)mxGetPr(prhs[1]);
    int irows = mxGetM(prhs[1]);
    int icols = mxGetN(prhs[1]);
    cv::Mat imgG(irows, icols, CV_8UC1);
    unsigned char * _img = (unsigned char*)imgG.data;
    for(int i = 0; i < irows; i++)
    {
        for(int j = 0; j < icols; j++)
        {
            _img[i * icols + j] = _imgmatlab[j * icols + i];
        }
    }
    _aamed->run_FLED(imgG);
    int elp_num = _aamed->detEllipses.size();
    plhs[0] = mxCreateDoubleMatrix(elp_num,5,mxREAL);
    double *_elp = (double *)mxGetPr(plhs[0]);
    for(int i = 0; i < elp_num; i++)
    {
        _elp[i] = _aamed->detEllipses[i].center.x;
        _elp[i + elp_num] = _aamed->detEllipses[i].center.y;
        _elp[i + 2 * elp_num] = _aamed->detEllipses[i].size.width;
        _elp[i + 3 * elp_num] = _aamed->detEllipses[i].size.height;
        _elp[i + 4 * elp_num] = _aamed->detEllipses[i].angle;
    }

}