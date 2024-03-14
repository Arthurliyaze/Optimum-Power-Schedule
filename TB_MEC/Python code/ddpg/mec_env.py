"""This file creates an environment following the gym environment
structure and describes the behaviors of the MEC in both the 
transportation network and the power system network.
By Yaze Li, University of Arkansas. 05/30/2023"""

import gymnasium as gym
import numpy as np
from gymnasium import spaces
import pandapower
from case14mdf import change_load, add_renewable
from ess import Mec, get_path_time_hour
import pandapower.networks as pn

# Global parameters
# Discount factor, ess efiiciency
gamma, gamma_e = 1, 0.94
# Ess limits
c_max, q_max = 10, 3
bus_to_node = [1,2,5,8,10,12,13,14,15,18,19,20,22,24]


class MecTrainEnv(gym.Env):
    """
    A customized environment based on gym environment.

    Attributes
    ----------
    gamma : float
        The fixed reward discount factor in [0,1]
    gamma_e: float
        The efficiency of the ESS
    c_max: int
        The ESS capacity
    q_max: int
        The ESS maximum charging rate
    lamb : int or float
        The factor multiplying the penalty associated with violating
        operational constraints (used in the reward signal).
    network: pandapower network
        The disribution network.
    month: int
        month in [1,12]
    date: int
        date in [1,31]
    hour: int
        hour in [1,24]
    bus_i: list of int
        bus ID of industrial loads.
    bus_c: list of int
        bus ID of commercial loads.
    bus_r: list of int
        bus ID of residential loads.
    bus_renew: list of int
        bus ID of renewable energy sourses.

    """

    def __init__(self, initial_network, bus_i, bus_c, bus_r, bus_renew, month, date):
        """      
        Environment Parameters
        dimensions of action space (8): mec assign bus: 4 continuous (-1 to 1)
                                        mec soc: 4 continuous (-1 to 1)
        dimensions of state space (30):   curtain = active load - renewable at 14 bus
                                            previous truck location: 4 discrete
                                            next truck location: 4 discrete
                                            time left for truck: 4 discrete
                                            mess soc: 4 continuous                         
        """

        self.initial_network = initial_network
        self.bus_i = bus_i
        self.bus_r = bus_r
        self.bus_c = bus_c
        self.bus_renew = bus_renew
        self.b = len(bus_renew)
        self.n = len(initial_network.bus)
        self.month = month
        self.date = date
        self.action_space = spaces.Box(low=-1, high=1, shape=(2*self.b,), dtype=np.float32)
        self.observation_space = spaces.Box(low=-1, high=1, shape=(self.n + 4*self.b,),dtype=np.float64)
        
        self.info = {}
        self.reset()

    def reset(self,seed=None):
        """
        Reset the environment.

        Returns
        -------
        observation : numpy.ndarray
            The initial observation vector: math 'a_0'
        """

        self.done = False
        self.render_mode = None
        self.timestep = 0
        self.e_loss = 0.0
        self.penalty = 0.0
        self.reward = 0.0
        self.hour = 1
        self.mecs = []
        self.seed = seed

        # Modify network to the profile in the first hour.
        self.modify_network_hour()

        # Initial the Mecs
        for b in range(self.b):
            mec = Mec(c_max,q_max,gamma_e,self.bus_renew[b],self.hour)
            self.mecs.append(mec)

        # Initialize the state.
        self.observation = self.create_observation()

        return self.observation, self.info
    
    def step(self, action):
        """
        Take a control action and transition 
        from state :math:'s_t' to state :math:'s_{t+1}'.

        Parameters
        ----------
        action : numpy.ndarray
            The action vector :math:'a_t' taken by the agent.

        Returns
        -------
        obs : numpy.ndarray
            The observation vector :math:'o_{t+1}'.
        reward : float
            The reward associated with the transition :math:'r_t'.
        terminated : bool
            The parameter to show if reach the goal or the max number of steps (not used in this project).
        done : bool
            True if a terminal state has been reached; False otherwise.
        info : dict
            A dictionary with further information (used for debugging).
        """

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
                bus_list = list(range(self.n))
                scaled_action = 7*(action[b]+1)
                destination = min(bus_list, key=lambda x: abs(x-scaled_action))
                mec.move_to_bus(destination)
                # Update time left
                origin_node = bus_to_node[origin]
                destination_node = bus_to_node[destination]
                time_lft = get_path_time_hour(origin_node,destination_node,self.hour)
                mec.time_to_bus(time_lft)
                
                if destination == origin:
                    # Park for an hour
                    self.reward += 0.5

                    # Charge/discharge
                    q = action[b+4]*q_max
                    q_real, violate = mec.charge(q)
                    if violate:
                        self.penalty += 0.5
                    
                    # Add storage at bus
                    
                    pandapower.create_storage(self.network, 
                                                bus = origin, 
                                                p_mw = q_real,
                                                max_p_mw = q_max,
                                                soc_percent = mec.soc/c_max,
                                                max_e_mwh = c_max) 

        # Run AC OPF
        try:
            pandapower.runopp(self.network)
            # Calculate difference
            self.generation = np.abs(self.network.res_ext_grid['p_mw'][0]) + sum(self.network.res_gen['p_mw'])
            self.penalty += np.tanh(self.generation)
        except:
            # OPF not converge
            self.penalty += 1
            self.done = True

        # Check final SOC
        if self.hour == 24:
            self.done = True
            for b in range(self.b):
                mec = self.mecs[b]
                soc_percent = mec.soc/c_max

                self.penalty += soc_percent
        else:
            self.hour += 1
            #self.reward += self.hour
            self.modify_network_hour()

            # Update the observation
            self.observation = self.create_observation()

        r = self.reward-(self.e_loss+self.penalty)#-0.01*self.network.res_cost
        terminated = self.done
        

        return self.observation, r, terminated, self.done, self.info

    def modify_network_hour(self):
        """Modify the network at hour self.hour"""
        self.initial_network = pn.case14()
        # Change the load and add renewable energy.
        network1 = change_load(self.initial_network,self.bus_c,self.bus_i,self.bus_r,self.month,self.date,self.hour)
        self.network = add_renewable(network1,self.bus_renew,self.month,self.date,self.hour)

    def get_curtain(self):
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
                    renew =0
            curtain.append(load-renew)

        return curtain
    
    def create_observation(self):
        """Return a ndarray of normalized observation."""

        curtain = [np.tanh(self.get_curtain()[n]) for n in range(self.n)]
        pre_loc = [Mec.get_location(mec)/7-1 for mec in self.mecs]
        nxt_loc = [Mec.get_destination(mec)/7-1 for mec in self.mecs]
        time_lft = [Mec.get_time_left(mec)/24-1 for mec in self.mecs]
        soc = [Mec.get_soc(mec)/c_max*2-1 for mec in self.mecs]

        return np.array(curtain + pre_loc + nxt_loc + time_lft + soc)

