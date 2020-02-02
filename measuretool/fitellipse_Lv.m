function [ellipse_shape, err, state] = fitellipse_Lv(dot)
state = 1;
scale = abs(dot);
dot(:,1) = dot(:,1)/scale(1);
dot(:,2) = dot(:,2)/scale(2);

X = [dot(:,1).^2 , 2*dot(:,1).*dot(:,2), dot(:,2).^2, 2*dot(:,1),2*dot(:,2),ones(size(dot,1),1)];
C = zeros(6,6); C(1,3) = 0.5; C(3,1) = 0.5; C(2,2) = -1;
fitData = X'*X;

err = det(fitData);

invS = inv(fitData);
y = ones(6,1);
x = invS*y;
[~,idx] = max(x);
arge = invS(:, idx);

k = arge(1)*arge(3) - arge(2)^2;
arge = arge/sqrt(k);
center_x = arge(2) * arge(5) - arge(3) * arge(4);
center_y = arge(2) * arge(4) - arge(1) * arge(5);
if abs(arge(1) - arge(3)) > 1e-10
    theta = atan(2*arge(2)/(arge(1)-arge(3)))/2;
else
    if arge(2)>0
        theta = pi /4;
    else
        theta = -pi/4;
    end
end

a1p = cos(theta) * arge(4) + sin(theta) * arge(5);
a2p = -sin(theta) * arge(4) + cos(theta) * arge(5);
a11p = arge(1) + tan(theta) * arge(2);
a22p = arge(3) - tan(theta) * arge(2);
C2 = a1p^2/a11p + a2p^2/a22p -arge(6);
dls_temp = C2/a11p;
if dls_temp>0
    major_axis = sqrt(dls_temp);
    minor_axis = sqrt(C2/a22p);
    if major_axis < minor_axis
        if theta >= 0
            theta = theta - pi/2;
        else
            theta = theta + pi/2;
        end
        dls_temp = major_axis;
        major_axis = minor_axis;
        minor_axis = dls_temp;
    end
    
else
    state = 0;
end


ellipse_shape(1) = center_x * scale(1);
ellipse_shape(2) = center_y * scale(2);
ellipse_shape(3) = major_axis * scale(1);
ellipse_shape(4) = minor_axis * scale(2);
ellipse_shape(5) = theta;
end