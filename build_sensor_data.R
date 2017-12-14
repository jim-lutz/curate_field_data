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
load(file = paste0(wd_data,"DT_sensorID.RData"))

# load the DT_meta2 data.table
load(file = paste0(wd_data,"DT_meta2.RData"))

tables()
  #      NAME         NROW NCOL MB
  # [1,] DT_meta2    2,947   16  1
  # [2,] DT_sensorID 1,738    8  1
  #      COLS                                                                            
  # [1,] uuid,source,path,houseID,moteID,sensortype,units,type,study,model,timezone,drive
  # [2,] uuid,houseID,moteID,sensortype,sensorID,count,first,last                        
  #      KEY   
  # [1,] uuid  
  # [2,] moteID

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

# get tempA and flowA
DT_tempA <- get_DT_uuid_data("182d1615-9268-5836-b8fe-c0cd8012354f")
setkey(DT_tempA,time)
DT_flowA <- get_DT_uuid_data("5e530240-f53d-5250-89a4-336d84f285ba")
setkey(DT_flowA,time)
DT_sensor_data <- merge(DT_tempA,DT_flowA)

# fix the names
setnames(DT_sensor_data, old = c("value.x","value.y"), new = c("temp","flow"))

# add human readable time
DT_sensor_data[,datetime:=readUTCmilliseconds(time)]

# look at flows
summary(DT_sensor_data[,flow])
summary(DT_sensor_data[flow>0,flow])
DT_sensor_data[, list(n=length(time)), by = (flow>0)]
  #    flow      n
  # 1: FALSE 224173
  # 2:  TRUE   1468
# not much flow
DT_sensor_data[flow>0,]

# why flow in October & again in March?
str(DT_sensor_data)
DT_sensor_data[,week.num := week(datetime)]
DT_sensor_data[flow>0,list(vol=sum(flow/60), 
                           start.date=str_sub(readUTCmilliseconds(min(time)),1,10)
                          ),by = week.num]
# not reading much flow, but otherwise looks OK.

# look at temps
summary(DT_sensor_data[,temp])
  #  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  # 17.51   26.87   27.45   27.35   28.25   40.45 
DT_sensor_data[temp>35][order(datetime)]
DT_sensor_data[datetime>"2013-10-07 15:40" & datetime<"2013-10-07 16:00"][order(datetime)]


