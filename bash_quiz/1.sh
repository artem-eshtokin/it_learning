#!/bin/bash

# Проверка на два параметра
if [ $# -ne 2 ]; then
  echo "Usage: $0 <_name> <search_string>"
  exit 1
fi

# Проверка на директорию
if [ ! -d "$1" ]; then
  echo "Error: $1 is not a directory"
  exit 1
fi

# Прогонка по файлам директории
for file in "$1"/*; do
  if [ -f "$file" ] && [ -r "$file" ]; then
    if grep -q "$2" "$file"; then
      echo "$file"
    fi
  fi
done
