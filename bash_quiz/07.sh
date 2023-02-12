#!/bin/bash

# Проверка количества аргументов
if [ $# -ne 2 ]; then
  echo "Неверное количество аргументов."
  exit 1
fi

# Переимование, чтобы не путаться
file=$1
string=$2

# Чтение файл
while read -r line; do
  # Поиск строк содержающую подстроку
  if echo "$line" | grep -q "$string"; then
    # Разбиваем строку на поля
    # <Строка_текста_без_пробелов>_<число1> current_offset: <число2> log_end_offset: <число3>
    # hello_world_1 current_offset: 13 log_end_offset: 25
    # hello_world_1 lag: 12  

    # строка текста
    text=$(echo "$line" | awk -F'[ ]' '{ print $1 }')
    # число1
    number1=$(echo "$line" | awk -F'[ ]' '{ print $1 }' | awk -F'[_]' '{ print $NF }')
    # число2
    number2=$(echo "$line" | awk -F'[ ]' '{ print $(NF-2) }')
    # число3
    number3=$(echo "$line" | awk -F'[ ]' '{ print $NF }')
    # lag
    lag=$((number3 - number2))
    # формирование новой строки (number1 для сортировки)
    result="$number1 $text lag: $lag"

    # добавляем в массив
    results+=("$result")
  fi
done < "$file"

# Сортировка
# вывод массива построчно | сортировка по первому полю | отсекаем первое поле
sorted_results=$(printf '%s\n' "${results[@]}" | sort -k1n | cut -d' ' -f2-)
echo "$sorted_results"
