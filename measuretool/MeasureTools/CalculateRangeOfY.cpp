#include "MeasureTools.h"

void CalculateRangeOfY(double *elpshape, double *x_min, double *x_max, double *y_min, double *y_max)
{
    double elp_equ[6];
    ELPShape2Equation(elpshape, elp_equ);
    
    double B, C;
    B = elp_equ[1] * elp_equ[3] - elp_equ[0] * elp_equ[4];
    C = elp_equ[3] * elp_equ[3] - elp_equ[0] * elp_equ[5];
    
    double tx_min, tx_max, ty_min, ty_max;
    
    ty_min = B - sqrt(B*B + C);
    ty_max = B + sqrt(B*B + C);
    
    tx_min = -(elp_equ[1] * ty_min + elp_equ[3]) / elp_equ[0];
    tx_max = -(elp_equ[1] * ty_max + elp_equ[3]) / elp_equ[0];
    
    *x_min = tx_min;
    *x_max = tx_max;
    *y_min = ty_min;
    *y_max = ty_max;
    
    
}