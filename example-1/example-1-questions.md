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

# Example 1

## Overview

This notebook reviews

- some of the aspects of the central limit theorem,
- confidence intervals,
- and hypothesis testing.

As usual we will start by importing some useful libraries. Recall from the
[previous
notebook](https://github.com/aezarebski/aas-extended-examples/tree/main/example-0)
that it is good practise to import these packages with the standard
abbreviations of their names.

```python
import pandas as pd
import numpy as np
import scipy.stats as stats
import matplotlib.pyplot as plt
```

## Probability Review


This section is a brief review of probability as a way to work towards the central limit theorem.


### Expected Value


For a real-valued random variable, the expected value is the average of the possible outcomes weighted by the respective probabilites of occuring.


### Question

Define a random variable X as follows: roll a fair six-sided die until a six is rolled, then record the total number of rolls required. What is the expected value of X?

We have answered this question mathematically below. Simulate this procedure and show the result with a chart to verify the math is correct.

<!-- #region -->
### Mathematical Answer

The expected value is given by the summation over all possible values of X multiplied by their probabilites:

$\mathbb{E}(X) = \sum_{i=1}^{\infty}i*P(X=i)$

For a fair die, the probability $P(X=i) = \frac{5}{6}^{i-1}*\frac{1}{6}$

The summation is then:

$\mathbb{E}(X) = \sum_{i=1}^{\infty}i*\frac{5}{6}^{i-1}*\frac{1}{6} = 1*\frac{5}{6}^{0}*\frac{1}{6} + 2*\frac{5}{6}^{1}*\frac{1}{6} + 3*\frac{5}{6}^{2}*\frac{1}{6} ... $

Recall that a geometric series is a series such that each term of the summation is equal to the previous term times some ratio $r$,

$a + ar + ar^2 + ar^3...$

and the sum of an infinite geometric series is $\frac{a}{1-r}$.

We can observe that this is a sum of several geometric series with $r=\frac{5}{6}$:

$\frac{5}{6}^{0}*\frac{1}{6} + 2*\frac{5}{6}^{1}*\frac{1}{6} + 3*\frac{5}{6}^{2}*\frac{1}{6}... = $

$\frac{5}{6}^{0}*\frac{1}{6} + \quad  \frac{5}{6}^{1}*\frac{1}{6}  + \quad \frac{5}{6}^{2}*\frac{1}{6}...$

$\qquad \quad + \quad  \frac{5}{6}^{1}*\frac{1}{6} + \quad \frac{5}{6}^{2}*\frac{1}{6}...$

$\qquad \quad + \qquad  \qquad + \quad \frac{5}{6}^{2}*\frac{1}{6}...$

The sum of each series is $\frac{a}{1-r}$ where $a$ is the first term, so this is equivalent to:

$\frac{\frac{1}{6}}{1-\frac{5}{6}} + \frac{\frac{5}{36}}{1-\frac{5}{6}} + \frac{\frac{25}{216}}{1-\frac{5}{6}}...$

$ = 1 + \frac{5}{6} + \frac{25}{36}...$

Which is itself a geometric series:

$\sum_{i=1}^{\infty}\frac{5}{6}^i = \frac{1}{1-\frac{5}{6}} = 6$

Therefore, $\mathbb{E}(X) = 6$


**NOTE:** As a shortcut, you could have noticed that this is one of the definitions of a geometric random variable and looked up the mean to find that it is $\frac{1}{p}$



<!-- #endregion -->

### Monte Carlo Approach

```python

```

## Central limit theorem

The central limit theorem (CLT) tells us about the distribution of the sample
mean as the number of observations grows. A lot of results in statistics rely on
the CLT, so it is worth getting familiar with the details. There are some
conditions that need to be satisfied for the CLT to hold, for example, we will
usually want to know that the samples are independent and identically
distributed (IID) and that they are drawn from a distribution with a finite
variance.

## CLT: Motivating example

### Question

Write the following functions:

1. A function called `rand_exp_mean` which takes a number, `n`, and a rate,
   `lam` and returns the sample average of `n` exponentially distributed (with
   rate `lam`) random variables. Note this should return a different value each
   time you call it.
2. A function called `rand_sample_means` which takes a number, `n` and a rate,
   `lam` and returns an array with 1000 evaluations of the function call
   `rand_exp_mean(n, lam)`. Note that a list comprehension may help here.

### Question

Make a histogram of the values from `rand_sample_means` in the question above
with `lam=0.2` and `n=5`. Plot the probability density function of a normal
distribution with mean $5$ and standard deviation $5 / \sqrt{5}$. Repeat whis
process with `n=100` and with a normal distribution with standard distribution
$5 / \sqrt{100}$. What do you notice?

## CLT: Theory

### Question

Write down a statement of the law of large numbers (LLN). Write down a
statement of the central limit theorem. Make sure you understand what
each of them tells you.


## Example: CLT

To see that the distribution of the sample mean converges to a normal
distribution we will do a simulation study.


### Question

Write down the distribution of the sample mean given an IID sample of
exponential random variables with rate $1/5$.


## Estimating the mean of a small sample

If we have a sample from a normal distribution with sample mean $\bar{x}$ and
known the standard deviation, $\sigma$, the $(1-\alpha)100\%$ CI for the
estimate of the mean is

$$
\bar{x} \pm z_{\alpha / 2} \frac{\sigma}{\sqrt{n}}
$$

where $z_{\alpha / 2}$ comes from the inverse CDF.

### Question

Simulate a set of 5 draws from a $N(1,1)$ distribution and, assuming the
standard deviation is known, check if the $95\%$ CI contains the true mean.


### Question

Now repeat this process 1000 times and check how many times it contains the true
mean. Do you think the coverage of the CI will be correct?


### Question

Now repeat this 1000-fold repetition using the sample standard deviation instead of the true standard deviation but treat it as though it is known, ie continue with $z_{\alpha / 2}$. Do you think the coverage of the CI will be correct?


### Question

Now repeat this process while accounting for the uncertainty in the standard deviation, ie use the $t_{\alpha / 2}$. How many degrees of freedom are there in the _t_-distribution? Do you think the coverage of the CI will be correct?


## Testing the hypothesis that a coin is fair

There is an election to choose between candidate _A_ and candidate _B_. To win the election a candidate needs to get the majority of the votes. Candidate _B_ declared victory but there is suspicion that they cheated. A random sample of $n$ ballots had $m$ votes for _A_. We want to know if we can reject the null hypothesis that _B_ did in fact win.


### Question

Would we reject the null if $n=100$ and $m=70$?


### Question

If $n=100$, how small would $m$ need to be for us to not be able to reject the null using this test?


## Parameter estimation of the binomial distribution

We want to make an *estimate* the probability that a coin comes up
heads. We also want to understand the level of confidence we have in
this estimate; we use a *confidence interval* (CI) to describe the range
of values we are confident the \"true\" probability of heads lies
within.

Binomial random variables can be used to model the number of times a
coin comes up heads when flipped $n$ times. Let $X$ be a binomial random
variable (RV) representing the number of heads that are observed when a
coin is flipped $n$ times and the probability of coming up heads is $p$.
We assume that $n$ is known but $p$ is unknown.

The expected value of $X$, ie the average number of times that the coin
comes up heads, is $np$. So a simple way to estimate $p$ is to divide
the number of heads, $X$, by the number of flips, $n$. This gives the
estimate

$$
\hat{p} = X / n.
$$

This estimator is called the [the method of
moments](https://en.wikipedia.org/wiki/Method_of_moments_(statistics)). This is
also an example of a maximum likelihood estimate (MLE).

Given an estimator, such as $\hat{p}$, we usually want to quantify the
uncertainty. One way to construct a CI is to approximate the sampling
distribution by a normal distribution. It is a bit crude, but it is acceptable
when we have lots of data. The estimated standard error of $\hat{p}$ is
$\sqrt{\hat{p}(1-\hat{p})/n}$, so the CI is given by

$$
\hat{p} \pm z \sqrt{\frac{\hat{p}(1-\hat{p})}{n}}
$$

where $z$ is the appropriate quantile of the standard normal distribution. In
the case of a $95\%$ distribution this value is $1.96$.


### Question

State the limitations on the estimator we are using for the CI.


### Question

Implement a function called `estimate_and_ci` which takes two
arguments: `num_trials` which is $n$ in the description above, and
`num_success` which is $X$ above. The function should return
`(p_hat,(ci_lower,ci_upper))` where `p_hat` is $\hat{p}$ and
`ci_x` are the limits of the $95\%$ CI.


### Question

Simulate a binomial random variable with $n=100$ and $p=0.6$. Then use
the value and the `estimate_and_ci` function to see how well you
can estimate $p$. Write a couple of sentences to explain this.

Recall that in a previous example we have looked at how to simulate
random variables using `scipy.stats`.


### Question

Repeat the process from the previous question 100000 times and see what
proportion of the CIs capture the true value of $p$. Is it what you
expect? Write a couple of sentences to explain what you found.
