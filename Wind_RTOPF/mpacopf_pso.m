function sch_pso = mpacopf_pso(t, nt, mpc, soc_t)
%MPACOPF_PSO Calculates the multi-period AC OPF by PSO with given starting
%time, and time period.
%   t:      starting time
%   nt:     time horizon calculated
%   mpc:    case that calculated
%   soc_t:    1*4 initial soc
%   Yaze Li, University of Arkansas

nvars = 4*nt;
fun = @(x) pso_cost(x,t,nt,mpc,soc_t);
lb = -1*ones(1,nvars);
ub = 1*ones(1,nvars);
%%
rng default  % For reproducibility
options = optimoptions('particleswarm','MinNeighborsFraction',1);
options.UseParallel = true;
options.FunctionTolerance = 1;
[x,~,~,~] = particleswarm(fun,nvars,lb,ub,options);
sch_pso = input2sch2(x,nt,mpc,soc_t);
end