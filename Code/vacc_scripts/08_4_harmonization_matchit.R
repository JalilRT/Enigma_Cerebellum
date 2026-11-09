library(tidyverse)

path="/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info"
path_files=paste0(path,"/enigma/suit_stats/wdseg1_files")
path_match_id=paste0(path,"/scripts/match_id")

setwd(path)

input_files_mul <- read_csv("scripts/input_files_mul.csv") %>%
    mutate(ID_MRI = basename(PATH_NEW) %>% str_remove("^wd") %>% str_remove("_n4_mni_seg1_neuroharmonized\\.nii$"), .before = 1)

Acapulco_volumes_files <- list.files(paste0(path,"/scripts/match_id"), pattern = "Acapulco_volumes")
Acapulco_volumes_matchit <- Acapulco_volumes_files %>%
    set_names(str_remove(., "\\.csv$") %>% str_remove("^Acapulco_volumes_matchit\\.?") %>% toupper()) %>%
    map(~ read_csv(file.path(path_match_id, .)))

# Merge Acapulco_volumes_matchit with input_files_mul
input_files_mul_matched <- Acapulco_volumes_matchit %>% names() %>%
    map(~ inner_join(input_files_mul, Acapulco_volumes_matchit[[.x]], by = "ID_MRI") %>%
        select(PATH,PATH_NEW) %>%
        mutate(PATH_NEW = str_replace(PATH_NEW, paste0("suit_stats/wdseg1_files/(HC|", .x, ")"), paste0("harmonized/",.x)))
        ) %>% set_names(Acapulco_volumes_matchit %>% names())

database_age_sex_etiv <- Acapulco_volumes_matchit %>%
    map(~ inner_join(input_files_mul, ., by = "ID_MRI") %>%
        mutate(Age=round(Age),
            eTIV=round(eTIV,3),
            SITE=paste0(Database)) %>%
        select(SITE,Age,Sex,eTIV))

afni_input_harmonized <- Acapulco_volumes_matchit %>% names() %>%
    map(~ inner_join(input_files_mul, Acapulco_volumes_matchit[[.x]], by = "ID_MRI") %>%
        mutate(Subj = ID_MRI, 
            InputFile = str_replace(PATH_NEW, paste0("suit_stats/wdseg1_files/(HC|", .x, ")"), paste0("harmonized/",.x))) %>%
        select(Subj, Substance, Database, Age, Sex, eTIV, Total_Cerebel_Vol, InputFile)) %>% 
        set_names(Acapulco_volumes_matchit %>% names())

# Export
output_path <- paste0(path,"/scripts/match_id")

walk2(input_files_mul_matched,
      names(input_files_mul_matched),
      ~ write_csv(.x, file.path(output_path, paste0(.y,"/input_files_mul_", .y, ".csv"))))

walk2(database_age_sex_etiv,
    names(database_age_sex_etiv),
    ~ write_csv(.x, file.path(output_path, paste0(.y,"/database_age_sex_etiv_", .y, ".csv"))))

walk2(afni_input_harmonized,
      names(afni_input_harmonized),
      ~ write.table(.x, file.path(output_path, paste0(.y,"/afni_input_harmonized.txt")), sep = " ", row.names = FALSE, quote = FALSE))