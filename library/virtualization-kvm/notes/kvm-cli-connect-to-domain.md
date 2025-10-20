# Conectarse a un dominio/VM de KVM

Hay varias formas de conectarte a una VM en ejecución desde el CLI. Estas son:

## Opción 1: Consola Serial (virsh console) - Más Común

```bash
sudo virsh console docker-host-ubu2404
```

**Para salir de la consola:** Presiona `Ctrl + ]`

⚠️ **Nota importante**: Esta opción solo funciona si la VM tiene una consola serial configurada. En Ubuntu/Debian modernas esto suele estar habilitado por defecto.

## Opción 2: SSH (Recomendado para uso regular)

Si la VM tiene red configurada y SSH habilitado:

```bash
# Primero, obtén la IP de la VM
sudo virsh domifaddr docker-host-ubu2404

# O mira en el DHCP de libvirt
sudo virsh net-dhcp-leases default

# Luego conéctate por SSH
ssh usuario@IP_DE_LA_VM
```

## Opción 3: VNC (Interfaz Gráfica)

Si la VM tiene display VNC configurado:

```bash
# Ver información del display VNC
sudo virsh vncdisplay docker-host-ubu2404

# Conectar con un cliente VNC (ejemplo: virt-viewer)
sudo virt-viewer docker-host-ubu2404
```

## Opción 4: Spice (Más moderno que VNC)

```bash
sudo virt-viewer --connect qemu:///system docker-host-ubu2404
```

## Verificar Configuración de Consola

Para asegurarte de que `virsh console` funcionará:

```bash
# Ver la configuración XML de la VM
sudo virsh dumpxml docker-host-ubu2404 | grep -A 5 console

# Debería mostrar algo como:
# <console type='pty'>
#   <target type='serial' port='0'/>
# </console>
```

## Si virsh console no funciona

Puede que necesites habilitar la consola serial dentro de la VM guest. Una vez dentro (por SSH o VNC), ejecuta:

```bash
# Para sistemas con systemd (Ubuntu/Debian modernas)
sudo systemctl enable serial-getty@ttyS0.service
sudo systemctl start serial-getty@ttyS0.service

# O editar GRUB (más permanente)
sudo nano /etc/default/grub
# Añadir: GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,115200n8"
sudo update-grub
sudo reboot
```

## Recomendación

Para administración habitual, usa **SSH**. Es más flexible y permite copiar/pegar fácilmente. Para troubleshooting o cuando la red no funciona, usa **virsh console**.

