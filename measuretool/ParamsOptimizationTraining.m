clc;clear;close all;
% 从训练数据集来训练参数

% T_dp = 1:0.1:5;
% theta_arc = 5:1:90;
% theta_arc = theta_arc/180*pi;
% lambda_arc = 1.1:0.1:8;
% N_grad = 2:1:10;
% T_val = 0.1:0.01:0.99;

T_dp = 1:0.1:1.5;
theta_arc = 30:1:60;
theta_arc = theta_arc/180*pi;
lambda_arc = 3:0.1:4;
N_grad = 2:1:5;
T_val = 0.45:0.01:0.65;

dataset = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset';
method_name = 'training';
training_file = 'AAMEDForTraining12.exe';
iter_max = 100000;

%parpool('local',4);

%% init params
% T_dp_i = (T_dp(1) + T_dp(end))/2;
% theta_arc_i = (theta_arc(1) + theta_arc(end))/2;
% lambda_arc_i = (lambda_arc(1) + lambda_arc(end))/2;
% N_grad_i = (N_grad(1) + N_grad(end))/2;
% T_val_i = (T_val(1) + T_val(end))/2;


T_dp_i = T_dp(1);
theta_arc_i = theta_arc(1);
lambda_arc_i = lambda_arc(1);
N_grad_i = N_grad(1);
T_val_i = T_val(1);

% T_dp_i = 1.1;
% theta_arc_i = 0.68068;
% lambda_arc_i = 3;
% N_grad_i = 6;
% T_val_i = 0.58;


F_iter = []; P_iter = []; R_iter = [];

T_overlap = 0.8;

