clc;clear;close all;

filename=dir('../src/*.cpp');
all_cpp_files = filename.name;


disp('Build mexAAMED');
mex_cpp = 'mexAAMED.cpp';
cmd_str = ['mex ', mex_cpp, ' '];
for i = 1:length(filename)
    cmd_str = [cmd_str, ...
        filename(i).folder,'\',filename(i).name,' '];
end
cmd_str = [cmd_str, '-I''D:\opencv3.1\opencv\build\include'' -L''D:\opencv3.1\opencv\build\x64\vc14\lib'' -lopencv_world310'];
eval(cmd_str);

disp('Build mexdestoryAAMED');
mex_cpp = 'mexdestoryAAMED.cpp';
cmd_str = ['mex ', mex_cpp, ' '];
for i = 1:length(filename)
    cmd_str = [cmd_str, ...
        filename(i).folder,'\',filename(i).name,' '];
end
cmd_str = [cmd_str, '-I''D:\opencv3.1\opencv\build\include'' -L''D:\opencv3.1\opencv\build\x64\vc14\lib'' -lopencv_world310'];
eval(cmd_str);

disp('Build mexSetAAMEDParameters');
mex_cpp = 'mexSetAAMEDParameters.cpp';
cmd_str = ['mex ', mex_cpp, ' '];
for i = 1:length(filename)
    cmd_str = [cmd_str, ...
        filename(i).folder,'\',filename(i).name,' '];
end
cmd_str = [cmd_str, '-I''D:\opencv3.1\opencv\build\include'' -L''D:\opencv3.1\opencv\build\x64\vc14\lib'' -lopencv_world310'];
eval(cmd_str);

disp('Build mexdetectImagebyAAMED');
mex_cpp = 'mexdetectImagebyAAMED.cpp';
cmd_str = ['mex ', mex_cpp, ' '];
for i = 1:length(filename)
    cmd_str = [cmd_str, ...
        filename(i).folder,'\',filename(i).name,' '];
end
cmd_str = [cmd_str, '-I''D:\opencv3.1\opencv\build\include'' -L''D:\opencv3.1\opencv\build\x64\vc14\lib'' -lopencv_world310'];
eval(cmd_str);
