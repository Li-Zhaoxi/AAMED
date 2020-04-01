function plot_aamed_res(detElps)

hold on;
for i = 1:size(detElps,1)
    tmp = detElps(i,:);
    tmp = [tmp(2)+1, tmp(1) + 1, tmp(4)/2, tmp(3)/2, -tmp(5)/180*pi];
    [x,y] = GenerateElpData(tmp);
    plot(x,y,'-r','linewidth',1.5);
end
hold off;

end