# build_sensor_data.R
# script to build sensor data files
# houseID_moteID_{A|B}.RData
#   time
#   flow
#   temp

# Jim Lutz "Wed Dec 13 17:52:57 2017"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# call useful functions
source("functions.R")

# load the DT_sensorID data.table
load(file = paste0(wd_data,"DT_sensorID.RData"))

