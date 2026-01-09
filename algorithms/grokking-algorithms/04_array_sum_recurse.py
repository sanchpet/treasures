def sum_of_array(list):
    if len(list) == 0:
        return 0
    else:
        return list.pop() + sum_of_array(list)

def biggest_number(list):
    if len(list) == 1:
        return list[0]
    last = list.pop()
    max = biggest_number(list)
    if last > max:
        return last
    else:
        return max

my_list = [1, 2, 10, 4, 5]
print(sum_of_array(my_list[:]))
print(biggest_number(my_list[:]))
