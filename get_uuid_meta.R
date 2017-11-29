# get_uuid_meta.R
# script to collect all the uuid meta information in
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

# see if there's really 2278 uuids
DT_field_data_uuid[,list(nuuids=length(moteID)),by=uuid][order(nuuids)]
# yeah there really are.

# count of motes by houseID
DT_field_data_uuid[,list(nmotes=length(unique(moteID))),by=houseID][order(houseID)]

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
#  1:       1     210        12    12
#  2:       2      82        13    13
#  3:       3     106        16    16
#  4:       4     114        17    17
#  5:       5     210        20    20
#  6:       6      82        12    12
#  7:       7     108        16    16
#  8:       9      95        14    14
#  9:      10      99        15    15
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
# the moteIDs w/o files for house 18
DT_field_data_uuid[houseID==18 & is.na(fn),list(length(uuid)),by=moteID][order(moteID)]
  #    moteID V1
  # 1:  x327d  7
  # 2:  x3332  7
  # 3:  x3468  7

str(DT_field_data_uuid)
# remaining uuids w/ missing filenames
DT_field_data_uuid[is.na(fn),list(nuuids     = length(uuid),
                                  nmoteIDs   = length(moteID)
                                  ),
                   by=houseID][order(houseID)]
    #    houseID nuuids nmoteIDs
    # 1:       3      7        7
    # 2:      13      7        7
    # 3:      18     21       21
    # 4:      24     14       14

# get the uuid filenames from the same directory.
DT_uuid_fns <- data.table(fn=Sys.glob(paste0(wd_mote_data,"RSmap.*.RData")))
# looking for filenames like RSmap.c55f4e94-af05-5c5f-9fde-ba8302e13468.raw.xz.RData
DT_uuid_fns[,uuid:=str_extract(fn,"[a-f0-9-]{36}")]
DT_uuid_fns[is.na(uuid),] # 247
DT_uuid_fns[!is.na(uuid),] #19, 

#these are the filenames without moteIDs
DT_uuid_fns <- DT_uuid_fns[!is.na(uuid),] 
setkey(DT_uuid_fns,uuid)

# merge into DT_field_data_uuid
setkey(DT_field_data_uuid,uuid)
DT_uuid_meta <- merge(DT_field_data_uuid,DT_uuid_fns, all.x=TRUE)

# how many missing fns ? moteID = fn.x uuid=fn.y
with(DT_uuid_meta,table(is.na(fn.x),is.na(fn.y)))
  #       FALSE TRUE
  # FALSE     0 2229
  # TRUE     19   30     

# rename the fn
setnames(DT_uuid_meta, old = c("fn.x","fn.y"), new = c("fn.moteID","fn.uuid"))

