% this code reads the load profile and wind profile from the xlsx and
% preprocess them
% Yaze Li, University of Arkansas
% Note that get_profile.m is different from getprofiles.m in the MOST
% library
clear; close all; clc;

%% Wind Profile
Table = readtable('SUX.csv');
Table = fillmissing(Table,'previous');
[hour_mean, hour_data, count_hour] = groupsummary(Table.sped, [month(Table.valid),day(Table.valid),hour(Table.valid)], 'mean');
dt = diff(hour_data{1,3});
lost_begin = find(dt~= 1 & dt~= -23);
lost_length = dt(lost_begin);
for i = 1:length(lost_begin)
    hour_mean = [hour_mean(1:lost_begin(i)-1);hour_mean(lost_begin(i))*ones(lost_length(i),1);hour_mean(lost_begin(i)+1:end)];
end
clearvars -except hour_mean
%% Change from mph to m/s
wind_speed = hour_mean' *0.44704;

A = 8495; % Sweep area
rho = 1.23; % air density
cp = 0.4; % power coefficient
single_turbine = 1/2*rho*A*wind_speed.^3*cp/1e6; % W to MW (1MW base)

n_turbine = 5; % 5 is used to scale wind farm to 5 MW
wind = n_turbine * single_turbine;
clearvars -except single_turbine n_turbine wind

%% PV Profile
ImportedData2 = xlsread('pvwatts_hourly.csv'); % solar energy in W every hour in a year
single_pv = ImportedData2(1:end-1,11)'/1e6; % W to MW (500kW base)
single_pv = single_pv(~isnan(single_pv));

n_pv = 10; % 10 is used to scale pv power up to around 5 MW
pv = n_pv*single_pv;
clear ImportedData2

%% Residential Load Profile
ImportedData3 = xlsread('USA_SD_Sioux.Falls.726510_TMY2.csv');
single_rload = ImportedData3(:,13)'/1e3; % kW to MW (one house)

n_house = 300;
rload = n_house*single_rload; % MW for 300 houses
clear ImportedData3

%% Commercial Load Profile
myDir = 'D:\OneDrive - University of Arkansas\Lab\06Truck_base_MEC\Simulation\code_new\USA_SD_Sioux.Falls-Foss.Field.726510_TMY3';%laptop
myFiles = dir(fullfile(myDir,'*.csv'));
filenames={myFiles(:).name}';
cload = zeros(1,24*365);
for i = 1:length(filenames)
    ImportedData4 = importdata(char(filenames(i)));
    cload = cload + sum(ImportedData4.data,2)'/1e3; % kW to MW (16 loads)
end
cload = cload/8; % kW to MW for 2 commercial loads
clear myDir myFiles filenames ImportedData4

%% Industrial Load Profile
ImportedData5 = importdata('LoadProfile_30IPs_2017.csv').data;
iload_15 = sum(ImportedData5,2);
iload = mean(reshape(iload_15,4,[]),1)/1e3; % kW to MW (30 locations)
iload = [iload iload(end-23:end)];
clear ImportedData5 iload_15

%%
week = repelem(mod(4:4+365-1,7),24);
weekday_hour = find(week>0 & week<6);
nt = 4*(wind+pv)-(7*rload+2*cload+iload);
nt_weekday = nt(weekday_hour);
nt_weekend = setdiff(nt,nt_weekday);

