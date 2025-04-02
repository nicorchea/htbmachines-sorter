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

#Ctrl_C
trap ctrl_c INT

function ctrl_c() {
    echo -e "\n\n${redColour}[!] Saliendo... ${endColour}\n"
    tput cnorm && exit 1
}

#Variables Globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel() {
    echo -e "\n${yellowColour}[+]${endColour}${grayColour}Uso:${endColour}"
    echo -e "\t${purpleColour}u)${endColour} ${grayColour}Actualizar lista de maquinas${endColour}"
    echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por un nombre de maquina${endColour}"
    echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por un direccion IPs${endColour}"
    echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar este panel de ayuda${endColour}"
}

function updateFiles() {

    if [ ! -f bundle.js ]; then
        echo -e "\n${yellowColour}[+]${endColour} Descargando archivos necesarios..."
        curl -s $main_url >bundle.js
        js-beautify bundle.js | sponge bundle.js
        echo -e "\n${yellowColour}[+]${endColour} La descarga se a realizado con exito!"
        tput cnorm

    else
        curl -s $main_url >bundle_temp.js
        js-beautify bundle_temp.js | sponge bundle_temp.js
        md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
        md5_original_value=$(md5sum bundle.js | awk '{print $1}')

        if [ "$md5_temp_value" == "$md5_original_value" ]; then
            echo -e "\n${yellowColour}[+]${endColour} Comprobando si hay actualizaciones..."
            echo -e "\n${yellowColour}[+]${endColour} Tu paquete esta actualizado :)"
            rm bundle_temp.js
        else
            echo -e "${yellowColour}[+]${endColour} Comprobando si hay actualizaciones..."
            sleep 3
            echo -e "\n${yellowColour}[+]${endColour} Se han encontrado actualizaciones"
            rm bundle.js && mv bundle_temp.js bundle.js
            echo -e "\n${yellowColour}[+]${endColour} El paquete se ha actualizado exitosamente! :D"

        fi

        tput cnorm
    fi
}

function searchMachine() {

    echo -e "\n${yellowColour}[+]${endColour} Listando las propiedades de la maquina ${blueColour}$machineName${endColour}:\n"
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
}

function searchIP() {
    ipAdress="$1"
    echo -e "\n La IP es $ipAdress"
}

#indicators
declare -i parameter_counter=0

while getopts "m:ui:h" arg; do
    case $arg in
    m)
        machineName=$OPTARG
        parameter_counter+=1
        ;;
    u)
        parameter_counter+=2
        ;;
    i)
        ipAdress=$OPTARG
        parameter_counter+=3
        ;;
    h) 
    ;;
    *)

        echo "Invalid Input"
        helpPanel
        ;;
    esac
done

if [ $parameter_counter -eq 1 ]; then
    searchMachine "$machineName"

elif [ $parameter_counter -eq 2 ]; then
    updateFiles

elif [ $parameter_counter -eq 3 ]; then
    searchIP "$ipAdress"

else

    helpPanel
fi
