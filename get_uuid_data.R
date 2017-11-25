# get_uuid_data.R
# script to collect all the uuid information in
# /home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_sensorID
# makes one huge long data.table of uuid, time, value
# Jim Lutz "Sat Nov 25 13:06:14 2017"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# call useful functions
source("functions.R")

# path to mote files
wd_mote_data = "/home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_sensorID/"

# get the moteID files.
fn_motes <- Sys.glob(paste0(wd_mote_data,"RSmap.x*.RData"))

# get data from all the moteIDs
DT_uuids_data <- get_DT_uuids_data(fn_motes)

# see what we got
DT_uuids_data[,list(nrows=length(time)),by=uuid]
