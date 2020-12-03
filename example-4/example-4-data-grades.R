library(dplyr)
library(purrr)
library(magrittr)
library(ggplot2)

set.seed(1234)


CAT_BREEDS <- c(
  "persian",
  "britishShorthair",
  "maineCoon",
  "siamese",
  "americanShorthair",
  "ragdoll",
  "sphinx",
  "bengal",
  "abyssinian",
  "scottishFold"
)



random_breed <- function() {
  sample(x = CAT_BREEDS, size = 1)
}

random_hours_study <- function(breed) {
  .tmp <- qnorm(seq(from = 0.01, to = 0.99, length = 10))
  .tmp <- (.tmp - min(.tmp))
  .m <- 4 + 5 * .tmp / diff(range(.tmp))
  .sd <- 2.5
  switch(breed,
    "persian" = rnorm(n = 1, mean = .m[1], sd = .sd),
    "britishShorthair" = rnorm(n = 1, mean = .m[2], sd = .sd),
    "maineCoon" = rnorm(n = 1, mean = .m[3], sd = .sd),
    "siamese" = rnorm(n = 1, mean = .m[4], sd = .sd),
    "americanShorthair" = rnorm(n = 1, mean = .m[5], sd = .sd),
    "ragdoll" = rnorm(n = 1, mean = .m[6], sd = .sd),
    "sphinx" = rnorm(n = 1, mean = .m[7], sd = .sd),
    "bengal" = rnorm(n = 1, mean = .m[8], sd = .sd),
    "abyssinian" = rnorm(n = 1, mean = .m[9], sd = .sd),
    "scottishFold" = rnorm(n = 1, mean = .m[10], sd = .sd)
  )
}

random_grade <- function(breed, hours_study) {
  .sd <- 0.3
  .y <- seq(from = 0.0, to = 1.0, length = 10) # 10 because there are 10 breeds.
  .z <- switch(breed,
    "persian" = .y[1],
    "britishShorthair" = .y[2],
    "maineCoon" = .y[3],
    "siamese" = .y[4],
    "americanShorthair" = .y[5],
    "ragdoll" = .y[6],
    "sphinx" = .y[7],
    "bengal" = .y[8],
    "abyssinian" = .y[9],
    "scottishFold" = .y[10]
  )
  rnorm(n = 1, mean = 5 + 5 * .z + 5 * .z * hours_study, sd = .sd)
}

random_cat <- function(cat_id) {
  breed <- random_breed()
  hours_study <- random_hours_study(breed)
  grade <- random_grade(breed, hours_study)
  data.frame(
    breed = breed,
    hours_study = hours_study,
    grade = max(min(rnorm(n = 1, mean = grade, sd = 15), 100), 0),
    id = cat_id
  )
}




main <- function(args) {
  num_cats <- 80
  cat_data <- map(.x = 1:num_cats, .f = random_cat) %>% bind_rows()

  write.table(
    x = cat_data,
    file = "cat-grades-by-breed.csv",
    row.names = FALSE
  )
}

if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  main(args)
}
