function [dt_elps, dt_time, patch_gt_elps] = Read_Ellipse_Noise_Results(filepath, prefix, imgname, dataset_name, L_num, ...
    patch_imgnum, gt_elps)
% 读取噪声图像检测结果的函数

imgnum = length(imgname);
dt_elps = cell(1, imgnum);
dt_time = zeros(1,imgnum);
patch_gt_elps = cell(1, patch_imgnum);
if strcmp(dataset_name, 'fled') || strcmp(dataset_name, 'aamed')
    for i = 1:patch_imgnum
        fid_dt = fopen([filepath, prefix, num2str(i),'_line', num2str(L_num),'.png.fled.txt']);
        if fid_dt == -1
            error([dataset_name, ': wrong file path']);
        end
        elps_data = [];
        dt_time(i) = str2num(fgetl(fid_dt));
        while feof(fid_dt) == 0
            elp_datat = str2num(fgetl(fid_dt));
            if elp_datat(1) == 2
                continue;
            end
            elp_datat(1) = [];
            temp = elp_datat(1);
            elp_datat(1) = elp_datat(2);
            elp_datat(2) = temp;
            elp_datat(1:2) = elp_datat(1:2) + 1;
            elp_datat(3:4) = elp_datat(3:4)/2;
            elp_datat(5) = -elp_datat(5)/180*pi;
            
            elps_data = [elps_data; elp_datat];
        end
        dt_elps{i} = elps_data;
        fclose(fid_dt);
        % 查找对应的patch
        idx = find(strcmp(imgname, [prefix, num2str(i),'_line',num2str(L_num),'.png']));
        patch_gt_elps{i} = gt_elps{idx};
    end
    return;
end

if strcmp(dataset_name, 'yaed') || strcmp(dataset_name, 'cned')
    for i = 1:patch_imgnum
        fid_dt = fopen([filepath,prefix, num2str(i), '_line', num2str(L_num), '.png.elp.txt'],'r');
        elp_num = str2double(fgetl(fid_dt));
        elp_data = zeros(elp_num,5);
        for j = 1:elp_num
            elp_data(j,:) = str2num(fgetl(fid_dt));
            
            if strcmp(dataset_name, 'yaed')
                elp_data(j,:) = [elp_data(j,3) + 1,elp_data(j,4) + 1,elp_data(j,1),elp_data(j,2),elp_data(j,5)];
            else
                elp_data(j,:) = [elp_data(j,3) ,elp_data(j,4),elp_data(j,1),elp_data(j,2),elp_data(j,5)];
            end
            
        end
        dt_time(i) = str2double(fgetl(fid_dt));
        dt_elps{i}=elp_data;
        fclose(fid_dt);
        
        % 查找对应的patch
        idx = find(strcmp(imgname, [prefix, num2str(i),'_line',num2str(L_num),'.png']));
        patch_gt_elps{i} = gt_elps{idx};
        
        
    end
    
    return;
end


if strcmp(dataset_name, 'tded')
    for i = 1:imgnum
        fid_dt = fopen([filepath,imgname{i},'.tded.txt'],'r');
        elp_num = str2double(fgetl(fid_dt));
        dt_time(i) = str2double(fgetl(fid_dt));
        elp_data = zeros(elp_num,5);
        for j = 1:elp_num
            elp_data(j,:) = str2num(fgetl(fid_dt));
            elp_data(j,3:4) = elp_data(j,3:4)/2;
            elp_data(j,5) = elp_data(j,5)/180*pi;
            
        end
        dt_elps{i}=elp_data;
        fclose(fid_dt);
    end
    
    return;
end

if strcmp(dataset_name, 'tped')
    for i = 1:patch_imgnum
        fid_dt = fopen([filepath,prefix, num2str(i), '_line', num2str(L_num), '.png.tped.txt'],'r');
        elp_num = str2double(fgetl(fid_dt));
        dt_time(i) = str2double(fgetl(fid_dt));
        elp_data = zeros(elp_num,5);
        for j = 1:elp_num
            elp_data(j,:) = str2num(fgetl(fid_dt));
            elp_data(j,3:4) = elp_data(j,3:4)/2;
            elp_data(j,5) = elp_data(j,5)/180*pi;
            
        end
        dt_elps{i}=elp_data;
        fclose(fid_dt);
        
        % 查找对应的patch
        idx = find(strcmp(imgname, [prefix, num2str(i),'_line',num2str(L_num),'.png']));
        patch_gt_elps{i} = gt_elps{idx};
    end
    
    return;
