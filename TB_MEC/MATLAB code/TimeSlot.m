% this script chooses the route with the shortest total travel time in the
% modified Sioux Falls network between all buses
% Yaze Li, University of Arkansas
clear; close all; clc;

%% Load the data
load siouxfalls.mat % original sioux falls data
load avgTravelTime.mat

busnum = 14;
busnodes = [1,2,5,8,10,12,13,14,16,18,19,20,22,24];
busid = nan*ones(24,1);
for i=1:busnum
    busid(busnodes(i))=i;
end
nodes = addvars(nodes,busid,'After','id');
%% Create Sioux Falls graph and calculated hourly shortest path time
shortestPathTime = zeros(busnum,busnum,24);
for hour = 1:24
    G = digraph(links.fromNode,links.toNode,travelTime(:,hour));
    for m1=1:busnum
        for m2=1:busnum
            if m1 ~= m2
                [~,shortestPathTime(m1,m2,hour)] = shortestpath(G,busnodes(m1),busnodes(m2));
            end
        end
    end
end
shortestPathSlot = ceil(shortestPathTime);
%% Plot the shortest path slot at 6 p.m.
figure;
imagesc(shortestPathSlot(:,:,18));
colorbar
xlabel('destination bus')
ylabel('origin bus')
title('Shortest path time slots at 6 p.m.')
%% save matrix
save shortestPath.mat shortestPathTime shortestPathSlot