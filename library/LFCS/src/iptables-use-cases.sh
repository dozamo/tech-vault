#!/bin/bash
# ========================================
# CASOS DE USO PRÁCTICOS DE IPTABLES
# ========================================

# ========================================
# CASO 1: Servidor Web Básico
# ========================================
# Escenario: Servidor web que debe permitir HTTP, HTTPS y SSH
# Bloquear todo lo demás

caso1_servidor_web() {
    echo "=== Configurando servidor web básico ==="
    
    # Limpiar reglas
    iptables -F
    iptables -X
    
    # Política por defecto: denegar
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    
    # Permitir loopback
    iptables -A INPUT -i lo -j ACCEPT
    
    # Permitir conexiones establecidas y relacionadas
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # Permitir SSH (puerto 22)
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    
    # Permitir HTTP (puerto 80) y HTTPS (puerto 443)
    iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
    
    # Permitir ping
    iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
    
    # Log de intentos bloqueados (opcional)
    iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "IPT-DROP: " --log-level 7
    
    echo "Configuración completada"
    iptables -L -v -n
}

# ========================================
# CASO 2: Protección contra Ataques SSH
# ========================================
# Escenario: Limitar intentos de conexión SSH para prevenir ataques de fuerza bruta

caso2_proteccion_ssh() {
    echo "=== Configurando protección SSH contra fuerza bruta ==="
    
    # Permitir SSH solo desde IPs específicas (opcional)
    iptables -A INPUT -p tcp -s 192.168.1.0/24 --dport 22 -j ACCEPT
    
    # Limitar conexiones SSH: máximo 3 intentos en 60 segundos
    iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH
    iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP
    
    # Permitir SSH normal después de pasar el límite
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    
    # Alternativa: usando hashlimit (más flexible)
    # iptables -A INPUT -p tcp --dport 22 -m state --state NEW \
    #   -m hashlimit --hashlimit-above 3/minute --hashlimit-burst 5 \
    #   --hashlimit-name ssh --hashlimit-mode srcip -j DROP
    
    echo "Protección SSH configurada"
}

# ========================================
# CASO 3: Router/Gateway con NAT
# ========================================
# Escenario: Servidor que actúa como gateway para compartir Internet

caso3_router_nat() {
    echo "=== Configurando router con NAT ==="
    
    # Interfaces
    WAN_IF="eth0"    # Internet
    LAN_IF="eth1"    # Red local
    LAN_NET="192.168.1.0/24"
    
    # Habilitar IP forwarding
    echo 1 > /proc/sys/net/ipv4/ip_forward
    sysctl -w net.ipv4.ip_forward=1
    
    # Limpiar tablas NAT y filter
    iptables -t nat -F
    iptables -t nat -X
    iptables -F FORWARD
    
    # Masquerading para compartir Internet
    iptables -t nat -A POSTROUTING -s $LAN_NET -o $WAN_IF -j MASQUERADE
    
    # Permitir forwarding de conexiones establecidas
    iptables -A FORWARD -i $WAN_IF -o $LAN_IF -m state --state RELATED,ESTABLISHED -j ACCEPT
    
    # Permitir forwarding desde LAN a WAN
    iptables -A FORWARD -i $LAN_IF -o $WAN_IF -j ACCEPT
    
    # Protección adicional: bloquear paquetes inválidos
    iptables -A FORWARD -m state --state INVALID -j DROP
    
    # Logging de forward rechazado
    iptables -A FORWARD -j LOG --log-prefix "FWD-DROP: "
    iptables -A FORWARD -j DROP
    
    echo "Router NAT configurado"
    echo "Red local $LAN_NET puede acceder a Internet a través de $WAN_IF"
}

# ========================================
# CASO 4: Port Forwarding a Servidor Interno
# ========================================
# Escenario: Redirigir tráfico web del puerto 80 público a servidor interno

