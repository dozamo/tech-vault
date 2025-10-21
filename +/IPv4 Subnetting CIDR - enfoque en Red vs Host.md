---
up: "[[IPv4 subnetting]]"
parent: ["[[IPv4 Subnetting CIDR]]", "[[IPv4 Subnetting - Guía de cálculo]]"]
---

# ALGORITMO DEFINITIVO: Enfoque en Red vs Host

## CONCEPTO FUNDAMENTAL

### **La Máscara CIDR Define la División Automáticamente:**

```
Dirección IP: 32 bits totales

/X significa:
├─ X bits → PORCIÓN DE RED (fija, no se toca)
└─ (32-X) bits → PORCIÓN DE HOST (aquí trabajamos)
```

### **Visualización:**

```
Ejemplo: 172.31.1.0/24

11111111.11111111.11111111     .00000000
├────── 24 bits RED ──────┤├─ 8 bits HOST ─┤
         (INMUTABLE)                  (MODIFICABLE)
```

## PRINCIPIO DE ORO DEL SUBNETTING

```
SUBNETTING = "PRESTAR" bits de la porción HOST 
             para crear más redes
```

**Lo que pasa internamente:**

```
Antes:   [RED fija] [      TODOS para hosts    ]
Después: [RED fija] [Subredes] [Hosts restantes]
                    ↑          ↑
              (bits prestados) (lo que queda)
```

## ALGORITMO PASO A PASO (VERSIÓN DEFINITIVA)

### **ENTRADA:** Red X.X.X.X/M_original

---

### **ESCENARIO A: Te dan NÚMERO DE SUBREDES**

```
PASO 1: IDENTIFICAR la porción de HOST disponible
   B_host_disponible = 32 - M_original
   
   Ejemplo: 172.31.1.0/24
   B_host_disponible = 32 - 24 = 8 bits para trabajar

PASO 2: CALCULAR cuántos bits PRESTAR de los hosts
   Buscar: 2^B_prestados ≥ N_subredes
   
   Ejemplo: Necesito 7 subredes
   2^3 = 8 ≥ 7 ✓
   B_prestados = 3 bits

PASO 3: CALCULAR nueva máscara (extender la RED)
   M_nueva = M_original + B_prestados
   
   Ejemplo: M_nueva = 24 + 3 = /27
   
   Interpretación:
   [24 bits RED original] + [3 bits prestados] = 27 bits RED
   
PASO 4: CALCULAR hosts restantes
   B_host_restantes = 32 - M_nueva
   N_hosts = 2^B_host_restantes - 2
   
   Ejemplo:
   B_host_restantes = 32 - 27 = 5 bits
   N_hosts = 2^5 - 2 = 30 hosts por subred
```

---

### **ESCENARIO B: Te dan NÚMERO DE HOSTS**

```
PASO 1: IDENTIFICAR la porción de HOST disponible
   B_host_disponible = 32 - M_original
   
   Ejemplo: 172.31.1.0/24
   B_host_disponible = 32 - 24 = 8 bits

PASO 2: CALCULAR cuántos bits NECESITO para hosts
   Buscar: 2^B_host - 2 ≥ N_hosts_requeridos
   
   Ejemplo: Necesito 14 hosts
   2^4 - 2 = 14 ≥ 14 ✓
   B_host_restantes = 4 bits

PASO 3: CALCULAR cuántos bits PUEDO PRESTAR
   B_prestados = B_host_disponible - B_host_restantes
   
   Ejemplo: B_prestados = 8 - 4 = 4 bits
   
PASO 4: CALCULAR nueva máscara
   M_nueva = 32 - B_host_restantes
   O equivalente: M_nueva = M_original + B_prestados
   
   Ejemplo: M_nueva = 32 - 4 = /28
   
PASO 5: VERIFICAR subredes disponibles
   N_subredes = 2^B_prestados
   
   Ejemplo: N_subredes = 2^4 = 16 subredes
```

---

## VISUALIZACIÓN DEL PROCESO

### **Ejemplo Completo: 172.31.1.0/24 → 7 subredes**

#### **Estado Inicial:**

```
172.31.1.0/24
32 bits = [24 bits RED] [8 bits HOST]
          ────────────  ────────────
           INMUTABLE     DISPONIBLE
```

#### **Después del Subnetting (/28):**

```
172.31.1.0/28
32 bits = [24 bits RED original] [4 bits prestados] [4 bits HOST]
          ────────────────────── ────────────────── ──────────────
               INMUTABLE              SUBREDES         HOSTS
          └──────── 28 bits NUEVA RED ──────────┘
```

#### **Resultado:**

```
Bits prestados: 4
Subredes: 2^4 = 16
Hosts por subred: 2^4 - 2 = 14
```

## REGLAS CRÍTICAS

### **REGLA 1: La porción de RED NUNCA cambia**

```
172.31.1.0/24 → /28
Los primeros 24 bits (172.31.1) permanecen FIJOS
Solo modificamos los últimos 8 bits del cuarto octeto
```

### **REGLA 2: Prestamos de HOST, nunca de RED**

```
Disponible: 8 bits HOST
Prestamos: 4 bits → se convierten en SUBRED
Quedan: 4 bits → para HOSTS dentro de cada subred
```

### **REGLA 3: La suma siempre es 32**

```
M_original + B_host_disponible = 32
M_nueva + B_host_restantes = 32
M_original + B_prestados + B_host_restantes = 32
```

## TABLA DE RELACIONES

|Concepto|Fórmula|Qué Manipula|
|---|---|---|
|**Bits disponibles**|32 - M_original|Porción HOST completa|
|**Bits prestados**|M_nueva - M_original|Tomados de HOST|
|**Bits host restantes**|32 - M_nueva|Lo que queda de HOST|
|**Nueva máscara**|M_original + B_prestados|Extiende porción RED|

## VERIFICACIÓN VISUAL

### **Cualquier red se puede visualizar así:**

```
/24: RRRRRRRR.RRRRRRRR.RRRRRRRR.HHHHHHHH
     └──────── 24 bits R ───────┘└─ 8H ─┘

/28: RRRRRRRR.RRRRRRRR.RRRRRRRR.SSSSHHHH
     └──────── 24 bits R ───────┘└4S┘└4H┘
     └────────── 28 bits R ──────────┘

Donde:
R = RED (fija)
S = SUBRED (prestada de H)
H = HOST (restante)
```

## ALGORITMO UNIFICADO FINAL

```
ENTRADA: X.X.X.X/M_original, Requisito

1. B_host_disponible = 32 - M_original
   
2. SI conoces N_subredes:
      B_prestados = log₂(N_subredes) [redondeado arriba]
      B_host_restantes = B_host_disponible - B_prestados
   
   SI conoces N_hosts:
      B_host_restantes = log₂(N_hosts + 2) [redondeado arriba]
      B_prestados = B_host_disponible - B_host_restantes

3. M_nueva = M_original + B_prestados

4. VERIFICAR: M_nueva ≤ 30 (para LANs)

5. CALCULAR resultados:
   N_subredes = 2^B_prestados
   N_hosts = 2^B_host_restantes - 2

SALIDA: M_nueva, N_subredes, N_hosts
```

## CONCLUSIÓN CRÍTICA

✅ **M_original define QUÉ es RED y QUÉ es HOST automáticamente** ✅ **Subnetting = Prestar bits de HOST para crear SUBREDES** ✅ **La porción RED original NUNCA se modifica** ✅ **Las fórmulas manipulan SOLO la porción HOST original**

¿Ahora está 100% claro cómo la guía usa la porción de red vs host?

