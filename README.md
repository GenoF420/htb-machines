# Buscador de Máquinas de HackTheBox Resueltas por s4vitar

Este script en Bash te permite buscar y filtrar información sobre las máquinas resueltas por s4vitar en la plataforma de HackTheBox. Puedes filtrar por nombre de máquina, dirección IP, sistema operativo, dificultad, habilidades (skills) y obtener enlaces a las resoluciones en YouTube.

## Características

- **Actualizar archivos necesarios**: Descarga o actualiza el archivo `bundle.js` que contiene la información de las máquinas.
- **Buscar por nombre de máquina**: Obtén información detallada de una máquina específica.
- **Buscar por dirección IP**: Encuentra el nombre de la máquina correspondiente a una IP dada.
- **Obtener enlace de YouTube**: Consigue el enlace al video de resolución en YouTube de una máquina específica.
- **Buscar por dificultad**: Lista las máquinas según su nivel de dificultad.
- **Buscar por sistema operativo**: Lista las máquinas según su sistema operativo.
- **Buscar por sistema operativo y dificultad**: Combina filtros para obtener máquinas que cumplan ambos criterios.
- **Buscar por skill**: Encuentra máquinas que requieran una habilidad específica.

## Requisitos

- **Bash**: El script está escrito para ejecutarse en Bash.
- **js-beautify**: Para formatear el archivo `bundle.js`.
- **moreutils**: Necesario para el comando `sponge`.
- **curl**: Para descargar el archivo `bundle.js` desde la URL proporcionada.
- **awk, grep, sed**: Utilizados para procesar y filtrar la información del archivo.

# Uso

Clona el repositorio o descarga el script:

```bash
git clone https://github.com/GenoF420/htb-machines.git
git clone git@github.com:GenoF420/htb-machines.git
```

Da permisos de ejecución al script:

```bash
chmod +x htbmachines.sh
```

Ejecuta el script con las opciones deseadas:

```bash
./htbmachines.sh [opciones]
```

## Opciones Disponibles

- `-u`: Descargar o actualizar los archivos necesarios (`bundle.js`).
- `-h`: Mostrar el panel de ayuda.
- `-m <nombre>`: Buscar por nombre de máquina.
- `-i <IP>`: Buscar por dirección IP.
- `-y <nombre>`: Obtener enlace de YouTube de la máquina.
- `-d <dificultad>`: Buscar por dificultad de la máquina (Fácil, Media, Difícil, Insane).
- `-o <sistema operativo>`: Buscar por sistema operativo de la máquina (Linux o Windows).
- `-s <skill>`: Buscar por habilidad requerida.

## Ejemplos de Uso

### Actualizar Archivos Necesarios

Antes de realizar búsquedas, es necesario descargar el archivo `bundle.js`:

```bash
./htbmachines.sh -u
```

### Buscar por Nombre de Máquina

```bash
./htbmachines.sh -m "Lame"
```

### Buscar por Dirección IP

```bash
./htbmachines.sh -i 10.10.10.3
```

### Obtener Enlace de YouTube de una Máquina

```bash
./htbmachines.sh -y "Lame"
```

### Buscar Máquinas por Dificultad

```bash
./htbmachines.sh -d "Media"
```

### Buscar Máquinas por Sistema Operativo

```bash
./htbmachines.sh -o "Linux"
```

### Buscar Máquinas por Sistema Operativo y Dificultad

```bash
./htbmachines.sh -d "Media" -o "Linux"
```

### Buscar Máquinas por Skill

```bash
./htbmachines.sh -s "SQL Injection"
```

## Notas

- **Sistema Operativo y Dificultad**: Al usar `-d` y `-o` juntos, el script filtrará las máquinas que coincidan con ambos criterios.
- **Skills**: La búsqueda por skill no es sensible a mayúsculas y minúsculas.

## Ayuda

Para mostrar el panel de ayuda:

```bash
./htbmachines.sh -h
```

Salida esperada:

```less
[+] Uso:
    u) Descargar o actualizar archivos necesarios 
    h) Mostrar panel de ayuda 
    y) Obtener link de la resolución de la máquina en YouTube 
    m) Buscar por nombre de máquina 
    o) Buscar por el sistema operativo de la máquina 
    i) Buscar por dirección IP
    s) Buscar por skill
    d) Buscar por la dificultad de la máquina
```

## Agradecimientos

- A **s4vitar** por ser un profesor de primera categoría.
- A la comunidad de **hack4u** por todo el apoyo y los recursos entregados.
