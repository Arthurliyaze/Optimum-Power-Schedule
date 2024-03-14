# -*- coding: utf-8 -*-
"""
Created on Fri Nov 13 03:02:35 2020
Project: Battery schedule by DQN
@author: yazeli
Version: 1
"""

#%% Importing Libraries and Dependencies
from silence_tensorflow import silence_tensorflow
silence_tensorflow()

import numpy as np
import os
clear = lambda: os.system('cls')

from gym import Env
from gym.spaces import Discrete, Box
from scipy.io import loadmat, savemat
#%%
from stable_baselines.deepq.policies import FeedForwardPolicy
from stable_baselines import DQN

from stable_baselines.bench import Monitor
from stable_baselines.results_plotter import load_results, ts2xy
from stable_baselines.common.callbacks import BaseCallback

#%% Parameters
phi = 100
N_b = 5500 # number of batteries
N_s = 82 # number of solar panels
Qmax = 5 # maximum charge/discharge rate of the battery
Smax = 13.5 #battery capacity for bounding in function initilization
Gamma_e=0.94 # energy efficiency
Dmax = 16.08 # Demand charge rate

#%% Get the training and testing set
"""
The notations of dataset
train: 2016(1-12)
test: 2017(1-9)
"""

uark = loadmat('uark_data.mat')
# Get the data
ld = uark['ld']
re = uark['re']
s = uark['s']
T = uark['T']
tou = uark['p']
del uark

opt = loadmat('opt.mat')
cost_opt = opt['cost_opt']
cost_org = opt['cost_org']
cost_pv = opt['cost_pv']
q_opt = opt['q_opt']
c_opt = opt['c_opt']
qnet_opt = opt['qnet_opt']
qnet_subopt = opt['q_subopt']
#%%
class SaveOnBestTrainingRewardCallback(BaseCallback):
    """
    Callback for saving a model (the check is done every ``check_freq`` steps)
    based on the training reward (in practice, we recommend using ``EvalCallback``).

    :param check_freq: (int)
    :param log_dir: (str) Path to the folder where the model will be saved.
      It must contains the file created by the ``Monitor`` wrapper.
    :param season: (int) 
    :param verbose: (int)
    """
    def __init__(self, check_freq: int, log_dir: str, season: int, verbose=1):
        super(SaveOnBestTrainingRewardCallback, self).__init__(verbose)
        self.check_freq = check_freq
        self.log_dir = log_dir
        self.season = season
        self.save_path = os.path.join(log_dir, 'best_dqn_model_'+str(['summer','winter'][self.season]))
        self.best_mean_reward = -np.inf

    def _init_callback(self) -> None:
        # Create folder if needed
        if self.save_path is not None:
            os.makedirs(self.save_path, exist_ok=True)

    def _on_step(self) -> bool:
        if self.n_calls % self.check_freq == 0:

          # Retrieve training reward
          x, y = ts2xy(load_results(self.log_dir), 'timesteps')
          if len(x) > 0:
              # Mean training reward over the last month's episodes
              mean_reward = np.mean(y[-30:])
              if self.verbose > 0:
                print("Num timesteps: {}".format(self.num_timesteps))
                print("Best mean reward: {:.2f} - Last mean reward per episode: {:.2f}".format(self.best_mean_reward, mean_reward))

              # New best model, you could save the agent here
              if mean_reward > self.best_mean_reward:
                  self.best_mean_reward = mean_reward
                  print("Best mean reward: {:.2f} - Last mean reward per episode: {:.2f}".format(self.best_mean_reward, mean_reward))
                  # Example for saving best model
                  if self.verbose > 0:
                    print("Saving new best model to {}".format(self.save_path))
                  self.model.save(self.save_path)

        return True
