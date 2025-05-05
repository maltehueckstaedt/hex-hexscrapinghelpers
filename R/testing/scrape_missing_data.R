library(devtools)
library(janitor)
setwd("C:/Users/mhu/Documents/gitlab/hex-hexscrapinghelpers")
pkgload::load_all()
setwd("C:/Users/mhu/Downloads/Eberhard_Karls_Universitaet_Tuebingen/2024_S")

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# START DRIVER ---------------------------------------------
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

driver <- rsDriver(
  browser = "chrome",
  chromever = "latest",
  port = 1237L
)

rmdr <- driver[["client"]]
rmdr$maxWindowSize()

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# CHOOSE SEMESTER ------------------------------------------
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

rmdr <- rmdr
base_url <- "https://alma.uni-tuebingen.de/alma/pages/startFlow.xhtml?_flowId=searchCourseNonStaff-flow&_flowExecutionKey=e2s1"
sem_dropdown <- "#genericSearchMask\\:search_e4ff321960e251186ac57567bec9f4ce\\:cm_exa_eventprocess_basic_data\\:fieldset\\:inputField_3_abb156a1126282e4cf40d48283b4e76d\\:idabb156a1126282e4cf40d48283b4e76d\\:termSelect_label"
num_sem_selector <- 4 # 10 == SS2021 - je niederiger die Zahl, desto jünger das Semester: 9== WS21 usw.
num_courses_selector <- "#genSearchRes\\:id3f3bd34c5d6b1c79\\:id3f3bd34c5d6b1c79Navi2NumRowsInput"
num_courses <- "300"
search_field <- "#genericSearchMask\\:search_e4ff321960e251186ac57567bec9f4ce\\:cm_exa_eventprocess_basic_data\\:fieldset\\:inputField_0_1ad08e26bde39c9e4f1833e56dcce9b5\\:id1ad08e26bde39c9e4f1833e56dcce9b5"

SVScrapeR::select_semester_and_set_courses(
  rmdr,
  base_url,
  num_sem_selector,
  num_courses,
  sem_dropdown,
  search_field,
  num_courses_selector
)

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# SCRAPE BASE-INFORMATIONEN --------------------------------
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

css_max_selector <- "#genSearchRes\\:id3f3bd34c5d6b1c79\\:id3f3bd34c5d6b1c79Navi2_div > div > span.dataScrollerPageText"
base_info_tueb_ws21 <- scrape_base_info(rmdr, css_max_selector)
write_rds(base_info_tueb_ws21, "base_info.RDS")

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# VERGLEICHE SCRAPING DATA UND BASE DATA -------------------
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

course_data <- readRDS("course_data_2024_S.rds") |>
  select(Titel) %>%
  mutate(titel = ifelse(lengths(Titel) == 0, NA, unlist(Titel)))

base_info <- readRDS("base_info.RDS") |>
  clean_names() |>
  dplyr::rename(titel = titel_der_veranstaltung)

missing_data <- base_info %>%
  anti_join(course_data, by = join_by(titel)) |>
  select(titel, nummer) |>
  mutate(titel = str_replace_all(titel, "[\\(\\)]", " ")) |>  # entfernt runde Klammern
  mutate(titel = str_replace_all(titel, "[|]", " ")) |>        # entfernt Pipe-Zeichen
  mutate(titel = str_replace_all(titel, "[+]", " ")) |>        # entfernt Pluszeichen
  mutate(titel = str_replace_all(titel, "[-]", " ")) |>        # entfernt Minuszeichen
  mutate(titel = str_replace_all(titel, "[!]", " "))           # entfernt Ausrufezeichen

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# Scrape fehlende Daten -------------------
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

# Gehe zu der angegebenen URL
base_url <- "https://alma.uni-tuebingen.de/alma/pages/startFlow.xhtml?_flowId=searchCourseNonStaff-flow&_flowExecutionKey=e2s1"
rmdr$navigate(base_url)

scrape_for_missing_data(rmdr, missing_data, 4)
scrape_for_missing_data(rmdr, missing_data[820:nrow(missing_data), ], 4)




view(missing_data[820:nrow(missing_data), ])

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# CLOSE DRIVER, KILL PROCESS -------------------------------
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

rmdr$close()
system("taskkill /im java.exe /f", intern = FALSE, ignore.stdout = FALSE)

# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# FÜHRE DATEN ZUSAMMEN -------------------------------------
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
getwd()
all_data <- load_course_data("C:/Users/mhu/Downloads/Eberhard_Karls_Universitaet_Tuebingen/2024_S") %>%
  mutate(titel = ifelse(lengths(Titel) == 0, NA, unlist(Titel))) %>%
  distinct(titel, .keep_all = TRUE)

base_info <- readRDS("base_info.RDS") |>
  clean_names() |>
  dplyr::rename(titel = titel_der_veranstaltung) |>
  select(titel)

result <- base_info %>%
  left_join(all_data, by = "titel") |> select(-titel)

write_rds(result, "course_data_2024_S.RDS")
