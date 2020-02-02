function [imgname, bbox, use_time] = Read_RCNN_BBox(bbox_file)
% 读取Fast RCNN检测结果的BBox
fid = fopen(bbox_file,'r');
imgname_t = [];
bbox_t = [];
imgnum = 0;
use_time_t = [];
while feof(fid) == 0
    imgnum = imgnum + 1;
    str = fgetl(fid);
    S = regexp(str,'\s+','split');
    imgname_t{imgnum} = S{1};
    bbox_t{imgnum} = [str2double(S{2}),str2double(S{3}),str2double(S{4}),str2double(S{5})];
    use_time_t(imgnum) = str2double(S{6});
end
fclose(fid);

imgname = imgname_t(1);
bbox = bbox_t(1);
use_time = use_time_t(1);
for i = 2:length(imgname_t)
    if strcmp(imgname_t{i}, imgname{end})
        bbox{end} = [bbox{end}; bbox_t{i}];
    else
        imgname{end+1} = imgname_t{i};
        bbox{end+1} = bbox_t{i};
        use_time(end+1) = use_time_t(i);
    end
end


end