end

if strcmp(dataset_name, 'fdced')
    for i = 1:imgnum
        fid_dt = fopen([filepath,imgname{i},'.fdced.txt'],'r');
        elp_num = str2double(fgetl(fid_dt));
        dt_time(i) = str2double(fgetl(fid_dt));
        elp_data = zeros(elp_num,5);
        for j = 1:elp_num
            elp_data(j,:) = str2num(fgetl(fid_dt));
            elp_data(j,3:4) = elp_data(j,3:4)/2;
            elp_data(j,5) = elp_data(j,5)/180*pi;
            
        end
        dt_elps{i}=elp_data;
        fclose(fid_dt);
    end
    
    return;
end


if strcmp(dataset_name, 'prasad')
    isSaveInaFile = 0;
    try
        load([filepath,'prasad.mat']); % imgname, par_Param_all, par_Param_good, par_t_used
        isSaveInaFile = 1;
        error('噪声数据集中不存在prasad.mat文件')
    catch
        warning('prasad.mat不存在，尝试一张张数据读取');
        isSaveInaFile = 0;
    end
    
    if isSaveInaFile
        for i = 1:imgnum
            det_param = par_Param_good{i};
            if isempty(det_param)
                det_param = zeros(9,0);
            end
            ellipse_param = det_param([3,4,1,2,5],:);
            
            idx = ellipse_param(3,:) < 10 | ellipse_param(4,:) < 10;
            ellipse_param(:,idx) = [];
            
            dt_elps{i} = ellipse_param';
            dt_time(i) = par_t_used(i);
        end
    else
        for i = 1:patch_imgnum
            load([filepath, prefix, num2str(i), '_line', num2str(L_num),'.png.mat']);
            det_param = Param_good;
            ellipse_param = det_param([3,4,1,2,5],:);
            idx = ellipse_param(3,:) < 10 | ellipse_param(4,:) < 10;
            ellipse_param(:,idx) = [];
            
            dt_elps{i} = ellipse_param';
            dt_time(i) = t_used;
            
            % 查找对应的patch
            idx = find(strcmp(imgname, [prefix, num2str(i),'_line',num2str(L_num),'.png']));
            if isempty(idx)
                error('找不到图片');
            end
            patch_gt_elps{i} = gt_elps{idx};
            
        end
        
    end
    
    return;
end


if strcmp(dataset_name, 'amed')
    for i = 1:imgnum
        fid_dt = fopen([filepath, imgname{i},'.amed.txt']);
        if fid_dt == -1
            error([dataset_name, ': wrong file path']);
        end
        elps_data = [];
        dt_time(i) = str2num(fgetl(fid_dt));
        while feof(fid_dt) == 0
            elp_datat = str2num(fgetl(fid_dt));
            if elp_datat(1) == 2
                continue;
            end
            elp_datat(1) = [];
            temp = elp_datat(1);
            elp_datat(1) = elp_datat(2);
            elp_datat(2) = temp;
            
            elp_datat(3:4) = elp_datat(3:4)/2;
            elp_datat(5) = -elp_datat(5)/180*pi;
            
            elps_data = [elps_data; elp_datat];
        end
        dt_elps{i} = elps_data;
        fclose(fid_dt);
    end
    
    return;
    
end

if strcmp(dataset_name, 'aamed')
    
    
    for i = 1:imgnum
        fid_dt = fopen([filepath, imgname{i},'.aamed.txt']);
        if fid_dt == -1
            error([dataset_name, ': wrong file path']);
        end
        elps_data = [];
        dt_time(i) = str2num(fgetl(fid_dt));
        while feof(fid_dt) == 0
            elp_datat = str2num(fgetl(fid_dt));
            if elp_datat(1) == 2
                continue;
            end
            elp_datat(1) = [];
            temp = elp_datat(1);
            elp_datat(1) = elp_datat(2);
            elp_datat(2) = temp;
            elp_datat(1:2) = elp_datat(1:2)+1;
            elp_datat(3:4) = elp_datat(3:4)/2;
            elp_datat(5) = -elp_datat(5)/180*pi;
            
            elps_data = [elps_data; elp_datat];
        end
        dt_elps{i} = elps_data;
        fclose(fid_dt);
    end
    
    return;
    
