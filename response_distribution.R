#!/usr/bin/env Rscript

library(patchwork)
library(here)
library(lubridate)
library(ggplot2)
library(tidyverse)

resultsTidy <- readRDS(here("../../../data/2024/resultsTidy.rds"))
poll_opening_day <- "2024-02-15"
poll_closing_day <- "2024-03-25"

plot_aesthetics <- function(gplot, ylabel = "", xticks = TRUE, legend = FALSE, bar = FALSE, xmin=ymd(as.Date(poll_opening_day)), xmax=ymd(as.Date(poll_closing_day))){
  gplot <- gplot +
    theme_bw() +
    xlab("") +
    ylab(ylabel)
  
  if(bar){
    gplot <- gplot +
      scale_x_date(limits=c(xmin-1, xmax+1), breaks = seq.Date(xmin, xmax, by="days"), labels = seq.Date(xmin, xmax, by="days"))
  } else{
    gplot <- gplot +
      scale_x_date(limits=c(xmin, xmax), breaks = seq.Date(xmin, xmax, by="days"), labels = seq.Date(xmin, xmax, by="days"))
  }
  
  if(xticks){
    gplot <- gplot +
      theme(axis.text.x = element_text(angle = 45, hjust=1))
  } else{
    gplot <- gplot +
      theme(axis.text.x = element_blank())
  }
  
  if(legend){
    gplot <- gplot +
      theme(legend.position = "bottom")
  } else{
    gplot <- gplot +
      theme(legend.position = "none")
  }
    
  return(gplot)
}

socialMedia <-data.frame(
  media = c("AnVIL-mailing-list", "X", "FH-Data Slack" , "X", "X", "X", "AnVIL-mailing-list", "X"),
  date = ymd(c("2024-02-15", "2024-02-15", "2024-02-16", "2024-02-26", "2024-03-05", "2024-03-11", "2024-03-13", "2024-03-14")))

echo(paste0("Unique days of advertisement (at least): ", length(unique(socialMedia$date)))) #7 unique days of advertisement

allDatesDf <- data.frame(date = ymd(seq.Date(as.Date(poll_opening_day), as.Date(poll_closing_day), by = "days")), count = 0)

responseDf <- resultsTidy %>% 
  select(Timestamp, InstitutionalAffiliation, UserType, FurtherSimplifiedDegrees) %>% 
  mutate(date = ymd(as_date(ymd_hms(Timestamp)))) %>% 
  group_by(date, InstitutionalAffiliation, UserType, FurtherSimplifiedDegrees) %>% 
  summarize(count = n())

toPlot <- right_join(responseDf, allDatesDf, by="date") %>%
  mutate(count = coalesce(count.x, count.y)) %>% #this is setting days without a timestamp to 0 and adding a 0 to days with responses
  select(!c(count.x, count.y)) 

#Raw Daily Response Count
p1 <- toPlot %>%
  ungroup() %>%
  select(date, count) %>%
  group_by(date) %>%
  summarize(daily_count = sum(count)) %>%
  ggplot(aes(x = date, y = daily_count)) +
  geom_point() + 
  geom_line()

p1 <-  plot_aesthetics(p1, ylabel = "Daily Response Count", xticks = FALSE)

ggsave(here("../../plots/2024/raw_daily_response_count.png"), plot = p1)

#Advertisements subpanel
p2 <- left_join(allDatesDf, socialMedia, by='date', relationship = "many-to-many") %>%
  drop_na() %>%
  ggplot(aes(x = date, y = -1, color = media)) +
  geom_jitter(width=0, height=0.2)

p2 <- plot_aesthetics(p2, ylabel = "Recruitment", legend = TRUE) +
  theme(axis.text.y = element_blank(),
        axis.ticks.y = element_blank())

combo_plot <- p1 / p2 + plot_layout(heights = c(3,1))

ggsave(here("../../plots/2024/daily_response_count_with_adverts.png"), plot = combo_plot)

#Daily Count split out by Institutional Affiliations
p3 <- toPlot %>%
  ungroup() %>%
  select(date, InstitutionalAffiliation, count) %>%
  group_by(date, InstitutionalAffiliation) %>%
  summarize(daily_inst_count = sum(count)) %>%
  drop_na() %>%
  ggplot(aes(x = date, y = daily_inst_count, fill = InstitutionalAffiliation)) +
  geom_bar(stat="identity")

p3 <- plot_aesthetics(p3, ylabel = "Institutional Responses", bar = TRUE)

ggsave(here("../../plots/2024/daily_response_county_by_inst.png"), plot = p3)

#Daily Count split out by usertype

p4 <- toPlot %>%
  ungroup() %>%
  select(date, UserType, count) %>%
  group_by(date, UserType) %>%
  summarize(daily_usertype_count = sum(count)) %>%
  ggplot(aes(x = date, y = daily_usertype_count, fill = UserType)) +
  geom_bar(stat = "identity")

p4 <- plot_aesthetics(p4, ylabel = "Usertype Responses", legend = TRUE, bar = TRUE)

ggsave(here("../../plots/2024/daily_response_count_by_usertype.png"), plot = p4)

#Daily count split out by degree type

p5 <- toPlot %>%
  ungroup() %>%
  select(date, FurtherSimplifiedDegrees, count) %>%
  group_by(date, FurtherSimplifiedDegrees) %>%
  summarize(daily_degree_count = sum(count)) %>%
  ggplot(aes(x = date, y=daily_degree_count, fill = FurtherSimplifiedDegrees)) +
  geom_bar(stat = "identity")

p5 <- plot_aesthetics(p5, ylabel = "Degree Type Responses", legend = TRUE, bar = TRUE)

ggsave(here("../../plots/2024/daily_response_count_by_degree.png"), plot = p5)
  
## Stats
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

responses_only <- toPlot %>%
  ungroup() %>%
  select(date, count) %>%
  group_by(date) %>%
  summarize(daily_count = sum(count))

responses_only_nz <- responses_only %>%
  filter(daily_count >=1) #filter out days with a response count of 0

most_common <- Mode(responses_only$daily_count)
echo(paste0("Most common daily response count: ", most_common)) #0
echo(paste0("Number of days with 0 reponses : ", sum(responses_only$daily_count == most_common)))#21 days with 0 responses

most_common_withoutZeros <- Mode(responses_only_nz$daily_count)
echo(paste0("Most common daily response count (ignoring days without responses): ", most_common_withoutZeros)) #1
echo(paste0("Number of days with ", most_common_withoutZeros, " responses: ", sum(responses_only$daily_count == most_common_withoutZeros))) #8 days with 1 response

echo(paste0("Average daily response count: ", mean(responses_only$daily_count))) #1.25

