import random

def quicksort(list):
    if len(list) < 2:
        return list
    pivot = list.pop(random.randrange(len(list)))
    less = [i for i in list if i < pivot]
    greater = [i for i in list if i > pivot]
    return quicksort(less) + [pivot] + quicksort(greater)

my_list = [1, 2, 10, 4, 5]
print(quicksort(my_list))
