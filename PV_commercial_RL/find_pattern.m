% this code plots the load of uark to observe the pattern
% Yaze Li, University of Arkansas
clear all;close all;clc;
load('uark_data');
load('opt_old.mat');
L = importdata('Total Demand(kW) 2016_2017.xlsx');
ld_15min = L.data(~isnan(L.data(:)));
ld_hour = mean(reshape(ld_15min, 4,[]));
%% Find monthly patterns
[n_month,n_hour] = size(ld);
% figure;
% for month = [3,15]
%     plot(ld(month,:));
%     hold on;
% end
% No monthly patterns are found
%% Find weekly patterns
% n_week = 52;
% week_sum = [18:43];
% week_win = [1:17,44:52];
% Day = {'Fri';'Sat';'Sun';'Mon';'Tue';'Wed';'Thu'};
% figure;
% w = 24;
% for week = [w,w+52]
%     ld_week = ld_hour(168*(week-1)+1:168*week);
%     plot(ld_week)%,set(gca,'xtick',[1:7],'xticklabel',Day));
%     hold on;
% end
% Same weekday in a same month share a same pattern in load
%% Find similar patterns on the opt result
n_week = 4;
month = 2;
figure;
for week = 1:n_week
    q_opt_week = q_opt(month,168*(week-1)+1:168*week);
    plot(q_opt_week);
    hold on;
end
%%
figure