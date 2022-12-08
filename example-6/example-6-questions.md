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

# Example 6

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
import statsmodels.tools.tools as smt
import matplotlib.pyplot as plt
```

# Salaries for Professors

The 2008--09 nine-month academic salary for Assistant Professors, Associate
Professors and Professors in a college in the U.S. The data were collected as
part of the on-going effort of the college's administration to monitor salary
differences between male and female faculty members.

- `rank` a factor with levels `AssocProf`` `AsstProf`` `Prof`.
- `discipline` a factor with levels `A` ("theoretical" departments) or ``B`` ("applied" departments).
- `yrs.since.phd` years since PhD.
- `yrs.service` years of service.
- `sex` a factor with levels `Female` `Male`.
- `salary` nine-month salary, in dollars.

This data comes with the `statsmodels` package along with some metadata. Here we
will rename a couple of variables so they are a bit easier to access.

```python
salaries_dataset = sm.datasets.get_rdataset("Salaries", "carData")
#print(salaries_dataset.__doc__)
salaries_df = salaries_dataset.data
salaries_df = salaries_df.rename(columns={"yrs.since.phd": "years_post_phd", "yrs.service": "years_service", "rank": "job"})
```

We can use a scatter plot to get an idea for how the salary changes. There is a
general trend that the salary increases through time, but the variance appears
to change.

```python
plt.figure()
plt.scatter(salaries_df.years_post_phd, salaries_df.salary)
plt.xlabel("Years post PhD", fontsize="large")
plt.ylabel("Salary", fontsize="large")
plt.show()
```

If we colour these points based on the professors' ranks a very different
pattern emerges

```python
jobs = salaries_df["job"].unique()

plt.figure()
for job in jobs:
    tmp = salaries_df[salaries_df["job"] == job]
    plt.scatter(tmp.years_post_phd, tmp.salary, label = job)
plt.legend(title = "Rank", title_fontsize = "large")
plt.xlabel("Years post PhD", fontsize="large")
plt.ylabel("Salary", fontsize="large")
plt.show()
```

### Question

What assumption of the variance component model clearly does not hold for this
data set?


# Simulation

Before we analyse this data we should familiarise ourselves with the
functionality provided by `statsmodels`. To have a data set where we know the
"true" values we will simulate a very similar dataset. Note that we have set the
mean values for each rank to the true values and set a constant scale across all
the jobs of $15000$ (note $15000^{2} = 225000000$). The "years post PhD" is
sampled randomly from a Poisson distribution with a relevant mean.

```python
demo_job = np.repeat(a=['Prof', 'AsstProf', 'AssocProf'], repeats=100)
demo_ypp = np.concatenate(
    (stats.poisson.rvs(30, size = 100),
    stats.poisson.rvs(5, size = 100),
    stats.poisson.rvs(15, size = 100)))

demo_salary_means = [126772,80775,93876]
demo_salary_scale = 15000
demo_salary = stats.norm.rvs(loc = np.repeat(a=demo_salary_means, repeats=100), scale = demo_salary_scale, size = 300)

demo_df = pd.DataFrame({'job': demo_job,
                      'years_post_phd': demo_ypp,
                       'salary': demo_salary})
demo_df = smt.add_constant(demo_df)

jobs = demo_df["job"].unique()
```

We can use the same plotting code from before to confirm that this is a relevant
dataset to work with.

```python
plt.figure()
for job in jobs:
    tmp = demo_df[demo_df["job"] == job]
    plt.scatter(tmp.years_post_phd, tmp.salary, label = job)
plt.title("Simulated data")
plt.legend(title = "Rank", title_fontsize = "large")
plt.xlabel("Years post PhD", fontsize="large")
plt.ylabel("Salary", fontsize="large")
plt.show()
```

### Question

As a way to get a rough idea of the components of the variance, estimate the
variance among the known means and use it to compute the variance partition
coefficient (VPC) for the simulated dataset. Obviously since we are estimating
the variance based on a data set of size 3 we should not put too much faith in
the results.

### Question

Write down a way to describe the salaries with a variance components model. What
parameters will be estimated?


### Question

The following cell fits this model to the data. What are the estimated parameter
values?

Hint: Due to an odd choice of names, the "Scale" parameter in the summary is the
individual level variance.

```python
mlm_0 = smf.mixedlm(formula = "salary ~ 1", data = demo_df, groups = demo_df.job).fit()
mlm_0.summary()
```

### Question

Does this look reasonable?


### Question

Compute the VPC from the model fit. Does it agree with the previous estimate?


### Question

Test whether including the effects of job is important in this model.


### Question

If we were to add `years_post_phd` as a covariate, what sort of model would this
be? What was the name given to this type of model in the lecture?


### Question

Fit the model including the `years_post_phd` as a covariate. Does this parameter
have a significant association?


### Question

Apply the methodology above to establish if `years_post_phd` has a significant
association with a Professor's salary while adjusting for random job-specific
effects.

### Question

How much of the variance is explained by the professors rank?
