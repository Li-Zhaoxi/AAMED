function [P,R,F] = AAMEDMeasureEllipseFun(data_root_path, dataset_name,...
    gt_label, methods_name, method_label)

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
if strcmp(gt_label,'occluded') || strcmp(gt_label,'overlap')
    [gt_elps, ~] = Read_Ellipse_GT([dirpath,'gt\'], ...
        [dirpath,'images\'], imgname, gt_label);
    T_overlap = 0.95;
else
    [gt_elps, ~] = Read_Ellipse_GT([dirpath,'gt\gt_'], ...
        [dirpath,'images\'], imgname, gt_label);
    T_overlap = 0.8;
end


[dt_elps, ~] = Read_Ellipse_Results([dirpath,methods_name,'\'], ...
    imgname, method_label);

Pos = 0; detN = 0; gtN = 0;
use_res = dt_elps;

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



end