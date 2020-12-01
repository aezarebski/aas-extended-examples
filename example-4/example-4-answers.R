library(dplyr)
library(purrr)
library(magrittr)
library(ggplot2)
library(lme4)

x <- read.csv("cat-weights-by-breed.csv", sep = " ")

.id_sample <- sample(unique(x$id), size = 12)


g1 <- ggplot(filter(x, is.element(id, .id_sample)), aes(x = age, y = weight, group = id)) + geom_point() + facet_wrap(~id)


summarise_fit_factory <- function(summary_func) {
  function(id_num) {
    fit <- lm(weight ~ poly(age, 2),
              data = x[x$id == id_num,])
    summary_func(fit)
  }
}
demo_coefs <- summarise_fit_factory(coef)
demo_fit <- summarise_fit_factory((function(x) x$fit))


individual_model_fits <- map(.x = unique(x$id),
           .f = function(x) {data.frame(age = 1:20, weight_fit = demo_fit(x), id = x)}) %>% bind_rows



g2 <- ggplot() +
  geom_point(
  data = filter(x, is.element(id, .id_sample)),
  mapping = aes(x = age, y = weight)) +
  geom_line(
  data = filter(individual_model_fits, is.element(id, .id_sample)),
  mapping = aes(x = age, y = weight_fit, group = id)) + facet_wrap(~id)


## Do the algebra to work out the appropriate definition for a LMM for this data
## set.
