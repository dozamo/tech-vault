## EJEMPLO COMPLETO CON NOMENCLATURA CONSISTENTE

**Escenario:** 192.168.1.0/24 → 8 subredes

```
DATOS:
mask_original = 24

PASO 1: Determinar bits_prestados
num_subredes = 8
2^bits_prestados = 8
bits_prestados = 3

PASO 2: Calcular mask_nueva
mask_nueva = mask_original + bits_prestados
mask_nueva = 24 + 3 = 27

PASO 3: Calcular capacidad
bits_host = 32 - mask_nueva = 32 - 27 = 5
num_hosts = 2^bits_host - 2 = 2^5 - 2 = 30

RESULTADO:
mask_nueva = /27
num_subredes = 8
num_hosts = 30 por subred
```
