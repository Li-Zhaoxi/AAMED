function [dt_elps_Fornaciari, detTime_Fornaciari] = Read_Fornaciari_Ellipse_Results(fledelppath,imgname)

imgnum = length(imgname);
dt_elps_Fornaciari = cell(1, imgnum);
detTime_Fornaciari = zeros(1,imgnum);
for i = 1:imgnum
    fid_dt = fopen([fledelppath,imgname{i},'.elp.txt'],'r');
    elp_num = str2double(fgetl(fid_dt));
    elp_data = zeros(elp_num,5);
    for j = 1:elp_num
        elp_data(j,:) = str2num(fgetl(fid_dt));
        elp_data(j,:) = [elp_data(j,3),elp_data(j,4),elp_data(j,1),elp_data(j,2),-elp_data(j,5)];
        
    end
    detTime_Fornaciari(i) = str2double(fgetl(fid_dt));
    dt_elps_Fornaciari{i}=elp_data;
    fclose(fid_dt);
end


end