caso4_port_forwarding() {
    echo "=== Configurando port forwarding ==="
    
    WAN_IF="eth0"
    LAN_IF="eth1"
    INTERNAL_SERVER="192.168.1.10"
    
    # Habilitar forwarding
    echo 1 > /proc/sys/net/ipv4/ip_forward
    
    # DNAT: Redirigir puerto 80 externo al servidor interno
    iptables -t nat -A PREROUTING -i $WAN_IF -p tcp --dport 80 \
      -j DNAT --to-destination $INTERNAL_SERVER:80
    
    # Redirigir puerto 443 (HTTPS)
    iptables -t nat -A PREROUTING -i $WAN_IF -p tcp --dport 443 \
      -j DNAT --to-destination $INTERNAL_SERVER:443
    
    # Masquerade para respuestas
    iptables -t nat -A POSTROUTING -o $LAN_IF -d $INTERNAL_SERVER -p tcp --dport 80 \
      -j MASQUERADE
    iptables -t nat -A POSTROUTING -o $LAN_IF -d $INTERNAL_SERVER -p tcp --dport 443 \
      -j MASQUERADE
    
    # Permitir forwarding hacia el servidor interno
    iptables -A FORWARD -i $WAN_IF -o $LAN_IF -p tcp --dport 80 -d $INTERNAL_SERVER -j ACCEPT
    iptables -A FORWARD -i $WAN_IF -o $LAN_IF -p tcp --dport 443 -d $INTERNAL_SERVER -j ACCEPT
    
    # Permitir respuestas
    iptables -A FORWARD -i $LAN_IF -o $WAN_IF -m state --state RELATED,ESTABLISHED -j ACCEPT
    
    echo "Port forwarding configurado"
    echo "Tráfico en puertos 80 y 443 redirigido a $INTERNAL_SERVER"
}

# ========================================
# CASO 5: Bloqueo de IPs Maliciosas
# ========================================
# Escenario: Bloquear lista de IPs conocidas como maliciosas

caso5_bloqueo_ips() {
    echo "=== Configurando bloqueo de IPs maliciosas ==="
    
    # Crear cadena personalizada para IPs bloqueadas
    iptables -N BLACKLIST 2>/dev/null || iptables -F BLACKLIST
    
    # Lista de IPs a bloquear
    IPS_MALICIOSAS=(
        "10.0.0.50"
        "172.16.0.100"
        "192.168.100.0/24"
    )
    
    # Agregar IPs a la blacklist
    for ip in "${IPS_MALICIOSAS[@]}"; do
        iptables -A BLACKLIST -s "$ip" -j LOG --log-prefix "BLACKLIST-DROP: "
        iptables -A BLACKLIST -s "$ip" -j DROP
        echo "Bloqueada IP: $ip"
    done
    
    # Aplicar blacklist al inicio de INPUT
    iptables -I INPUT 1 -j BLACKLIST
    
    echo "Blacklist configurada con ${#IPS_MALICIOSAS[@]} entradas"
}

# ========================================
# CASO 6: Servidor de Base de Datos
# ========================================
# Escenario: MySQL/PostgreSQL accesible solo desde servidores web específicos

caso6_servidor_db() {
    echo "=== Configurando firewall para servidor de base de datos ==="
    
    # IPs de servidores web autorizados
    WEB_SERVERS=(
        "192.168.1.10"
        "192.168.1.11"
        "192.168.1.12"
    )
    
    # Puerto de base de datos
    DB_PORT=3306  # MySQL (PostgreSQL sería 5432)
    
    # Limpiar y configurar política
    iptables -F INPUT
    iptables -P INPUT DROP
    iptables -P OUTPUT ACCEPT
    
    # Loopback y conexiones establecidas
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # SSH para administración
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    
    # Permitir MySQL solo desde servidores web autorizados
    for server in "${WEB_SERVERS[@]}"; do
        iptables -A INPUT -p tcp -s "$server" --dport $DB_PORT -j ACCEPT
        echo "Permitido acceso DB desde: $server"
    done
    
    # Rechazar otros intentos de conexión a DB (con mensaje)
    iptables -A INPUT -p tcp --dport $DB_PORT -j REJECT --reject-with tcp-reset
    
    echo "Firewall DB configurado - Acceso solo desde servidores autorizados"
}

# ========================================
# CASO 7: Limitación de Ancho de Banda (Traffic Shaping)
# ========================================
# Escenario: Limitar conexiones concurrentes y ancho de banda

