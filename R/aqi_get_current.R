#!/usr/bin/env Rscript

library(readr)
library(dplyr)
library(stringr)


source("https://raw.githubusercontent.com/dKvale/aqi-watch/master/R/aqi_convert.R")

# Fargo, Lacrosse, Voyageurs
border_sites <- c('380171004', '271370034', '550630012')

# Sioux Falls, Emmetsburg, Aberdeen
extra_sites  <- c('191471002', '460990008', '840460990009', '840460130004')

canada_sites <- c('000070118', '000070119', '000070203', '000064001')

year <- format(Sys.Date(), "%Y")

daylight_savings <- Sys.Date() > as.Date(paste0(year, "-03-12")) & Sys.Date() < as.Date(paste0(year, "-10-6"))

# Load credentials
credentials <- read_csv("../credentials.csv")

gmt_time <-  (as.numeric(format(Sys.time() - 195, tz="GMT", "%H")) - 1) %% 24

#######################################################################
# Hourly AQI data -- obtain the most recent hour of data
#######################################################################
aqi_all <- data.frame()

# Loop through 3 hours of records and keep most recent
for (i in 0:2) {

  time <- paste0("0", (gmt_time - i) %% 24) %>% substring(nchar(.) - 1, nchar(.))

  # Adjust date when searching back to previous day's results
  if(((gmt_time < 2) && (time > 20)) | gmt_time == 23) {
    date_time <- paste0(format(Sys.time() - (60 * 60 * 24), tz = "GMT", "%Y%m%d"), time)
  } else {
    date_time <- paste0(format(Sys.time(), tz = "GMT", "%Y%m%d"), time)
  }


  airnow_link <- paste0("https://s3-us-west-1.amazonaws.com//files.airnowtech.org/airnow/",
                        substring(date_time, 1, 4), "/",
                        substring(date_time, 1, 8), "/",
                        "HourlyData_", date_time, ".dat")

  aqi <- try(read_delim(airnow_link, "|",
                        col_names = F,
                        col_types = c('ccccdccdc')),
             silent = T)

  closeAllConnections()

  # If blank, try again in 5 minutes
  if(!is.data.frame(aqi) || (nrow(aqi) < 1)) {
    if(i == 0) {

      Sys.sleep(60 * 4)  # Pause for 5 minutes

      aqi <- try(read_delim(airnow_link, "|",
                            col_names = F,
                            col_types = c('ccccdccdc')),
                 silent = T)
    }
  }

  # Write to error log if AirNow data missing
  if (!is.data.frame(aqi) || (nrow(aqi) < 1)) {

    errs <- read.csv("log/error_log.csv", stringsAsFactors = F)

    errs$File <- as.character(errs$File)

    err_time <- as.character(format(Sys.time(), tz = "America/Chicago"))

    errs <- bind_rows(errs, data.frame(File    = date_time,
                                       Time    = err_time,
                                       Status  = "Failed",
                                       Message = paste0(aqi, collapse = ""), stringsAsFactors = F))

    write.csv(errs, "log/error_log.csv", row.names=F)

  } else {

    names(aqi) <- c("Date", "Time", "AqsID", "Site Name", "Local_Time" , "Parameter", "Units", "Concentration","Agency")

    aqi$Parameter <- gsub("[.]", "", aqi$Parameter)

    aqi$StateID <- substring(aqi$AqsID, 1, 2)

    # Filter to local results
    aqi <- filter(aqi, StateID %in% c('27', '19', '55', '38', '46', '84') |
                    AqsID %in% c(border_sites, canada_sites))

    # Keep all criteria pollutants
    aqi <- filter(aqi, toupper(Parameter) %in% c("CO", "NO2", "O3", "OZONE", "PM10", "PM25", "SO2"))

    aqi$Site_Param <- paste(aqi$AqsID, aqi$Parameter, sep = "_")

    aqi <- filter(aqi, !Site_Param %in% aqi_all$Site_Param)

    aqi_all <- bind_rows(aqi, aqi_all)

  }
}

#--------------------------------------------------------#
# Check for results
#--------------------------------------------------------#
if (nrow(aqi_all) < 1) return()

aqi <- aqi_all[ , 1:9]

# Adjust time to Central daylight time CDT
aqi$local <- as.POSIXct(paste(aqi$Date, aqi$Time), tz = "GMT", "%m/%d/%y %H:%M") %>% format(tz = "America/Chicago", usetz = TRUE)

#aqi$Time <- (as.numeric(gsub(":00", "", aqi$Time)) - 6 + daylight_savings) %% 24

aqi$Time <- as.POSIXlt(aqi$local, tz = "America/Chicago") %>% format(tz = "America/Chicago", format = "%H") %>% as.numeric()

aqi$Time <- paste0(aqi$Time, ":00")

aqi$Date <-  as.POSIXlt(aqi$local, tz = "America/Chicago") %>% as.Date() %>% format("%m/%d/%Y")

aqi$local <- NULL

aqi <- group_by(aqi, AqsID, Parameter) %>% mutate(AQI_Value = round(conc2aqi(Concentration, Parameter)))


#-- Get missing sites from China Air Quality site - aqicn.org
source("https://raw.githubusercontent.com/dKvale/aqi-watch/master/R/get_aqicn.R")

