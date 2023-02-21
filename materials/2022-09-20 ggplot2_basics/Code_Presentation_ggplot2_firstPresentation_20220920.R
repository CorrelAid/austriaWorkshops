#clear environment
rm(list=ls())

# load packages
library(ggplot2)
library(dplyr)
library(patchwork)
library(tidyverse)

# load data
data("airquality")

# get summary statistics
summary(airquality)

# factorize Month variable
airquality$Month <- factor(airquality$Month, labels = c("May", "June", "July", "Aug", "Sep"))

# Examples of ggplot2 graphs (scatter plot)
ggplot(airquality) +
  geom_point(aes(x= Month, Wind))

# Examples of ggplot2 graphs (box plot)
ggplot(airquality) +
  geom_boxplot(aes(x = Month, Wind))

# aggregate the data (mean, standard deviation standard error 
# and Confidence Intervals)
airquality_summary <- airquality %>%
  group_by(Month) %>%
  summarise(
    meanwi = mean(Wind),
    sd = sd(Wind),
    se = sd(Wind) / sqrt(length(Wind))
  ) 

alpha = 0.05
t = 1.96  # for simplicity
airquality_summary$CI = t * airquality_summary$se


# simple bar plot
p1 <- 
  ggplot(airquality_summary, aes(x = Month, y = meanwi, fill = Month)) +
  geom_bar(stat = "identity", color = "black") +
  labs(title = "Mean Wind Force by Month (mph)", y = "", x = "") +
  theme_classic() +
  theme(legend.position = "none",
        title = element_text(size = 20, 
                             face = "bold")
  )

# bar plot with error bars (standard deviation)
p2 <-
  ggplot(airquality_summary, aes(x = Month, y = meanwi, fill = Month)) +
  geom_bar(stat = "identity", color = "black") +
  geom_errorbar(aes(ymin = meanwi - sd, ymax = meanwi + sd), 
                width = 0.2 ) +
  labs(title = "Standard Deviation", y = "", x = "") +
  theme_classic() + theme(legend.position = "none")

# bar plot with error bars (standard error)
p3 <-
ggplot(airquality_summary, aes(x = Month, y = meanwi, fill = Month)) +
  geom_bar(stat = "identity", color = "black") +
  geom_errorbar(aes(ymin = meanwi - se, ymax = meanwi + se), 
                width = 0.2 ) +
  labs(title = "Standard Error", y = "", x = "") +
  theme_classic() + theme(legend.position = "none")

# bar plot with error bars (CI)
p4 <-
  ggplot(airquality_summary, aes(x = Month, y = meanwi, fill = Month)) +
  geom_bar(stat = "identity", color = "black") +
  geom_errorbar(aes(ymin = meanwi - CI, ymax = meanwi + CI), 
                width = 0.2 ) +
  labs(title = "Confidence Interval (alpha 0.05)", y = "", x = "") +
  theme_classic() + theme(legend.position = "none")

# combine the data with the patchwork package
p1 + p2 + p3 + p4 + 
  plot_annotation(
    caption = "Source: ggplot2 - dataset airquality"
  )

                