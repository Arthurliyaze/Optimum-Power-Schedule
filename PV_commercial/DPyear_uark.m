%this code tries DP of uark data in 2016
clear all; close all; clc;
%tic
%% Reading the excel file
D = importdata('Total Demand(kW) 2016_2017.xlsx');
total_data=D.data(:,1:12);%col1-12 is 2016 Jan-Dec
month_data=zeros(12,720);
for i=1:720
    month_data(:,i)=mean(total_data(4*i-3:4*i,:),1);
end

%R = importdata('pvwatts_hourly_uark.xlsx');
R = importdata('pvwatts_hourly_san10.xlsx');
r_data=R.data(16:8655,11)/1000;
renew_data=reshape(r_data,12,720);%renewable ac energy(kW) for 10kw solar system in a year
clear i D total_data R r_data;
%% Prepare variables
TOU_day=[0.19637*ones(1,8),0.26796*ones(1,4),0.56478*ones(1,6),0.26796*ones(1,3),0.19637*ones(1,3)];%rate in San Francisco
TOU_month=TOU_day(ones(30,1),:)';
P=reshape(TOU_month,1,numel(TOU_month))';
clear TOU_month
%%
Dmax=16.08;
%Dpk=18.64;
%Dppk=5.18;

bcost=5900;%POWERWALL PRICE
Pb=bcost/10;% powerwall battery price per month

%pcost=3.95*10000;%10kw solar system price in Arkansas
pcost=2.95*10000;%10kw solar system price in San Francisco
Pr=pcost/10;%10kw solar system price per month

for t=1:20
    for year=1:10
nb=10*t+4000;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S=13.5*nb*0.99^(year-1);
Q=5*nb;

np=120;

gamma=1;
qre=np*renew_data*0.995^(year-1);%120 solar system number
%Ptest=[ones(1,12),zeros(1,12)];
%%
month_num=12;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qld=month_data(1:month_num,:);
q=floor(S/100);%the step size of states
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
%V=zeros(l,n+1);
%%
for month=1:month_num
for k=2:n+1
    indexr=1:nos(k);
    index1=1:nos(k-1);
    for j=1:length(indexr)
        index2=find(trellis(:,j)==1);
        indexl=intersect(index1,index2)';
        if length(indexl)==0
            indexl=index1(end)+1;
        end
        Phi=single(zeros(1,length(indexl)));
        for i=1:length(indexl)
            I=indexl(i);
            Phi(i)= P(k-1)*max(qld(month,k-1)-qre(month,k-1)+state(j)-state(I),0)+E(I,k-1)+max(Dmax*(qld(month,k-1)-qre(month,k-1)+state(j)-state(I)),D(I,k-1));
        end
        [V(j,k),id] = min(Phi);
        ind=indexl(id);
        E(j,k)=P(k-1)*max(qld(month,k-1)-qre(month,k-1)+state(j)-state(ind),0)+E(ind,k-1);
        D(j,k)=max(Dmax*(qld(month,k-1)-qre(month,k-1)+state(j)-state(ind)),D(ind,k-1));
        prestate(j,k)=ind;
        clear Phi;
    end
end
[bill(month),fsind]=min(V(:,n+1));
inde(n+1)=fsind;
for m=n:-1:1
    inde(m)=prestate(inde(m+1),m+1);
end
s(month,:)=q*(inde-1);
for p=1:n
    charge(month,p)=s(month,p+1)-s(month,p);
end
end
%%
year_bill(year)=sum(bill);
end
all_bill(t)=sum(year_bill)+nb*5900
end
%%
%{
Bill=sum(bill)+Pb*nb+Pr*np
qnet=qld+charge;
%%
%toc
figure;
hour=1:n;
plot(hour,month_data(2,:));
grid on;
xlim([0,24*7]);
%ylim([-1,4]);
hold on;
plot(hour,max(0,qnet(2,:)));
legend('Without Solar Panel and Battery','With Solar Panel and 5kW/13.5Wh Battery');
xlabel('Time(hour)');
ylabel('Load(kW)');
title('DP');
%savefig(strcat(num2str(j),'00_Sld.fig'));
figure;
plot(1:n+1,s(2,:)/1000);
grid on;
xlim([0,7*24]);
legend('Battery Behavior');
xlabel('Time(hour)');
ylabel('Energy(MWh)');
q=reshape(qnet',12*720,1);
title('DP');
figure;
plot(max(q,0)/1000)
xlabel('Time(hour)');
ylabel('Load(MW)');
title('load after using battery and solar (DP)')
%}