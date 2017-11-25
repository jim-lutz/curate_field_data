# review_mote_data.R
# script to review information in the mote files in
# /home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_sensorID
# Jim Lutz "Thu Nov 23 11:37:13 2017"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# call useful functions
source("functions.R")

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
DT_field_data_uuid[,list(nmotes=length(unique(moteID))),by=houseID][order(houseID)]

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
#  get the data from RSmap.this_mote.raw.xz.RData
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

# start building the summary information about this data set
DT_moteID_summary <- DT_field_data_uuid[moteID==this_mote,list(houseID,moteID,uuid,sensortype)]

# get the datastream from one uuid
l_data <- data[[1]]
str(l_data)

# turn that into a data.table
DT_data <- get_DT_uuid_data(l_data = l_data)



nchar(uuid)
# [1] 36

# get the first and last time stamp of each data stream
uuid <- as.character()
first_time <- as.numeric()
last_time <- as.numeric()
ndata <- as.numeric()
summ <- as.numeric

for(d in 1:7) {
  uuid[d]       = data[[d]]$uuid
  first_time[d] = readUTCmilliseconds(min(data[[d]]$time))
  last_time[d]  = readUTCmilliseconds(max(data[[d]]$time))
  ndata         = length(data[[d]]$time)
  summ          <- as.numeric(summary(data[[d]]$value))
  }
DT_moteID_data_summary <- data.table(uuid,first_time,last_time, ndata, t(summ))

merge(DT_moteID_summary,DT_moteID_data_summary,by="uuid")
# values aren't being read correctly



