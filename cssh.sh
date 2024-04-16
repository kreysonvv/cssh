#!/usr/bin/env bash

while true; do
cat << 'EOF'
                                    
   ####    #####    #####   ##   ## 
  ##  ##  ##   ##  ##   ##  ##   ## 
 ##       ##       ##       ##   ## 
 ##        #####    #####   ####### 
 ##            ##       ##  ##   ## 
  ##  ##  ##   ##  ##   ##  ##   ## 
   ####    #####    #####   ##   ## 
                                    
                                    
EOF

echo " +--------------------------------+"
echo " |   Утилита для настройки SSH    |"
echo " +--------------------------------+"
echo "1. Посмотреть содержимое конфигурационного файла"
echo "2. Добавить новый хост"
echo "3. Сделать бэкап конфигурационного файла"
read choose

if [[ $choose == "1" ]]; then
   cat ~/.ssh/config
elif [[ $choose == "2" ]]; then
   echo "Введите имя хоста или IP-адрес, если имени нет"
   read host
   echo "Введите пользователя"
   read user
   echo "Введите порт для SSH"
   read port
   echo "Введите имя закрытого ключа (например  ~/.ssh/id_ed25519). Или newkey, если ключа ещё нет."
   read key
   if [[ $key == "newkey" ]]; then
      ssh-keygen -t ed25519
      cat <<EOF >> ~/.ssh/config
      Host $host
         User $user
         Hostname $host
         Port $port
         IdentityFile $key
EOF
   else
      cat <<EOF >> ~/.ssh/config
      Host $host
         User $user
         Hostname $host
         Port $port
         IdentityFile $key
EOF
   fi
elif [[ $choose == "3" ]]; then
   tar -czvf ~/ssh_config_$USER.tar.gz ~/.ssh/config

fi
done