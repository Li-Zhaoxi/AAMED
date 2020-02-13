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
    if(allnum < 2 * sizeof(int))
        mexErrMsgTxt("Basic参数大小小于2个int");
    unsigned char *_d = (unsigned char *)mxGetPr(prhs[0]);
    int iROWS = *((int*)_d), iCOLS = *((int*)(_d+4));
    //mexPrintf("%d, %d\n", iROWS,iCOLS);
    
    const int filednumber = 2;
    const char* filednames[filednumber] = {"iROWS", "iCOLS"};
    plhs[0] = mxCreateStructMatrix(1,1,filednumber,filednames);
    
    mxArray *pROWS = mxCreateDoubleMatrix(1,1,mxREAL);
    *(double*)mxGetPr(pROWS)=iROWS;
    
    mxArray *pCOLS = mxCreateDoubleMatrix(1,1,mxREAL);
    *(double*)mxGetPr(pCOLS)=iCOLS;
    
    mxSetField(plhs[0], 0, "iROWS", pROWS);
    mxSetField(plhs[0], 0, "iCOLS", pCOLS);
    
    //mxDestroyArray(pROWS);mxDestroyArray(pCOLS);
    
}