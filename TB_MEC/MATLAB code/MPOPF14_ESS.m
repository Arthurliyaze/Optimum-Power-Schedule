% this code uses MOST to solve the MPOPF of 14 case with ESS
% choose bus 3 6 8 11 for ESS
% Yaze Li, University of Arkansas
clear all; close all; clc;
%% input
nt = 24;
% load modified case 14
mpc = loadcase('case14mdf');
% add renew energy
renew = renew(mpc.renewSite);
[irenew, mpc, ~] = addrenew(renew, mpc, []);
windpv = renew_profile(nt);
profiles = getprofiles(windpv,irenew);
% add loads
Pload = load_profile(nt);
profiles = getprofiles(Pload,profiles);
% add ESS
%[iess, mpc, ~, sd] = addstorage(storage(mpc.essSize,mpc.essSite), mpc, []);
%% solve
tic
mdi = loadmd(mpc, nt, [], [], [], profiles);
mpopt = mpoption('verbose',3,'out.all',1);
mpopt = mpoption(mpopt, 'most.storage.cyclic', 1);
mdo = most(mdi, mpopt);
toc
%% get results
EPg = mdo.results.ExpectedDispatch; % active generation
Elam = mdo.results.GenPrices; % nodal energy price
ms = most_summary(mdo); % print results, depending on verbose option
cost = ms.f;
Pg = ms.Pg(1:5,:);
Pb = -ms.Pg(10:13,:);