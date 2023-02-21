# Weekly Visualisations 2022-10-18
# Raincloud Plots

# data transformation 

library(readxl)
library(tidyverse)

# import BP election 2022 data
data <- read_excel("data/vorlaeufiges_Gesamtergebnis_inkl_Briefwahl_BPW22_20221010.xlsx")

# create long dataset with two result variables (pct, abs)

## separate datasets
dat_abs <- data %>%
  select(-"%...8", -"%...10", -"%...12", -"%...14", -"%...16", -"%...18", -"%...20") %>% 
  rename(stimmen_abg = Stimmen,
         stimmen_ung = "...5",
         stimmen_guel = "...6") %>% 
  drop_na(Wahlberechtigte)


dat_pct <- data %>% 
  select(-"Dr. Michael Brunner",
         -"Gerald Grosz",
         -"Dr. Walter Rosenkranz",
         -"Heinrich Staudinger",
         -"Dr. Alexander Van der Bellen",
         -"Dr. Tassilo Wallentin",
         -"Dr. Dominik Wlazny") %>% 
  rename(stimmen_abg = Stimmen,
         stimmen_ung = "...5",
         stimmen_guel = "...6",
         "Dr. Michael Brunner" = "%...8",
         "Gerald Grosz" = "%...10",
         "Dr. Walter Rosenkranz" = "%...12",
         "Heinrich Staudinger" = "%...14",
         "Dr. Alexander Van der Bellen" = "%...16",
         "Dr. Tassilo Wallentin" = "%...18",
         "Dr. Dominik Wlazny" = "%...20") %>% 
  drop_na(Wahlberechtigte)

## longer datasets

dat_abs <- dat_abs %>% 
  pivot_longer(!c("GKZ", "Gebietsname","Wahlberechtigte", "stimmen_abg", "stimmen_ung", "stimmen_guel"),
               names_to = "candidate",
               values_to = "result_abs")

dat_pct <- dat_pct %>% 
  pivot_longer(!c("GKZ", "Gebietsname","Wahlberechtigte", "stimmen_abg", "stimmen_ung", "stimmen_guel"),
               names_to = "candidate",
               values_to = "result_pct")

## merge datasets

data <- left_join(dat_abs, dat_pct)

rm(dat_abs, dat_pct)

## create bundesland variable

bland_GKZ <- data %>% 
  filter(str_detect(GKZ, "0000") |
         str_detect(Gebietsname, "Wahlkarten -")) %>% 
  select(GKZ, Gebietsname) %>% 
  unique() %>% 
  print()

data <- data %>%
  mutate(bland = case_when(
    str_detect(GKZ, "G0") ~ "Österreich",
    str_detect(GKZ, "G1") ~ "Burgenland",
    str_detect(GKZ, "G2") ~ "Kärnten",
    str_detect(GKZ, "G3") ~ "Niederösterreich",
    str_detect(GKZ, "G4") ~ "Oberösterreich",
    str_detect(GKZ, "G5") ~ "Salzburg",
    str_detect(GKZ, "G6") ~ "Steiermark",
    str_detect(GKZ, "G7") ~ "Tirol",
    str_detect(GKZ, "G8") ~ "Vorarlberg",
    str_detect(GKZ, "G9") ~ "Wien")) %>% 
  mutate(bezirk = case_when(
    str_ends(GKZ, "00") & !str_ends(GKZ, "0000") ~ TRUE,
    TRUE ~ FALSE
  )) %>% 
  mutate(sprengl = case_when(
    !str_ends(GKZ, "00") & !str_ends(GKZ, "000") &!str_ends(GKZ, "0000") & !str_ends(GKZ, "0099") ~ TRUE,
    TRUE ~ FALSE
  )) %>% 
  mutate(wahlkarte = case_when(
    str_ends(GKZ, "99") ~ TRUE,
    TRUE ~ FALSE
  ))

# export data

saveRDS(data, "data/data_BP_election.rds")
write_csv(data, "data/data_BP_elections.csv")


