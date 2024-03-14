% this code uses MINLP to help find reward parameters
% Yaze Li, University of Arkansas
clear all;close all;clc;
load('uark_data');
load('opt.mat');
%% cvx MINLP for each month
phi = 100;
ns = 82;
nb = 5500;
gamma_e = 0.94;
Dmax = 16.08;
%Dmax=0;
h = ones(1,24);
h(13:18) = -1;
q_subopt = zeros(21,31);

for m = 4
m
t = T(m);
day = t/24;
%day = 1
C_day = 0;
C_pv = 0;
qnet = [];
soc  = [];


%%
for d = 1:day
    indx = 24*d-23 : 24*d;
    q_sol = re(m,indx);
    l = ld(m,indx);
    tou = p(m,indx);
    cvx_solver mosek_2
    cvx_begin quiet
    variable qc(1,24) nonnegative
    variable qd(1,24) nonnegative
    expression c(1,24)
    q = qc-qd;
    %q = 0;
    expression qnet_day(1,24);
    expression Q(1,24);
    qnet_day=max(0,l-q_sol+q);%energy bought from the utility
    
    for i=1:23
        c(i+1)=c(i)+gamma_e*qc(i)-qd(i)/gamma_e;
    end

    expression CE;
    CE=sum(qnet_day.*tou);%Energy charge
    
    expression CD;
    CD=Dmax*(max(qnet_day));%Demand charge
    
    minimize CE+CD;
    
    subject to %5kw/13.5kWh
    qc<=nb*5;
    qd<=nb*5;
    0<=c<=5500*13.5;
    c(1)==0;
    %c(24)==20000;
    cvx_end
    
    C_day = C_day + cvx_optval;
    qnet = [qnet, qnet_day];
    soc = [soc, c];
    C_pv = C_pv + sum((l-q_sol).*tou) + max(l-q_sol)*Dmax;
    q_subopt(m,d) = qnet_day(12);
end
%%
C_day
CE=sum(qnet.*p(m,1:24*day));
CD=Dmax*(max(qnet));
C_apply = CE+CD
Real_opt = cost_opt(m)
C_pv
end
%%
close all
figure
plot(qnet)
hold on;
plot(ld(m,:)-re(m,:))
plot(qnet_opt(m,:))
xlim([1,744])

figure
plot(soc/(5500*13.5))
xlim([1,168])
% %%
% sum(qnet(1:24))
% sum(ld(6,1:24)-re(6,1:24))
% sum(qnet_opt(6,1:24))