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
    char* _d = (char*)mxGetPr(prhs[0]);
    
    int now_need = 4;
    if(allnum < now_need)
        mexErrMsgTxt("解析VVP所需数据不足");
    int fsaNum = *((int*)_d);
    _d+=4;
    now_need += fsaNum * fsaNum;
    if(allnum < now_need)
        mexErrMsgTxt("解析VVP所需数据不足");
    plhs[0] = mxCreateDoubleMatrix(fsaNum, fsaNum, mxREAL);
    double* _pdata = (double*)mxGetPr(plhs[0]);
    
    for(int i =0; i < fsaNum; i++)
    {
        for(int j = 0; j < fsaNum; j++)
        {
            _pdata[j * fsaNum + i] = *_d;
            _d++;
        }
    }
    
}