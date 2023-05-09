import pandas as pd
import numpy as np
import scipy.stats as sps
from statsmodels.stats.proportion import proportions_ztest

chat_id = 0 # Ваш chat ID, не меняйте название переменной

def solution(x_success: int, 
             x_cnt: int, 
             y_success: int, 
             y_cnt: int) -> bool:
    alpha = 0.08
    stat, pval = proportions_ztest(count=[x_success, y_success], 
                                   nobs=[x_cnt, y_cnt],
                                   alternative='smaller')
    return pval < alpha