for i = 1:iter_max
    clc;
    disp(['>>>The ',num2str(i),'th step optimization.']);
    
    %% 对T_dp进行优化
    F_t = zeros(1,length(T_dp)); P_t = zeros(1,length(T_dp)); R_t = zeros(1,length(T_dp));
    for k = 1:length(F_t)
        cmd=[training_file,' ',dataset,' ',num2str(T_dp(k)),' ',num2str(theta_arc_i),' ',num2str(lambda_arc_i),' ',num2str(T_val_i),' ',num2str(N_grad_i)];
        [status, result]=system(cmd,'-echo');
        if status == -1024
            disp('exe调用失败');
        end
        [P,R,F] = MeasureEllipsesFun([dataset,'\Training Images - Dataset Training\'], method_name, T_overlap);
        P_t(k) = P; R_t(k) = R; F_t(k) = F;
    end
    [val,idx] = max(F_t);
    T_dp_i_1 = T_dp(idx);
    disp(['Select T_dp:', num2str(T_dp_i_1),', Max F:', num2str(val)]);
    F_iter(end+1) = F_t(idx); P_iter(end+1) = P_t(idx); R_iter(end+1) = R_t(idx);

    %% 对theta_arc进行优化
    F_t = zeros(1,length(theta_arc)); P_t = zeros(1,length(theta_arc)); R_t = zeros(1,length(theta_arc));
    for k = 1:length(F_t)
        cmd=[training_file,' ',dataset,' ',num2str(T_dp_i_1),' ',num2str(theta_arc(k)),' ',num2str(lambda_arc_i),' ',num2str(T_val_i),' ',num2str(N_grad_i)];
        [status, result]=system(cmd,'-echo');
        if status == -1024
            disp('exe调用失败');
        end
        [P,R,F] = MeasureEllipsesFun([dataset,'\Training Images - Dataset Training\'], method_name, T_overlap);
        P_t(k) = P; R_t(k) = R; F_t(k) = F;
    end
    [val,idx] = max(F_t);
    theta_arc_i_1 = theta_arc(idx);
    disp(['Select theta_arc:', num2str(theta_arc_i_1),', Max F:', num2str(val)]);
    F_iter(end+1) = F_t(idx); P_iter(end+1) = P_t(idx); R_iter(end+1) = R_t(idx);
    
    
    %% 对lambda_arc进行优化
    F_t = zeros(1,length(lambda_arc)); P_t = zeros(1,length(lambda_arc)); R_t = zeros(1,length(lambda_arc));
    for k = 1:length(F_t)
        cmd=[training_file,' ',dataset,' ',num2str(T_dp_i_1),' ',num2str(theta_arc_i_1),' ',num2str(lambda_arc(k)),' ',num2str(T_val_i),' ',num2str(N_grad_i)];
        [status, result]=system(cmd,'-echo');
        if status == -1024
            disp('exe调用失败');
        end
        [P,R,F] = MeasureEllipsesFun([dataset,'\Training Images - Dataset Training\'], method_name, T_overlap);
        P_t(k) = P; R_t(k) = R; F_t(k) = F;
    end
    [val,idx] = max(F_t);
    lambda_arc_i_1 = lambda_arc(idx);
    disp(['Select lambda_arc:', num2str(lambda_arc_i_1),', Max F:', num2str(val)]);
    F_iter(end+1) = F_t(idx); P_iter(end+1) = P_t(idx); R_iter(end+1) = R_t(idx);
    
    %% 对N_grad进行优化
    F_t = zeros(1,length(N_grad)); P_t = zeros(1,length(N_grad)); R_t = zeros(1,length(N_grad));
    for k = 1:length(F_t)
        cmd=[training_file,' ',dataset,' ',num2str(T_dp_i_1),' ',num2str(theta_arc_i_1),' ',num2str(lambda_arc_i_1),' ',num2str(T_val_i),' ',num2str(N_grad(k))];
        [status, result]=system(cmd,'-echo');
        if status == -1024
            disp('exe调用失败');
        end
        [P,R,F] = MeasureEllipsesFun([dataset,'\Training Images - Dataset Training\'], method_name, T_overlap);
        P_t(k) = P; R_t(k) = R; F_t(k) = F;
    end
    [val,idx] = max(F_t);
    N_grad_i_1 = N_grad(idx);
    disp(['Select N_grad:', num2str(N_grad_i_1),', Max F:', num2str(val)]);
    F_iter(end+1) = F_t(idx); P_iter(end+1) = P_t(idx); R_iter(end+1) = R_t(idx);
    
    %% 对T_val进行优化
    F_t = zeros(1,length(T_val)); P_t = zeros(1,length(T_val)); R_t = zeros(1,length(T_val));
    for k = 1:length(F_t)
        cmd=[training_file,' ',dataset,' ',num2str(T_dp_i_1),' ',num2str(theta_arc_i_1),' ',num2str(lambda_arc_i_1),' ',num2str(T_val(k)),' ',num2str(N_grad_i_1)];
        [status, result]=system(cmd,'-echo');
        if status == -1024
            disp('exe调用失败');
        end
        [P,R,F] = MeasureEllipsesFun([dataset,'\Training Images - Dataset Training\'], method_name, T_overlap);
        P_t(k) = P; R_t(k) = R; F_t(k) = F;
    end
    [val,idx] = max(F_t);
    T_val_i_1 = T_val(idx);
    disp(['Select T_val:', num2str(T_val_i_1),', Max F:', num2str(val)]);
    F_iter(end+1) = F_t(idx); P_iter(end+1) = P_t(idx); R_iter(end+1) = R_t(idx);
    
%     %% 更新结果
%     F_iter(i) = F_t(idx); P_iter(i) = P_t(idx); R_iter(i) = R_t(idx);
    
    if abs(T_dp_i_1 - T_dp_i) < 1e-6 && abs(theta_arc_i_1 - theta_arc_i) < 1e-6 ...
            && abs(lambda_arc_i_1 - lambda_arc_i) < 1e-6 && abs(N_grad_i_1 - N_grad_i) < 1e-6 && abs(T_val_i_1 - T_val_i) < 1e-6
        break;
    end
    
    T_dp_i = T_dp_i_1; theta_arc_i = theta_arc_i_1; lambda_arc_i = lambda_arc_i_1; N_grad_i = N_grad_i_1; T_val_i = T_val_i_1;
end
disp(['Final Parms:','T_dp:', num2str(T_dp_i_1), ' theta_arc:', ...
    num2str(theta_arc_i_1), ' lambda_arc:', num2str(lambda_arc_i_1), ' N_grad:', num2str(N_grad_i_1), ' T_val:', num2str(T_val_i_1)]);
save PRF.mat F_iter P_iter R_iter T_dp_i_1 theta_arc_i_1 lambda_arc_i_1 N_grad_i_1 T_val_i_1;