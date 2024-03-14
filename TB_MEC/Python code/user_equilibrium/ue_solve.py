"""This file calculates the ue traffic flow solution
By Yaze Li, University of Arkansas. 05/23/2023"""
from traffic_flow import TrafficFlowModel
#import get_data as dt
import get_test_data as dt

# Initialize the model by data
mod = TrafficFlowModel(dt.graph, dt.origins, dt.destinations, 
dt.demand, dt.free_time, dt.capacity)

# Change the accuracy of solution if necessary
mod._conv_accuracy = 1e-2

# Display all the numerical details of
# each variable during the iteritions
mod.disp_detail()

# Set the precision of display, which influences
# only the digit of numerical component in arrays
mod.set_disp_precision(2)

# Solve the model by Frank-Wolfe Algorithm
mod.solve()

# Generate report to console
#mod.report()

# Return the solution if necessary
solution = mod._formatted_solution()
link_flow = solution[0]
link_time = solution[1]

# Save result to txt
file = open('ue_test_result.txt','w')
file.write(f"link flow:\n{link_flow}\nlink time:\n{link_time}")
file.close()