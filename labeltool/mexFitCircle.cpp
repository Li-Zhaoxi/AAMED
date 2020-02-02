#include "mex.h"
#include <opencv2/opencv.hpp>
#include <iostream>

using namespace std;
using namespace cv;

#define PIXEL_SCALE 50
void GetPointMat(double x, double y, int scale, double *nodeMat)
{
    nodeMat[0] = pow(double(x), 4) / pow(scale, 4);
	nodeMat[1] = 2 * pow(double(x), 3)*y / pow(scale, 4);
	nodeMat[2] = double(x)*x*y*y / pow(scale, 4);
	nodeMat[3] = 2 * pow(double(x), 3) / pow(scale, 3);
	nodeMat[4] = 2 * double(x)*x*y / pow(scale, 3);
	nodeMat[5] = double(x)*x / (scale*scale);
	nodeMat[6] = 2 * double(x)*y*y*y / pow(scale, 4);
	nodeMat[7] = 4 * double(x)*y*y / pow(scale, 3);
	nodeMat[8] = 2 * double(x)*y / (scale*scale);
	nodeMat[9] = pow(double(y), 4) / pow(scale, 4);
	nodeMat[10] = 2 * pow(double(y), 3) / pow(scale, 3);
	nodeMat[11] = double(y)*y / (scale*scale);
	nodeMat[12] = 2 * double(x) / scale;
	nodeMat[13] = 2 * double(y) / scale;
	nodeMat[14] = 1;
}

