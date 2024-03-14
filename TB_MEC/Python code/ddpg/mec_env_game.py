"""This file creates a basic game that simulates the Mec movement 
in the Sioux Falls Network
By Yaze Li, University of Arkansas. 06/07/2023"""

import pygame

import os
import sys
#import numpy as np
#import pandas as pd
#from mec_visual_env import MecVisualEnv

current_directory = os.getcwd()
parent = os.path.dirname(current_directory)
ddpg_directory = parent + '\\ddpg'
sys.path.insert(0,ddpg_directory)

from ess import *

# parameters
c_max = 10
q_max = 9
gamma_e = 0.94
b = 4
bus_renew = [2,5,7,10]

directionNumbers = {0:'right', 1:'down', 2:'left', 3:'up'}

# pygame setup
pygame.init()
screen = pygame.display.set_mode((1000,1000))
clock = pygame.time.Clock()



# changing title of the game window
pygame.display.set_caption('Mec Movement Simulation')

# create a font object.
# 1st parameter is the font file
# which is present in pygame.
# 2nd parameter is size of the font
font = pygame.font.Font('freesansbold.ttf', 32)
black = (0,0,0)
white = (255,255,255)


# setting background image
surface = pygame.image.load('images/Buses in the SiouxFalls Network.png')

# setting the mec
#mec = Mec(c_max,q_max,gamma_e,2)
node = 15
hour = 1

# Create the Mec object
mec = Mec(c_max,q_max,gamma_e,bus_renew[0],hour)
#direction = mec.get_direction()
#direction = 0
#mec_logo = pygame.image.load(f'images/mec_{directionNumbers[direction]}.png')
bus = mec.get_location()
#node = bus_to_node[bus-1]

def move_to_bus_figure(mec, bus, screen, clock):
        """Move the mec to the bus in figure"""

        mec.move_to_bus(bus)
        node_list = mec.node_on_path()

        # create a text surface object, on which text is drawn on it.
        text = font.render(f'From Bus {mec.get_location()} to Bus {bus}', True, black, white)

        screen.blit(text,(30,30))
        
        for idx in range(len(node_list)-1):
            mec.move_to_node(node_list[idx+1])
            mec_xy = get_node_xy(mec.current_node)
            direction = mec.get_direction()
            mec_logo = pygame.image.load(f'images/mec_{directionNumbers[direction]}.png')
            
            # Get distance
            #delta_x, delta_y = get_distance(mec.current_node, mec.next_node)

            # Display the Mec
            if direction in [0,2]:
                x = mec_xy[0] - length/2
                y = mec_xy[1] - width/2
            else:
                x = mec_xy[0] - width/2
                y = mec_xy[1] - length/2

            

            screen.blit(mec_logo,(x,y))
            pygame.display.update()
            clock.tick(1.5)



            # Move to node by updating node info
            mec.set_node(node_list[idx+1])

             
        pygame.display.update()

"""
running = True

while running:
    # Poll for events
    for event in pygame.event.get():
        # pygame.QUIT event means the user clicked X to close your window
        if event.type == pygame.QUIT:
            running = False

    #displaying the background image
    screen.blit(surface,(0,-100))

    # Initial location as bus
    mec.set_location(bus)
    

    # Assign new destination
    bus = np.random.randint(14)+1
    move_to_bus_figure(mec, bus, screen, clock)
pygame.quit()
"""