# census_prep.R downloads selected census variables at the block group level (very fine detail)
# The block group level was chosen for the most accurate values when mapped to other polygons (station territories, districts, etc)


library(tidycensus)
library(dplyr)
library(tidyr)

### Paramaters and options
readRenviron("~/.Renviron")
options(tigris_use_cache = TRUE)
year <- 2023


# Available census variables
census_vars_df <- load_variables(year   = year,
                                 dataset = "acs5",
                                 cache   = TRUE)

# selected census variables
census_selected_vars <- c(
  # Population
  total_pop               = "B01003_001",
  
  ### MALES ###
  male_total = "B01001_002",
  male_under5 = "B01001_003",
  male_5_9 = "B01001_004",
  male_10_14 = "B01001_005",
  male_15_17 = "B01001_006",
  male_18_19 = "B01001_007",
  male_20 = "B01001_008",
  male_21 = "B01001_009",
  male_22_24 = "B01001_010",
  male_25_29 = "B01001_011",
  male_30_34 = "B01001_012",
  male_35_39    = "B01001_013",
  male_40_44    = "B01001_014",
  male_45_49    = "B01001_015",
  male_50_54    = "B01001_016",
  male_55_59    = "B01001_017",
  male_60_61    = "B01001_018",
  male_62_64    = "B01001_019",
  male_65_66    = "B01001_020",
  male_67_69    = "B01001_021",
  male_70_74    = "B01001_022",
  male_75_79    = "B01001_023",
  male_80_84    = "B01001_024",
  male_85_plus  = "B01001_025",
  
  ### FEMALES ###
  female_total    = "B01001_026",
  female_under5   = "B01001_027",
  female_5_9      = "B01001_028",
  female_10_14    = "B01001_029",
  female_15_17    = "B01001_030",
  female_18_19    = "B01001_031",
  female_20       = "B01001_032",
  female_21       = "B01001_033",
  female_22_24    = "B01001_034",
  female_25_29    = "B01001_035",
  female_30_34    = "B01001_036",
  female_35_39    = "B01001_037",
  female_40_44    = "B01001_038",
  female_45_49    = "B01001_039",
  female_50_54    = "B01001_040",
  female_55_59    = "B01001_041",
  female_60_61    = "B01001_042",
  female_62_64    = "B01001_043",
  female_65_66    = "B01001_044",
  female_67_69    = "B01001_045",
  female_70_74    = "B01001_046",
  female_75_79    = "B01001_047",
  female_80_84    = "B01001_048",
  female_85_plus  = "B01001_049",
  
  # Hispanic or Latino
  hispanic_pop            = "B03003_003",
  
  # Race (B02001)
  white_pop               = "B02001_002",
  black_pop               = "B02001_003",
  aian_pop                = "B02001_004",
  asian_pop               = "B02001_005",
  nhopi_pop               = "B02001_006",
  other_race_pop          = "B02001_007",
  two_plus_race_pop       = "B02001_008",
  
  # Language spoken at home (B16001)
  english_only            = "B16001_002",
  spanish_speaker         = "B16001_003",
  other_language_speaker  = "B16001_018",
  
  # Income & SES
  median_household_income = "B19013_001",
  per_capita_income       = "B19301_001",
  below_poverty_level = "B17010_002",
  households = "B19058_001",
  households_food_stamps = "B19058_002",
  households_no_food_stamps = "B19058_003",
  
  # Disability (B18101)
  total_with_disability   = "B18101_001",
  
  # Employment (B23025)
  labor_force = "B23025_003",
  employed_count = "B23025_004",
  unemployed_count = "B23025_005"
)

# Get census data 
cobb_census_bg_sf <- get_acs(
  geography = "block group",
  state     = "GA",
  county    = "Cobb",
  year      = year,
  survey    = "acs5",
  variables = census_selected_vars,
  geometry  = TRUE,
  moe_level = 90
)


cobb_census_bg_wide_sf <- cobb_census_bg_sf %>%
  select(GEOID, NAME, variable, estimate, moe) %>%
  pivot_wider(
    names_from  = variable,
    values_from = c(estimate, moe),
    names_glue = "{variable}_{.value}"
  )

