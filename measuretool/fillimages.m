clc;clear;close all;
% 对仿真图像进行颜色填充


dsi = 1;

% occluded椭圆填充颜色方案。
color_type = {[0,0,0]};



data_root_path = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset\';

dataset_name = [{'Synthetic Images - Occluded Ellipses'}];
gt_label = [{'occluded'},{'overlap'},{'concentric'},{'concurrent'}];
color_use = color_type{dsi};


imgname_path = [data_root_path,dataset_name{dsi},'\imagenames.txt'];
fid = fopen(imgname_path,'r');
imgnum = 0;
imgname = [];
while feof(fid) == 0
    imgnum = imgnum + 1;
    imgname{imgnum} = fgetl(fid);
end
fclose(fid);
        
for i = 1:1
    img = imread([data_root_path,dataset_name{dsi},'\images\', imgname{i}]);
    img2 = zeros(300, 300) + 255;
    bw = img > 200;
    cad_stats = regionprops(~bw, 'PixelList');
    
    figure;
    imshow(bw);

    hold on;
    for k = 1:size(cad_stats,1)
        pts = cad_stats(k).PixelList;
        plot(pts(:,1), pts(:,2),'.b');
        img2=roifill(img2,pts(:,1),pts(:,2));
    end
    
end