void fitCircle(double *data, double &error, cv::RotatedRect &res)
{
    double _buf_fit_data[36];
    int dot_num = data[14];
    cv::Point2d cen_dot(data[12] / (2 * dot_num), data[13] / (2 * dot_num));//the center of the fitting data.

    _buf_fit_data[0] = data[0] - 2 * cen_dot.x*data[3] + 6 * cen_dot.x*cen_dot.x*data[5] - 3 * dot_num*pow(cen_dot.x, 4);
    _buf_fit_data[1] = data[1] - 3 * cen_dot.x*data[4] + 3 * cen_dot.x*cen_dot.x*data[8] - cen_dot.y*data[3] + cen_dot.x*cen_dot.y * 6 * data[5] - 6 * dot_num*cen_dot.y*pow(cen_dot.x, 3);
    _buf_fit_data[2] = data[2] - cen_dot.y*data[4] + cen_dot.y*cen_dot.y*data[5] - cen_dot.x*data[7] / 2 + cen_dot.x*cen_dot.y*data[8] * 2 + cen_dot.x*cen_dot.x*data[11] - 3 * dot_num*pow(cen_dot.x*cen_dot.y, 2);
    _buf_fit_data[3] = data[3] - 6 * cen_dot.x*data[5] + 4 * dot_num*pow(cen_dot.x, 3);
    _buf_fit_data[4] = data[4] - cen_dot.x*data[8] * 2 - 2 * cen_dot.y*data[5] + 4 * dot_num*cen_dot.x*cen_dot.x*cen_dot.y;
    _buf_fit_data[5] = data[5] - dot_num*cen_dot.x*cen_dot.x;

    _buf_fit_data[1 * 6 + 1] = 4 * _buf_fit_data[2];
    _buf_fit_data[1 * 6 + 2] = data[6] - 1.5 * cen_dot.y*data[7] + 3 * cen_dot.y*cen_dot.y*data[8] - cen_dot.x*data[10] + 6 * cen_dot.x*cen_dot.y*data[11] - 6 * dot_num*cen_dot.x*pow(cen_dot.y, 3);
    _buf_fit_data[1 * 6 + 3] = 2 * _buf_fit_data[4];
    _buf_fit_data[1 * 6 + 4] = data[7] - 4 * cen_dot.y*data[8] - 4 * cen_dot.x*data[11] + 8 * dot_num*cen_dot.x*cen_dot.y*cen_dot.y;
    _buf_fit_data[1 * 6 + 5] = data[8] - 2 * dot_num*cen_dot.x*cen_dot.y;

    _buf_fit_data[2 * 6 + 2] = data[9] - 2 * cen_dot.y*data[10] + 6 * cen_dot.y*cen_dot.y*data[11] - 3 * dot_num*pow(cen_dot.y, 4);
    _buf_fit_data[2 * 6 + 3] = _buf_fit_data[1 * 6 + 4] / 2;
    _buf_fit_data[2 * 6 + 4] = data[10] - 6 * cen_dot.y*data[11] + 4 * dot_num*pow(cen_dot.y, 3);
    _buf_fit_data[2 * 6 + 5] = data[11] - dot_num*cen_dot.y*cen_dot.y;

    _buf_fit_data[3 * 6 + 3] = 4 * _buf_fit_data[5];
    _buf_fit_data[3 * 6 + 4] = 2 * _buf_fit_data[1 * 6 + 5];
    _buf_fit_data[3 * 6 + 5] = 0;

    _buf_fit_data[4 * 6 + 4] = 4 * _buf_fit_data[2 * 6 + 5];
    _buf_fit_data[4 * 6 + 5] = 0;

    _buf_fit_data[5 * 6 + 5] = dot_num;
    for (int i = 0; i < 6; i++)
    {
        for (int j = i + 1; j < 6; j++)
        {
            _buf_fit_data[j * 6 + i] = _buf_fit_data[i * 6 + j];
        }
    }

    double _buffer_circle_data[16];
    _buffer_circle_data[0] = _buf_fit_data[0] + 2 * _buf_fit_data[2] + _buf_fit_data[2 * 6 + 2];
    _buffer_circle_data[1] = _buf_fit_data[3] + 2 * _buf_fit_data[3 * 6 + 2];
    _buffer_circle_data[2] = _buf_fit_data[4] + _buf_fit_data[2 * 6 + 4];
    _buffer_circle_data[3] = _buf_fit_data[5] + _buf_fit_data[2 * 6 + 5];
    _buffer_circle_data[1 * 4 + 1] = _buf_fit_data[ 3 * 6 + 3];
    _buffer_circle_data[1 * 4 + 2] = _buf_fit_data[ 3 * 6 + 4];
    _buffer_circle_data[1 * 4 + 3] = _buf_fit_data[ 3 * 6 + 5];
    _buffer_circle_data[2 * 4 + 2] = _buf_fit_data[ 4 * 6 + 4];
    _buffer_circle_data[2 * 4 + 3] = _buf_fit_data[ 4 * 6 + 5];
    _buffer_circle_data[3 * 4 + 3] = dot_num;
    for (int i = 0; i < 4; i++)
    {
        for (int j = i + 1; j < 4; j++)
        {
            _buffer_circle_data[j * 4 + i] = _buffer_circle_data[i * 4 + j];
        }
    }
    cv::Mat DLS_C = cv::Mat::zeros(4,4,CV_64FC1), buf_circle_data(4, 4, CV_64FC1, _buffer_circle_data);
    DLS_C.at<double>(0, 3) = -0.5;
    DLS_C.at<double>(3, 0) = -0.5;
    DLS_C.at<double>(1, 1) = 1;
    DLS_C.at<double>(2, 2) = 1;
    
    cv::Mat dls_D, dls_V, dls_D2, dls_V2, dls_X;

    cv::eigen(buf_circle_data, dls_D, dls_V);
    double *_dls_D = (double*)dls_D.data;
    if (_dls_D[3] > 1e-10)
    {
        for (int i = 0; i < 4; i++)
            dls_V.row(i) = dls_V.row(i) / sqrt(fabs(_dls_D[i]));
        buf_circle_data = dls_V*DLS_C*dls_V.t();
        cv::eigen(buf_circle_data, dls_D2, dls_V2);
        //		cout << dls_D2 << '\n' << dls_V2 << endl;
        double *_dls_D2 = (double*)dls_D2.data;
        if (_dls_D2[0] > 0)
        {
            error = PIXEL_SCALE*PIXEL_SCALE / _dls_D2[0] / dot_num;
            dls_X = dls_V2.row(0)*dls_V;
        }
        else
        {
            error = -1;
            return;
        }
    }
    else
        dls_X = dls_V.row(3);


    double *_dls_X = (double*)dls_X.data;
    double dls_k = _dls_X[1] * _dls_X[1] + _dls_X[2] * _dls_X[2] - _dls_X[0] * _dls_X[3];
    dls_X = dls_X / sqrt(abs(dls_k));



    res.center.x = (-_dls_X[1]/_dls_X[0] + cen_dot.x)*PIXEL_SCALE;
    res.center.y = (-_dls_X[2]/_dls_X[0] + cen_dot.y)*PIXEL_SCALE;
    res.size.width =  res.size.height = 2 / abs(_dls_X[0]) * PIXEL_SCALE;
    res.angle = 0;


}




void mexFunction(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
    int N = (int)mxGetM(prhs[0]);
    double *p = (double *)mxGetPr(prhs[0]);
    

    const int mat_element_num = 15;
    double tmpMat[mat_element_num];
    double FitMat[mat_element_num];
    for(int i = 0; i < mat_element_num; i++)
        tmpMat[i] = FitMat[i] = 0;
    for(int i = 0; i < N; i++)
    {
        double x = p[i];
        double y = p[i + N];
        GetPointMat(x, y, PIXEL_SCALE, tmpMat);
        for(int k = 0; k < mat_element_num; k++)
            FitMat[k] += tmpMat[k];
    }
    double error;
    RotatedRect res;
    fitCircle(FitMat, error, res);
    if (error < -0.5)
    {
        res.size.width = -100;
        res.size.height = -100;
    }
    
    plhs[0] = mxCreateDoubleMatrix(5,1,mxREAL);
    double *res_elp = (double *)mxGetPr(plhs[0]);
    res_elp[0] = res.center.x;
    res_elp[1] = res.center.y;
    res_elp[2] = res.size.width;
    res_elp[3] = res.size.height;
    res_elp[4] = res.angle;
}