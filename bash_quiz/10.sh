#!/bin/bash

while true
do
  random_num=$((RANDOM % 10001))
  echo '#!/bin/bash' > "${random_num}.sh"
  echo 'while true' >> "${random_num}.sh"
  echo 'do' >> "${random_num}.sh"
  echo '  sleep 1 # Чтобы не грузить' >> "${random_num}.sh"
  echo 'done' >> "${random_num}.sh"
  bash "${random_num}.sh"
  sleep 15
done 