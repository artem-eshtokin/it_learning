'''
На вход программе подается строка, содержащая строки-идентификаторы.
Программа исправляет их так, чтобы в результирующей строке не было дубликатов.
Для этого необходимо прибавлять к повторяющимся идентификаторам постфикс _n,
где n – количество раз, сколько такой идентификатор уже встречался.
'''

lst = input('Введите: ').split()
res = {}
for s in lst:
    res[s] = res.get(s, 0) + 1
tmp = []
for i in lst[::-1]:
    if res[i] - 1 > 0:
        tmp.append(str(i) + '_' + str(res[i] - 1))
        res[i] -= 1
    else:
        tmp.append(i)
print(*tmp[::-1])