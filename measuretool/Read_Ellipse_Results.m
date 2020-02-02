function [dt_elps, dt_time] = Read_Ellipse_Results(filepath, imgname, dataset_name)

imgnum = length(imgname);
dt_elps = cell(1, imgnum);
dt_time = zeros(1,imgnum);

if strcmp(dataset_name, 'aamed2')
    for i = 1:imgnum
%         imgname{i}
        fid_dt = fopen([filepath, imgname{i},'.txt']);
        if fid_dt == -1
            error([dataset_name, ': wrong file path']);
        end
        elps_data = [];
        %dt_time(i) = str2num(fgetl(fid_dt));
        while feof(fid_dt) == 0
            tstr = fgetl(fid_dt);
            if tstr == -1
                break;
            end
            elp_datat = str2num(tstr);
            if elp_datat(1) == 2
                continue;
            end
            if elp_datat(1) ~= 1
%                 continue;
            end
            elp_datat(1) = [];
            elp_datat(1:2) = elp_datat(1:2) + 1;
            elp_datat(3:4) = [elp_datat(4), elp_datat(3)];
            elp_datat(5) = elp_datat(5);
            
            elps_data = [elps_data; elp_datat];
            
        end
%         elps_data = mexClusterEllipses(elps_data);
        dt_elps{i} = elps_data;
        fclose(fid_dt);
    end
    
    return;
end

if strcmp(dataset_name, 'fled')
    for i = 1:imgnum
        fid_dt = fopen([filepath, imgname{i},'.fled.txt']);
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
    end
    
    return;
end


if strcmp(dataset_name, 'yaed') || strcmp(dataset_name, 'cned')
    for i = 1:imgnum
        fid_dt = fopen([filepath,imgname{i},'.elp.txt'],'r');
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
%             elp_data(j,1:2) = elp_data(j,1:2)+1;
            elp_data(j,3:4) = elp_data(j,3:4)/2;
            elp_data(j,5) = elp_data(j,5)/180*pi;
            
        end
        dt_elps{i}=elp_data;
        fclose(fid_dt);
    end
    
    return;
end

if strcmp(dataset_name, 'tped')
    for i = 1:imgnum
        fid_dt = fopen([filepath,imgname{i},'.tped.txt'],'r');
        elp_num = str2double(fgetl(fid_dt));
        dt_time(i) = str2double(fgetl(fid_dt));
        elp_data = zeros(elp_num,5);
        for j = 1:elp_num
            elp_data(j,:) = str2num(fgetl(fid_dt));
            %elp_data(j,1:2) = elp_data(j,1:2) + 1;
            elp_data(j,3:4) = elp_data(j,3:4)/2;
            elp_data(j,5) = elp_data(j,5)/180*pi;
            
        end
        dt_elps{i}=elp_data;
        fclose(fid_dt);
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
        for i = 1:imgnum
            load([filepath, imgname{i},'.mat']);
            det_param = Param_good;
            ellipse_param = det_param([3,4,1,2,5],:);
            
            %         ratio = det_param(8,:);
            %         idx = ratio <0.7;
            
            idx = ellipse_param(3,:) < 10 | ellipse_param(4,:) < 10;
            ellipse_param(:,idx) = [];
            
            dt_elps{i} = ellipse_param';
            dt_time(i) = t_used;
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

if strcmp(dataset_name , 'rtded') || strcmp(dataset_name , 'wang')
    
    for i = 1:imgnum
        %elp_data = load([filepath,imgname{i},'.rtded.txt']);
        elp_data = load([filepath,imgname{i},'.wang.txt']);
        if isempty(elp_data)
            dt_elps{i} = [];
            continue;
        end
        elp_data(1:2) = elp_data(1:2) + 1;
        elp_data(:,5) = elp_data(:,5)/180*pi;
        dt_elps{i}=elp_data;
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
    
    
    for i = 1:imgnum
        fid_dt = fopen([filepath,imgname{i},'.pgm.txt'],'r');
        if fid_dt == -1
            error('wrong file path');
        end
        elp_data = []; elp_num = 0;
        while feof(fid_dt) == 0
            elp_datat = str2num(fgetl(fid_dt));
            if elp_datat(1) ~= 1
                
                if abs(elp_datat(end) - elp_datat(end-1)) < pi && elp_datat(end) > elp_datat(end-1)
                    continue;
                end
                if elp_datat(4) < 9 || elp_datat(5) < 9
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
    end
    
    % load([elsdpath,'elsdtime.mat']);
    useTime = 0;
    dt_time = useTime;
    
    return;
