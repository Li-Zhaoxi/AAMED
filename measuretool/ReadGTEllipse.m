function [gt_elps, gt_size] = ReadGTEllipse(gt_path, img_path, imgname)
% 读取数据集中真实结果

imgnum = length(imgname);
gt_elps = cell(1, imgnum);
gt_size = zeros(imgnum,2);
for i = 1:imgnum
    img = imread([img_path,imgname{i}]);
    gt_size(i,1) = size(img,1); gt_size(i,2) = size(img,2);
    fid_gt = fopen([gt_path,imgname{i},'.txt'],'r');
    if fid_gt == -1
        error('gt file error');
    end
    str = fgetl(fid_gt);
    elp_num = str2double(str);
    elp_data = zeros(elp_num,5);
    for j = 1:elp_num
        str = fgetl(fid_gt);
        elp_data(j,:) = str2num(str);
        
        elp_data(j,5) = -elp_data(j,5)/180*pi;
        %elp_data(j,5) = -elp_data(j,5);
    end
    gt_elps{i}=elp_data;
    fclose(fid_gt);
end
end