clc;clear;close all;
% 验证我们的每个验证因子的有效性

%% 设置参数初值
theta_arc_init = pi/3;
lambda_arc_init = 3.4;
T_val_init = 0.77;

%% 设置数据集信息

data_root_path = 'F:\Arcs-Adjacency-Matrix-Based-Fast-Ellipse-Detection\ellipse_dataset\';

dataset_name = [{'Synthetic Images - Occluded Ellipses'},...
    {'Synthetic Images - Overlap Ellipses'},...
    {'Prasad Images - Dataset Prasad'},...
    {'Random Images - Dataset #1'},...
    {'Smartphone Images - Dataset #2'},...
    {'Concentric Ellipses - Dataset Synthetic'},...
    {'Concurrent Ellipses - Dataset Synthetic'},...
    {'Satellite Images - Dataset Meng #1'},...
    {'Satellite Images - Dataset Meng #2'}];

gt_label = [{'occluded'},{'overlap'},{'prasad'},{'random'},{'smartphone'},...
    {'concentric'},{'concurrent'},{'satellite1'}, {'satellite2'}];

methods_name = 'FLED';
method_label = 'fled';

%% 处处验证结果

PA = cell(1,6);
PA{1} = zeros(length(dataset_name), 3); % WithoutSI, 每个数据集的PRF
PA{2} = zeros(length(dataset_name), 3); % WithoutGI, 每个数据集的PRF
PA{3} = zeros(length(dataset_name), 3); % WithoutWI, 每个数据集的PRF
PA{4} = zeros(length(dataset_name), 3); % WithoutSIGI, 每个数据集的PRF
PA{5} = zeros(length(dataset_name), 3); % WithoutSIWI, 每个数据集的PRF
PA{6} = zeros(length(dataset_name), 3); % 正常结果, 每个数据集的PRF

%% Step 1: 验证形状参数的有效性
disp('Step 1: 正在进行分析Without SI.');
idx_parm = 1;

for dsi = 1:length(dataset_name)
    
    fprintf(['-->正在测量数据集：',dataset_name{dsi}]);
    
    if strcmp(gt_label{dsi},'occluded') || strcmp(gt_label{dsi},'overlap')...
            || strcmp(gt_label{dsi},'concentric') || strcmp(gt_label{dsi},'concurrent')
        isCanny = 0;
    else
        isCanny = 1;
    end
    
    fprintf('.');
    cmd=['AAMEDWithoutSI.exe',' ',...
        data_root_path,' ',... % 数据集地址
        gt_label{dsi}, ' ',...  % 数据集名称
        num2str(theta_arc_init),' ',...
        num2str(lambda_arc_init),' ',...
        num2str(T_val_init),' ',...
        num2str(isCanny)];
    [status, result]=system(cmd);
    if status == -1024
        error('exe调用失败');
    end
    
    [P,R,F] = AAMEDMeasureEllipseFun_4_22(data_root_path, dataset_name{dsi},...
        gt_label{dsi}, methods_name, method_label);
    
    PA{idx_parm}(dsi,1) = P;
    PA{idx_parm}(dsi,2) = R;
    PA{idx_parm}(dsi,3) = F;
    fprintf('\n');
end


%% Step 2: 验证梯度参数的有效性
disp('Step 2: 正在进行分析Without GI.');
idx_parm = 2;

for dsi = 1:length(dataset_name)
    
    fprintf(['-->正在测量数据集：',dataset_name{dsi}]);
    
    if strcmp(gt_label{dsi},'occluded') || strcmp(gt_label{dsi},'overlap')...
            || strcmp(gt_label{dsi},'concentric') || strcmp(gt_label{dsi},'concurrent')
        isCanny = 0;
    else
        isCanny = 1;
    end
    
    fprintf('.');
    cmd=['AAMEDWithoutGI.exe',' ',...
        data_root_path,' ',... % 数据集地址
        gt_label{dsi}, ' ',...  % 数据集名称
        num2str(theta_arc_init),' ',...
        num2str(lambda_arc_init),' ',...
        num2str(T_val_init),' ',...
        num2str(isCanny)];
    [status, result]=system(cmd);
    if status == -1024
        error('exe调用失败');
    end
    
    [P,R,F] = AAMEDMeasureEllipseFun_4_22(data_root_path, dataset_name{dsi},...
        gt_label{dsi}, methods_name, method_label);
    
    PA{idx_parm}(dsi,1) = P;
    PA{idx_parm}(dsi,2) = R;
    PA{idx_parm}(dsi,3) = F;
    fprintf('\n');
end


%% Step 3: 验证形状参数的有效性
disp('Step 3: 正在进行分析Without WI.');
idx_parm = 3;