class MecTestEnv(MecTrainEnv):
    """Inheritance from MecTrainEnv"""

    def __init__(self, initial_network, bus_i, bus_c, bus_r, bus_renew, month, date):
        super().__init__(initial_network, bus_i, bus_c, bus_r, bus_renew, month, date)
        self.info = 0

    def step(self, action):
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
                bus_list = list(range(self.n))
                scaled_action = 7*(action[b]+1)
                destination = min(bus_list, key=lambda x: abs(x-scaled_action))
                mec.move_to_bus(destination)
                # Update time left
                origin_node = bus_to_node[origin]
                destination_node = bus_to_node[destination]
                time_lft = get_path_time_hour(origin_node,destination_node,self.hour)
                mec.time_to_bus(time_lft)
                
                if destination == origin:
                    # Park for an hour
                    self.reward += 0.5

                    # Charge/discharge
                    q = action[b+4]*q_max
                    q_real, violate = mec.charge(q)
                    if violate:
                        self.penalty += 0.5
                    
                    # Add storage at bus
                    
                    pandapower.create_storage(self.network, 
                                                bus = origin, 
                                                p_mw = q_real,
                                                max_p_mw = q_max,
                                                soc_percent = mec.soc/c_max,
                                                max_e_mwh = c_max) 

        # Run AC OPF
        try:
            pandapower.runopp(self.network)
            # Calculate difference
            self.generation = np.abs(self.network.res_ext_grid['p_mw'][0]) + sum(self.network.res_gen['p_mw'])
            self.penalty += np.tanh(self.generation)
            r = self.network.res_cost
        except:
            # OPF not converge
            self.penalty += 1
            self.done = True
            r = 1000000

        # Check final SOC
        if self.hour == 24:
            self.done = True
            for b in range(self.b):
                mec = self.mecs[b]
                soc_percent = mec.soc/c_max

                self.penalty += soc_percent
        else:
            self.hour += 1
            #self.reward += self.hour
            self.modify_network_hour()

            # Update the observation
            self.observation = self.create_observation()

        
        terminated = self.done
        
        return self.observation, r, self.done, self.info