library(tidyverse)

path="/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info"
path_files=paste0(path,"/enigma/suit_stats/wdseg1_files")
path_match_id=paste0(path,"/scripts/match_id")

setwd(path)

volume_acapulco <- read_csv(paste0(path_files,"/../Volumes_Cerebellum_Acapulco_Harmonized.csv")) %>%
    select(Substance,ID_MRI,Database,Age,Sex,eTIV,Total_Cerebel_Vol)

volumes_acapulco_matchid_paths <- list.files(path_match_id, pattern="csv", full.names=TRUE) 
volumes_acapulco_matchid_names <- volumes_acapulco_matchid_paths %>% 
    basename() %>% str_split_fixed("\\.", 3) %>% .[,2] %>% toupper()
volumes_acapulco_matchid_files <- volumes_acapulco_matchid_paths %>% 
    map(~ read_csv(.x) %>% select(Substance,group,ID_MRI) %>%
        left_join(volume_acapulco %>% unique(), by = c("Substance","ID_MRI"))) %>% 
    set_names(volumes_acapulco_matchid_names)

drugs <- list.dirs(path_files) %>% basename() %>% .[c(-1)]

path_lists <- drugs %>% map(~ list.files(path = paste0(path_files,"/",.x), pattern="T1w_n4_mni_seg1.nii", recursive=T, full.names=T) %>% as_tibble() )

detect_files <- path_lists %>% map(~ .x %>% mutate(file = value %>% basename(),
 DB = file %>% str_split(pattern="_") %>% map(~ .x %>% .[1]) %>% reduce(rbind),
 ID = file %>% str_split(pattern="_") %>% map(~ .x %>% .[2]) %>% reduce(rbind),
 ID_MRI = paste0(DB,"_",ID,"_T1w") %>% str_remove(pattern = "wd"), .before=1 ) %>%
 rename("InputFile" = "value") %>% select(-(file)) )  %>% reduce(rbind) %>% select("ID_MRI","InputFile")

afni_input_matchid <- volumes_acapulco_matchid_files %>% 
    map(~ .x %>% 
        left_join(detect_files, by=c("ID_MRI")) %>% 
        drop_na() %>%
        select(c("ID_MRI","Substance","Database","Age","Sex","eTIV","Total_Cerebel_Vol","InputFile")) %>%
        distinct() %>%
        rename("Subj"="ID_MRI") %>%
        mutate(
            Age = round(Age),
            eTIV = round(eTIV, 3),
            Database = paste0("site_", Database),
            Sex = paste0("Sex_", Sex)
        )
    )

# Writing files
afni_input_matchid %>% names() %>% walk(~ dir.create(paste0(path,"/scripts/match_id/",.x), showWarnings = FALSE))
afni_input_matchid %>% names() %>% 
    imap(~ write.table(x = afni_input_matchid[[.x]], 
        file = paste0(path,"/scripts/match_id/",.x,"/afni_input_raw.txt"), 
        sep = " ", row.names=FALSE, quote=FALSE))
afni_input_matchid %>% names() %>%
    imap(~ write.table(x = afni_input_matchid[[.x]] %>%
        mutate(InputFile = str_remove(InputFile, "\\.nii") %>% paste0("_neuroharmonized.nii")),
        file = paste0(path,"/scripts/match_id/",.x,"/afni_input.txt"), 
        sep = " ", row.names=FALSE, quote=FALSE))