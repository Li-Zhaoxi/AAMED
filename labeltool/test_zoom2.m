function demo
% Allow a line to have its own 'ButtonDownFcn' callback.
hLine = plot(rand(1,10));
hLine.ButtonDownFcn = 'disp(''This executes'')';
hLine.Tag = 'DoNotIgnore';
h = zoom;
h.ButtonDownFilter = @mycallback;
h.Enable = 'on';
% mouse click on the line

function [flag] = mycallback(obj,event_obj)
% If the tag of the object is 'DoNotIgnore', then return true.
objTag = obj.Tag;
if strcmpi(objTag,'DoNotIgnore')
    flag = true;
else
    flag = false;
end