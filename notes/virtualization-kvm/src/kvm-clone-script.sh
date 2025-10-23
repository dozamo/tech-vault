#!/bin/bash

# Script de Clonación de Máquinas Virtuales KVM
# Uso: ./kvm-clone.sh <vm-original> <nombre-nueva-vm> [ruta-disco]
# Este script debe ejecutarse con permisos apropiados de libvirt/sudo

set -e  # Salir ante cualquier error

# Códigos de color para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sin Color

# Función para mostrar el uso
usage() {
    echo "Uso: $0 <vm-original> <nombre-nueva-vm> [ruta-disco]"
    echo ""
    echo "Argumentos:"
    echo "  vm-original       Nombre del dominio VM de origen (requerido)"
    echo "  nombre-nueva-vm   Nombre para la VM clonada (requerido)"
    echo "  ruta-disco        Ruta personalizada para imagen de disco clonada (opcional)"
    echo ""
    echo "Ejemplos:"
    echo "  $0 terminal-001 terminal-002"
    echo "  $0 terminal-001 terminal-002 /data/vms/terminal-002.qcow2"
    echo ""
    echo "Nota: Este script requiere permisos de libvirt. El usuario debe estar en el grupo 'libvirt'"
    echo "      o tener configuración apropiada de sudoers, o ejecutar con sudo."
    exit 1
}

# Funciones para imprimir mensajes con colores
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ADVERTENCIA]${NC} $1"
}

# Verificar si estamos corriendo como root
if [ "$EUID" -eq 0 ]; then
    print_warning "Ejecutar como root no es recomendado por razones de seguridad"
    print_warning "Considera crear un usuario dedicado con membresía en el grupo libvirt"
    read -p "¿Continuar de todos modos? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Operación cancelada"
        exit 0
    fi
fi

