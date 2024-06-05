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
echo "1. Если хотите подключиться к настроенным хостам"
echo "2. Посмотреть содержимое конфигурационного файла"
echo "3. Добавить новый хост"
echo "4. Сделать бэкап конфигурационного файла"
echo "5. Сделать бэкап всех ключей"
read choose

date=$(date +%d-%m-%Y)

#Функция добавления хоста в файл ~/.ssh/config
add_host() {
cat <<EOF >> ~/.ssh/config
Host $host
   User $user
   Hostname $hostname
   Port $port
   IdentityFile $key
EOF
}

if [[ $choose == "2" ]]; then
   awk '{print "\033[31m" $0 "\033[0m"}' ~/.ssh/config
elif [[ $choose == "3" ]]; then
   echo "Введите имя хоста или IP-адрес"
   read host
   echo "Введите доменное имя или IP-адрес, если имени нет"
   read hostname
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
elif [[ $choose == "4" ]]; then
   cp ~/.ssh/config ~/.ssh/config.bak
   echo -e "\e[32mБэкап готов. Лежит в ~/.ssh/config.bak\e[0m"
elif [[ $choose == "5" ]]; then
   cd /home/$USER/.ssh
   tar -czf /home/$USER/Documents/keys_$date.tar.gz ./id_*
   echo -e "\e[32mБэкап ключей готов. Лежит в ~/Documents/keys_$date.tar.gz\e[0m"
elif [[ $choose == "1" ]]; then
    # Файл конфигурации SSH
    SSH_CONFIG="$HOME/.ssh/config"

    # Проверка наличия файла конфигурации
    if [[ ! -f "$SSH_CONFIG" ]]; then
        echo "Файл конфигурации SSH не найден: $SSH_CONFIG"
        exit 1
    fi

    # Чтение хостов из файла конфигурации и создание строки OPTIONS
    OPTIONS=()
    while read -r line; do
        if [[ $line =~ ^Host[[:space:]]+(.*) ]]; then
            host="${BASH_REMATCH[1]}"
            OPTIONS+=("$host" "$host")
        fi
    done < "$SSH_CONFIG"

    # Проверка, есть ли хосты
    if [[ ${#OPTIONS[@]} -eq 0 ]]; then
        echo "Хосты не найдены в файле конфигурации SSH."
    fi

    # Преобразование массива OPTIONS в строку
    OPTIONS_STR=""
    for ((i = 0; i < ${#OPTIONS[@]}; i += 2)); do
        OPTIONS_STR+="${OPTIONS[i]} ${OPTIONS[i+1]} "
    done

    # Параметры диалогового окна
    HEIGHT=15
    WIDTH=50
    CHOICE_HEIGHT=10
    TITLE="Выбор хоста"
    MENU="Выберите хост для подключения:"

    # Отображение меню с помощью whiptail
    CHOICE=$(whiptail --clear \
                      --backtitle "Выбор хоста SSH" \
                      --title "$TITLE" \
                      --menu "$MENU" \
                      $HEIGHT $WIDTH $CHOICE_HEIGHT \
                      $OPTIONS_STR \
                      3>&1 1>&2 2>&3)

    # Очистка экрана после закрытия диалога
    clear

    # Действие на основе выбора пользователя
    if [[ -n "$CHOICE" ]]; then
        echo "Вы выбрали хост: $CHOICE"
        hn=$(awk -v search="$CHOICE" '
        $0 ~ search {
             found = 1
             next
        }
        found && /Hostname/ {
            print $2
            exit
        }
        ' "$SSH_CONFIG")  
        un=$(awk -v search="$CHOICE" '
        $0 ~ search {
             found = 1
             next
        }
        found && /User/ {
            print $2
            exit
        }
        ' "$SSH_CONFIG")  
        pn=$(awk -v search="$CHOICE" '
        $0 ~ search {
             found = 1
             next
        }
        found && /Port/ {
            print $2
            exit
        }
        ' "$SSH_CONFIG")  
    ssh $un@$hn -p $pn
    else
        echo "Выбор хоста отменен."
    fi
fi
done
