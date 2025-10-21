---
up: "[[KVM - virsh]]"
parent:
  - "[[Definición de bridge]]"
  - "[[Eliminación de guest - eliminación de un dominio o VM]]"
---

Eliminar completamente un guest, incluyendo sus discos asociados, es un proceso que requiere varios pasos para asegurar que no queden rastros. El comando principal para esto es [[KVM - virsh]], pero la eliminación del almacenamiento es un paso separado y crucial.

Aquí te muestro cómo eliminar por completo el guest `ubuntu2204` y sus discos.

**Advertencia:** Este proceso es destructivo y eliminará todos los datos de la VM y sus discos. Antes de ejecutarlo, se recomienda asegurarse de que no necesitas la VM ni sus datos antes de proceder.

## Pasos para Eliminar Completamente un Guest KVM

Supongamos que el guest se llama `ubuntu2204` y que el disco principal se encuentra en `/var/lib/libvirt/images/ubuntu2204.img` .

### Paso 1: Apagar la Máquina Virtual (si está encendida)

Primero, la VM debe estar apagada para poder eliminarla.

```bash
sudo virsh shutdown ubuntu2204
```

Espera un momento a que se apague. Puedes verificar su estado con `sudo virsh list`. Si no se apaga limpiamente, forzar el apagado:

```bash
sudo virsh destroy ubuntu2204
```

### Paso 2: Identificar y Eliminar los Volúmenes de Almacenamiento (Discos)

Este es el paso más importante y el que libera el espacio en disco.

1.  **Encontrar los volúmenes de almacenamiento asociados:**
    Aunque generalmente sabemos dónde está el disco (`/var/lib/libvirt/images/ubuntu2204.img`), es buena práctica verificar si hay otros discos o volúmenes gestionados por `libvirt` asociados a la VM.

    Puedes obtener la configuración XML del guest (antes de `undefine` si no sabes dónde están los discos) para encontrar las rutas de los discos:

    ```bash
    # Si no la has desdefinido aún, puedes ver su XML
    # sudo virsh dumpxml ubuntu2204 | grep "source file"
    ```
    Dado que ya la desdefinimos, si tienes el XML guardado o si recuerdas la ruta, úsala. En tu caso, es `/var/lib/libvirt/images/ubuntu2204.img`.

2.  **Eliminar el archivo del disco:**
    `libvirt` gestiona el almacenamiento a través de "Storage Pools" y "Storage Volumes". Si el disco fue creado dentro de un pool gestionado por `libvirt`, puedes usar `virsh vol-delete`. Si es un archivo de imagen simple (como en tu caso), lo borras directamente con `rm`.

    *   **Opción A: Si el disco es un archivo simple (lo más probable en tu caso):**
        ```bash
        sudo rm -f /var/lib/libvirt/images/ubuntu2204.img
        ```
        Si tienes otros discos asociados (por ejemplo, un disco de datos adicional), asegúrate de eliminarlos también:
        ```bash
        # Ejemplo si hubiera otro disco
        # sudo rm -f /var/lib/libvirt/images/ubuntu2204-data.img
        ```

    *   **Opción B: Si el disco fue creado y está gestionado por un pool de almacenamiento de `libvirt`:**
        Primero, necesitas saber en qué pool se encuentra el volumen y el nombre del volumen.
        ```bash
        # Listar todos los volúmenes en un pool específico (ej. 'default')
        sudo virsh vol-list default --details

        # Identificar el volumen para ubuntu2204.img (por ejemplo, el nombre del volumen podría ser 'ubuntu2204.img')
        # Luego, eliminar el volumen:
        # sudo virsh vol-delete ubuntu2204.img --pool default
        ```
        La Opción A es la más probable para tu caso, ya que `virt-install` con `--disk path=/ruta/a/archivo.img,size=...` crea un archivo de imagen directo en el sistema de archivos, sin necesariamente usar las características completas de gestión de volúmenes de `libvirt` a menos que se especifique un pool.

### Paso 3: Desdefinir la Máquina Virtual

Esto elimina la configuración de la VM de `libvirt`, pero no borra el archivo del disco duro.

```bash
sudo virsh undefine ubuntu2204
```

Si la VM tiene snapshots o un archivo de respaldo (backup) definido, `virsh undefine` podría fallar o advertir al respecto. Si existen snapshots, se necesitará eliminarlos primero:

```bash
# Listar snapshots si los hubiera
sudo virsh snapshot-list ubuntu2204

# Si hay snapshots, eliminarlos (ejemplo para un snapshot llamado 'first_snapshot')
# sudo virsh snapshot-delete ubuntu2204 first_snapshot
# Repite para todos los snapshots
```
Después de eliminar los snapshots, reintentar `sudo virsh undefine ubuntu2204`.

### Paso 4: Limpieza de configuraciones de red (Opcional)

Si hubieras configurado reglas de NAT o reenvío de puertos específicos para esta VM en el firewall del host (por ejemplo, `iptables`), deberías revisar y eliminarlas si ya no son necesarias. `libvirt` suele gestionar sus propias reglas para la red `default`, pero si hiciste ajustes manuales, es un buen momento para limpiar.

---

### Resumen de Comandos para tu Caso Específico:

Asumiendo que `ubuntu2204` tiene su disco en `/var/lib/libvirt/images/ubuntu2204.img`:

1.  **Apagar la VM (si está corriendo):**
    ```bash
    sudo virsh shutdown ubuntu2204 || sudo virsh destroy ubuntu2204
    ```
    El `||` es para que, si `shutdown` falla (e.g., ya está apagada o no responde), intente `destroy`.

2.  **Desdefinir la VM:**
    ```bash
    sudo virsh undefine ubuntu2204
    ```

3.  **Eliminar el archivo del disco:**
    ```bash
    sudo rm -f /var/lib/libvirt/images/ubuntu2204.img
    ```

Después de estos pasos, la VM `ubuntu2204` habrá desaparecido por completo del sistema KVM.

Si por alguna razón se sospecha que hay otros discos asociados que no se encuentran en `/var/lib/libvirt/images/`, se puede listar todos los volúmenes en todos los pools definidos:
```bash
sudo virsh pool-list --all
# Para cada pool, por ejemplo 'default':
# sudo virsh vol-list default --details
```
Esto te ayudará a identificar cualquier volumen huérfano.