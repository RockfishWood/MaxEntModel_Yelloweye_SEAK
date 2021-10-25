#An R Script for Preparing Data for MaxEnt##################################################
#Code from: https://www.azavea.com/blog/2018/10/09/preparing-data-for-maxent-species-distribution-modeling-using-r/

#There are five steps required in the script to prepare your data for use in MaxEnt. #######
# 1 Set up your R packages and libraries
# 2 Set up some parameters you'll use to make your data uniform
# 3 Read your data into R
# 4 Resample and extend your data using the parameters from step 2
# 5 Write your data out into a .asc format

# 1 Set up your R packages and libraries######################################

# install necessary packages and libraries
install.packages("raster")
install.packages("rgdal")
install.packages("sf")
install.packages("tidyverse")
install.packages("fasterize")
library(sf)
library(raster)
library(rgdal)
library(tidyverse)
library(rgeos)
library(scales)
library(fasterize)

setwd("D:/Predictors")

# 2 Set up some parameters you'll use to make your data uniform#######################

# set up projection parameter for use throughout script
projection <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

#set up extent parameter for use throughout script (the following are for all of SEAK)
ext <- extent(-140, -133, 54, 60)

# 3 Read your data into R#############################################################
#>>RASTER DATA##########################################################################

#R can read in many types of raster data, but generally, a TIFF is easiest to work 
#with. Let's take a look at the full code for reading in and manipulating the 
#elevation data, and then break it down.

#Process for Environmental Variable 1 - Elevation

# READ IN RASTER DATA
#The first part of this script takes data from your computer and 
#reads it into R. The name of the data to be read in is given by 
#"bathy_extract.tif" - be sure to use the full filenames for your data, 
#enclosed in quotes, as seen here. I use that data to create an R 
#raster object called bath_raw.

assign(paste0("bath_", "raw"), raster("bathy_extract.tif"))

# REPROJECT TO OUR SHARED PARAMETER

#The second section of code reprojects bath_raw using the parameter 
#we created and makes that into a new raster object, bath_projected. 
#Then we rename bath_projected to bath_final, and extend bath_final 
#to our extent parameter and call that bath_extended. The "gaps" 
#between our elevation dataset's original extent and our chosen "ext" 
#extent are filled in by NA values so that they do not distort the data.

#____BATHY DATA##########################################################
assign(paste0("bath_", "projected"),
       projectRaster(bath_raw, crs=projection))

# create variable equal to final raster
assign(paste0("bath_final"), bath_projected)

# extend bath_final to the desired extent with NA values
bath_extended <- extend(bath_final, ext, value=NA)

#____ASPECT DATA##########################################################
assign(paste0("aspect_", "raw"), raster("aspect.tif"))

assign(paste0("aspect_", "projected"),
       projectRaster(aspect_raw, crs=projection))

# create variable equal to final raster
assign(paste0("aspect_final"), aspect_projected)

# extend bath_final to the desired extent with NA values
aspect_extended <- extend(aspect_final, ext, value=NA)

#____BPI DATA##########################################################
assign(paste0("BPI_", "raw"), raster("BPI_Extract.tif"))

assign(paste0("BPI_", "projected"),
       projectRaster(BPI_raw, crs=projection))

# create variable equal to final raster
assign(paste0("BPI_final"), BPI_projected)

# extend bath_final to the desired extent with NA values
BPI_extended <- extend(BPI_final, ext, value=NA)

#____Chlorophyll DATA##########################################################
assign(paste0("chlorophyll_", "raw"), raster("chlorophyll_resampled_extract2.tif"))

assign(paste0("chlorophyll_", "projected"),
       projectRaster(chlorophyll_raw, crs=projection))

# create variable equal to final raster
assign(paste0("chlorophyll_final"), chlorophyll_projected)

# extend bath_final to the desired extent with NA values
chlorophyll_extended <- extend(chlorophyll_final, ext, value=NA)

#____RUGGEDNESS (VRM) DATA##########################################################
assign(paste0("VRM_", "raw"), raster("Ruggedness_Extract.tif"))

assign(paste0("VRM_", "projected"),
       projectRaster(VRM_raw, crs=projection))

# create variable equal to final raster
assign(paste0("VRM_final"), VRM_projected)

