'''
Программа генерирует случайное число в диапазоне от 1 до заданной пользователем
границы и просит пользователя угадать это число. Если пользователь угадывает число,
то программа поздравляет и выводит сообщение с количеством попыток.
'''

import random

print('Добро пожаловать в числовую угадайку')

def is_level():
    rn = int(input('Укажите правую границу: '))
    a = random.randint(1,rn)
    return rn, a

def is_valid(s):
    return s.isdigit() and 1 <= int(s) <= rn

def input_num():
    while True:
        n = input(f'Угадайте число от 1 до {rn}: ')
        if is_valid(n) == False:
            print(f'А может быть все-таки введем целое число от 1 до {rn}?')
        else:
            return int(n)

def compare_num():
    count = 1
    while True:
        n = input_num()
        if n < a:
            print('Ваше число меньше загаданного, попробуйте еще разок')
            count += 1
        elif n > a:
            print('Ваше число больше загаданного, попробуйте еще разок')
            count += 1
        else:
            print(f'Вы угадали, поздравляем! Попыток: {count}')
            break

again = 'д'
while again.lower() == 'д':
    rn, a = is_level()
    compare_num()
    again = input('Сыграем еще раз? (д = да, н = нет): ')