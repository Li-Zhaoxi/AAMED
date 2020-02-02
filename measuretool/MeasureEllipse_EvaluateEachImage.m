clc;clear all;close all;
dirpath = 'G:\ellipse_dataset\Smartphone Images - Dataset #2\'; % Data set path
%% Read the image name list 'imagenames.txt', the list is got by 'getImagesName.bat'
fid = fopen([dirpath,'imagenames.txt'],'r');
imgnum = 0;
while feof(fid) == 0
    imgnum = imgnum + 1;
    imgname{imgnum} = fgetl(fid);
end
fclose(fid);

%% Read the ground-truth ellipse data
% [gt_elps, gt_size] = ReadGTEllipse([dirpath,'gt\gt_'], [dirpath,'images\'], imgname);
% [gt_elps, gt_size] = Read_GT_Oils_Ellipse([dirpath,'gt\'], [dirpath,'images\'], imgname);
[gt_elps, gt_size] = Read_Ellipse_GT([dirpath,'gt\gt_'], [dirpath,'images\'], imgname, 'smartphone');


%% Read the detected ellipse by FLED methods
[dt_elps, dt_time] = Read_Ellipse_Results([dirpath,'FLED\'], imgname, 'fled');



%% Get the Precision and Recall for each image.
Precision = zeros(1, imgnum);
Recall = zeros(1, imgnum);
use_res = dt_elps;
for i = 1:imgnum
    Pos = 0;
    detN = 0;
    gtN = 0;
    disp(['正在验证第',num2str(i),'张图片：', imgname{i}]);
    elpnum_det = size(use_res{i},1);
    elpnum_gt = size(gt_elps{i},1);
    detN = detN + elpnum_det;
    gtN = gtN + elpnum_gt;
    
    for p = 1:elpnum_gt
        elp_gt = gt_elps{i}(p,:);
        for q = 1:elpnum_det
            elp_det = use_res{i}(q,:);
            [ration, ~] = CalculateOverlap(elp_gt,elp_det);
            if ration >0.75
                Pos = Pos + 1;
                break;
            end
        end
    end
    if detN ==0
        Precision(i) = 0;
    else
        Precision(i) = Pos/detN;
    end
    
    if gtN ==0
        Recall(i)=1;
    else
        Recall(i) = Pos/gtN;
    end
    
end

avgP = mean(Precision);
avgR = mean(Recall);

F = 2*avgP*avgR/(avgP+avgR);
disp(['Precision:',num2str(avgP*100),'%,  Recall:',num2str(avgR*100),'%,  F-measure:',num2str(F*100),'%.']);
