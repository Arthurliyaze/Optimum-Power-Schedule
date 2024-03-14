"""This python file draws plots for siouxfalls.
By Yaze Li, University of Arkansas 05/17/2023"""
from get_csv import get_csv
from get_siouxfalls import get_siouxfalls
import os

# Extract data from 3 files
current_directory = os.getcwd()
parent = os.path.dirname(current_directory)
data_directory = parent + '\\data\\'
#print(data_directory)

def get_data():
    """Return net, node, od, bus to build network."""

    net_file = data_directory + 'SiouxFalls_net.csv'
    node_file = data_directory + 'SiouxFalls_node.csv'
    od_file = data_directory + 'SiouxFalls_od.csv'
    bus_file = data_directory + 'Bus_node.csv'

    net_columns = ['link_idx', 'link_a', 'link_b', 'link_fftime']
    node_columns = ['node_idx', 'node_x', 'node_y']
    od_columns = ['demand_o', 'demand_d','demand']
    bus_columns = ['bus_idx', 'node_idx', 'load_type']

    net = get_csv(net_file, net_columns)
    node = get_csv(node_file, node_columns)
    od = get_csv(od_file, od_columns)
    bus = get_csv(bus_file, bus_columns)

    return net, node, od, bus

# Get data
net, node, od, bus = get_data()

# Get a transnetwork of siouxfalls
siouxfalls = get_siouxfalls(net, node, od, bus)

figure_path = parent + '\\figure\\'

# Draw the whole network#
title1 = 'Sioux Falls Transportation Network'
#fig1 = siouxfalls.draw_transnetwork(width=10, height=12)#, title=title1)
#fig1.savefig(figure_path+title1+'.svg',format='svg')

# Draw different type of loads in the network
title2 = 'Buses in the SiouxFalls Network'
#fig2 = siouxfalls.draw_bus_in_transnetwork(width=10, height=12)#, title=title2)
#fig2.savefig(figure_path+title2+'.svg',format='svg')

# Draw different type of loads in the network in black and white
title3 = 'Buses in the SiouxFalls Network new'
fig3 = siouxfalls.draw_bus_in_transnetwork_bw(width=12, height=8)#, title=title2)
#fig3.savefig(figure_path+title3+'.png',format='png')