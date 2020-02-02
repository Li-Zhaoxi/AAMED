clc;clear all;close all;

% Precision:74.4681%,  Recall:30.0172%,  F-measure:42.7873%.

dirpath = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset\Random Images - Dataset #1\'; % Data set path
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
% [gt_elps, gt_size] = Read_GT_Oils_Ellipse([dirpath,'gt\'], [dirpath,'images\'], imgname); save gt.mat gt_elps gt_size
 [gt_elps, gt_size] = Read_Ellipse_GT([dirpath,'gt\gt_'], [dirpath,'images\'], imgname, 'random'); save gt.mat gt_elps gt_size
% [gt_elps, gt_size] = Read_Ellipse_GT([dirpath,'gt\'], [dirpath,'images\'], imgname, 'occluded'); save gt.mat gt_elps gt_size

%% Read the detected ellipse by FLED methods
% [dt_elps, dt_time] = Read_Ellipse_Results([dirpath,'FLED\'], imgname, 'fled'); save fled.mat dt_elps dt_time

%% Read the detected ellipse by Fornaciari methods
% [dt_elps_Fornaciari, detTime_Fornaciari] = Read_Fornaciari_Ellipse_Results([dirpath,'Fornaciari\'],imgname);
 [dt_elps, dt_time] = Read_Ellipse_Results([dirpath,'Fornaciari\'], imgname, 'yaed'); save yaed.mat dt_elps dt_time
%% Read the detected ellipse by Prasad methods.
% [dt_elps_prasad, detTime_prasad] =  Read_Prasad_Ellipse_Results([dirpath,'Prasad\'],imgname);
% [dt_elps, dt_time] = Read_Ellipse_Results([dirpath,'Prasad\'], imgname, 'prasad'); save prasad.mat dt_elps dt_time;
%% Read the detected ellipse by ELSD methods.
% [dt_elps, dt_time] = Read_ELSD_Ellipse_Results([dirpath,'ELSD\'], imgname); save elsd.mat dt_elps dt_time;

%% Read the detected ellipse y UpWrite methods.
% [dt_elps_upwrite, detTime_upwrite] = Read_UpWrite_Ellipse_Results([dirpath,'UpWrite\'],imgname);

% [dt_elps, dt_time] = Read_Ellipse_Results([dirpath,'CNED\'], imgname, 'cned'); save cned.mat dt_elps dt_time;
% [dt_elps, dt_time] = Read_Ellipse_Results([dirpath,'TDED\'], imgname, 'tded'); save cned.mat dt_elps dt_time;
% [dt_elps, dt_time] = Read_Ellipse_Results([dirpath,'TPED\'], imgname, 'tped'); save cned.mat dt_elps dt_time;
% [dt_elps, dt_time] = Read_Ellipse_Results([dirpath,'RTDED\'], imgname, 'rtded'); save rtded.mat dt_elps dt_time;
% [dt_elps, dt_time] = Read_Ellipse_Results([dirpath,'RCNED\'], imgname, 'rcned'); save rcned.mat dt_elps dt_time;
 
%% Calculate the Precision and Recall

Pos = 0; detN = 0; gtN = 0;
use_res = dt_elps;
Pos_each = zeros(1,imgnum);
detN_each = zeros(1,imgnum);
gtN_each = zeros(1,imgnum);
for i = 1:imgnum
    disp(['正在验证第',num2str(i),'张图片：', imgname{i}]);
    elpnum_det = size(use_res{i},1);
    elpnum_gt = size(gt_elps{i},1);
    
%     if elpnum_det == 0
%         continue;
%     end
    
    detN = detN + elpnum_det;
    gtN = gtN + elpnum_gt;
    
    detN_each(i) = elpnum_det;
    gtN_each(i) = elpnum_gt;

    
    
    dt_match_num = zeros(1, elpnum_det);
    for p = 1:elpnum_gt
        elp_gt = gt_elps{i}(p,:);
        for q = 1:elpnum_det
            elp_det = use_res{i}(q,:);
            [ration, ~] = CalculateOverlap(elp_gt,elp_det);
            if ration >0.8
               Pos = Pos + 1;
               Pos_each(i) = Pos_each(i) + 1;
               dt_match_num(q) = dt_match_num(q) + 1;
               break;
            end
        end
    end
    
    idx = find(dt_match_num>2);
    more_det = sum(dt_match_num(idx)) - length(idx);
    detN = detN + more_det;
    detN_each(i) = detN_each(i) + more_det;
    
    
end

P = Pos/detN;
R = Pos/gtN;
beta = 1;
F = (beta^2+1)*P*R/(beta*P+R);
disp(['Precision:',num2str(P*100),'%,  Recall:',num2str(R*100),'%,  F-measure:',num2str(F*100),'%.']);


% F_each = zeros(1,length(Pos_each));
% P_each = zeros(1,length(Pos_each));
% R_each = zeros(1,length(Pos_each));
% 
% for i = 1:length(Pos_each)
%    if gtN_each(i) == 0
%        P_each(i) = 1;
%        R_each(i) = 1;
%        F_each(i) = 1;
%    elseif detN_each(i) == 0 || Pos_each(i) == 0
%        P_each(i) = 0;
%        R_each(i) = 0;
%        F_each(i) = 0;
%    else
%        P = Pos_each(i)/detN_each(i);
%        R = Pos_each(i)/gtN_each(i);
%        F = 2*P*R/(P+R);
%        
%        P_each(i) = P;
%        R_each(i) = R;
%        F_each(i) = F;
%    end
% end



% figure;
% idx = 100
% imshow([dirpath,'images\',imgname{idx}]);
% img = imread([dirpath,'images\',imgname{idx}]);
% if length(size(img))>2
%     img=rgb2gray(img);
% end
% imshow(img);
% imshow('Canny.png');
% 
% hold on;
% 
% elp_gt = gt_elps{idx};
% elp_dt = gt_elps{idx};
% for i = 1:size(elp_gt,1)
%     [x,y] = GenerateElpData(elp_gt(i,:));
%     plot(x,y,'-r','linewidth',2);
%     text(x(1),y(1), num2str(i),'color','y');
% end
% figure;
% imshow(img);
% hold on;
% for i = 1:size(elp_dt,1)
%     [x,y] = GenerateElpData(elp_dt(i,:));
%     plot(x,y,'-r','linewidth',2);
%     text(x(1),y(1), num2str(i),'color','y');
% end
% 
% 
% 
% Pos = 0; detN = 0; gtN = 0;
% disp(['正在验证第',num2str(i),'张图片：', imgname{i}]);
% elpnum_det = size(elp_dt,1);
% elpnum_gt = size(elp_gt,1);
% detN = detN + elpnum_det;
% gtN = gtN + elpnum_gt;
% 
% for p = 1:elpnum_gt
%     elp_gtt = elp_gt(p,:);
%     for q = 1:elpnum_det
%         elp_dett = elp_dt(q,:);
%         [ration, ~] = CalculateOverlap(elp_gtt,elp_dett);
%         ration
%         if ration >0.75
%             Pos = Pos + 1;
%             break;
%         end
%     end
% end
% if detN == 0
%     P=0;
% else
%     P = Pos/detN;
% end
% R = Pos/gtN;
% beta = 1;
% F = (beta^2+1)*P*R/(beta*P+R);
% disp(['detected number:', num2str(detN),',  gt number:', num2str(gtN),',  truth number:', num2str(Pos)])
% disp(['Precision:',num2str(P*100),'%,  Recall:',num2str(R*100),'%,  F-measure:',num2str(F*100),'%.']);





% figure; hold on;
% pixnum = gt_size(:,1).*gt_size(:,2);
% pixnum = pixnum';
% [pixnums,idx] = sort(pixnum);
% detTime_fleds = detTime_fled(idx);
% detTime_Fornaciaris = detTime_Fornaciari(idx);
%
%
% plot(pixnums,detTime_fleds,'*r');
% plot(pixnums,detTime_Fornaciaris,'*b');
% plot(pixnums, ones(size(pixnums))*mean(detTime_fleds),'-r','linewidth',1.5);
% plot(pixnums, ones(size(pixnums))*mean(detTime_Fornaciaris),'-b','linewidth',1.5);
