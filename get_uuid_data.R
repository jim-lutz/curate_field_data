# get_uuid_data.R
# script to collect all the uuid information in
# /home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_sensorID
# make one long data.table of uuid, time, value by houseID & moteID
# Jim Lutz 

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

# get the moteIDs and uuids for a houseID
DT_field_data_uuid[houseID==3,]
# 106 uuids
sort(unique(DT_field_data_uuid[houseID==3,]$moteID))
  #  [1] "x323f" "x3288" "x32f3" "x32ff" "x331f" "x332c" "x3352" "x3356" "x339e" "x33ed"
  # [11] "x3443" "x3497" "x34c5" "x358e" "x35b1" "x35b4"

# key by moteID
setkey(DT_field_data_uuid, moteID)

# get the moteID filenames
DT_moteID_fns <- data.table(fn=Sys.glob(paste0(wd_mote_data,"RSmap.x*.RData")))
DT_moteID_fns[,moteID:=str_extract(fn,"x[a-f0-9]{3,4}")]
setkey(DT_moteID_fns,moteID)

# merge the filenames into DT_field_data_uuid
DT_field_data_uuid <- merge(DT_field_data_uuid,DT_moteID_fns, all.x = TRUE)

# count uuids and fn by houseId
DT_field_data_uuid[,list(n_uuids   = length(unique(uuid)),
                         n_moteIDs = length(unique(moteID)),
                         n_fns     = length(unique(fn)) 
                         ),
                   by=houseID][order(houseID)]
    #    houseID n_uuids n_moteIDs n_fns
    # 1:       1     210        12    12
    # 2:       2      82        13    13
    # 3:       3     106        16    16
    # 4:       4     114        17    17
    # 5:       5     210        20    20
    # 6:       6      82        12    12
    # 7:       7     108        16    16
    # 8:       9      95        14    14
    # 9:      10      99        15    15
    # 10:      11      82        12    12
    # 11:      13     113        17    17
    # 12:      14     131        20    20
    # 13:      16      38         6     6
    # 14:      17      43         7     7
    # 15:      18     164        24    22
    # 16:      19      67        10    10
    # 17:      20     111        16    16
    # 18:      21      70        11    11
    # 19:      22      94        14    14
    # 20:      24     111         9     9
    # 21:      25      87        13    13
    # 22:      35      61         9     9
    #     houseID n_uuids n_moteIDs n_fns

# seems like houseID 18 is missing some moteID files
DT_field_data_uuid[houseID==18 & is.na(fn),list(moteID,uuid,fn)][order(uuid)]
# don't seem to have these files anywhere
DT_field_data_uuid[houseID==18 & is.na(fn),list(moteID,sensortype,uuid)][order(moteID,sensortype)]
# it's 3 different moteIDs
DT_field_data_uuid[houseID==18 & is.na(fn),list(length(uuid)),by=moteID][order(moteID)]


# get all the moteIDs for a houseID
this_houseID = 5  # try one houseID

# list of moteIDs for this houseID
l_moteIDs <- sort(unique(DT_field_data_uuid[houseID==this_houseID & !is.na(fn),]$moteID))

# try one moteID
this_moteID = l_moteIDs[5]
fn_moteID = unique(DT_field_data_uuid[houseID==this_houseID & moteID==this_moteID]$fn)

# get all the data from one moteID
DT_moteID_data <- get_DT_moteID_data(fn_moteID)
setkey(DT_moteID_data,uuid)

# check how many uuids
DT_moteID_data[,list(uuid=unique(uuid))][order(uuid)]
# 14? expected only 7, maybe put out second set of sensors after thermistor leak fix?

# see what's in it.
str(DT_moteID_data)

# add the sensortype
DT_sensortype_uuid <- DT_field_data_uuid[houseID==this_houseID & moteID==this_moteID, list(uuid,sensortype)]
setkey(DT_field_data_uuid,uuid)

# merge sensortype into DT_moteID_data
DT_moteID_sensortype <- merge(DT_moteID_data,DT_sensortype_uuid)

# check if any sensortypes missing
DT_moteID_sensortype[is.na(sensortype)]
  # Empty data.table (0 rows) of 4 cols: uuid,time,value,sensortype

# see if it makes sense
DT_moteID_sensortype[,list(sensortype=unique(sensortype)),by=uuid][order(uuid)]

# find first & last time for each uuid
DT_moteID_sensortype[,list(first= readUTCmilliseconds(min(time)),
                           last = readUTCmilliseconds(max(time)),
                           sensortype = unique(sensortype)
                           ),
                     by=uuid][order(first)]
# in this case we have a gap from 2013-08-16 12:07:03 PDT to 2014-01-08 10:41:50 PST
