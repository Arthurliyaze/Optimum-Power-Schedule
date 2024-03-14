function [Pg_ac, loss, cost_ac] = spacopf_ess(sch, nt, mpc)
%SPACOPF_ESS calculates the single-period AC optimal power flow with given
%ESS schedule (from dc result or else), starting time, and time horizon
%   nt:     time horizon calculated
%   sch:    4xnt the schedule of ESS from DC OPF or else
%   mpc:    case that calculated
%   Pg_ac:  5xnt the generation results from AC OPF
%   loss:   ntx1 total power loss of the system in each hour from AC OPF
%   cost_ac:    total generation cost from AC
%   Yaze Li, University of Arkansas

profile = load('profile.mat');
bus_no = [2,3,4,5,6,9,10,12,13];
rbus = [2,3,5,6,7,8,9];
cbus = [4,10];
ibus = 1;
Pload = zeros(nt,length(bus_no));
Pload(:,1) = profile.iload';
for bus = 2:length(bus_no)
    if ismember(bus,cbus)
        Pload(:,bus) = profile.cload';
    else
        Pload(:,bus) = profile.rload';
    end
end
define_constants;
loss = zeros(nt,1);
Pg_ac = zeros(5,nt);
cost_ac = 0;
[~, mpc, ~] = addrenew(renew(mpc.renewSite), mpc, []);
[~, mpc, ~, ~] = addstorage(storage(mpc.essSize,mpc.essSite), mpc, []);
%% solve
for step = 1:nt       
        % add renew
        mpc.gen(end-7:end-4,PMAX) = repmat((profile.wind(step)+profile.pv(step)),4,1);
        % change loads
        mpc.bus(mpc.loadSite,PD) = Pload(step,:)';

    % add ESS schedule to load
    mpc.gen(end-3:end,PMAX) =  -sch(:,step);
    mpopt = mpoption('verbose',0,'out.all',0);
    results = runopf(mpc,mpopt);
    loss(step) = sum(real(get_losses(results)));
    Pg_ac(:,step) = results.gen(1:5,2);
    cost_ac = cost_ac + results.f;
end
end