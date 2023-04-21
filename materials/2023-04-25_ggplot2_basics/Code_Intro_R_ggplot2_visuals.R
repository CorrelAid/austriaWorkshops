# title: "Introduction into data visualisation with R & ggplot2"
# author: "Felix - CorrelAid Austria"
# date: 2023-04-24



# first time using the packages, you need to install them
#install.packages("tidyverse")
#install.packages("palmerpenguins")

# load packages
library(tidyverse) # loads also ggplot2
library(palmerpenguins) # our data for today


# explore data
glimpse(penguins)
head(penguins, n=3)


# Syntax of ggplot2

## bar plot - one variable

ggplot(data = penguins) +
  geom_bar(mapping = aes(x = species))

## bar plot - multiple variables

ggplot(data = penguins) +
  geom_bar(mapping = aes(x = species, fill = island))


ggplot(data = penguins) +
  geom_bar(mapping = aes(x = species, fill = island),
           position = "dodge")

ggplot(data = penguins) +
  geom_bar(mapping = aes(x = species, fill = island),
           position = "fill")

## plot distributions

ggplot(data = penguins) +
  geom_boxplot(mapping = aes(y = body_mass_g))

ggplot(data = penguins) +
  geom_boxplot(mapping = aes(y = body_mass_g, x = species))

## plot multiple numeric variables

ggplot(data = penguins) +
  geom_point(mapping = aes(y = body_mass_g, x = flipper_length_mm)) +
  stat_smooth(mapping = aes(y = body_mass_g, x = flipper_length_mm), method = "lm",geom = "smooth")

ggplot(data = penguins, mapping = aes(y = body_mass_g, x = flipper_length_mm)) +
  geom_point() +
  stat_smooth(method = "lm",geom = "smooth")

ggplot(data = penguins, mapping = aes(y = body_mass_g, x = flipper_length_mm, colour = species)) +
  geom_point() +
  stat_smooth(method = "lm",geom = "smooth")

## adding labels

ggplot(data = penguins, mapping = aes(y = body_mass_g, x = flipper_length_mm, colour = species)) +
  geom_point() +
  stat_smooth(method = "lm",geom = "smooth") +
  labs(title = "Do heavier penguins have longer flippers?",
       x = "lenght of flipper in mm",
       y = "weight in g",
       colour = "penguin species",
       caption  = "Data from palmerpenguins package")

## now it is your turn

### Use the R script from github <https://github.com/CorrelAid/austriaWorkshops/blob/main/materials/2023-04-25_ggplot2_basics>
### Adapt the code and plot the relationship between penguins' bill length and bill depth

