clc;clear all;close all;
% 测试从UpWrite 保存出来的结果

filename = 'bone.pbm.txt';
%% 读取UpWrite保存的文件格式
fid = fopen(filename,'r');
imgsize = str2num(fgetl(fid));
edgenum = 0;
edgecell= [];
while feof(fid) == 0
    str = fgetl(fid);
    if strcmp(str,'line')
        edgetype = 1;
    else
        edgetype = 2;
    end
    edgepoint = str2num(fgetl(fid));
    edgenum = edgenum + 1;
    edgecell{edgenum} = [edgetype, edgepoint];
end
fclose(fid);

img = ones(imgsize(2), imgsize(1));
figure;
imshow(uint8(img*255)); hold on;
for i = 1:length(edgecell)
    edgetype = edgecell{i}(1);
    idx = 2:2:length(edgecell{i});
    x = edgecell{i}(idx);
    y = edgecell{i}(idx+1);
    if edgetype == 1
        plot(x,y,'.b');
    else
        plot(x,y,'.r');
    end
    [ellipse_shape, err, state] = fitellipse([x',y']);
    ellipse_shape(5) = -ellipse_shape(5);
    [xe,ye] = GenerateElpData(ellipse_shape);
    plot(xe,ye,'-b','linewidth',1.5);
end



