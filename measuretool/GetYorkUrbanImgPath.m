clc;clear all;close all;
% 生成城市数据集路径

dirpath = 'E:\迅雷下载\YorkUrbanDB\'; % Data set path

%% 读取图片名信息
load([dirpath, 'Manhattan_Image_DB_Names.mat']);

%% 读取每个直线的数据信息
data = Manhattan_Image_DB_Names; % 获取文件夹名

imgnum = size(data,1);


fid = fopen('lsdpath.txt','w');
fprintf(fid, '%s\n', dirpath);
for i = 1:imgnum
    str = data{i};
    single_img = str(1:end-1);
    fprintf(fid, '%s\n', single_img);
end
fclose(fid);