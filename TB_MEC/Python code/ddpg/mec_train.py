"""This file trains a DDPG model using the mec environment.
By Yaze Li, University of Arkansas. 06/02/2023 """

from stable_baselines3 import DDPG
from stable_baselines3.common.noise import NormalActionNoise
import os
from mec_env import MecTrainEnv
import time
import numpy as np
from check_mec_env import network, bus_i, bus_c, bus_r, bus_renew

# Create path to record model and training log.
models_dir = 'models/'
logdir = 'logs'

models_name = f"models/{int(time.time())}/"

if not os.path.exists(models_dir):
	os.makedirs(models_dir)

if not os.path.exists(logdir):
	os.makedirs(logdir)

# Train for a single day
month = 7
date = 1


# Create environment
env = MecTrainEnv(network, bus_i, bus_c, bus_r, bus_renew, month, date)
env.reset()

# The noise objects for DDPG
n_actions = env.action_space.shape[-1]
action_noise = NormalActionNoise(mean=np.zeros(n_actions), sigma=0.1 * np.ones(n_actions))

model = DDPG('MlpPolicy', env, verbose=1, tensorboard_log=logdir,
                        action_noise=action_noise,
                        #device = 'cuda',
						device = 'cpu',
			)

start_time = time.time()
timesteps = 10_000
iterations = 10
for iter in range(iterations):
	model.learn(total_timesteps = timesteps, reset_num_timesteps=False, tb_log_name=f"ddpg_{iter}_run")
	model.save(f"{models_name}/{timesteps*iter}")

#print('with GPU:', time.time()-start_time)
"""
Type the following bash command to the ternimal:
tensorboard --logdir logs
"""