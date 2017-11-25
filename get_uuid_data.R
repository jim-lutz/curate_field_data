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

# try one moteID
fn_moteID <- fn_motes[211]

get_DT_uuids_data <- function(fn_moteID){
  # function to read all the data from all Rsmap data structures in a file

  # load the list of data lists into data
  load(file = fn_moteID)
  str(data)
  
  # call get_DT_uuids_data on every data list in the list
  ldply(.data=data, .fun =get_DT_uuid_data(), .progress= "text")
    
  # return the data as a data.table with uuid as a field
  # not very efficient but puts everything in one record
  return(data.table( uuid = l_data$uuid, time = l_data$time, value = l_data$value))
}


