from time import perf_counter
import cProfile
import random


def max_permutations(next):
    visited = [False] * len(next)
    result = set()

    for node in range(len(next) - 1):
        if not visited.__getitem__(node):
            visited.__setitem__(node, True)
            if not visited.__getitem__(next.__getitem__(node)):
                next_node = next.__getitem__(node)
                if visited.__getitem__(next.__getitem__(next_node)):
                    visited.__setitem__(node, True)
                    if next.__getitem__(next_node) == node:
                        result.update([node, next_node])
                else:
                    path = list().append(1)
                    node = next.__getitem__(node)
                    while not visited.__getitem__(node):
                        path.append(node)
                        visited.__setitem__(node, True)
                        node = next.__getitem__(node)
                    if node in path:
                        index = path.index(node)
                        if len(path) - index > 1:
                            result.update(path.__getitem__(slice(index, None)))
    return result


n = 1_000_000
next = [random.randint(0, n-1) for _ in range(n)]
cProfile.run(f"max_permutations({next})", sort="cumtime")
