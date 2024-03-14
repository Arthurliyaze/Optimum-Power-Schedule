% this code calculates the opf use cost with no ess
% Yaze Li, University of Arkansas
clear; close all; clc;
%%
mpc = loadcase('case14');
profile = load('profile.mat');
N = 14;
T = 24;
n = 5;
m = 10;
bus = 1:N;
gbus = [2,3,6,8];
lbus = [2,3,4,5,6,9,10,11,12,13];
cbus = [5,13];
ibus = 2;
rbus = [3,4,6,9,10,11,12];
bbus = [3,6,8,11];
PD = 3;
QD = 4;
PMAX = 9;

%%
nt_max = zeros(1,24*365);
curt = zeros(1,24*365);
for i = 184
    i
    cload_day = profile.cload(24*i-23:24*i);
    iload_day = profile.iload(24*i-23:24*i);
    rload_day = profile.rload(24*i-23:24*i);
    pv_day = profile.pv(24*i-23:24*i);
    wind_day = profile.wind(24*i-23:24*i);
    for t = 1:T
        mpc.bus(cbus,[PD,QD]) = cload_day(t);
        mpc.bus(ibus,[PD,QD]) = iload_day(t);
        mpc.bus(rbus,[PD,QD]) = rload_day(t);
        mpc.bus(14,[PD,QD]) = 0;
        mpopt = mpoption('verbose',0,'out.all',0);
        results = runopf(mpc,mpopt);
        nt_max(24*i-24+t) = 4*(pv_day(t)+wind_day(t))+sum(results.gen(1:5,2));
        
        [~, mpc, ~] = addrenew(renew(bbus), mpc, []);
        mpc.gen(end-3:end,PMAX) = repmat((pv_day(t)+wind_day(t)),4,1);
        mpopt = mpoption('verbose',0,'out.all',0);
        results = runopf(mpc,mpopt);
        curt(24*i-24+t) = 4*(pv_day(t)+wind_day(t))-sum(results.gen(end-3:end,2))+sum(results.gen(1:5,2));
    end
end
%%
% Pload = zeros(24,10);
% Pload(:,[4,10])= repmat(cload_day',1,2);
% Pload(:,1)= iload_day';
% Pload(:,[2,3,5,6,7,8,9])= repmat(rload_day',1,7);
% Renew = repmat((wind_day+pv_day)',1,4);
% nt = nt_max(1:24)';
% save profile_py.mat Pload Renew nt