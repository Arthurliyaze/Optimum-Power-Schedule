%this code compares one year MILP & DP different step size
clear all; close all; clc;
load('all_data.mat');

%% compares one year MILP & DP different step size
load('MILP1_m.mat');
load('DP1_q.mat');
nb=90;
ns=120;
MILP_abill=sum(ebill);
DP_abill=cost-Pb*nb*12-Ps*ns*12;
pe=(DP_abill-MILP_abill)/MILP_abill;%percentage error for different DPq every month
%% compares one year MILP & DP with step size 10 each month 1st year
load('DP1_q10.mat');
x=ebill;
y=DP1_q10_ebill;
pe=(y-x)./x;
figure
bill=[obill';x;y]';
b = bar(bill,'FaceColor','flat');
grid on;
xlabel('Month');
ylabel('Electricity cost ($)');
legend('Without ESS, Annual=$613.59k','With ESS MILP, Annual=$361.03k','With ESS DP, Annual=$371.26k');
ylim([0,70000])
title('Monthly Electricity Bill in the 1st year')
%%
load('DP10_q10.mat');
DP_ebill=ebill;
qld=qld_10(1:120,:);
obill=sum(max(qld,0).*P_years(1:120,:),2)+Dmax*max(qld,[],2);
Csave=obill'-DP_ebill;
for i=1:10
    A(12*i-11:12*i)=1.04^(-i+1);
end
NPV=cumsum(Csave.*A);
find(NPV>96*5900+120*6400)