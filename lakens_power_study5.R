devtools::install_github("Lakens/ANOVApower")

library(ANOVApower)
design_result <- ANOVA_design(design = "2w*2w",
                              n = 80, 
                              mu = c(37, 32, 34, 36), 
                              sd = 17, 
                              r<- c(0.5,0.6,0.5,0.7,0.6,0.7), 
                              labelnames = c("Soc_context", "Positive", "Negative", "Congruency", "Congruent", "Incongruent"))
ANOVA_exact(design_result)$main_results$power

nsims = 100
 power_result_vig_1 <- ANOVA_power(design_result, 
                                   alpha = 0.05, 
                                   nsims = nsims, 
                                   seed = 1234,
                                   p_adjust = "none" )
 plot_power(design_result, min_n = 10, max_n = 85)
 
 #reduce file size for github - only save what is needed
 #power_result_vig_1$sim_data <- NULL
 #power_result_vig_1$plot1 <- NULL
 #power_result_vig_1$plot2 <- NULL
 #saveRDS(power_result_vig_1, file = "vignettes/sim_data/power_result_vig_1_test.rds")
 
 design_result$cor_mat
 
 psych::describeBy(task$CH_HF, task$Belief:task$Congruency)
 psych::describeBy(task$DV_HF, task$Belief:task$Congruency)
 
 
 names(task)
study3_CS<- task %>%
  filter(Congruency == "Congruent" & Belief == "Self")
study3_CO<-  task %>%
  filter(Congruency == "Congruent" & Belief == "Other")
study3_ICS<-task %>%
  filter(Congruency == "Incongruent" & Belief == "Self")
study3_ICO<-task %>%
  filter(Congruency == "Incongruent" & Belief == "Other")

study3_vars<-dplyr::data_frame(CS = study3_CS$DV_HF,CO = study3_CO$DV_HF,ICS = study3_ICS$DV_HF,
                               ICO = study3_ICO$DV_HF)

corr_matrix<-sjp.corr(study3_vars)


