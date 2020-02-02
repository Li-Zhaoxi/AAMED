clc;clear;close all;
% 将Prasad数据集格式统一
dirpath = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset\Prasad Images - Dataset Prasad\'; % Data set path

%% Read the image name list 'imagenames.txt', the list is got by 'getImagesName.bat'
fid = fopen([dirpath,'imagenames.txt'],'r');
imgnum = 0;
while feof(fid) == 0
    imgnum = imgnum + 1;
    imgname{imgnum} = fgetl(fid);
end
fclose(fid);


[gt_elps, gt_size] = Read_Ellipse_GT([dirpath,'gt\gt_'], [dirpath,'images\'], imgname, 'prasad'); save gt.mat gt_elps gt_size

%New Prasad GT
for i = 1 : imgnum
    fid = fopen(['New Prasad GT\gt_',imgname{i},'.txt'],'w');
    gt = gt_elps{i};
    fprintf(fid,'%d\n',size(gt,1));
    for j = 1:size(gt,1)
         fprintf(fid,'%f\t%f\t%f\t%f\t%f\n',gt(j,1),gt(j,2),gt(j,3),gt(j,4),gt(j,5)/pi*180);
    end
    fclose(fid);
end


