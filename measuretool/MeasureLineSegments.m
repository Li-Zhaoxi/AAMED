clc;clear all;close all;
% 直线结果验证准则，衡量标准有三个指标：精度，召回率，连续度。

dirpath = 'E:\迅雷下载\YorkUrbanDB\'; % Data set path

%% Read the ground-truth line segment data
 [gt_lines, gt_size, imgname] = Read_GT_Lines_YorkUrbanDB(dirpath);

%% Read the det line segment data
% [det_lines, ~] = Read_GT_Lines_YorkUrbanDB(dirpath);
% [gt_lines, gt_size, imgname] = Read_Lines_GroundTruth(dirpath, 'prasad');
%% Read the det line segment by LSD method
% [dt_lines_lsd, detTime_lsd] = Read_LSD_Line_Results([dirpath, 'LSD\'], imgname);

%% Read the det line segment by UpWrite method
 [dt_lines_lsd, detTime_lsd] = Read_LSD_Line_Results([dirpath, 'LSD\'], imgname);

%% Read the FLED line segment result.
%[dt_lines_fled, dt_time_fled] = Read_Lines_Results([dirpath,'FLED\'], imgname, 'fled');

% imgnum = length(gt_lines);
% 
% N_length = 0; P_length = 0;
% R_num = 0; R_P_num = 0;
% C_num = 0;
% for i = 1:imgnum
%     disp(['正在验证第',num2str(i),'张直线数据图']);
%     img_gt_linenum = size(gt_lines{i},1);
%     
%     n1 = gt_lines{i}(:,1:2); n2 = gt_lines{i}(:,3:4); n12 = n2-n1;
%     N_length =  N_length + sum(sqrt(n12(:,1).^2 + n12(:,2).^2));
%     R_num = R_num + size(gt_lines{i},1);
%     
%     
%     for j = 1:img_gt_linenum
% %         disp(['>>>>>>>>>>正在验证第', num2str(j), '条直线段']);
%         [ration, coverlines] = CalculateLinePrecisionAndContinuity(gt_lines{i}(j,:), gt_lines{i}); % ration = [精度，连续度]
%         
%         
%         if ration(1) > 0.5
%             n1 = coverlines(:,2:3); n2 = coverlines(:,4:5); n12 = n2-n1;
%             P_length =  P_length + sum(sqrt(n12(:,1).^2 + n12(:,2).^2));
%             R_P_num = R_P_num +1;
%             C_num = C_num + ration(2);
%         end
%         
%     end
% %     disp('************************************************')
% end
% 
% P = P_length/N_length;
% R = R_P_num / R_num;
% C = C_num / R_P_num;
% F = 1/(0.2/P + 0.4/R + 0.4/C);
% disp(['Precision: ', num2str(P*100),'%, Recall: ', num2str(R*100), '%, Continuity: ', num2str(C*100), '%, F-measure: ', num2str(F*100),'%.']);


figure;
idx = 1
% img_size = gt_size(idx,:);
% img = ones(img_size(1), img_size(2));
% imshow(img); 
img = imread('Canny.png');
img = 255 - (255-img)/3;
imshow(img);
hold on;
% det_linet = dt_lines_fled{idx};
gt_linest = dt_lines_lsd{idx};

for i = 1:size(gt_linest,1)
   plot([gt_linest(i,1), gt_linest(i,3)], [gt_linest(i,2), gt_linest(i,4)],'-k', 'linewidth',2) ;
end
% for i = 1:size(det_linet,1)
%    plot([det_linet(i,1), det_linet(i,3)], [det_linet(i,2), det_linet(i,4)],'-r') ;
% end




