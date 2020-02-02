function [img_gt, img_name] = Read_Ellipse_GT_Synth(datapath)


data_type = {'occluded', 'overlap'};
data_elpnum = {'4','8','12','16','20','24'};
elp_num = 100;

img_gt = cell(length(data_type), length(data_elpnum), elp_num);
img_name = cell(length(data_type), length(data_elpnum), elp_num);

for i = 1:length(data_type)
    for j = 1:length(data_elpnum)
        for k = 1:elp_num
            image_name = ['synth_',data_type{i},'_',data_elpnum{j},'ellipses_img', num2str(k),'.jpg'];
            gt_name = ['Synth_',data_type{i},'_',data_elpnum{j},'ellipses_img', num2str(k),'.mat'];
            gt = load([datapath,'\gt\',gt_name]);
            gt_elp = gt.ellipse_param';
            gt_elp(:,5) = gt_elp(:,5)/180*pi;
            
            temp = gt_elp(:,1); gt_elp(:,1) = gt_elp(:,2); gt_elp(:,2) = temp;
            temp = gt_elp(:,3); gt_elp(:,3) = gt_elp(:,4); gt_elp(:,4) = temp;
            temp = pi/2 - gt_elp(:,5);
            gt_elp(:,5) =  temp;
            %            temp = gt_elp(:,1); gt_elp(:,1) = gt_elp(:,2); gt_elp(:,2) = temp;
            %            temp = gt_elp(:,3); gt_elp(:,3) = gt_elp(:,4); gt_elp(:,4) = temp;
            %            temp = pi/2 - gt_elp(:,5);
            %            gt_elp(:,5) = temp;
            
            img_gt{i,j,k} = gt_elp;
            img_name{i,j,k} = image_name;
        end
    end
end





end