library(tidyverse)

pl_dt <- 
  map_int(
    fs::dir_ls(type = "directory"),
    ~ read_csv(glue::glue("{.}/{.}.csv")) %>% nrow()
  ) %>% 
  tibble(dataset = names(.), n = .) %>% 
  mutate(dataset = fct_reorder(dataset, n)) %>% 
  filter(n > 0) %>% 
  arrange(-n)

pl <- 
  ggplot(pl_dt, aes(x = dataset, y = n)) +
  geom_bar(stat = "identity") +
  coord_flip()

print(pl)
ggsave("pf-data.png", pl, width = 20, height = 15, units = "cm")
