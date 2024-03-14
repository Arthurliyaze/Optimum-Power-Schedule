"""This file checks if mec_visual_env works.
By Yaze Li, University of Arkansas. 06/07/2023"""

from stable_baselines3.common.env_checker import check_env
from mec_visual_env import MecVisualEnv
import gymnasium as gym
from gymnasium.wrappers import FlattenObservation

import pandapower.networks as pn

network = pn.case14()
month = 7
date = 1

bus_i = [1]
bus_c = [4,12]
bus_r = [2,3,5,8,9,10,11]
bus_renew = [2,5,7,10]

env = MecVisualEnv(network, bus_i, bus_c, bus_r, bus_renew, month, date)
wrapped_env = FlattenObservation(env)
# It will check your custom environment and output additional warnings if needed
#print(wrapped_env.reset())
check_env(wrapped_env)