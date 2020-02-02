clc; clear all; close all;
% 输出直线数据集路径地址

dataset_name = 'yorkurban';

if strcmp(dataset_name, 'yorkurban')
    gt_path = 'E:\迅雷下载\YorkUrbanDB\'; % Data set path
    
    %% 读取图片名信息
    load([gt_path, 'Manhattan_Image_DB_Names.mat']);
    
    %% 获取图像名，不带后缀
    data = Manhattan_Image_DB_Names; % 获取文件夹名
    imgnum = size(data,1);
    
    %% 创建文件路径文件
    fid = fopen('lsdpath.txt', 'w');
    %% 开始输出路径
    for i = 1:imgnum
        str = data{i};
        single_img = str(1:end-1);
        imgname = [single_img,'.jpg'];
        allpath = [gt_path, str, imgname];
        fprintf(fid, '%s\n', allpath);
    end
    fclose(fid);
    return;
end


if strcmp(dataset_name, 'prasad')
    gt_path = 'G:\ellipse_dataset\Prasad Images - Dataset Prasad\'; % Data set path
    fid_in = fopen([gt_path, 'imagenames.txt'],'r');
    fid_out = fopen('parasadpath.txt','w');
    while feof(fid_in) == 0
        imgname = fgetl(fid_in);
        fprintf(fid_out, '%s\n', [gt_path, 'images\', imgname]);
    end
    fclose(fid_in);
    fclose(fid_out);
    return;
end



error([dataset_name, ': Error dataset name']);

