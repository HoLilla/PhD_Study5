#randomise order of trials for Study 5 
#final PhD study
# Seed for random number generation
set.seed(42)
# disable scientific notation (this causes long numbers to appear in full rather than being truncated)
options(scipen = 999)

library(dplyr)
library(utils)

random_order<-NULL
no_dyad <- 45
for(dyad in 1:no_dyad) {
condition_df<-dplyr::data_frame( condition = c("A_C_IND", "B_C_IND",
                                                  "A_C_JP", "B_C_JP",
                                                  "A_C_JN", "B_C_JN"),
                                 dyad_number = rep(dyad,6))


index<-sample(1:nrow(condition_df))
condition_df<-condition_df[index,]

random_order<- rbind(random_order,condition_df)

}

numbers <- NULL
for (i in 1:45) {
  numbers <- c(numbers, (2*i)-1)
  }


random_order$ID_A <-(2*random_order$dyad_number)-1

random_order$ID_B <-random_order$ID_A+1

write.csv(random_order,file = "study5_random_order.csv", row.names = FALSE)
