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

### Answer

```python
outcome_tbl = pd.crosstab(ra.Treatment, ra.Improved)
print(outcome_tbl)
```

### Question

Generate a mosaic plot to display this data.

[hint](https://www.statsmodels.org/dev/generated/statsmodels.graphics.mosaicplot.mosaic.html)

### Answer

```python
mosaic(ra, ['Treatment','Improved'], title = "Arthritis Treatment")
plt.show()
```

### (Bonus) question

What fundamental error does the default plot from `pandas` make?

### Answer

1. It uses red and green as the only colours which can be difficult for people
   with colour blindness.
2. It has not respected the implicit ordering of the response values.

The figure below makes the pattern in the data far clearer (at the expense of a
few extra lines of code).

```python
ra['Improved'] = pd.Series(
    pd.Categorical(ra.Improved,
                 categories=['None','Some','Marked'],
                 ordered=True))

props = lambda key: {'color': 'r' if 'a' in key else 'gray'}
props = {}
props[('Treated','Marked')] = {'color': '#b35806'}
props[('Treated','Some')] = {'color': '#f1a340'}
props[('Treated','None')] = {'color': '#fee0b6'}
props[('Placebo','Marked')] = {'color': '#d8daeb'}
props[('Placebo','Some')] = {'color': '#998ec3'}
props[('Placebo','None')] = {'color': '#542788'}

mosaic(ra, ['Treatment','Improved'], title = "Arthritis Treatment", properties=props)
plt.show()
```

### Question

For this trial, what was the null hypothesis?

### Answer

The null hypothesis is that any change in symptoms is independent of whether the
patient recieved the treatment or a placebo.

### Question

Is it valid to use a $\chi^{2}$-test for this data?

### Answer

We have more than 5 counts in each cell of the table, so we meet the rule of
thumb that says we can use the $\chi^{2}$-test. Be warned, some statisticians
would prefer that you had at least 10 in each cell.

### Question

How many degrees of freedom are there in this data?

### Answer

Two, because there are two rows of three columns and $(2 - 1)(3 - 1) = 2$.

### Question

Perform a $\chi^{2}$-test on the contingency table; are treatment and changes in
symptoms independent?

### Answer

The following code carries out the test and suggests we should reject the null
hypothesis.

```python
t = outcome_tbl.to_numpy()
col_sums = np.sum(t, axis=0)
row_sums = np.sum(t, axis=1)
total_sum = t.sum()

my_et = np.zeros((2,3))
for ix in range(2):
    for jx in range(3):
        my_et[ix,jx] = col_sums[jx] * row_sums[ix] / total_sum

print("Observed values")
print(t)
print("Expected values under null")
print(my_et)
print("Chi-squared statistic")
my_chi = (np.power(t - my_et, 2) / my_et).sum()
print(my_chi)
print("p-value")
print(1 - scipy.stats.chi2.cdf(my_chi, df=2))
```

```python
chi2, p, dof, expected = scipy.stats.chi2_contingency(outcome_tbl.to_numpy())
print(chi2)
print(p)
print(dof)
print(expected)
```

### (Bonus) Question

What can we conclude from this hypothesis test? Why do we need to randomise the
treatment?

### Answer

- We can conclude that treatment and changes in symptoms are not independent.
- Randomisation helps avoid confounding factors which lends more credibility to
  the conclusion that the treatment improves the condition.

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

### Answer

The false positive test suggests that the test will not be powerful enough on
smaller tables.

```python
num_trials = 10000
false_pos_count = 0
for _ in range(num_trials):
    x = rand_small_table()
    _, p, _, _ = scipy.stats.chi2_contingency(x)
    if p < 0.1:
        false_pos_count+=1
print(estimate_and_ci(num_trials, false_pos_count))
```
