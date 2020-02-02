clc;clear;close all;
% 在所有数据集上，针对不同的重叠度计算所有的数据集，直接获得所有的PRF值

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

% methods_names = [{'Prasad'}, {'ELSD'}, {'YAED'}, {'TDED'}, {'RCNN'},{'TPED'}, {'CNED'}, {'Wu'}, {'FLED'}];
% method_labels = [{'prasad'}, {'elsd'}, {'yaed'}, {'tded'}, {'rcnn'},{'tped'}, {'cned'}, {'wu'}, {'fled'}];


methods_names = [{'Prasad'}, {'ELSD'}, {'YAED'}, {'Wang'}, {'RCNN'},{'TPED'}, {'CNED'}, {'Wu'}, {'Lu'}, {'FLED'}];
method_labels = [{'prasad'}, {'elsd'}, {'yaed'}, {'wang'}, {'rcnn'},{'tped'}, {'cned'}, {'wu'}, {'lu'}, {'fled'}];
                                                                                                                                                                                                                                   
% methods_names = [{'Prasad'}, {'ELSD'}, {'YAED'}, {'TDED'}, {'RCNN'},{'TPED'}, {'CNED'}, {'Wu'}, {'Lu'}, {'FLED'}];
% method_labels = [{'prasad'}, {'elsd'}, {'yaed'}, {'tded'}, {'rcnn'},{'tped'}, {'cned'}, {'wu'}, {'lu'}, {'fled'}];



for dsi = [3,4,5,8,9] %length(dataset_name)
    disp(['正在评价数据集: ',dataset_name{dsi}]);
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
    T_overlaps = 0.50:0.02:0.98;
    PRF_val = zeros(length(methods_names), 3, length(T_overlaps));
    for idx_method = 1:length(methods_names)
        %% 读取椭圆检测结果..
        disp(['正在计算算法：', methods_names{idx_method}]);
        [dt_elps, dt_time] = Read_Ellipse_Results([dirpath,methods_names{idx_method},'\'], ...
            imgname, method_labels{idx_method});
        
%         if strcmp(method_labels{idx_method},'rcnn')
%             T_overlaps = T_overlaps*70/80;
%         end
%         if strcmp(method_labels{idx_method},'elsd') || strcmp(method_labels{idx_method},'yaed') || strcmp(method_labels{idx_method},'wang') ...
%                 || strcmp(method_labels{idx_method},'cned') || strcmp(method_labels{idx_method},'lu') || strcmp(method_labels{idx_method},'tped')
%             T_overlaps = T_overlaps*90/80;
%         end
        
        for idx_overlap = 1:length(T_overlaps)
            T_overlap = T_overlaps(idx_overlap);
            pos_num = zeros(1,imgnum); % 有效椭圆个数
            pos_elp = cell(1, imgnum); % 有效椭圆参数，最后一个是角标
            
            det_num = zeros(1,imgnum); % 检测出的椭圆个数
            det_elp = cell(1,imgnum); % 存储无效椭圆个数，最后一个是角标
            
            gt_num = zeros(1,imgnum);  % 真实椭圆个数
            gt_elp = cell(1, imgnum);  % 存储未检测
            parfor i = 1:imgnum
                detected_ellipses = dt_elps{i};
                gt_ellipses = gt_elps{i};
                
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
                pos_num(i) = num_true_elp;
                det_num(i) = num_true_elp + num_false_elp + max([num_det_true_elp - num_true_elp, 0]);
                gt_num(i) = num_true_elp + num_loss_elp;
                
            end
            
            pos_all = sum(pos_num);
            det_all = sum(det_num);
            gt_all = sum(gt_num);
            if det_all == 0
                P = 0;
                R = 0;
                F = 0;
            else
                P = pos_all / det_all;
                R = pos_all / gt_all;
                F = 2 * P * R / (P + R);
            end
            
            PRF_val(idx_method, 1, idx_overlap) = P;
            PRF_val(idx_method, 2, idx_overlap) = R;
            PRF_val(idx_method, 3, idx_overlap) = F;
        end
    end
    save([num2str(dsi),'-PRF_val.mat'], 'PRF_val');
end

% save PRF_val.mat PRF_val