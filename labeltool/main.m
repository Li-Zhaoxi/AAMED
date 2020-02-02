function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 10-Jan-2020 17:55:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @main_OpeningFcn, ...
    'gui_OutputFcn',  @main_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end



if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function figure_img_1_CreateFcn(hObject, eventdata, handles)

global handle_plot handle_ellipse handle_global_ellipses
handle_plot =[];
handle_ellipse =[];
handle_global_ellipses = [];
guidata(hObject, handles);


function open_new_img(tpath_name, tfilename, hObject, eventdata, handles)
% 清空数据
global filename pathname;
global input_img;
global select_points; % 选择的点的信息
global handle_plot handle_ellipse handle_global_ellipses; % 画点的句柄
global push_key; % 当前按键
global fitEllipses;


select_points = [];
input_img = [];
if ~isempty(handle_plot)
    delete(handle_plot)
end
if ~isempty(handle_ellipse)
    delete(handle_ellipse)
end
if ~isempty(handle_global_ellipses)
    delete(handle_global_ellipses)
end
push_key = [];
fitEllipses = [];

pathname = tpath_name;
filename = tfilename;


input_img = imshow([pathname, filename]);
set(handles.text_filepath, 'string', pathname);
set(handles.text_filename, 'string', filename);

hold on;
if exist([pathname, filename, '.mat'], 'file')
    tmp = load([pathname, filename,'.mat']);
    fitEllipses = tmp.fitEllipses;
    for i = 1:size(fitEllipses,1)
        [x,y] = GenerateElpData(fitEllipses(i,:));
        handle_global_ellipses = [handle_global_ellipses;plot(x,y,'-r','linewidth', 1.5)];
    end
end
hold off;

guidata(hObject, handles);


% 打开图片，记录坐标
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 清空数据
global filename pathname;
global input_img;
global select_points; % 选择的点的信息
global handle_plot handle_ellipse handle_global_ellipses; % 画点的句柄
global push_key; % 当前按键
global fitEllipses;


select_points = [];
input_img = [];
if ~isempty(handle_plot)
    delete(handle_plot)
end
if ~isempty(handle_ellipse)
    delete(handle_ellipse)
end
if ~isempty(handle_global_ellipses)
    delete(handle_global_ellipses)
end
push_key = [];
fitEllipses = [];


[filename, pathname] = uigetfile( ...
    {'*.jpg;*.bmp;*.tif;*.png;*.gif','All Image Files';...
    '*.*','All Files' },...
    '请选择要标记的图片');
try
    input_img = imshow([pathname, filename]);
    set(handles.text_filepath, 'string', pathname);
    set(handles.text_filename, 'string', filename);
catch
    warning(['打开图片：', pathname, filename, '失败。']);
end
guidata(hObject, handles);



% --- Executes on button press in bun_select_points.
function bun_select_points_Callback(hObject, eventdata, handles)
% hObject    handle to bun_select_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global select_points; % 选择的点的信息
global handle_plot handle_ellipse handle_global_ellipses; % 画点的句柄
global push_key; % 当前按键
global fitEllipses;


pt = [];
select_points = [];
push_key = [];


axes(handles.figure_img_1);
hold on;

if ~isempty(handle_plot)
    delete(handle_plot);
end
if ~isempty(handle_ellipse)
    delete(handle_ellipse);
end

fit_elp = [];
flag_wrong_points = 0;
flag_points_accept = 0;
accept_elp = [];
while 1
    [x,y] = ginput(1);
    if x < 0 || y < 0
        break;
    end
    if size(pt,1) > 0
        if x == pt(end,1) && y == pt(end,2) % 双击表示同一个点，则认为失败
            flag_wrong_points = 1;
            break;
        end
    end
    
    pt = [pt;x,y];
    if ~isempty(handle_plot)
        delete(handle_plot);
    end
    handle_plot = plot(pt(:,1),pt(:,2),'og','markerface', 'g');
    
    if size(pt, 1) >= 6 % 选择的点超过了6个，进行椭圆拟合
        delete(handle_plot);
        handle_plot = plot(pt(:,1),pt(:,2),'oy','markerface', 'y');
        fitelp = mexElliFit(pt);
        if fitelp(3) > 0 || fitelp(4) > 0 % 绘制拟合椭圆
            if ~isempty(handle_ellipse)
                delete(handle_ellipse);
            end
            fit_elp = [fitelp(1), fitelp(2), fitelp(3)/2, fitelp(4)/2, fitelp(5)/180*pi];
            [x,y] = GenerateElpData(fit_elp);
            handle_ellipse = plot(x,y,'-y');
            pause(1);
        end
        
        if strcmp(push_key, 'return') || strcmp(push_key, 'q')
            flag_points_accept = 1;
            break;
        end
    end
    
