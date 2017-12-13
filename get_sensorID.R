# get_sensorID.R
# script to get the sensorID values out of the sensorA and sensorB uuid data streams
# Jim Lutz "Wed Dec  6 17:09:41 2017"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# call useful functions
source("functions.R")

# load the DT_meta2.RData data.table
load(file = paste0(wd_data,"DT_meta2.RData"))

# check the data 
DT_meta2

# look at number by sensortypes
DT_meta2[,list(n=length(uuid)), by = sensortype]
# more flows & temps than sensors?

DT_meta2[str_detect(sensortype, "[AB]$"),list(n=length(moteID)), by = sensortype][order(stringi::stri_reverse(sensortype))]
  #    sensortype   n
  # 1:      tempA 359
  # 2:    sensorA 351
  # 3:      flowA 364
  # 4:      tempB 365
  # 5:    sensorB 353
  # 6:      flowB 364

# take a closer look
DT_meta2[sensortype %in% c("sensorA","tempA","flowA"),list(moteID, sensortype, count)][order(moteID)]

# look at number of A sensors per moteID
with(
  DT_meta2[sensortype %in% c("sensorA","tempA","flowA"),list(nsensor=length(sensortype)), by = moteID][order(nsensor)],
  table(nsensor)
  )
  # nsensors 
  #   1   2   3   4   5   6   8   9  10  11  12  15  18  21 
  #   2  29 155   2   8  31   1   6   1   6   7   1   2   2 
# well this is a mess! not all of these numbers are multiples of 3

# find sensorA|B with highest count
DT_meta2[sensortype %in% c("sensorA","sensorB"),list(moteID, sensortype, count)][order(-count)][1:25]
# for a lot of these, there's same count on A and B

# get list of uuids that belong to sensors
l_uuids <- DT_meta2[sensortype %in% c("sensorA","sensorB") & count > 0, uuid]
length(l_uuids)
# 700 of them

# get the sensorID data.table for all those uuids
DT_sensorID_info <- data.table(ldply(.data=l_uuids, .fun = get_sensorID_info, .progress= "text", .inform=TRUE))

summary(DT_sensorID_info[,sensorID])
  # Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
  #    0        0  4762096  2986168  4769099 12583168 

qplot(DT_sensorID_info[,sensorID])
sort(DT_sensorID_info[,sensorID])
tail(sort(DT_sensorID_info[,sensorID]), n=50)

DT_sensorID_info[,list(sensorID,count)][order(-count)]

# looks like a lot of messy data
# merge with sensortype and moteID off DT_meta2
names(DT_meta2)
DT_meta3 <- DT_meta2[,list(uuid,moteID,sensortype)]
setkey(DT_meta3, uuid)

names(DT_sensorID_info)
setkey(DT_sensorID_info, uuid)

DT_sensorID <- merge(DT_sensorID_info,DT_meta3)
names(DT_sensorID)
setcolorder(DT_sensorID, c("uuid", "moteID", "sensortype", "sensorID", "count", "first", "last"))
setkey(DT_sensorID, moteID)

# save DT_sensorID
save(DT_sensorID, file = paste0(wd_data,"DT_sensorID.RData"))



