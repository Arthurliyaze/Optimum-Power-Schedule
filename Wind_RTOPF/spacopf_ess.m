function [Pg_ac, loss, cost_ac] = spacopf_ess(sch, t, nt, mpc)
%SPACOPF_ESS calculates the single-period AC optimal power flow with given
%ESS schedule (from dc result or else), starting time, and time horizon
%   t:      starting time
%   nt:     time horizon calculated
%   sch:    4xnt the schedule of ESS from DC OPF or else
%   mpc:    case that calculated
%   Pg_ac:  5xnt the generation results from AC OPF
%   loss:   ntx1 total power loss of the system in each hour from AC OPF
%   cost_ac:    total generation cost from AC
%   Yaze Li, University of Arkansas

profile = load('profile.mat');
predict = load('predict.mat');
define_constants;
loss = zeros(nt,1);
Pg_ac = zeros(5,nt);
cost_ac = 0;
[~, mpc, ~] = addrenew(renew(mpc.windSite), mpc, []);
[~, mpc, ~, ~] = addstorage(storage(mpc.essSize,mpc.essSite), mpc, []);
%% solve
for step = 1:nt
    %if step == 1        
        % add wind
        mpc.gen(end-4,PMAX) = profile.wind_test(t+step-1);
        % change loads
        mpc.bus(mpc.loadSite,[PD,QD]) = reshape(profile.load_test(t+step-1,:),2,[])';
        
%     else        
%         % add wind
%         mpc.gen(end-4,PMAX) = predict.wind_pre(step-1,t+1);      
%         % change loads
%         mpc.bus(mpc.loadSite,PD) = predict.load_pre(:,step-1,t+1);
%         mpc.bus(mpc.loadSite,QD) = predict.load_pre(:,step-1,t+1);
%     end
    
    % add ESS schedule to load
    mpc.gen(end-3:end,PMAX) =  -sch(:,step);
    mpopt = mpoption('verbose',0,'out.all',0);
    results = runopf(mpc,mpopt);
    loss(step) = sum(real(get_losses(results)));
    Pg_ac(:,step) = results.gen(1:5,2);
    cost_ac = cost_ac + results.f;
end
end