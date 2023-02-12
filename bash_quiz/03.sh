#!/bin/bash

# Путь до скрипта
script_path="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

# Пути
cur_dir=$(pwd)
full_path=$(cd "$script_path" && pwd)
rel_path=$(realpath --relative-to="$cur_dir" "$(dirname "$0")") # Относительный путь не только из ветки, а из любого места

# Имя директории
dir_name=$(basename "$script_path")

# Вывод
echo $full_path
echo $rel_path
echo $dir_name