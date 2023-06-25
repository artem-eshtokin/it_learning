#!/bin/bash
echo -n "Input name directory: "
read name_dir

if [ ! -d "$name_dir" ]; 
then echo "$name_dir is not a directory"
  exit 1
else cd $name_dir
fi

# Поиск максимального количества строк
max_rows=0

for file in *; do
  if [ -f "$file" ] && [ -r "$file" ]; then
    l_temp=$(wc -l < $file)
    if (( $l_temp > $max_rows )); then
      max_rows=$l_temp
    fi
  fi
done

echo "Result:"

# Сравнение количества строк файлов и вывод названия
for file in *; do
  if [ -f "$file" ] && [ -r "$file" ]; then
    if [ $(wc -l < $file) -eq $max_rows ]; then
      echo "$file"
    fi
  fi
done