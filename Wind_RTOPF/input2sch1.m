function sch = input2sch1(pso_input, mpc, soc_t)
%INPUT2SCH1 Change the pso input to a legal schedule by method1
%   pso_input:  1x4*nt PSO input matrix
%   nt: time horizon calculated
%   mpc:    case that calculated
%   soc_t:    1*4 initial soc

pso_input = reshape(pso_input,nt,4)'; % 4xnt
gamma_e = 0.94;
sch = zeros(4,nt);
soc = zeros(4,nt);
soc(:,1) = soc_t';

for step = 1:nt
    lb = max(-0.4*mpc.essSize',-soc(:,step)*gamma_e);
    ub = min(0.4*mpc.essSize',(mpc.essSize'-soc(:,step))/gamma_e);
    a = (ub-lb)./2;
    b = (ub+lb)./2;
    sch(:,step) = a.*pso_input(:,step)+b;% scaled sch
    soc(:,step+1) = soc(:,step)+sch(:,step);
end
end