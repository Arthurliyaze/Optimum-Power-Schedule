function [ ebill,bill,qnet ] = DP(nb,ns,m,q)
%This function applies DP to calculate the schedule and bill for the first
%m month given the system size
%   m is the # of months
%   nb is the # of batteries
%   ns is the # of solar panels
%   q is the step size
%   ebill is the electricity cost
%   bill is the length m vector saves the cost of the first m month
%   qnet is the schedule

load('all_data');
month_num=m;
year=ceil(month_num./12);

solar=zeros(1,month_num);%solar energy
solar=gamma_s.^(0:month_num-1);

cap=zeros(month_num,1);%battery capacity
alpha=0.0036;%calendar aging
beta=0.0155;%cycling aging
age=@(m) 1-alpha.*(m-1).^0.75-beta.*sqrt(m-1);
m=1:1:month_num;
cap=age(m)';
S=nb*13.5*cap;
%%qnet=zeros(m,720);

for i=1:month_num
    qre(i,:)=ns*qre_10(i,:)*solar(i);
end
%%
for month=1:month_num
    qld=qld_10(1:month,:);
    state=0:q:S(month);%state sequence
    n=720;
    l=length(state);
    Q=5*nb;
    
    clim=floor(Q*gamma_e/q);%charge limit # of state
    dlim=floor(Q/gamma_e/q);%discharge limit # of state
    r=[ones(1,clim+1),zeros(1,l-clim-1)];
    c=[ones(1,dlim+1),zeros(1,l-dlim-1)]';
    trellis=logical(toeplitz(c,r));
    clear clim dlim r c;
    
    nos=zeros(1,n+1);%number of state
    for k=1:n+1
        if k<=S(month)/(Q*gamma_e)+1
            nos(k)=1+floor((k-1)*Q*gamma_e/q);
        else
            nos(k)=l;
        end
    end
    
    E=zeros(l,n);
    D=zeros(l,n);
    
    
    for k=2:n+1
        indexr=1:nos(k);
        index1=1:nos(k-1);
        for j=1:length(indexr)
            index2=find(trellis(:,j)==1);
            indexl=intersect(index1,index2)';
            
            if isempty(indexl)
                indexl=index1(end)+1;
            end
            
            Phi=single(zeros(1,length(indexl)));
            for i=1:length(indexl)
                I=indexl(i);
                Phi(i)= P_years(month,k-1)*max(qld(month,k-1)-qre(month,k-1)+state(j)-state(I),0)+E(I,k-1)+max(Dmax*(qld(month,k-1)-qre(month,k-1)+state(j)-state(I)),D(I,k-1));
            end
            [V(j,k),id] = min(Phi);
            ind=indexl(id);
            E(j,k)=P_years(month,k-1)*max(qld(month,k-1)-qre(month,k-1)+state(j)-state(ind),0)+E(ind,k-1);
            D(j,k)=max(Dmax*(qld(month,k-1)-qre(month,k-1)+state(j)-state(ind)),D(ind,k-1));
            prestate(j,k)=ind;
            clear Phi;
        end
    end
    [x,fsind]=min(V(:,n+1));
    ebill(month)=x+P;
    bill(month)=ebill(month)+Pb*nb+Ps*ns;
    
    inde(n+1)=fsind;
    for m=n:-1:1
        inde(m)=prestate(inde(m+1),m+1);
    end
    s(month,:)=q*(inde-1);
    for p=1:n
        charge(month,p)=s(month,p+1)-s(month,p);
    end
    qnet(month,:)=qld(month,:)+charge(month,:)-qre(month,:);
    %qnet=0;
end
end

