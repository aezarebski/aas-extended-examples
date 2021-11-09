library(dplyr)
library(ggplot2)
library(magrittr)
library(purrr)
library(ISLR)

#' Look at the data and ensure that the inferred types make sense.

Auto |> select(-origin, -name, -cylinders) |> pairs()
Auto |> select(-origin, -name, -cylinders) |> cor()
str(Auto)
df1 <- Auto |> mutate(origin = as.factor(origin))

#' Fit a boring model and look at what you get.
m1 <- lm(mpg ~ . - name, data = df1)
summary(m1)

plot(m1)

#' Transform some of the variables to make their relationship with MPGs look
#' more linear.
df2 <- df1 |>
  mutate(ln_weight = log(weight),
         sqrd_acceleration = acceleration ^ 2)

m2 <- lm(mpg ~ . - name - weight - sqrd_acceleration, data = df2)
summary(m2)

#' Observe that removing horsepower leaves a very similar model probably because
#' horsepower is so closely associated with the displacement.
m3 <- lm(mpg ~ . - name - weight - acceleration, data = df2)
summary(m3)

#' Observe that you can also do this with the original data set by modifying the formula.
m3b <- lm(mpg ~ . - name - weight + log(weight) - acceleration + I(acceleration^2), data = df1)
summary(m3b)

## Observe that if you consider the interaction between year and the country
## that you find that the MPG is improving faster in Europe and Japan than in
## America.
m4a <- lm(mpg ~ . - name - weight + log(weight) - acceleration + I(acceleration^2), data = df1)
summary(m4a)

m4b <- lm(mpg ~ . + origin*year - name - weight + log(weight) - acceleration + I(acceleration^2), data = df1)
summary(m4b)
