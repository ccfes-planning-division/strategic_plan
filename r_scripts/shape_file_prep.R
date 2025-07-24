library(tidyverse)
library(sf)
library(leaflet)
library(leaflet.extras)

crs_nad83 <- 2240
crs_wgs84 <- 4326

### functions

herons_risk_score <- function(probability, impact, consequences) {
  sqrt(((probability*consequences)^2)/2 +
         ((consequences*impact)^2)/2 +
         ((impact*probability)^2)/2)
}

### Shape Files

# districts

gis_districts_sf <- read.csv('./datasets/gis_districts.csv') %>%
  st_as_sf(wkt = 'shape_wkt', crs = crs_nad83) %>%
  st_transform(crs_wgs84)

# stations

gis_stations_sf <- read.csv('./datasets/gis_stations.csv') %>%
  st_as_sf(wkt = 'shape_wkt', crs = crs_nad83) %>%
  st_transform(crs_wgs84)

# station territories

gis_station_territories_sf <- read.csv('./datasets/gis_station_territories.csv') %>%
  st_as_sf(wkt = 'shape_wkt', crs = crs_nad83) %>%
  st_transform(crs_wgs84)



