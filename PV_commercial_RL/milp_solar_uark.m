% this code uses MINLP to calculate optimal schedule as training reference
% Yaze Li, University of Arkansas
clear all;close all;clc;
load('uark_data');
%% cvx MINLP for each month
ns = 82;
nb = 5500;
gamma_e = 0.94;
%gamma_e = 1;
Dmax = 16.08;
%Dmax = 0;
q_opt = zeros(21,744);
c_opt = zeros(21,744);
qnet_opt = zeros(21,744);
cost_opt = zeros(21,1);
cost_pv = zeros(21,1);
cost_org = zeros(21,1);
for m = 13
    m
    t = T(m);
    q_sol = re(m,1:t);
    l = ld(m,1:t);
    tou = p(m,1:t);
    %tou = ones(1,720);
    S = s(m,1:t);
    
    %%
    cvx_solver mosek_2
    cvx_begin %quiet
    variable qc(1,t) nonnegative
    variable qd(1,t) nonnegative
    expression c(1,t)
    for i=1:t-1
        c(i+1)=c(i)+gamma_e*qc(i)-qd(i)/gamma_e;
    end
    expression qnet(1,t);
    qnet=max(0,l-q_sol+qc-qd);%energy bought from the utility
    
    expression CE;
    CE=sum(qnet.*tou);%Energy charge
    
    expression CD;
    CD=Dmax*(max(qnet));%Demand charge
    
    minimize CE+CD;
    
    subject to %5kw/13.5kWh
    qc<=nb*5;
    qd<=nb*5;
    0<=c<=S;
    c(1)==0;
    c(t)==0;
    
    cvx_end
    
    %% Results
    C_milp = CE+CD;
    C_pv = sum(max(0,(l-q_sol)).*tou)+max(l-q_sol)*Dmax;
    C_org = sum(max(0,l).*tou)+max(l)*Dmax;
    q_opt(m,1:t) = qc-qd;
    c_opt(m,1:t) = c;
    qnet_opt(m,1:t) = qnet;
    cost_opt(m) = C_milp;
    cost_pv(m) = C_pv;
    cost_org(m) = C_org;
end    
%%
% clearvars -except cost_opt cost_org cost_pv q_opt c_opt qnet_opt
% save opt.mat
%%
% close all
% figure;
% plot(max(qnet)-l+q_sol)
% hold on;
% plot(-l+q_sol)
% plot(qc-qd)
% legend('q_opt-ld','-ld','qc-qd')
% %xlim([1,168])
% figure;
% plot(l-q_sol)
% hold on;
% plot(qnet)