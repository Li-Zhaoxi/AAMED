function demo
% Listen to zoom events
plot(1:10);
h = zoom;
h.ActionPreCallback = @myprecallback;
h.ActionPostCallback = @mypostcallback;
h.Enable = 'on';

function myprecallback(obj,evd)
disp('A zoom is about to occur.');

function mypostcallback(obj,evd)
newLim = evd.Axes.XLim;
msgbox(sprintf('The new X-Limits are [%.2f %.2f].',newLim));
evd(1)