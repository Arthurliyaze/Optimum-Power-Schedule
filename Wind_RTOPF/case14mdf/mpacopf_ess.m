function [Pg, sch, cost, loss] = mpacopf_ess(t, nt, mpc)
%MPACOPF_ESS calculates the multi-period AC optimal power flow on case
%with given ESS setting, starting time, and time horizon
%   t:      starting time
%   nt: time horizon calculated
%   mpc:    case that calculated
%   Pg: optimal ac generation
%   sch:    optimal ESS schedule
%   cost:   optimal cost
%   loss:   total power loss
%  Yaze Li, University of Arkansas

%%
delta = inf;
threshold = 1;
loss = 0;
[~, sch1, cost1] = mpdcopf_ess(loss, t, nt, mpc);
while delta > threshold
    [Pg_ac, loss, cost_ac] = spacopf_ess(sch1, t, nt, mpc);
    [~, sch2, cost2] = mpdcopf_ess(loss, t, nt, mpc);
    delta = abs(cost1-cost2);
    sch1 = sch2;
    cost1 = cost2;
end
Pg = Pg_ac;
sch = sch1;
cost = cost_ac;