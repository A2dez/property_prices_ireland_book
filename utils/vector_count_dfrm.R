library(magrittr)
library(dplyr)

vector_count_dfrm <- function(character_column) {
  character_column %>% 
    table(useNA = 'ifany')  %>% 
    as.data.frame() %>%
    select(group = '.', count = Freq)  %>%
    arrange(count %>% desc)
}