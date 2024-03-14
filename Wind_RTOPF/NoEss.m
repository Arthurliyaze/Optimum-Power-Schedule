% this code calculates RT-OPF without ESS
% Yaze Li, University of Arkansas
clear; close all; clc;
%% Parameter setting
mpc = loadcase('case14mdf');
t = 1493;
T = 24;
sch = zeros(4,T);

%% Calculate the daily cost
[Pg_noess, loss, cost_noess] = spacopf_ess(sch, t, T, mpc);