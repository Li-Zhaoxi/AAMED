clc;clear;close all;
% detect ellipse from an image;

%% AAMED Init. 
obj = mexAAMED(540, 960);
mexSetAAMEDParameters(obj, pi/3, 3.4, 0.77);
figure;

%% detect ellipses from an image.
img = imread('139_0018.jpg');
img = rgb2gray(img);

% If you want to detect another image, you can directly use
% mexdetectImagebyAAMED again. The image shape must be lower than defined
% shape. For example, size(img, 1) < 540, size(img, 2) < 960.
detElps = mexdetectImagebyAAMED(obj, img); 

imshow(img); hold on;
plot_aamed_res(detElps)
hold off;


mexdestoryAAMED(obj);