#!/bin/bash

# Colores
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Variables Globales
main_url="https://htbmachines.github.io/bundle.js"

# Función para manejar Ctrl+C
function ctrl_c() {
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

# Función para mostrar el panel de ayuda
function helpPanel() {
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Descargar o actualizar archivos necesarios ${endColour}"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar panel de ayuda ${endColour}"
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Obtener link de la resolución de la máquina en YouTube ${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por nombre de máquina ${endColour}"
  echo -e "\t${purpleColour}o)${endColour} ${grayColour}Buscar por el sistema operativo de la máquina ${endColour}"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}s)${endColour} ${grayColour}Buscar por skill${endColour}"
  echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar por la dificultad de la máquina${endColour}"
}

# Función para buscar una máquina por nombre
function searchMachine() {
  local machineName="$1"

  local machineInfo
  machineInfo=$(awk "/name: \"$machineName\"/,/resuelta:/" bundle.js | grep -vE "id|resuelta|sku" | tr -d '",' | sed 's/^ *//')

  if [ -n "$machineInfo" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Propiedades de la máquina${endColour}${blueColour} $machineName${endColour}${grayColour}:${endColour}\n"
    echo "$machineInfo"
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe.${endColour}"
  fi
}

# Función para actualizar los archivos necesarios
function updateFiles() {
  tput civis
  if [ ! -f bundle.js ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
    curl -s $main_url -o bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Todos los archivos han sido descargados correctamente.${endColour}"
  else
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comprobando si hay actualizaciones disponibles...${endColour}"
    curl -s $main_url -o bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js

    local md5_temp_value md5_original_value
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')

    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No se han detectado actualizaciones, todo al día :D!${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Hay actualizaciones disponibles, actualizando...${endColour}"
      mv bundle_temp.js bundle.js
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Los archivos se han actualizado correctamente.${endColour}"
    fi
  fi
  tput cnorm
}

# Función para buscar una máquina por IP
function searchIp() {
  local ipAddress="$1"
  local machineName

  machineName=$(grep "ip: \"$ipAddress\"" bundle.js -B 5 | grep "name:" | awk -F'"' '{print $2}')

  if [ -n "$machineName" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}La máquina correspondiente a la IP${endColour} ${blueColour}$ipAddress${endColour} ${grayColour}es${endColour} ${purpleColour}$machineName${endColour}"
  else
    echo -e "\n${redColour}[!] La IP proporcionada no existe.${endColour}"
  fi
}

# Función para obtener el enlace de YouTube de una máquina
function getYoutubeLink() {
  local machineName="$1"
  local youtubeLink

  youtubeLink=$(awk "/name: \"$machineName\"/,/resuelta:/" bundle.js | grep "youtube:" | awk -F'"' '{print $2}')

  if [ -n "$youtubeLink" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El tutorial para la máquina${endColour}${purpleColour} $machineName ${endColour}${grayColour}está en el siguiente enlace:${endColour} ${blueColour}$youtubeLink${endColour}"
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe o no tiene enlace de YouTube.${endColour}"
  fi
}

# Función para obtener máquinas por dificultad
function getMachinesDifficulty() {
  local difficulty="$1"
  local machines

  machines=$(grep "dificultad: \"$difficulty\"" bundle.js -B 5 | grep "name:" | awk -F'"' '{print $2}' | column)

  if [ -n "$machines" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Máquinas con dificultad${endColour} ${purpleColour}$difficulty${endColour}${grayColour}:${endColour}\n"
    echo "$machines"
  else
    echo -e "\n${redColour}[!] No existen máquinas con la dificultad proporcionada.${endColour}"
  fi
}

# Función para obtener máquinas por sistema operativo
function getOSMachines() {
  local os="$1"
  local machines

  machines=$(grep "so: \"$os\"" bundle.js -B 5 | grep "name:" | awk -F'"' '{print $2}' | column)

  if [ -n "$machines" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Máquinas con sistema operativo${endColour} ${purpleColour}$os${endColour}${grayColour}:${endColour}\n"
    echo "$machines"
  else
    echo -e "\n${redColour}[!] No existen máquinas con el sistema operativo proporcionado.${endColour}"
  fi
}

# Función para obtener máquinas por sistema operativo y dificultad
function getOSDifficultyMachines() {
  local difficulty="$1"
  local os="$2"
  local machines

  machines=$(grep "dificultad: \"$difficulty\"" bundle.js -C7 | grep "so: \"$os\"" -B7 | grep "name:" | awk -F'"' '{print $2}' | column)

  if [ -n "$machines" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Máquinas con dificultad${endColour} ${purpleColour}$difficulty${endColour} ${grayColour}y sistema operativo${endColour} ${purpleColour}$os${endColour}${grayColour}:${endColour}\n"
    echo "$machines"
  else
    echo -e "\n${redColour}[!] No existen máquinas con los criterios proporcionados.${endColour}"
  fi
}

# Función para obtener máquinas por skill
function getSkill() {
  local skill="$1"
  local machines

  machines=$(grep -i "skills: " bundle.js -B 6 | grep -i "$skill" -B 6 | grep "name:" | awk -F'"' '{print $2}' | column)

  if [ -n "$machines" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Máquinas que requieren la habilidad${endColour} ${purpleColour}$skill${endColour}${grayColour}:${endColour}\n"
    echo "$machines"
  else
    echo -e "\n${redColour}[!] No se han encontrado máquinas que requieran la skill indicada.${endColour}"
  fi
}

# Manejo de señales
trap ctrl_c INT

# Inicialización de variables
declare -i parameter_counter=0
declare -i flag_difficulty=0
declare -i flag_os=0

# Procesamiento de opciones
while getopts "uy:m:i:hd:o:s:" arg; do
  case $arg in
    u) updateFiles; exit 0;;
    h) helpPanel; exit 0;;
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    i) ipAddress="$OPTARG"; let parameter_counter+=2;;
    y) youtubeMachine="$OPTARG"; let parameter_counter+=3;;
    d) difficulty="$OPTARG"; flag_difficulty=1; let parameter_counter+=4;;
    o) os="$OPTARG"; flag_os=1; let parameter_counter+=5;;
    s) skill="$OPTARG"; let parameter_counter+=6;;
    *) helpPanel; exit 1;;
  esac
done

# Verificación de que bundle.js existe
if [ ! -f bundle.js ]; then
  echo -e "\n${redColour}[!] El archivo bundle.js no existe. Por favor, ejecuta la opción -u para descargarlo.${endColour}"
  exit 1
fi

# Ejecución de funciones según opciones proporcionadas
if [ $parameter_counter -eq 1 ]; then
  searchMachine "$machineName"
elif [ $parameter_counter -eq 2 ]; then
  searchIp "$ipAddress"
elif [ $parameter_counter -eq 3 ]; then
  getYoutubeLink "$youtubeMachine"
elif [ $flag_difficulty -eq 1 ] && [ $flag_os -eq 0 ]; then
  getMachinesDifficulty "$difficulty"
elif [ $flag_os -eq 1 ] && [ $flag_difficulty -eq 0 ]; then
  getOSMachines "$os"
elif [ $flag_difficulty -eq 1 ] && [ $flag_os -eq 1 ]; then
  getOSDifficultyMachines "$difficulty" "$os"
elif [ $parameter_counter -eq 6 ]; then
  getSkill "$skill"
else
  helpPanel
fi