#%% Define environment
class BatteryEnv(Env):
  """
  A customized environment for training and testing dqn
  """
  metadata = {'render.modes': ['human']}
  
  def __init__(self, m, train):
      """
      Environment Parameters
      m: month 0-11
      train: {True, False}
      dimensions of action space (1): battery behavior
      dimensions of state space (3): {hour, load-solar, soc}
      """      
      self.m = m # month 0-11
      self.train = train
      self.action_space = Discrete(128)
      self.observation_space =  Box(low=0, high=10, shape=(3,),dtype=np.float32)
      self.day = 0
      self.reset()
      
  def reset(self):
      self.current_step = 0
      if self.train:
          self.ep_length = 24
      else:
          self.ep_length = T[self.m,0]
      self.Q = 0
      self.state_org = np.concatenate((0, ld[self.m,0]-re[self.m, 0], 0),axis=None)
      self.normalize()
      return self.state      
      
  def my_reset(self, d):
      self.reset
      self.state_org = np.concatenate((0, ld[self.m, 24*d]-re[self.m, 24*d], 0),axis=None)
      self.normalize()
      return self.state
  
  def normalize(self):
      h = self.state_org[0]
      qld = self.state_org[1]
      c = self.state_org[2]
      
      if self.m < 4 or self.m > 9: # winter
          if h < 9 or h > 20:
              h_nor = 0
          else:
              h_nor = 1
      else: # summer
          if h < 12 or h > 17:
              h_nor = 0
          else:
              h_nor = 1
      qld_nor = qld/10000
      c_nor = c/(N_b*Smax)
      self.state = np.concatenate((h_nor, qld_nor, c_nor),axis=None)
      return self.state
      
      
  
  def step(self, action):

      h = self.state[0]
      qld = self.state[1]*10000
      c = self.state[2]*N_b*Smax      
      
      qmax_step = min(N_b*Qmax,(s[self.m,self.current_step]-c)/Gamma_e)
      qmin_step = max(-N_b*Qmax,-c*Gamma_e)
      d = (qmax_step-qmin_step)/127
      q = action*d+qmin_step
      
      if q>=0:
          c_nxt = c + q*Gamma_e
      else:
          c_nxt = c + q/Gamma_e
      
      qnet = np.max([0,qld+q])
      Q_nxt = np.max([self.Q,qnet])
      p = tou[self.m,self.current_step]
         
      
      if self.train:
          qmax_day = np.max(qnet_opt[self.m,:])
          if qmax_day < qld: # peak load
              qopt = max(qmax_day - qld, -N_b*Qmax) # discharge to qmax to shave peak
              phi = 100
          elif qmax_day > qld and h == 1: # peak hour or part-peak, 
              qopt = max(-qld, -N_b*Qmax) # discharge to 0(summer) or qmax(winter) to shift load
              phi = 20
          else: # qmax_day > qld and h!=0 : off-peak hour
              qopt = min(qmax_day-qld, N_b*Qmax) # charge to qmax to shift load
              phi = 100
          reward = 1-phi*np.abs(qopt-q)/(N_b*Qmax)
      else: # testing
          reward = (qnet*p + Dmax*(Q_nxt-self.Q))
          
      # Transition
      self.current_step += 1
      done = self.current_step >= self.ep_length
      if done:
          if self.train:
              self.day = (self.day+1)%int(T[self.m,0]/24)
              self.my_reset(self.day)
          else:
              self.reset()
      else:
          h_nxt = self.current_step%24
          if self.train:
              qld_nxt = ld[self.m,24*self.day+self.current_step]-re[self.m,24*self.day+self.current_step]
          else:
              qld_nxt = ld[self.m,self.current_step]-re[self.m,self.current_step]
          self.Q = Q_nxt
          self.state_org = np.concatenate((h_nxt, qld_nxt, c_nxt),axis=None)
          self.normalize()
      return self.state, reward, done, q, {}

  def render(self, mode='human', close=False):
      pass

#%% Define policy
# Custom MLP policy of two layers of size [32,32]
class CustomPolicy(FeedForwardPolicy):
    def __init__(self, *args, **kwargs):
        super(CustomPolicy, self).__init__(*args, **kwargs,
                                           layers=[128, 128],
                                           layer_norm=True,
                                           feature_extraction="mlp")
#%% Define the model
log_dir = "./dqn_bs/"
os.makedirs(log_dir, exist_ok=True)
# command for tensorboard:
# tensorboard --logdir="./dqn_bs"
#Define the training environment and model
# m = 18 # July 2017
# season = 0 # Summer
m = 18 # Jan 2017
season = 0 # Winter
#%% Train the model
# train = BatteryEnv(m,train = True)
# train = Monitor(train, log_dir)
# M = 1000 # episodes
# time_steps = M*T[m,0]
# # Create the callback: check every 1000 steps
# callback = SaveOnBestTrainingRewardCallback(check_freq = T[m,0], season = season, log_dir = log_dir, verbose = 1)

# model = DQN(CustomPolicy, train, train_freq = 24, batch_size = 128,
#              verbose = 0, tensorboard_log = log_dir)

# model.learn(total_timesteps = time_steps, callback = callback)

#%% Testing
m = 18
test = BatteryEnv(m,train=False)
model = DQN.load("best_dqn_model_summer", env=test, policy=CustomPolicy, tensorboard_log=log_dir)
obs = test.reset()
dones = False

actions = np.zeros(T[m,0])
obsers = np.zeros((3,T[m,0]))
C_dqn = 0
k = 0
while not dones:
    action, _states = model.predict(obs)
    obs, rewards, dones, q, info = test.step(action)
    actions[k] = q
    
    obsers[:,k] = obs
    C_dqn = C_dqn + rewards
    k = k+1
    test.render()
result = {"q_dqn": actions, "soc_dqn": obsers[2,:]}
savemat('q_py_dqn_19.mat',result)