x% this code uses MPC to achieve RT-OPF with ESS
% Yaze Li, University of Arkansas
clear; close all; clc;
%% Parameter setting
mpc = loadcase('case14mdf');
t = 1493;
nt = 4;
T = 24;
sch_mpc = zeros(4,T);
soc = zeros(4,T);
soc_t = ones(4,1)*5;

tic
%% Calculate the daily schedule
for step = 1:T
    step
    soc(:,step) = soc_t;        % record soc
    sch_pso = mpacopf_pso(t+step-1,nt,mpc,soc_t);
    sch_mpc(:,step) = sch_pso(:,1); % get 1 step schedule
    soc_t = soc_t+sch_mpc(:,step);  % update soc   
end
toc
%% Calculate the daily cost
[Pg_mpc, loss, cost_mpc] = spacopf_ess(sch_mpc, t, T, mpc);