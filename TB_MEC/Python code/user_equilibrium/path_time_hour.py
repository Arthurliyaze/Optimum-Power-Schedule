"""This file calculates the travel time on the fastest path,
and record the fastest path by a list of passing node
between each O-D pair at different hours in a day.
By Yaze Li, University of Arkansas. 05/27/2023"""
import os
import sys
import pandas as pd
import json
import networkx as nx

current_directory = os.getcwd()
parent = os.path.dirname(current_directory)
network_path = parent + '\plot_network'
ue_directory = parent + '\\user_equilibrium\\'
sys.path.insert(0,network_path)

from transnetwork_for_plot import Transnetwork
from plot_siouxfalls import *
from get_csv import *

# Read link time by hour in the text file
df = pd.read_csv(ue_directory+'link_time_hour.txt', sep=' ', header=None)
#a = df.iloc[0]

# Get network data
net, node, od, bus = get_data()

path_time_hour = {}
path_hour = {}

for hour in range(24):
    # Change travel time from free flwo to UE flow
    net['link_fftime'] = df.iloc[hour].tolist()

    # Build network
    siouxfalls = get_siouxfalls(net, node, od, bus)

    # Get the fastest path between all nodes.
    path_time = dict(nx.all_pairs_dijkstra_path_length(siouxfalls, weight='travel_time'))
    path = dict(nx.all_pairs_dijkstra_path(siouxfalls, weight='travel_time'))

    # Read the travel time and path from dictionary to a dataframe.
    path_time_df = pd.DataFrame.from_dict(path_time).sort_index().to_json()
    path_df = pd.DataFrame.from_dict(path).sort_index().to_json()
    path_time_hour[hour+1] = path_time_df
    path_hour[hour+1] = path_df

# Save results to json  
with open(ue_directory+'path_time_hour.json','w') as outfile:
    json.dump(path_time_hour, outfile)
with open(ue_directory+'path_hour.json','w') as outfile:
    json.dump(path_hour, outfile) 