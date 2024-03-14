function [Pg_dc, sch, cost_dc] = mpdcopf_ess(loss, t, nt, mpc)
%MPDCOPF_ESS calculates the multi-period DC optimal power
%flow on case with given loss, ESS setting, starting time, and time horizon
%   loss:   ntx1 total power loss of the system in each hour from AC OPF
%   t:      starting time
%   nt:     time horizon calculated
%   mpc:    case that calculated
%   Pg_dc:  5xnt the generation results from DC OPF
%   sch:    4xnt the schedule of ESS from DC OPF
%   cost_dc:    total generation cost from DC 

% add wind
[iwind, mpc, ~] = addrenew(renew(mpc.windSite), mpc, []);
wind = wind_profile(t,nt,mpc.baseMVA);
profiles = getprofiles(wind,iwind);

% change loads
[Pload,Qload] = load_profile(t,nt,mpc.loadSite);
% note that add Q first then P
profiles = getprofiles(Qload,profiles);
profiles = getprofiles(Pload,profiles);

% add loss
profiles(3).values = profiles(3).values+loss;

% add ESS
[~, mpc, ~, sd] = addstorage(storage(mpc.essSize,mpc.essSite), mpc, []);
%% solve
mdi = loadmd(mpc, nt, [], sd, [], profiles);
mpopt = mpoption('verbose',0,'out.all',0);
mpopt = mpoption(mpopt, 'most.storage.cyclic', 1);
mdo = most(mdi, mpopt);
Pg_dc = mdo.results.ExpectedDispatch(1:5,:);
sch = -mdo.results.ExpectedDispatch(7:10,:);
cost_dc = mdo.results.f;