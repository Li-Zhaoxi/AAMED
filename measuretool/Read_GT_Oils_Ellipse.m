function [gt_elps, gt_size] = Read_GT_Oils_Ellipse(gt_path, img_path, imgname)


imgnum = length(imgname);
gt_elps = cell(1, imgnum);
gt_size = zeros(imgnum,2);
for i = 1:imgnum
    img = imread([img_path,imgname{i}]);
    gt_size(i,1) = size(img,1); gt_size(i,2) = size(img,2);
    fid_gt = fopen([gt_path,imgname{i}(1:end-4),'.txt'],'r');
    if fid_gt == -1
        error('gt file error');
    end
    
    elp_data = []; elpnum = 0;
    while feof(fid_gt) == 0
        elpnum = elpnum + 1;
        elp_data(elpnum,:) = str2num(fgetl(fid_gt));
    end
    
    x = (elp_data(:,2)+elp_data(:,4))/2;
    y = (elp_data(:,3)+elp_data(:,5))/2;
    w = abs(elp_data(:,2)-elp_data(:,4))/2;
    h = abs(elp_data(:,3)-elp_data(:,5))/2;
    
    gt_elps{i}=[x,y,w,h,zeros(size(x))];
    fclose(fid_gt);
end






end