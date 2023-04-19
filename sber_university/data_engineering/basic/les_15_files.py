def email_gen(list_of_names):
    emails = []
    for i in list_of_names:
        letter = 1
        while i[1] + '.' + i[0][0:letter] + '@company.io' in emails:
            letter+=1
        emails.append(i[1] + '.' + i[0][0:letter] + '@company.io')
    return emails

# print(email_gen([['Ivan', 'Petrov'], ['Ivan', 'Petrov'], ['Ivan', 'Petrov']]))

file_task = open('task_file.txt', 'r')

# Создаем временную матрицу из файла
temp_matrix = []
for line in file_task:
    if 'EMAIL, NAME, LAST_NAME, TEL, CITY' in line:
        continue
    temp_list = line.split(', ')
    for i in range(len(temp_list)):
        temp_list[i] = temp_list[i].strip()
    temp_matrix.append(temp_list)
file_task.close()

# Создаем временную валидную матрицу для генерации email
temp_gen_matrix = []
list_not_valid = []
for i in range(len(temp_matrix)):
    if temp_matrix[i][1] != '' and temp_matrix[i][2] != '' and temp_matrix[i][3] != '' and temp_matrix[i][4] != '' and len(temp_matrix[i][3]) == 7:
        temp_gen_matrix.append([temp_matrix[i][1], temp_matrix[i][2]])
    else:
        list_not_valid.append(i)
emails = email_gen(temp_gen_matrix)

# Собираем файл обратно
file_task = open('task_file_new.txt', 'w')
file_task.write('EMAIL, NAME, LAST_NAME, TEL, CITY\n')
j = 0
for i in range(len(temp_matrix)):
    if i not in list_not_valid:
        temp_matrix[i][0] = emails[j]
        file_task.write(', '.join(temp_matrix[i]) + '\n')
        j += 1
    else:
        file_task.write(', '.join(temp_matrix[i]) + '\n')
file_task.close()