clc;clear;close all;
% 椭圆验证程序，更新：2018-12-16
%

% addpath MeasureTools;
addpath F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\FLED验证准则\MeasureTools
% try
%     parpool('local', 4);
% catch
%     warning('并行可能已开启');
% end

data_root_path = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset\';

dataset_name = [{'Synthetic Images - Occluded Ellipses'},...
    {'Synthetic Images - Overlap Ellipses'},...
    {'Prasad Images - Dataset Prasad'},...
    {'Random Images - Dataset #1'},...
    {'Smartphone Images - Dataset #2'},...
    {'Concentric Ellipses - Dataset Synthetic'},...
    {'Concurrent Ellipses - Dataset Synthetic'},...
    {'Satellite Images - Dataset Meng #1'},...
    {'Satellite Images - Dataset Meng #2'}];

gt_label = [{'occluded'},{'overlap'},{'prasad'},{'random'},{'smartphone'},...
    {'concentric'},{'concurrent'},{'satellite1'}, {'satellite2'}];

methods_name = 'FLED';
method_label = 'fled';

ellipse_result = cell(1, length(dataset_name));

for dsi = [4]%length(dataset_name)
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
%     imgnum = 242;
%     imgname = imgname(1:242);
    dirpath = [data_root_path,dataset_name{dsi},'\'];
    
    %% 读取椭圆ground truth
    if strcmp(gt_label{dsi},'occluded') || strcmp(gt_label{dsi},'overlap') || ...
            strcmp(gt_label{dsi},'concentric') || strcmp(gt_label{dsi},'concurrent') % 仿真数据集
        [gt_elps, gt_size] = Read_Ellipse_GT([dirpath,'gt\'], ...
            [dirpath,'images\'], imgname, gt_label{dsi});
        T_overlap = 0.90;
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
    
    %% 读取椭圆检测结果..
    [dt_elps, dt_time] = Read_Ellipse_Results([dirpath,methods_name,'\'], ...
        imgname, method_label);
    
    pos_num = zeros(1,imgnum); % 有效椭圆个数
    pos_elp = cell(1, imgnum); % 有效椭圆参数，最后一个是角标
    
    det_num = zeros(1,imgnum); % 检测出的椭圆个数
    det_elp = cell(1,imgnum); % 存储无效椭圆个数，最后一个是角标
    
    gt_num = zeros(1,imgnum);  % 真实椭圆个数
    gt_elp = cell(1, imgnum);  % 存储未检测
    for i = 1:imgnum
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
        
        % 触发det匹配个数大于gt个数问题，选择最优匹配，剩下的作为false ellipse
        
        %         if num_det_true_elp > num_true_elp
        %             idx_gt = find(gt_match > 0);
        %             idx_det = find(det_match > 0);
        %
        %             gt_select = cell(1, length(idx_gt));
        %             for gidx = 1:length(gt_select)
        %                 idx_tmp = find(res(:, idx_gt(gidx)) > 0);
        %                 gt_select{gidx} = [elps_overlap(idx_tmp,idx_gt(gidx)), idx_tmp(:)];
        %                 gt_select{gidx} = sortrows(gt_select{gidx},1);
        %             end
        %
        %             % 选择最大overlap的作为最终真值，其余全部作为false ellipse
        %
        %         end
        
        
        % 统计有效椭圆个数，检测个数，与真实个数
        pos_num(i) = num_true_elp;
        det_num(i) = num_true_elp + num_false_elp + max([num_det_true_elp - num_true_elp, 0]);
        gt_num(i) = num_true_elp + num_loss_elp;
        
%         % 统计检测情况
%         idx_pos_match = find(det_match > 0);
%         if ~isempty(idx_pos_match)
%             pos_elp{i} = [detected_ellipses(idx_pos_match, :), idx_pos_match(:)];
%         end
%         idx_false_elp = find(det_match == 0);
%         if ~isempty(idx_false_elp)
%             det_elp{i} = [detected_ellipses(idx_false_elp,:), idx_false_elp(:)];
%         end
%         idx_loss_elp = find(gt_match == 0);
%         if ~isempty(idx_loss_elp)
%             gt_elp{i} = [gt_ellipses(idx_loss_elp,:), idx_loss_elp(:)];
%         end
        
    end
    
%     idx = (pos_num ==0);
%     idx(1:2:end) = 0;
%     pos_num(idx) = [];
%     det_num(idx) = [];
%     gt_num(idx) = [];
    
    pos_all = sum(pos_num);
    det_all = sum(det_num);
    gt_all = sum(gt_num);
    
    P = pos_all / det_all;
    R = pos_all / gt_all;
    F = 2 * P * R / (P + R);
    
    disp(['Precision: ',num2str(P*100),'%,  Recall: ',...
        num2str(R*100),'%,  F-measure: ',num2str(F*100),'%. ']);
    disp(['Average detected time: ', num2str(mean(dt_time)), ' ms.']);
    
    ellipse_result{dsi}.ds_name = dataset_name(dsi);
    ellipse_result{dsi}.method = methods_name;
    
%     ellipse_result{dsi}.pos_elp = pos_elp;
%     ellipse_result{dsi}.det_elp = det_elp;
%     ellipse_result{dsi}.gt_elp = gt_elp;
    
    ellipse_result{dsi}.pos_all = pos_all;
    ellipse_result{dsi}.det_all = det_all;
    ellipse_result{dsi}.gt_all = gt_all;
    ellipse_result{dsi}.P = P;
    ellipse_result{dsi}.R = R;
    ellipse_result{dsi}.F = F;
    ellipse_result{dsi}.avgtime = mean(dt_time);
    
end

save([methods_name,'-results.mat'],'ellipse_result');