% this code plots the complexity of MILP &DP in different time horizon
clear all; close all; clc;
%% load MILP data
T_MILP=[0 7.9856 26.2938 45.8884 117.2344 171.0670 223.4262 286.4864 363.4346...
429.4927  513.3498  619.2142  723.4904  825.0706  936.4459 1042.4    1182.1    1333.9    1482.6    1645.7    1833.0];
%% load DP with different step size
T_DP100=[0 9.8958   12.5416   14.8065   17.6961   20.4378   23.2091   25.9149...
    28.5145   31.1292   33.8977   36.9189   39.7272   42.3935   44.4610...
    47.0921 49.6898   57.6276   60.9931   63.7472   66.7899];
T_DP50=[0 18.6003   24.0351   29.5097   35.9381   40.7245   46.0763   52.8831...
    57.8379   64.6599   68.6829   73.5952   78.9425   84.8392   95.4685...
    95.4817 100.6330  105.5387  121.9165  129.6051  134.8644];
T_DP10=120*[0 0.6538    0.8588    1.0545    1.2548    1.4571    1.6158...
    1.8046    2.0085    2.1358    2.2977    2.4749    2.6629    2.8431...
    3.0206    3.2034    3.3875    3.5686    3.7492    3.9852    4.1708];
%% plot the complexity
month=0:20;
figure
plot(month,T_MILP,'ko-','LineWidth',1.5);
grid on;
hold on	
plot(month,T_DP10,'b*--','LineWidth',1.5);
plot(month,T_DP50,'r^-.','LineWidth',1.5);
plot(month,T_DP100,'gx-','LineWidth',1.5);
xlabel('number of month');
ylabel('Optimization Time (Seconds)');
legend('MILP','DP (q=10kWh)','DP (q=50kWh)','DP (q=100kWh)');
title('Time comparision of MILP and DP in different time horizon')
%% fitting
p = polyfit(0:20,T_MILP,2);
y = polyval(p,0:0.1:20);
figure
plot(0:0.1:20,y)
hold on
plot(0:20,T_MILP,'O')
hold off
t=polyval(p,20);
%%
month=1:12;
figure
plot(month,T_cvx/60,'ko','LineWidth',1.5);
grid on;
% hold on	
% plot(month,T_DP100,'b*--','LineWidth',1.5);
% plot(month,T_DP50,'r^-.','LineWidth',1.5);
% plot(month,T_DP10,'gx-','LineWidth',1.5);
xlabel('number of month');
ylabel('time to run the cvx (min)');
%legend('MILP','DP (step=100)','DP (step=50)','DP (step=10)');
%title('time comparision of MILP and DP in different time horizon')
%% fitting
x = 2:length(T_MILP);
log_x = log(x-1);
log_y = log(T_MILP(2:end));
figure;
plot(log_x(4:end),log_y(4:end),'o');
grid on;

%p = polyfit(log_x,log_y,1)
%%
figure;
loglog(T_MILP(2:end),'ko-','LineWidth',1.5);
grid on;
hold on;
x = 1:20;
y = x.^1.7*exp(2.4);
xlim([1,30])
ylim([7,3000])
plot(x,y,'b*--','LineWidth',1.5);
xlabel('number of month');
ylabel('Optimization Time (Seconds)');
legend('Real time','y = exp^{2.4} x^{1.7}')
title('Curve fitting for MILP complexity')