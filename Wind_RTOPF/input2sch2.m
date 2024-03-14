function sch = input2sch2(pso_input, nt, mpc, soc_t)
%INPUT2SCH2 Change the pso input to a legal schedule by method2
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
    sch_uncst = 0.4*mpc.essSize'.*pso_input(:,step);
    for nb = 1:4
        if sch_uncst(nb) >= 0
            sch(nb,step) = min(sch_uncst(nb),(mpc.essSize(nb)-soc(nb,step))/gamma_e);
        else
            sch(nb,step) = max(sch_uncst(nb),-soc(nb,step)*gamma_e);
        end
    end
    soc(:,step+1) = soc(:,step)+sch(:,step);
end
end