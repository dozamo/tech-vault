# Instalación de virt-manager como Cliente de Administración Remota en Linux Mint 22.2

Este documento explica como instalar `virt-manager` para administrar **hosts KVM remotos** y no como un host de virtualización local.

## 1. Actualizar el sistema

Es una buena práctica antes de cualquier instalación:

```bash
sudo apt update
sudo apt upgrade -y
```

## 2. Instalar virt-manager y las librerías cliente de libvirt

En este caso, solo necesitamos `virt-manager` y los clientes de `libvirt` para establecer la conexión remota.

```bash
sudo apt install virt-manager libvirt-client -y
```

**Explicación de los paquetes:**

*   **`virt-manager`**: La interfaz gráfica de usuario para gestionar las VMs.
*   **`libvirt-client`**: Contiene las utilidades cliente de `libvirt` (como `virsh`) y las librerías necesarias para que `virt-manager` se comunique con demonios `libvirt` locales o remotos.

**¡Importante!** No es necesario instalar `qemu-kvm`, `libvirt-daemon-system`, `bridge-utils`, `virtinst`, ni añadir tu usuario al grupo `libvirt` en esta máquina cliente si no vas a ejecutar VMs localmente. Tampoco necesitas verificar `kvm-ok` ni configurar puentes de red en el cliente.

## 3. Configuración del Host KVM Remoto (Pre-requisito)

Asegúrate de que tu host KVM remoto esté correctamente configurado para permitir conexiones SSH y que el servicio `libvirtd` esté ejecutándose.

Para una administración remota efectiva, el host KVM remoto debe:

*   Tener `qemu-kvm`, `libvirt-daemon-system` y `openssh-server` instalados.
*   El usuario con el que te conectarás remotamente debe ser parte del grupo `libvirt` en el **host remoto**.
*   El servicio `libvirtd` debe estar activo y habilitado en el **host remoto**.

## 4. Ejecutar virt-manager y Conectar al Host Remoto

1.  Inicia `virt-manager` desde el menú de aplicaciones o la terminal:

    ```bash
    virt-manager
    ```

2.  En la ventana principal de `Virtual Machine Manager`, haz clic en **"Archivo" -> "Añadir Conexión..."**.
    
    
