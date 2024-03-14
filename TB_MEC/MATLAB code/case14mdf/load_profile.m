function [Pload_profile] = load_profile(nt)
%UARK_LOAD_PROFILE  imports load profile data period
%   nt:     time horizon imported
%   bus_no: bus number where the load energy is changed
%   Pload_profile:  Active load profile
%   Yaze Li, University of Arkansas

%% define constants
[CT_LABEL, CT_PROB, CT_TABLE, CT_TBUS, CT_TGEN, CT_TBRCH, CT_TAREABUS, ...
    CT_TAREAGEN, CT_TAREABRCH, CT_ROW, CT_COL, CT_CHGTYPE, CT_REP, ...
    CT_REL, CT_ADD, CT_NEWVAL, CT_TLOAD, CT_TAREALOAD, CT_LOAD_ALL_PQ, ...
    CT_LOAD_FIX_PQ, CT_LOAD_DIS_PQ, CT_LOAD_ALL_P, CT_LOAD_FIX_P, ...
    CT_LOAD_DIS_P, CT_TGENCOST, CT_TAREAGENCOST, CT_MODCOST_F, ...
    CT_MODCOST_X] = idx_ct;
%% import load proflie from t to t+nt-1
% Note that testing set is used for ACOPF
profile = load('profile.mat');
bus_no = [2,3,4,5,6,9,10,11,12,13];
rbus = [2,3,5,6,7,8,9];
cbus = [4,10];
ibus = 1;
Pload = zeros(nt,length(bus_no));
Pload(:,1) = profile.iload';
for bus = 2:length(bus_no)
    if ismember(bus,cbus)
        Pload(:,bus) = profile.cload';
    else
        Pload(:,bus) = profile.rload';
    end
end

% bus_no = [10,12,13,14];
% cbus = 2;
% Pload(:,1) = profile.iload';
% for bus = 2:length(bus_no)
%     if ismember(bus,cbus)
%         Pload(:,bus) = profile.cload';
%     else
%         Pload(:,bus) = profile.rload';
%     end
% end

% Construct load profile structure
% Change P
Pload_profile = struct( ...
    'type', 'mpcData', ...
    'table', CT_TLOAD, ...
    'rows', bus_no, ...
    'col', CT_LOAD_ALL_P, ...
    'chgtype', CT_REP, ...
    'values', [] );
Pload_profile.values(:, 1, :) = Pload;
