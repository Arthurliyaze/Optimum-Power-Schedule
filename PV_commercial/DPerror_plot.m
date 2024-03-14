%this code calculate DP result with different q and plot
clear all; close all; clc;
%%
[y100,c100]=DPbill(1,89,120,100);
[y50,c50]=DPbill(1,89,120,50);
[y25,c25]=DPbill(1,89,120,25);
[y20,c20]=DPbill(1,89,120,20);
[y10,c10]=DPbill(1,89,120,10);
[y5,c5]=DPbill(1,89,120,5);
%%
clear y100 y50 y25 y20 y10 y5;
c100=c100+359000-c5;
c50=c50+359000-c5;
c25=c25+359000-c5;
c20=c20+359000-c5;
c10=c10+359000-c5;
c5=c5+359000-c5;
%%
lp=353310;
e100=(c100-lp)/lp;
e50=(c50-lp)/lp;
e25=(c25-lp)/lp;
e20=(c20-lp)/lp;
e10=(c10-lp)/lp;
e5=(c5-lp)/lp;
%%
save('dperror');
%%
close all;
step=[5,10,20,25,50,100];
error=[e5,e10,e20,e25,e50,e100];
bill=[c5,c10,c20,c25,c50,c100];
figure;
plot(step,100*error,'-*r','LineWidth',1.5);
grid on;
xlabel('step^{-1}')
ylabel('error with LP (%)')
%%
clear all;clc;
tic
DPbill(1,89,120,100);
toc
