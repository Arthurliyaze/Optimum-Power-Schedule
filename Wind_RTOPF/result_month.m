% this code calculates March result for No storage, OPF and MPC
% Yaze Li, University of Arkansas
clear all; close all; clc;
%% Parameter setting
t = 1493;
T = 24*31;
% sch_mpc = zeros(4,T);
% soc = zeros(4,T);
%% No storage
mpc = loadcase('case14mdf');
sch_nostorage = zeros(4,T);
tic
[Pg_nostorage, ~, cost_nostorage] = spacopf_ess(sch_nostorage, t, T, mpc);
toc
%% OPF
cost_opf = 0;
tic
for day = 1:31
    %day
    mpc = loadcase('case14mdf');
    t = 1493+(day-1)*24;
    T = 24;
    soc_t = ones(4,1)*5;
    sch_opf = mpacopf_pso(t, T, mpc, soc_t);
    mpc = loadcase('case14mdf');
    [Pg_opf, ~, cost] = spacopf_ess(sch_opf, t, T, mpc);
    cost_opf = cost_opf+cost;
end
toc
%% MPC
mpc = loadcase('case14mdf');
T = 24*31;
nt = 6;
soc_t = ones(4,1)*5;
sch_mpc = zeros(4,T);
tic
% Calculate the daily schedule
for step = 1:T
    %step
    soc(:,step) = soc_t;        % record soc
    sch_pso = mpacopf_pso(t+step-1,nt,mpc,soc_t);
    sch_mpc(:,step) = sch_pso(:,1); % get 1 step schedule
    soc_t = soc_t+sch_mpc(:,step);  % update soc
end
% Calculate the daily cost
mpc = loadcase('case14mdf');
[Pg_mpc, loss, cost_mpc] = spacopf_ess(sch_mpc, t, T, mpc);
toc