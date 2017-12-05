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

# list of uuid files 
fn_uuids <- paste0(wd_uuid,list.files(wd_uuid))


get_uuid_info <- function(fn_uuid){
  # function to get the number of records and the first & last times
  # returns a data.table
  
  # get the uuid from the filename
  this_uuid <- str_sub(fn_uuid,-42,-7)
  
  # load the data.table
  load(fn_uuid, verbose = TRUE)
  
  # get the number of records
  nrecs <- nrow(DT_uuid)

  # get the datetimes of the first and last data fields
  first <- readUTCmilliseconds(min(DT_uuid[]$time))
  last  <- readUTCmilliseconds(max(DT_uuid[]$time))
  
  # build a data.table to return
  return(data.table(uuid  = this_uuid,
                    nrecs = nrecs,
                    first = first,
                    last  = last)
         )
  
}

# minimal testing
this_fn_uuid <- fn_uuids[2]

str(get_uuid_info(this_fn_uuid))
