%this code uses LP new aging model calculate 10 years
clear all;close all;clc;%uark case in 2016
%tic
%% Reading the excel file
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
clear i D total_data R %r_data;
%% Prepare variables
month_num=12;%%%%%%%%%%%%%%%%%%%%%%%%%%%%
year=10;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TOU_day1=[0.09317*ones(1,9),0.10779*ones(1,12),0.09317*ones(1,3)];%winter TOU
TOU_day2=[0.08651*ones(1,9),0.11333*ones(1,3),0.15384*ones(1,6),0.11333*ones(1,3),0.08651*ones(1,3)];%summer TOU
TOU_month1=TOU_day1(ones(30,1),:)';
TOU_month2=TOU_day2(ones(30,1),:)';
P1=reshape(TOU_month1,1,numel(TOU_month1))';
P2=reshape(TOU_month2,1,numel(TOU_month2))';
P=zeros(month_num,720);%year TOU price
for i=1:month_num
    if i>=5&&i<=10
        P(i,:)=P2;
    else
        P(i,:)=P1;
    end
end
P=P*1.04^(year-1);
clear TOU_month
%%
Dmax=16.08;

bcost=5900;%POWERWALL PRICE
Pb=bcost/10;% powerwall battery price per year

pcost=6400;%10kw solar system price in San Francisco
Ps=pcost/10;%10kw solar system price per year

gamma=0.94;
gamma_s=0.9996;
solar=zeros(1,12);%solar energy
solar=gamma_s.^(0:11);

cap=zeros(1,12);%battery capacity
alpha=0.0036;%calendar aging
beta=0.0155;%cycling aging
age=@(m) 1-alpha.*(m-1).^0.75-beta.*sqrt(m-1);
m=1:1:12;
cap=age(m);
%% Linear Minimax
qld=month_data(1:month_num,:);

capacity=cap*cap(12)^(year-1);
cvx_solver mosek;
cvx_begin
    variables qc(month_num,720) qd(month_num,720);
    %variable ns nonnegative integer; %number of 10kw solar system
    %variable nb nonnegative integer; % number of powerwall
    expression S(month_num,720);
    for month=1:month_num
        S(month,1)=gamma*qc(month,1)-qd(month,1)/gamma;
        for i=1:720-1
            S(month,i+1)=S(month,i)+gamma*qc(month,i)-qd(month,i)/gamma;
        end
    end
    clear month;
    expression qre(month_num,720);
    ns=120;
    nb=90;
    for m=1:month_num
        qre(m,:)=ns*renew_data(m,:)*solar(m)*solar(12)^(year-1);
    end
    %qre=ns*renew_data(1:month_num,:)*gamma_s^(year-1);
    expression qnet(month_num,720);
    qnet=qld-qre+qc-qd;
    expression CE;
    expression CD;
    expression CS;
    expression CB;
    CE=sum(sum(max(qnet,0).*P));%Energy charge
    CD=Dmax*sum(max(qnet,[],2));%Demand charge
    CS=Ps*ns;
    CB=Pb*nb;
    %minimize (CE+CD+CB);
    minimize (CE+CD+CS+CB);
    subject to %5kw/13.5kWh
        0<=qc<=nb*5;
        0<=qd<=nb*5;
        0<=S(1,:)<=nb*13.5*capacity(1);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        0<=S(2,:)<=nb*13.5*capacity(2);
        0<=S(3,:)<=nb*13.5*capacity(3);
        0<=S(4,:)<=nb*13.5*capacity(4);
        0<=S(5,:)<=nb*13.5*capacity(5);
        0<=S(6,:)<=nb*13.5*capacity(6);
        0<=S(7,:)<=nb*13.5*capacity(7);
        0<=S(8,:)<=nb*13.5*capacity(8);
        0<=S(9,:)<=nb*13.5*capacity(9);
        0<=S(10,:)<=nb*13.5*capacity(10);
        0<=S(11,:)<=nb*13.5*capacity(11);
        0<=S(12,:)<=nb*13.5*capacity(12);
        0<=ns<=120;%area of Harmon Garage
cvx_end

%% break even point
prebill=sum(sum(max(qld,0).*P,2)+Dmax*max(qld,[],2))%previous monthly bill
bill_solar=sum(sum(max(qld-qre,0).*P))+Dmax*sum(max(qld-qre,[],2))
bill=sum(sum(max(qnet,0).*P,2)+Dmax*max(qnet,[],2))
%savebill=cumsum(prebill-bill)
%%
figure;
save('LP10_new');