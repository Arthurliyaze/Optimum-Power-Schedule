function [ nb ] = Bsearch_nb( ns,month,step )
%This function uses binary search to find opt ns
%   ns # of solar panels
%   month: time horizon
%   step: discretization size
nb1=80;
nb2=100;
[~,bill1,~]=DP(nb1,ns,month,step);
[~,bill2,~]=DP(nb2,ns,month,step);
while abs(nb2-nb1)>1
    nb=round((nb2+nb1)/2);
    [~,bill,~]=DP(nb,ns,1,step);
    if bill1>bill2
        nb1=nb;
        bill1=bill;
    else
        nb2=nb;
        bill2=bill;
    end    
end
nb=max(nb1,nb2);

end