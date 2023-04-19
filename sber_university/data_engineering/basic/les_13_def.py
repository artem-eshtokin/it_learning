def sum_num(list_nums):
    return list_nums[0] + list_nums[1]

def diff_num(list_nums):
    return list_nums[0] - list_nums[1]

def div_num(list_nums):
    return list_nums[0] / list_nums[1]

def mult_num(list_nums):
    return list_nums[0] * list_nums[1]

def perc_num(s):
    return int(s) / 100

def squar_num(s):
    return int(s) ** 2

def exp_num(list_nums):
    return list_nums[0] ** list_nums[1]

def division_into_arguments(sl, d):
    '''
    Функция принимает выражение и знак действия.
    Разделяет строку на элементы списка, удаляет пробелы и переводит в числа.
    :param sl: мат. выражение
    :param d: мат. действие
    :return: список
    '''
    final = [int(item) for item in sl.split(d)]
    # for i in range(len(final)):
    #     final[i] = final[i].strip()
    return final

def main_calc():
    s = input('Введите математическое выражение: ')
    if '+' in s:
        print(sum_num(division_into_arguments(s, '+')))
    elif '-' in s:
        print(diff_num(division_into_arguments(s, '-')))
    elif '/' in s:
        print(div_num(division_into_arguments(s, '/')))
    elif '%' in s:
        print(perc_num(s.replace('%', '')))
    elif '**' in s:
        if s.strip()[-2:] == '**':
            print(squar_num(s.replace('**', '')))
        else:
            print(exp_num(division_into_arguments(s, '**')))
    elif '*' in s:
        print(mult_num(division_into_arguments(s, '*')))
    else:
        print('Неизвестное выражение.')

flag = ''
while flag != 'n':
    main_calc()
    flag = input('Продолжить? (n - no): ')