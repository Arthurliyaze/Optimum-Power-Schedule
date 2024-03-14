%this code plots figures for DP
clear all; close all; clc;
load('DPyear.mat');
%%
figure;
hour=1:length(qld);
plot(hour,qld(6,:),'r-','LineWidth',1.5);
grid on;
hold on;
plot(hour,max(0,qld(6,:)-qre(6,:)),'b--','LineWidth',1.5);
plot(hour,max(0,qnet(6,:)),'k-.','LineWidth',1.5);
xlim([0,24*7]);
ylim([-100,1000]);
legend('Without PV and Battery','With PV','With PV and Battery');
xlabel('Time (hour)');
ylabel('Power bought (kW)');
%%
figure;
hour=1:length(qld);
plot(hour,qld(12,:),'r-','LineWidth',1.5);
grid on;
hold on;
plot(hour,max(0,qld(12,:)-qre(12,:)),'b--','LineWidth',1.5);
plot(hour,max(0,qnet(12,:)),'k-.','LineWidth',1.5);
xlim([0,24*7]);
ylim([-100,1000]);
legend('Without PV and Battery','With PV','With PV and Battery');
xlabel('Time (hour)');
ylabel('Power bought (kW)');