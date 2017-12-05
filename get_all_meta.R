# get_all_meta.R
# script to collect all the meta information in
# /home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/
# Jim Lutz "Mon Dec  4 16:06:40 2017"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# call useful functions
source("functions.R")

# path to Rsmap files
wd_smap_data = "/home/jiml/HotWaterResearch/projects/HWDS monitoring/retrieve_field_data/data/"

# load the DT_tags_raw.RData data.table
load(file = paste0(wd_smap_data,"DT_tags_raw.RData"))

# look at what's in it
tables()
str(DT_tags)
names(DT_tags)

# clean up the DT_tags data.table

# better names
setnames(DT_tags,
         c('Properties.Timezone',
           'Properties.UnitofMeasure', 
           'Properties.ReadingType', 
           'Path', 
           'uuid', 
           'Metadata.SourceName', 
           'Metadata.Metadata.Instrument.Model', 
           'Metadata.Metadata.Instrument.Manufacturer', 
           'Metadata.Metadata.Extra.Driver', 
           'Metadata.Description'),
         c('timezone',
           'units', 
           'type', 
           'path', 
           'uuid', 
           'source', 
           'model', 
           'study', 
           'driver', 
           'other')
)

# get house number
DT_tags[source %like% "HWDS_h", house:= str_sub(source,7,8)]
sort(unique(DT_tags$house)) # looks like if worked, but house 35?

# change house to houseID numeric
DT_tags[,houseID:=as.numeric(house)]
str(DT_tags)

# remove house, no longer needed
DT_tags[,house:=NULL]

sort(unique(DT_tags[]$houseID))
# [1]  1  2  3  4  5  6  7  9 10 11 13 14 16 17 18 19 20 21 22 24 25 35
# missing 8, 12, 15, & 23

# what's house 35?
DT_tags[houseID==35,]
# apparently has data, probably typo into SMap data.

# get sensorID and sensortype from path
DT_tags[path %like% "/hwds_test/0x", ':=' (sensorID = str_sub(path,13,17),
                                           sensortype = str_sub(path,19,-1)
                                           )
        ]
sort(unique(DT_tags$sensorID)) # OK? 253 sensors
sort(unique(DT_tags$sensortype)) # OK, except when sensorID =="x5c2/"

DT_tags[sensorID =="x5c2/", ':=' (sensorID = str_sub(path,13,16),
                                  sensortype = str_sub(path,18,-1)
                                  )
        ]

sort(unique(DT_tags$sensortype)) # OK, that's better

# see which fields don't contain useful information
unique(DT_tags$Metadata.uuid)
  # [1] NA                                     "985ef7ef-2309-50c9-8c57-a057687e0ac2"
DT_tags[,list(n=length(uuid)),by=Metadata.uuid]
  #                           Metadata.uuid    n
  # 1:                                   NA 2946
  # 2: 985ef7ef-2309-50c9-8c57-a057687e0ac2    1
DT_tags[Metadata.uuid=="985ef7ef-2309-50c9-8c57-a057687e0ac2"]
DT_tags[uuid=="985ef7ef-2309-50c9-8c57-a057687e0ac2"]
identical(DT_tags[Metadata.uuid=="985ef7ef-2309-50c9-8c57-a057687e0ac2"],
          DT_tags[uuid=="985ef7ef-2309-50c9-8c57-a057687e0ac2"]
          )
# this field only has one record, and the data is duplicated under uuid, 
# OK to get rid of column
DT_tags[,Metadata.uuid:=NULL]

# better order
str(DT_tags)
names(DT_tags)
setcolorder(DT_tags, c('source', 'path', 'houseID', 'sensorID', 'sensortype', 'units', 'uuid', 
                       'type', 'study', 'model', 'timezone', 'driver', 'other'))

# rename the data.table
DT_meta <- DT_tags
rm(DT_tags) # don't really need to do this

save(DT_meta, file = paste0(wd_data,"DT_meta.RData"))
