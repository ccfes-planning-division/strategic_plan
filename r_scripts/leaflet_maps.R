library(viridis) 

source('./r_scripts/census_areal_interpolation_prep.R')

### Custom formatting

fire_station_icon <- makeIcon(iconUrl = "./resources/icons/fire_station_icon.png",
                              iconWidth = 32,
                              iconHeight = 32)


### Maps

# District map

gis_district_pal <- colorFactor(palette = "Set3", domain  = gis_districts_sf$comm_d)

gis_district_leaflet <- leaflet(gis_districts_sf, width = "100%", height = "800px") %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(
    fillColor = ~ gis_district_pal(comm_d),
    color       = "#444444",
    weight      = 1,
    fillOpacity = 0.5,
    popup       = ~ paste0("<strong>District:</strong> ", comm_d)
  ) %>%
  addLegend(
    position = "bottomright",
    pal      = gis_district_pal,
    values   = ~ comm_d,
    title    = "District",
    opacity  = 1
  ) %>%
  addMarkers(
    data        = gis_stations_sf,
    icon = fire_station_icon,
    popup       = ~ paste0(dept," ", name)
  ) %>%
  addFullscreenControl(pseudoFullscreen = FALSE)


# Station territories map

color_list <- RColorBrewer::brewer.pal(5, "Set3")
gis_station_territories_pal <- colorFactor(
  palette = color_list,
  domain = unique(gis_station_territories_sf$station_number)
)

gis_station_territories_leaflet <- leaflet(gis_station_territories_sf,
                                           width = "100%",
                                           height = "800px") %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(
    fillColor   = ~ gis_station_territories_pal(station_number),
    color       = "#444444",
    weight      = 1,
    fillOpacity = 0.5,
    popup       = ~ paste0("<strong>Station Territory:</strong> ", station_number),
    label       = ~ station_number,
    highlightOptions = highlightOptions(
      weight = 3,
      color = "#666",
      bringToFront = TRUE
    )
  ) %>%
  addMarkers(
    data        = gis_stations_sf,
    icon = fire_station_icon,
    popup       = ~ paste0(dept," ", name)
  ) %>%
  addFullscreenControl(pseudoFullscreen = FALSE)


# Station territories population density map

station_territory_census_breaks <- pretty(station_territory_census_sf$population_density_sqmi, n = 10)

station_territory_census_pal <- colorBin(
  palette = viridis(256),
  na.color = "#CCCCCC",
  bins = station_territory_census_breaks,
  domain = station_territory_census_sf$population_density_sqmi
)

station_territory_census_leaflet <- leaflet(station_territory_census_sf,
                                           width = "100%",
                                           height = "800px") %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(
    fillColor   = ~ station_territory_census_pal(population_density_sqmi),
    color       = "#444444",
    weight      = 1,
    fillOpacity = 0.5,
    popup       = ~ paste0("Station ", station_number, 
                           "<br>Population Density: ", formatC(round(population_density_sqmi), big.mark=','), " ± ", round(population_density_moe_sqmi), " people/mi\u00B2",
                           "<br>Population: ", formatC(round(total_pop_estimate_w), format = "f", digits = 0, big.mark=','), " ± ", round(total_pop_moe_w),
                           "<br>Area: ", round(area_sqmi, 1), " mi\u00B2"
                           ),
    label       = ~ station_number,
    highlightOptions = highlightOptions(
      weight = 3,
      color = "#666",
      bringToFront = TRUE
    )
  ) %>%
  addLegend(
    position = "bottomright",
    pal      = station_territory_census_pal,
    values   = ~ population_density_sqmi,
    title    = "Population Density",
    opacity  = 1
  ) %>%
  addFullscreenControl(pseudoFullscreen = FALSE)
