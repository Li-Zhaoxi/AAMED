clc;clear;close all;
% 设定AAMED参数，获得最终结果

data_root_path = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset';

dataset_name = [{'Synthetic Images - Occluded Ellipses'},...
    {'Synthetic Images - Overlap Ellipses'},...
    {'Prasad Images - Dataset Prasad'},...
    {'Random Images - Dataset #1'},...
    {'Smartphone Images - Dataset #2'}];
gt_label = [{'occluded'},{'overlap'},{'prasad'},{'random'},{'smartphone'}];

T_dp = 1.3;
theta_arc = 0.678;
lambda_arc = 3.6;
N_grad = 4;
T_val = 0.595;


for i = 3:length(dataset_name)
    
    if strcmp(gt_label{i},'occluded') || strcmp(gt_label{i},'overlap')
        isCanny = 0;
    else
        isCanny = 1;
    end
    
    cmd=['.\FLED.exe',' ',...
        data_root_path,' ',... % 数据集地址
        gt_label{i}, ' ',...  % 数据集名称
        num2str(T_dp),' ',...
        num2str(theta_arc),' ',...
        num2str(lambda_arc),' ',...
        num2str(T_val),' ',...
        num2str(N_grad), ' ',...
        num2str(isCanny)];
    [status, result]=system(cmd,'-echo');
    if status == -1024
        disp('exe调用失败');
    end
    
end