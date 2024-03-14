close all;clear;clc;
%% Load data
load('result_ac.mat');
load('result_mpc12.mat');
load('result_ddpg.mat');
soc_ac = abs(min(10,5+cumsum(sch_ac,2)));
soc_mpc = abs(min(10,5+cumsum(sch_mpc,2)));
soc_ddpg = abs(min(10,5+cumsum(sch_ddpg,2)));
%% Plot by cases
LineStyle = ["ro-","b^-","kd--","m*--"];
figure
grid on 
hold on
for i=1:4
    plot(soc_ac(i,:),LineStyle(i),'LineWidth',1.5);
end
legend('Bus 3','Bus 6','Bus 8','Bus 11','Location','Southwest')
xlim([1,24])
ylim([-1,12])
xlabel('Hour')
ylabel('Storage SOC')

figure
grid on 
hold on
for i=1:4
    plot(soc_mpc(i,:),LineStyle(i),'LineWidth',1.5);
end
legend('Bus 3','Bus 6','Bus 8','Bus 11','Location','Southwest')
xlim([1,24])
ylim([-1,12])
xlabel('Hour')
ylabel('Storage SOC')

figure
grid on 
hold on
for i=1:4
    plot(soc_ddpg(i,:),LineStyle(i),'LineWidth',1.5);
end
legend('Bus 3','Bus 6','Bus 8','Bus 11','Location','Southwest')
xlim([1,24])
ylim([-1,12])
xlabel('Hour')
ylabel('Storage SOC')
%% Plot by buses
close all;
LineStyle = ["ro-","b^-","kd--","m*--"];
bus = ["3","6","8","11"];
figure
for i = 1:4
    data1 = soc_ac(i,:);
    data2 = soc_mpc(i,:);
    data3 = soc_ddpg(i,:);
    subplot(2,2,i)
    plot(data1,LineStyle(1),'LineWidth',1.5);
    hold on
    grid on
    plot(data2,LineStyle(2),'LineWidth',1.5);
    plot(data3,LineStyle(3),'LineWidth',1.5);
    xlabel('Hour')
    ylabel(append('SOC at bus ',bus(i),' (MWh)'))
    xlim([1,24])
    ylim([-1,11])
    set(gca,'XTick',(2:4:22))
    set(gca,'YTick',(0:5:10))
end
legend('OPF','MPC','DDPG','Orientation','horizontal');
legend('boxoff')