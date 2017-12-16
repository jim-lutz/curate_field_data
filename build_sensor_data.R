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

# load the DT_meta2 data.table
load(file = paste0(wd_data,"DT_meta2.RData"))


# find uuids for one sensor, one mote for one house
# number of sensors by houseID
DT_meta2[,list(n.sensors=length(sensortype)),by = houseID][!is.na(houseID),][order(houseID)]

# number of sensors by mote for house 4
DT_meta2[houseID==4,list(n.sensors=length(sensortype)),by = moteID][!is.na(moteID),]

# sensors for one moteID
DT_meta2[houseID==4 & moteID=='x334f',list(sensortype, uuid, count )]
  #    sensortype                                 uuid  count
  # 1:    sensorB 1260d952-2370-5861-b7ea-da415880b1dd 211442
  # 2:      tempA 182d1615-9268-5836-b8fe-c0cd8012354f 225641
  # 3:      tempB 4018e7a3-d535-595a-a682-95c8d2238cda 225640
  # 4:      flowA 5e530240-f53d-5250-89a4-336d84f285ba 225642
  # 5:    sensorA a811afa7-1390-5e44-95a5-07da332d3b59 211442
  # 6:      flowB b87eb256-14ca-5265-b948-4459ad79a625 225642
  # 7:  batt_volt fd1c0d8f-392b-59f9-96da-07de92ab7d3f 211442

# check to see if any moteID is used by more than one house
DT_houseIDs_moteID <- DT_meta2[!is.na(moteID),list(houseIDs = unique(houseID)), by = moteID][,list(n.houseIDs=length(houseIDs)),by = moteID][order(-n.houseIDs)]
qplot(DT_houseIDs_moteID$n.houseIDs)
# check an interesting one
DT_meta2[moteID=='x356a' & str_detect(sensortype, "tempA|flowA"), list(moteID,houseID, sensortype, count, first, last)][order(houseID,sensortype)]
  #     moteID houseID sensortype  count                   first                    last
  #  1:  x356a       2      flowA    217 2013-07-15 16:01:10 PDT 2013-07-24 16:34:36 PDT
  #  2:  x356a       2      tempA    217 2013-07-15 16:01:10 PDT 2013-07-24 16:34:36 PDT
  #  3:  x356a       4      flowA    511 2013-08-06 14:25:23 PDT 2013-08-06 17:35:24 PDT
  #  4:  x356a       4      tempA    511 2013-08-06 14:25:23 PDT 2013-08-06 17:35:24 PDT
  #  5:  x356a       7      flowA   2638 2013-08-07 08:42:50 PDT 2013-08-07 11:46:50 PDT
  #  6:  x356a       7      tempA   2638 2013-08-07 08:42:50 PDT 2013-08-07 11:46:50 PDT
  #  7:  x356a       9      flowA    677 2013-08-07 15:02:59 PDT 2013-08-07 16:58:59 PDT
  #  8:  x356a       9      tempA    677 2013-08-07 15:02:59 PDT 2013-08-07 16:58:59 PDT
  #  9:  x356a      11      flowA 408779 2013-08-09 12:27:08 PDT 2014-03-25 08:19:56 PDT
  # 10:  x356a      11      tempA 408779 2013-08-09 12:27:08 PDT 2014-03-25 08:19:56 PDT
  # 11:  x356a      14      flowA    448 2013-08-06 09:47:35 PDT 2013-08-06 11:58:36 PDT
  # 12:  x356a      14      tempA    448 2013-08-06 09:47:35 PDT 2013-08-06 11:58:36 PDT
  # 13:  x356a      NA      flowA   1358 2013-08-06 20:36:25 PDT 2013-08-07 23:14:29 PDT
  # 14:  x356a      NA      tempA   1358 2013-08-06 20:36:25 PDT 2013-08-07 23:14:29 PDT
# going to have to limit to one houseID at a time

