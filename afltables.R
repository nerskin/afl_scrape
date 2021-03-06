## ----message=FALSE-------------------------------------------------------
library(tidyverse)
library(rvest)
season <- read_html('https://afltables.com/afl/seas/2017.html')

## ------------------------------------------------------------------------
process_match_description <- function(x){
  home_team <- x[1,1]
  away_team <- x[2,1]
  home_score <- x[1,3]
  away_score <- x[2,3]
  metadata_string <- x[1,4] #includes date, time, attendance, venue
  venue <- str_extract(metadata_string,'Venue:.*$') %>%
    str_replace('Venue: ','')
  attendance <- str_extract(metadata_string,'Att: [0-9,]+') %>% str_replace('Att: ','') %>% str_replace(',','') %>% as.numeric()
  date <- str_extract(metadata_string,'[0-9]{1,2}-[A-Z][a-z]{2}-[0-9]{4}') %>% lubridate::dmy()
  tibble(home=home_team,away=away_team,home_score=home_score,away_score=away_score,venue=venue,attendance=attendance,date=date)
}

## ------------------------------------------------------------------------
get_season_results <- function(year){
  url <- paste0('https://afltables.com/afl/seas/',year,'.html')
  season <- read_html(url)
  results <- html_table(season,fill=TRUE)
  results <- results %>%
  keep(~all(dim(.x)==c(2,4))) %>%
  map(process_match_description)
results <- bind_rows(results)
results
}

## ------------------------------------------------------------------------
results <- map(2010:2018,get_season_results) %>%
  bind_rows

