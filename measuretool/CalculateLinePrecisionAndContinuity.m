function [ration, coverlines] = CalculateLinePrecisionAndContinuity(gt_line, det_lines)
% 给定一个真实直线段，找出与其精度在要求范围内的最大连续度直线组合
linenum = size(det_lines,1);
lines_idx = 1:linenum;
is_use_line = zeros(1, linenum);

for i = 1:linenum
    isMatch = CalculateLinesMatch(gt_line, det_lines(i,:));
    if isMatch
        is_use_line(i) = 1;
    end
end
lines_idx(is_use_line ~= 1) =[];

choose_num = length(lines_idx);

% figure;hold on;
% plot([gt_line(1,1),gt_line(1,3)], [gt_line(1,2),gt_line(1,4)],'-r');
% for i = 1:choose_num
%     plot([det_lines(lines_idx(i),1),det_lines(lines_idx(i),3)], [det_lines(lines_idx(i),2),det_lines(lines_idx(i),4)],'-b');
% end
% hold off;
% axis equal;
% pause;

%% 计算所需直线在gt_line上的投影距离

use_lines = det_lines(lines_idx,:);
n1_x = use_lines(:,1) - gt_line(1); n1_y = use_lines(:,2) - gt_line(2);
n2_x = use_lines(:,3) - gt_line(1); n2_y = use_lines(:,4) - gt_line(2);
nt = [gt_line(3) - gt_line(1), gt_line(4) - gt_line(2)]; nt2 = nt*nt';
t1 = n1_x * nt(1) + n1_y * nt(2); t1 = t1 / nt2;
t2 = n2_x * nt(1) + n2_y * nt(2); t2 = t2 / nt2;

idx = find(t1 > t2);
for i = 1:length(idx)
   temp = t1(idx(i));
   t1(idx(i)) = t2(idx(i));
   t2(idx(i)) = temp;
end
project_range = [t1, t2];
t1(t1<0) = 0; t2(t2>1) = 1;
project_range_norm = [t1, t2];


%% 进行直线段组合，最后找出精度满足阈值的组合，在满足精度要求下，找出连续度最大的一组数据
max_continuity = 0; idx_conbine = []; use_precision = 0;
for i = 1:choose_num
    
    C = nchoosek(1:choose_num, i); % 得到直线段的组合
    
    for k = 1:size(C,1)
        
        [precision, conti] = CalculateLineOverlap(C(k,:), project_range, project_range_norm);
        if precision < 0.75
            continue;
        end
        
        if conti > max_continuity
            idx_conbine = lines_idx(C(k,:));
            max_continuity = conti;
            use_precision = precision;
        end
        
    end

end
ration = [use_precision, max_continuity];
coverlines = [idx_conbine', det_lines(idx_conbine,:)];

end

function [precision, conti] = CalculateLineOverlap(sel_idx, project_range, project_range_norm)


sel_range = project_range(sel_idx,:);
sel_range_norm = project_range_norm(sel_idx,:);
det_num = size(sel_range_norm,1);
S2 = sum(sel_range(:,2) - sel_range(:,1));
S1 = 1;

l = linspace(0,1,1000);
for i = 1:det_num
    l( l >= sel_range_norm(i,1) & l <= sel_range_norm(i,2) ) = [];
end
S12 = 1 - length(l) / 1000;

precision = S12 / (S1 + S2 - S12);
conti = max(sel_range_norm(:,2) - sel_range_norm(:,1));

end


