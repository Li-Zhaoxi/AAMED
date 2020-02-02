function [ration, overlapdot] = fasterCalculateOverlap(elp1,elp2)
% 计算两个椭圆的重叠面积
% elp格式为[epl(1),elp(2)]为椭圆中心点，[elp1(3),elp(4)]为椭圆半长短轴,elp(5)为弧度制旋转角

%% 形状参数转换为椭圆的一般方程
parm1 = ELPShape2Equation(elp1);
parm2 = ELPShape2Equation(elp2);

%% 计算椭圆Y方向的搜索范围
[y_min1, y_max1, ~, ~] = CalculateRangeOfY(elp1);
[y_min2, y_max2, ~, ~] = CalculateRangeOfY(elp2);

y_min = floor(max([y_min1,y_min2]));
y_max = ceil(min([y_max1,y_max2]));

if y_min >= y_max
    ration = 0;
    overlapdot = [];
    return;
end

max_iter = 150;
min_step = 0.2;

iter_step = (y_max - y_min)/(max_iter + 2);

search_step = max([min_step, iter_step]);



%% 计算重叠面积
S12 = 0; % S12表示重叠面积
overrange = zeros(length(y_min:search_step:y_max),3); idx_lap = 1;


for i = y_min:search_step:y_max
    [x11,x12] = CalculateRangeAtY(parm1,i);
    [x21,x22] = CalculateRangeAtY(parm2,i);
%     x11
%     x12
%     x21
%     x22
%     i

    %disp(num2str([x11,x12,x21,x22]));
    rangetemp = [-1,-2,i];
    if ~isempty(x11) && ~isempty(x21)
        if x11<=x21 && x12>=x21 
            if x12<x22   % [x11   [x21   x12]  x22]
                S12 = S12 + x12-x21;
                rangetemp =[x12,x21,i];
            else   % [x11   [x21     x22]  x12]
                S12 = S12 + x22-x21;
                rangetemp =[x22,x21,i];
            end
        elseif x21<=x11 && x22>=x11  
            if x22 < x12   % [x21   [x11   x22]   x12]  
                S12 = S12 + x22 - x11;
                rangetemp =[x22,x11,i];
            else    % [x21   [x11     x12]   x22] 
                S12 = S12 + x12-x11;
                rangetemp =[x12,x11,i];
            end
        end
    end
    overrange(idx_lap,:) = rangetemp;
    idx_lap = idx_lap + 1;
end

ration = S12 * search_step/(pi*elp1(3)*elp1(4)+pi*elp2(3)*elp2(4) - S12 * search_step);
overlapdot = overrange;
end