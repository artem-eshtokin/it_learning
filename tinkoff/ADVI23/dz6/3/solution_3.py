import pandas as pd
import numpy as np
from scipy.stats import ttest_1samp

chat_id = 0 # Ваш chat ID, не меняйте название переменной

def solution(x: pd.Series) -> bool:
    alpha = 0.04
    threshold = 300
    t_statistic, p_value = ttest_1samp(x, threshold)
    return p_value/2 < alpha and t_statistic < 0