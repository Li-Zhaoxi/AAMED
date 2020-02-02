function [dt_elps, dt_time] = Read_SynthEllipse_Results(filepath,imgname, method_name)

size_imgname = size(imgname);

dt_elps = cell(size_imgname(1),size_imgname(2),size_imgname(3));
dt_time = zeros(size_imgname(1),size_imgname(2),size_imgname(3));


if strcmp(method_name, 'aamed')
    
    for i = 1:size_imgname(1)
        for j = 1:size_imgname(2)
            for k = 1:size_imgname(3)
                fid_dt = fopen([filepath, imgname{i,j,k},'.aamed.txt']);
                if fid_dt == -1
                    error([method_name, ': wrong file path']);
                end
                elps_data = [];
                dt_time(i,j,k) = str2num(fgetl(fid_dt));
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
                dt_elps{i,j,k} = elps_data;
                fclose(fid_dt);
            end
        end
    end
    return;
end



if strcmp(method_name, 'prasad')
    
    for i = 1:size_imgname(1)
        for j = 1:size_imgname(2)
            for k = 1:size_imgname(3)
                
                load([filepath, imgname{i,j,k},'.mat']);
                det_param = Param_good;
                ellipse_param = det_param([3,4,1,2,5],:);
                dt_elps{i,j,k} = ellipse_param';
                dt_time(i,j,k) = t_used;
            end
        end
    end
    
    return;
end


if strcmp(method_name, 'tded')

    for i = 1:size_imgname(1)
        for j = 1:size_imgname(2)
            for k = 1:size_imgname(3)
                
                fid_dt = fopen([filepath,imgname{i,j,k},'.tded.txt'],'r');
                
                elp_num = str2double(fgetl(fid_dt));
                dt_time(i,j,k) = str2double(fgetl(fid_dt));
                elp_data = zeros(elp_num,5);
                for m = 1:elp_num
                    elp_data(m,:) = str2num(fgetl(fid_dt));
                    elp_data(m,1:2) = elp_data(m,1:2) + 1;
                    elp_data(m,3:4) = elp_data(m,3:4)/2;
                    elp_data(m,5) = elp_data(m,5)/180*pi;
                    
                end
                dt_elps{i,j,k}=elp_data;
                fclose(fid_dt);

            end
        end
    end
    
    return;
end


end