clc;clear all;close all;
% 参数讨论

dirpath = 'F:\Arcs Adjacency Matrix Based Fast Ellipse Detection\ellipse_dataset\Random Images - Dataset #1\'; % Data set path
dataset = 'random';

T_dp = 1:0.1:5;
theta_fsa = 5:1:90;
theta_fsa = theta_fsa/180*pi;
length_fsa = 1.1:0.1:8;
T_val = 0.1:0.01:0.99;
grad_num = 2:1:10;

P = cell(1,5);
R = cell(1,5);
F = cell(1,5);

T_dp_init = 1.5;
theta_fsa_init = pi/4;
length_fsa_init = 3.5;
T_val_init = 0.65;
grad_num_init = 5;

%% Step 1: 参数T_dp调试
step = 1;
P{step} = zeros(1,length(T_dp)); R{step} = zeros(1,length(T_dp)); F{step} = zeros(1,length(T_dp));
for i = 1:length(T_dp)
    disp(['调试T_dp参数-------------------->',num2str(T_dp(i))]);
    cmd=['FLED.exe',' ',dataset,' ',num2str(T_dp(i)),' ',num2str(theta_fsa_init),' ',num2str(length_fsa_init),' ',num2str(T_val_init),' ',num2str(grad_num_init)];
    [status, result]=system(cmd,'-echo');
    if status == -1024
        disp('exe调用失败');
    end
    [Pt,Rt,Ft] = MeasureEllipsesFun(dirpath, dataset);
    P{step}(i) = Pt; R{step}(i) = Rt; F{step}(i) = Ft;
end

%% Step 2: 参数theta_fsa调试
step = 2;
P{step} = zeros(1,length(theta_fsa)); R{step} = zeros(1,length(theta_fsa)); F{step} = zeros(1,length(theta_fsa));
for i = 1:length(theta_fsa)
    disp(['调试theta_fsa参数-------------------->',num2str(theta_fsa(i))]);
    cmd=['FLED.exe',' ',dataset,' ',num2str(T_dp_init),' ',num2str(theta_fsa(i)),' ',num2str(length_fsa_init),' ',num2str(T_val_init),' ',num2str(grad_num_init)];
    [status, result]=system(cmd,'-echo');
    if status == -1024
        disp('exe调用失败');
    end
    [Pt,Rt,Ft] = MeasureEllipsesFun(dirpath, dataset);
    P{step}(i) = Pt; R{step}(i) = Rt; F{step}(i) = Ft;
end

%% Step 3: 参数length_fsa调试
step = 3;
P{step} = zeros(1,length(length_fsa)); R{step} = zeros(1,length(length_fsa)); F{step} = zeros(1,length(length_fsa));
for i = 1:length(length_fsa)
    disp(['调试length_fsa参数-------------------->',num2str(length_fsa(i))]);
    cmd=['FLED.exe',' ',dataset,' ',num2str(T_dp_init),' ',num2str(theta_fsa_init),' ',num2str(length_fsa(i)),' ',num2str(T_val_init),' ',num2str(grad_num_init)];
    [status, result]=system(cmd,'-echo');
    if status == -1024
        disp('exe调用失败');
    end
    [Pt,Rt,Ft] = MeasureEllipsesFun(dirpath, dataset);
    P{step}(i) = Pt; R{step}(i) = Rt; F{step}(i) = Ft;
end

%% Step 4: 参数T_val调试
step = 4;
P{step} = zeros(1,length(T_val)); R{step} = zeros(1,length(T_val)); F{step} = zeros(1,length(T_val));
for i = 1:length(T_val)
    disp(['调试T_val参数-------------------->',num2str(T_val(i))]);
    cmd=['FLED.exe',' ',dataset,' ',num2str(T_dp_init),' ',num2str(theta_fsa_init),' ',num2str(length_fsa_init),' ',num2str(T_val(i)),' ',num2str(grad_num_init)];
    [status, result]=system(cmd,'-echo');
    if status == -1024
        disp('exe调用失败');
    end
    [Pt,Rt,Ft] = MeasureEllipsesFun(dirpath, dataset);
    P{step}(i) = Pt; R{step}(i) = Rt; F{step}(i) = Ft;
end

%% Step 5: 参数grad_num调试
step = 5;
P{step} = zeros(1,length(grad_num)); R{step} = zeros(1,length(grad_num)); F{step} = zeros(1,length(grad_num));
for i = 1:length(grad_num)
    disp(['调试grad_num参数-------------------->',num2str(grad_num(i))]);
    cmd=['FLED.exe',' ',dataset,' ',num2str(T_dp_init),' ',num2str(theta_fsa_init),' ',num2str(length_fsa_init),' ',num2str(T_val_init),' ',num2str(grad_num(i))];
    [status, result]=system(cmd,'-echo');
    if status == -1024
        disp('exe调用失败');
    end
    [Pt,Rt,Ft] = MeasureEllipsesFun(dirpath, dataset);
    P{step}(i) = Pt; R{step}(i) = Rt; F{step}(i) = Ft;
end

% save ParamsResult.mat P R F;
save([dataset,'.mat'],'P','R','F');
