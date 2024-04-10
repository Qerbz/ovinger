import numpy as np


def f(x):
    return np.e**(3*x)


xs = [(-(1/35)*np.sqrt(525+70*np.sqrt(30))),
      (-(1/35)*np.sqrt(525-70*np.sqrt(30))),
      ((1/35)*np.sqrt(525-70*np.sqrt(30))),
      ((1/35)*np.sqrt(525+70*np.sqrt(30)))]

ws = [(1/36)*(18-np.sqrt(30)),
      (1/36)*(18+np.sqrt(30)),
      (1/36)*(18+np.sqrt(30)),
      (1/36)*(18-np.sqrt(30))]

sum = 0

for i in range(4):
    sum += ws[i]*f(xs[i])

sum *= 3

print(sum)
