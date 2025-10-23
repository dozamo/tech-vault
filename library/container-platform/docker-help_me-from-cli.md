---
up: "[[Container Platform]]"
related:
  - ""
note_type: library/note
tags:
  - LFCS
  - container-platform
---

## 🔍 Recursos de Documentación Disponibles en el Sistema

Este documento es un resumen de la ayuda que se puede consultar sobre el sistema, cuando el mismo no tiene en principio acceso a Internet, escenario por defecto cuando se rinde la LFCS.

### 1. **Páginas del Manual (man pages)**
El recurso más importante en el examen:

```bash
# Documentación completa de Docker
man docker

# Ayuda específica para subcomandos
man docker-volume
man docker-run
man docker-exec

# Buscar en todas las páginas del manual
man -k docker          # Lista todos los comandos relacionados
man -k volume          # Busca referencias a "volume"
```

### 2. **Ayuda Integrada de Docker (--help)**
Siempre disponible y muy detallada:

```bash
# Ayuda general
docker --help

# Ayuda específica por comando
docker volume --help
docker volume create --help
docker run --help
docker exec --help
docker inspect --help

# Ver opciones de un subcomando específico
docker volume ls --help
```

### 3. **Comando `info` de Docker**
```bash
# Información del sistema Docker
docker info

# Información de un contenedor específico
docker inspect mysql-prod

# Información de un volumen
docker volume inspect db-data
```

### 4. **Ejemplos con `--help` y filtrado**
```bash
# Ver solo las opciones de volúmenes en docker run
docker run --help | grep -A 5 volume

# Buscar opciones de variables de entorno
docker run --help | grep -i env

# Ver ejemplos de uso
docker run --help | less   # Navegar con espacio/flechas
```

## 📚 Estrategia Práctica para Este Escenario

Antes de resolver, yo consultaría:

```bash
# 1. Para Task 1 (crear volumen)
docker volume create --help

# 2. Para Task 2 (run con opciones)
docker run --help | grep -E "volume|env|name|publish"

# 3. Para Task 3 (ejecutar comando en contenedor)
docker exec --help
# También podría revisar comandos MySQL si no los recuerdo
man mysql    # Si está disponible

# 4. Para Task 5 (backup - la parte más compleja)
docker run --help | grep -A 3 "volumes-from"
# O buscar ejemplos de backup
man docker-run | grep -i backup

# 5. Para Task 6 (inspect)
docker volume inspect --help
docker volume --help | grep inspect

# 6. Para Task 7 (listar volúmenes)
docker volume ls --help
```

## 💡 Tip del Examen LFCS

**El flag `--help` es tu mejor amigo** porque:
- ✅ Siempre está disponible
- ✅ Muestra sintaxis exacta
- ✅ Incluye ejemplos
- ✅ Es más rápido que `man`

**Orden de consulta recomendado:**
1. `comando --help` (rápido y conciso)
2. `man comando` (más detallado)
3. `man -k palabra_clave` (cuando no sabes el comando exacto)

¿Quieres que ahora resolvamos el escenario paso a paso usando esta documentación como referencia?