close all;
figure;

idx = 2;

for idx = 1:100
    
    idx
    imgname{idx}
    % imshow(9[dirpath,'images\',imgname{idx}]);
    img = imread([dirpath,'images\',imgname{idx}]);
    if length(size(img))>2
        img=rgb2gray(img);
    end
    
    %imshow('Canny.png');
    subplot(1,2,1);
    imshow(img);
    hold on;
    
    elp_gt = gt_elps{idx};
    elp_dt = dt_elps{idx};
    for i = 1:size(elp_gt,1)
        [x,y] = GenerateElpData(elp_gt(i,:));
        plot(x,y,'-r','linewidth',2);
        text(x(1),y(1), num2str(i),'color','y');
    end
    title('真值')
    hold off;
    
    subplot(1,2,2);
    imshow(img);
    hold on;
    for i = 1:size(elp_dt,1)
        elp_dt(:,5) = elp_dt(:,5);
        [x,y] = GenerateElpData(elp_dt(i,:));
        plot(x,y,'-r','linewidth',2);
        text(x(1),y(1), num2str(i),'color','y');
    end
    
    title(['检测值：',imgname{idx}]);
    
    hold off;
    pause;
end
% imgname{idx}
% Pos = 0; detN = 0; gtN = 0;
% disp(['正在验证第',num2str(i),'张图片：', imgname{i}]);
% elpnum_det = size(elp_dt,1);
% elpnum_gt = size(elp_gt,1);
% detN = detN + elpnum_det;
% gtN = gtN + elpnum_gt;
%
% for p = 1:elpnum_gt
%     elp_gtt = elp_gt(p,:);
%     for q = 1:elpnum_det
%         elp_dett = elp_dt(q,:);
%         [ration, ~] = CalculateOverlap(elp_gtt,elp_dett);
%
%         if ration >0.75
%             Pos = Pos + 1;
%             break;
%         end
%     end
% end
% if detN == 0
%     P=0;
% else
%     P = Pos/detN;
% end
% R = Pos/gtN;
% beta = 1;
% F = (beta^2+1)*P*R/(beta*P+R);
% disp(['detected number:', num2str(detN),',  gt number:', num2str(gtN),',  truth number:', num2str(Pos)])
% disp(['Precision:',num2str(P*100),'%,  Recall:',num2str(R*100),'%,  F-measure:',num2str(F*100),'%.']);
