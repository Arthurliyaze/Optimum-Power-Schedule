function [ allbill,year_bill ] = DPbill( H, nb, np, step )
%   This function uses DP to calculate the bill
%   With given time hoziron, step size and nb, the result returns to the elec bill and cost
%   of system

% get data
D=importdata('RefBldgLargeHotelNew2004_7.1_5.0_3C_USA_CA_SAN_FRANCISCO.csv');
total_data=D.data(1:8640,11);
month_data=zeros(12,720);
for i=1:12
    month_data(i,:)=total_data(720*(i-1)+1:720*i);
end

R = importdata('pvwatts_hourly_san10.xlsx');
r_data=R.data(16:8655,11)/1000;
renew_data=reshape(r_data,720,12);%renewable ac energy(kW) for 10kw solar system in a year
renew_data=renew_data';
clear i D total_data R r_data;
% Prepare variables in San Francisco
%
TOU_day1=[0.09317*ones(1,9),0.10779*ones(1,12),0.09317*ones(1,3)];%winter TOU
TOU_day2=[0.08651*ones(1,9),0.11333*ones(1,3),0.15384*ones(1,6),0.11333*ones(1,3),0.08651*ones(1,3)];%summer TOU
TOU_month1=TOU_day1(ones(30,1),:)';
TOU_month2=TOU_day2(ones(30,1),:)';
P1=reshape(TOU_month1,1,numel(TOU_month1))';
P2=reshape(TOU_month2,1,numel(TOU_month2))';
P=zeros(12,720);%year TOU price
for i=1:12
    if i>=5&&i<=10
        P(i,:)=P2;
    else
        P(i,:)=P1;
    end
end
clear TOU_day1 TOU_day2 TOU_month1 TOU_month2 P1 P2 i;

Dmax=16.08;

bcost=5900;%POWERWALL PRICE
Pb=bcost/10;% powerwall battery price per year

pcost=6400;%10kw solar system price in San Francisco
Pr=pcost/10;%10kw solar system price per year

clear bcost pcost;
year=H;
S=13.5*nb*0.99^(year-1);
Q=5*nb;
gamma=0.94;
qre=np*renew_data*0.995^(year-1);%120 solar system number

month_num=12;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qld=month_data(1:month_num,:);
q=step;%the step size of states
state=0:q:S;%state sequence
n=720;
l=length(state);

clim=floor(Q*gamma/q);%charge limit # of atate
dlim=floor(Q/gamma/q);%discharge limit # of state
r=[ones(1,clim+1),zeros(1,l-clim-1)];
c=[ones(1,dlim+1),zeros(1,l-dlim-1)]';
trellis=logical(toeplitz(c,r));
clear clim dlim r c;

nos=zeros(1,n+1);%number of state
for k=1:n+1
    if k<=S/(Q*gamma)+1
        nos(k)=1+floor((k-1)*Q*gamma/q);
    else
        nos(k)=l;
    end
end

E=zeros(l,n);
D=zeros(l,n);

for month=1:month_num
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
            Phi(i)= P(month,k-1)*max(qld(month,k-1)-qre(month,k-1)+state(j)-state(I),0)+E(I,k-1)+max(Dmax*(qld(month,k-1)-qre(month,k-1)+state(j)-state(I)),D(I,k-1));
        end
        [V(j,k),id] = min(Phi);
        ind=indexl(id);
        E(j,k)=P(month,k-1)*max(qld(month,k-1)-qre(month,k-1)+state(j)-state(ind),0)+E(ind,k-1);
        D(j,k)=max(Dmax*(qld(month,k-1)-qre(month,k-1)+state(j)-state(ind)),D(ind,k-1));
        prestate(j,k)=ind;
        clear Phi;
    end
end
[bill(month),fsind]=min(V(:,n+1));
%{
inde(n+1)=fsind;
for m=n:-1:1
    inde(m)=prestate(inde(m+1),m+1);
end
s(month,:)=q*(inde-1);
for p=1:n
    charge(month,p)=s(month,p+1)-s(month,p);
end
%}
end
%
year_bill(year)=sum(bill);%+590*nb
%annual_ebill=sum(year_bill);
annual_allbill=sum(year_bill)+Pb*nb+Pr*np;
allbill=annual_allbill;
end