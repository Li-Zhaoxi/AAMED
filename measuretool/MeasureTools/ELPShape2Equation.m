function parm = ELPShape2Equation(elpshape)
% 形状参数转方程参数：前两个中心点，然后半长短轴
xc = elpshape(1); yc = elpshape(2); a = elpshape(3); b = elpshape(4); theta = elpshape(5);

parm = zeros(1,5);

parm(1) = cos(theta)^2/a^2 + sin(theta)^2/b^2;
parm(2) = -(sin(2*theta)*(a^2 - b^2))/(2*a^2*b^2);
parm(3) = cos(theta)^2/b^2 + sin(theta)^2/a^2;
parm(4) = (-a^2*xc*sin(theta)^2 + (a^2*yc*sin(2*theta))/2)/(a^2*b^2) - (xc*cos(theta)^2 + (yc*sin(2*theta))/2)/a^2;
parm(5) = (-a^2*yc*cos(theta)^2 + (a^2*xc*sin(2*theta))/2)/(a^2*b^2) - ((xc*sin(2*theta))/2 + yc*sin(theta)^2)/a^2;
parm(6) = (xc*cos(theta) + yc*sin(theta))^2/a^2 + (yc*cos(theta) - xc*sin(theta))^2/b^2 - 1;
k = parm(1)*parm(3)-parm(2)^2;
parm = parm/sqrt(abs(k));


end