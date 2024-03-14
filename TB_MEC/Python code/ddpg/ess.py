"""This file define an energy storage system class.
By Yaze Li, University of Arkansas. 05/30/2023"""

import os
import sys
import numpy as np
import pandas as pd
import json

current_directory = os.getcwd()
parent = os.path.dirname(current_directory)
data_directory = parent + '\\data\\'
sys.path.insert(0,data_directory)

node_xy = pd.read_csv(data_directory+'SiouxFalls_node.csv')
length = 62
width = 26
bus_to_node = [1,2,5,8,10,12,13,14,15,18,19,20,22,24]

def get_path_hour(origin, destination, hour):
    """Return the path for a vehicle to travel from
      origin to destination at hour"""
    
    current_directory = os.getcwd()
    parent = os.path.dirname(current_directory)
    ue_directory = parent + '\\user_equilibrium\\'

    # Opening JSON file
    f_path = open(ue_directory+'path_hour.json')
    
    # returns JSON object as a dictionary
    path = json.load(f_path)

    # return the hourly path
    path_hour = json.loads(path[str(hour)])

    # Find the O-D pair
    path = path_hour[str(origin)][str(destination)]
    f_path.close()
    return path
    

def get_path_time_hour(origin, destination, hour):
    """Return the minimal hours needed for a vehicle to travel from
    origin to destinition at hour."""

    current_directory = os.getcwd()
    parent = os.path.dirname(current_directory)
    ue_directory = parent + '\\user_equilibrium\\'

    # Opening JSON file
    f_time = open(ue_directory+'path_time_hour.json')
    
    # returns JSON object as a dictionary
    time = json.load(f_time)

    # return the hourly travel time
    time_hour = json.loads(time[str(hour)])

    # Find the O-D pair
    path_time = time_hour[str(origin)][str(destination)]
    f_time.close()

    # Round time to integer hour
    return np.ceil(path_time/60)

def get_node_xy(node):
        """Return the (x,y) tuple as the position of node in figure."""

        node_x = node_xy['X'][node-1]
        node_y = node_xy['Y'][node-1]
        x = np.round(node_x/10000*17.33+105.4)
        y = np.round(-node_y/10000*16.63+970.2)
        #x ,y = 833, 438
        return (x,y)

def get_distance(current_node, next_node):
        """Return the distance between the current node and 
        next node in figure."""
        current_xy = get_node_xy(current_node)
        next_xy = get_node_xy(next_node)

        delta_x = next_xy[0] - current_xy[0]
        delta_y = next_xy[1] - current_xy[1]
        return (delta_x, delta_y)
    
    

class Sess():
    """Define the static ESS class."""

    def __init__(self, capacity, rate, efficiency) :
        """Initialize attributes of the SESS."""

        self.c_max = capacity
        self.q_max = rate
        self.gamma_e = efficiency
        self.soc = 0

    def charge(self, q):
        """Change the SOC by charging or discharging."""

        pre_soc = self.soc
        if q >= 0:
            # Check charging/discharging rate limit
            q = min(q, self.q_max)
            self.soc += self.gamma_e*q
        else:
            q = max(q, -self.q_max)
            self.soc += q/self.gamma_e

        # Check capacity
        violate = self.soc < 0 or self.soc > self.c_max
        self.soc = max(0, self.soc)
        self.soc = min(self.soc, self.c_max)
        q_real = self.soc - pre_soc

        return q_real, violate
    
    def get_soc(self):
        """Return the SOC."""

        return self.soc/self.c_max

class Mec(Sess):
    """Inheritance from SESS."""

    def __init__(self, capacity, rate, efficiency, location, hour):
        super().__init__(capacity, rate, efficiency)
        # Start from one of the renewable bus
        self.set_location(location)
        self.move_to_bus(location)
        self.time_left = 0
        self.hour = hour

    def set_location(self, bus):
        """Set the location of Mec in the power system"""
        self.location = bus
        self.current_node = bus_to_node[bus-1]
    def set_node(self, node):
        self.current_node = node
        
    def get_location(self):
        """Get the location of Mec in the power system"""
        return self.location

    def move_to_bus(self, bus):
        self.destination = bus
        self.next_node = bus_to_node[bus-1]
        self.destination_node = bus_to_node[bus-1]

    def move_to_node(self, node):
        """Move the Mec in the transportation network
        on a link."""

        self.next_node = node

    def node_on_path(self):
        """Return the list of nodes that the vehicle will pass
        to travel from the location to the destinition."""
        return get_path_hour(self.current_node, self.destination_node, self.hour)
    
    def time_on_path(self):
        """Return the number of hours that the vehicle will pass
        to travel from the location to the destinition."""
        return get_path_time_hour(self.current_node, self.destination_node, self.hour)

    def get_destination(self):
        return self.destination

    def time_to_bus(self, time):
        self.time_left = time
    
    def get_time_left(self):
        return self.time_left
    
    def get_info(self):
        info = {'location':self.location,
                'destination': self.destination,
                'time_left': self.time_left}
        return info

    """Unused function"""
    def get_speed_path(self):
        """Return the speed list of mec moving on each link in figure"""

        path = self.node_on_path()
        time = self.time_on_path()
        timeslot = time/(len(path)-1)
        speed_x, speed_y = [], []
        for idx in range(len(path)-1):
            delta_x = get_distance(path[idx],path[idx+1])[0]
            delta_y = get_distance(path[idx],path[idx+1])[1]
            speed_x.append(delta_x/timeslot)
            speed_y.append(delta_y/timeslot)

        return speed_x, speed_y
    

    def get_direction(self):
        """Get the direction of the Mec"""

        delta_x = get_distance(self.current_node,self.next_node)[0]
        delta_y = get_distance(self.current_node,self.next_node)[1]

        if np.abs(delta_x) >= np.abs(delta_y):
            # Horizontal move
            if delta_x >= 0:
                direction = 0 # right
            else:
                direction = 2 # left
        else: # Vertical move
            if delta_y > 0:
                direction = 1 # down
            else:
                direction = 3 # up
        return direction

    






