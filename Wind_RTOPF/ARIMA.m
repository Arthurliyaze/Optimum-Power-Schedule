% this code builds an ARMA model for load and wind forecasting
% Yaze Li, University of Arkansas
clear; close all; clc;

%% Import load and wind
load('profile.mat');
[H, ~] = size(load_test);
%% Generate ARMA model for load
nt = 24;
mdl = [];
mape1 = zeros(location_no,1);
mape24 = zeros(location_no,nt);
yf = zeros(location_no,H);
yf24 = zeros(location_no,nt,H-nt+1);
for n = 1:location_no
    col = 2*n-1;
    Mdl = arima(2,1,2);
    idxpre = 1:Mdl.P;
    idxest = (Mdl.P+1):H;
    EstMdl = estimate(Mdl,load_train(idxest,col),'Y0',load_train(idxpre,col));
    mdl = [mdl, EstMdl];
    
    % Calculate mean absolute percentage error (MAPE) of 1-hour ahead
    yf0 = [load_train(end-Mdl.P+1:end,col);load_test(1:end-1,col)];
    
    for i = 1:H
        yf(n,i) = forecast(EstMdl,1,yf0(i:i+2));
    end
    y = load_test(:,col)';
    mape1(n) = mean(abs((y-yf(n,:))./y));
    ape = zeros(H-nt+1,nt);
    yf024 = yf0(1:end-nt+1);
    for i = 1:H-nt+1
        %24-hour ahead forecast
        yf24(n,:,i) = forecast(EstMdl,nt,yf024(i:i+2));
        idxest24 = i:(i+nt-1);
        y0 = load_test(idxest24,col)';
        ape(i,:) = abs((y0-yf24(n,:,i))./y0);
    end
    mape24(n,:) = mean(ape,1);
end

%% Generate ARMA model for wind
nt = 24;
wind_pre = zeros(nt,H-nt+1);
Mdl = arima(2,1,2);
idxpre = 1:Mdl.P;
idxest = (Mdl.P+1):H;
EstMdl = estimate(Mdl,log(wind_train(idxest)+0.1),'Y0',log(wind_train(idxpre)+0.1));

% Calculate mean square error (MSE) of 24-hour ahead
log_wf0 = [log(wind_train(end-Mdl.P+1:end)+0.1);log(wind_test(1:end-1)+0.1)];
se = zeros(H-nt+1,nt);
log_wf024 = log_wf0(1:end-nt+1);
for i = 1:H-nt+1
    %24-hour ahead forecast
    log_wind_pre = forecast(EstMdl,nt,log_wf024(i:i+2));
    idxest24 = i:(i+nt-1);
    w0(:,i) = wind_test(idxest24);
    wind_pre(:,i) = max(exp(log_wind_pre)-0.1,0);
    se(i,:) = sqrt((w0(:,i)-wind_pre(:,i)).^2);
end
wind_mean = mean(w0,2)';
mse_wind = mean(se,1)./wind_mean;

%% Plot prediction result
close all
idx = 1420+72+[1:24]; % March 4th, 2017
T = 1:length(idx);

for location = 1:location_no
    ld = load_test(idx,2*location-1);
    ld_pre = 
% location = 4;
% figure;
% plot(T,load_test(idx,2*location-1),'r.-','MarkerSize',15,'LineWidth',1.5);
% grid on
% hold on
% plot(yf(location,idx),'bo--','MarkerSize',5,'LineWidth',1.5);
% legend('Real','Predicted')
% xlim([1,24])
% xlabel('Hour');
% ylabel('Load(MW)');

figure
plot(T,wind_test(idx),'r.-','MarkerSize',15,'LineWidth',1.5);
grid on
hold on
plot(T,wind_pre(1,idx),'bo--','MarkerSize',5,'LineWidth',1.5);
legend('Real','Predicted')
xlim([1,24])
xlabel('Hour');
ylabel('Wind(MW)');

%% Plot prediction error vs time lag
close all;
figure;
T = 1:24;
% plot(T,mape24(1,:),'o-','LineWidth',1.5);
% grid on
% hold on
% plot(T,mape24(2,:),'^--','LineWidth',1.5);
% plot(T,mape24(3,:),'x:','LineWidth',1.5);
% plot(T,mape24(4,:),'*-.','LineWidth',1.5);
% legend('NW','Raz Std','SW','Will Str')
% xlim([1,24])
% ylim([0,0.7])
% xlabel('Time lag(hour)')
% ylabel('MAPE')

figure;
plot(T,mse_wind,'ko-','LineWidth',1.5);
grid on
xlim([1,24])
%ylim([0,0.7])
xlabel('Time lag(hour)')
ylabel('MSE')
%% Save predicted data
save predict.mat load_pre wind_pre