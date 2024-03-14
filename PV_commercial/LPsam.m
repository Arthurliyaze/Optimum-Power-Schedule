%this code helps Samrat to compare the result
clear all;close all;clc;%uark case in 2016
%tic
%% Reading the excel file
D=importdata('RefBldgLargeHotelNew2004_7.1_5.0_3C_USA_CA_SAN_FRANCISCO.csv');
total_data=D.data(1:8640,11);
month_data=zeros(12,720);
for i=1:12
    month_data(i,:)=total_data(720*(i-1)+1:720*i);
end

%R = importdata('pvwatts_hourly_uark.xlsx');
R = importdata('pvwatts_hourly_san10.xlsx');
r_data=R.data(16:8655,11)/1000;
renew_data=reshape(r_data,720,12);%renewable ac energy(kW) for 10kw solar system in a year
renew_data=renew_data';
clear i D total_data R %r_data;
%% Prepare variables
TOU_day1=[0.09317*ones(1,9),0.10779*ones(1,12),0.09317*ones(1,3)];%winter TOU
TOU_day2=[0.08651*ones(1,9),0.11333*ones(1,3),0.15384*ones(1,6),0.11333*ones(1,3),0.08651*ones(1,3)];%summer TOU
TOU_month1=TOU_day1(ones(30,1),:)';
TOU_month2=TOU_day2(ones(30,1),:)';
P1=reshape(TOU_month1,1,numel(TOU_month1))';
P2=reshape(TOU_month2,1,numel(TOU_month2))';

clear TOU_month1 TOU_month2;
%%
%Dmax=6.8;
Dmax=16.08;

bcost=5900;%POWERWALL PRICE
Pb=bcost/10;% powerwall battery price per year

%pcost=3.95*10000;%10kw solar system price in Arkansas
pcost=2.95*10000;%10kw solar system price in San Francisco
Ps=pcost/10;%10kw solar system price per year

gamma=0.94;

%% Linear Minimax
n=720;
ns=120;
nb=20;
for month=6
ld=month_data(month,:);       
qre=ns*renew_data(month,:);
    if month>=5&&month<=10
        P=P2;
    else
        P=P1;
    end
cvx_solver mosek;
cvx_begin
    variables qc(1,n) qd(1,n);
    %variable np nonnegative; %number of 10kw solar system
    %variable nb nonnegative; % number of powerwall
    expression S(n);
    S(1)=gamma*qc(1)-qd(1)/gamma;
    for i=1:n-1
        S(i+1)=S(i)+gamma*qc(i+1)-qd(i+1)/gamma;
    end
    expression net(n);
    net=ld-qre+qc-qd;
    %minimize (sum(P*max(qnet,0))+Dmax*max(qnet)+Pb*nb+Pr*np);
    minimize (sum(max(net,0)*P)+Dmax*max(net));
    subject to %5kw/13.5kWh
        0<=qc<=nb*5;
        0<=qd<=nb*5;
        0<=S<=nb*13.5;
        %0<=ns<=120;%area of Harmon Garage
cvx_end
qnet(month,:)=net;
qld(month,:)=ld;
prebill(month)=sum(max(ld,0)*P)+Dmax*max(ld);
bill(month)=sum(max(net,0)*P)+Dmax*max(net);
bill_solar(month)=sum(max(ld-qre,0)*P)+Dmax*max(ld-qre);
end
%% Month data plot
%clc;
close all;
battery_number=nb
battery_capacity=13.5*nb
charging_rate=5*nb
solar_system_number=ns
solar_power=10*ns

%{
save_bill=prebill-bill
battery_cost=bcost*nb
solar_cost=pcost*ns
breaking_even=(bcost*nb+pcost*ns)/save_bill
%}
%%
%clc;
%close all;
figure;
hour=1:length(month_data);
plot(hour,month_data(6,:));
grid on;
xlim([0,24*7]);
ylim([0,900]);
hold on;
plot(hour,max(0,qnet(6,:)));
legend('Without Solar Panel and Battery','With Solar Panel and 5kW/13.5Wh Battery');
xlabel('Time(hour)');
ylabel('Load(kW)');
%savefig(strcat(num2str(j),'00_Sld.fig'));
%%
figure;
plot(hour,S/1000);
grid on;
xlim([0,7*24]);
legend('Battery Behavior');
xlabel('Time(hour)');
ylabel('Energy(MWh)');
qall=reshape(qld',month*720,1);
%toc
%%
figure;
plot(qc);
grid on;
hold on;
plot(qd);
xlim([0,7*24]);