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

# get data.table of the meta info from all the uuid files
DT_uuid_info <- data.table(ldply(.data=fn_uuids, 
                                  .fun =get_uuid_info, 
                                  .progress= "text", 
                                  .inform=TRUE))



# key data.tables by uuid
setkey(DT_uuid_info,uuid)
setkey(DT_meta,uuid)
tables()

# merge uuid info onto meta data
DT_meta2 <- merge(DT_meta, DT_uuid_info, all.x = TRUE )

# now save it
save(DT_meta2, file = paste0(wd_data,"DT_meta2.RData"))