# save this for later inspections and cleaning
# this_houseID <- 11
# this_moteID  <- 'x356a'
# this_sensor  <- 'A'
# 
# DT_sensor_data <- get.temp.and.flow(this_houseID = 11, 
#                                     this_moteID  = 'x356a',
#                                     this_sensor  = 'A',
#                                     DT_meta2)
# 
# 
#   # look at flows
# summary(DT_sensor_data[,flow])
# summary(DT_sensor_data[flow>0,flow])
# qplot(DT_sensor_data[flow>0,flow])
# DT_sensor_data[, list(n=length(time)), by = (flow>0)]
#   #     flow      n
#   # 1: FALSE 373714
#   # 2:  TRUE  35065
# # not much flow
# DT_sensor_data[flow>0,]
# 
# # look at total volume by week
# DT_sensor_data[,week.num := week(datetime)]
# DT_sensor_data[flow>0,list(vol=sum(flow/60), 
#                            start.date=str_sub(readUTCmilliseconds(min(time)),1,10)
#                           ),by = week.num]
# # looks OK.
# 
# # look at temps
# summary(DT_sensor_data[,temp])
#   #  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   # 16.11   27.45   29.19   35.54   36.78   72.04 
# # average temperature by week
# DT_sensor_data[       , list(n.records = length(time),
#                              ave.temp  = mean(temp)
#                              ), by = week.num]
# Tstat setting for this one appears to be high!

# lists of moteIDs by houseID
DT_meta2[!is.na(moteID) & !is.na(houseID) ,list(moteID),by = houseID][order(houseID)]

# for debugging
this_houseID <- 11
this_moteID  <- 'x356a'
this_sensor  <- 'A'

# check for multiple uuids with same houseID moteID sensortype
DT_meta2[sensortype %in% c('tempA','flowA','tempB','flowB') & !is.na(houseID), list(uuid)]
# 1320 uuid files

DT_meta2[sensortype %in% c('tempA','flowA','tempB','flowB') & !is.na(houseID),
         list(n.uuid = length(uuid)), 
         by=c("houseID", "moteID", "sensortype")][order(-n.uuid)][n.uuid>1]
# of which 115 have duplicate uuids

# find the count, first and last for the data files for each combo
DT_hms <-
DT_meta2[sensortype %in% c('tempA','flowA','tempB','flowB') & !is.na(houseID),
         list(uuid, count, first, last), 
         by=c("houseID", "moteID", "sensortype")][order(houseID, moteID, sensortype)]

# count number of uuids per combos of hms
DT_hms[, n.hms:=length(uuid), by=c("houseID", "moteID", "sensortype")]

# look at the multiples
DT_hms[n.hms>1, unique(houseID)]
# [1]  1  5 24

# look at houseID ==1
DT_hms[n.hms>1 & houseID==1,]
# 113

DT_hms[n.hms>1 & houseID==1, sort(unique(moteID))]
DT_meta2[houseID==1, sort(unique(moteID))]
# it's only a problem with some of the moteIDs in houseID 1

# look at houseID ==5
DT_hms[n.hms>1 & houseID==5,]
# 86

DT_hms[n.hms>1 & houseID==5, sort(unique(moteID))]
DT_meta2[houseID==5, sort(unique(moteID))]

# look at houseID ==24
DT_hms[n.hms>1 & houseID==24,]
# 64

DT_hms[n.hms>1 & houseID==24, sort(unique(moteID))]
DT_meta2[houseID==24, sort(unique(moteID))]
# all but 1 of the moteIDs for houseID 24




# loop through all the houseIDs
for( hID in DT_meta2[!is.na(houseID),sort(unique(houseID))] ){
# for( hID in c(this_houseID) ){ # for debugging
  cat(hID,"\n")
  
  # loop through all the moteIDs 
  for( mID in DT_meta2[houseID==hID,sort(unique(moteID))] ){
#  for( mID in c(this_moteID) ){ # for debugging
  cat("\t",mID,"\n")
    
    # look for both A & B sensors
    for( s in c('A', 'B')){
      cat("\t\t",s,"\n")
      
      # build the filename to store the data.table in
      fn_DT <- paste0(wd_data,"sensors/DT_",hID,"_",mID,'_',s,".xz.Rdata")
      cat(hID,"\t",mID,"\t",s)
      cat(fn_DT,"\n")
      
      # get the temp & flow data
      DT <- get.temp.and.flow(hID, mID, s, DT_meta2)
      
      # store the data, use xz compression
      save(DT, file = fn_DT, compress = "xz")
      
    }
    
  }
    
}


DT_meta2[houseID    ==  1 &
         moteID     ==  "x34b8" &
         sensortype ==  paste0('temp', 'A'), 
         uuid]

DT_meta2[houseID    ==  1 &
         moteID     ==  "x34b8" &
         sensortype ==  paste0('temp', 'A'),]

get.temp.and.flow(this_houseID=1, 
                  this_moteID="x34b8", 
                  this_sensor="tempA", 
                  DT_meta2, humanreadable = TRUE)

