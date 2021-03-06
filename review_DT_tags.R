# review_DT_tags.R
# script to review information in DT_tags.RData
# Jim Lutz "Tue Nov 21 07:28:48 2017"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# load the tags
load(file = "/home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/DT_tags.RData")

# see what we got
tables()
  # NAME          NROW NCOL MB
  # [1,] DT_tags 2,947   13  1
  # COLS                                                                            
  # [1,] source,path,house,sensorID,sensortype,units,uuid,type,study,model,timezone,drive
  # KEY
  # [1,]    
  # Total: 1MB
DT_tags

# rename sensorID column to moteID. Was a mistaken use of terminology
setnames(DT_tags,old="sensorID", new = "moteID")

# see if only moteID is good enough
DT_tags[!is.na(moteID),]
# 2511 records

# look at moteID
length(sort(unique(DT_tags[!is.na(moteID),moteID])))
# [1] 253

# look at all the variables to see which could be dropped
names(DT_tags)
  # [1] "source"     "path"       "house"      "moteID"     "sensortype" "units"     
  # [7] "uuid"       "type"       "study"      "model"      "timezone"   "driver"    
  # [13] "other" 

sort(unique(DT_tags[!is.na(moteID),source]))
  #  [1] "HWDS_dev"              "HWDS_h1"               "HWDS_h10 (beagle22)"  
  #  [4] "HWDS_h11 (beagle11)"   "HWDS_h13 (beagle16)"   "HWDS_h14 (beagle3)"   
  #  [7] "HWDS_h16 (beagle15)"   "HWDS_h17 (beagle12)"   "HWDS_h18 (beagle20)"  
  # [10] "HWDS_h19 (beagle10)"   "HWDS_h1 (beaglebone)"  "HWDS_h2"              
  # [13] "HWDS_h20 (beagle4)"    "HWDS_h21 (beagle19)"   "HWDS_h22 (beagle17)"  
  # [16] "HWDS_h24 (beagle18)"   "HWDS_h25 (beagle24)"   "HWDS_h3"              
  # [19] "HWDS_h35 (beagle13)"   "HWDS_h3 (beagle2)"     "HWDS_h4 (beagle5)"    
  # [22] "HWDS_h5 (beagle23)"    "HWDS_h5 (beagle9)"     "HWDS_h6 (beagle14)"   
  # [25] "HWDS_h7 (beagle6)"     "HWDS_h9 (beagle8)"     "HWDS Pre-install test"
  # [28] "HWDS test (beagle4)"  

length(sort(unique(DT_tags[!is.na(moteID),path])))
  # [1] 1707
# probably don't neet to keep path.

DT_tags[,path]
DT_tags[!(path %like% "hwds_test"), other]
# this is only about things like latency and ping success, probably don't need that.
unique(DT_tags[(path %like% "hwds_test"), other])
# these are all NA, not useful

# check it hwds_test means there was a moteID
DT_tags[(path %like% "hwds_test"), ]
# 2612
DT_tags[!is.na(moteID), ]
# 2511 what are the 101 that are different?
DT_tags[(path %like% "hwds_test"), ][is.na(moteID), ]
# these are the net_reliabilty and net_reliability, probably don't need if is.na(moteID)

sort(unique(DT_tags[!is.na(moteID),house]))
  #  [1] "1"  "1 " "10" "11" "13" "14" "16" "17" "18" "19" "2"  "20" "21" "22" "24" "25"
  # [17] "3"  "3 " "35" "4 " "5 " "6 " "7 " "9 "
# what's 35? some of the values have trailing spaces, will have to get rid of those.

# change house to houseID numeric
DT_tags[,houseID:=as.numeric(house)]
str(DT_tags)

sort(unique(DT_tags[!is.na(moteID),houseID]))
# [1]  1  2  3  4  5  6  7  9 10 11 13 14 16 17 18 19 20 21 22 24 25 35
# missing 8, 12, 15, & 23

