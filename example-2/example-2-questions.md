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

# Example 2

This notebook is available on GitHub
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
```

The data in `data-auto.csv` is a popular dataset of car characteristics. We will
be looking at the horsepower and miles per gallon (MPG) obtained by these cars.
The model we will consider in this notebook is a simple linear regression:

$$
\text{mpg}_{i} = \alpha + \beta \text{horsepower}_{i} + \epsilon_{i}
$$

where the $\epsilon_{i}$ are independent and identically distributed (IID)
normal random variables. We will estimate the parameters $\alpha$ and $\beta$.

As in previous notebooks, to accommodate the use of Google Colab we will load
the data in a slightly circuitous way.

```python
auto_url = "https://raw.githubusercontent.com/aezarebski/aas-extended-examples/main/example-2/data-auto.csv"
auto_file = "data-auto.csv"

try:
    df = pd.read_csv(auto_file)
    print("Auto data loaded from file\n")
except:
    print("Could not load auto from file, defaulting to URL")
    df = pd.read_csv(auto_url)
    print("Auto loaded from URL\n")

y = df["mpg"].to_numpy()
x = df["horsepower"].to_numpy()
y_bar = y.mean()
x_bar = x.mean()
```

### Question

Plot the horsepower and MPG, describe the relationship between these variables.


### Question

Using the formula you saw in lectures, calculate the least squares estimates
$\hat{\beta}$ and $\hat{\alpha}$


### Question

Using your parameter estimates, calculate the expected values for the MPG,
$\hat{y}_{i}$, and the residuals, $e_{i}$.


### Question

Plot the model fit and the residuals. Are the assumptions (linearity, constant
variance and independence) of the model valid? What does the model predict would
be the MPG for a car with the power of 400 horses?


### Question

Calculate the correlation coeffient, and $R^{2}$.


### Question

Calculate the confidence intervals on your estimates. Is the result significant?


### `statsmodels`

We are finally ready to use the `statsmodel` package. In the following code we
perform ordinary least squares regression and print out a summary. You can see
that all of the estimates agree with those we calculated above.

```python
my_lm = smf.ols("mpg ~ horsepower", df).fit()
print(my_lm.summary())
```