end

if flag_wrong_points
    delete(handle_plot);
    handle_plot = plot(pt(:,1),pt(:,2),'or','markerface', 'r');
end

if flag_points_accept
    delete(handle_plot);
    handle_plot = plot(pt(:,1),pt(:,2),'og','markerface', 'g');
    select_points = pt;
    
    delete(handle_ellipse);
    [x,y] = GenerateElpData(fit_elp);
    handle_global_ellipses = [handle_global_ellipses;plot(x,y,'-r','linewidth', 1.5)];
    fitEllipses = [fitEllipses; fit_elp];
    btn_save_Callback(hObject, eventdata, handles);
    fitEllipses
end



% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
global push_key;
global fileNames file_pointer_idx input_img folderpath
push_key = eventdata.Key;
key = get(gcf, 'currentcharacter');
if key == 'w'
    bun_select_points_Callback(hObject, eventdata, handles);
end

if key == 'a'
    if length(fileNames) > 0
        if file_pointer_idx > 1
            file_pointer_idx = file_pointer_idx - 1;
            set(handles.list_img, 'value', file_pointer_idx);
            
            open_new_img([folderpath, '\'], fileNames{file_pointer_idx}, hObject, eventdata, handles);
        end
    end
end

if key == 'd'
    if length(fileNames) > 0
        if file_pointer_idx < length(fileNames)
            file_pointer_idx = file_pointer_idx + 1;
            set(handles.list_img, 'value', file_pointer_idx);
            
            open_new_img([folderpath, '\'], fileNames{file_pointer_idx}, hObject, eventdata, handles);
        end
    end
end

if key == '1'
    pan on;
    pause(1);
    pan off;
end

if key == '2'
    zoom on;
    pause(1);
    zoom off;
end

if key == '3'
    zoom out;
    pause(1);
    zoom off;
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
global fitEllipses;
fitEllipses = [];
guidata(hObject, handles);






% --- 数据文件保存
function btn_save_Callback(hObject, eventdata, handles)
global fitEllipses select_points;
global filename pathname;

save([pathname, filename,'.mat'], 'fitEllipses', 'select_points');




% --- Executes on button press in btn_batch.
function btn_batch_Callback(hObject, eventdata, handles)
% hObject    handle to btn_batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fileNames file_pointer_idx input_img folderpath

folderpath = uigetdir('*.*','请选择文件夹');

fileFolder=fullfile(folderpath);

dirOutput=dir(fullfile(fileFolder,'*.jpg'));

fileNames={dirOutput.name};
while 1
    if strcmp(fileNames{1}, '.') || strcmp(fileNames{1}, '..')
        fileNames(1) = [];
    else
        break;
    end
end

if length(fileNames) > 0
    file_pointer_idx = 1;
    set(handles.list_img, 'string', fileNames);
    
    open_new_img([folderpath , '\'], fileNames{file_pointer_idx}, hObject, eventdata, handles);
    
else
    file_pointer_idx = 0;
    set(handles.list_img, 'string', []);
end


% --- Executes on selection change in list_img.
function list_img_Callback(hObject, eventdata, handles)
% hObject    handle to list_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns list_img contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_img

global fileNames file_pointer_idx input_img folderpath

file_pointer_idx = get(handles.list_img, 'Value');
open_new_img([folderpath, '\'], fileNames{file_pointer_idx}, hObject, eventdata, handles);
