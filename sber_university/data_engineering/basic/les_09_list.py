print('Задание 1')
print('Задан список. Напишите программу, которая выводит элементы списка с четными индексами в виде нового списка.')
list1 = [1, 2, 3, 4, 5]
list2 = [9, 4, 5, 2, 3]
list3 = [7, 8]
list4 = [90, 45, 3, 43]
list_all = [list1, list2, list3, list4]

for l in list_all:
    list_new = [l[i] for i in range(0, len(l), 2)]
    print(l)
    print(list_new)


print('\nЗадание 2')
print('Задан список с числами. Напишите программу, которая выводит все элементы списка, которые больше предыдущего, в виде отдельного списка.')

list1 = [1, 5, 2, 4, 3]
list2 = [1, 2, 3, 4, 5]
list3 = [5, 4, 3, 2, 1]
list4 = [1, 5, 1, 5, 1]

list_all = [list1, list2, list3, list4]
for l in list_all:
    list_new = [l[i] for i in range(1, len(l)) if l[i] > l[i-1]]
    print(l)
    print(list_new)


print('\nЗадание 3')
print('Задан список с числами. Напишите программу, которая меняет местами наибольший и наименьший элемент и выводит новый список.')

list1 = [3, 4, 5, 2, 1]
list2 = [-3000, 3000]
list3 = [1, 2, 3, 4, 5, 6, 7]
list4 = [-5, 5, 10]
list_all = [list1, list2, list3, list4]

for l in list_all:
    print(l)
    num_min = l[0]
    index_min = 0
    num_max = l[0]
    index_max = 0
    for i in range(0, len(l)):
        if l[i] < num_min:
            num_min = l[i]
            index_min = i
        if l[i] > num_max:
            num_max = l[i]
            index_max = i
    l[index_min], l[index_max] = l[index_max], l[index_min]
    print(l)