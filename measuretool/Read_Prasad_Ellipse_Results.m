function [dt_elps_prasad, detTime_prasad] =  Read_Prasad_Ellipse_Results(prasadelppath,imgname)

imgnum = length(imgname);

dt_elps_prasad = cell(1, imgnum);
detTime_prasad = zeros(1, imgnum);

for i = 1:imgnum
    load([prasadelppath, imgname{i},'.mat']);
    det_param = Param_good;
    ellipse_param = det_param([3,4,1,2,5],:);
    ellipse_param(5,:) = -ellipse_param(5,:);
    dt_elps_prasad{i} = ellipse_param';
    detTime_prasad(i) = t_used;

end



end