caso7_limitacion_trafico() {
    echo "=== Configurando limitación de tráfico ==="
    
    # Limitar conexiones HTTP concurrentes por IP
    iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 20 -j REJECT
    
    # Limitar rate de nuevas conexiones SSH
    iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m limit --limit 3/min --limit-burst 3 -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j DROP
    
    # Limitar ICMP (ping) para prevenir flood
    iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 3 -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
    
    # Proteger contra syn flood
    iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT
    iptables -A INPUT -p tcp --syn -j DROP
    
    echo "Limitaciones de tráfico configuradas"
}

# ========================================
# CASO 8: Red Segmentada (DMZ)
# ========================================
# Escenario: Tres zonas de red - Internet, DMZ (servidores públicos), LAN (red interna)

caso8_dmz() {
    echo "=== Configurando DMZ ==="
    
    # Interfaces
    INET_IF="eth0"    # Internet
    DMZ_IF="eth1"     # DMZ (192.168.10.0/24)
    LAN_IF="eth2"     # LAN (192.168.1.0/24)
    
    DMZ_NET="192.168.10.0/24"
    LAN_NET="192.168.1.0/24"
    
    # Habilitar forwarding
    echo 1 > /proc/sys/net/ipv4/ip_forward
    
    # Limpiar reglas
    iptables -F FORWARD
    iptables -P FORWARD DROP
    
    # Internet → DMZ: Solo HTTP, HTTPS, SSH
    iptables -A FORWARD -i $INET_IF -o $DMZ_IF -d $DMZ_NET \
      -p tcp -m multiport --dports 22,80,443 -m state --state NEW,ESTABLISHED -j ACCEPT
    
    # DMZ → Internet: Permitir respuestas y actualizaciones
    iptables -A FORWARD -i $DMZ_IF -o $INET_IF -s $DMZ_NET \
      -m state --state NEW,ESTABLISHED -j ACCEPT
    
    # LAN → DMZ: Acceso completo (administración)
    iptables -A FORWARD -i $LAN_IF -o $DMZ_IF -s $LAN_NET -d $DMZ_NET -j ACCEPT
    
    # DMZ → LAN: RECHAZAR (DMZ comprometida no debe alcanzar LAN)
    iptables -A FORWARD -i $DMZ_IF -o $LAN_IF -j REJECT
    
    # LAN → Internet: Acceso completo con NAT
    iptables -A FORWARD -i $LAN_IF -o $INET_IF -s $LAN_NET -j ACCEPT
    iptables -t nat -A POSTROUTING -s $LAN_NET -o $INET_IF -j MASQUERADE
    
    # DMZ → Internet: NAT para servidores DMZ
    iptables -t nat -A POSTROUTING -s $DMZ_NET -o $INET_IF -j MASQUERADE
    
    # Permitir tráfico establecido
    iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    echo "DMZ configurada:"
    echo "  - Internet puede acceder a DMZ (puertos 22,80,443)"
    echo "  - LAN puede acceder a DMZ (administración)"
    echo "  - DMZ NO puede acceder a LAN (seguridad)"
    echo "  - LAN y DMZ pueden acceder a Internet"
}

# ========================================
# CASO 9: VPN Server (OpenVPN)
# ========================================
# Escenario: Configurar firewall para servidor OpenVPN

caso9_vpn_server() {
    echo "=== Configurando firewall para servidor VPN ==="
    
    VPN_IF="tun0"
    VPN_NET="10.8.0.0/24"
    WAN_IF="eth0"
    VPN_PORT=1194
    
    # Permitir conexiones VPN entrantes
    iptables -A INPUT -i $WAN_IF -p udp --dport $VPN_PORT -j ACCEPT
    
    # Permitir tráfico en interfaz VPN
    iptables -A INPUT -i $VPN_IF -j ACCEPT
    iptables -A OUTPUT -o $VPN_IF -j ACCEPT
    
    # NAT para clientes VPN
    iptables -t nat -A POSTROUTING -s $VPN_NET -o $WAN_IF -j MASQUERADE
    
    # Permitir forwarding para clientes VPN
    iptables -A FORWARD -i $VPN_IF -o $WAN_IF -j ACCEPT
    iptables -A FORWARD -i $WAN_IF -o $VPN_IF -m state --state RELATED,ESTABLISHED -j ACCEPT
    
    # Habilitar forwarding
    echo 1 > /proc/sys/net/ipv4/ip_forward
    
    echo "Firewall VPN configurado en puerto $VPN_PORT"
}

