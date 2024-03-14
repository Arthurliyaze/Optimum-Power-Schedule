% this code calculates the generation given the sch result
% Yaze Li, University of Arkansas
clear; close all; clc;

%%
load('result_Pg.mat');
%%
LineStyle = ["ro-","b^-","kd--","m*--"];
bus = ["1","2","3","6","8"];
figure
% for j=1:3
%     subplot(2,2,j)
%     plot(Pg_noess(j,:),LineStyle(4),'LineWidth',1.5)
%     grid on
%     hold on
%     plot(Pg_opf(j,:),LineStyle(1),'LineWidth',1.5)
%     plot(Pg_mpc(j,:),LineStyle(2),'LineWidth',1.5)
%     plot(Pg_ddpg(j,:),LineStyle(3),'LineWidth',1.5)
%
%     xlim([1,24])
%     ylim([-1,12])
%     xlabel('Hour')
%     ylabel(append('P^g at bus ',bus(j),' (MW)'))
%     set(gca,'XTick',(2:4:22))
%     set(gca,'YTick',(0:5:10))
% end
% legend('No storage','OPF','MPC','DDPG','Location','Southeast')

for j=1:3
    plot(Pg_noess(j,:),LineStyle(1),'LineWidth',1.5)
    grid on
    hold on
    plot(Pg_opf(j,:),LineStyle(2),'LineWidth',1.5)
    plot(Pg_mpc(j,:),LineStyle(3),'LineWidth',1.5)
    plot(Pg_ddpg(j,:),LineStyle(4),'LineWidth',1.5)
end
text(9,200,'\downarrow Bus 1')
text(9,45,'\downarrow Bus 2')
text(9,10,'\downarrow Bus 3')
legend('No storage','OPF','MPC','DDPG','Location','Northeast')
xlim([1,24])
ylim([-10,240])
xlabel('Hour')
ylabel(append('Active power generation (MW)'))
set(gca,'XTick',(2:4:22))
%set(gca,'YTick',(0:5:10))