%%
nt_weekday = reshape(nt_weekday,24,[]);
nt_weekend = reshape(nt_weekend,24,[]);
nt_weekday_pos = nt_weekday-min(nt_weekday,[],'all');
nt_weekend_pos = nt_weekend-min(nt_weekend,[],'all');
%%
% close all
% figure
% h = histogram(nt_weekday(1,:),'Normalization','pdf');
% %xlim([-50,150])
% h.BinWidth = 2;
% hold
% x = 0:.1:range(nt_weekday,'all');
% pd = fitdist(nt_weekday_pos(1,:)','gamma');
% gpdf = gampdf(x,pd.a,pd.b);
% plot(x+min(nt_weekday,[],'all'),gpdf)
% % b = mean(nt_weekday(1,:))/var(nt_weekday(1,:));
% % a = b*mean(nt_weekday(1,:));
% % gpdf = gampdf(range,a,b);
% % plot(range,gpdf)
% hold off
% %%
% close all
% figure;
% for hour = 1:12
%     subplot(3,4,hour)
%     h = histogram(nt_weekday(hour,:),'Normalization','pdf');
%     h.BinWidth = 10;
%     hold
%     x = 0:.1:range(nt_weekday,'all');
%     pd = fitdist(nt_weekday_pos(hour,:)','gamma');
%     gpdf = gampdf(x,pd.a,pd.b);
%     plot(x+min(nt_weekday,[],'all'),gpdf,'LineWidth',1.5)
%     hold off
%     title([num2str(hour),' oclock'])
% end
% 
% figure
% for hour = 13:24
%     subplot(3,4,hour-12)
%     histogram(nt_weekday(hour,:),'Normalization','pdf')
%     xh.BinWidth = 10;
%     hold
%     x = 0:.1:range(nt_weekday,'all');
%     pd = fitdist(nt_weekday_pos(hour,:)','gamma');
%     gpdf = gampdf(x,pd.a,pd.b);
%     plot(x+min(nt_weekday,[],'all'),gpdf,'LineWidth',1.5)
%     hold off
%     title([num2str(hour),' oclock'])
% end
% %%
% close all
% figure;
% for hour = 1:12
%     subplot(3,4,hour)
%     h = histogram(nt_weekend(hour,:),'Normalization','pdf');
%     h.BinWidth = 10;
%     hold
%     x = 0:.1:range(nt_weekend,'all');
%     pd = fitdist(nt_weekend_pos(hour,:)','gamma');
%     gpdf = gampdf(x,pd.a,pd.b);
%     plot(x+min(nt_weekend,[],'all'),gpdf)
%     hold off
%     title([num2str(hour),' oclock'])
% end
% 
% figure
% for hour = 13:24
%     subplot(3,4,hour-12)
%     histogram(nt_weekend(hour,:),'Normalization','pdf')
%     xh.BinWidth = 10;
%     hold
%     x = 0:.1:range(nt_weekend,'all');
%     pd = fitdist(nt_weekend_pos(hour,:)','gamma');
%     gpdf = gampdf(x,pd.a,pd.b);
%     plot(x+min(nt_weekend,[],'all'),gpdf)
%     hold off
%     title([num2str(hour),' oclock'])
% end
% %%
% close all
% figure
% plot(1:hour,mean(nt_weekday,2),'ro-','LineWidth',1.5)
% hold on
% grid on
% plot(1:hour,std(nt_weekday,0,2),'b^-','LineWidth',1.5)
% legend('Mean','Std')
% title('Statistics of weekday')
% xlabel('Hour')
% 
% figure
% plot(1:hour,mean(nt_weekend,2),'ro-','LineWidth',1.5)
% hold on
% grid on
% plot(1:hour,std(nt_weekend,0,2),'b^-','LineWidth',1.5)
% legend('Mean','Std')
% title('Statistics of weekend')
% xlabel('Hour')
%%
figure;
plot(wind,'--','LineWidth',1.5)
hold on
grid on
plot(pv,'-','LineWidth',1.5)
%xlim([1,24])
legend('Wind (2MW)','Solar (2MW)')
xlabel('Hour')
ylabel('Renewable power (MW)')
title('Renewable profile of Sioux Falls in 2021')
%%
figure
plot(rload,'ro-','LineWidth',1.5)
hold on
grid on
plot(cload,'b^-','LineWidth',1.5)
plot(iload,'kd--','LineWidth',1.5)
%xlim([1,24])
legend('Residential','Commercial','Industrial')
xlabel('Hour')
ylabel('Load (MW)')
title('Load profile of Sioux Falls in 2021')

%%
day=200;
figure
plot(4*(wind+pv),'ro-','LineWidth',1.5)
hold on
grid on
plot(7*rload+2*cload+iload,'b^-','LineWidth',1.5)
xlim([24*day+1,24*day+24])
legend('Renew','Total load')
xlabel('Hour')
ylabel('Power (MW)')
title('Total renew v.s. load of Sioux Falls in 2021')
%%
%save profile.mat wind pv rload cload iload
%%
%close all
figure
plot(nt)
xlim([1,24])
grid on
title('Time Series of renew minus load')
xlabel('Hour in a month')
ylabel('RE Curtailment')
%%
figure
plot((wind+pv),'ro-','LineWidth',1.5)
hold on
grid on
plot(rload,'b^-','LineWidth',1.5)
legend('Renew at one bus','Load at one bus')
xlabel('Hour')
ylabel('Load (MW)')

%%
clear
load('profile.mat');
Pload = zeros(8760,10);
Pload(:,[4,10])= repmat(cload',1,2);
Pload(:,1)= iload';
Pload(:,[2,3,5,6,7,8,9])= repmat(rload',1,7);
Renew = repmat((wind+pv)',1,4);