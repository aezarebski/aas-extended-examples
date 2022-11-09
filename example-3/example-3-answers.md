---
jupyter:
  jupytext:
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.14.1
  kernelspec:
    display_name: Python 3 (ipykernel)
    language: python
    name: python3
---

# Example 3

This notebook is available on github
[here](https://github.com/aezarebski/aas-extended-examples). If you find errors
or would like to suggest an improvement, feel free to create an issue.

As usual we will start by importing some useful libraries.

```python
%matplotlib inline
import pandas as pd
import numpy as np
import scipy.stats as stats
import statsmodels.api as sm
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt
import matplotlib as matplotlib
import os.path as path
```

In this notebook we will also use an additional module, `heatmap`, which
provides a function for drawing heatmaps of the correlations between columns of
a pandas dataframe. If you have downloaded this code from GitHub you should
already have the file, if you are using Colab, the following will download a
copy of into your session.

```python
if path.exists('heatmap.py'):
    from heatmap import correlation_heatmap
else:
    import requests
    heatmap_py_url = 'https://raw.githubusercontent.com/aezarebski/aas-extended-examples/main/example-3/heatmap.py'
    req = requests.get(heatmap_py_url)
    with open('urlheatmap.py', 'w') as f:
        f.write(req.text)
    from urlheatmap import correlation_heatmap
```

The data in `data-auto.csv` is a popular dataset of car characteristics. In this
notebook we will be looking at the miles per gallon (MPG) achieved by these cars
based on some features of the cars and where/when they were produced. The
`origin` of origin of the car is encoded as an integer, (recall you can use the
`dtypes` method to see this). The representation of the data is clearer by
mapping it to a string describing the origin.

```python
data_csv = 'data-auto.csv'
if not path.exists(data_csv):
    data_csv = 'https://raw.githubusercontent.com/aezarebski/aas-extended-examples/main/example-3/data-auto.csv'
df = pd.read_csv(data_csv)
```

```python
df.origin = df.origin.map({1: 'America', 2: 'Europe', 3: 'Japan'})
```

```python
col_names = df.columns.to_list()
numeric_cols = col_names[0:7]
```

A heatmap of the correlations between the variables in the data is a good way to
get a feel for the data.

```python
correlation_heatmap(df[numeric_cols])
plt.show()
```

```python
plt.figure()
pd.plotting.scatter_matrix(df[numeric_cols], alpha = 0.4)
plt.show()
```

### Question

What do you notice about `cylinders`, `displacement`, `horsepower` and `weight`?
How do they relate to `mpg`?


### Answer

These variables are all highly correlated with each other and decreasing MPG;
given what we know about cars this also makes sense from a mechanical
perspective. They have a non-linear relationship with `mpg`.


### Question

Fit an ordinary linear regression for the MPG using all of the variables
(excluding the name of the car). Print a summary of the fitted model. Comment on
the results, how has the MPG changed over time? Save the fitted model as
`fit_1`, note the `1`, we are going to improve on this below.

### Answer

```python
form_1 = 'mpg ~ cylinders + displacement + horsepower + weight + acceleration + year + origin'
fit_1 = smf.ols(formula = form_1, data = df).fit()
fit_1.summary()
```

### Question

Plot the residuals against the fitted values, what do you notice?


### Answer

There is some clear non-linearity and the variance is not constant.

```python
def make_fittedvalues_resid_plot(fit):
    plt.figure()
    plt.scatter(fit.fittedvalues, fit.resid, color='b')
    plt.axhline(y=0, color='r')
    plt.xlabel("Fitted value")
    plt.ylabel("Residual")
    return


make_fittedvalues_resid_plot(fit_1)
plt.show()
```

### Question

What does this model tell us about fuel efficiency across the years?


### Answer

**Keeping the attributes of a car constant**, each year, new cars get about
`0.8` more miles per gallon **on average**. Note that the types of cars produced
change over time, there is a trend for newer cars to be lighter, however this
model fit still suggests there are improvements in efficiency beyond this.


### Question

Apply some transforms to reduce non-linearity in the relationship between the
predictors and the response.

### Answer

Looking at the scatter plots, we can see that the `displacement`, `horsepower`
and `weight` all appear to have a non-linear relationship. To adjust for this we
can log-transform these variables.

```python
plt.figure()
pd.plotting.scatter_matrix(df[['mpg',
 'displacement',
 'horsepower',
 'weight',
 'acceleration',
 'year']], alpha = 0.4)
plt.show()
```

```python
df['ln_weight'] = np.log(df.weight)
df['ln_horsepower'] = np.log(df.horsepower)
df['ln_displacement'] = np.log(df.displacement)

plt.figure()
pd.plotting.scatter_matrix(df[['mpg',
 'ln_displacement',
 'ln_horsepower',
 'ln_weight',
 'acceleration',
 'year']], alpha = 0.4)
plt.show()
```

### Question

Re-fit the model (as `fit_2`) with the transformed variables and comment on what
has changed.


### Answer

The log transformation of the variables has improved the fit. There is still
some strong col-linearity though.

```python
form_2 = 'mpg ~ cylinders + ln_displacement + ln_horsepower + ln_weight + acceleration + year + origin'
fit_2 = smf.ols(formula = form_2, data = df).fit()
fit_2.summary()
```

```python
make_fittedvalues_resid_plot(fit_2)
plt.show()
```

### Question

Remove the `ln_displacement` variable in a new model `fit_3`. Comment on how the
model has changed.


### Answer

Removing `ln_displacement` has produced a more parsimonious model without
reducing the model fit.

```python
form_3 = 'mpg ~ cylinders + ln_horsepower + ln_weight + acceleration + year + origin'
fit_3 = smf.ols(formula = form_3, data = df).fit()
fit_3.summary()
```

### Question

In a new model, `fit_4`, include an interaction term between the origin of the
cars and their year or release. What does this tell you about car manufacturing
in the considered regions?

### Answer

We see that Europe and Japan are improving their efficiency faster than America.

```python
form_4 = form_3 + ' + origin * year'
fit_4 = smf.ols(formula = form_4, data = df).fit()
fit_4.summary()
```

```python
make_fittedvalues_resid_plot(fit_4)
plt.show()
```
