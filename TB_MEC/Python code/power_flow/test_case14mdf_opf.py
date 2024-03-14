"""This file test the optimal power flow on the modified 
IEEE 14 bus system.
By Yaze Li, University of Arkansas. 05/29/2023"""

import pandapower
import pandapower.networks as pn
import matplotlib.pyplot as plt
from get_profile import *

month = 7
date = 1
hour = 1
# Get the data
wind = get_day_index(get_wind_profile(), month, date)[0]
pv = get_day_index(get_pv_profile(), month, date)[0]
res = get_day_index(get_residential_profile(), month, date)[0]
com = get_day_index(get_commercial_profile(), month, date)[0]
ind = get_day_index(get_industrial_profile(), month, date)[0]

l = 4
m = 10
bus_i = [1]
bus_c = [4,12]
bus_r = [2,3,5,8,9,10,11]
bus_renew = [2,5,7,10]

# Calculate powerflow with python
# Change the active power in case 14 load bus
net = pn.case14()
for bus in range(len(bus_i)):
    net.load.p_mw[bus_i[bus]] = ind[hour]

for bus in range(len(bus_c)):
    net.load.p_mw[bus_c[bus]] = com[hour]

for bus in range(len(bus_r)):
    net.load.p_mw[bus_r[bus]] = res[hour]

# Add renew power as static generator at renew bus
for renew in range(l):
    pandapower.create_sgen(net, bus_renew[renew], p_mw = wind[hour]+pv[hour], name = 'renew', controllable=False)

# May output a warning to set bus limit for generators.

pandapower.runopp(net, suppress_warnings=True)
#print(net.res_cost)
print(net.res_ext_grid)