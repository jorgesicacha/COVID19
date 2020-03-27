###########################
## COVID19 Data Analysis ##
###########################

## First dataset: coronastatus.no ##
## Reading from API ##

library(httr)
library(jsonlite)
library(raster)
library(pbapply)
library(ggplot2)
library(ggspatial)
library(plyr)

options(stringsAsFactors = FALSE)
## Aggregated data @ postcode level ##

## List of postcodes ##
postcodesshp <- shapefile("/Users/jorgespa/Documents/Research/CORONA/PostCodeArea_Clipped.shp")
postcodesshp
postcodeinfo <- postcodesshp@data
postnummer <- unique(postcodeinfo$POSTNUMMER)

## Retrieving data ##
aggdata <- function(postnummer){
raw0 <- GET(url="https://coronastatus.no",path=paste0("api/aggregated/",postnummer))
raw1 <- rawToChar(raw0$content)
raw2 <- fromJSON(raw1)
info <- do.call("cbind",raw2)
return(info)
}

data0 <- list()
for(i in 1:length(postnummer)){
  data0[[i]] <- aggdata(postnummer[i])
}
idxs <- which(lapply(data0, length)==6)
data <- as.data.frame(do.call("rbind",data0[idxs]))
data <- data[,-1]
names(data)[1] <- "POSTNUMMER"
data <- as.data.frame(apply(data,2,as.numeric))
postcodesshp@data <- join(postcodesshp@data,data,by="POSTNUMMER")
mapview(postcodesshp,zcol=c("numberOfReports","numberOfPeopleShowingSymptoms","numberOfConfirmedInfected","numberOfTested"))


## Reports ##
reports0 <- GET(url="https://coronastatus.no",path="api/reports/")
reports1 <- rawToChar(reports0$content)
reports2 <- fromJSON(reports1)
