"""This file plots the profiles.
By Yaze Li, University of Arkansas. 05/25/2023"""

import os
import matplotlib as plt
from get_profile import *


current_directory = os.getcwd()
parent = os.path.dirname(current_directory)
figure_path = parent+"\\figure\\"

# Plot for single profile on a chosen day.
# Choose a day
month = 7
date = 1
profiles = ['wind','pv','residential','commercial','industrial']
"""
for profile in profiles:
    fig, title = eval(f"plot_single_day_profile('{profile}',month,date)")
    fig.savefig(figure_path+title+'.svg',format='svg')
"""
# Plot for renewable on a chosen day
fig, title = plot_day_renewable(month,date)
fig.savefig(figure_path+title+'.svg',format='svg')

# Plot for load on a chosen day
fig, title = plot_day_load(month,date)
fig.savefig(figure_path+title+'.svg',format='svg')