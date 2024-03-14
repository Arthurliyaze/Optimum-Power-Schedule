% this script calculates the best known flow of modeified Sious Falls network
% Yaze Li, University of Arkansas
clear; close all; clc;

%% Import the functions for traffic assignment
folder='D:\OneDrive - University of Arkansas\Lab\06Truck_base_MEC\Simulation\TrafficAssignment';
addpath(genpath(folder));

%% Load the data
%network and demand data
load siouxfalls.mat
load proportion.mat

%triple the length
links.length = 3*links.length;

%scale up the dailytrip demands 10 times
odmatrix = 10*odmatrix;

%form hourly od matrix
odmatrix_hour = zeros(24,24,24);
for hour = 1:24
    odmatrix_hour(:,:,hour) = pro_hour(hour)*odmatrix;
end

%% Plot the network
%plotNetwork(nodes,links,true,[]);

%calculate travel costs if there is no flow propagating on the network
alpha = 0.15;
beta = 4;
flows = zeros(size(links,1),1);
travel_costs = calculateCostBPR(alpha,beta,flows,links.length,links.freeSpeed,links.capacity);

%plot loads (cost) on the links
%plotLoadedLinks(nodes,links,travel_costs,true,[],[],[]);
%title('Link length (km)')

%plot loads (number of outgoing links) on the nodes
% nbOut = hist(links.fromNode,size(nodes,1));
% plotLoadedNodes(nodes,links,nbOut',true,[],[],[]);

%% deterministic assignment
travelTime = zeros(76,24);
truckSpeed = 40;
for t = 1:24
    disp(['TAP hour: ',int2str(t)])
    oFlw_Det = DIALB(odmatrix_hour(:,:,t),nodes,links);
    flows_Det = sum(oFlw_Det,2);
    
    freeFlowTime = links.length./links.freeSpeed;
    travelTime(:,t) = freeFlowTime.*links.freeSpeed./truckSpeed.*(1+0.15*(flows_Det./links.capacity).^4);
    % plotLoadedLinks(nodes,links,round(flows_Det),true,[],[],[]);
    % title('Best known link flow')
end
%% Plot the modified hourly TAP result
plotLoadedLinks(nodes,links,round(travelTime(:,18),2),true,[],[],[]);
title('Best known travel time (hr) at 6 p.m.')

%% Save the average travel time matrix
save avgTravelTime.mat travelTime