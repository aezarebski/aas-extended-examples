library(nnet)
library(MASS)
library(effects)

data_df <- read.csv("cat-opinions.csv")
data_df$work_from_home <- as.logical(data_df$work_from_home)
data_df$fifth_generation <- as.logical(data_df$fifth_generation)
data_df$support_lockdown <- factor(data_df$support_lockdown,
                                   levels = 0:4,
                                   ordered = TRUE)

binary_df <- data_df[data_df$will_vaccinate != 0, ]
binary_df$will_vaccinate <- 0.5 * (binary_df$will_vaccinate + 1)
binary_logistic <- glm(will_vaccinate ~ work_from_home + whisker_length + trust_in_government + fifth_generation,
  data = binary_df,
  family = binomial
)

print(summary(binary_logistic))

png("figs/binary-logistic-regression-fig-1.png")
plot(allEffects(binary_logistic),
     axes=list(grid=TRUE, x=list(rug=FALSE)),
     lattice=list(key.args=list(columns=1)),
     lines=list(multiline=TRUE))
dev.off()

multi_logistic <- multinom(will_vaccinate ~ work_from_home + whisker_length + trust_in_government + fifth_generation,
                           data = data_df)

print(summary(multi_logistic))

png("figs/multinomial-logistic-regression-fig-1.png")
plot(allEffects(multi_logistic),
     axes=list(grid=TRUE, x=list(rug=FALSE)),
     lattice=list(key.args=list(columns=1)),
     lines=list(multiline=TRUE))
dev.off()

prop_odds_logistic <- polr(support_lockdown ~ work_from_home + whisker_length + trust_in_government + fifth_generation,
                           data = data_df)

print(summary(prop_odds_logistic))
print(confint(prop_odds_logistic))

png("figs/ordinal-logistic-regression-fig-1.png")
plot(predictorEffects(prop_odds_logistic,
                      ~ whisker_length + trust_in_government),
     axes=list(grid=TRUE, x=list(rug=FALSE)),
     lattice=list(key.args=list(columns=1)),
     lines=list(multiline=TRUE))
dev.off()
