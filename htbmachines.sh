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
  exit 1
}

function helpPanel() {
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por nombre de máquina ${endColour}"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar panel de ayuda ${endColour}\n"
}

function searchMachine() {
  machineName="$1"
  echo "$machineName"
}

function updateFiles() {
  if [ ! -f bundle.js ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Todos los archivos han sido descargados${endColour}"
  else
    echo -e "\n[!] El archivo ya existe"
  fi
}

#Indicadores
declare -i parameter_counter=0

# Ctrl_c
trap ctrl_c INT

while getopts "m:uh" arg; do
  case $arg in
    m) machine_name=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machine_name
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
else
  helpPanel
fi
