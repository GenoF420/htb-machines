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
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Obtener link de la resolución de la máquina en youtube ${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por nombre de máquina ${endColour}"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar panel de ayuda ${endColour}\n"
}

function searchMachine() {
  machineName="$1"

  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id|resuelta|sku" | tr -d '",' | sed 's/^ *//')"
  if [ "$machineName_checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando las propiedades de la máquina${endColour}${blueColour} $machineName${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id|resuelta|sku" | tr -d '",' | sed 's/^ *//'
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

#Indicadores
declare -i parameter_counter=0

# Ctrl_c
trap ctrl_c INT

while getopts "uy:m:i:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
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
else
  helpPanel
fi
