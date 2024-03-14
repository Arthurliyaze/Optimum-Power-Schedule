function [ ns ] = Bsearch_ns( nb,month,step )
%This function uses binary search to find opt ns
%   nb # of batteries
%   month: time horizon
%   step: discretization size
ns1=100;
ns2=120;
[~,bill1,~]=DP(nb,ns1,month,step);
[~,bill2,~]=DP(nb,ns2,month,step);
while abs(ns2-ns1)>1
    ns=round((ns2+ns1)/2);
    [~,bill,~]=DP(nb,ns,1,step);
    if bill1>bill2
        ns1=ns;
        bill1=bill;
    else
        ns2=ns;
        bill2=bill;
    end    
end
ns=max(ns1,ns2);

end

