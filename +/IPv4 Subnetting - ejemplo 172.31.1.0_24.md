---
up: "[[IPv4 subnetting]]"
parent: ["[[IPv4 Subnetting CIRD - enfoque en Red vs Host]]", "[[IPv4 Subnetting CIRD - enfoque en Red vs Host]]", "[[IPv4 Subnetting - Guía de cálculo]]"]
---

## Usando la guía en ejemplo 172.31.1.0/24

### **DATOS:**

```
Red: 172.31.1.0/24
mask_original = 24
Hosts máximos requeridos = 14
Subredes necesarias = 7
```

### **PASO 1: Calcular bits_host necesarios**

```
num_hosts = 2^bits_host - 2

Probando valores:
bits_host = 3 → num_hosts = 2^3 - 2 = 6   ❌
bits_host = 4 → num_hosts = 2^4 - 2 = 14  ✅

Resultado: bits_host = 4
```

### **PASO 2: Calcular mask_nueva**

```
mask_nueva = 32 - bits_host
mask_nueva = 32 - 4
mask_nueva = 28
```

### **PASO 3: Calcular bits_prestados**

```
bits_prestados = mask_nueva - mask_original
bits_prestados = 28 - 24
bits_prestados = 4
```

### **PASO 4: Verificar num_subredes disponibles**

```
num_subredes = 2^bits_prestados
num_subredes = 2^4
num_subredes = 16 ✅ (suficiente para las 7 requeridas)
```

### **PASO 5: Verificación de consistencia**

```
Direcciones originales = 2^(32 - mask_original)
                       = 2^(32 - 24)
                       = 256

Direcciones usadas = num_subredes × 2^bits_host
                   = 16 × 16
                   = 256 ✅
```



