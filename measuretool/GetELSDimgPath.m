clc;clear all;close all;
% 生成ELSE读取图片的路径

dirpath = 'D:\MBZIRC2020\datasets\TBall1\'; % Data set path
%% Read the image name list 'imagenames.txt', the list is got by 'getImagesName.bat'
fid = fopen([dirpath,'imagenames.txt'],'r');
imgnum = 0;
while feof(fid) == 0
    imgnum = imgnum + 1;
    imgname{imgnum} = fgetl(fid);
end
fclose(fid);


%elsd_path = '../ellipse_dataset/Oil\\ Tanks\\ -\\ Dataset\\ #1/images_pgm/';
elsd_path = './elsd ../ellipse_dataset/TBall/images_pgm/';
fid = fopen('elsdpath.txt','wt');
for i = 1:imgnum
   
    str = [elsd_path, imgname{i},'.pgm'];
    fprintf(fid,'%s | tee -a elsd.log\n', str);
    
end

fclose(fid);

