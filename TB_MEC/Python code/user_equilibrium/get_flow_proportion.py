"""This file extracts the proportion of the trip demands
in each hour.
By Yaze Li, University of Arkansas. 05/26/2023"""

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

current_directory = os.getcwd()
parent = os.path.dirname(current_directory)
data_directory = parent + '\\data\\'
figure_path = parent+"\\figure\\"

def get_proportion():
    """Return the proportion of the demands"""

    # Read link data from csv files
    demand_data = pd.read_csv(
        data_directory+'TYPICAL_HOURLY_VOLUME_DATA.csv',
        usecols=range(7,31),
        )
    hour_mean = demand_data.mean()
    proportion = hour_mean/hour_mean.sum()
    hour_list = [hour+1 for hour in range(24)]
    proportion = proportion.set_axis(hour_list)
    
    return proportion

def plot_proportion():
    """Plot the daily demand proportion."""

    proportion = get_proportion()*100
    #print(proportion)
    title = 'Typical daily traffic demand proportion'

    fig, ax = plt.subplots()
    proportion.plot.bar(ax=ax)
    ax.set_axisbelow(True)
    ax.grid(color='gray', linestyle='dashed', axis='y')
    ax.set_xlabel('Hour')
    ax.set_ylabel('Proportion (%)')

    return fig, title

#fig, title = plot_proportion()
#fig.savefig(figure_path+title+'.svg',format='svg')