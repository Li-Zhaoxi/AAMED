clc;clear;close all;

global push_key;

push_key = [];


% [filename, pathname] = uigetfile( ...
%     {'*.jpg;*.tif;*.png;*.gif','All Image Files';...
%     '*.*','All Files' },...
%     '请选择要标记的图片');

img = imread([filename, pathname]);




handle_fig = figure('name','Image Label Tools');
set(handle_fig,'windowkeypressfcn',@callback_keyboard_pression_fun);

imshow(img);
hold on;


while 1
    if strcmp(push_key, 'q') % 按下q退出标记
        break;
    end
    pt = [];
    while 1
        if strcmp(push_key, 'return') % 按下回车结束当前标记
            break;
        end
    end
    
    pause(0.1);
end