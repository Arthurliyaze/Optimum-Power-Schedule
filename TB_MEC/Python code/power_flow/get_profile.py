"""This file reads the wind and pv profile, the residential,
commerial, and industrial load profile from the csv.
Functions are also defined to plot the profiles.
By Yaze Li, University of Arkansas. 05/23/2023"""

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

current_directory = os.getcwd()
parent = os.path.dirname(current_directory)
data_directory = parent + '\\data\\'

# number of buses with renewable and loads
n_ren, n_res, n_com, n_ind = [4, 7, 2, 1]

def get_wind_profile():
    """Return the wind profile."""

    # Read wind data from csv file
    headers=['time','speed']
    wind_data = pd.read_csv(data_directory+'SUX.csv',
                            header=0,
                            names=headers,
                            usecols=range(1,3),
                            parse_dates=['time'],
                            index_col='time',
                            )
    # Replace 'M' with the value of the nearest one above it.
    wind_data.replace(to_replace='M',method='ffill', inplace=True)

    # Check the number of missing value.
    (wind_data['speed'].eq('M')).sum()

    # Convert the 'speed' column to float.
    wind_data['speed'] = pd.to_numeric(wind_data['speed'])

    # Drop duplicated rows.
    #wind_data.drop_duplicates(subset=['time'])
    #print(wind_data)

    # Check the missing timesteps.
    ref_date_hour_range = pd.date_range('2020-01-01 00:00:00','2020-12-30 23:55:00',freq='5Min')
    ref_df = pd.DataFrame(np.full([ref_date_hour_range.shape[0],1],np.nan))
    ref_df.index = ref_date_hour_range
    #missing_hours = ref_df.index[~ref_df.index.isin(wind_data.index)]

    # Fill the missing timesteps.
    wind_data = ref_df.join(wind_data,how='left').fillna(method='ffill')
    del wind_data[0]

    # Find the duplicated row index and remove the row.
    wind_data = wind_data[~wind_data.index.duplicated(keep='first')]

    # Calculate the mean wind speed of each hour
    wind_speed = wind_data.groupby([wind_data.index.date, wind_data.index.hour])[['speed']].mean()
    wind_speed = wind_speed.reset_index(level=[0,1])

    # Change unit from mph to m/s
    wind_speed['speed'] = wind_speed['speed']*0.44704

    area = 8495 # Sweep area
    rho = 1.23 # air density
    cp = 0.4 # power coefficient
    single_turbine = wind_speed['speed']

    single_turbine = 1/2*rho*area*single_turbine**3*cp/1e6 # W to MW (1MW base)
    single_turbine.name = 'wind'

    n_turbine = 1; # 1 is used to scale wind farm to 1 MW
    wind_profile = single_turbine * n_turbine
    return wind_profile

def get_pv_profile():
    """Return the pv profile."""

    # Read PV data from csv file
    pv_data = pd.read_csv(data_directory+'pvwatts_hourly.csv',
                                skiprows=range(17),
                                usecols=[0,1,2,10],
                                )
    single_pv = pv_data.iloc[:-1,-1]/1e6 # W to MW
    single_pv.name = 'pv'
    n_pv = 1   # 1 is used to scale pv power up to around 0.5 MW
    pv_profile = n_pv*single_pv
    #pv_profile.isnull().values.any()
    return pv_profile

def get_residential_profile():
    """Return the residential load profile."""

    # Read residential load from csv file
    res_data = pd.read_csv(data_directory+'USA_SD_Sioux.Falls.726510_TMY2.csv',usecols=[13])
    #res_data.isnull().values.any()
    n_house = 1
    res_profile = n_house*res_data.iloc[:,-1]
    res_profile.name = 'residential'
    return res_profile

def get_commercial_profile():
    """Return the commercial load profile."""

    # Read commercial load from multiple csv files in the folder.
    com_path = data_directory+'\\USA_SD_Sioux.Falls-Foss.Field.726510_TMY3\\'
    com_files = os.listdir(com_path)

    # Sum load in each file
    com_dfs = [pd.read_csv(com_path+com_file,usecols=range(1,11)).sum(axis=1) for com_file in com_files]
    # Sum loads in all files
    com_data = pd.concat(com_dfs,axis=1).sum(axis=1)

    # kW to MW for single commer
    com_profile = com_data/1e3/8
    com_profile.name = 'commercial'
    return com_profile

