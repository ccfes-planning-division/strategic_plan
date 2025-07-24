# This script maps the census data (block group polygons) to the station district, station territory, and FDZs
# Standard areal weighting method was chosen.
# Census values are mapped proportionally to Cobb polygons with an assumption of a uniform distribution.
# For example, if two or more station territories share a census group block, the proportions will be calculated based on land area.
# Assume that 30% of the block group belongs to station A, 30% belongs to station B, and 40% belongs to station C
# If the census block group has a population of 1000 people, then it will contribute 300 to station A, 300 to station B, and 400 to station C

library(tidyverse)
library(sf)

source("./r_scripts/shape_file_prep.R")
source("./r_scripts/census_prep.R")

#' Area‑weighted interpolation of ACS estimates & MOEs
#'
#' @param census_sf sf with census polygons; colnames ending in `_estimate` and `_moe`
#' @param target_sf sf with target zones; must contain grouping variables
#' @param group_cols unquoted names of columns in target_sf to group by (e.g. c(battalion, station_number))
#' @param crs_equal_area numeric EPSG code for equal‑area projection (default 5070)
#' @return A tibble with one row per group and summed <var>_estimate and <var>_moe (90% CI).
census_areal_interpolation <- function(census_sf,
                                       target_sf,
                                       group_cols,
                                       crs_equal_area = 5070) {
  target_crs <- st_crs(target_sf)
  estimate_cols <- census_sf %>% select(ends_with("_estimate")) %>% names()
  moe_cols      <- census_sf %>% select(ends_with("_moe"))      %>% names()
  
  census_sf <- census_sf %>%
    st_transform(crs_equal_area) %>%
    mutate(census_geo_area = st_area(geometry))
  
  target_sf <- target_sf %>%
    st_transform(crs_equal_area)
  
  hits <- st_intersects(census_sf, target_sf)
  census_sf <- census_sf[lengths(hits) > 0, ]
  target_sf <- target_sf[unique(unlist(hits)), ]
  
  census_sf <- st_make_valid(census_sf)
  target_sf <- st_make_valid(target_sf)
  
  intersection_sf <- st_intersection(census_sf %>% select(GEOID, census_geo_area), target_sf) %>%
    mutate(
      intersection_area = st_area(geometry),
      prop_census_geo_in_target_geo = as.numeric(intersection_area / census_geo_area)
    ) %>%
    left_join(st_drop_geometry(census_sf %>% select(-census_geo_area)), by = "GEOID") %>%
    mutate(
      across(
        all_of(estimate_cols),
        ~ . * prop_census_geo_in_target_geo,
        .names = "{.col}_w"
      ),
      across(
        all_of(moe_cols),
        ~ . * prop_census_geo_in_target_geo,
        .names = "{.col}_w"
      )
    )
  
  intersection_sf %>%
    group_by(across(all_of(group_cols))) %>%
    summarise(
      across(matches("_estimate_w$"), sum, .names = "{.col}"),
      across(matches("_moe_w$"), ~ sqrt(sum(.^2, na.rm = TRUE)), .names = "{.col}"),
      .groups = "drop"
    ) %>%
    mutate(area = st_area(geometry)) %>%
    st_transform(crs = target_crs)
}


station_territory_census_sf <- census_areal_interpolation(
  census_sf = cobb_census_bg_wide_sf,
  target_sf = gis_station_territories_sf,
  group_cols = c("battalion", "station_number")
) %>%
  mutate(
    area_sqmi = area / 2.589988e6,
    population_density_sqmi = total_pop_estimate_w / area_sqmi,
    population_density_moe_sqmi = total_pop_moe_w / area_sqmi
  )

districts_census_sf <- census_areal_interpolation(
  census_sf = cobb_census_bg_wide_sf,
  target_sf = gis_districts_sf,
  group_cols = c("comm_d")
)  %>%
  mutate(
    area_sqmi = area / 2.589988e6,
    population_density_sqmi = total_pop_estimate_w / area_sqmi,
    population_density_moe_sqmi = total_pop_moe_w / area_sqmi
  )
