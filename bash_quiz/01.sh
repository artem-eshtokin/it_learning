#!/bin/bash
echo -n "Input name directory: "
read name_dir

echo -n "Input string of text: "
read str_text

if [ ! -d "$name_dir" ]; 
then echo "$name_dir is not a directory"
  exit 1
else cd $name_dir
fi

echo; echo "Result:"

for file in *; do
  if [ -f "$file" ] && [ -r "$file" ]; then
    if grep -q "$str_text" "$file"; then
      echo "$file"
    fi
  fi
done
