# functions.R
# R functions for hwds field monitoring data streams


readUTCmilliseconds <-function(UTCtime){
  # function to translate UTC milliseconds to something human readable
  
  # default to Pacific time
  tz = "America/Los_Angeles"
  
  # first convert to POSIXlt
  POSIXltime <- as.POSIXlt(UTCtime/1000,origin="1970-01-01", tz=tz )
  
  # then convert to formatted character string
  return(as.character(POSIXltime,usetz=TRUE))
  
}

writeUTCmilliseconds <-function(datetime){
  # function to translate from human readable to UTC milliseconds
  # assumes %Y-%M-%D %H:%M:%s
  
  # default to Pacific time
  tz = "America/Los_Angeles"
  
  # convert to POSIXct format
  UTCtime <- as.POSIXct(datetime, tz=tz)
  
  # numeric and to milliseconds
  UTCmilliseconds <- as.numeric(UTCtime)*1000
  
  return(UTCmilliseconds)
  
}

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


get_DT_uuid_data <- function(uuid = this_uuid, save_dir = wd_uuid){
  # function to get the single SMAP data stream from a uuid file in wd_uuid_data
  
  # make the file name
  uuid_fn = paste0(save_dir,uuid,".RData")
  
  # load the data.table
  load(file = uuid_fn)
  
  # return the data.table
  return(DT_uuid)
  
}


get_sensorID_info <- function(uuid = this_uuid, save_dir = wd_uuid){
  # function to get the number of records and the first & last times
  # by sensorID
  # returns a data.table
  
  # get the data
  DT_uuid <- get_DT_uuid_data(uuid)
  
  # look by sensorID
  DT_sensorID <-
    DT_uuid[,list(uuid,
                  count = length(time),
                  first = readUTCmilliseconds(min(time)),
                  last  = readUTCmilliseconds(max(time))
    ), by = value]
  
  # change value to sensorID
  setnames(DT_sensorID,"value","sensorID")
  setcolorder(DT_sensorID, c("uuid", "sensorID", "count", "first", "last"))
  
  # return the new data.table
  return( DT_sensorID )
  
}

put_SMAP_file <- function(this_fn = fn, save_dir = wd_save_uuid){
  # function to save all the SMAP data streams from one RSMAP file 
  # into uuid.RData files
  # this_fn is the file with a RSMAP data object
  # save_dir is the path to save the uuid.RData files
  
  # load the R object from the file. Object should be named data
  load(this_fn)
  
  # loop through all the data streams in one SMAP object
  l_ply(.data=data, .fun =put_DT_uuid_data, save_dir, .progress= "text", .inform=TRUE)
  
  # remove the object
  rm(data)
  
}

put_SMAP_files <- function(l_fn = l_fns, save_dir = wd_save_uuid){
  # function to save all the SMAP data streams from a LIST of RSMAP files 
  # into uuid.RData files
  # l_fn is the list of file names containing RSMAP data objects
  # save_dir is the path to save the uuid.RData files
  
  # loop through all the file names
  l_ply(.data=l_fn, .fun =put_SMAP_file, save_dir, .progress= "text", .inform=TRUE)
  
}

get_DT_moteID_data <- function(fn_moteID){
  # function to read all the data from all Rsmap data structures in a moteID file
  # return the data as a data.table with uuid as a field
  # not very efficient but puts everything in one record
  
  # load the list of data lists into data
  load(file = fn_moteID)
  
  # call get_DT_uuids_data on every data list in the list
  DT_moteID_data <- data.table(ldply(.data=data, .fun =get_DT_uuid_data, .progress= "text", .inform=TRUE))
  
  # clean up the data
  rm(data)
  
  return(DT_moteID_data)
}

get_DT_uuids_data <- function(fn_motes){
  # function to read all the data from all the Rsmap data structures in all the moteID file
  # return the data as one big data.table with uuid as a field
  # not very efficient but puts everything in one record
  
  # call get_DT_uuids_data on every data list in the list
  DT_uuids_data <- data.table(ldply(.data=fn_motes, 
                                    .fun =get_DT_moteID_data, 
                                    .progress= "text", 
                                    .inform=TRUE))
  
  return(DT_uuids_data)
}

get_uuid_info <- function(fn_uuid){
  # function to get the number of records and the first & last times
  # returns a data.table
  
  # get the uuid from the filename
  this_uuid <- str_sub(fn_uuid,-42,-7)
  
  # load the data.table
  load(fn_uuid)
  
  # get the number of records
  nrecs <- nrow(DT_uuid)
  
  # get the datetimes of the first and last data fields
  first <- readUTCmilliseconds(min(DT_uuid[]$time))
  last  <- readUTCmilliseconds(max(DT_uuid[]$time))
  
  # build a data.table to return
  return(data.table(uuid  = this_uuid,
                    count = nrecs,
                    first = first,
                    last  = last)
  )
  
}

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


