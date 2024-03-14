%this code tries LP for uark data in 2016
clear all;close all;clc;%uark case in 2016
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
%{
H_month=1:length(month_data);%time index
Hpk_day=13:18;
Hppk_day=[10:12,19:21];
Hpk_month=Hpk_day(ones(30,1),:);
Hppk_month=Hppk_day(ones(30,1),:);
for i=1:30
    Hpk_month(i,:)=Hpk_month(i,:)+(i-1)*24;
    Hppk_month(i,:)=Hppk_month(i,:)+(i-1)*24;
end
Hpk_month=reshape(Hpk_month',1,numel(Hpk_month));%peak time index
Hppk_month=reshape(Hppk_month',1,numel(Hppk_month));%part peak time index
%}

%TOU_day=[0.007*ones(1,12),0.0556*ones(1,6),0.007*ones(1,6)];%rate in Arkansas
TOU_day=[0.19637*ones(1,8),0.26796*ones(1,4),0.56478*ones(1,6),0.26796*ones(1,3),0.19637*ones(1,3)];%rate in San Francisco
TOU_month=TOU_day(ones(30,1),:)';
P=reshape(TOU_month,1,numel(TOU_month))';
clear TOU_month
%%
%Dmax=6.8;
Dmax=16.08;

bcost=5900;%POWERWALL PRICE
Pb=bcost/10;% powerwall battery price per year

%pcost=3.95*10000;%10kw solar system price in Arkansas
pcost=2.95*10000;%10kw solar system price in San Francisco
Ps=pcost/10;%10kw solar system price per year

gamma=1;

%% Linear Minimax
month_num=12;
qld=month_data(1:month_num,:);
cvx_solver mosek;
cvx_begin
    variables qc(month_num,720) qd(month_num,720);
    variable ns nonnegative; %number of 10kw solar system
    variable nb nonnegative; % number of powerwall
    expression S(month_num,720);
    for month=1:month_num
        S(month,1)=gamma*qc(month,1)-qd(month,1)/gamma;
        for i=1:720-1
            S(month,i+1)=S(month,i)+gamma*qc(month,i)-qd(month,i)/gamma;
        end
    end
    clear month;
    expression qre(month_num,720);
    qre=ns*renew_data(1:month_num,:);
    expression qnet(month_num,720);
    qnet=qld-qre+qc-qd;
    expression CE;
    expression CD;
    expression CS;
    expression CB;
    CE=sum(max(qnet,0)*P);%Energy charge
    CD=Dmax*sum(max(qnet,[],2));%Demand charge
    CS=Ps*ns;
    CB=Pb*nb;
    minimize (CE+CD+CS+CB);
    subject to %5kw/13.5kWh
        0<=qc<=nb*5;
        0<=qd<=nb*5;
        0<=S<=nb*13.5;
        0<=ns<=120;%area of Harmon Garage
cvx_end
%% Month data plot
%clc;
close all;
battery_number=nb
battery_capacity=13.5*nb
charging_rate=5*nb
solar_system_number=ns
solar_power=10*ns
prebill=sum(max(qld,0)*P)+Dmax*sum(max(qld,[],2))%previous bill
bill_solar=sum(max(qld-qre,0)*P)+Dmax*sum(max(qld-qre,[],2))
bill=sum(max(qnet,0)*P)+Dmax*sum(max(qnet,[],2))

save_bill=prebill-bill
battery_cost=bcost*nb
solar_cost=pcost*ns
breaking_even=(bcost*nb+pcost*ns)/save_bill
%%
%clc;
close all;
figure;
hour=1:length(month_data);
plot(hour,month_data(2,:));
grid on;
xlim([0,24*7]);
%ylim([-1,4]);
hold on;
plot(hour,max(0,qnet(2,:)));
legend('Without Solar Panel and Battery','With Solar Panel and 5kW/13.5Wh Battery');
xlabel('Time(hour)');
ylabel('Load(kW)');
%savefig(strcat(num2str(j),'00_Sld.fig'));
figure;
plot(hour,S(2,:)/1000);
grid on;
xlim([0,7*24]);
legend('Battery Behavior');
xlabel('Time(hour)');
ylabel('Energy(MWh)');
q=reshape(qnet',12*720,1);
figure
plot(max(q,0)/1000)
xlabel('Time(hour)');
ylabel('Load(MW)');
title('load after using battery and solar')
%xlim([721,1440]);