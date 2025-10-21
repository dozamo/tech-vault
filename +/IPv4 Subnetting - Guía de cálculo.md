---
up: "[[IPv4 subnetting]]"
parent: ["[[IPv4 Subnetting CIRD - enfoque en Red vs Host]]", "[[IPv4 Subnetting CIRD - enfoque en Red vs Host]]", "[[IPv4 Subnetting - Guía de cálculo]]"]
---

# GUÍA: Nomenclatura Matemática Estandarizada

## NOMENCLATURA ESTÁNDAR (Usar SIEMPRE)

### Variables Fundamentales:

```
mask_original  = Máscara CIDR de la red original (ejemplo: 24 en /24)
mask_nueva     = Máscara CIDR de las subredes nuevas (ejemplo: 27 en /27)
num_subredes  = Número de subredes a crear
num_hosts     = Número de hosts utilizables por subred
bits_prestados = Bits prestados para crear subredes
bits_host      = Bits disponibles para hosts
```

## FÓRMULAS MAESTRAS ESTANDARIZADAS

### **1. Cálculo de Subredes:**

```
num_subredes = 2^bits_prestados
```

### **2. Cálculo de Hosts:**

```
num_hosts = 2^bits_host - 2
```

### **3. Relación entre Bits:**

```
bits_prestados = mask_nueva - mask_original
bits_host = 32 - mask_nueva
```

### **4. Cálculo de Máscara Nueva:**

```
mask_nueva = mask_original + bits_prestados
```

### **5. Verificación de Consistencia:**

```
2^(32 - mask_original) = num_subredes × 2^bits_host
```

## TABLA DE REFERENCIA REFACTORIZADA

### Escalera de Potencias (ESTANDARIZADA):

|bits_prestados o bits_host|Valor|Aplicación|
|---|---|---|
|1|2|2 subredes / 2 hosts|
|2|4|4 subredes / 4 hosts|
|3|8|8 subredes / 8 hosts|
|4|16|16 subredes / 16 hosts|
|5|32|32 subredes / 32 hosts|
|6|64|64 subredes / 64 hosts|
|7|128|128 subredes / 128 hosts|
|8|256|256 subredes / 256 hosts|

## MÉTODO DEL "SALTO MÁGICO"

```
Salto = 256 - Valor_octeto_máscara

Donde:
Valor_octeto_máscara = valor decimal del octeto afectado
```

## ALGORITMO COMPLETO

```
ENTRADA: mask_original, requisito (num_subredes O num_hosts)

SI conoces num_hosts requeridos:
   1. Calcular: bits_host donde 2^bits_host - 2 ≥ num_hosts
   2. Calcular: mask_nueva = 32 - bits_host
   3. Calcular: bits_prestados = mask_nueva - mask_original
   4. Verificar: num_subredes = 2^bits_prestados (¿suficientes?)

SI conoces num_subredes requeridas:
   1. Calcular: bits_prestados donde 2^bits_prestados ≥ num_subredes
   2. Calcular: mask_nueva = mask_original + bits_prestados
   3. Calcular: bits_host = 32 - mask_nueva
   4. Calcular: num_hosts = 2^bits_host - 2

SALIDA: mask_nueva, num_subredes, num_hosts
```
