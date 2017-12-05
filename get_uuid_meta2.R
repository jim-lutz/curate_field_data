# get_uuid_meta2.R
# script to collect number of records, start and end dates of each uuid data stream
# Jim Lutz "Mon Dec  4 17:13:39 2017"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# call useful functions
source("functions.R")

# path to the uuid files
wd_uuid <- paste0(wd_data,"uuid/")

# load the DT_tags_raw.RData data.table
load(file = paste0(wd_data,"DT_meta.RData"))

# get a uuid file for testing
fn_uuids <- list.files(wd_uuid)

uuid <- DT_meta[23,uuid]
# [1] "15512975-e7cc-5924-b250-c521fd29b8b8"

# name of uuid data file
fn_uuid <- paste0(wd_data,"uuid/",uuid,".Rdata")

# load the data.table
load(fn_uuid)
# /data/uuid/15512975-e7cc-5924-b250-c521fd29b8b8.Rdata', probable reason 'No such file or directory'

# count of uuids vs files
length(unique(DT_meta[,uuid]))
# [1] 2947
# $ ls -1 | wc -l
# 2917
# there's 30 more uuids than files

#function to return the data.table for a uuid data file

# get a uuid for testing
uuid <- DT_meta[231,uuid]

# name of uuid data file
fn_uuid <- paste0(wd_data,"uuid/",uuid,".Rdata")

# load the data.table
load(fn_uuid, verbose = TRUE)
# cannot open compressed file 
# '/home/jiml/HotWaterResearch/projects/HWDS monitoring/curate_field_data/data/uuid/fb4528d9-d564-5ff9-a6ac-2e92c38889d2.Rdata',
# probable reason 'No such file or directory'
# but
# $ ls -hAlt fb4*
#   -rw-rw-r-- 1 jiml jiml 438 Nov 30 17:47 fb4528d9-d564-5ff9-a6ac-2e92c38889d2.RData
# it's not very big?

# try one of a reasonable size that's in the directory
fn_uuid <- paste0(wd_data,"uuid/","5982a85d-d56f-5f91-9767-b2846c6c12c5",".Rdata")

# load the data.table
load(fn_uuids[2], verbose = TRUE)


