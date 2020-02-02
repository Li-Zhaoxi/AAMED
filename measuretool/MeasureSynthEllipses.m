clc;clear;close all;
% 这个脚本用于衡量

dataset_path = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset\Synthetic Images - Dataset Prasad';

% 读取真值
[img_gt, img_name] = Read_Ellipse_GT_Synth(dataset_path); save gt.mat img_gt

% 读取检测值
% [dt_elps, dt_time] = Read_SynthEllipse_Results([dataset_path,'\AMED\'],img_name, 'aamed'); save dt.mat dt_elps
% [dt_elps, dt_time] = Read_SynthEllipse_Results([dataset_path,'\Prasad\'],img_name, 'prasad'); save dt.mat dt_elps
 [dt_elps, dt_time] = Read_SynthEllipse_Results([dataset_path,'\TDED\'],img_name, 'tded'); save dt.mat dt_elps
% 进行验证






Pos = 0; detN = 0; gtN = 0;
use_res = dt_elps;
data_size = size(img_gt);


for i = 1:1%data_size(1)
    for j = 1:data_size(2)
        for k = 1:data_size(3)
            
            disp(['正在验证:',img_name{i,j,k}]);
            dt = dt_elps{i,j,k};
            gt = img_gt{i,j,k};
            elpnum_det = size(dt,1);
            elpnum_gt = size(gt,1);
            detN = detN + elpnum_det;
            gtN = gtN + elpnum_gt;
            for p = 1:elpnum_gt
                elp_gt = gt(p,:);
                for q = 1:elpnum_det
                    elp_det = dt(q,:);
                    [ration, ~] = CalculateOverlap(elp_gt,elp_det);
                    if ration >0.95
                        Pos = Pos + 1;
                        break;
                    end
                end
            end
            
        end
    end
end

P = Pos/detN;
R = Pos/gtN;
beta = 1
F = (beta^2+1)*P*R/(beta*P+R);
disp(['Precision:',num2str(P*100),'%,  Recall:',num2str(R*100),'%,  F-measure:',num2str(F*100),'%, Time:', num2str(mean(dt_time(:))),' ms.']);
