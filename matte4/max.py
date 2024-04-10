import numpy as np


def f(x):
    return -4 * np.sin(x) * np.cos(2 * x)


l = np.linspace(np.pi/6, np.pi/3, 100)
print(max(f(l))*((np.pi/6)**3) / 12)
print(-(4/3)*(np.pi*(1-np.sqrt(3))/96))