# Verificar si los argumentos requeridos están presentes
if [ $# -lt 2 ]; then
    print_error "Faltan argumentos requeridos"
    usage
fi

# Asignar argumentos a variables
ORIGINAL_VM="$1"
NEW_VM_NAME="$2"
DISK_PATH="${3:-}"  # Tercer argumento opcional

# Determinar si necesitamos usar sudo y qué URI de conexión usar
# Las VMs de sistema requieren qemu:///system que normalmente necesita permisos elevados
USE_SUDO=""
VIRSH_CONNECT="--connect qemu:///system"

if [ "$EUID" -eq 0 ]; then
    # Ya estamos corriendo como root
    USE_SUDO=""
    print_info "Ejecutando como root"
else
    # Probar si podemos acceder a qemu:///system sin sudo
    if virsh $VIRSH_CONNECT list --all &>/dev/null; then
        USE_SUDO=""
        print_info "Permisos de libvirt detectados para qemu:///system (usuario en grupo libvirt)"
    else
        # No podemos acceder a qemu:///system sin sudo, intentar con sudo
        print_info "Se requiere sudo para acceder a qemu:///system"
        
        # Verificar si sudo está disponible y funciona
        if ! command -v sudo &>/dev/null; then
            print_error "sudo no está instalado y no tienes permisos de libvirt para qemu:///system"
            echo ""
            echo "Soluciones:"
            echo "  1. Instalar sudo"
            echo "  2. Añadir tu usuario al grupo libvirt y volver a iniciar sesión"
            echo "  3. Ejecutar el script como root (no recomendado)"
            exit 1
        fi
        
        # Probar sudo con virsh
        if sudo virsh $VIRSH_CONNECT list --all &>/dev/null; then
            USE_SUDO="sudo"
            print_info "Usando sudo para acceder a qemu:///system"
        else
            print_error "No se puede acceder a qemu:///system ni con sudo"
            echo ""
            echo "Soluciones:"
            echo "  1. Añadir tu usuario al grupo libvirt:"
            echo "     sudo usermod -aG libvirt \$USER"
            echo "     Luego cerrar sesión y volver a entrar"
            echo ""
            echo "  2. Configurar sudoers para comandos virsh/virt-clone"
            exit 1
        fi
    fi
fi

# Verificar que la VM original existe
print_info "Verificando si la VM original '$ORIGINAL_VM' existe..."
if ! $USE_SUDO virsh $VIRSH_CONNECT dominfo "$ORIGINAL_VM" &>/dev/null; then
    print_error "La VM original '$ORIGINAL_VM' no existe"
    echo ""
    echo "VMs disponibles:"
    $USE_SUDO virsh $VIRSH_CONNECT list --all --name
    exit 1
fi

# Verificar que el nombre de la nueva VM no exista ya
print_info "Verificando que el nombre '$NEW_VM_NAME' esté disponible..."
if $USE_SUDO virsh $VIRSH_CONNECT dominfo "$NEW_VM_NAME" &>/dev/null; then
    print_error "Ya existe una VM con el nombre '$NEW_VM_NAME'"
    exit 1
fi

# Verificar si la VM original está en ejecución
VM_STATE=$($USE_SUDO virsh $VIRSH_CONNECT domstate "$ORIGINAL_VM" 2>/dev/null)
if [ "$VM_STATE" == "running" ]; then
    print_warning "La VM original '$ORIGINAL_VM' está actualmente en ejecución"
    print_warning "Se recomienda apagarla antes de clonar para consistencia de datos"
    read -p "¿Deseas continuar de todos modos? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Operación de clonado cancelada"
        exit 0
    fi
fi

# Construir comando virt-clone
print_info "Iniciando operación de clonado..."
CLONE_CMD="virt-clone $VIRSH_CONNECT --original $ORIGINAL_VM --name $NEW_VM_NAME"

if [ -n "$DISK_PATH" ]; then
    # Ruta de disco personalizada proporcionada
    print_info "Usando ruta de disco personalizada: $DISK_PATH"
    
    # Verificar si el directorio padre existe
    DISK_DIR=$(dirname "$DISK_PATH")
    if [ ! -d "$DISK_DIR" ]; then
        print_error "El directorio '$DISK_DIR' no existe"
        exit 1
    fi
    
    # Verificar si el archivo ya existe
    if [ -f "$DISK_PATH" ]; then
        print_error "El archivo de disco '$DISK_PATH' ya existe"
        exit 1
    fi
    
    # Verificar si el directorio tiene permisos de escritura
    if [ ! -w "$DISK_DIR" ]; then
        if [ -z "$USE_SUDO" ]; then
            print_error "El directorio '$DISK_DIR' no tiene permisos de escritura para el usuario actual"
            exit 1
        fi
    fi
    
    CLONE_CMD="$CLONE_CMD --file $DISK_PATH"
else
    # Usar opción auto-clone
    print_info "Usando opción --auto-clone (generación automática de ruta de disco)"
    CLONE_CMD="$CLONE_CMD --auto-clone"
fi

# Ejecutar el comando de clonado
if [ -n "$USE_SUDO" ]; then
    print_info "Ejecutando: sudo $CLONE_CMD"
else
    print_info "Ejecutando: $CLONE_CMD"
fi
echo ""

if $USE_SUDO $CLONE_CMD; then
    echo ""
    print_info "¡Operación de clonado completada exitosamente!"
    print_info "La nueva VM '$NEW_VM_NAME' ha sido creada"
    echo ""
    print_info "Información de la VM:"
    $USE_SUDO virsh $VIRSH_CONNECT dominfo "$NEW_VM_NAME"
    echo ""
    print_info "Para iniciar la VM clonada, ejecuta:"
    if [ -n "$USE_SUDO" ]; then
        echo "  sudo virsh start $NEW_VM_NAME"
    else
        echo "  virsh --connect qemu:///system start $NEW_VM_NAME"
    fi
else
    print_error "La operación de clonado falló"
    exit 1
fi
