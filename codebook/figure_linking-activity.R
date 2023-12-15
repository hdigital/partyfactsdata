library(lubridate)
library(tidyverse)


# download and read Party Facts mapping table
if (!exists("pf_raw")) {
  url <- "https://partyfacts.herokuapp.com/download/external-parties-csv/"
  pf_raw <- read_csv(url, guess_max = 50000)
}

pf <-
  pf_raw %>%
  select(linked) %>%
  mutate(
    linked = ymd_hms(linked),
    year = year(linked) %>% factor() %>% fct_rev(),
    month = month(linked) %>% factor()
  ) %>%
  count(year, month, name = "linked") %>%
  drop_na()

pl <-
  ggplot(pf, aes(x = month, y = year, size = linked)) +
  geom_point(colour = "cornflowerblue") +
  labs(
    title = "Party Facts linking activity",
    subtitle = "Number of parties linked per month"
  ) +
  theme_bw()


ggsave("figure_linking-activity.png", pl, width = 8, height = 6)
print(pl)