# what's house 35?
DT_tags[!is.na(moteID),][houseID==35]
# apparently has data, probably typo into SMap data.

# what to do about sensortype
sort(unique(DT_tags[!is.na(moteID),sensortype]))
  # [1] "batt_volt" "flowA"     "flowB"     "sensorA"   "sensorB"   "tempA"    
  # [7] "tempB"    

# what to do about units
sort(unique(DT_tags[!is.na(moteID),units]))
  # [1] "degC" "GPM"  "N/A"  "V"   

# do units correspond exactly with sensortype?
unique(DT_tags[!is.na(moteID) & sensortype %like% "flow", units ])
  # [1] "GPM"
unique(DT_tags[!is.na(moteID) & sensortype %like% "temp", units ])
  # [1] "degC"
unique(DT_tags[!is.na(moteID) & sensortype %like% "batt", units ])
  # [1] "V"
unique(DT_tags[!is.na(moteID) & sensortype %like% "sensor", units ])
  # [1] "N/A"
# don't need units if have sensortype

# what about type
unique(DT_tags[!is.na(moteID),type])
  # [1] "double" "long"  
unique(DT_tags[!is.na(moteID),list(type,sensortype)])
# flow & temp are double, sensor is long

# study?
unique(DT_tags[!is.na(moteID),study])
  # [1] "LBNL" 
# don't bother keeping.

# model?
unique(DT_tags[!is.na(moteID),model])
  # [1] "HWDS Flow Meters"
unique(DT_tags[,model])
# [1] "HWDS Flow Meters" NA                
unique(DT_tags[is.na(moteID),model])
# [1] NA                 "HWDS Flow Meters"
# don't bother keeping.

# timezone?
unique(DT_tags[,timezone])
  # [1] "America/Los_Angeles"
# don't bother keeping.

# driver?
unique(DT_tags[,driver])
  # [1] "smap.drivers.mote.MoteDriver"       "smap.drivers.ping_drvr.chk_latency"
unique(DT_tags[!is.na(moteID),driver])
  # [1] "smap.drivers.mote.MoteDriver"
# don't bother keeping.

# other?
unique(DT_tags[!is.na(moteID),other])# [1] NA
# don't bother keeping.

# double check relation between moteID and houseID
DT_tags[!is.na(moteID),]
#2511
DT_tags[!is.na(houseID),]
# 2687
# compare the counts
with(DT_tags,
     table(is.na(moteID), is.na(houseID), useNA = "ifany" )
    )
  #       FALSE TRUE
  # FALSE  2278  233
  # TRUE    409   27
DT_tags[!is.na(moteID) & !is.na(houseID),]
# 2278
sort(unique(DT_tags[!is.na(moteID) & is.na(houseID),source]))
  # [1] "HWDS_dev"              "HWDS Pre-install test" "HWDS test (beagle4)"
  # 233
sort(unique(DT_tags[is.na(moteID) & is.na(houseID),source]))
  # [1] "HWDS Pre-install test" "HWDS test (beagle4)"
  # 27
sort(unique(DT_tags[is.na(moteID) & !is.na(houseID),other]))
  # [1] "128.3.28.51 maximum latency"        "128.3.28.51 median latency"        
  # [3] "128.3.28.51 minimum latency"        "128.3.28.51 rate of pin success"   
  # [5] "128.8.237.77 maximum latency"       "128.8.237.77 median latency"       
  # [7] "128.8.237.77 minimum latency"       "128.8.237.77 rate of pin success"  
  # [9] "www.google.com maximum latency"     "www.google.com median latency"     
  # [11] "www.google.com minimum latency"     "www.google.com rate of pin success"
# so keep !is.na(moteID) & !is.na(houseID)

# save the field data uuids
DT_field_data_uuid <- DT_tags[!is.na(moteID) & !is.na(houseID), 
                              list(uuid, houseID, moteID, sensortype, source)]
save(DT_field_data_uuid, file = paste0(wd_data,"DT_field_data_uuid.RData"))

