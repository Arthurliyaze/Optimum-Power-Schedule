 % this script extract the proportion of the trip demands in each hour
% Yaze Li, University of Arkansas
clear; close all; clc;
%% Load the typical hourly volume data
table = importdata('TYPICAL_HOURLY_VOLUME_DATA.csv');
mean_hour = mean(table.data,1);
pro_hour = mean_hour/sum(mean_hour);
%% Plot the proportion
% figure
% plot(1:24,pro_hour*100)
% grid on
% xticks(0:4:24)
% xlim([0,24])
% ylim([0,10])
% xlabel('Time (h)')
% ylabel('Hourly demand proportion (%)')
save proportion.mat pro_hour