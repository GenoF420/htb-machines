#!/bin/bash


#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#variablesGlobales
main_url="https://htbmachines.github.io/bundle.js"

function ctrl_c() {
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n\n"
  tput cnorm && exit 1
}

function helpPanel() {
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Descargar o actualizar archivos necesarios ${endColour}"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar panel de ayuda ${endColour}"
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Obtener link de la resolución de la máquina en youtube ${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por nombre de máquina ${endColour}"
  echo -e "\t${purpleColour}o)${endColour} ${grayColour}Buscar por el sistema operativo de la máquina ${endColour}"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}s)${endColour} ${grayColour}Buscar por skill${endColour}"
  echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar por la dificultad de la máquina${endColour}"
}

function searchMachine() {
  machineName="$1"

  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id|resuelta|sku" | tr -d '",' | sed 's/^ *//')"
  if [ "$machineName_checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando las propiedades de la máquina${endColour}${blueColour} $machineName${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|resuelta:|sku:" | tr -d '",' | sed 's/^ *//'
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe.${endColour}"
  fi
}

function updateFiles() {

  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Todos los archivos han sido descargados correctamente.${endColour}"
    tput cnorm
  else
    tput civis
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comprobando si hay actualizaciónes disponibles...${endColour}"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')

    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No se han detectado actualizaciónes, todo al día :D!${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Hay actualizaciónes disponibles, actualizando...${endColour}"
      rm bundle.js
      mv bundle_temp.js bundle.js
      sleep 1
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Los archivos se han actualizando correctamente.${endColour}"
    fi

    tput cnorm
  fi
}

function searchIp() {
  ipAddress="$1"
  machineName=$(grep "ip: \"$ipAddress\"" bundle.js -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d ',"')

  if [ $machineName ]; then
    echo -e "\n${yellowColour}La máquina correspondiente para la IP ${endColour}${blueColour}$ipAddress${endColour} ${grayColour}es${endColour} ${purpleColour}$machineName ${endColour}"
  else
     echo -e "\n${redColour}[!] La ip proporcionada no existe.${endColour}"
  fi
}

function getYoutubeLink() {
  machineName=$1
  youtubeLink=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep "youtube:" | awk 'NF{print $NF}' | tr -d '",')
  
  if [ $youtubeLink ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El tutorial para la máquina${endColour}${purpleColour} $machineName ${endColour}${grayColour}está en el siguiente enlace:${endColour} ${blueColour}$youtubeLink${endColour}"
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe ${endColour}"
  fi
}

function getMachinesDifficulty() {
  difficulty=$1
  machinesDifficulty="$(grep "dificultad: \"$difficulty\"" -B 5 bundle.js | grep name | awk 'NF{print $NF}' | tr -d '",' | column)"

  if [ "$machinesDifficulty" ]; then
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Representando las máquinas que poseen un nivel de dificultad${endColour} ${purpleColour}$difficulty ${endColour}${grayColour}:${endColour}\n"
  echo -e "\n$machinesDifficulty"
  else
    echo -e "\n${redColour}[!] No existen máquinas con la dificultad proporcionada ${endColour}\n"
  fi
}

function getOSMachines() {
  os=$1
  os_results="$(grep "so: \"$os\"" -B5 bundle.js | grep "name:" | awk 'NF{print $NF}' | tr -d '",' | column)"

  if [ "$os_results" ]; then
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Representando las máquinas cuyo sistema operativo es${endColour} ${purpleColour}$os ${endColour}${grayColour}:${endColour}"
    echo -e "\n$os_results"
  else
    echo -e "\n${redColour}[!] El sistema operativo no existe\n ${endColour}"
  fi
}

function getOSDifficultyMachines() {
  difficulty=$1
  os=$2
  check_results="$(grep "so: \"$os\"" -C4 bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '",' | column)"

  if [ "$check_results" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Representando las máquinas que poseen un nivel de dificultad${endColour} ${purpleColour}$difficulty${endColour}${grayColour} y sistema operativo ${endColour}${blueColour}$os${endColour}${grayColour}:${endColour}\n"
    echo -e "\n$check_results\n"
  else
    echo -e "\n${redColour}[!] Se ha indicado una dificultad o sistema operativo incorrecto\n ${endColour}"
  fi
}

function getSkill() {
  skill="$1"
  skill_check="$(grep "skills: " bundle.js -B 6 | grep "$skill" -i -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '",' | column)"

  if [ "$skill_check" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las maquinas que traten la skill${endColour} ${purpleColour}$skill${endColour}${grayColour}:${endColour}\n"
    echo -e "$skill_check\n"
  else  
   echo -e "\n${redColour}[!] No se han encontrado máquinas que requieran la skill indicada\n ${endColour}"
  fi
}


#Indicadores
declare -i parameter_counter=0

#Chivatos(?
declare -i chivato_difficulty=0
declare -i chivato_os=0

# Ctrl_c
trap ctrl_c INT

while getopts "uy:m:i:hd:o:s:" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
    o) os=$OPTARG; chivato_os=1; let parameter_counter+=6;;
    s) skill=$OPTARG; let parameter_counter+=7;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIp $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  getOSMachines $os
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
  getOSDifficultyMachines $difficulty $os
elif [ $parameter_counter -eq 7 ]; then
  getSkill "$skill"
else
  helpPanel
fi 
