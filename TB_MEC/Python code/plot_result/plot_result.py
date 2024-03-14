"""This file plots the one day result for the ddpg agent"""

import numpy as np
import matplotlib.pyplot as plt
import os

current_directory = os.getcwd()
parent = os.path.dirname(current_directory)
figure_directory = parent + '\\figure\\'
result = np.loadtxt('result.txt')

loc = result[0:4,:]
soc = result[4:,:]
hour = np.arange(1,25)

fig, axs = plt.subplots(4, sharex=True, sharey=True)
title = 'MEC schedules and behaviors'

for b in range(4):
    
    axs[b].set_label
    axs[b].set_xlim(0.5,24.5)
    axs[b].set_yticks([0,50,100])
    axs[b].set_yticklabels(axs[b].get_yticks(), rotation = 90)

    # Instantiate a second axes that shares the same x-axis
    ax2 = axs[b].twinx()  
    ax2.set_ylim(0,15)
    ax2.set_yticks([0,5,10,15])

    axs[b].bar(hour, soc[b,:], color='gray', alpha=0.8)
    
    ax2.plot(hour, loc[b,:], marker="*")
    ax2.set_xticks(range(1,25))
    
    ax2.set_axisbelow(True)
    ax2.grid(True)
    #ax2.legend([f"MEC {b+1}"],bbox_to_anchor=(0.02, 0.5))
    ax2.text(-1.8, 7, f'MEC {b+1}', va='center', rotation='vertical')


fig.text(0.5, 0.00, 'Hour', ha='center')
fig.text(0.98, 0.5, 'MEC location (bus ID)', va='center', rotation='vertical')
fig.text(0.00, 0.5, 'MEC SOC (%)', va='center', rotation='vertical')

fig.savefig(figure_directory+title+'.svg')