# extend bath_final to the desired extent with NA values
VRM_extended <- extend(VRM_final, ext, value=NA)

#____SLOPE DATA##########################################################
assign(paste0("Slope_", "raw"), raster("Slope.tif"))

assign(paste0("Slope_", "projected"),
       projectRaster(Slope_raw, crs=projection))

# create variable equal to final raster
assign(paste0("slope_final"), Slope_projected)

# extend bath_final to the desired extent with NA values
Slope_extended <- extend(slope_final, ext, value=NA)

#____SALINITY DATA##########################################################
assign(paste0("Salinity_", "raw"), raster("Salinity_Resample_Bilinear_2.tif"))

assign(paste0("Salinity_", "projected"),
       projectRaster(Salinity_raw, crs=projection))

# create variable equal to final raster
assign(paste0("salinity_final"), Salinity_projected)

# extend bath_final to the desired extent with NA values
Salinity_extended <- extend(salinity_final, ext, value=NA)

#BREAK############################################################################
#>>VECTOR FORMAT##############
#Now let's take a look at the code necessary to read in and manipulate 
#data that is in vector format (i.e., Population Location Data):

# process for Environmental Variable 2 - Vegetation Community

#read in spatial data
#assign(paste0("vegcommunity, "_raw"),
#sf::st_read(dsn="FOLDER NAME", layer="vegcommunity"))

# convert new spatial vector data to raster
#require(raster)
#hold.raster <- raster()
#extent(hold.raster) <- extent(vegcommunity_raw)
#res(hold.raster) <- 20
#assign(paste0("veg", "_rasterized"),
#  fasterize(vegcommunity_raw, hold.raster, 'ATTRIBUTE'))

# reproject to our shared parameter
#assign(paste0("veg_", "projected"),
#  projectRaster(veg_rasterized,crs=projection))

# create variable equal to final raster
#assign(paste0("vegcommunity_final"), veg_projected)

#BREAK#####################################################################################

# 4 Resample and extend your data using the parameters from step 2###########

#Pick one of your variables to use as a basis for resampling. 
#This means that the others will all be forced to share its resolution. 
#If you aren't worried about processing time and don't mind larger file sizes, 
# pick the variable with the smallest pixels (highest resolution). 
#If you want quick processing and small files, pick the variable with 
#the largest pixels. In this case, I'll choose bathy_final as my basis for resampling.

bathy_final_re <- resample(bath_final, bath_final)

aspect_final_re <- resample(aspect_final, bath_final)

slope_final_re <- resample(slope_final, bath_final)

chloro_final_re <- resample(chlorophyll_final, bath_final)

salinity_final_re <- resample(salinity_final, bath_final)

BPI_final_re <- resample(BPI_final, bath_final)

VRM_final_re <- resample(VRM_final, bath_final)

#Next, we have to re-extend the datasets to make sure that their 
#shared extent was not influenced by the resampling.

bathy_tend <- extend(bathy_final_re, ext, value=NA)

aspect_tend <- extend(aspect_final_re, ext, value=NA)

slope_tend <- extend(slope_final_re, ext, value=NA)

chloro_tend <- extend(chloro_final_re, ext, value=NA)

salinity_tend <- extend(salinity_final_re, ext, value=NA)

BPI_tend <- extend(BPI_final_re, ext, value=NA)

VRM_tend <- extend(VRM_final_re, ext, value=NA)

# 5 Write your data out into a .asc format######################################

#Now we have five datasets that are identical in extent, resolution, 
#and many other properties. Our final step is to write out these 
#environmental datasets into the .asc format that the MaxEnt GUI uses.

writeRaster(bathy_tend, filename="bathy.asc", format="ascii", overwrite=TRUE)

writeRaster(aspect_tend, filename="aspect.asc", format="ascii", overwrite=TRUE)

writeRaster(slope_tend, filename="slope.asc", format="ascii", overwrite=TRUE)

writeRaster(chloro_tend, filename="chloro.asc", format="ascii", overwrite=TRUE)

writeRaster(salinity_tend, filename="salinity.asc", format="ascii", overwrite=TRUE)

writeRaster(BPI_tend, filename="BPI.asc", format="ascii", overwrite=TRUE)

writeRaster(VRM_tend, filename="VRM.asc", format="ascii", overwrite=TRUE)