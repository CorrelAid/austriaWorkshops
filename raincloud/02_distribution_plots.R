# Weekly Visualisations 2022-10-18
# Raincloud Plots

# based on https://www.cedricscherer.com/2021/06/06/visualizing-distributions-with-raincloud-plots-and-how-to-create-them-with-ggplot2/

# Distribution plots - election results Van der Bellen

library(tidyverse)
library(gghalves)
# more info gghalves https://erocoar.github.io/gghalves/
library(ggdist)
# info ggdist https://mjskay.github.io/ggdist/

# import dataset

data <- readRDS("data/data_BP_election.rds")

## Histogramm
data %>% 
  filter(sprengl == TRUE) %>%
  filter(str_detect(candidate, "Bellen")) %>% 
  ggplot(aes(x = result_pct)) +
  geom_histogram()

## Histogramm by Bundesländer
data %>% 
  filter(sprengl == TRUE) %>%
  filter(str_detect(candidate, "Bellen")) %>% 
  ggplot(aes(x = result_pct)) +
  geom_histogram() + 
  facet_wrap(vars(bland))

## Density plot by Bundesländer

## Histogramm by Bundesländer
data %>% 
  filter(sprengl == TRUE) %>%
  filter(str_detect(candidate, "Bellen")) %>% 
  ggplot(aes(x = result_pct)) +
  geom_density() + 
  facet_wrap(vars(bland))

## Boxplots by Bundesländer
data %>% 
  filter(sprengl == TRUE) %>%
  filter(str_detect(candidate, "Bellen")) %>% 
  ggplot(aes(y = result_pct,
             x = bland)) +
  geom_boxplot()

## Scatterplot by Bundesländer

data %>% 
  filter(sprengl == TRUE) %>%
  filter(str_detect(candidate, "Bellen")) %>% 
  ggplot(aes(y = result_pct,
             x = bland,
             color = wahlkarte)) +
  geom_jitter()


## combining plots - Raincloud plot
## Raincloud plot

data %>% 
  filter(sprengl == TRUE) %>%
  filter(str_detect(candidate, "Bellen")) %>% 
  ggplot(aes(y = result_pct, 
             x = bland, 
             fill = bland)) +
  gghalves::geom_half_point_panel(
    aes(color = wahlkarte),
    ## draw jitter on the left
    side = "l", 
    ## control range of jitter
    range_scale = .4, 
    ## add some transparency
    alpha = .3  
  ) +
  ggdist::stat_halfeye(
    adjust = .33, 
    width = .55, 
    color = NA, 
    position = position_nudge(x = .14)
  ) +
  geom_boxplot(
    width = .15, 
    outlier.shape = NA, fill = "white") +
  scale_y_continuous(breaks=c(0, 25, 50, 75, 100)) +
  theme_minimal() +
  labs(x = "",
       y = "votes (%)",
       title = "Austrian Presidential Election 2022",
       subtitle = "Votes for Alexander Van der Bellen by electoral districts (postal voting in turquoise)") +
  theme(legend.position = "none")

## add additional statistical info

stat_box_data <- function(y, 
                          upper_limit = max(y)) {
  return( 
    data.frame(
      y = 1.25 * upper_limit,
      label = paste('count =', length(y), '\n',
                    'mean =', round(mean(y), 1), '\n')
    )
  )
}

data %>% 
  filter(sprengl == TRUE) %>%
  filter(str_detect(candidate, "Bellen")) %>% 
  ggplot(aes(y = result_pct, 
             x = bland, 
             fill = bland)) +
  gghalves::geom_half_point_panel(
    aes(color = wahlkarte),
    ## draw jitter on the left
    side = "l", 
    ## control range of jitter
    range_scale = .4, 
    ## add some transparency
    alpha = .3  
  ) +
  ggdist::stat_halfeye(
    adjust = .33, 
    width = .55, 
    color = NA, 
    position = position_nudge(x = .14)
  ) +
  geom_boxplot(
    width = .15, 
    outlier.shape = NA, fill = "white") +
  stat_summary(fun.data = stat_box_data, 
               geom = "text",
               hjust = 0.5,
               vjust = 0.9) +
  scale_y_continuous(breaks=c(0, 25, 50, 75, 100)) +
  theme_minimal() +
  labs(x = "",
       y = "Time remaining to next election (%)")+
  theme(legend.position = "none") +
  labs(x = "",
       y = "votes (%)",
       title = "Austrian Presidential Election 2022",
       subtitle = "Votes for Alexander Van der Bellen by electoral districts (postal voting in turquoise)") +
  theme(legend.position = "none")


