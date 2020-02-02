clc;clear all;close all;
% 椭圆验证程序，更新：2018-12-16
%

addpath MeasureTools;

try
    parpool('local', 4);
catch
    warning('并行可能已开启');
end

data_root_path = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset\';

dataset_name = [{'Synthetic Images - Occluded Ellipses'},...
    {'Synthetic Images - Overlap Ellipses'},...
    {'Prasad Images - Dataset Prasad'},...
    {'Random Images - Dataset #1'},...
    {'Smartphone Images - Dataset #2'},...
    {'Concentric Ellipses - Dataset Synthetic'},...
    {'Concurrent Ellipses - Dataset Synthetic'},...
    {'Satellite Images - Dataset Meng #1'},...
    {'Satellite Images - Dataset Meng #2'},...
    {'Industrial Images - Dataset Meng'}];

gt_label = [{'occluded'},{'overlap'},{'prasad'},{'random'},{'smartphone'},...
    {'concentric'},{'concurrent'},{'satellite1'}, {'satellite2'}, {'industrial'}];

methods_name = 'FLED-T-Val';
method_label = 'aamed';


dsi = 1;

T_val = 0:44;
P_val = zeros(1, length(T_val));
R_val = zeros(1, length(T_val));
F_val = zeros(1, length(T_val));


imgname_path = [data_root_path,dataset_name{dsi},'\imagenames.txt'];
fid = fopen(imgname_path,'r');
imgnum = 0;
imgname = [];
while feof(fid) == 0
    imgnum = imgnum + 1;
    imgname{imgnum} = fgetl(fid);
end
fclose(fid);


dirpath = [data_root_path,dataset_name{dsi},'\'];

%% 读取椭圆ground truth
if strcmp(gt_label{dsi},'occluded') || strcmp(gt_label{dsi},'overlap') || ...
        strcmp(gt_label{dsi},'concentric') || strcmp(gt_label{dsi},'concurrent') % 仿真数据集
    [gt_elps, gt_size] = Read_Ellipse_GT([dirpath,'gt\'], ...
        [dirpath,'images\'], imgname, gt_label{dsi});
    T_overlap = 0.95;
else
    [gt_elps, gt_size] = Read_Ellipse_GT([dirpath,'gt\gt_'], ...
        [dirpath,'images\'], imgname, gt_label{dsi});
    T_overlap = 0.8;
end
elp_num = 0;
for k = 1:length(gt_elps)
    elp_num = elp_num + size(gt_elps{k},1);
end
%     disp(['真实椭圆个数为：', num2str(elp_num)]);


parfor i = 1:length(T_val)
    disp(['Processing', num2str(T_val(i)), ' T_val']);
    %% 读取检测结果
    dt_elps = cell(1, imgnum);
    dt_time = zeros(1,imgnum);
    filepath = [dirpath,methods_name,'\'];
    for k = 1:imgnum
        fid_dt = fopen([filepath, imgname{k},'-',num2str(T_val(i)),'.aamed.txt']);
        if fid_dt == -1
            error([dataset_name, ': wrong file path']);
        end
        elps_data = [];
        dt_time(k) = str2num(fgetl(fid_dt));
        while feof(fid_dt) == 0
            elp_datat = str2num(fgetl(fid_dt));
            if elp_datat(1) == 2
                continue;
            end
            elp_datat(1) = [];
            temp = elp_datat(1);
            elp_datat(1) = elp_datat(2);
            elp_datat(2) = temp;
            elp_datat(1:2) = elp_datat(1:2)+1;
            elp_datat(3:4) = elp_datat(3:4)/2;
            elp_datat(5) = -elp_datat(5)/180*pi;
            
            elps_data = [elps_data; elp_datat];
        end
        dt_elps{k} = elps_data;
        fclose(fid_dt);
    end
    %% 根据检测结果计算对应的PRF
    pos_num = zeros(1,imgnum); % 有效椭圆个数
    pos_elp = cell(1, imgnum); % 有效椭圆参数，最后一个是角标
    
    det_num = zeros(1,imgnum); % 检测出的椭圆个数
    det_elp = cell(1,imgnum); % 存储无效椭圆个数，最后一个是角标
    
    gt_num = zeros(1,imgnum);  % 真实椭圆个数
    gt_elp = cell(1, imgnum);  % 存储未检测
    for k = 1:imgnum
        detected_ellipses = dt_elps{k};
        gt_ellipses = gt_elps{k};
        
        elpnum_det = size(detected_ellipses, 1);
        elpnum_gt = size(gt_ellipses, 1);
        
        elps_overlap = zeros(elpnum_det, elpnum_gt);
        for p = 1:elpnum_det
            for q = 1:elpnum_gt
                [ration, ~] = mexCalculateOverlap(detected_ellipses(p,:),gt_ellipses(q,:));
                elps_overlap(p,q) = ration;
            end
        end
        
        res = elps_overlap > T_overlap;
        
        gt_match = sum(res, 1);
        det_match = sum(res, 2);
        
        num_loss_elp = sum(gt_match == 0);
        num_false_elp = sum(det_match == 0);
        
        % 注：考虑到目标的特殊性，一个检测出来的椭圆可能会对应两个gt椭圆，那么这个检测出来
        % 的椭圆可以认为是2个，自动对数目进行扩展。相反，多个det可能会对应一个gt，这个问题
        % 可以被认为是没有设计出一个好的椭圆聚类算法
        num_true_elp = sum(gt_match > 0);
        num_det_true_elp = sum(det_match > 0);
        
        % 统计有效椭圆个数，检测个数，与真实个数
        pos_num(k) = num_true_elp;
        det_num(k) = num_true_elp + num_false_elp + max([num_det_true_elp - num_true_elp, 0]);
        gt_num(k) = num_true_elp + num_loss_elp;
    end
    
    pos_all = sum(pos_num);
    det_all = sum(det_num);
    gt_all = sum(gt_num);
    
    P = pos_all / det_all;
    R = pos_all / gt_all;
    F = 2 * P * R / (P + R);
    
    P_val(i) = P;
    R_val(i) = R;
    F_val(i) = F;
    
    
end

save PRF_val.mat P_val R_val F_val;