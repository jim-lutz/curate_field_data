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

# look at sensortypes
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

# look at number of A sensors by moteID
with(DT_meta2[sensortype %in% c("sensorA","tempA","flowA"), list(nsensor=length(sensortype)), by = moteID][order(nsensors)],
  table(nsensors))
# well this is a mess!
  # nsensors
  #   1   2   3   4   5   6   8   9  10  11  12  15  18  21 
  #   2  29 155   2   8  31   1   6   1   6   7   1   2   2 


