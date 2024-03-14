"""This file modifies the IEEE 14 bus system,
and calculate the generation and cost of the system on a test day.
By Yaze Li, University of Arkansas. 05/31/2023"""

import os
import sys
import pandas as pd

current_directory = os.getcwd()
parent = os.path.dirname(current_directory)
powerflow_path = parent + '\power_flow'
sys.path.insert(0,powerflow_path)

import pandapower
import pandapower.networks as pn
import matplotlib.pyplot as plt
from get_profile import *

def change_load(net, bus_c, bus_i, bus_r, month, date, hour):
    """Change the load of the load bus to the load profile of 
    the chosen day."""

    res = get_day_index(get_residential_profile(), month, date)[0]
    com = get_day_index(get_commercial_profile(), month, date)[0]
    ind = get_day_index(get_industrial_profile(), month, date)[0]

    idx_i = net.load.index[net.load['bus'].isin(bus_i)]
    net.load.loc[idx_i, 'p_mw'] = ind[hour]

    idx_c = net.load.index[net.load['bus'].isin(bus_c)]
    net.load.loc[idx_c, 'p_mw'] = com[hour]
    
    idx_r = net.load.index[net.load['bus'].isin(bus_r)]
    net.load.loc[idx_r, 'p_mw'] = res[hour]

    idx_n = net.load.index[net.load['bus'].isin([0,6,7,13])]
    net.load.loc[idx_n, 'p_mw'] = 0

    return net

def add_renewable(net, bus_renew, month, date, hour):
    """Add renew energy as static generators at renew bus,
    whose load is the renewable profile on the chosen day."""

    wind = get_day_index(get_wind_profile(), month, date)[0]
    pv = get_day_index(get_pv_profile(), month, date)[0]

    for renew in range(len(bus_renew)):
        pandapower.create_sgen(net, bus_renew[renew], 
                            p_mw = wind[hour]+pv[hour], 
                            #sn_mva = wind[hour]+pv[hour], 
                            name = f'renew_{renew+1}', controllable=False)

    return net

def test_converge(bus_c, bus_i, bus_r, bus_renew, month, date):
    """Test if the modeified network has an optimal power flow result."""
    
    for hour in range(1,25):
        network = pn.case14()
        network_1 = change_load(network, bus_c, bus_i, bus_r, month, date, hour)
        network_2 = add_renewable(network_1, bus_renew, month, date, hour)
        try:
            pandapower.runopp(network_2)
            print(f'OPF converged for hour {hour}.')
        except:
            print(f'OPF did not converge for hour {hour}.')

def calculate_opf(bus_c, bus_i, bus_r, bus_renew, month, date):
    """Test if the modeified network has an optimal power flow result."""
    
    cost = []
    gen = pd.DataFrame(index=range(4))
    for hour in range(1,25):
        network = pn.case14()
        network_1 = change_load(network, bus_c, bus_i, bus_r, month, date, hour)
        network_2 = add_renewable(network_1, bus_renew, month, date, hour)
        pandapower.runopp(network_2)
        cost.append(network_2.res_cost)
        gen[f'{hour}'] = network_2.res_gen.p_mw

    return gen, cost
"""
# For test
month = 7
date = 1

bus_i = [1]
bus_c = [4,12]
bus_r = [2,3,5,8,9,10,11]

bus_renew = [2,5,7,10]

gen, cost = calculate_opf(bus_c, bus_i, bus_r, bus_renew, month, date)
"""