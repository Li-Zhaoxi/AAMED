function [gt_lines, gt_size, imgname] = Read_GT_Lines_YorkUrbanDB(gt_path)
% 读取YorkUrbanDB直线段数据集的数据信息


%% 读取图片名信息
load([gt_path, 'Manhattan_Image_DB_Names.mat']);

%% 读取每个直线的数据信息
data = Manhattan_Image_DB_Names; % 获取文件夹名
imgnum = size(data,1);
gt_lines = cell(1, imgnum);
imgname = cell(1, imgnum);
gt_size = zeros(imgnum, 2);
for i = 1:imgnum
   str = data{i};
   single_img = str(1:end-1);
   
   t = load([gt_path, str, single_img, 'LinesAndVP.mat']); % 读取直线数据
   gt_size(i,1) = size(t.finalImg,1); gt_size(i,2) = size(t.finalImg,2);
   linesget = t.lines;
   gt_lines_t = zeros(size(linesget,1)/2,4);
   for j = 1:2:size(linesget,1)
      gt_lines_t((j+1)/2,:) = [linesget(j,:), linesget(j+1,:)]; 
   end
   gt_lines{i} = gt_lines_t;
   imgname{i} = [single_img, '.jpg'];
end

end