% this code uses MOST to solve the MPOPF of 14 case with ESS
% choose bus 10 12 13 14 for ESS
% Yaze Li
clear all; close all; clc;
%% input
t = 1493;
nt = 24;
% load modified case 14
mpc = loadcase('case14mdf');
% add wind energy
turbine = renew(mpc.windSite);
[iwind, mpc, ~] = addrenew(turbine, mpc, []);
wind = wind_profile(t,nt,mpc.baseMVA);
profiles = getprofiles(wind,iwind);
% add loads
[Pload,Qload] = load_profile(t,nt,mpc.loadSite);
% note that add Q first then P
profiles = getprofiles(Qload,profiles);
profiles = getprofiles(Pload,profiles);
% add ESS
[iess, mpc, ~, sd] = addstorage(storage(mpc.essSize,mpc.essSite), mpc, []);
%% solve
tic
mdi = loadmd(mpc, nt, [], sd, [], profiles);
mpopt = mpoption('verbose',3,'out.all',1);
mpopt = mpoption(mpopt, 'most.storage.cyclic', 1);
mdo = most(mdi, mpopt);
toc
%% get results
EPg = mdo.results.ExpectedDispatch; % active generation
Elam = mdo.results.GenPrices; % nodal energy price
ms = most_summary(mdo); % print results, depending on verbose option
cost = ms.f;
Pg = ms.Pg(1:6,:);
Pb = ms.Pg(7:10,:);