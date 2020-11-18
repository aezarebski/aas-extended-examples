## There are some libraries that will make things a lot easier. Note that the
## effects package is a little bit mysterious, so if you want to truely
## understand it you will need to do a little bit of your own reading...

library(nnet)
library(MASS)
library(effects)

## First we read in the data and fit the logistic regression to make sure we can
## replicate the results

## We need to be careful that R interprets the Boolean variables as catagorical
## variables rather than integers so we cast them to logicals explicitly. The
## same goes for the likert style data which we need to state is ordered.

data_df <- read.csv("cat-opinions.csv")
data_df$work_from_home <- as.logical(data_df$work_from_home)
data_df$fifth_generation <- as.logical(data_df$fifth_generation)
data_df$support_lockdown <- factor(data_df$support_lockdown,
                                   levels = 0:4,
                                   ordered = TRUE)

## We subsample the data set as before and make sure that it is in a suitable
## format for the \code{glm} function. Note that in doing so the family we are
## using here is binomial.
binary_df <- data_df[data_df$will_vaccinate != 0, ]
binary_df$will_vaccinate <- 0.5 * (binary_df$will_vaccinate + 1)
binary_logistic <- glm(will_vaccinate ~ work_from_home + whisker_length + trust_in_government + fifth_generation,
  data = binary_df,
  family = binomial
)

## The \code{print} and \code{summary} functions work pretty much the same as in
## python.
print(summary(binary_logistic))

## And now for a effect display

plot(allEffects(binary_logistic),
     axes=list(grid=TRUE, x=list(rug=FALSE)),
     lattice=list(key.args=list(columns=1)),
     lines=list(multiline=TRUE))

## Now we will fit the multi-nomial logistic regression to make sure that it
## gives the same results.

multi_logistic <- multinom(will_vaccinate ~ work_from_home + whisker_length + trust_in_government + fifth_generation,
                           data = data_df)

## The \code{print} and \code{summary} functions work pretty much the same as in
## python.

print(summary(multi_logistic))

plot(allEffects(multi_logistic),
     axes=list(grid=TRUE, x=list(rug=FALSE)),
     lattice=list(key.args=list(columns=1)),
     lines=list(multiline=TRUE))

## Finally to compute the ordinal logistic regression for the lockdown support,
## we need to use the function from \code{MASS}.

prop_odds_logistic <- polr(support_lockdown ~ work_from_home + whisker_length + trust_in_government + fifth_generation,
                           data = data_df)

## Recall that we have to have multiple intercepts when doing ordinal logistic
## regression. A crude way to see if a coefficient is "significant" is to look
## at the confidence interval which can be computed for this model fit with
## \code{confint}

print(summary(prop_odds_logistic))
print(confint(prop_odds_logistic))

plot(predictorEffects(prop_odds_logistic,
                      ~ whisker_length + trust_in_government),
     axes=list(grid=TRUE, x=list(rug=FALSE)),
     lattice=list(key.args=list(columns=1)),
     lines=list(multiline=TRUE))

