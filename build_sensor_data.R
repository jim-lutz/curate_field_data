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

# load the DT_sensorID data.table
# load(file = paste0(wd_data,"DT_sensorID.RData"))
# not using this for now.

# load the DT_meta2 data.table
load(file = paste0(wd_data,"DT_meta2.RData"))

tables()
  #      NAME         NROW NCOL MB
  # [1,] DT_meta2 2,947   16  1
  #      COLS                                                                            
  # [1,] uuid,source,path,houseID,moteID,sensortype,units,type,study,model,timezone,drive
  #      KEY 
  # [1,] uuid

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

this_houseID <- 11
this_moteID  <- 'x356a'
this_sensor  <- 'A'

get.temp.and.flow <- function(this_houseID, this_moteID, this_sensor, DT_meta2) {
  # function to get temp and flow given houseID, moteID & sensor {A|B}
  # this sensor is c("A","B")
  
  # check that both temp and flow data streams exist for this combination
  temp.uuid <- DT_meta2[houseID    ==  this_houseID &
                        moteID     ==  this_moteID &
                        sensortype ==  paste0('temp', this_sensor), uuid]
  flow.uuid <- DT_meta2[houseID    ==  this_houseID &
                        moteID     ==  this_moteID &
                        sensortype ==  paste0('flow', this_sensor), uuid]
  # issue warnings if the uuid don't exist
  if(nchar(temp.uuid)!=36) {warning(paste0('temp', this_sensor, " does not exist for house ", this_houseID," mote ", this_moteID))}  
  if(nchar(flow.uuid)!=36) {warning(paste0('flow', this_sensor, " does not exist for house ", this_houseID," mote ", this_moteID))}  
  
  # get temp and flow
  DT_temp <- get_DT_uuid_data(temp.uuid)
  setkey(DT_temp,time)
  DT_flow <- get_DT_uuid_data(flow.uuid)
  setkey(DT_flow,time)
  
  # merge into one data.table
  DT_sensor_data <- merge(DT_temp,DT_flow)

  # fix the names
  setnames(DT_sensor_data, old = c("value.x","value.y"), new = c("temp","flow"))

  # add human readable time
  DT_sensor_data[,datetime:=readUTCmilliseconds(time)]
  
  # set flow -0.01 to 0
  DT_sensor_data[flow==-0.01, flow:=0.0]

  # return the data.table
  return(DT_sensor_data)

}
  
DT_sensor_data <- get.temp.and.flow(this_houseID = 11, 
                                    this_moteID  = 'x356a',
                                    this_sensor  = 'A',
                                    DT_meta2)


  # look at flows
summary(DT_sensor_data[,flow])
summary(DT_sensor_data[flow>0,flow])
qplot(DT_sensor_data[flow>0,flow])
DT_sensor_data[, list(n=length(time)), by = (flow>0)]
  #     flow      n
  # 1: FALSE 373714
  # 2:  TRUE  35065
# not much flow
DT_sensor_data[flow>0,]

# look at total volume by week
DT_sensor_data[,week.num := week(datetime)]
DT_sensor_data[flow>0,list(vol=sum(flow/60), 
                           start.date=str_sub(readUTCmilliseconds(min(time)),1,10)
                          ),by = week.num]
# looks OK.

# look at temps
summary(DT_sensor_data[,temp])
  #  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  # 16.11   27.45   29.19   35.54   36.78   72.04 
# average temperature by week
DT_sensor_data[       , list(n.records = length(time),
                             ave.temp  = mean(temp)
                             ), by = week.num]
# Tstat setting for this one appears to be high!

# build lists of moteIDs by houseID
DT_meta2[!is.na(moteID) & !is.na(houseID) ,list(moteID),by = houseID][order(houseID)]