end

if strcmp(dataset_name,'rcnn')
    load_path = [filepath, 'rcnn.mat'];
    load(load_path);
    
    for i = 1:length(dt_elps)
        dt_elps{i} = mexClusterEllipses(dt_elps{i});
    end
    
%     [imgnames_dt, bboxs_dt, use_time_dt] = Read_RCNN_BBox([filepath, 'result_images.txt']);
%     
%     for i = 1:imgnum
%         isFind = 0; idx = -1;
%         for j = 1:length(bboxs_dt)
%             if strcmp(imgname{i}(1:(end-4)), imgnames_dt{j}(1:(end-4)))
%                 isFind = 1;
%                 idx = j;
%                 break
%             end
%         end
%         
%         if isFind == 0
%             dt_elps{i} = [];
%             continue;
%         end
%         
%         bboxs = bboxs_dt{idx};
%         elps = zeros(size(bboxs,1),5);
%         elps(:,1) = (bboxs(:,1) + bboxs(:,3))/2;
%         elps(:,2) = (bboxs(:,2) + bboxs(:,4))/2;
%         elps(:,3) = (bboxs(:,3) - bboxs(:,1))/2;
%         elps(:,4) = (bboxs(:,4) - bboxs(:,2))/2;
%         dt_elps{i} = elps;
%     end
    
    return;
end


if strcmp(dataset_name,'wu')
    load([filepath,'wu.mat']); % imgname, par_Param_all, par_Param_good, par_t_used
    for i = 1:imgnum
        telp = det_elp{i};
        theta = telp(:,5);
        n1 = [sin(theta(:)), cos(theta(:))];
        theta = atan2(n1(:,2), n1(:,1));
        telp = [telp(:,2), telp(:,1), telp(:,3), telp(:,4), theta];
        dt_elps{i} = telp;
    end
    dt_time = ust_t * 1000;
    return;
end

if strcmp(dataset_name, 'lu')
    load_path = [filepath, 'lu.mat'];
    load(load_path);
    
%     for i = 1:length(det_ellipses)
%         tmp = det_ellipses{i};
%         tmp(:,1:2) = tmp(:,1:2)+1;
%         det_ellipses{i} = tmp;
%     end
    
    dt_elps = det_ellipses;
    dt_time = det_time;
    return;
end

if strcmp(dataset_name, 'crht')
    load_path = [filepath, 'crht.mat'];
    load(load_path);
    dt_elps = det_elp;
    dt_time = det_times;
    return;
end

if strcmp(dataset_name, 'liu')
    load_path = [filepath, 'liu.mat'];
    load(load_path);
    
    for i = 1:imgnum
        tmp = det_elp{i};
        if isempty(tmp)
            continue;
        end
        
        idx = tmp(:,3) < 15 | tmp(:,4) < 15;
        tmp(idx,:) = [];
        
        theta = tmp(:,5);
        n1 = [sin(theta(:)), cos(theta(:))];
        theta = atan2(n1(:,2), n1(:,1));
        
        dt_elps{i} = [tmp(:,2), tmp(:,1), tmp(:,4), tmp(:,3), -theta];
    end

    dt_time = det_times;
    return;
end

if strcmp(dataset_name, 'gmmed')
    for i = 1:imgnum
        try
            load([filepath,imgname{i},'.mat']);
            idx = [];
            for j = 1:length(relate_elp)
                if isempty(relate_elp{j})
                    continue;
                end
                tmpelp = det_elp(j,:);
                if min(tmpelp(3:4)) < 10
                    continue;
                end
                
                idx = [idx;j];
                
            end
            dt_elps{i} = det_elp(idx,:);
            dt_time(i) = use_t;
        catch
            disp(num2str(i));
        end
    end
    return;
end
if strcmp(dataset_name, 'gmmed2')
    load([filepath,'gmmedvld.mat']);
    dt_elps = dt_elps_new;
    return;
end
if strcmp(dataset_name, 'prasad2')
    load([filepath,'prasadnew.mat']);
    dt_elps = dt_elps_new;
    return;
end
error(['不存在当前数据集：', dataset_name]);

end