end

if strcmp(dataset_name , 'rtded')
    
    for i = 1:patch_imgnum
        elp_data = load([filepath,prefix, num2str(i),'_line', num2str(L_num),'.png.rtded.txt']);
        if isempty(elp_data)
            dt_elps{i} = [];
            continue;
        end
        elp_data(1:2) = elp_data(1:2) + 1;
        elp_data(:,5) = elp_data(:,5)/180*pi;
        dt_elps{i}=elp_data;
        
        % 查找对应的patch
        idx = find(strcmp(imgname, [prefix, num2str(i),'_line',num2str(L_num),'.png']));
        if isempty(idx)
            error('找不到图片');
        end
        patch_gt_elps{i} = gt_elps{idx};
        
    end
    
    
    
    return;
end

if strcmp(dataset_name , 'wang')
    
    for i = 1:patch_imgnum
        elp_data = load([filepath,prefix, num2str(i),'_line', num2str(L_num),'.png.wang.txt']);
        if isempty(elp_data)
            dt_elps{i} = [];
            continue;
        end
        elp_data(1:2) = elp_data(1:2) + 1;
        elp_data(:,5) = elp_data(:,5)/180*pi;
        dt_elps{i}=elp_data;
        
        % 查找对应的patch
        idx = find(strcmp(imgname, [prefix, num2str(i),'_line',num2str(L_num),'.png']));
        if isempty(idx)
            error('找不到图片');
        end
        patch_gt_elps{i} = gt_elps{idx};
        
    end
    
    
    
    return;
end



if strcmp(dataset_name, 'rcned')
    
    for i = 1:imgnum
        
        fid_gt = fopen([filepath,imgname{i},'.cned.txt'],'r');
        if fid_gt == -1
            error('gt file error');
        end
        str = fgetl(fid_gt);
        elp_num = str2double(str);
        elp_data = zeros(elp_num,5);
        for j = 1:elp_num
            str = fgetl(fid_gt);
            dt_str = str2num(str);
            elp_data(j,:) = dt_str(1:5);
            elp_data(j,1:2) = elp_data(j,1:2) + 1;
        end
        dt_elps{i}=elp_data;
        fclose(fid_gt);
    end
    
    return;
end


if strcmp(dataset_name, 'elsd')
    
    for i = 1:patch_imgnum
        fid_dt = fopen([filepath,prefix, num2str(i),'_line', num2str(L_num),'.png.pgm.txt'],'r');
        if fid_dt == -1
            error('wrong file path');
        end
        elp_data = []; elp_num = 0;
        while feof(fid_dt) == 0
            elp_datat = str2num(fgetl(fid_dt));
            if elp_datat(1) ~= 1
                
                if abs(elp_datat(end) - elp_datat(end-1)) <= pi && elp_datat(end) > elp_datat(end-1)
                    continue;
                end
                if elp_datat(4) < 10 || elp_datat(5) < 10
                    continue;
                end
                
                if elp_datat(4) < 10 || elp_datat(5) < 10
                    continue;
                end
                
                elp_num = elp_num + 1;
                elp_datat(end-2) = elp_datat(end-2);
                elp_data(elp_num,:) = elp_datat(2:end-2);
            end
        end
        
        if ~isempty(elp_data)
            elp_data(:,1:2) = elp_data(:,1:2) + 1;
        end
        
        %elp_data = ellipses_cluster(elp_data); % 椭圆聚类
        
        
        dt_elps{i} = elp_data;
        fclose(fid_dt);
        
        % 查找对应的patch
        idx = find(strcmp(imgname, [prefix, num2str(i),'_line',num2str(L_num),'.png']));
        if isempty(idx)
            error('找不到图片');
        end
        patch_gt_elps{i} = gt_elps{idx};
        
    end
    
    % load([elsdpath,'elsdtime.mat']);
    useTime = 0;
    dt_time = useTime;
    
    return;
