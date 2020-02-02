function [x1,x2] = CalculateRangeAtY(elpparm,y)
% 计算椭圆一般方程当y值已知时，计算出的两个交点，如果不存在则为空集
elpparm = double(elpparm);
A = elpparm(1); B = elpparm(2); C = elpparm(3); D = elpparm(4); E = elpparm(5); F = elpparm(6);
Delta = (B*y+D)^2 - A*(C*y^2+2*E*y+F);
if Delta< 0 
    x1 = []; x2 = [];
else
    x1 = (-(B*y+D)-sqrt(Delta))/A;
    x2 = (-(B*y+D)+sqrt(Delta))/A;
%     x1 = round(x1); x2 = round(x2);
    
    if x2 < x1
        t = x1;
        x1 = x2;
        x2 = t;
    end
    
end



end