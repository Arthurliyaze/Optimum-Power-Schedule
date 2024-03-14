"""This file plots the learning curve of DDPG agent.
By Yaze Li, University of Arkansas. 06/19/2023"""

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

current_directory = os.getcwd()
parent = os.path.dirname(current_directory)
figure_directory = parent + '\\figure\\'

# Read mean of episode rewards from multiple csv files in the folder.
path = current_directory+'\\learning\\'
files = os.listdir(path)

# Get dataframe in each file
dfs = [pd.read_csv(path+file,usecols=range(1,3),index_col=0) for file in files]
# Connect dataframes in all files
data = pd.concat(dfs,axis=0)

# Get Exponential Moving Averages
ema = data.ewm(alpha=0.4).mean()

fig, ax = plt.subplots()
title = 'ddpg_training_curve'
g = data.plot(ax=ax, grid=True, legend=False,
          xlabel="Step",
          ylabel="Episode reward mean",
          color='lightsteelblue',
          )
plt.plot(ema, color='royalblue')
xlabels = ['{:,.0f}'.format(x) + 'k' for x in g.get_xticks()/1000]
g.set_xticklabels(xlabels)

fig.savefig(figure_directory+title+'.svg')