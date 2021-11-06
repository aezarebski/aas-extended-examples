# library(dplyr)
# library(ggplot2)
# library(magrittr)
# library(purrr)
# library(ISLR)

import pandas as pd
import numpy as np
import scipy.stats as stats
import statsmodels.api as sm
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt

df = pd.read_csv("data-auto.csv")
df.origin = df.origin.map({1: 'America', 2: 'Europe', 3: 'Japan'})

# Generate a plot to understand how things look.
pd.plotting.scatter_matrix(df.iloc[:, 0:8], alpha = 0.4)
plt.show()

col_names = df.columns.to_list()
form_1 = 'mpg ~ ' + ' + '.join(col_names[1:8])
# May want to address the multicollinearity here but not sure.
# form_1 = form_1.replace(' + displacement', '').replace(' + horsepower', '')

# TODO Need to generate the diagnostic plots for the model fit but it is
# unclear how much of this we can do without them having seen it in lectures

fit_1 = smf.ols(formula = form_1, data = df).fit()

form_2 = form_1.replace('weight', 'np.log(weight)').replace('acceleration', 'np.power(acceleration, 2)')

fit_2 = smf.ols(formula = form_2, data = df).fit()

form_3 = form_2 + ' + origin * year'

fit_3 = smf.ols(formula = form_3, data = df).fit()
