function [P,R,F] = MeasureEllipsesFun(dirpath, dataset, T_overlap)

%% Read the image name list 'imagenames.txt', the list is got by 'getImagesName.bat'
fid = fopen([dirpath,'imagenames.txt'],'r');
imgnum = 0;
while feof(fid) == 0
    imgnum = imgnum + 1;
    imgname{imgnum} = fgetl(fid);
end
fclose(fid);

%% Read the ground-truth ellipse data
[gt_elps] = Read_Ellipse_GT([dirpath,'gt\gt_'], [dirpath,'images\'], imgname, dataset);

%% Read the detected ellipse by FLED methods
[dt_elps, dt_time] = Read_Ellipse_Results([dirpath,'AMED\'], imgname, 'aamed');

Pos = 0; detN = 0; gtN = 0;
use_res = dt_elps;
for i = 1:imgnum
    %    disp(['正在验证第',num2str(i),'张图片：', imgname{i}]);
    elpnum_det = size(use_res{i},1);
    elpnum_gt = size(gt_elps{i},1);
    detN = detN + elpnum_det;
    gtN = gtN + elpnum_gt;
    
    dt_match_num = zeros(1, elpnum_det);
    for p = 1:elpnum_gt
        elp_gt = gt_elps{i}(p,:);
        for q = 1:elpnum_det
            elp_det = use_res{i}(q,:);
            [ration, ~] = mexCalculateOverlap(elp_gt,elp_det);
            if ration > T_overlap
                Pos = Pos + 1;
                dt_match_num(q) = dt_match_num(q) + 1;
                break;
            end
        end
    end
%     disp(num2str(Pos));
    idx = find(dt_match_num>2);
    more_det = sum(dt_match_num(idx)) - length(idx);
    detN = detN + more_det;
    
end
if detN == 0
    P = 0;
    R = 0;
    F = 0;
else
    P = Pos/detN;
    R = Pos/gtN;
    beta = 1;
    F = (beta^2+1)*P*R/(beta*P+R);
end

end