import pandas as pd
from scipy import stats
import numpy as np
from typing import List, Any
from functools import reduce


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
    num_flips = 10
    num_people = 15
    person_ids = range(num_people)
    num_outliers = 2
    probs_heads_list = ((num_people - num_outliers) * [0.5] +
                        num_outliers * [0.8])
    experiment_results = random_experiment(num_flips,
                                           person_ids,
                                           probs_heads_list)
    return experiment_results


if __name__ == '__main__':
    main()
