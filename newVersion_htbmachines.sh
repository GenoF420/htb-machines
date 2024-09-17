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
json_file="bundle.json"

# Funciones
function ctrl_c() {
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

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

function updateFiles() {
  tput civis
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
  curl -s $main_url -o bundle.js
  # Extraer el objeto JavaScript y convertirlo a JSON
  sed -n '/var machines = \[/,/\];/p' bundle.js | sed '1d;$d' > $json_file
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Todos los archivos han sido descargados correctamente.${endColour}"
  tput cnorm
}

function searchMachine() {
  local machineName="$1"
  local machineData

  machineData=$(jq ".[] | select(.name == \"$machineName\")" $json_file)
  if [[ -n "$machineData" ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Propiedades de la máquina${endColour}${blueColour} $machineName${endColour}${grayColour}:${endColour}\n"
    echo "$machineData" | jq
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe.${endColour}"
  fi
}

function searchIp() {
  local ipAddress="$1"
  local machineName

  machineName=$(jq -r ".[] | select(.ip == \"$ipAddress\") | .name" $json_file)
  if [[ -n "$machineName" ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}La máquina correspondiente a la IP${endColour} ${blueColour}$ipAddress${endColour} ${grayColour}es${endColour} ${purpleColour}$machineName${endColour}"
  else
    echo -e "\n${redColour}[!] La IP proporcionada no existe.${endColour}"
  fi
}

function getYoutubeLink() {
  local machineName="$1"
  local youtubeLink

  youtubeLink=$(jq -r ".[] | select(.name == \"$machineName\") | .youtube" $json_file)
  if [[ -n "$youtubeLink" && "$youtubeLink" != "null" ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El tutorial para la máquina${endColour}${purpleColour} $machineName ${endColour}${grayColour}está en el siguiente enlace:${endColour} ${blueColour}$youtubeLink${endColour}"
  else
    echo -e "\n${redColour}[!] No se encontró enlace de YouTube para la máquina proporcionada.${endColour}"
  fi
}

function getMachinesByDifficulty() {
  local difficulty="$1"
  local machines

  machines=$(jq -r ".[] | select(.dificultad == \"$difficulty\") | .name" $json_file)
  if [[ -n "$machines" ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Máquinas con dificultad${endColour} ${purpleColour}$difficulty${endColour}${grayColour}:${endColour}\n"
    echo "$machines" | column
  else
    echo -e "\n${redColour}[!] No se encontraron máquinas con la dificultad proporcionada.${endColour}"
  fi
}

function getMachinesByOS() {
  local os="$1"
  local machines

  machines=$(jq -r ".[] | select(.so == \"$os\") | .name" $json_file)
  if [[ -n "$machines" ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Máquinas con sistema operativo${endColour} ${purpleColour}$os${endColour}${grayColour}:${endColour}\n"
    echo "$machines" | column
  else
    echo -e "\n${redColour}[!] No se encontraron máquinas con el sistema operativo proporcionado.${endColour}"
  fi
}

function getMachinesBySkill() {
  local skill="$1"
  local machines

  machines=$(jq -r ".[] | select(.skills[]? | contains(\"$skill\")) | .name" $json_file)
  if [[ -n "$machines" ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Máquinas que requieren la habilidad${endColour} ${purpleColour}$skill${endColour}${grayColour}:${endColour}\n"
    echo "$machines" | column
  else
    echo -e "\n${redColour}[!] No se encontraron máquinas que requieran la habilidad indicada.${endColour}"
  fi
}

function getMachinesByOSAndDifficulty() {
  local os="$1"
  local difficulty="$2"
  local machines

  machines=$(jq -r ".[] | select(.so == \"$os\" and .dificultad == \"$difficulty\") | .name" $json_file)
  if [[ -n "$machines" ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Máquinas con sistema operativo${endColour} ${purpleColour}$os${endColour} ${grayColour}y dificultad${endColour} ${purpleColour}$difficulty${endColour}${grayColour}:${endColour}\n"
    echo "$machines" | column
  else
    echo -e "\n${redColour}[!] No se encontraron máquinas con los criterios proporcionados.${endColour}"
  fi
}

# Manejo de Señales y Parámetros
trap ctrl_c INT

declare -i parameter_counter=0

while getopts "uy:m:i:hd:o:s:" arg; do
  case $arg in
    u) updateFiles; exit 0;;
    h) helpPanel; exit 0;;
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    i) ipAddress="$OPTARG"; let parameter_counter+=2;;
    y) machineName="$OPTARG"; let parameter_counter+=3;;
    d) difficulty="$OPTARG"; let parameter_counter+=4;;
    o) os="$OPTARG"; let parameter_counter+=5;;
    s) skill="$OPTARG"; let parameter_counter+=6;;
    *) helpPanel; exit 1;;
  esac
done

# Verificar si el archivo JSON existe
if [[ ! -f "$json_file" ]]; then
  echo -e "\n${redColour}[!] El archivo $json_file no existe. Por favor, ejecuta la opción -u para descargarlo.${endColour}"
  exit 1
fi

# Lógica para Ejecutar Funciones Basadas en Parámetros
if [[ $parameter_counter -eq 1 ]]; then
  searchMachine "$machineName"
elif [[ $parameter_counter -eq 2 ]]; then
  searchIp "$ipAddress"
elif [[ $parameter_counter -eq 3 ]]; then
  getYoutubeLink "$machineName"
elif [[ $parameter_counter -eq 4 ]]; then
  getMachinesByDifficulty "$difficulty"
elif [[ $parameter_counter -eq 5 ]]; then
  getMachinesByOS "$os"
elif [[ $parameter_counter -eq 9 ]]; then
  getMachinesByOSAndDifficulty "$os" "$difficulty"
elif [[ $parameter_counter -eq 6 ]]; then
  getMachinesBySkill "$skill"
else
  helpPanel
fi