#-- Fargo
## fargo <- get_aqicn(country="usa", state="north-dakota", city="fargo-nw", param="pm25")
#-- Red Lake
## red_lake <- get_aqicn(country="usa", state="minnesota", city="red-lake-nation", param="pm25")

#-- Canada
winnipeg_ellen_pm25 <- tryCatch({get_aqicn(country="canada", state="manitoba", city="winnipeg-ellen-st.", param="pm25")}, error = function(e) {aqi[0, ]})
winnipeg_ellen_o3  <- tryCatch({get_aqicn(country="canada", state="manitoba", city="winnipeg-ellen-st.", param="o3")}, error = function(e) {aqi[0, ]})

winnipeg_scotia_pm25 <- tryCatch({get_aqicn(country="canada", state="manitoba", city="winnipeg-scotia-st.", param="pm25")}, error = function(e) {aqi[0, ]})
#winnipeg_scotia_o3   <- tryCatch({get_aqicn(country="canada", state="manitoba", city="winnipeg-scotia-st.", param="o3")}, error = function(e) {aqi[0, ]})

brandon_pm25 <- tryCatch({get_aqicn(country="canada", state="manitoba", city="brandon", param="pm25")}, error = function(e) {aqi[0, ]})
brandon_o3   <- tryCatch({get_aqicn(country="canada", state="manitoba", city="brandon", param="o3")}, error = function(e) {aqi[0, ]})

thunder_pm25 <-  tryCatch({get_aqicn(country="canada", state="ontario", city="thunder-bay", param="pm25")}, error = function(e) {aqi[0, ]})
thunder_o3   <-  tryCatch({get_aqicn(country="canada", state="ontario", city="thunder-bay", param="o3")}, error = function(e) {aqi[0, ]})

# Combine all
aqi <- bind_rows(aqi,
                 winnipeg_ellen_pm25, winnipeg_ellen_o3,
                 winnipeg_scotia_pm25, #winnipeg_scotia_o3,
                 brandon_pm25, brandon_o3,
                 thunder_pm25, thunder_o3)

# Add current time
aqi$Time_CST   <- as.character(format(Sys.time() + 10, tz = "America/Chicago"))

names(aqi)[11] <- as.character(format(Sys.time() + 10, tz = "America/Chicago"))

# Drop negative AQIs below 30
aqi <- filter(aqi, AQI_Value > -29)[ , -5]

# Set negative AQIs & concentrations to zero
aqi$AQI_Value     <- ifelse(aqi$AQI_Value < 0, 0, aqi$AQI_Value)

aqi$Concentration <- ifelse(aqi$Concentration < -5, 0, aqi$Concentration)


# Arrange from high to low
aqi <- arrange(ungroup(aqi), -AQI_Value)


locations <- read.csv('https://raw.githubusercontent.com/dKvale/aqi-watch/master/data-raw/locations.csv', stringsAsFactors = F,  check.names=F, colClasses = 'character')

#new_locations <- read_delim("https://s3-us-west-1.amazonaws.com//files.airnowtech.org/airnow/2021/20210716/monitoring_site_locations.dat",
#                            "|",
#                            col_names = F)

# Update Sioux Falls & Aberdeen, Milwaukee, Madison
locations <- locations %>%
  bind_rows(data.frame(AqsID = c("840380250004",
                                 "840460990009",
                                 "840550250047",
                                 "840550790068",
                                 "840551270006",
                                 "840460130004"

  ),
  "Site Name" = c("Lake Ilo",
                  "SF-USD",
                  "Madison University Ave",
                  "Milwaukee-UWM UPark",
                  "Elkhorn",
                  "Aberdeen"

  ),
  Lat   = c("47.34259",
            "43.59901",
            "43.07378",
            "43.09455",
            "42.66218",
            "45.4686"
  ),
  Long  = c("-102.646",
            " -96.78331",
            "-89.43595",
            " -87.90145",
            "-88.48703",
            "-98.49406"
  ),
  stringsAsFactors = F,
  check.names = F))

# Get MN site info
site_params <- read.csv('https://raw.githubusercontent.com/dKvale/aqi-watch/master/data-raw/site_params.csv', stringsAsFactors = F, check.names = F, colClasses = 'character')

mn_sites <- site_params %>%
            filter(substring(AqsID, 1, 2) == '27' | AqsID %in% border_sites)

# List of forecast sites for plotting model performance only includes sites with a monitor for that pollutant.
forecast_sites_pm25 <- filter(mn_sites, Parameter == "PM25")

forecast_sites_ozone <- filter(mn_sites, Parameter == "OZONE", AqsID != "271370034")



#--------------------------------------------------------#
# Update web map and tables                              #
#--------------------------------------------------------#

# Clean outstate names
aqi$Agency <- ifelse(grepl("Wisconsin", aqi$Agency), "Wisconsin DNR", aqi$Agency)

aqi$Agency <- ifelse(grepl("South Dakota", aqi$Agency), "South Dakota", aqi$Agency)

aqi$Agency <- ifelse(grepl("North Dakota", aqi$Agency), "North Dakota Health", aqi$Agency)

aqi_rank <- group_by(aqi, AqsID) %>% arrange(-AQI_Value) %>% mutate(rank = 1:n())

aqi_rank <- filter(ungroup(aqi_rank), rank == 1) %>% arrange(-AQI_Value)


# Save high sites table to test for changes on next cycle
write.csv(aqi_rank, "aqi_current.csv", row.names = F)


