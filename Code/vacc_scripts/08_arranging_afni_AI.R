library(tidyverse)

path="/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info"
path_files=paste0(path,"/enigma/suit_stats/wdseg1_files")

setwd(path)

volume_acapulco <- read_csv(paste0(path_files,"/../Volumes_Cerebellum_Acapulco_Harmonized_AI.csv"))

drugs <- list.dirs(path_files) %>% basename() %>% .[c(-1)]

path_lists <- drugs %>% map(~ list.files(path = paste0(path_files,"/",.x), pattern="T1w_n4_mni_seg1.nii", recursive=T, full.names=T) %>% as_tibble() )

detect_files <- path_lists %>% map(~ .x %>% mutate(file = value %>% basename(),
 DB = file %>% str_split(pattern="_") %>% map(~ .x %>% .[1]) %>% reduce(rbind),
 ID = file %>% str_split(pattern="_") %>% map(~ .x %>% .[2]) %>% reduce(rbind),
 ID_MRI = paste0(DB,"_",ID,"_T1w") %>% str_remove(pattern = "wd"), .before=1 ) %>%
 rename("InputFile" = "value") %>% select(-(file)) )  %>% reduce(rbind) %>% select("ID_MRI","InputFile")

afni_input <- left_join(detect_files %>% unique(),volume_acapulco %>% select(Substance,ID_MRI,Database,Sex,Age,eTIV) %>% unique(),by=c("ID_MRI")) %>% 
  drop_na() %>% 
  select(c("ID_MRI","Substance","Database","Age","Sex","eTIV","InputFile")) %>% 
  rename("Subj"="ID_MRI") %>%
  mutate(Age=round(Age),
        eTIV=round(eTIV,3),
        Database=paste0("site_",Database),
            Sex=paste0("Sex_",Sex))

write.table(x = afni_input, file = paste0(path,"/scripts/afni_input_AI.txt"), sep = " ", row.names=FALSE, quote=FALSE)

write_csv(afni_input %>% select(Database,Age,Sex,eTIV) %>% 
  mutate(Database = paste0("Site_",Database)) %>% 
  rename(SITE = Database), 
  paste0(path, "/scripts/database_age_sex_etiv_AI.csv"))
