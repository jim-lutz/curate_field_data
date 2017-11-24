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


get_dt_uuid <- function(uuid_num,ll_data) {
  # function to return one uuid from a ll_data Rsmap data structure as a data.table
  # uuid_num is a number corresponding to 
  # "flowA"     "tempA"     "sensorA"   "flowB"     "tempB"     "sensorB"   "batt_volt"
  
  eval(parse( text = paste0("data.table(",
                            "time = ll_data[[uuid_num]][[1]]$time,",
                            eval(datastreams[uuid_num])," = ll_data[[uuid_num]][[1]]$value)" 
  )
  )
  )
  
}

