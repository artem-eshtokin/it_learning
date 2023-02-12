#!/bin/bash

# Получаю имя владельца
u_name="$(stat -c '%U' ${BASH_SOURCE[0]})"

# Сравнение
if [ "${u_name}" != "${USER}" ]; then
    echo "You're not the owner!!!"
    exit 1
else
    echo OK
fi