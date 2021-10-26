import pandas as pd
import numpy as np
import scipy.stats as stats
import matplotlib.pyplot as plt
from functools import reduce
from itertools import repeat

# TODO Remove this style of colouring

colours = {
    "green": "#7fc97f",
    "purple": "#beaed4",
    "orange": "#fdc086",
    "red": "#ef8a62",
    "blue": "#67a9cf"
}

def wald_estimate_and_ci(num_trials, num_success):
    p_hat = num_success / num_trials
    z = 1.96
    delta = z * np.sqrt(p_hat * (1 - p_hat) / num_trials)
    return (p_hat,(p_hat - delta, p_hat + delta))

rand_xs = stats.binom.rvs(n = 100, p = 0.6, size = 100000)

def ci_contains_value(ci, p):
    lower,upper = ci
    return lower < p and p < upper

p_in_ci_bools = [ci_contains_value(wald_estimate_and_ci(100, x)[1], 0.6) for x in rand_xs]

reduce(lambda a, b: a + 1 if b else a, p_in_ci_bools, 0) / 100000

sample_size = 200
num_replicates = 500

# TODO Use itertools.repeat instead of ugly list
sample_means = [stats.expon.rvs(scale = 5, size = sample_size).mean() 
                for _ in range(num_replicates)]

plot_df = pd.DataFrame({"sample_mean": sample_means})

mesh_size = 200

# TODO Use =numpy.linspace= here.
x_vals = [0.02 * ix + 3 for ix in range(0,mesh_size)]

clt_scale = 5 / np.sqrt(sample_size)

# TODO revise after =x_vals= gets updated.
clt_pdf = [stats.norm.pdf(x, loc = 5, scale = clt_scale)
           for x in x_vals]
clt_df = pd.DataFrame({"x": x_vals, "pdf": clt_pdf})

plt.figure()
plt.hist(plot_df.sample_mean, density=True,  color=colours["blue"])
plt.plot(clt_df.x, clt_df.pdf, color=colours["red"], linewidth=5)
plt.xlabel("Sample mean")
plt.ylabel("Density")
plt.show()

# TODO This could be much better with numpy
unit_mesh = [1 - (1 / len(sample_means)) * ix - (0.5 / len(sample_means)) for ix in range(0,len(sample_means))]
quantile_vals = [stats.norm.isf(u, loc = 5, scale = clt_scale) for u in unit_mesh]
sample_means.sort()
quant_df = pd.DataFrame({
    "sample_means": sample_means,
    "quantiles": quantile_vals})

ab_lims = [min(sample_means)-0.1, max(sample_means)+0.1]
abline_df = pd.DataFrame({"x": ab_lims, "y": ab_lims})

plt.figure()
plt.scatter(quant_df.sample_means, quant_df.quantiles, color=colours["blue"])
plt.plot(abline_df.x, abline_df.y, color=colours["red"])
plt.xlabel("Sample mean quantile")
plt.ylabel("Normal quantile")
plt.show()

exp1 = pd.read_csv("experiment1.csv")

head_counts = exp1.drop(columns="flip_number").groupby("name").sum()
head_counts["name"] = head_counts.index.copy()

total_heads = int(head_counts["outcome"].sum())
num_people = int(head_counts["name"].unique().size)
num_flips = int(exp1["name"].value_counts().unique())

est_and_ci = wald_estimate_and_ci(num_success=total_heads, 
                                  num_trials=num_people * num_flips)

print(est_and_ci)

k_vals = range(0,30+1)
# TODO This could be improved
k_probs = [stats.binom.pmf(k = k, n = num_flips, p = 0.540) for k in k_vals]
binom_dist_df = pd.DataFrame({"value": k_vals,
                              "prob": k_probs})

plt.figure()
plt.hist(head_counts.outcome, color=colours["blue"], density=True)
plt.plot(binom_dist_df.value, binom_dist_df.prob, color=colours["red"])
plt.xlabel("Number of heads")
plt.ylabel("Density")
plt.show()

stats.binom.pmf(k = 30, n = 30, p = 0.54)

head_counts_clean = head_counts.loc[head_counts["outcome"] < 30]

total_heads_clean = int(head_counts_clean["outcome"].sum())
num_people_clean = int(head_counts_clean["name"].unique().size)

wald_estimate_and_ci(num_success=total_heads_clean, num_trials=num_people_clean * num_flips)

k_vals = range(0,31)
k_probs = [stats.binom.pmf(k = k, n = num_flips, p = 0.415) for k in k_vals]
binom_dist_df = pd.DataFrame({"value": k_vals,
                              "prob": k_probs})

plt.figure()
plt.hist(head_counts_clean.outcome, color=colours["blue"], density=True)
plt.plot(binom_dist_df.value, binom_dist_df.prob, color=colours["red"])
plt.xlabel("Number of heads")
plt.ylabel("Density")
plt.show()

exp2 = pd.read_csv("experiment2.csv")

head_counts = exp2.drop(columns="flip_number").groupby("name").sum()
head_counts["name"] = head_counts.index.copy()

total_heads = int(head_counts["outcome"].sum())
num_people = int(head_counts["name"].unique().size)
num_flips = int(exp2["name"].value_counts().unique())

wald_estimate = wald_estimate_and_ci(num_success=total_heads, 
                                     num_trials=num_people * num_flips)

print(wald_estimate)

emp_var = head_counts["outcome"].var()
thry_var = stats.binom.var(n = num_flips, p = wald_estimate[0])
print(emp_var,thry_var)

plt.figure()
plt.scatter(head_counts.name, head_counts.outcome, color=colours["blue"])
plt.show()
