%this code fits time-q and time-h
%% cdtime fit
clear all;close all;clc;
x=[1/100,1/50,1/25,1/20,1/10,1/5]*13.5*90;
y=[384.914,663.118,1263.419,1459.700,3008.448,5834.442];
x2 = x.*log(x);
p=polyfit(x2,y,1);
x1=linspace(0,1400);
y1=polyval(p,x1);
figure;
plot(x2,y,'*r')
%plot(x2,y,'*r',x1,y1,'-r','LineWidth',1.5);
grid on;
xlabel('step^{-1}')
ylabel('CD algorithm time (s)')
%%
save('cdtime')
%% dptime q fit
clear all;close all;clc;
x=[1/100,1/50,1/25,1/20,1/10,1/5]*13.5*90;
x2 = x.*log(x);
y=[22.375,35.874,71.375,86.186,174.025,359.0783];
p=polyfit(x2,y,1);
x1=linspace(0,300);
x3 = x1.*log(x1);
y1=polyval(p,x3);
figure;
plot(x,y,'ob',x1,y1,'--b','LineWidth',1.5);
%plot(x,y,'ob','LineWidth',1.5);
grid on;
legend('Measured simulation time','Curve fitting (O(n log n))')
xlabel('number of states (n)')
ylabel('DP time (s)')
%%
save('dp-qtime')
%% lptime H fit
clear all;close all;clc;
x=[1,3,6,12];
y=[8.337,53.561,161.777,567.781];
%logx=log(x);
%logy=log(y);
%p=polyfit(logx,logy,1);
%x1=linspace(0,log(12));
x1=linspace(.5,30);
y1=exp(2.1130)*x1.^(1.6887);
figure;
%plot(logx,logy,'*r',x1,y1,'-r','LineWidth',1.5);
plot(x,y,'*r',x1,y1,'-r','LineWidth',1.5);
grid on;
set(gca, 'XScale','log','YScale', 'log')
%ylim([0,log(600)]);
xlabel('number of month')
ylabel('MILP time (s)')
%%
save('lptime')
%% dptime H fit
clear all;close all;clc;
load('t.mat');
x=[1,3,6,12]*30*24;
for i =1:3
    p = polyfit(x,t(i,:),1);
    x1=linspace(0,10000);
    y1(i,:) =polyval(p,x1);
end
figure;
plot(x,t(3,:),'*r',x1,y1(3,:),'-r','LineWidth',1.5);
grid on;
hold on;
plot(x,t(2,:),'ob',x1,y1(2,:),'--b','LineWidth',1.5);
plot(x,t(1,:),'^k',x1,y1(1,:),'-.k','LineWidth',1.5);
legend('Step size = 20','Curve fitting (O(H))','Step size = 50','Curve fitting (O(H))','Step size = 100','Curve fitting (O(H))')
xlabel('H, Number of hours')
ylabel('DP time (s)')
%%
save('dp-htime')