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

sort(unique(DT_tags[!is.na(moteID),houseID]))



