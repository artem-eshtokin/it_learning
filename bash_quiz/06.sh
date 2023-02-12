#!/bin/bash

# Проверка количества аргументов
if [ $# -ne 4 ]; then
  echo "Неверное количество аргументов."
  exit 1
fi

# Проверяка директории источника
if [ ! -d "$1" ]; then
  echo "Директория источник не найдена"
  exit 1
fi

# Проверяка директории для архива
if [ ! -d "$4" ]; then
  echo "Директория для архива не найдена"
  exit 1
fi

# Текущая дата и время
current_date=$(date +%Y%m%d)
current_time=$(date +%H%M%S)

# Имя архива
archive_name="${current_date}_${current_time}_$(basename "$1").tar.gz"

# Поиск по маске и дате
# Если правильно понял задание "файлы(и только файлы)", то в архив попадают только файлы без директорий
find "$1" -type f -name "$2" -mmin +"$(( $3 * 60 ))" -print0 | xargs -0 tar --transform='s#.*/##' -czvf "$4/$archive_name"

# Удаление файлов
find "$1" -type f -name "$2" -mmin +"$3" -delete

echo "Архивация выполнена"
