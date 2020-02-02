clc;clear;close all;
% 测试算法的极限程度

%% 绘制SemiMajorWithAxisRatio 的极限图

addpath('MeasureTools')

data_root_path = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset\';
dataset_name = 'AxisRatioWithOrientation';
gt_label = 'axisratiowithorientation';

large_size = [1,1.1,1.2,1.3,1.4,2.25,2.5,2.75,3,3.25,3.5,3.75,4];
str_size = [{'1'},{'1.1'},{'1.2'},{'1.3'},{'1.4'},{'2.25'},{'2.5'},{'2.75'},{'3'},{'3.25'},{'3.5'},{'3.75'},{'4'}];
idx_size = 4;


methods_name = ['FLED_', str_size{idx_size}];
method_label = 'fled';

orientation = -89:90;
ratio = 0.01:1;


imgname_path = [data_root_path,dataset_name,'\imagenames.txt'];
fid = fopen(imgname_path,'r');
imgnum = 0;
imgname = [];
while feof(fid) == 0
    imgnum = imgnum + 1;
    imgname{imgnum} = fgetl(fid);
end
fclose(fid);

dirpath = [data_root_path,dataset_name,'\'];


load axisratiowithorientation_gt.mat;
% [gt_elps, gt_size] = Read_Ellipse_GT([dirpath,'gt\'], ...
%     [dirpath,'images\'], imgname, gt_label);

T_overlap = 0.90;

% load axisratiowithorientation_1_dt.mat;
% load(['axisratiowithorientation_',str_size{idx_size},'_dt.mat']);
[dt_elps, dt_time] = Read_Ellipse_Results([dirpath,methods_name,'\'], ...
        imgname, method_label);
save(['axisratiowithorientation_',str_size{idx_size},'_dt.mat'], 'dt_elps', 'dt_time');
    
    
valid_range = zeros(length(orientation), length(ratio), 3);
true_color = [255,255,255];
false_color = [0,0,0];


for i = 1:imgnum
    if mod(i, 100) == 0
        disp(['正在处理第',num2str(i),'张图片']);
    end
    
    str = imgname{i};
    idx = find(str == '_');
    str_num1 = str((idx(1)+1):(idx(2)-1));
    str_num2 = str((idx(3)+1):(end-4));
    
    orien_idx = str2double(str_num1) + 90;
    ratio_idx = str2double(str_num2);
    
    gt = gt_elps{i}(1,:);
    dt = dt_elps{i};
    isValid = 0;
    for k = 1:size(dt,1)
        [ration, ~] = mexCalculateOverlap(dt(k,:),gt);
        if ration >= T_overlap
            isValid = 1;
            break;
        end
    end
    
    if isValid
        valid_range(orien_idx, ratio_idx,:) = true_color(:);
    else
        valid_range(orien_idx, ratio_idx,:) = false_color(:);
    end
end


figure;
imshow(uint8(valid_range));

imwrite(uint8(valid_range),['axisratiowithorientation-',str_size{idx_size},'.png'], 'png');


