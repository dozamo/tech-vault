---
up: "[[KVM - virsh]]"
parent:
  - "[[Definición de bridge]]"
  - "[[Eliminación de guest - eliminación de un dominio o VM]]"
---


## Definición de un bridge

```bash
# 1. Fichero de definición del bridge
dzamo@victus:~$ cat /tmp/br0-network.xml    
<network>  
 <name>host-bridge-br0</name>  <!-- Un nombre descriptivo para esta red de libvirt -->  
 <forward mode='bridge'/>      <!-- Indica que es una red bridge -->  
 <bridge name='br0'/>          <!-- Aquí especificas tu bridge de Linux existente -->  
 <link state='up'/>            <!-- Asegura que la interfaz del bridge está arriba -->  
 <!-- Opcional: Si quieres un servidor DHCP para tus VMs desde este bridge, puedes añadirlo,  
      pero lo más común es que la red física ya tenga uno.  
      Por ejemplo, si tu red 172.17.17.0/24 tiene DHCP, las VMs lo usarán automáticamente.  
 <ip address='172.17.17.254' netmask='255.255.255.0'>  
   <dhcp start='172.17.17.100' end='172.17.17.150'/>  
 </ip>  
 -->  
</network>

virsh net-define /tmp/br0-network.xml

# 2. Definir/crear la red
virsh net-define /tmp/br0-network.xml

# 3. Arrancar la red  
virsh net-start host-bridge-br0    

# 4. Listar las redes actuales
virsh net-list

# 5. En caso de ser necesario, autoarrancar la red (que inicie al arrancar el host anfitrión)
virsh net-autostart host-bridge-br0

```
