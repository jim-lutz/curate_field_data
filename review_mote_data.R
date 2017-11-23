# review_mote_data.R
# script to review information in the mote files in
# /home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_sensorID
# Jim Lutz "Thu Nov 23 11:37:13 2017"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# path to mote files
wd_mote_data = "/home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_sensorID/"

# load the DT_field_data_uuid data.table
load(file = paste0(wd_data,"DT_field_data_uuid.RData"))

# see what we got
tables()
  # NAME                NROW NCOL MB COLS                                  KEY
  # [1,] DT_field_data_uuid 2,278    5  1 uuid,houseID,moteID,sensortype,source    
  # Total: 1MB
DT_field_data_uuid

# count of motes by houseID
DT_field_data_uuid[,length(unique(moteID)),by=houseID][order(houseID)]

# list all the motes from houseID 7
sort(unique(DT_field_data_uuid[houseID==7,moteID]))
# [1] "x3234" "x3242" "x3259" "x325f" "x3262" "x32ad" "x32ae" "x3356" "x337a" "x34e9"
# [11] "x356a" "x3595" "x35b4" "x35b5" "x35c6" "x388b"

# motes for this house
this_house = 7
motes_this_house = sort(unique(DT_field_data_uuid[houseID==this_house,moteID]))

# uuids for this mote
this_mote = "x3242"
DT_field_data_uuid[moteID==this_mote,uuid]

# load data for this mote 
mote_fn = paste0("RSmap.",this_mote,".raw.xz.RData")
#  the DT_field_data_uuid data.table
load(file = paste0(wd_mote_data, mote_fn))

# see what it looks like
head(data)
str(data)
length(data)
  # [1] 7
  # it's the data streams from 7 uuids
length(data[[1]])
  # [1] 3
  # each item in the original list is a list of 3 items
length(data[[1]][[2]])
  # [1] 185907
  # the length of the 2nd list of 3 in the 1st list of 7

# list the uuids
data[[1]]$uuid
uuids=""
for(d in 1:7) {uuids[d] = data[[d]]$uuid}

# see if uuids matches from DT_field_data_uuid
identical(uuids,DT_field_data_uuid[moteID==this_mote,uuid])
  # [1] TRUE





