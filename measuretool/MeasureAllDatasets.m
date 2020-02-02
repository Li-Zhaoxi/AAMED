clc;clear;close all;
% 计算所有数据集，直接获得所有的PRF值

data_root_path = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset\';

dataset_name = [{'Synthetic Images - Occluded Ellipses'},...
    {'Synthetic Images - Overlap Ellipses'},...
    {'Prasad Images - Dataset Prasad'},...
    {'Random Images - Dataset #1'},...
    {'Smartphone Images - Dataset #2'}];

gt_label = [{'occluded'},{'overlap'},{'prasad'},{'random'},{'smartphone'}];

methods_name = 'TDED';
method_label = 'tded';
for dsi = 5;%length(dataset_name)
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
    
    if strcmp(gt_label{dsi},'occluded') || strcmp(gt_label{dsi},'overlap')
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
    
    [dt_elps, dt_time] = Read_Ellipse_Results([dirpath,methods_name,'\'], ...
        imgname, method_label);
    
    
    Pos = 0; detN = 0; gtN = 0;
    use_res = dt_elps;
    Pos_each = zeros(1,imgnum);
    detN_each = zeros(1,imgnum);
    gtN_each = zeros(1,imgnum);
    for i = 1:imgnum
        elpnum_det = size(use_res{i},1);
        elpnum_gt = size(gt_elps{i},1);
        
        detN = detN + elpnum_det;
        gtN = gtN + elpnum_gt;
        
        detN_each(i) = elpnum_det;
        gtN_each(i) = elpnum_gt;
        
        dt_match_num = zeros(1, elpnum_det);
        gt_multi_use = zeros(1, elpnum_gt);
        for p = 1:elpnum_gt
            elp_gt = gt_elps{i}(p,:);
            for q = 1:elpnum_det
                elp_det = use_res{i}(q,:);
                [ration, ~] = mexCalculateOverlap(elp_gt,elp_det);
                if ration > T_overlap
                    Pos = Pos + 1;
                    
                    dt_match_num(q) = dt_match_num(q) + 1;
                    gt_multi_use(p) = gt_multi_use(p) + 1;
%                     break;
                end
            end
        end
        
        idx = find(dt_match_num>=2);
        more_det = sum(dt_match_num(idx)) - length(idx);
        detN = detN + more_det;
        
        idx = find(gt_multi_use>=2);
        more_gt = sum(gt_multi_use(idx)) - length(idx);
        gtN = gtN + more_gt;
        %disp(num2str([Pos,detN,gtN]));
    end
    
    P = Pos/detN;
    R = Pos/gtN;
    beta = 1;
    F = (beta^2+1)*P*R/(beta*P+R);
    disp(['Precision:',num2str(P*100),'%,  Recall:',...
        num2str(R*100),'%,  F-measure:',num2str(F*100),'%.']);
    
    mean(dt_time)
end

% 
% Pos
% detN
% gtN