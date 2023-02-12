#!/bin/bash

# Аргументы $1 папка, $2 таймер, $3 процент

# Проверка количества аргументов
if [ $# -ne 3 ]; then
  echo "Неверное количество аргументов."
  exit 1
fi

# Переменные
dir=$1
percent=$( echo "1 + $3/100" | bc -l ) # Перевод в десятичное

# Стартовые значения
size1=$(du -s $dir | awk '{print $1}')
size2=$size1
size3=$size1

while true
do
  sleep "$2s"
  # Новые значения для сравнения
  size1=$size2
  size2=$size3
  size3=$(du -s $dir | awk '{print $1}')
  # Сравнение
  if [ $(echo "$size2 / $size1 > $percent" | bc -l) -eq 1 ]
  then
    if [ $(echo "$size3 / $size2 > $percent" | bc -l) -eq 1 ]
    then
      touch warning.flg
      break
    fi
  fi
done