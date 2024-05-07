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
echo "4. Сделать бэкап всех ключей"
read choose

date=$(date +%d-%m-%Y)

#Функция добавления хоста в файл ~/.ssh/config
add_host() {
cat <<EOF >> ~/.ssh/config
Host $host
   User $user
   Hostname $host
   Port $port
   IdentityFile $key
EOF
}

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
      echo "Введите имя для ключа, например github"
      read key_name
      echo "" | ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_$key_name
      key=$(echo ~/.ssh/id_ed25519_$key_name)
      add_host
      echo -e "\e[32mКлюч создан и запись добавлена в файл config\e[0m"
   else
      add_host
      echo -e "\e[32mЗапись добавлена в файл config\e[0m"
   fi
elif [[ $choose == "3" ]]; then
   cp ~/.ssh/config ~/.ssh/config.bak
   echo -e "\e[32mБэкап готов. Лежит в ~/.ssh/config.bak\e[0m"
elif [[ $choose == "4" ]]; then
   tar -czf ~/.ssh/keys_$date.tar.gz ~/.ssh/id_*
   echo -e "\e[32mБэкап ключей готов. Лежит в ~/.ssh/keys_$date.tar.gz\e[0m"
fi
done