import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


# the data was taken from the UCI Machine Learning Repository: http://archive.ics.uci.edu/ml/datasets/Adult

header_file = "adult.header"
data_file = "adult.data"

with open(header_file) as f:
    header = f.readlines()[0].split(',')


df = pd.read_table(data_file, delimiter = ",", names=header)

print("The number of records is {num_records}".format(num_records = df.shape[0]))
print("The number of records with sex as female is {num_female}".format(num_female = df.sex.value_counts()[' Female']))
print("The mean age is {mean_age} with a standard deviation of {age_std}".format(mean_age = df.age.mean(), age_std = df.age.std()))

hpw_quantiles = dict(df['hours-per-week'].quantile([0.25,0.5,0.75]))
hpw_iqr = hpw_quantiles[0.75] - hpw_quantiles[0.25]
print("The median hours per week worked is {median_hpw} with an IQR of {iqr_hpw}".format(median_hpw = hpw_quantiles[0.5], iqr_hpw = hpw_iqr))



bin_breaks = np.linspace(start = df.age.min() - 0.5,
                         stop = df.age.max() + 0.5,
                         num = df.age.max() - df.age.min() + 2)
if False:
    plt.figure()
    plt.hist(df.age, bins = bin_breaks, density = False)
    plt.vlines(df.age.mean(), 0, 1000, color = 'r')
    plt.vlines([df.age.mean() - 2 * df.age.std(), df.age.mean() + 2 * df.age.std()], 0, 1000, color = 'r', linestyle='dashed')
    plt.xlabel("Age")
    plt.ylabel("Frequency")
    plt.show()


unique_sex = df.sex.unique()
age_grouped = [df[df.sex == sex]['age'] for sex in unique_sex]

if False:
    plt.figure()
    plt.boxplot(x = age_grouped, labels = unique_sex)
    plt.ylabel("Age")
    plt.show()

plt.figure()
plt.scatter(x = unique_sex, y = [d.median() for d in age_grouped], color = 'b')
for sex, data in zip(unique_sex, age_grouped):
    plt.plot([sex,sex], [data.min(), data.quantile(0.25)], color = 'b')
    plt.plot([sex,sex], [data.max(), data.quantile(0.75)], color = 'b')
plt.show()
