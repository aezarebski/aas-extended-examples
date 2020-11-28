library(lme4)
library(dplyr)

hsb_df <- read.csv("high-school-and-beyond.csv", sep = " ") %>% rename(math_achieve = math.achieve)
tmp <- hsb_df %>%
  select(school, ses) %>%
  group_by(school) %>%
  summarise(mean_ses = mean(ses))
hsb_df <- left_join(hsb_df, tmp, by = "school") %>% mutate(centered_ses = ses - mean_ses)


## lmer(formula, data = NULL, REML = TRUE, control = lmerControl(),
##      start = NULL, verbose = 0L, subset, weights, na.action,
##      offset, contrasts = NULL, devFunOnly = FALSE)

rand_const_fit_ml <- lmer(math_achieve ~ 1 + (1 | school), hsb_df, REML = FALSE)
summary(rand_const_fit_ml)

rand_const_fit <- lmer(math_achieve ~ 1 + (1 | school), hsb_df)
summary(rand_const_fit)



rand_coef_fit <- lmer(math_achieve ~ 1 + centered_ses + (centered_ses | school), hsb_df)
summary(rand_coef_fit)
