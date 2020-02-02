clc;clear;close all;
% 计算不同参数下的结果PRF

ds_root_path = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset';
ds_name = 'random';

T_dp = 1.4;
theta_arc = 46/180*pi;
length_arc = 3.6;
T_val = 0.61;
N_grad = 5;
isCanny = 1;


cmd = ['AAMEDForAdjustParms.exe', ' ', ds_root_path,' ',ds_name, ' ',num2str(T_dp),' ',...
    num2str(theta_arc),' ',num2str(length_arc),' ',num2str(T_val),' ',num2str(N_grad), ' ', num2str(isCanny)];

[status, result]=system(cmd,'-echo');
if status == -1024
    disp('exe调用失败');
end