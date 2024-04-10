from matplotlib import pyplot as plt
import random


def max_permutations(next):
    visited = next
    solution = []
    for node in range(len(next)):
        path = []
        if visited[node] is not False:
            while visited[node] is not False:
                path.append(node)
                visited[node], node = False, next[node]
            if next[node] != node and node in path:
                solution.append(len(path[path.index(node):]))
    return set(solution)


n = 1000
perms = []
for i in range(10_000):
    perms.append([random.randint(0, n-1) for _ in range(n)])

lengths = []
for i, perm in enumerate(perms):
    lengths += max_permutations(perm)

plt.hist(lengths, bins=100)
plt.show()
