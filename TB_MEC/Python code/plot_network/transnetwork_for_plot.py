"""This python file builds a transportation network class for siouxfalls plot
By Yaze Li, University of Arkansas 05/15/2023"""
import networkx as nx
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.lines as mlines
from networkx import DiGraph
import seaborn as sns

class Transnetwork(DiGraph):
    """Define a class for transportation network based on directed graph
    class in networkx."""
    def __init__(self, incoming_graph_data=None, **attr):
        """Initialize attributes of the parent class"""
        super().__init__(incoming_graph_data, **attr)
        self.od_demand = []
        self.bus_list = []

    def add_demands(self, origin, destination, demand):
        """Add O-D demand as an attribute of the transportation network class."""
        od = (origin, destination, {'demand': demand})
        self.od_demand.append(od)

    def get_node_pos(self):
        """Return a dictionary with nodes as keys and positions as values.
        Position is a list of length 2."""
        return nx.get_node_attributes(self,'position')
    
    def vertical_to_horizontal(self):
        """Return a dictionary with nodes as keys and positions as values.
        Position is horizontal."""

        pos_vert = self.get_node_pos()
        pos_hori = {}
        for node,pos in pos_vert.items():
            pos_hori[node]=[540000-pos[1],0.8*pos[0]]
        return pos_hori

    def draw_transnetwork_nodes(self, node_color='yellow', node_border_color='black', node_list=[]):
        """Draw the nodes in nodelist with labels."""
        pos = self.get_node_pos()
        if node_list:
            nodelist = node_list
        else:
            nodelist = list(self)
        
        # Draw nodes
        nx.draw_networkx_nodes(self, pos = pos,
                         nodelist = nodelist,
                         node_color = node_color,
                         edgecolors = node_border_color,
                        )
        
        # Draw node labels
        nx.draw_networkx_labels(self, pos = pos)

    def draw_transnetwork_edges(self, edge_list=[]):
        """Draw the edges in edgelist with labels."""
        pos = self.get_node_pos()
        if edge_list:
            edgelist = edge_list
        else:
            edgelist = self.edges

        # Draw edges
        nx.draw_networkx_edges(self, pos, edgelist,
                               arrowsize=20,
                               node_size=800,
                               connectionstyle='arc3,rad=0.08',
                               )

        # Set label parameters for two directions
        bbox = dict(boxstyle='round,pad=0.01',
                    ec=(1.0, 1.0, 1.0),
                    fc=(1.0, 1.0, 1.0))
        edge_labels = nx.get_edge_attributes(self, 'index')
        edge_idx = [1,2,4,6,7,9,10,12,13,16,18,20,22,24,25,28,29,30,32,34,36,
                    37,39,41,42,45,46,49,50,53,56,59,64,68,69,72,73,75]
        edge_labels_1, edge_labels_2 ={}, {}
        for key, value in edge_labels.items():
            if value in edge_idx:
                edge_labels_1[key] = value
            else:
                edge_labels_2[key] = value

        # Draw edge labels
        nx.draw_networkx_edge_labels(self, pos,
                                    edge_labels=edge_labels_1,
                                    label_pos = 0.3,
                                    horizontalalignment='right',
                                    verticalalignment='top',
                                    bbox=bbox,
                                    )
        nx.draw_networkx_edge_labels(self, pos,
                                    edge_labels=edge_labels_2,
                                    label_pos = 0.4,
                                    horizontalalignment='left',
                                    verticalalignment='bottom',
                                    bbox=bbox,
                                    )
    
    def get_buses(self):
        """Return a list of nodes which are also buses."""
        for node in list(self):
            try:
                nx.get_node_attributes(self,'bus_idx')[node]
                self.bus_list.append(node)
            except: KeyError


    def draw_transnetwork_buses(self):
        """Draw the buses in IEEE-14bus system in the transnetwork."""
        self.get_buses()
        pos = self.get_node_pos()

        # Draw buses
        for bus in self.bus_list:
            if nx.get_node_attributes(self,'load_type')[bus] == 'I':
                node_color = 'tab:green'
            elif nx.get_node_attributes(self,'load_type')[bus] == 'R':
                node_color = 'tab:blue'
            elif nx.get_node_attributes(self,'load_type')[bus] == 'C':
                node_color = 'tab:orange'
            else:
                node_color = 'yellow'
            nx.draw_networkx_nodes(self, pos = pos, node_color=node_color, edgecolors = 'black', nodelist = [bus])

        # Draw bus labels
        labels = {bus:nx.get_node_attributes(self,'bus_idx')[bus] for bus in self.bus_list}
        nx.draw_networkx_labels(self, pos = pos, labels = labels)

    def draw_transnetwork_buses_bw(self):
        """Draw the buses in IEEE-14bus system in the transnetwork in black and white."""

        self.get_buses()
        #pos = self.get_node_pos()
        pos = self.vertical_to_horizontal()

        # Draw buses
        for bus in self.bus_list:
            if nx.get_node_attributes(self,'load_type')[bus] == 'I':
                node_color = 'tab:green'
                node_shape = 's'
                node_size = 700
            elif nx.get_node_attributes(self,'load_type')[bus] == 'R':
                node_color = 'tab:blue'
                node_shape = 'D'
                node_size = 600
            elif nx.get_node_attributes(self,'load_type')[bus] == 'C':
                node_color = 'tab:orange'
                node_shape = 'H'
                node_size = 900
            else:
                node_color = 'yellow'
                node_shape = 'o'
                node_size = 800
            nx.draw_networkx_nodes(self, pos = pos, node_size = node_size, node_color=node_color, node_shape=node_shape, edgecolors = 'black', nodelist = [bus])

        # Draw node labels
        nx.draw_networkx_labels(self, pos = pos, font_size = 14)

        # Draw bus labels
        bus_pos = {}
        for node, node_pos in pos.items():
            bus_pos[node]=[node_pos[0]-15000,node_pos[1]-15000]

        labels = {bus:nx.get_node_attributes(self,'bus_idx')[bus] for bus in self.bus_list}
        nx.draw_networkx_labels(self, pos = bus_pos, font_size = 14, font_weight='bold', labels = labels)

    def draw_transnetwork(self, width, height, title=[], fontsize=20, node_color='yellow', node_border_color='black'):
        """Draw the transportation network."""

        fig, ax = plt.subplots()
        fig.set_figwidth(width)
        fig.set_figheight(height)
        plt.style.use('tableau-colorblind10')
        ax.axis('off')
        if title:
            ax.set_title(title,fontsize=fontsize)

        self.draw_transnetwork_nodes(node_color, node_border_color)
        self.draw_transnetwork_edges()
        
        plt.show()
        return fig

    def draw_bus_in_transnetwork(self, width, height, title=[], fontsize=20, node_color='yellow', node_border_color='black'):
        """Draw the buses along with the transportation network."""

        fig, ax = plt.subplots()
        fig.set_figwidth(width)
        fig.set_figheight(height)
        plt.style.use('tableau-colorblind10')
        ax.axis('off')
        if title:
            ax.set_title(title,fontsize=fontsize)
        
        pos = self.get_node_pos()
        nx.draw_networkx_nodes(self, pos = pos,
                         nodelist = self.nodes,
                         node_color = 'yellow',
                         edgecolors = 'black',
                        )
        self.draw_transnetwork_buses()
        nx.draw_networkx_edges(self, pos = pos, edgelist = self.edges,
                               arrowsize=10,
                               connectionstyle='arc3,rad=0.08',
                               )
        # Creating legend with color box
        r = mpatches.Patch(color='tab:blue', label='Residential Load')
        i = mpatches.Patch(color='tab:green', label='Industrial Load')
        c = mpatches.Patch(color='tab:orange', label='Commercial Load')
        n = mpatches.Patch(color='yellow', label='No Load')
        plt.legend(handles=[n,r,c,i])
        plt.show()
        return fig
    
    def draw_bus_in_transnetwork_bw(self, width, height, title=[], fontsize=20, node_color='white', node_border_color='black'):
        """Draw the buses along with the transportation network in black and white."""

        fig, ax = plt.subplots()
        fig.set_figwidth(width)
        fig.set_figheight(height)
        plt.style.use('tableau-colorblind10')
        ax.axis('off')
        if title:
            ax.set_title(title,fontsize=fontsize)
        
        #pos = self.get_node_pos()
        pos = self.vertical_to_horizontal()
        nx.draw_networkx_nodes(self, pos = pos,
                         nodelist = [3,4,6,7,9,11,17,15,23,21],
                         node_size = 800,
                         node_color = 'yellow',
                         edgecolors = 'black',
                        )

        self.draw_transnetwork_buses_bw()
        nx.draw_networkx_edges(self, pos = pos, edgelist = self.edges,
                               arrowsize = 10,
                               node_size = 800,
                               connectionstyle='arc3,rad=0.08',
                               )
        # Creating legend with color box
        r = mlines.Line2D([], [], markeredgecolor='black', markerfacecolor='tab:blue', linestyle='None', marker='D', markersize=10, label='Residential Load')
        i = mlines.Line2D([], [], markeredgecolor='black', markerfacecolor='tab:green', linestyle='None', marker='s', markersize=12, label='Industrial Load')
        c = mlines.Line2D([], [], markeredgecolor='black', markerfacecolor='tab:orange', linestyle='None', marker='H', markersize=15, label='Commercial Load')
        n = mlines.Line2D([], [], markeredgecolor='black', markerfacecolor='yellow', linestyle='None', marker='o', markersize=12, label='No Load')
        plt.legend(handles=[n,r,c,i],fontsize="14",loc='best')
        plt.show()
        return fig