import time

a = [0]
b = a.__getitem__

t1 = time.perf_counter()
l = [0]
t2 = time.perf_counter()
print(t2-t1)
