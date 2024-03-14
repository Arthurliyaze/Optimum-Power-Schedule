%this code plots figures for LP
clear all; close all; clc;
%load('LPyear.mat');
load('LP01_new.mat');
%%
figure;
hour=1:length(qld);
subplot(211)
plot(hour,qld(7,:),'ro-','LineWidth',1.5);
grid on;
hold on;
plot(hour,max(0,qld(7,:)-qre(7,:)),'b^:','LineWidth',1.5);
plot(hour,max(0,qnet(7,:)),'kx-.','LineWidth',1.5);
plot([10,10],[-100,900],'k--','LineWidth',1);
plot([17,17],[-100,900],'k--','LineWidth',1);
xlim([0,24]);
ylim([-100,900]);
hleg=legend('Without PV or Battery','With PV','With PV and Battery',...
    'Orientation','horizontal');
set(hleg, 'Position', [.13,.94,.77,.05]);
%xlabel('Time (hour)');
ylabel('Net load q^{net}(i) (kWh)');
subplot(212)
plot(hour,S(7,:)/1000,'kx-.','LineWidth',1.5);
grid on;
hold on;
plot([10,10],[-0.1,1.3],'k--','LineWidth',1);
plot([17,17],[-0.1,1.3],'k--','LineWidth',1);
xlim([0,24]);
ylim([-0.1,1.3]);
xlabel('Time (hour)');
ylabel('Battery SOC s(i) (MWh)');
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
legend('No PV or Battery','PV-only','Battery-assisted PV');
xlabel('Time (hour)');
ylabel('Net load q^{net}(i) (kWh)');
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
legend('No PV or Battery','PV-only','Battery-assisted PV');
xlabel('Time (hour)');
ylabel('Net load q^{net}(i) (kWh)');