library(dplyr)
library(purrr)
library(magrittr)
library(ggplot2)

set.seed(1)


CAT_WEIGHT_DATA <- read.csv("cat-weights.csv") %>%
  filter(sex == "male") %>%
  select(age, weight, sd)

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


mean_weight_curve <- function(age_1_weight) {
  .l <- CAT_WEIGHT_DATA[1, "weight"]
  .s <- CAT_WEIGHT_DATA[1, "sd"]
  .m <- (age_1_weight - .l) / .s
  .final_age <- max(min(rpois(n = 1, lambda = 10), 20), 7)
  .df <- data.frame(
    age = CAT_WEIGHT_DATA$age,
    weight = CAT_WEIGHT_DATA$weight + .m * CAT_WEIGHT_DATA$sd
  )
  head(.df, .final_age)
}

random_breed <- function() {
  sample(x = CAT_BREEDS, size = 1)
}

random_age_1_weight <- function(breed) {
  .tmp <- qnorm(seq(from = 0.01, to = 0.99, length = 10))
  .tmp <- (.tmp - min(.tmp))
  .m <- 4 + 5 * .tmp / diff(range(.tmp))
  .sd <- 0.6
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

random_weights <- function(breed, age_1_weight) {
  mean_weights <- mean_weight_curve(age_1_weight)
  .sd <- 0.3
  .cwd <- head(CAT_WEIGHT_DATA, nrow(mean_weights))
  .x <- (.cwd$weight - mean(.cwd$weight)) / diff(range(.cwd$weight))
  .y <- seq(from = -0.2, to = 0.2, length = 10) # 10 because there are 10 breeds.
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
  rnorm(n = nrow(mean_weights), mean = mean_weights$weight + .z * .x, sd = .sd)
}

random_cat <- function(cat_id) {
  breed <- random_breed()
  age_1_weight <- random_age_1_weight(breed)
  weights <- random_weights(breed, age_1_weight)
  .cwd <- head(CAT_WEIGHT_DATA, length(weights))
  data.frame(
    breed = breed,
    weight = rnorm(n = length(weights), mean = weights, sd = 0.3),
    age = .cwd$age,
    id = cat_id
  )
}




main <- function(args) {
  stopifnot(file.exists("cat-weights.csv"))

  g1 <- ggplot(CAT_WEIGHT_DATA, aes(x = age, y = weight, ymin = weight - 2 * sd, ymax = weight + 2 * sd)) +
    geom_ribbon(alpha = 0.1) +
    geom_line()

  num_cats <- 100
  cat_data <- map(.x = 1:num_cats, .f = random_cat) %>% bind_rows()

  g2 <- ggplot(cat_data, aes(x = age, y = weight, colour = breed, group = id)) +
    geom_line()

  write.table(
    x = cat_data,
    file = "cat-weights-by-breed.csv",
    row.names = FALSE
  )
}

if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  main(args)
}
