function [ c ] = bisec1( nb,np,step )
%this function use binary search to found opt nb
%   nb is the search max, step size given
a=1;
b=nb;
intv=abs(a-b);
ya=DPbill(1,a,np,step);
yb=DPbill(1,b,np,step);
while intv>1
    c=floor((a+b)/2);
    if ya>yb
        a=c;
        ya=DPbill(1,a,np,step);
    else
        b=c;
        yb=DPbill(1,b,np,step);
    end
    intv=abs(a-b);
end
end