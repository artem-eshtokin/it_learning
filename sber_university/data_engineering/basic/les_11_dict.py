print('Задание 1')
print('Задан словарь. Напишите программу, которая будет выводить значение по заданному ключу.')

dict1 = {'Hello' : 'Hi', 'Bye' : 'Goodbye', 'List' : 'Array'}
dict2 = {'beep' : 'car'}
dict3 = {'a' : 1, 'b' : 2, 'c' : 3, 'd' : 4, 'e' : 5}

print(dict1[input('Введите ключ словаря 1: ')])
print(dict2[input('Введите ключ словаря 2: ')])
print(dict3[input('Введите ключ словаря 3: ')])

print('\nЗадание 2')
print('Программа должна производить поиск по значению и выдавать ключ.')

i = list(dict1.values()).index(input('Введите значение словаря 1: '))
print(list(dict1.keys())[i])
i = list(dict2.values()).index(input('Введите значение словаря 2: '))
print(list(dict2.keys())[i])
i = list(dict3.values()).index(int(input('Введите значение словаря 3: ')))
print(list(dict3.keys())[i])



print('\nЗадание 3')
print('Напишите программу, которая принимает список строк и выводит количество повторений данных строк в списке.')

list1 = input('Введите список через запятую: ').split(', ')
print(list1)
dict1 = {}
for l in list1:
    i = dict1.setdefault(l, 0)
    dict1[l] = i + 1
print(*dict1.values())