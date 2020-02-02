function [dt_elps_elsd, detTime_elsd] = Read_ELSD_Ellipse_Results(elsdpath, imgname)

imgnum = length(imgname);
dt_elps_elsd = cell(1, imgnum);

for i = 1:imgnum
%     [elsdpath,imgname{i},'.pgm.txt']
    fid_dt = fopen([elsdpath,imgname{i},'.pgm.txt'],'r');
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
            if elp_datat(4) < 5 || elp_datat(5) <5
                continue;
            end
           elp_num = elp_num + 1;
           elp_datat(end-2) = elp_datat(end-2);
           elp_data(elp_num,:) = elp_datat(2:end-2);
        end
    end
    dt_elps_elsd{i} = elp_data;
    fclose(fid_dt);
end

% load([elsdpath,'elsdtime.mat']);
useTime = 0;
detTime_elsd = useTime;



end