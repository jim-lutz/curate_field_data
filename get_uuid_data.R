# get_uuid_data.R
# script to convert all the uuid data streams to data.table.RData files
# /home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/
# both by_sensorID and by_uuid
# makes each uuid data stream one data.table and saves it in a uuid.RData file
# Jim Lutz 

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# call useful functions
source("functions.R")

# input path
# path to mote files
wd_mote_data = "/home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_sensorID/"
# path to uuid files
wd_uuid_data = "/home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_uuid/"

# output path
# path to put the converted files in
wd_save_uuid = "/home/jiml/HotWaterResearch/projects/HWDS monitoring/curate_field_data/data/uuid/"

# get list of all the file names in wd_mote_data
l_fns <- Sys.glob(paths = paste0(wd_mote_data,"*.RData"))

# test on one file name
this_fn = l_fns[32]

# save all the SMAP objects in one file as data.table RData files
put_SMAP_file(this_fn, wd_uuid_data)



