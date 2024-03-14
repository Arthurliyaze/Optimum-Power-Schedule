% this code draws the figures for the paper
% Yaze Li, University of Arkansas
close all;clc;
load('uark_data');
load('q_py_13.mat');
load('q_py_dqn_13.mat');
close all
idx = [232,254,256,258,259,278,280,305,327];
qnet(idx)=0;
%%
h = 1:744;
figure;
plot(h,l-q_sol,'b-','LineWidth',1.5);
hold on
grid on
plot(h,qnet,'r--','LineWidth',1.5);
plot(h,max(0,l-q_sol+q_dqn),'m:','LineWidth',1.5);
plot(h,max(0,l-q_sol+q),'k-.','LineWidth',1.5);

xlabel('Hours in the peak week of July, 2017')
ylabel('The energy bought from utility (kWh)')
legend('PV only','NLP','DQN','DDPG')
xlim([169,168*2])
ylim([0,22000])

figure;
plot(h,c/(13.5*nb)*100,'r--','LineWidth',1.5);
hold on;
grid on
plot(h,soc_dqn*100,'m:','LineWidth',1.5);
plot(h,soc*100,'k-.','LineWidth',1.5);

xlabel('Hours in the peak week of Jan, 2017')
ylabel('Battery SOC (%)')
xlim([1,168])
ylim([0,110])
legend('NLP','DQN','DDPG')