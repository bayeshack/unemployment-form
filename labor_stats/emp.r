library(data.table)
library(plyr)
library(dplyr)
library(magrittr)
library(stringr)
library(rjson)
library(RJSONIO)

msa_occupation_13 <- fread('msa_occupation_13.csv')
msa_occupation_14 <- fread('msa_occupation_14.csv')
msa_occupation_15 <- fread('msa_occupation_15.csv')

zip_msa <- fread('zip_msa.csv')
setnames(zip_msa, gsub(' ', '_', names(zip_msa)))

zip_msa %<>% mutate(zip_code = as.character(str_pad(ZIP_CODE, 5, pad = '0')))

similar_socs <- fread('sample_similar_socs.csv')

similar_socs %<>% mutate(zipcode = as.character(zipcode),
                         related_soc = substr(related_soc, 1, 7))

msa_occupation <- merge(msa_occupation_13, msa_occupation_14,
                        by = c('AREA', 'OCC_CODE', 'OCC_TITLE'),
                        suffixes = c('_13', '_14'))
msa_occupation <- merge(msa_occupation, msa_occupation_15,
                        by = c('AREA', 'OCC_CODE', 'OCC_TITLE'))
setnames(msa_occupation, gsub(' ', '_', names(msa_occupation)))

msa_occupation %<>% filter(OCC_GROUP == 'detailed',
                           A_MEAN != '*',
                           'LOC_QUOTIENT' != '**') %>%
  mutate(TOT_EMP = as.numeric(TOT_EMP),
         TOT_EMP_13 = as.numeric(TOT_EMP_13),
         LOC_QUOTIENT = as.numeric(LOC_QUOTIENT),
         A_MEAN = as.numeric(A_MEAN),
         GROWTH = (TOT_EMP - TOT_EMP_13) / TOT_EMP_13 / 2) %>%
    filter(!is.na(GROWTH)) %>%
      group_by(AREA) %>%
        mutate(AREA_NAME == max(AREA_NAME)) %>%
          group_by(AREA, AREA_NAME) %>%
            mutate(GROWTH_SCORE = (GROWTH - mean(GROWTH)) / sd(GROWTH),
                   LOCQUO_SCORE = (LOC_QUOTIENT - mean(LOC_QUOTIENT)) / sd(LOC_QUOTIENT),
                   WAGE_SCORE = (A_MEAN - mean(A_MEAN)) / sd(A_MEAN),
                   SCORE = GROWTH_SCORE + LOCQUO_SCORE + WAGE_SCORE)

output_msa <- select(msa_occupation, OCC_CODE, OCC_TITLE,
                     AREA_NAME, AREA,
                     SCORE, GROWTH, A_MEAN)

output_zip <- merge(select(zip_msa, zip_code, MSA_No.), output_msa,
                    by.x = 'MSA_No.', by.y = 'AREA',
                    allow.cartesian = T)

final_output <- merge(output_zip, similar_socs,
                      by.x = c('zip_code',
                               'OCC_CODE'),
                      by.y = c('zipcode',
                               'related_soc')) %>%
  group_by(zip_code, current_soc, current_title) %>%
    top_n(4, SCORE)

json_output <- toJSON(final_output)

write(json_output, 'scoring.json')
