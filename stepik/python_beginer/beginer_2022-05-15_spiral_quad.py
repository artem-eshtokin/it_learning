'''
На вход программе подаются два натуральных числа.
Напишите программу, которая создает матрицу размером
n×m заполнив её "спиралью".
'''

from math import ceil

n, m = [int(i) for i in input('Введите размер четырехугольника (9 5): ').split()]
mtx = [[0] * m for _ in range(n)]
cnt = 1

n1, m1 = 0, 0
n2, m2 = n, m
i, j = 0, 0
for q in range(ceil(min(n, m) / 2)):
    i = q
    for j in range(m1, m2):
        mtx[i][j] = cnt
        cnt += 1
    for i in range(n1 + 1, n2):
        mtx[i][j] = cnt
        cnt += 1

    if n == 1 or m == 1:
        continue
    else:
        for j in range(m1 + 2, m2 + 1):
            mtx[i][-j] = cnt
            cnt += 1
        for i in range(n1 + 2, n2):
            mtx[-i][-j] = cnt
            cnt += 1
    m1 += 1
    n1 += 1
    m2 -= 1
    n2 -= 1

for i in range(n):
    for j in range(m):
        print(str(mtx[i][j]).ljust(2), end=' ')
    print()