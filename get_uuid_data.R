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
  # Error: with piece 37: 
  #   [1] "/home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_sensorID/RSmap.x324b.raw.xz.RData"

DT_uuids_data <- get_DT_moteID_data("/home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_sensorID/RSmap.x324b.raw.xz.RData")
  # Error: with piece 1: 
  #   $uuid
  # [1] "636775bf-f199-545d-a6cf-269697171e04" 

# problem with this file
load(file = "/home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_sensorID/RSmap.x324b.raw.xz.RData")
data
str(data)
# RSmap.x324b.raw.xz.RData is only 348 bytes. 
# looks like it only has uuids, no data.

# there's some other small files
# this one is only 1.4K
load(file = "/home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_sensorID/RSmap.x3440.raw.xz.RData")
data
str(data)
# it does have data though.

load(file = "/home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_sensorID/RSmap.x3220.raw.xz.RData")
data
str(data)
# it does have data though.

# so does RSmap.x356c.raw.xz.RData
# see what we got
DT_uuids_data[,list(nrows=length(time)),by=uuid]

# apparently only file w/o data is:
# RSmap.x324b.raw.xz.RData
# some of the others only have one record.
# delete that file
