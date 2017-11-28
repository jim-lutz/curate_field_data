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

get_DT_uuid_data <- function(l_data){
  # function to read all the data from a single Rsmap data structure list.
  # l_data = List of 3
    # $ time : num [1:x] 
    # $ value: num [1:x]
    # $ uuid : chr 
  
  # return the data as a data.table with uuid as a field
  # not very efficient but puts everything in one record
  return(data.table( uuid = l_data$uuid, time = l_data$time, value = l_data$value))
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
