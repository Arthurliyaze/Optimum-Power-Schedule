"""This python file returns a transnetwork class of 
siouxfalls network.
By Yaze Li, University of Arkansas 05/15/2023"""
from transnetwork_for_plot import Transnetwork
import networkx as nx

def get_siouxfalls(net, node, od, bus):
    """Return a transnetwork class of the siouxfalls network"""

    siouxfalls = Transnetwork(name='SiouxFalls')
    attrs = {}
    bus_idx = 0

    for num in range(len(node['node_idx'])):
        siouxfalls.add_node(node['node_idx'][num])
        attr = {}
        attr['position'] = [int(node['node_x'][num]), int(node['node_y'][num])]
        
        if node['node_idx'][num] in bus['node_idx']:
            attr['bus_idx'] = bus['bus_idx'][bus_idx]
            attr['load_type'] = bus['load_type'][bus_idx]
            bus_idx += 1
        attrs[node['node_idx'][num]] = attr
        nx.set_node_attributes(siouxfalls, attrs)

    for num in range(len(net['link_idx'])):
        link = (net['link_a'][num], net['link_b'][num], net['link_fftime'][num])
        siouxfalls.add_weighted_edges_from([link], weight='travel_time', index=num+1)

    for num in range(len(od['demand_o'])):
        siouxfalls.add_demands(od['demand_o'][num], od['demand_d'][num],
                                demand = od['demand'][num])

    return siouxfalls