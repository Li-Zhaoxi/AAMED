#include "mex.h"


void mexFunction(int nlhs,       mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])       
{
    if(nlhs!=1)
    {
        mexErrMsgTxt("输出参数个数必须为1个.");
    }
    if(nrhs!=1)
    {
        mexErrMsgTxt("输入参数个数必须为1个.");
    }
    size_t allnum = mxGetNumberOfElements(prhs[0]);
    unsigned char* _d = (unsigned char*)mxGetPr(prhs[0]);
    int now_need = 4;
    if(allnum < now_need)
        mexErrMsgTxt("解析VVP所需数据不足");
    int elpNum = *((int*)_d);
    _d+=4;
    if(elpNum == 0)
    {
        plhs[0] = mxCreateDoubleMatrix(0, 5, mxREAL);;
        return;
    }
    now_need += elpNum * 5 * sizeof(float);
    if(allnum < now_need)
        mexErrMsgTxt("解析VVP所需数据不足");
    plhs[0] = mxCreateDoubleMatrix(elpNum, 5, mxREAL);
    double* _pdata = (double*)mxGetPr(plhs[0]);
    float *_rrect = (float*)_d;
    for(int i = 0; i < elpNum; i++)
    {
        _pdata[i + 0 * elpNum] = *_rrect; _rrect++;
        _pdata[i + 1 * elpNum] = *_rrect; _rrect++;
        _pdata[i + 2 * elpNum] = *_rrect; _rrect++;
        _pdata[i + 3 * elpNum] = *_rrect; _rrect++;
        _pdata[i + 4 * elpNum] = *_rrect; _rrect++;
    }
}