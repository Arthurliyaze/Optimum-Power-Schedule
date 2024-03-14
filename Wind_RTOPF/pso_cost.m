function pso_cost = pso_cost(pso_input, t, nt, mpc, soc_t)
%PSO_COST calculates the generation cost plus the final soc punishment
%given the pso_input as form of schedule and time horizon
%   pso_input:  1x4*nt PSO input matrix
%   t:      starting time
%   nt: time horizon calculated
%   mpc:    case that calculated
%   soc_t:    1*4 initial soc
%   pso_cost: cost for pso
%   Yaze Li, University of Arkansas

%% transfors a PSO input from -1 to 1 into legal schedule
sch = input2sch2(pso_input, nt, mpc, soc_t);

%% calculate the AC power flow cost
[~, ~, cost_ac] = spacopf_ess(sch, t, nt, mpc);
pso_cost = cost_ac;

end