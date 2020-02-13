clc;clear;close all;
% AAMED Data Viewer


%% Read all data.
fid = fopen('aamed', 'r');
d = fread(fid, inf, 'uchar=>uchar');
fclose(fid);

%% uint8 to char
str = char(d');

%% Find data.

% 1 Basic
idx = strfind(str, 'basic');
idx_start = idx(1);
idx_end = strfind(str, 'endbasic.');
tdata = d((idx_start + length('basic')):(idx_end - 1));
aamed_basic = mexcvtBasicData(tdata);

% 2 EdgeContours
idx = strfind(str, 'edgecontours');
idx_start = idx(1);
idx_end = strfind(str, 'endedgecontours.');
tdata = d((idx_start + length('edgecontours')):(idx_end - 1));
aamed_edgecontours = mexcvtVVP(tdata);

% 3 DPContours
idx = strfind(str, 'dpcontours');
idx_start = idx(1);
idx_end = strfind(str, 'enddpcontours.');
tdata = d((idx_start + length('dpcontours')):(idx_end - 1));
aamed_dpcontours = mexcvtVVP(tdata);

% 4 arccontours
idx = strfind(str, 'arccontours');
idx_start = idx(1);
idx_end = strfind(str, 'endarccontours.');
tdata = d((idx_start + length('arccontours')):(idx_end - 1));
aamed_arccontours = mexcvtVVP(tdata);

% 5 arcadjacencymatrix
idx = strfind(str, 'arcadjacencymatrix');
idx_start = idx(1);
idx_end = strfind(str, 'endarcadjacencymatrix.');
tdata = d((idx_start + length('arcadjacencymatrix')):(idx_end - 1));
aamed_AAM = mexcvtAAM(tdata);


% 6 detectedellipses
idx = strfind(str, 'detectedellipses');
idx_start = idx(1);
idx_end = strfind(str, 'enddetectedellipses.');
tdata = d((idx_start + length('detectedellipses')):(idx_end - 1));
aamed_ED = mexcvtRRect(tdata);


%% Draw Results.

img = zeros(aamed_basic.iROWS, aamed_basic.iCOLS) + 255;
img = uint8(img);
figure(1);
for i = 1:length(aamed_edgecontours)
    pt = aamed_edgecontours{i};
    idx = (pt(:,2)) * aamed_basic.iROWS + pt(:,1) + 1;
    img(idx) = 0;
end
imshow(img);
title('edgecontours');

figure(2);
imshow(img); hold on;
for i = 1:length(aamed_dpcontours)
    pt = aamed_dpcontours{i};
    plot(pt(:,2) + 1, pt(:,1) + 1, '-r','linewidth',1.5);
    plot(pt(1,2) + 1, pt(1,1) + 1, 'ob','linewidth',1.5, 'markerface','k');
    text(pt(1,2) + 1, pt(1,1) + 1, num2str(i), 'fontsize',8);
end
title('dpcontours');
hold off;

figure(3);
imshow(img); hold on;
for i = 1:length(aamed_arccontours)
    pt = aamed_arccontours{i};
    plot(pt(:,2) + 1, pt(:,1) + 1, '-r','linewidth',1.5);
    plot(pt(1,2) + 1, pt(1,1) + 1, 'ob','linewidth',1.5, 'markerface','k');
    text(pt(1,2) + 1, pt(1,1) + 1, num2str(i), 'fontsize',14);
end
title('aamed\_arccontours');
hold off;


figure;
imshow(img); hold on;
for i = 1:size(aamed_ED,1)
    elp = aamed_ED(i,:);
    temp = elp(1);
    elp(1) = elp(2);
    elp(2) = temp;
    elp(1:2) = elp(1:2) + 1;
    elp(3:4) = elp(3:4)/2;
    elp(5) = -elp(5)/180*pi;
    [x,y] = GenerateElpData(elp);
    plot(x, y, '-r','linewidth',1.5);
end
hold off;
