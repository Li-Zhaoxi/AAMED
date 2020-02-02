function [P,R,F] = MeasureEllipsesFun_4_19(dirpath, dataset, T_overlap)

%% Read the image name list 'imagenames.txt', the list is got by 'getImagesName.bat'
fid = fopen([dirpath,'imagenames.txt'],'r');
imgnum = 0;
while feof(fid) == 0
    imgnum = imgnum + 1;
    imgname{imgnum} = fgetl(fid);
end
fclose(fid);

%% Read the ground-truth ellipse data
[gt_elps] = Read_Ellipse_GT([dirpath,'gt\gt_'], [dirpath,'images\'], imgname, dataset);

%% Read the detected ellipse by FLED methods
[dt_elps, dt_time] = Read_Ellipse_Results([dirpath,'AMED\'], imgname, 'aamed');


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


end