def get_industrial_profile():
    """Return the industrial load profile."""

    # Read industrial load from csv file.
    ind_data = pd.read_csv(data_directory+'LoadProfile_30IPs_2017.csv',
                            sep=';',
                            header=1,
                            index_col=0,
                            parse_dates=True,
                            #date_parser=dateparse,
                            dayfirst=True,
                        )
    ind_data.index = pd.to_datetime(ind_data.index, format='%d.%m.%Y %H:%M:%S').strftime('%Y-%m-%d %H:%M:%S')
    ind_data.index = pd.DatetimeIndex(ind_data.index)
    ind_data = ind_data.fillna(method='ffill')
    ind_data = ind_data.sum(axis=1)
    #print(len(ind_data.index))

    # Check duplicated time stamps.
    ref_quarter_range = pd.date_range('2017-01-01 00:15:00','2018-01-01 00:00:00',freq='15Min')
    ref_df = pd.DataFrame(np.full([ref_quarter_range.shape[0],1],np.nan))
    ref_df.index = ref_quarter_range

    dup_index = [index for index in range(len(ref_df.index)) if ind_data.index[index]!=ref_df.index[index]]
    #print(dup_index[0])

    ind_data = ind_data[~ind_data.index.duplicated(keep='first')]
    #print((ind_data))

    # Calculate the mean industrial load of each hour
    ind_data = ind_data.groupby([ind_data.index.date, ind_data.index.hour]).mean()[:-1]

    # Change unit from kW to MW
    ind_profile = ind_data.reset_index(level=[0,1])[0]/1e3*5
    ind_profile.name = 'industrial'
    return ind_profile

def get_day_index(profile, month, date):
    """Return the hourly datetime indexed profile on the given day,
    and the date of the day."""

    # Create 2021 datetime for index
    full_year_range = pd.date_range('2021-01-01 00:00:00','2021-12-31 23:00:00',freq='60Min')
    profile.index = full_year_range

    hour_start = pd.to_datetime(str(2021)+str(month)+str(date),format='%Y%m%d')
    hour_end = hour_start + pd.Timedelta(24,unit='h')
    hour_index = (profile.index >= hour_start) & (profile.index < hour_end)
    profile = profile.loc[hour_index]

    date_start = hour_start.date()
    profile.index = profile.index.hour+1

    return (profile,date_start)   
    
def plot_single_day_profile(profile_name, month, date):
    """Plot the single profile (string) on the chosen day.
    The profilename should be 'wind', 'pv', 'residential', 'commerical', or 'industrial'."""

    try:
        # Get profile data
        profile = eval(f"get_{profile_name}_profile()")

        profile, date_start = get_day_index(profile, month, date)
        title = f"The {profile_name} profile on {str(date_start)}"
        
        fig, ax = plt.subplots()
        profile.plot.bar()
        ax.set_axisbelow(True)
        ax.grid(color='gray', linestyle='dashed', axis='y')
        ax.set_xlabel('Hour')
        ax.set_ylabel('Power (MW)')
    except Exception as e: print(e)

    return fig, title

def plot_day_renewable(month,date):
    """Plot the renewable energy profile on the chosen day."""

    wind, date_start = get_day_index(get_wind_profile(), month, date)
    pv = get_day_index(get_pv_profile(), month, date)[0]

    renew = pd.concat([wind, pv], axis=1)
    renew = renew * n_ren
    renew = renew.rename(columns={'wind': 'Wind', 'pv': 'PV'})
    title = f"The renewable energy profile on {str(date_start)}"
    
    fig, ax = plt.subplots()
    renew.plot.bar(ax=ax, stacked=True)
    bars = ax.patches
    hatches = ''.join(h*len(renew) for h in '/ ')
    for bar, hatch in zip(bars, hatches):
        bar.set_hatch(hatch)
    ax.set_axisbelow(True)
    ax.grid(color='gray', linestyle='dashed', axis='y')
    ax.set_xlabel('Hour')
    ax.set_ylabel('Power (MW)')
    ax.legend(loc='upper right')
    return fig, title

def plot_day_load(month,date):
    """Plot the load profile on the chosen day."""

    res, date_start = get_day_index(get_residential_profile(), month, date)
    com = get_day_index(get_commercial_profile(), month, date)[0]
    ind = get_day_index(get_industrial_profile(), month, date)[0]

    res = res*n_res
    com = com*n_com
    ind = ind*n_ind
    
    load = pd.concat([res, com, ind], axis=1)
    load = load.rename(columns={'residential': 'Residential', 'commercial': 'Commercial', 'industrial': 'Industrial'}) 
    title = f"The load profile on {str(date_start)}"
    
    fig, ax = plt.subplots()
    load.plot(ax=ax, kind='bar', stacked=True, color=['tab:blue','tab:orange','tab:green'], ylim=[0,13])
    bars = ax.patches
    hatches = ''.join(h*len(load) for h in '/ \\')
    for bar, hatch in zip(bars, hatches):
        bar.set_hatch(hatch)
    ax.set_axisbelow(True)
    ax.grid(color='gray', linestyle='dashed', axis='y')
    ax.set_xlabel('Hour')
    ax.set_ylabel('Power (MW)')
    ax.legend(loc='upper right')
    return fig, title