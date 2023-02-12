#!/bin/bash

# Присвоение полученных параметров
dir_from="$1"
dir_to="$2"
min_size=${3:-0} # Размер, по-умолчанию 0
time_m=${4:-0} # Время, по-умолчанию 0

# Проверка параметров
if [ -z "$1" ] || [ -z "$2" ] || ! [ -d "$1" ] || ! [ -d "$2" ]; then
  echo "Check parameters"
  exit 1
fi

# Проверка указанного пути (относительный или абсолютный)
if ! [[ "$dir_from" = /* ]]; then
  dir_from="$(realpath "$dir_from")"
fi

if ! [[ "$dir_to" = /* ]]; then
  dir_to="$(realpath "$dir_to")"
fi

if [[ ! -d "$dir_from" ]]; then
  echo "Directory '$dir_from' not found"
  exit 1
fi

if [[ ! -d "$dir_to" ]]; then
  echo "Directory '$dir_to' not found"
  exit 1
fi

cd "$dir_from"

# Копирование, включая вложенные папки и файлы
find . -type f -size +"$min_size"c -mmin +"$((time_m * 60))" -print0 | while read -r -d '' file; do
  mkdir -p "$dir_to/$(dirname "$file")"
  cp "$file" "$dir_to/$file"
done

echo "Done"
