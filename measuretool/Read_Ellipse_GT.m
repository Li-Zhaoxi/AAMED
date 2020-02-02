function [gt_elps, varargout] = Read_Ellipse_GT(gt_path, img_path, imgname, dataset)

imgnum = length(imgname);
gt_elps = cell(1, imgnum);
gt_size = zeros(imgnum,2);

if nargout == 1
    get_size = 0;
else
    get_size = 1;
end

if strcmp(dataset, 'prasad')
    for i = 1:imgnum
        
        if get_size  == 1
            img = imread([img_path,imgname{i}]);
            gt_size(i,1) = size(img,1); gt_size(i,2) = size(img,2);
        end
        
        
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
        end
%         elp_data(:,3:4) = elp_data(:,3:4) +1;
        gt_elps{i}=elp_data;
        fclose(fid_gt);
    end
    
    
    if get_size == 1
        varargout{1} = gt_size;
    end
    
    return;
end

if strcmp(dataset, 'random') || strcmp(dataset, 'smartphone') || strcmp(dataset, 'training')
    for i = 1:imgnum
        
        if get_size  == 1
            img = imread([img_path,imgname{i}]);
            gt_size(i,1) = size(img,1); gt_size(i,2) = size(img,2);
        end
        
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
        end
        
        elp_data(:,1:2)=elp_data(:,1:2)+1; % 设置图像角标从1开始
        
        elp_data(:,5) = elp_data(:,5)/180*pi;
        gt_elps{i}=elp_data;
        fclose(fid_gt);
    end
    
    if get_size == 1
        varargout{1} = gt_size;
    end
    
    
    
    
    return;
end


if strcmp(dataset, 'overlap') || strcmp(dataset, 'occluded') || ...
        strcmp(dataset, 'occludedwithmultilines') || strcmp(dataset, 'overlapwithmultilines')
    
    for i = 1:imgnum
        if get_size  == 1
            img = imread([img_path,imgname{i}]);
            gt_size(i,1) = size(img,1); gt_size(i,2) = size(img,2);
        end
        
        gt = load([gt_path,imgname{i}(1:end-4), '.mat']);
        gt_elp = gt.ellipse_param';
        gt_elp(:,5) = gt_elp(:,5)/180*pi;
        
        temp = gt_elp(:,1); gt_elp(:,1) = gt_elp(:,2); gt_elp(:,2) = temp;
        temp = gt_elp(:,3); gt_elp(:,3) = gt_elp(:,4); gt_elp(:,4) = temp;
        temp = pi/2 - gt_elp(:,5);
        gt_elp(:,5) =  temp;
        
        gt_elps{i}=gt_elp;
    end
    
    
    if get_size == 1
        varargout{1} = gt_size;
    end
    
    return;
end


if strcmp(dataset, 'concentric') || strcmp(dataset, 'concurrent')
    
    for i = 1:imgnum
        
        if get_size  == 1
            img = imread([img_path,imgname{i}]);
            gt_size(i,1) = size(img,1); gt_size(i,2) = size(img,2);
        end
        
        fid_gt = fopen([gt_path,imgname{i},'.txt'],'r');
        if fid_gt == -1
            error('gt file error');
        end
        str = fgetl(fid_gt);
        elp_num = str2double(str);
        elp_data = zeros(elp_num,5);
        for j = 1:elp_num
            str = fgetl(fid_gt);
            tmp = str2num(str);
            elp_data(j,:) = [tmp(2), tmp(1), tmp(4), tmp(3), -tmp(5)/180*pi];
        end
        gt_elps{i}=elp_data;
        fclose(fid_gt);
    end
    
    if get_size == 1
        varargout{1} = gt_size;
    end
    return;
    
end



if strcmp(dataset, 'axisratiowithorientation') || strcmp(dataset, 'semimajorwithaxisratio')
    
    for i = 1:imgnum
        
        if get_size  == 1
            img = imread([img_path,imgname{i}]);
            gt_size(i,1) = size(img,1); gt_size(i,2) = size(img,2);
        end
        
        fid_gt = fopen([gt_path,imgname{i},'.txt'],'r');
        if fid_gt == -1
            error('gt file error');
        end
        str = fgetl(fid_gt);
        elp_num = str2double(str);
        elp_data = zeros(elp_num,5);
        for j = 1:elp_num
            str = fgetl(fid_gt);
            tmp = str2num(str);
            elp_data(j,:) = [tmp(2), tmp(1), tmp(4), tmp(3), -tmp(5)];
        end
        gt_elps{i}=elp_data;
        fclose(fid_gt);
    end
    
    if get_size == 1
        varargout{1} = gt_size;
    end
    return;
    
end

if strcmp(dataset, 'satellite1') || strcmp(dataset, 'satellite2') || strcmp(dataset, 'industrial') 
    A = load([gt_path(1:end-3),'gt.mat']);
    gt_elps = A.gts;
    
    
    if get_size == 1
        varargout{1} = 0;
    end
    return;
end

error(['不存在当前数据集：', dataset]);




end