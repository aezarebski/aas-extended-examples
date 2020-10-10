import pandas as pd
from scipy import stats
import altair as alt
from typing import List, Any, Tuple
from functools import reduce
import math as math

EstimateAndCI = Tuple[float,Tuple[float,float]]


def wald_estimate_and_ci(num_trials: int, num_success: int) -> EstimateAndCI:
    p_hat = num_success / num_trials
    z = 1.96
    delta = z * math.sqrt(p_hat * (1 - p_hat) / num_trials)
    return (p_hat,(p_hat - delta, p_hat + delta))

def random_flips(num_flips: int,
                 prob_heads: float,
                 person_id: int) -> pd.DataFrame:
    coin_result = stats.bernoulli.rvs(p = prob_heads,
                                      size = num_flips)
    flip_number = range(1, num_flips + 1)
    flipper_id = num_flips * [person_id]
    return pd.DataFrame({"name": flipper_id,
                         "flip_number": flip_number,
                         "outcome": coin_result})


def random_experiment(num_flips: int,
                      person_ids: List[int],
                      prob_heads_list: List[float]) -> pd.DataFrame:
    rand_dfs = (random_flips(num_flips, prob, pid)
                for (prob,pid) in zip(prob_heads_list,person_ids))
    op = lambda df, x: df.append(x)
    return reduce(op, rand_dfs, pd.DataFrame())


def main():
    num_flips = 30
    num_people = 15
    person_ids = range(num_people)
    num_outliers = 2
    probs_heads_list = ((num_people - num_outliers) * [0.4] +
                        num_outliers * [0.95])
    experiment_results = random_experiment(num_flips,
                                           person_ids,
                                           probs_heads_list)

    bar = experiment_results.drop(columns = "flip_number").groupby("name").sum()
    bar["name"] = bar.index.copy()
    return bar


bar = main()
chart = alt.Chart(bar).mark_bar().encode(
    alt.X("outcome:Q", bin = True),
    y = 'count()'
)

# To actually display the chart use chart.show() to start a local server to
# display it.

bar2 = bar.loc[bar['outcome'] < 22]



# >>> bar['outcome'].sum()
# 206
# >>> wald_estimate_and_ci(30 * 15, 206)
# (0.4577777777777778, (0.41174514399055895, 0.5038104115649966))
# >>> bar2['outcome'].sum()
# 148
# >>> wald_estimate_and_ci(30 * 13, 148)
# (0.37948717948717947, (0.33132593489635276, 0.4276484240780062))

if __name__ == '__main__':
    main()
