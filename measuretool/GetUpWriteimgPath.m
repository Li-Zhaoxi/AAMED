clc;clear all;close all;
% 生成UpWrite读取图片的路径

dirpath = 'G:\ellipse_dataset\Smartphone Images - Dataset #2\'; % Data set path
%% Read the image name list 'imagenames.txt', the list is got by 'getImagesName.bat'
fid = fopen([dirpath,'imagenames.txt'],'r');
imgnum = 0;
while feof(fid) == 0
    imgnum = imgnum + 1;
    imgname{imgnum} = fgetl(fid);
end
fclose(fid);


elsd_path = '../../ellipse_dataset/Smartphone\\ Images\\ -\\ Dataset\\ #2/images_pbm/';
fid = fopen('Upwritepath.txt','wt');
for i = 1:imgnum
   
    str = [elsd_path, imgname{i},'.pbm'];
    fprintf(fid,'%s\n', str);
    
end

fclose(fid);