end

if strcmp(dataset_name,'rcnn')
    
    [imgnames_dt, bboxs_dt, use_time_dt] = Read_RCNN_BBox([filepath, 'result_images.txt']);
    
    for i = 1:imgnum
        isFind = 0; idx = -1;
        for j = 1:length(bboxs_dt)
            if strcmp(imgname{i}(1:(end-4)), imgnames_dt{j}(1:(end-4)))
                isFind = 1;
                idx = j;
                break
            end
        end
        
        if isFind == 0
            dt_elps{i} = [];
            continue;
        end
        
        bboxs = bboxs_dt{idx};
        elps = zeros(size(bboxs,1),5);
        elps(:,1) = (bboxs(:,1) + bboxs(:,3))/2;
        elps(:,2) = (bboxs(:,2) + bboxs(:,4))/2;
        elps(:,3) = (bboxs(:,3) - bboxs(:,1))/2;
        elps(:,4) = (bboxs(:,4) - bboxs(:,2))/2;
        dt_elps{i} = elps;
    end
    
    return;
end


if strcmp(dataset_name,'wu')
    load([filepath,'wu.mat']); % imgname, par_Param_all, par_Param_good, par_t_used
    for i = 1:patch_imgnum
        
        % 查找对应的patch
        idx = find(strcmp(imgname, [prefix, num2str(i),'_line',num2str(L_num),'.png']));
        if isempty(idx)
            error('找不到图片');
        end
        telp = det_elp{idx};
        if ~isempty(telp)
            theta = telp(:,5);
            n1 = [sin(theta(:)), cos(theta(:))];
            theta = atan2(n1(:,2), n1(:,1));
            telp = [telp(:,2), telp(:,1), telp(:,3), telp(:,4), theta];
            
        end
        
        dt_elps{i} = telp;
        patch_gt_elps{i} = gt_elps{idx};
        dt_time(i) = ust_t(idx) * 1000;
        %         figure;
        %         img = ones(600,600) * 255;
        %         imshow(uint8(img)); hold on;
        
        %         for k = 1:size(gt_elps{idx}, 1)
        %             [x,y] = GenerateElpData(gt_elps{idx}(k,:));
        %             plot(x,y,'--b','linewidth',1.5);
        %         end
        %
        %         for k = 1:size(telp, 1)
        %             [x,y] = GenerateElpData(telp(k,:));
        %             plot(y,x,'-r','linewidth',1.5);
        %         end
        
        
        
    end
    
    return;
end


if strcmp(dataset_name, 'lu')
    load([filepath,'lu.mat']);
    for i = 1:patch_imgnum
        
        
        % 查找对应的patch
        idx = find(strcmp(imgname, [prefix, num2str(i),'_line',num2str(L_num),'.png']));
        if isempty(idx)
            error('找不到图片');
        end
        dt_elps{i} = det_ellipses{idx};
        patch_gt_elps{i} = gt_elps{idx};
        dt_time(i) = det_time(idx) * 1000;
    end
    return;
end

if strcmp(dataset_name, 'liu')
    
    load_path = [filepath, 'liu.mat'];
    load(load_path);
    
    for i = 1:patch_imgnum
        % 查找对应的patch
        idx = find(strcmp(imgname, [prefix, num2str(i),'_line',num2str(L_num),'.png']));
        if isempty(idx)
            error('找不到图片');
        end
        tmp = det_elp{idx};
        if isempty(tmp)
            continue;
        end
        idxdel = tmp(:,3) < 15 | tmp(:,4) < 15;
        tmp(idxdel,:) = [];
        theta = tmp(:,5);
        n1 = [sin(theta(:)), cos(theta(:))];
        theta = atan2(n1(:,2), n1(:,1));
        
        dt_elps{i} = [tmp(:,2), tmp(:,1), tmp(:,4), tmp(:,3), -theta];
        patch_gt_elps{i} = gt_elps{idx};
    end
    dt_time = det_times;
    return;
end

error(['不存在当前数据集：', dataset_name]);

end