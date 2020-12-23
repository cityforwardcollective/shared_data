library(tidyverse)
library(wisconsink12)

mke_schools <- make_mke_schools() %>%
  write_csv(., "Data/milwaukee_schools.csv")

mke_rc <- make_mke_rc() %>%
  write_csv(., "Data/milwaukee_report_cards.csv")
  
mke_schools <- mke_schools %>% 
  filter(broad_agency_type != "Private")

mke_enr <- enrollment %>% 
  filter(group_by_value == "All Students") %>% 
  right_join(., mke_schools %>% select(dpi_true_id, school_name, accurate_agency_type, school_year))

mke_enrollment_aat <- mke_enr %>% 
  select(school_year, dpi_true_id, school_name, accurate_agency_type, total_enrollment = student_count) %>% 
  bind_rows(., other_enrollment %>% select(-broad_agency_type))


  group_by(school_year, accurate_agency_type) %>% 
    summarise(total_enrollment = sum(total_enrollment, na.rm = TRUE))
  

mpcp_snsp <- choice_counts %>% 
  filter(MPCP_count > 0) %>%
  select(dpi_true_id, school_year, school_name,
         MPCP = MPCP_count, SNSP = SNSP_count) %>%
  pivot_longer(cols = 4:5, names_to = "accurate_agency_type", values_to = "total_enrollment")



mke_enrollment_aat <- bind_rows(mke_enrollment_aat, mpcp_snsp) %>%
  write_csv(., "Data/milwaukee_enrollment.csv")
