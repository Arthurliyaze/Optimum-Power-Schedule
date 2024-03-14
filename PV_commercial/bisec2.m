function [ c ] = bisec2( nb,np,step )
%this function use binary search to found opt np
%   np is the search max, step size given
a=1;
b=np;
intv=abs(a-b);
ya=DPbill(1,nb,a,step);
yb=DPbill(1,nb,b,step);
while intv>1
    c=floor((a+b)/2);
    if ya>yb
        a=c;
        ya=DPbill(1,nb,a,step);
    else
        b=c;
        yb=DPbill(1,nb,b,step);
    end
    intv=abs(a-b);
end
end