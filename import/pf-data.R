library(tidyverse)

# use of magrittr pipe ('%>%') with placeholder ('.')
pl_dt <-
  map_int(
    fs::dir_ls(type = "directory"),
    ~ read_csv(glue::glue("{.}/{.}.csv")) %>% nrow()
  ) %>%
  tibble(dataset = names(.), parties = .) %>%
  mutate(dataset = fct_reorder(dataset, parties))

pl <-
  ggplot(pl_dt, aes(x = parties, y = dataset)) +
  geom_bar(stat = "identity")

print(pl)
ggsave("pf-data.png", pl, width = 20, height = 15, units = "cm")
