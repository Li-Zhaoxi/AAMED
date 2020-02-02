function res = ellipses_cluster(ellipses)

if isempty(ellipses)
    res = ellipses;
    return;
end

th_Da = 0.1;
th_Db = 0.1;
th_Dr = 0.1;

th_Dc_ratio = 0.1;
th_Dr_circle = 0.9;

ellipses(:,5) = ellipses(:,5)/pi*180;
iNumOfEllipses = size(ellipses,1);
if isempty(ellipses)
    res = ellipses;
    return;
end

res = ellipses(1,:);

bFoundCluster = 0;

for i = 2:iNumOfEllipses
    e1 = ellipses(i,:);
    
    sz_clusters = size(res, 1);
    
    ba_e1 = e1(4)/e1(3);
    Decc1 = e1(4)/e1(3);
    
    bFoundCluster = 0;
    
    for j = 1:sz_clusters
        e2 = res(j,:);
        
        ba_e2 = e1(4)/e1(3);
        th_Dc = min([e1(4), e2(4)]) * th_Dc_ratio;
        th_Dc = th_Dc*th_Dc;
        
        Dc = (e1(1) - e2(1))^2 + (e1(2) - e2(2))^2;
        if Dc > th_Dc
            continue;
        end
        
        Da = abs(e1(3) - e2(3))/max([e1(3), e2(3)]);
        if Da > th_Da
            continue;
        end
        
        Db = abs(e1(4) - e2(4))/min([e1(4), e2(4)]);
        if Db > th_Db
            continue;
        end
        
        
        Dr = GetMinAnglePI(e1(5), e2(5))/pi;
        if Dr > th_Dr && ba_e1 < th_Dr_circle && ba_e2 < th_Dr_circle
            continue;
        end
        
        bFoundCluster = 1;
        break;

    end
    if bFoundCluster
        res = [res;e1];
    end
    
end

res(:,5) = res(:,5)/180*pi;




end




function dis = GetMinAnglePI(alpha, beta)

pi2 = 2*pi;

a = mod(alpha + pi2, pi2);
b = mod(beta + pi2, pi2);


if a > pi
    a = a - pi;
end

if b > pi
    b = b - pi;
end

if a > b
    tmp = a;
    a = b;
    b = tmp;
end

diff1 = b - a;
diff2 = pi - diff1;

dis = min([diff1, diff2]);





end

