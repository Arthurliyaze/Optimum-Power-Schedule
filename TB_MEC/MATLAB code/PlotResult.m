% this code plots the truck behavior
% Yaze Li, University of Arkansas
clear; close all; clc;
%%
load('Case3test.mat');
%states(28:31,23)=[30;30;0;0]/100;
%states(28:31,22)=[60;60;0;0]/100;
%states(29:31,21)=[80;0;0]/100;
%%
h = 1:24;
pld = sum(states(2:11,:));
pr = sum(states(12:15,:));
loc = states(16:19,:)+1;
soc = states(28:31,:)*100;
%%
figure
plot(h,pld,'ro-','LineWidth',1.5)
hold on
grid on
plot(h,pr,'b^-','LineWidth',1.5)

xlim([1,24])
legend('Total load','Renew')
xlabel('Hour')
ylabel('Power (MW)')
title('Total renew v.s. load of Sioux Falls on a test day')

% figure
% plot(h,loc(1,:),'ro-','LineWidth',1.5)
% hold on
% grid on
% plot(h,loc(2,:),'b^-','LineWidth',1.5)
% plot(h,loc(3,:),'g*-','LineWidth',1.5)
% plot(h,loc(4,:),'mx-','LineWidth',1.5)
% xlim([1,24])
% legend('1','2','3','4')
% xlabel('Hour')
% ylabel('Bus number')
% title('MESS locations on a test day')

% figure
% plot(h,soc(1,:),'ro-','LineWidth',1.5)
% hold on
% grid on
% plot(h,soc(2,:),'b^-','LineWidth',1.5)
% plot(h,soc(3,:),'g*-','LineWidth',1.5)
% plot(h,soc(4,:),'mx-','LineWidth',1.5)
% xlim([1,24])
% legend('1','2','3','4')
% xlabel('Hour')
% ylabel('Percentage (%)')
% title('MESS state of charge on a test day')
%%
z = zeros(4,1);
sch = [diff(soc')'/10,z];
figure
subplot(2,1,1);
grid on
hold on
yyaxis left
plot(h,loc(1,:),'ko-','LineWidth',1.5)
xlabel('Hour')
ylabel('Bus number')
ylim([0,15])
title('MESS 1 location and behavior on a test day')
yyaxis right
bar(h,sch(1,:))
xlabel('Hour')
ylabel('MW')
ylim([-4,4])
hold off

subplot(2,1,2);
grid on
hold on
yyaxis left
plot(h,loc(2,:),'ko-','LineWidth',1.5)
xlabel('Hour')
ylabel('Bus number')
title('MESS 2 location and behavior on a test day')
ylim([0,15])
yyaxis right
bar(h,sch(2,:))
xlabel('Hour')
ylabel('MW')
hold off

figure
subplot(2,1,1);
grid on
hold on
yyaxis left
plot(h,loc(3,:),'ko-','LineWidth',1.5)
xlabel('Hour')
ylabel('Bus number')
title('MESS 3 location and behavior on a test day')
yyaxis right
bar(h,sch(3,:))
xlabel('Hour')
ylabel('MW')
hold off

subplot(2,1,2);
grid on
hold on
yyaxis left
plot(h,loc(4,:),'ko-','LineWidth',1.5)
xlabel('Hour')
ylabel('Bus number')
title('MESS 4 location and behavior on a test day')
yyaxis right
bar(h,sch(4,:))
xlabel('Hour')
ylabel('MW')
ylim([-4,4])
hold off