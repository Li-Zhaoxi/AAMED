function [dt_elps_upwrite, detTime_upwrite] = Read_UpWrite_Ellipse_Results(upwriteelppath,imgname)

imgnum = length(imgname);
dt_elps_upwrite = cell(1, imgnum);

for i = 1:imgnum
    
    %% 读取UpWrite 的椭圆弧段
    fid_dt = fopen([upwriteelppath,imgname{i},'.pbm.txt'],'r');
    imgsize = str2num(fgetl(fid_dt));
    edgenum = 0;
    edgecell= [];
    while feof(fid_dt) == 0
        str = fgetl(fid_dt);
        if strcmp(str,'line')
            edgetype = 1;
        else
            edgetype = 2;
        end
        edgepoint = str2num(fgetl(fid_dt));
        if edgetype ~= 1
            edgenum = edgenum + 1;
            edgecell{edgenum} = edgepoint;
        end
    end
    fclose(fid_dt);
    %% 根据提取出的弧段点进行拟合得到最终椭圆
    elp_res = zeros(edgenum,5);
    for j = 1:edgenum
        idx = 1:2:length(edgecell{j});
        x = edgecell{j}(idx);
        y = edgecell{j}(idx+1);
        [ellipse_shape, ~, ~] = fitellipse([x',y']);
        ellipse_shape(5) = -ellipse_shape(5);
        elp_res(j,:) = ellipse_shape;
    end
    dt_elps_upwrite{i} = elp_res;
end


detTime_upwrite = 0;




end