library(dplyr)
library(purrr)
library(magrittr)
library(ggplot2)
library(lme4)
library(MuMIn)

set.seed(1)
HEX_CODES <- c("#d8b365", "#5ab4ac")
LINE_SIZE <- 1.5

CAT_DF <- read.csv("cat-grades-by-breed.csv", sep = " ")
CAT_BREEDS <- unique(CAT_DF$breed)

g1_with_col <- ggplot(data = CAT_DF, mapping = aes(x = hours_study, y = grade, colour = breed)) + geom_point()
g1_without_col <- ggplot(data = CAT_DF, mapping = aes(x = hours_study, y = grade, group = breed)) + geom_point()
g2_with_se <- g1_with_col + geom_smooth(method = "lm", se=TRUE)
g2 <- g1_without_col + geom_smooth(method = "lm", se=FALSE, size = LINE_SIZE, colour = HEX_CODES[1]) + facet_wrap(~ breed)


## More motivation!

boring_lm <- lm(grade ~ hours_study, CAT_DF)
boring_df <- CAT_DF
boring_df$resid <- boring_lm$residuals
boring_df$val <- boring_lm$fitted.values

ggplot(boring_df, aes(y = resid, x = val, colour = breed)) + geom_point() + geom_hline(yintercept = 0) + facet_wrap(~breed)

## Massive problem!
lm(grade ~ hours_study, filter(CAT_DF, breed == "britishShorthair")) %>% summary

summarise_fit_factory <- function(summary_func) {
  function(breed_str) {
    fit <- lm(grade ~ hours_study,
              data = CAT_DF[CAT_DF$breed == breed_str, ]
              )
    summary_func(fit)
  }
}
demo_coefs <- summarise_fit_factory(coef)
demo_fit <- summarise_fit_factory((function(x) x$fit))

individual_model_coefs <- map(
  .x = CAT_BREEDS,
  .f = demo_coefs
) %>% map(compose(as.data.frame, t)) %>% bind_rows

individual_model_fits <- map(
  .x = CAT_BREEDS,
  .f = function(x) {
    data.frame(hours_study = CAT_DF[CAT_DF$breed == x, "hours_study"], grade_fit = demo_fit(x), breed = x)
  }
) %>% bind_rows()


## Motivate the jump based on the differences in the fited parameters and the
## advice of Barr (2013)
## https://www.sciencedirect.com/science/article/pii/S0749596X12001180#f0005

mlm_null_fit <- lmer(grade ~ 1 + (hours_study | breed),
                     data = CAT_DF,
                     REML = FALSE
                     )



mlm_fit <- lmer(grade ~ hours_study + (hours_study | breed),
                        data = CAT_DF,
                REML = FALSE
)


cat_df_with_lme_fit <- CAT_DF
cat_df_with_lme_fit$fit <- fitted(mlm_fit)

g3 <- g2 + geom_line(
             data = cat_df_with_lme_fit,
             mapping = aes(y = fit),
             size = LINE_SIZE,
             colour = HEX_CODES[2]
           )

g3

anova(mlm_null_fit, mlm_fit)
