clc;clear all;close all;
% 绘制标准像素尺度

fun{1} = @(x) x<=0.5;
fun{2} = @(x) x>0.5 & x<=1;
fun{3} = @(x) x>1 & x<=2;
fun{4} = @(x) x>2 & x<=4;
fun{5} = @(x) x>4 & x<=6;
fun{6} = @(x) x>6 & x<=8;
fun{7} = @(x) x>8 & x<=10;
fun{8} = @(x) x>10;

load gt.mat;
px = gt_size(:,1).*gt_size(:,2);
px = px'/1e6;

load elsd.mat;
useTime = zeros(1, 8);
for i = 1:length(useTime)
    idx = find(fun{i}(px)>0);
    useTimes = dt_time(idx);
    if length(useTimes) ~=0
        useTime(i) = mean(useTimes);
    end
end
format long g
useTime
format short g