'''
Программа шифровует и дешифрует текст в соответствии с алгоритмом Цезаря.
'''

def cesar_sh():
    abc = ['ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ']
    ch_lan = int(input('Выберите язык:\n0 - english, 1 - русский) '))
    key = int(input('Введите ключ: '))
    text = input('Введите сообщение: ')
    print('Ваше сообщение: ', end='')
    for c in text:
        if c.isalpha():
            char = abc[ch_lan][(abc[ch_lan].index(c.upper()) + key) % len(abc[ch_lan])]
            print(char if c.isupper() else char.lower(), end='')
        else:
            print(c, end='')
    print('\nThe End!')

def cesar_de():
    abc = ['ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ']
    ch_lan = int(input('Выберите язык:\n0 - english, 1 - русский) '))
    text = input('Введите сообщение: ')
    print('Варианты перебором: ')
    for i in range(len(abc[ch_lan])):
        key = int(ch_dir + str(i))
        for c in text:
            if c.isalpha():
                char = abc[ch_lan][(abc[ch_lan].index(c.upper()) + key) % len(abc[ch_lan])]
                print(char if c.isupper() else char.lower(), end='')
            else:
                print(c, end='')
        print()
    print('\nThe End!')

ch_dir = input('Выберите действие:\n(+) зашифровать, (-) расшифровать) ')

if ch_dir == '+':
    cesar_sh()
elif ch_dir == '-':
    cesar_de()