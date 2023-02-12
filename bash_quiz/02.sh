#!/bin/bash
echo -n "Input name directory: "
read name_dir

if [ ! -d "$name_dir" ]; then
  echo "$name_dir is not a directory"
  exit 1
else 
  cd "$name_dir"
fi

max_rows=0

# Поиск максимального количества строк
for n_file in $(find "$name_dir" -type f); do
  if [ -f "$n_file" ] && [ -r "$n_file" ]; then
    l_temp=$(wc -l < "$n_file")
    if (( $l_temp > $max_rows )); then
      max_rows=$l_temp
    fi
  fi
done

echo "Result:"

# Сравнение количества строк файлов и вывод названия
for n_file in $(find "$name_dir" -type f); do
  if [ -f "$n_file" ] && [ -r "$n_file" ]; then
    if [ $(wc -l < "$n_file") -eq $max_rows ]; then
      echo "$n_file"
    fi
  fi
done
