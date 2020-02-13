function [x,y] = GenerateElpData(elp, varargin)
% 根据椭圆的形状参数(xc, yc, semi-major, semi_minor, theta)，得到椭圆的数据点
if nargin == 1
    sita = linspace(0,2*pi,200);
elseif nargin == 2
    sita = linspace(0,2*pi,varargin(1));
else
    error('输入参数过多');
end

xc = elp(1); yc = elp(2); R = elp(3); r = elp(4); theta = elp(5);

x0 = R*cos(sita); y0 = r*sin(sita);

XY = [cos(theta), -sin(theta); sin(theta), cos(theta)]*[x0;y0];

x = XY(1,:) + xc;
y = XY(2,:) + yc;




end