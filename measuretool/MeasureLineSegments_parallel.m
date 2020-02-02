clc;clear all;close all;
% 多核计算直线验证准则

dirpath = 'E:\迅雷下载\YorkUrbanDB\'; % Data set path

%% Read the ground-truth line segment data
[gt_lines, gt_size, imgname] = Read_GT_Lines_YorkUrbanDB(dirpath);

%% Read the det line segment data
% [det_lines, ~] = Read_GT_Lines_YorkUrbanDB(dirpath);

%% Read the det line segment by LSD method
[dt_lines_lsd, detTime_lsd] = Read_LSD_Line_Results([dirpath, 'LSD\'], imgname);





imgnum = length(gt_lines);

N_length_single = zeros(1,imgnum);
P_length_single = zeros(1,imgnum);
R_num_single = zeros(1, imgnum);
R_P_num_single = zeros(1, imgnum);
C_num_single = zeros(1, imgnum);

matlabpool local 4

parfor i = 1:imgnum
    disp(['正在验证第',num2str(i),'张直线数据图']);
    img_gt_linenum = size(gt_lines{i},1);
    
    n1 = gt_lines{i}(:,1:2); n2 = gt_lines{i}(:,3:4); n12 = n2-n1;
    N_length_single(i) =  sum(sqrt(n12(:,1).^2 + n12(:,2).^2));
    R_num_single(i) = size(gt_lines{i},1);
    
    
    for j = 1:img_gt_linenum
%         disp(['>>>>>>>>>>正在验证第', num2str(j), '条直线段']);
        [ration, coverlines] = CalculateLinePrecisionAndContinuity(gt_lines{i}(j,:), gt_lines{i}); % ration = [精度，连续度]
        if ration(1) > 0.5
            n1 = coverlines(:,2:3); n2 = coverlines(:,4:5); n12 = n2-n1;
            P_length_single(i) = sum(sqrt(n12(:,1).^2 + n12(:,2).^2));
            R_P_num_single(i) = 1;
            C_num_single(i) = ration(2);
        end
        
    end
%     disp('************************************************')
end
matlabpool close

N_length = sum(N_length_single);
P_length = sum(P_length_single);
R_num = sum(R_num_single);
R_P_num = sum(R_P_num_single);
C_num = sum(C_num_single);


P = P_length/N_length;
R = R_P_num / R_num;
C = C_num / R_P_num;
F = 1/(0.2/P + 0.4/R + 0.4/C);
disp(['Precision: ', num2str(P*100),'%, Recall: ', num2str(R*100), '%, Continuity: ', num2str(C*100), '%, F-measure: ', num2str(F*100),'%.']);


% figure;
% idx = 1;
% img_size = gt_size(idx,:);
% img = ones(img_size(1), img_size(2));
% imshow(img); hold on;
% det_linet = dt_lines_lsd{idx};
% gt_linest = gt_lines{idx};
% 
% for i = 1:size(gt_linest,1)
%    plot([gt_linest(i,1), gt_linest(i,3)], [gt_linest(i,2), gt_linest(i,4)],'-b') ;
% end
% for i = 1:size(det_linet,1)
%    plot([det_linet(i,1), det_linet(i,3)], [det_linet(i,2), det_linet(i,4)],'-r') ;
% end
