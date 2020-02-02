clc;clear;close all;
% 从训练数据集来训练参数

theta_arc = 10:1:90;
theta_arc = theta_arc/180*pi;
lambda_arc = 1.1:0.1:5;
T_val = 0.5:0.01:0.99;

dataset = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset';
method_name = 'training';
training_file = 'AAMEDForTraining1.exe';
iter_max = 100000;

%parpool('local',4);

%% init params

% theta_arc_i = theta_arc(round(length(theta_arc)/2));
% lambda_arc_i = lambda_arc(round(length(lambda_arc)/2));
% T_val_i = T_val(round(length(T_val)/2));

theta_arc_i = theta_arc(1);
lambda_arc_i = lambda_arc(1);
T_val_i = T_val(1);




F_iter = []; P_iter = []; R_iter = [];

T_overlap = 0.8;

for i = 1:iter_max
    clc;
    disp(['>>>The ',num2str(i),'th step optimization.']);

    %% 对theta_arc进行优化
    F_t = zeros(1,length(theta_arc)); P_t = zeros(1,length(theta_arc)); R_t = zeros(1,length(theta_arc));
    for k = 1:length(F_t)
        cmd=[training_file,' ',dataset,' ',num2str(theta_arc(k)),' ',num2str(lambda_arc_i),' ',num2str(T_val_i)];
        [status, result]=system(cmd,'-echo');
        if status == -1024
            disp('exe调用失败');
        end
        [P,R,F] = MeasureEllipsesFun_4_19([dataset,'\Training Images - Dataset Training\'], method_name, T_overlap);
        P_t(k) = P; R_t(k) = R; F_t(k) = F;
    end
    [val,idx] = max(F_t);
    theta_arc_i_1 = theta_arc(idx);
    disp(['Select theta_arc:', num2str(theta_arc_i_1),', Max F:', num2str(val)]);
    F_iter(end+1) = F_t(idx); P_iter(end+1) = P_t(idx); R_iter(end+1) = R_t(idx);
    
    
    %% 对lambda_arc进行优化
    F_t = zeros(1,length(lambda_arc)); P_t = zeros(1,length(lambda_arc)); R_t = zeros(1,length(lambda_arc));
    for k = 1:length(F_t)
        cmd=[training_file,' ',dataset,' ',num2str(theta_arc_i_1),' ',num2str(lambda_arc(k)),' ',num2str(T_val_i)];
        [status, result]=system(cmd,'-echo');
        if status == -1024
            disp('exe调用失败');
        end
        [P,R,F] = MeasureEllipsesFun_4_19([dataset,'\Training Images - Dataset Training\'], method_name, T_overlap);
        P_t(k) = P; R_t(k) = R; F_t(k) = F;
    end
    [val,idx] = max(F_t);
    lambda_arc_i_1 = lambda_arc(idx);
    disp(['Select lambda_arc:', num2str(lambda_arc_i_1),', Max F:', num2str(val)]);
    F_iter(end+1) = F_t(idx); P_iter(end+1) = P_t(idx); R_iter(end+1) = R_t(idx);
    
    
    %% 对T_val进行优化
    F_t = zeros(1,length(T_val)); P_t = zeros(1,length(T_val)); R_t = zeros(1,length(T_val));
    for k = 1:length(F_t)
        cmd=[training_file,' ',dataset,' ',num2str(theta_arc_i_1),' ',num2str(lambda_arc_i_1),' ',num2str(T_val(k))];
        [status, result]=system(cmd,'-echo');
        if status == -1024
            disp('exe调用失败');
        end
        [P,R,F] = MeasureEllipsesFun_4_19([dataset,'\Training Images - Dataset Training\'], method_name, T_overlap);
        P_t(k) = P; R_t(k) = R; F_t(k) = F;
    end
    [val,idx] = max(F_t);
    T_val_i_1 = T_val(idx);
    disp(['Select T_val:', num2str(T_val_i_1),', Max F:', num2str(val)]);
    F_iter(end+1) = F_t(idx); P_iter(end+1) = P_t(idx); R_iter(end+1) = R_t(idx);
    
%     %% 更新结果
%     F_iter(i) = F_t(idx); P_iter(i) = P_t(idx); R_iter(i) = R_t(idx);
    
    if abs(theta_arc_i_1 - theta_arc_i) < 1e-6 && abs(lambda_arc_i_1 - lambda_arc_i) < 1e-6 && abs(T_val_i_1 - T_val_i) < 1e-6
        break;
    end
    
    theta_arc_i = theta_arc_i_1; lambda_arc_i = lambda_arc_i_1; T_val_i = T_val_i_1;
end
disp(['Final Parms:',' theta_arc:', num2str(theta_arc_i_1), ' lambda_arc:', num2str(lambda_arc_i_1), ' T_val:', num2str(T_val_i_1)]);
save PRF.mat F_iter P_iter R_iter theta_arc_i_1 lambda_arc_i_1 T_val_i_1;