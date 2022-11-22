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

# Example 4

This notebook is available on github
[here](https://github.com/aezarebski/aas-extended-examples). If you find
errors or would like to suggest an improvement, feel free to create an
issue.

As usual we will start by importing some useful libraries.

```python
%matplotlib inline
import statsmodels.api as sm
from statsmodels.graphics.mosaicplot import mosaic
import matplotlib.pyplot as plt
import pandas as pd
import scipy
import numpy as np
```

Today we will look at a dataset from a double-blind clinical trial of a new
treatment for rheumatoid arthritis. We will test whether treatment is correlated
with a change in symptoms using a $\chi^{2}$-test.

First, we need to load the data which comes bundled with `statsmodels`.

```python
ra = sm.datasets.get_rdataset("Arthritis", "vcd").data
ra.head()
```

### Question

Use `pandas` to generate a cross tabulation of the treatment status and
improvement.

[hint](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.crosstab.html)

### Question

Generate a mosaic plot to display this data.

[hint](https://www.statsmodels.org/dev/generated/statsmodels.graphics.mosaicplot.mosaic.html)

### (Bonus) question

What fundamental error does the default plot from `pandas` make?

### Question

For this trial, what was the null hypothesis?

### Question

Is it valid to use a $\chi^{2}$-test for this data?

### Question

How many degrees of freedom are there in this data?

### Question

Perform a $\chi^{2}$-test on the contingency table; are treatment and changes in
symptoms independent?

### (Bonus) Question

What can we conclude from this hypothesis test? Why do we need to randomise the
treatment?

Note that a proper treatment of *causality* goes well beyond the scope of this
course, but recall that randomised controlled trials provide very very high
quality evidence.

Recall from earlier notebooks the function `estimate_and_ci` which computes the
probability of success in repeated Bernoulli trials and the $95\%$ confidence
interval on this estimate.

```python
def estimate_and_ci(num_trials, num_success):
    p_hat = num_success / num_trials
    z = 1.96
    delta = z * np.sqrt(p_hat * (1 - p_hat) / num_trials)
    return (p_hat,(p_hat - delta, p_hat + delta))
```

The functions `rand_small_table` and `rand_big_table` defined below return
random datasets of the same shape as our arthritis dataset under the null
hypothesis, i.e. when the outcome is independent of treatment. The
`rand_small_table` returns data from a smaller cohort and the `rand_big_table`
returns data from a larger cohort.

```python
_, _, _, expected = scipy.stats.chi2_contingency(outcome_tbl.to_numpy())

def rand_small_table():
    x = np.array(0)
    while x.min() < 1:
        x = scipy.stats.poisson.rvs(mu = np.array(0.5) * expected)
    return x

def rand_big_table():
    x = np.array(0)
    while x.min() < 1:
        x = scipy.stats.poisson.rvs(mu = np.array(1.5) * expected)
    return x
```

### Question

Using the functions `estimate_and_ci`, and `rand_small_table` and
`rand_big_table`, demonstrate how the $\chi^{2}$-test will fail if the cell
values are too small.
