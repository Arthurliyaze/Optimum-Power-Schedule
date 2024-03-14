"""This file gets the data of siouxfalls network by pandas,
and plot the OD demands.
By Yaze Li, University of Arkansas. 05/21/2023"""

import os
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

current_directory = os.getcwd()
parent = os.path.dirname(current_directory)
data_directory = parent + '\\data\\'

# Read link data from csv files
link_data = pd.read_csv(data_directory+'SiouxFalls_net.txt', sep='	', usecols=range(1,5))
link_data.columns = ['init_node', 'term_node', 'capacity', 'free_flow_time']
link_data = link_data.astype({'init_node':'int','term_node':'int'})
#print(link_data)

# Graph represented by directed dictionary
# In order: first ("1", "2"), second ("1", "3"), third ("2", "1")...
init_nodes = list(map(str,list(range(1,25))))
graph_dic = {key: [] for key in init_nodes}
capacity, free_time = [], []

def find_term(row):
    """Add terminal nodes to the value of the dictionary whose key is the initial nodes."""
    graph_dic[str(int(row['init_node']))].append(str(int(row['term_node'])))
    capacity.append(row['capacity'])
    free_time.append(row['free_flow_time'])

link_data.apply(find_term,axis='columns')
graph = [(k,v) for k,v in graph_dic.items()]

#% Read OD pairs from csv files
demand_data = pd.read_csv(data_directory+'SiouxFalls_od.csv')

def plot_demand(demand_data):
    """Plot a heatmap for the OD demands."""
    pivot = demand_data.pivot(index='O',columns='D',values='Ton')
    fig, ax = plt.subplots()
    sns.heatmap(pivot, cmap='Blues', vmin=0, vmax=4500)
    plt.xlabel("Origin nodes") 
    plt.ylabel("Destination nodes") 
    plt.show()
    return fig

# Generate ordered OD pairs and demands
origins = list(map(str,list(range(1,25))))
destinations = list(map(str,list(range(1,25))))
demand_matrix = np.zeros((24,24))

def add_pair(row):
    """Add orgins and destinations with order and store the demand."""
    demand_matrix[int(row['O'])-1,int(row['D'])-1] = row['Ton']

demand_data.apply(add_pair,axis='columns')

demand = [demand_matrix[i,j] for i in range(24) for j in range(24)]

# Plot the heat map of the OD demands.
#fig = plot_demand(demand_data)
#figure_path = parent + '\\figure\\'
#title = 'Sioux Falls OD demands'
#fig.savefig(figure_path+title+'.svg',format='svg')