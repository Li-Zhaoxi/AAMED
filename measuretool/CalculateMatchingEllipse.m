function [N_truth, N_all, N_positive] = CalculateMatchingEllipse(det_elp, gt_elp)

N_truth = size(gt_elp,1);
N_all = size(det_elp,1);
N_positive = 0;
isMatched = zeros(1,N_all);

for i = 1:N_truth
    r_gt = max(gt_elp(i,3:4));
    
    loc_gt = [floor(gt_elp(i,1) - r_gt), ceil(gt_elp(i,1) + r_gt), ...
        floor(gt_elp(i,2) - r_gt), ceil(gt_elp(i,2) + r_gt)];
    
    gt_data = zeros(xg_max - xg_min + 1, yg_max - yg_min + 1);
    
    
    for j = 1:N_all
        if isMatched(j)
            continue;
        end
        r_det = max(det_elp(i,3:4));
        n = det_elp(j,1:2)-gt_elp(i,1:2);
        if r_gt + r_det < norm(n) % 如果相聚较远直接抛弃
            continue;
        end
        ration = CalculateOverlap(det_elp(j),gt_elp(i));
        if ration >0.8
           match_num = match_num + 1; 
           isMatched(j) = 1;
        end
    end
    if match_num >= 1
        N_all = N_all - match_num + 1;
        N_positive = N_positive + 1;
    end
    
    
end


end