for dsi = 1:length(dataset_name)
    
    fprintf(['-->正在测量数据集：',dataset_name{dsi}]);
    
    if strcmp(gt_label{dsi},'occluded') || strcmp(gt_label{dsi},'overlap')...
            || strcmp(gt_label{dsi},'concentric') || strcmp(gt_label{dsi},'concurrent')
        isCanny = 0;
    else
        isCanny = 1;
    end
    
    fprintf('.');
    cmd=['AAMEDWithoutWI.exe',' ',...
        data_root_path,' ',... % 数据集地址
        gt_label{dsi}, ' ',...  % 数据集名称
        num2str(theta_arc_init),' ',...
        num2str(lambda_arc_init),' ',...
        num2str(T_val_init),' ',...
        num2str(isCanny)];
    [status, result]=system(cmd);
    if status == -1024
        error('exe调用失败');
    end
    
    [P,R,F] = AAMEDMeasureEllipseFun_4_22(data_root_path, dataset_name{dsi},...
        gt_label{dsi}, methods_name, method_label);
    
    PA{idx_parm}(dsi,1) = P;
    PA{idx_parm}(dsi,2) = R;
    PA{idx_parm}(dsi,3) = F;
    fprintf('\n');
end

%% Step 4: Without SI GI验证形状参数的有效性
disp('Step 4: 正在进行分析Without SI GI.');
idx_parm = 4;

for dsi = 1:length(dataset_name)
    
    fprintf(['-->正在测量数据集：',dataset_name{dsi}]);
    
    if strcmp(gt_label{dsi},'occluded') || strcmp(gt_label{dsi},'overlap')...
            || strcmp(gt_label{dsi},'concentric') || strcmp(gt_label{dsi},'concurrent')
        isCanny = 0;
    else
        isCanny = 1;
    end
    
    fprintf('.');
    cmd=['AAMEDWithoutSIGI.exe',' ',...
        data_root_path,' ',... % 数据集地址
        gt_label{dsi}, ' ',...  % 数据集名称
        num2str(theta_arc_init),' ',...
        num2str(lambda_arc_init),' ',...
        num2str(T_val_init),' ',...
        num2str(isCanny)];
    [status, result]=system(cmd);
    if status == -1024
        error('exe调用失败');
    end
    
    [P,R,F] = AAMEDMeasureEllipseFun_4_22(data_root_path, dataset_name{dsi},...
        gt_label{dsi}, methods_name, method_label);
    
    PA{idx_parm}(dsi,1) = P;
    PA{idx_parm}(dsi,2) = R;
    PA{idx_parm}(dsi,3) = F;
    fprintf('\n');
end

%% Step 5: Without SI WI
disp('Step 5: 正在进行分析Without SI WI.');
idx_parm = 5;

for dsi = 1:length(dataset_name)
    
    fprintf(['-->正在测量数据集：',dataset_name{dsi}]);
    
    if strcmp(gt_label{dsi},'occluded') || strcmp(gt_label{dsi},'overlap')...
            || strcmp(gt_label{dsi},'concentric') || strcmp(gt_label{dsi},'concurrent')
        isCanny = 0;
    else
        isCanny = 1;
    end
    
    fprintf('.');
    cmd=['AAMEDWithoutSIWI.exe',' ',...
        data_root_path,' ',... % 数据集地址
        gt_label{dsi}, ' ',...  % 数据集名称
        num2str(theta_arc_init),' ',...
        num2str(lambda_arc_init),' ',...
        num2str(T_val_init),' ',...
        num2str(isCanny)];
    [status, result]=system(cmd);
    if status == -1024
        error('exe调用失败');
    end
    
    [P,R,F] = AAMEDMeasureEllipseFun_4_22(data_root_path, dataset_name{dsi},...
        gt_label{dsi}, methods_name, method_label);
    
    PA{idx_parm}(dsi,1) = P;
    PA{idx_parm}(dsi,2) = R;
    PA{idx_parm}(dsi,3) = F;
    fprintf('\n');
end

%% Step 6: 原始结果
disp('Step 6: 正在进行分析原始结果.');
idx_parm = 6;

for dsi = 1:length(dataset_name)
    
    fprintf(['-->正在测量数据集：',dataset_name{dsi}]);
    
    if strcmp(gt_label{dsi},'occluded') || strcmp(gt_label{dsi},'overlap')...
            || strcmp(gt_label{dsi},'concentric') || strcmp(gt_label{dsi},'concurrent')
        isCanny = 0;
    else
        isCanny = 1;
    end
    
    fprintf('.');
    cmd=['AAMEDWithAll.exe',' ',...
        data_root_path,' ',... % 数据集地址
        gt_label{dsi}, ' ',...  % 数据集名称
        num2str(theta_arc_init),' ',...
        num2str(lambda_arc_init),' ',...
        num2str(T_val_init),' ',...
        num2str(isCanny)];
    [status, result]=system(cmd);
    if status == -1024
        error('exe调用失败');
    end
    
    [P,R,F] = AAMEDMeasureEllipseFun_4_22(data_root_path, dataset_name{dsi},...
        gt_label{dsi}, methods_name, method_label);
    
    PA{idx_parm}(dsi,1) = P;
    PA{idx_parm}(dsi,2) = R;
    PA{idx_parm}(dsi,3) = F;
    fprintf('\n');
end

save ValidationIndex.mat PA
