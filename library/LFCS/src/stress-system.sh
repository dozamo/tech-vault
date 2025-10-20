#!/bin/bash

# Script de shell que genera carga intensiva en la CPU, la memoria y el disco. 
# Es un proceso iterativo/infinito, perfecto para practicar la supervisión y la gestión de recursos del sistema.

echo "Iniciando script de estrés del sistema..."
echo "Presiona Ctrl+C para detenerlo en cualquier momento."

# Función para generar carga en la CPU
stress_cpu() {
    echo "Generando carga de CPU en segundo plano..."
    # Se recomienda usar 'stress-ng' o 'stress' para una carga de CPU más controlada y efectiva.
    # Si no los tienes instalados, este bucle básico consumirá CPU.
    # Ejemplo con stress-ng (instala con 'sudo apt install stress-ng' o 'sudo yum install stress-ng'):
    # stress-ng --cpu 0 --timeout 0 &
    # O un bucle básico:
    while : ; do
        :
    done &
    CPU_PID=$!
    echo "Proceso de CPU iniciado con PID: $CPU_PID"
}

# Función para generar carga en la memoria
stress_memory() {
    echo "Generando carga de memoria en segundo plano..."
    # Asigna y libera memoria repetidamente para mantener la carga.
    # Se crea un archivo temporal grande y se lee/escribe en él.
    MEM_FILE=$(mktemp)
    # Tamaño del archivo de memoria temporal (ej. 1GB)
    MEM_SIZE="1G"

    # Escribir ceros en el archivo para reservarlo
    dd if=/dev/zero of="$MEM_FILE" bs=1M count=$(echo $MEM_SIZE | sed 's/G//')K 2>/dev/null &
    DD_PID=$!
    echo "Proceso de creación de archivo de memoria temporal iniciado con PID: $DD_PID"
    wait $DD_PID

    # Mantener el archivo abierto y escribir aleatoriamente para simular uso de memoria.
    # Esto también puede afectar al disco.
    while : ; do
        # Escribir una pequeña cantidad de datos aleatorios en una posición aleatoria del archivo
        # Esto ayuda a que el kernel no optimice demasiado la memoria.
        OFFSET=$(( RANDOM % $(echo $MEM_SIZE | sed 's/G//') * 1024 * 1024 ))
        dd if=/dev/urandom of="$MEM_FILE" bs=4K count=1 seek=$(( OFFSET / 4096 )) conv=notrunc 2>/dev/null
    done &
    MEM_PID=$!
    echo "Proceso de memoria iniciado con PID: $MEM_PID"
}

# Función para generar carga en el disco (I/O)
stress_disk() {
    echo "Generando carga de E/S de disco en segundo plano..."
    # Crear un archivo grande y escribir en él repetidamente, luego eliminarlo y recrearlo.
    DISK_FILE=$(mktemp)
    # Tamaño del archivo de disco temporal (ej. 500MB)
    DISK_SIZE="500M"

    while : ; do
        # Escribir datos aleatorios en el disco
        dd if=/dev/urandom of="$DISK_FILE" bs=1M count=$(echo $DISK_SIZE | sed 's/M//') conv=fdatasync 2>/dev/null
        # Eliminar y recrear para generar más actividad de metadatos y asegurar que no se almacene en caché.
        rm -f "$DISK_FILE"
        sleep 0.1 # Pequeña pausa para no saturar completamente el sistema de archivos
    done &
    DISK_PID=$!
    echo "Proceso de disco iniciado con PID: $DISK_PID"
}

# Función para manejar la señal de interrupción (Ctrl+C)
cleanup() {
    echo -e "\nDeteniendo procesos de estrés..."
    kill $CPU_PID 2>/dev/null
    kill $MEM_PID 2>/dev/null
    kill $DISK_PID 2>/dev/null
    rm -f "$MEM_FILE" 2>/dev/null
    rm -f "$DISK_FILE" 2>/dev/null
    echo "Script de estrés detenido."
    exit 0
}

# Registrar la función de limpieza para la señal SIGINT (Ctrl+C)
trap cleanup SIGINT

# Iniciar las funciones de estrés en segundo plano
stress_cpu
stress_memory
stress_disk

echo "El sistema está ahora bajo estrés. Monitorea con herramientas como top, htop, vmstat, iostat, sar, etc."
echo "Presiona Ctrl+C para detener todos los procesos y limpiar."

# Mantener el script principal en ejecución para que los procesos en segundo plano sigan funcionando
# hasta que se reciba la señal SIGINT.
wait
