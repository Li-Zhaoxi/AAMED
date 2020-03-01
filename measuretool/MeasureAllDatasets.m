clc;clear;close all;
% Ellipse Measure Tool. Update: 16/12/2018

addpath MeasureTools

data_root_path = 'E:\aamed_ellipse_datasets\'; 

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

methods_name = 'AAMED';
method_label = 'aamed';

ellipse_result = cell(1, length(dataset_name));

for dsi = [1,2,6,7,3,4,5,8,9]
    disp(['Evaluating dataset: ',dataset_name{dsi}]);
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
    
    %% Read ground truth
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
    %% Read detection results.
    [dt_elps, dt_time] = Read_Ellipse_Results([dirpath,methods_name,'\'], ...
        imgname, method_label);
    
    
    pos_num = zeros(1,imgnum);  pos_elp = cell(1, imgnum); 
    det_num = zeros(1,imgnum);  det_elp = cell(1,imgnum); 
    gt_num = zeros(1,imgnum);   gt_elp = cell(1, imgnum);  
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
        num_true_elp = sum(gt_match > 0);
        num_det_true_elp = sum(det_match > 0);
        pos_num(i) = num_true_elp;
        det_num(i) = num_true_elp + num_false_elp + max([num_det_true_elp - num_true_elp, 0]);
        gt_num(i) = num_true_elp + num_loss_elp;
    end

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
    ellipse_result{dsi}.pos_all = pos_all;
    ellipse_result{dsi}.det_all = det_all;
    ellipse_result{dsi}.gt_all = gt_all;
    ellipse_result{dsi}.P = P;
    ellipse_result{dsi}.R = R;
    ellipse_result{dsi}.F = F;
    ellipse_result{dsi}.avgtime = mean(dt_time);
end

save([methods_name,'-results.mat'],'ellipse_result');