clc;clear;close all;
% 测试算法的极限程度

%% 绘制SemiMajorWithAxisRatio 的极限图

data_root_path = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset\';
dataset_name = 'SemiMajorWithAxisRatio';
gt_label = 'semimajorwithaxisratio';


large_size = [1,1.1,1.2,1.3,1.4,2.25,2.5,2.75,3,3.25,3.5,3.75,4];
str_size = [{'1'},{'1.1'},{'1.2'},{'1.3'},{'1.4'},{'2.25'},{'2.5'},{'2.75'},{'3'},{'3.25'},{'3.5'},{'3.75'},{'4'}];
idx_size = 5;

methods_name = ['FLED_', str_size{idx_size}];
method_label = 'fled';

semimajor = 1:100;
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

load semimajorwithaxisratio_gt.mat
% [gt_elps, gt_size] = Read_Ellipse_GT([dirpath,'gt\'], ...
%     [dirpath,'images\'], imgname, gt_label);

T_overlap = 0.90;

[dt_elps, dt_time] = Read_Ellipse_Results([dirpath,methods_name,'\'], ...
        imgname, method_label);
    
    
valid_range = zeros(length(semimajor), length(ratio), 3);
true_color = [255,255,255];
false_color = [0,0,0];


for i = 1:imgnum
    disp(['正在处理第',num2str(i),'张图片']);
    str = imgname{i};
    idx = find(str == '_');
    str_num1 = str((idx(1)+1):(idx(2)-1));
    str_num2 = str((idx(3)+1):(end-4));
    
    semi_idx = str2double(str_num1);
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
        valid_range(semi_idx, ratio_idx,:) = true_color(:);
    else
        valid_range(semi_idx, ratio_idx,:) = false_color(:);
    end
end


figure;
imshow(uint8(valid_range));

% imwrite(uint8(valid_range),'semimajorwithaxisratio.png', 'png');
imwrite(uint8(valid_range),['semimajorwithaxisratio-',str_size{idx_size},'.png'], 'png');

