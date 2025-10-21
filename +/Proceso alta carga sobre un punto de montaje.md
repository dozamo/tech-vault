---
up:
  - "[[LFCS recuperación]]"
related: []
tags:
  - repaso/estudio
  - LFCS
---

## Escenario 1: Proceso que genera alta carga y está relacionado con un punto de montaje

**Enunciado aproximado:** "El sistema está experimentando una alta carga. Se ha identificado que un proceso relacionado con un punto de montaje específico (`/mnt/data`) está causando el problema. Se solicita detener el proceso problemático y desmontar la unidad para su revisión." 

### Abordaje de la incidencia

1. **Identificar el proceso:**
    - Usaría `top` o `htop` para ver los procesos que consumen más CPU y memoria.
    - Una vez identificado un posible candidato (por su nombre o usuario), usaría `ps aux | grep [nombre_proceso]` para obtener más detalles, incluyendo su PID.
    - Para confirmar la relación con el punto de montaje, se podría revisar los archivos abiertos por el proceso (`lsof -p [PID]`) o verificar la línea de comandos completa del proceso (`ps -fp [PID]`). 
2. **Analizar la causa (opcional pero recomendado):** 
	- Antes de matar, si el tiempo lo permite y es seguro, intentaría entender por qué el proceso está causando la carga. ¿Es un bucle infinito? ¿Está esperando E/S de una unidad lenta? Esto podría informar sobre la solución a largo plazo. 
3. **Detener el proceso problemático:**
	    - Enviaría una señal de terminación "graciosa" primero para permitir que el proceso se cierre limpiamente y libere recursos. 
        ```
        bash sudo kill [PID]
        ```
   	- Si después de unos segundos el proceso sigue activo, enviaría una señal más contundente. 
        ```bash sudo kill -9 [PID] # -9 es SIGKILL, termina el proceso de inmediato. 
        ``` 
4. **Verificar que el proceso ha terminado:** 
        ```bash
        ps aux | grep [nombre_proceso]
        ``` Si no aparece, ha terminado. 
5. **Desmontar la unidad:** 
	       - Una vez que el proceso ha sido terminado y ya no está utilizando el punto de montaje, intentaría desmontarlo. 
	         ```bash 
	         sudo umount /mnt/data 
	         ``` 
	        - Si `umount` falla porque la unidad "está ocupada" (lo cual no debería ocurrir si el proceso principal ha sido terminado, pero puede haber otros procesos secundarios), usaría `lsof /mnt/data` para identificar qué otros procesos la están usando y los terminaría si fuera necesario, o usaría la opción forzada (con precaución). 
	          ```bash 
	          sudo umount -l /mnt/data # Desmontaje "lazy", lo desasocia del árbol del sistema de archivos ahora y lo limpia cuando ya no esté ocupado. 
	          ``` 
6. **Acciones post-incidencia:** 
	      - Revisar logs del sistema (`journalctl -xe` o `/var/log/syslog`, `/var/log/kern.log`) para entender el origen del problema.
	      - Considerar si el proceso debe ser reiniciado, reconfigurado o si la unidad necesita ser reparada.

---

 **Ejemplo de cómo se vería la ejecución de comandos para el Escenario 1**
 
 - Imagina que el proceso problemático es un script llamado `data_processor.sh` y está afectando `/mnt/data`. 

1. **Identificar la carga:** 
    ```bash top 
    # (Ver que 'data_processor.sh' consume 95% CPU, PID 12345)
    ```
2. **Obtener detalles y confirmar relación con montaje:** 
    ```
    bash ps aux | grep data_processor.sh 
    # root 12345 95.0 0.1 123456 12348 ? R 10:00 5:30 /usr/local/bin/data_processor.sh /mnt/data/input sudo lsof -p 12345 # (Ver muchas entradas de archivos abiertos en /mnt/data)   
    ```
3. **Detener el proceso:**
    ```bash sudo kill 12345 
    # (Esperar unos segundos) 
    ps aux | grep 12345 
    # (Si aún aparece) 
    sudo kill -9 12345 
    ```
4. **Verificar terminación:** 
    ```bash
    ps aux | grep data_processor.sh 
    # (No debe mostrar nada)
    ``` 
5. **Desmontar la unidad:** 
    ```
    bash sudo umount /mnt/data 
    # (Si no hay error, perfecto) 
    ``` 
6. **Verificar desmontaje:** 
    ```bash
    df -h | grep /mnt/data 
    # (No debe mostrar la línea de /mnt/data)
    ```