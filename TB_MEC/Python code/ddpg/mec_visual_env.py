"""This file creates an environment same as mec_env 
but with a visualization and some tiny updates.
By Yaze Li, University of Arkansas. 06/06/2023"""

import numpy as np
import pygame

import gymnasium as gym
from gymnasium import spaces
from gymnasium.spaces import Box, Dict, MultiDiscrete

from ess import Mec, get_path_time_hour
from case14mdf import change_load, add_renewable

import pandapower as pp
import pandapower.networks as pn

from mec_env_game import move_to_bus_figure

class MecVisualEnv(gym.Env):
    metadata = {"render_modes": ["human", "rgb_array"], "render_fps": 4}

    def __init__(self, initial_network, bus_i, bus_c, bus_r,
                  bus_renew, month, date, render_mode=None):
        self.initial_network = initial_network # The initial power system
        self.bus_i = bus_i # The list of bus with industrial loads
        self.bus_r = bus_r # The list of bus with residential loads
        self.bus_c = bus_c # The list of bus with commercial loads
        self.bus_renew = bus_renew # The list of bus with renewable energy sources
        self.b = len(bus_renew) # The number of Mecs
        self.n = len(initial_network.bus) # The number of buses
        self.month = month # The month of the training set
        self.date = date # The date of the training set
        self.ep_len = 24
        self.c_max = 10
        self.q_max = 3
        self.gamma_e = 0.94
        self.bus_to_node = [1,2,5,8,10,12,13,14,15,18,19,20,22,24]
        self.window_size = 1000

        """
        Obserations are dictionaries with the curtianment of each bus
        previous Mec locations, Mec destinations, time left
        for Mec to travel, and SOC of Mec.
        """
        self.observation_space = Dict(
            {
                "Curtainment": Box(low=-1, high=1, shape=(self.n,), dtype=np.float32),
                "Previous_mec_loc": MultiDiscrete([self.n, self.n, self.n, self.n], seed=42),
                "Mec_destination": MultiDiscrete([self.n, self.n, self.n, self.n], seed=42),
                "Time_left": MultiDiscrete([self.ep_len, self.ep_len, self.ep_len, self.ep_len], seed=42),
                "Soc": Box(low=-1, high=1, shape=(self.b,), dtype=np.float32),
            }
        )

        # We have 8 actions, corresponding to assigned bus for Mec and Mec battery schedule
        # Stablebaselines3 DDPG only supports Box as action space
        self.action_space = spaces.Box(low=-1, high=1, shape=(2*self.b,), dtype=np.float32)

        assert render_mode is None or render_mode in self.metadata["render_modes"]
        self.render_mode = render_mode

        """
        If human-rendering is used, `self.window` will be a reference
        to the window that we draw to. `self.clock` will be a clock that is used
        to ensure that the environment is rendered at the correct framerate in
        human-mode. They will remain `None` until human-mode is used for the
        first time.
        """
        self.window = None
        self.clock = None
        self.directionNumbers = {0:'right', 1:'down', 2:'left', 3:'up'}
        self.reset()

    def _get_obs(self):
        """Constructing Observations From Environment States"""
        
        # Curtain is bound to -1 to 1 by tanh
        self._curtain = np.tanh(self._get_curtain())
        self._pre_loc = np.array([Mec.get_location(mec) for mec in self.mecs])
        self._nxt_loc = np.array([Mec.get_destination(mec) for mec in self.mecs])
        self._time_lft = np.array([Mec.get_time_left(mec) for mec in self.mecs])
        # SOC also needs to be bound to -1 to 1
        self._soc = np.array([Mec.get_soc(mec)/self.c_max*2-1 for mec in self.mecs])
        obs = {"Curtainment": self._curtain,
                "Previous_mec_loc": self._pre_loc,
                "Mec_destination": self._nxt_loc,
                "Time_left": self._time_lft,
                "Soc": self._soc}
        return obs
    
    def _get_acts(self, action):
        """
        Constructing Actions from Actor network.
        {
            "Mec_destination_assign": MultiDiscrete([self.n, self.n, self.n, self.n], seed=42),
            "Battery_schedule": Box(low=-1, high=1, shape=(self.b,), dtype=np.float32),
        }
        """

        # Change assign from Box to Discrete
        assign = []
        bus_list = list(range(self.n))
        for b in range(self.b):
            scaled_action = 7*(action[b]+1)
            destination = min(bus_list, key=lambda x: abs(x-scaled_action))
            assign.append(destination)
        # Get battery schedule
        schedule = action[4:]
        return assign, schedule
    
    def _get_info(self):
        """Provide the Mec information"""

        info = {}
        for idx in range(self.b):
            info[f"Mec{idx+1}"] = f"{self._pre_loc[idx]}->{self._nxt_loc[idx]} in {self._time_lft[idx]} hour. ({(self._soc[idx]+1)*50}%)"
        return info
    
    def reset(self, seed=None, options=None):
        """Initial a new episode."""

        #self.done = False
        self.e_loss = 0.0
        self.penalty = 0.0
        self.reward = 0.0
        self.hour = 1
        self.mecs = []

        # We need the following line to seed self.np_random
        super().reset(seed=seed)

        # Modify network to the profile in the first hour.
        self.modify_network_hour()

        # Initial the Mecs
        for b in range(self.b):
            mec = Mec(self.c_max,self.q_max,self.gamma_e,self.bus_renew[b],self.hour)
            self.mecs.append(mec)

        observation = self._get_obs()
        info = self._get_info()

        if self.render_mode == "human":
            self._render_frame()

        return observation, info
    
    def step(self, action):
        """accepts an action, computes the state of the environment
            after applying that action and returns the 4-tuple 
            (observation, reward, done, info)"""

        assign = self._get_acts(action)[0]
        schedule = self._get_acts(action)[1]
        # Check if Mec is traveling or not
        for b in range(self.b):
            mec = self.mecs[b]
            if mec.get_time_left() > 0:
                # Still on the way to the assigned destination
                # Time deduct by 1 hour
                mec.time_to_bus(mec.get_time_left()-1)
                self.e_loss += 0.1

            else:
                # Arrived at destination

                # Update location
                origin = mec.get_destination()
                mec.set_location(origin)
                # Update destination
                destination = assign[b]
                mec.move_to_bus(destination)
                # Update time left
                origin_node = self.bus_to_node[origin]
                destination_node = self.bus_to_node[destination]
                time_lft = get_path_time_hour(origin_node,destination_node,self.hour)
                mec.time_to_bus(time_lft)
                
                if destination == origin:
                    # Park for an hour
                    self.reward += 0.5

                    # Charge/discharge
                    q = schedule[b]*self.q_max
                    q_limited, violate = mec.charge(q)
                    if violate:
                        self.penalty += 0.5
                    
                    # Add storage at bus
                    pp.create_storage(self.network, 
                                                bus = origin, 
                                                p_mw = q_limited,
                                                max_p_mw = self.q_max,
                                                soc_percent = mec.soc/self.c_max,
                                                max_e_mwh = self.c_max)
            
        # Run AC OPF
        try:
            pp.runopp(self.network)
            # Calculate difference
            generation = np.abs(self.network.res_ext_grid['p_mw'][0]) + sum(self.network.res_gen['p_mw'])
            self.penalty += np.tanh(generation)
        except:
            # OPF not converge
            self.penalty += 1
            self.done = True

        # Check final SOC
        terminated = (self.hour == self.ep_len)
        if terminated:
            # Punish for remaining power
            for b in range(self.b):
                mec = self.mecs[b]
                soc_percent = mec.soc/self.c_max

                self.penalty += soc_percent
        else:
            self.hour += 1
            self.modify_network_hour()

            # Update the observation
            observation = self._get_obs()

        reward = 20 + self.reward - (self.e_loss + self.penalty)
        info = self._get_info()

        if self.render_mode == "human":
            self._render_frame()

        return observation, reward, terminated, False, info

    def modify_network_hour(self):
        """Modify the network at hour self.hour"""

        self.initial_network = pn.case14()
        # Change the load and add renewable energy.
        network1 = change_load(self.initial_network,self.bus_c,self.bus_i,self.bus_r,self.month,self.date,self.hour)
        self.network = add_renewable(network1,self.bus_renew,self.month,self.date,self.hour)

    def _get_curtain(self):
        """Return the curtain list of each bus in the network."""

        curtain = []
        for bus in self.network.bus['name']:
            load, renew = 0, 0
            # Check if there is load
            if bus in self.network.load['bus']:
                idx = self.network.load.index[self.network.load['bus']==bus]
                try:
                    load = self.network.load.loc[idx].p_mw.values[0]
                except:
                    load = 0

            # Check if there is renew
            if bus in self.network.sgen['bus']:
                idx = self.network.sgen.index[self.network.sgen['bus']==bus]
                try:
                    renew = self.network.sgen.loc[idx].p_mw.values[0]
                except:
                    renew = 0
            curtain.append(load-renew)

        return np.array(curtain)
    
    def render(self):
        """Using PyGame for rendering."""

        if self.render_mode == "rgb_array":
            return self._render_frame()
    
    def _render_frame(self):
        if self.window is None and self.render_mode == "human":
            pygame.init()
            pygame.display.init()
            self.window = pygame.display.set_mode((self.window_size, self.window_size))
        if self.clock is None and self.render_mode == "human":
            self.clock = pygame.time.Clock()

        # changing title of the game window
        pygame.display.set_caption('Mec Movement Simulation')

        # setting background image
        surface = pygame.image.load('images/Buses in the SiouxFalls Network.png')

        if self.render_mode == "human":
            # Poll for events
            for event in pygame.event.get():
                # pygame.QUIT event means the user clicked X to close your window
                if event.type == pygame.QUIT:
                    self.close()

            #displaying the background image
            self.window.blit(surface,(0,-100))

            for mec in self.mecs:
                move_to_bus_figure(mec, mec.get_destination, self.window, self.clock)
        else:  # rgb_array
            return np.transpose(
                np.array(pygame.surfarray.pixels3d(surface)), axes=(1, 0, 2)
            )

    def close(self):
        if self.window is not None:
            pygame.display.quit()
            pygame.quit()