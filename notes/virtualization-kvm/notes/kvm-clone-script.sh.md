# Script ../src/kvm_clone_script.sh

- El script `../src/kvm_clone_script.sh` fuerza la conexión a `qemu:///system`.
- El script esta definido en [kvm-clone-script.sh](../src/kvm-clone-script.sh).

## Libvirt en mi host KVM anfitrión

Libvirt tiene dos URIs de conexión diferentes:
- **qemu:///session** - VMs del usuario (sin privilegios)
- **qemu:///system** - VMs del sistema (requiere permisos especiales)

Cuando ejecuto `virsh` sin parámetros, se conecta por defecto a `qemu:///session`, pero las VMs están en `qemu:///system`. Por eso:
- ✅ `sudo virsh list --all` → funciona (se conecta a system)
- ❌ `virsh list --all` → lista vacía (se conecta a session)

## Implementación del script

He añadido `--connect qemu:///system` a todos los comandos virsh en el script. Ahora el script:

1. **Detecta permisos para qemu:///system** específicamente
2. **Usa `--connect qemu:///system`** en todos los comandos virsh y virt-clone
3. **Pruebo con y sin sudo** contra el sistema correcto

## Ejecución del script

```bash
bash kvm_clone_script.sh web-srv1-lab1 docker-host-ubu2404
```

El script debería ahora:
1. Detectar que necesita sudo para acceder a qemu:///system
2. Listar correctamente las VMs
3. Clonar exitosamente

