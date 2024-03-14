% this code calculates the operation cost with only sess
% Yaze Li, University of Arkansas
clear; close all; clc;
%%
nt = 24;
mpc = loadcase('case14mdf');
soc_t = zeros(1,4);
%%
sch_pso = mpacopf_pso(nt, mpc, soc_t);
[Pg_ac, loss, cost_ac] = spacopf_ess(sch_pso, nt, mpc);

%%
save sess_result.mat cost_ac Pg_ac sch_pso