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

# Example 5

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
```

In this notebook we will look at data on the mode of travel chosen by people
travelling between Sydney and Melbourne (Australia). Relevant variables for us
in this dataset are the mode of travel chosen: air, bus, car or train, the
travel time, the generalised cost of the journey, the income of the household
travelling, and the number of people travelling together. The relevant dataset
is provided by the `statsmodels` package.

```python
travel_dataset = sm.datasets.get_rdataset("TravelMode", "AER")
#print(travel_dataset.__doc__)
travel_df = travel_dataset.data
```

### Question

What units is the variable `income` in?

### Answer

Although it doesn't state it explicitly in the meta-data, it appears this is a
measure of income in thousands of Australian dollars. This can be guessed
because is on the order of the national average, although as a dataset from
1997, it is getting a bit old.

## Data exploration

As a first pass we will look at modelling whether the selected mode was train or
car. The following snippet puts the data in a tidy format. Note we have added a
new variable, `is_car`, which is `1` if the travel was done by car and `0` if it
was done by train. We will also subset the data to only contain those records
where the travellers had a choice in the mode of transport.

```python
cb_df = travel_df[(travel_df["mode"] == "train") | (travel_df["mode"] == "car")]
cb_df = cb_df[cb_df["choice"] == "yes"]
cb_df = cb_df[["mode", "income", "size"]]
cb_df = cb_df.rename(columns={"mode": "vehicle", "size": "num_people"})

predictor_names = ["income", "num_people"]

cb_df["is_car"] = 0
cb_df.loc[cb_df["vehicle"] == "car","is_car"] = 1
print(cb_df.head(10))
```

### Question

Generate visualisations to see how the distribution of income among car and
train trips. What do you notice?

[hint](https://aezarebski.github.io/misc/matplotlib/gallery.html#fig-06)

### Answer

The boxplots below show journeys by car are more likely to have individuals from
households with a larger income and transport more people.

```python tags=[]
print(cb_df.shape)
#cb_df.head(20)
unique_vehicles = cb_df.vehicle.unique()
grouped_values = {p : [cb_df[cb_df.vehicle == v][p] for v in unique_vehicles] for p in predictor_names}
```

```python
plt.figure()
plt.boxplot(x = grouped_values["income"],
           labels = unique_vehicles)
plt.title("Traveller income")
plt.show()
```

```python
plt.figure()
plt.boxplot(x = grouped_values["num_people"],
           labels = unique_vehicles)
plt.title("Number of people")
plt.show()
```

## Logistic model

### Question

Fit a logistic regression model to this data. Do the estimated coefficients make
sense?

[hint](https://www.statsmodels.org/stable/generated/statsmodels.formula.api.logit.html#statsmodels.formula.api.logit)

### Answer

We can use the `logit` function from `smf` to fit the logistic regression.

```python
logistic_model = smf.logit(formula="is_car ~ income + num_people", data = cb_df).fit()
```

```python
logistic_model.summary()
```

### Question

Write a function called `logit` which computes the logit function and
`inv_logit` which computes its inverse.

[hint](https://en.wikipedia.org/wiki/Logit#Definition)

### Answer

```python
def logit(p):
    return np.log(p / (1 - p))

def inv_logit(a):
    return np.exp(a) / (np.exp(a) + 1)
```

The following snippet demonstrates one way to visualise the results of the model
fit. If you have defined `logit` and `inv_logit` above this should make a
sensible figure.

```python
prob_is_car = logistic_model.predict()
log_odds_is_car = logit(prob_is_car)

plt.figure()
plt.scatter(log_odds_is_car, prob_is_car, label="Logistic regression")
plt.scatter(log_odds_is_car, cb_df["is_car"], label = "Data")
plt.legend()
plt.show()
```

### Question

For a fixed income, what change does the model predict for each additional
person on the journey? What happens to the log-odds for each additional person?
What happens to the odds?

### Answer

$$
\ln\left(\frac{p}{1-p}\right) = -2.2 + 0.06 \times \text{income} + 0.19 \times\text{num_people}
$$

For each additional person the *log-odds* of going by car increases by 0.19.

$$
\frac{p}{1-p} = e^{-2.2} (e^{0.06})^{\text{income}} + (e^{0.19})^{\text{num_people}}
$$

For each additional person the *odds* of going by car increase but the change is
not as simple as in the case of the log-odds.

### Question

For journeys with 2 people, plot the probability of going by car (as opposed to
train) as a function of household income. Determine the level of income at which
it becomes more likely they will travel by car than train.

### Answer

We can evaluate the predicted probability at a range of income levels and then
read off the plot that this changes at about 32.7 thousand, or we can just solve
for this value using the expression in the snippet.

```python
income_change_point = (2.23 - 0.189 * 2) / 0.0566
income_vals = np.linspace(10, 70, 100)

theta_int = logistic_model.params.Intercept
theta_income = logistic_model.params.income
theta_num = logistic_model.params.num_people

prob_car = inv_logit(theta_int + theta_income * income_vals + theta_num * 2)

plt.figure()
plt.plot(income_vals, prob_car)
plt.axhline(0.5, color='r')
plt.axvline(income_change_point, color='r')
plt.annotate("{x:.2f}".format(x=income_change_point), (income_change_point + 1, 0.2), color='r')
plt.show()
```

### Question

Plot the probability of going by car for 1, 2, and 3 people as a function of
income. What do you notice about the change in the probability as a function of
income?


### Answer

The change in probability is non-linear and depends upon the other variables,
but it is increasing with the number of people.

```python
income_vals = np.linspace(10, 70, 100)

theta_int = logistic_model.params.Intercept
theta_income = logistic_model.params.income
theta_num = logistic_model.params.num_people

prob_car_fn = lambda n : inv_logit(theta_int + theta_income * income_vals + theta_num * n)

plt.figure()
plt.plot(income_vals, prob_car_fn(1), color='r', label='One person')
plt.plot(income_vals, prob_car_fn(2), color='g', label='Two people')
plt.plot(income_vals, prob_car_fn(3), color='b', label='Three people')
plt.legend(loc='upper left')
plt.show()
```

## Bonus Example: Multinomial logistic regression

### Question

Set up a multinomial logistic regression model to predict the mode of transport
used based on all of the data.

### Answer

```python
all_df = travel_df[travel_df["choice"] == "yes"]
all_df = all_df[["mode", "income", "size"]]
all_df = all_df.rename(columns={"mode": "vehicle", "size": "num_people"})

all_df["vehicle_int"] = 0
all_df.loc[all_df["vehicle"] == "air","vehicle_int"] = 1
all_df.loc[all_df["vehicle"] == "bus","vehicle_int"] = 2
all_df.loc[all_df["vehicle"] == "car","vehicle_int"] = 3
all_df.loc[all_df["vehicle"] == "train","vehicle_int"] = 4
all_df.vehicle.value_counts()
```

```python
multi_logistic = smf.mnlogit(formula = "vehicle_int ~ income + num_people", data = all_df).fit()
multi_logistic.summary()
```
