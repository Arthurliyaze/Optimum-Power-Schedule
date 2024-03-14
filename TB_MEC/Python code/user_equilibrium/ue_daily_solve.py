"""This file calculates the ue traffic flow solution 
for a whole day based on a typical hourly demand sequentially.
By Yaze Li, University of Arkansas. 05/26/2023."""
from traffic_flow import TrafficFlowModel
from get_flow_proportion import *
import get_data as dt
#import get_test_data as dt
import os

current_directory = os.getcwd()
parent = os.path.dirname(current_directory)
figure_path = parent+"\\figure\\"
# Plot for daily demand proportion
#fig, title = plot_proportion()

#fig.savefig(figure_path+title+'.svg',format='svg')

proportion = get_proportion()
hour_demand = [[dt.demand[pair]/0.05*proportion[hour].astype(float) for pair in range(len(dt.demand))] for hour in range(len(proportion))]

def ue_hour_solve(hour_demand, cov_accuracy= 1e-2, disp_precision= 2):
    """Return the daily ue solution, nested list with 24 lists each 
    contains the link time."""

    link_time_hour = []
    for hour in range(24):
        print(f"\nSolve UE for hour: {hour}")
        mod = TrafficFlowModel(dt.graph, dt.origins, dt.destinations,
                                hour_demand[hour], dt.free_time, dt.capacity)
        mod._conv_accuracy = cov_accuracy
        mod.set_disp_precision(disp_precision)
        mod.__detail = False
        mod.solve()
        link_time = mod._formatted_solution()[1]
        link_time_hour.append(link_time)
        print('Solved!')

    print('UE solved for all 24 hours.')
    return link_time_hour

def write_time_matrix(filename,nest_list):
    """Write the time matrix to txt file"""

    with open(filename,'w') as file:
        for item in nest_list:
            file.write(f"{' '.join(list(map(str,item)))}\n")

    file.close()

time_matrix = ue_hour_solve(hour_demand)
filename = 'link_time_hour.txt'
write_time_matrix(filename,time_matrix)