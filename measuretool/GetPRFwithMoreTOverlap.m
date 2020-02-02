clc;clear;close all;
% 一个算法的不同椭圆重叠度对应的PRF值
% 每一行代表一个算法的变化程度
data_root_path = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset\';

dataset_name = [{'Synthetic Images - Occluded Ellipses'},...
    {'Synthetic Images - Overlap Ellipses'},...
    {'Prasad Images - Dataset Prasad'},...
    {'Random Images - Dataset #1'},...
    {'Smartphone Images - Dataset #2'}];

gt_label = [{'occluded'},{'overlap'},{'prasad'},{'random'},{'smartphone'}];

methods_name = 'FLED';
method_label = 'fled';
% 只有在进行训练参数的时候，才会保存为AMED


T_overlaps = 0.00:0.05:1.00;
T_overlaps(1) = 0.01; T_overlaps(end) = 0.99;


P_overlap  = zeros(length(dataset_name), length(T_overlaps));
R_overlap  = zeros(length(dataset_name), length(T_overlaps));
F_overlap  = zeros(length(dataset_name), length(T_overlaps));

for dsi = 1:length(dataset_name)
    clc;
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
    else
        [gt_elps, gt_size] = Read_Ellipse_GT([dirpath,'gt\gt_'], ...
            [dirpath,'images\'], imgname, gt_label{dsi});
    end
    
    [dt_elps, dt_time] = Read_Ellipse_Results([dirpath,methods_name,'\'], ...
        imgname, method_label);
    
    for t = 1:length(T_overlaps)
        Pos = 0; detN = 0; gtN = 0;
        use_res = dt_elps;
        
        T_overlap = T_overlaps(t);
        
        for i = 1:imgnum
            elpnum_det = size(use_res{i},1);
            elpnum_gt = size(gt_elps{i},1);
            
            detN = detN + elpnum_det;
            gtN = gtN + elpnum_gt;

            dt_match_num = zeros(1, elpnum_det);
            for p = 1:elpnum_gt
                elp_gt = gt_elps{i}(p,:);
                for q = 1:elpnum_det
                    elp_det = use_res{i}(q,:);
                    [ration, ~] = mexCalculateOverlap(elp_gt,elp_det);
                    if ration > T_overlap
                        Pos = Pos + 1;
                        dt_match_num(q) = dt_match_num(q) + 1;
                        break;
                    end
                end
            end
            
            idx = find(dt_match_num>2);
            more_det = sum(dt_match_num(idx)) - length(idx);
            detN = detN + more_det;
            
        end
        
        P = Pos/detN;
        R = Pos/gtN;
        beta = 1;
        F = (beta^2+1)*P*R/(beta*P+R);
        disp(['Precision:',num2str(P*100),'%,  Recall:',...
            num2str(R*100),'%,  F-measure:',num2str(F*100),'%.']);
        
        
        P_overlap(dsi, t) = P*100;
        R_overlap(dsi, t) = R*100;
        F_overlap(dsi, t) = F*100;
    end
    
    
end

save([methods_name,'.mat'],'P_overlap','R_overlap','F_overlap');
