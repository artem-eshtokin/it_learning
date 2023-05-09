import pandas as pd
import numpy as np

from scipy.stats import norm, chi2, gamma


chat_id = 0 # Ваш chat ID, не меняйте название переменной

def solution(p: float, x: np.array) -> tuple:
    p = 1 - p
    n = len(x)
    x_s = np.square(x)
    R = np.sum(x_s)
    l_g = gamma.ppf(p/2, a = n, scale = 2/n)
    r_g = gamma.ppf(1 - p/2, a = n, scale = 2/n)
    sigma_left = np.sqrt( R / 14 / n / r_g)
    sigma_right = np.sqrt( R / 14 / n / l_g)
    return sigma_left, sigma_right