function [y_min, y_max, x_min, x_max] = CalculateRangeOfY(elp_shape)

elp_equ = mexELPShape2Equation(elp_shape);

B = elp_equ(2) * elp_equ(4) - elp_equ(1) * elp_equ(5);
C = elp_equ(4) * elp_equ(4) - elp_equ(1) * elp_equ(6);
y_min = B - sqrt(B*B + C);
y_max = B + sqrt(B*B + C);
x_min = -(elp_equ(2) * y_min + elp_equ(4)) / elp_equ(1);
x_max = -(elp_equ(2) * y_max + elp_equ(4)) / elp_equ(1);

end