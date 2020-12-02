library(dplyr)
library(purrr)
library(magrittr)
library(ggplot2)
library(lme4)
library(MuMIn)

CAT_DF <- read.csv("cat-weights-by-breed.csv", sep = " ")

.id_sample <- sample(unique(CAT_DF$id), size = 12)


g1 <- ggplot(filter(CAT_DF, is.element(id, .id_sample)), aes(x = age, y = weight, group = id)) +
  geom_point() +
  facet_wrap(~id)


summarise_fit_factory <- function(summary_func) {
  function(id_num) {
    fit <- lm(weight ~ poly(age, 2, raw = TRUE),
      data = CAT_DF[CAT_DF$id == id_num, ]
    )
    summary_func(fit)
  }
}
demo_coefs <- summarise_fit_factory(coef)
demo_fit <- summarise_fit_factory((function(x) x$fit))

individual_model_coefs <- map(
  .x = unique(CAT_DF$id),
  .f = demo_coefs
)

individual_model_fits <- map(
  .x = unique(CAT_DF$id),
  .f = function(x) {
    data.frame(age = CAT_DF[CAT_DF$id == x, "age"], weight_fit = demo_fit(x), id = x)
  }
) %>% bind_rows()



g2 <- g1 +
  geom_line(
    data = filter(individual_model_fits, is.element(id, .id_sample)),
    mapping = aes(x = age, y = weight_fit, group = id),
    linetype = "dashed"
  ) + facet_wrap(~id)

quadratic_model <- lmer(weight ~ poly(age, 2, raw = TRUE) + (poly(age, 2, raw = TRUE) | id),
  data = CAT_DF
)

confint.merMod(quadratic_model, "poly(age, 2, raw = TRUE)1", method = "Wald")

r.squaredGLMM(quadratic_model)

cat_df_with_lme_fit <- CAT_DF
cat_df_with_lme_fit$fit <- fitted(quadratic_model)

g3 <- g2 + geom_line(
             data = filter(cat_df_with_lme_fit, is.element(id, .id_sample)),
           mapping = aes(x = age, y = fit, group = id), linetype = "solid")
