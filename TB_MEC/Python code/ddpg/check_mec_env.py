"""This file checks if mec_env works.
By Yaze Li, University of Arkansas. 06/01/2023"""

from stable_baselines3.common.env_checker import check_env
from mec_env import MecTrainEnv

import pandapower.networks as pn


network = pn.case14()
month = 7
date = 1

bus_i = [1]
bus_c = [4,12]
bus_r = [2,3,5,8,9,10,11]

bus_renew = [2,5,7,10]

env = MecTrainEnv(network, bus_i, bus_c, bus_r, bus_renew, month, date)

# It will check your custom environment and output additional warnings if needed
check_env(env)