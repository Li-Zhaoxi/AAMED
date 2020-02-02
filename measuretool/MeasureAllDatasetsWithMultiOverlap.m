clc;clear;close all;
% 针对不同的重叠度计算所有数据集，直接获得所有的PRF值

data_root_path = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset\';

dataset_name = [{'Synthetic Images - Occluded Ellipses'},...
    {'Synthetic Images - Overlap Ellipses'},...
    {'Prasad Images - Dataset Prasad'},...
    {'Random Images - Dataset #1'},...
    {'Smartphone Images - Dataset #2'}];

gt_label = [{'occluded'},{'overlap'},{'prasad'},{'random'},{'smartphone'}];

methods_name = 'FLED';
method_label = 'fled';

T_overlaps = 0:0.02:1; T_overlap(1) = 0.01; T_overlap(end) = 0.99;
PT = zeros(length(T_overlaps),5);
RT = zeros(length(T_overlaps),5);
FT = zeros(length(T_overlaps),5);

%% Step 0: 初始化并行工具
try
    parpool('local',4)
catch
    warning('并行已开启');
end
%% 进行多种重叠度计算
parfor ti = 1:length(T_overlaps)
    
    disp(['正在处理重叠度：', num2str(T_overlaps(ti))]);
    
    gt_label = [{'occluded'},{'overlap'},{'prasad'},{'random'},{'smartphone'}];
    
    PT_t = zeros(1, length(gt_label));
    RT_t = zeros(1, length(gt_label));
    FT_t = zeros(1, length(gt_label));
    for dsi = 3:length(dataset_name)
        %disp(['正在评价数据集: ',dataset_name{dsi}]);
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
            T_overlap = T_overlaps(ti);
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
            for p = 1:elpnum_gt
                elp_gt = gt_elps{i}(p,:);
                for q = 1:elpnum_det
                    elp_det = use_res{i}(q,:);
                    [ration, ~] = mexCalculateOverlap(elp_gt,elp_det);
                    if ration > T_overlap
                        Pos = Pos + 1;
                        Pos_each(i) = Pos_each(i) + 1;
                        dt_match_num(q) = dt_match_num(q) + 1;
                        break;
                    end
                end
            end
            %         disp(num2str(Pos));
            idx = find(dt_match_num>2);
            more_det = sum(dt_match_num(idx)) - length(idx);
            detN = detN + more_det;
            detN_each(i) = detN_each(i) + more_det;
        end
        
        P = Pos/detN;
        R = Pos/gtN;
        beta = 1;
        F = (beta^2+1)*P*R/(beta*P+R);
%         disp(['Precision:',num2str(P*100),'%,  Recall:',...
%             num2str(R*100),'%,  F-measure:',num2str(F*100),'%.']);
        
        PT_t(1,dsi) = P;
        RT_t(1,dsi) = R;
        FT_t(1,dsi) = F;
        %     mean(dt_time)
    end
    
    PT(ti,:) = PT_t;
    RT(ti,:) = RT_t;
    FT(ti,:) = FT_t;
end

save([method_label,'-multioverlap.mat'],'PT','RT','FT');