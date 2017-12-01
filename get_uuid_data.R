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

# path to mote files
wd_mote_data = "/home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_sensorID/"
# path to uuid files
wd_uuid_data = "/home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/by_uuid/"

# path to put the converted files in
wd_save_uuid = "/home/jiml/HotWaterResearch/projects/HWDS monitoring/curate_field_data/data/uuid/"

# get list of all the file names in wd_mote_data
l_fns <- Sys.glob(paths = paste0(wd_mote_data,"*.RData"))

# test on one file name
this_fn = l_fns[1]

# load the R object from the file. Object should be named data
load(this_fn)
str(data)

# for debugging only
l_data = unlist(data, recursive = FALSE) 
str(l_data)
# do this outside of this function to make sure it's just a list of 3,
# not a list of lists
save_dir = wd_save_uuid

# check number of SMAP data streams
n_ds <- length(data)



put_DT_uuid_data <- function(l_data = data, save_dir = wd_uuid_data){
  # function to save a single SMAP data stream a file in wd_uuid_data
  # l_data is one SMAP data stream
  # l_data = List of 3
  # $ time : num [1:x] 
  # $ value: num [1:x]
  # $ uuid : chr 
  # save_dir is name of directory to save the file to
  # file name is uuid.RData
  # data.table name is always just DT_uuid
  
  # get the uuid
  uuid <- l_data$uuid
  
  # make the file name
  uuid_fn = paste0(save_dir,uuid,".RData")
  
  # make the data.table
  DT_uuid <- data.table(time = l_data$time, value = l_data$value)

  # save the data.table
  save(DT_uuid, file = uuid_fn)
  
  # clean up the data
  rm(l_data, DT_uuid)
  
}

put_DT_uuid_data(l_data = l_data, save_dir = wd_save_uuid)
  





