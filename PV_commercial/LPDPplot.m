%this code plot annual_bill for LP DP
clear all;close all;clc;
%%
load('LPyear.mat');
lpbill=bill;
clearvars -except prebill lpbill;
%%
load('DPyear05.mat');
dpbill=bill;
clearvars -except prebill lpbill dpbill;
%%
y=[prebill';dpbill;lpbill']';
b = bar(y,'FaceColor','flat');
grid on;
xlabel('Month');
ylabel('Electricity cost ($)');
legend('Without ESS, Annual=$613.59k','With ESS MILP, Annual=$350.79k','With ESS DP, Annual=$359.75k');
ylim([0,70000])
title('Monthly Electricity Bill')