# ========================================
# CASO 10: Redirección Transparente (Proxy)
# ========================================
# Escenario: Redirigir tráfico HTTP/HTTPS a un proxy transparente (Squid)

caso10_proxy_transparente() {
    echo "=== Configurando proxy transparente ==="
    
    PROXY_PORT=3128
    LAN_IF="eth1"
    
    # Redirigir HTTP a proxy
    iptables -t nat -A PREROUTING -i $LAN_IF -p tcp --dport 80 \
      -j REDIRECT --to-port $PROXY_PORT
    
    # Redirigir HTTPS a proxy (requiere SSL bump en Squid)
    iptables -t nat -A PREROUTING -i $LAN_IF -p tcp --dport 443 \
      -j REDIRECT --to-port $PROXY_PORT
    
    # Permitir proxy acceder a Internet
    iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
    iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
    
    echo "Proxy transparente configurado en puerto $PROXY_PORT"
    echo "Todo el tráfico HTTP/HTTPS de LAN pasa por el proxy"
}

# ========================================
# SCRIPT DE PERSISTENCIA
# ========================================

guardar_reglas() {
    echo "=== Guardando reglas de iptables ==="
    
    # Detectar sistema operativo
    if [ -f /etc/debian_version ]; then
        # Ubuntu/Debian
        if command -v netfilter-persistent &> /dev/null; then
            netfilter-persistent save
            echo "Reglas guardadas con netfilter-persistent"
        else
            mkdir -p /etc/iptables
            iptables-save > /etc/iptables/rules.v4
            echo "Reglas guardadas en /etc/iptables/rules.v4"
        fi
    elif [ -f /etc/redhat-release ]; then
        # RHEL/CentOS
        service iptables save 2>/dev/null || iptables-save > /etc/sysconfig/iptables
        echo "Reglas guardadas en /etc/sysconfig/iptables"
    else
        # Método universal
        iptables-save > /root/iptables-backup-$(date +%Y%m%d-%H%M%S).rules
        echo "Reglas guardadas en /root/"
    fi
}

# ========================================
# MENÚ PRINCIPAL
# ========================================

mostrar_menu() {
    echo ""
    echo "=========================================="
    echo "  CASOS DE USO DE IPTABLES - LFCS"
    echo "=========================================="
    echo "1.  Servidor Web Básico"
    echo "2.  Protección SSH contra Fuerza Bruta"
    echo "3.  Router/Gateway con NAT"
    echo "4.  Port Forwarding a Servidor Interno"
    echo "5.  Bloqueo de IPs Maliciosas"
    echo "6.  Servidor de Base de Datos"
    echo "7.  Limitación de Tráfico"
    echo "8.  Red Segmentada (DMZ)"
    echo "9.  Servidor VPN (OpenVPN)"
    echo "10. Proxy Transparente"
    echo "11. Guardar Reglas"
    echo "12. Ver Reglas Actuales"
    echo "0.  Salir"
    echo "=========================================="
    echo -n "Selecciona una opción: "
}

# Verificar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then 
    echo "Este script debe ejecutarse como root"
    exit 1
fi

# Si se ejecuta sin argumentos, mostrar menú
if [ $# -eq 0 ]; then
    while true; do
        mostrar_menu
        read opcion
        
        case $opcion in
            1) caso1_servidor_web ;;
            2) caso2_proteccion_ssh ;;
            3) caso3_router_nat ;;
            4) caso4_port_forwarding ;;
            5) caso5_bloqueo_ips ;;
            6) caso6_servidor_db ;;
            7) caso7_limitacion_trafico ;;
            8) caso8_dmz ;;
            9) caso9_vpn_server ;;
            10) caso10_proxy_transparente ;;
            11) guardar_reglas ;;
            12) iptables -L -v -n; iptables -t nat -L -v -n ;;
            0) echo "Saliendo..."; exit 0 ;;
            *) echo "Opción inválida" ;;
        esac
        
        echo ""
        echo -n "Presiona Enter para continuar..."
        read
    done
else
    # Ejecutar función específica si se pasa como argumento
    "$@"
fi