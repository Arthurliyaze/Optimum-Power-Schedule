% this code reads the load profile and wind profile from the xlsx and 
% preprocess them
% Yaze Li, University of Arkansas
% Note that get_profile.m is different from getprofiles.m in the MOST
% library
clear; close all; clc;

%% Load Profile
path = 'C:\Users\yazeli\OneDrive - University of Arkansas\Lab\04RTOPFwESS\Simulation\code\Load data';
subfolderInfo = dir(path);
subfolderNames = {subfolderInfo.name};
subfolderNames(ismember(subfolderNames,{'.','..'}))=[];
for fol_no=1:numel(subfolderNames)
    fileInfo = dir(strcat(path,'\',subfolderNames{fol_no}));
    fileNames = {fileInfo.name};
    fileNames(ismember(fileNames,{'.','..'}))=[];
    for file_no = 1:numel(fileNames)
        file = string(strcat(path,'\',subfolderNames{fol_no},'\',fileNames(file_no)));
        ImportedData1{fol_no,file_no} = importdata(file);
    end
end
%% Load Preprocess: 8 colums (P1,Q1,P2,Q2,P3,Q3,P4,Q4)
load_train = [];
load_test = [];
for month_no=1:fol_no
    monthData = [];
    for location_no=1:file_no
        monthData = [monthData,ImportedData1{month_no,location_no}.data.LoadData(:,end-1:end)];
    end
    [m,n] = size(monthData);
    p = file_no;
    monthData_hour = squeeze(mean(reshape(monthData, p, m/p, []),1));
    if month_no <= 12
        load_train = [load_train;monthData_hour];
    else
        load_test = [load_test;monthData_hour];
    end
end
% Change from kW to MW
load_train = load_train/1000;
load_test = load_test/1000;

% Scale the load from first 3 locations up to match location 4
load_train(:,1:6) = load_train(:,1:6)*10;
load_test(:,1:6) = load_test(:,1:6)*10;
%% Wind Profile: 1 column
ImportedData2 = importdata('FYV_edited.xlsx');
%ImportedData2(minute(ImportedData2.valid)~= 53,:) = [];
wind_speed = ImportedData2.data;
wind_speed(isnan(wind_speed))=0;

% Change from mph to m/s
wind_speed = wind_speed *0.44704;

A = 8495; % Sweep area
rho = 1.23; % air density
cp = 0.4; % power coefficient
single_turbine = 1/2*rho*A*wind_speed.^3*cp/1e6; % MW

n_turbine = 100; % 100 is used to scale wind power up to around 10 MW
wind = n_turbine * single_turbine;

[m,~] = size(load_train);
wind_train = wind(1:m);
wind_test = wind(m+1:end);
[m,n] = size(wind_test);
load_test(m+1:end,:)=[];

%% Plot the load and scale the wind power
close all
LineStyle = ["ro-","b^-","kd--","m*--"];
idx = 1493:1493+23;
figure
plot(load_test(idx,1),LineStyle(1),'LineWidth',1.5);
grid on
hold on
plot(load_test(idx,3),LineStyle(2),'LineWidth',1.5);
plot(load_test(idx,5),LineStyle(3),'LineWidth',1.5);
plot(load_test(idx,7),LineStyle(4),'LineWidth',1.5);
xlabel('Hour');
ylabel('Load (MW)');
legend({'Bus 10','Bus 12','Bus 13','Bus 14'},'Location','Northeast');
%legend('NW','Raz Std','SW','Wil Str')
% [~, hobj, ~, ~] = legend({'Bus 10','Bus 12','Bus 13','Bus 14'},'Fontsize',10,'Location','Northwest');
% hl = findobj(hobj,'type','line');
% set(hl,'LineWidth',5);
% ht = findobj(hobj,'type','text');
% set(ht,'FontSize',12);
xlim([1,24])

figure
plot(wind_test(idx),'bo-','LineWidth',1.5);
grid on
xlabel('Hour');
ylabel('Wind power (MW)');
xlim([1,24])
%% Save Profile
save profile.mat load_test load_train location_no month_no wind_test wind_train