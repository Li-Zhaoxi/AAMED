function [P,R,F] = MeasureSynthEllipseFun(dataset_path, method_name)

% 读取真值
[img_gt, img_name] = Read_Ellipse_GT_Synth(dataset_path); save gt.mat img_gt

% 读取检测值
if strcmp(method_name, 'aamed')
    [dt_elps, dt_time] = Read_SynthEllipse_Results([dataset_path,'\AMED\'],img_name, 'aamed'); 
elseif strcmp(method_name, 'prasad')
    [dt_elps, dt_time] = Read_SynthEllipse_Results([dataset_path,'\Prasad\'],img_name, 'prasad'); 
    
end


data_size = size(img_gt);


detN_par = zeros(data_size(1), data_size(2), data_size(3));
gtN_par = zeros(data_size(1), data_size(2), data_size(3));
Pos_par = zeros(data_size(1), data_size(2), data_size(3));
for i = 2:data_size(1)
    for j = 1:data_size(2)
        for k = 1:data_size(3)
            dt = dt_elps{i,j,k};
            gt = img_gt{i,j,k};
            elpnum_det = size(dt,1);
            elpnum_gt = size(gt,1);
            detN_par(i,j,k) = elpnum_det;
            gtN_par(i,j,k) = elpnum_gt;
            Pos_t = 0;
            for p = 1:elpnum_gt
                elp_gt = gt(p,:);
                for q = 1:elpnum_det
                    elp_det = dt(q,:);
                    [ration, ~] = CalculateOverlap(elp_gt,elp_det);
                    if ration >0.95
                        Pos_t = Pos_t + 1;
                        break;
                    end
                end
            end
            Pos_par(i,j,k) = Pos_t;
        end
    end
end

Pos = sum(Pos_par(:));
detN = sum(detN_par(:));
gtN = sum(gtN_par(:));

P = Pos/detN;
R = Pos/gtN;
beta = 1;
F = (beta^2+1)*P*R/(beta*P+R);



end