---
up: "[[IPv4 subnetting]]"
parent: ["[[IPv4 Subnetting CIRD - enfoque en Red vs Host]]", "[[IPv4 Subnetting - Guía de cálculo]]"]
---

# ¿La guía [[IPv4 Subnetting - Guía de cálculo]] depende de las Clases? 
NO (con explicación)

## RESPUESTA DIRECTA

**[[IPv4 Subnetting - Guía de cálculo]] NO depende de las clases de redes** porque usa **CIDR (Classless Inter-Domain Routing)**, el estándar moderno desde 1993.

## EXPLICACIÓN FUNDAMENTAL - CIDR

### **El /X lo define TODO:**

Cuando escribo `172.31.1.0/24`, el **/24** YA me dice:

```
/24 significa:
- 24 bits para RED
- 8 bits para HOSTS
```

**No necesito saber si es "Clase A, B o C"** porque el CIDR ya especifica la división exacta.

## SISTEMA CLASSFUL vs CIDR

### **Sistema ANTIGUO (Classful - Obsoleto desde 1993):**

|Clase|Primer Octeto|Máscara por Defecto|Bits Red/Host|
|---|---|---|---|
|A|1-126|/8 (255.0.0.0)|8/24|
|B|128-191|/16 (255.255.0.0)|16/16|
|C|192-223|/24 (255.255.255.0)|24/8|

**Problema:** Si te daban `172.16.0.0` sin máscara, asumías /16 (Clase B)

### **Sistema MODERNO (CIDR - Actual):**

```
SIEMPRE se especifica la máscara: 172.16.0.0/X

El /X define EXPLÍCITAMENTE:
- Bits de red = X
- Bits de host = 32 - X
```

**Ventaja:** No hay ambigüedad, funciona con CUALQUIER máscara.

## POR QUÉ [[IPv4 Subnetting - Guía de cálculo]] ES UNIVERSAL

### **Fórmulas universales aplicables a CUALQUIER red:**

```
M_original = Lo que dice el /X original
B_host = 32 - M_nueva
N_hosts = 2^B_host - 2
```

**Ejemplos de la universalidad:**

#### Ejemplo 1: 10.0.0.0/8

```
M_original = 8 (no importa que sea "Clase A")
Para 256 subredes:
B_prestados = 8 (porque 2^8 = 256)
M_nueva = 8 + 8 = /16
```

#### Ejemplo 2: 10.0.0.0/12

```
M_original = 12 (¡no es una máscara "de clase"!)
Para 16 subredes:
B_prestados = 4 (porque 2^4 = 16)
M_nueva = 12 + 4 = /16
```

**Ambos casos usan las mismas fórmulas sin importar la "clase".**

## ¿CUÁNDO IMPORTAN LAS CLASES?

### **CASO 1: Te dan IP sin máscara (RARO hoy)**

```
Problema: "Divide 192.168.1.0 en subredes"
Sin /X, asumes Clase C = /24 por defecto
```

### **CASO 2: Examen de certificación antiguo**

```
Algunas preguntas viejas asumen conocimiento de clases
```

### **CASO 3: Nunca en [[IPv4 Subnetting - Guía de cálculo]]**

```
La guía SIEMPRE requiere el /X completo
Por eso es universal y moderna
```

## ACLARACIÓN SOBRE MI GUÍA ORIGINAL

Cuando escribí tablas como:

```
"Clase A Privada: 10.0.0.0/8"
"Clase B Privada: 172.16.0.0/12"
"Clase C Privada: 192.168.x.0/24"
```

**NO era porque mi guía dependa de clases**, sino:

- Para dar **ejemplos prácticos** con redes privadas comunes
- Para **contexto histórico** (muchos aún usan estos términos)
- Las fórmulas funcionan igual con 10.0.0.0/8 que con 10.0.0.0/15

## REGLA DE ORO REFACTORIZADA

```
SI el problema incluye /X → Usa M_original = X
SI el problema NO incluye /X → Pregunta o asume:
   - IP 1.x.x.x a 126.x.x.x → /8
   - IP 128.x.x.x a 191.x.x.x → /16
   - IP 192.x.x.x a 223.x.x.x → /24
```

## VERIFICACIÓN CON EJEMPLOS

### **Ejemplo "sin clase":**

```
Problema: 200.100.50.0/22 → 8 subredes

M_original = 22 (¡no es /24 de Clase C!)
B_prestados = 3 (porque 2^3 = 8)
M_nueva = 22 + 3 = /25
B_host = 32 - 25 = 7
N_hosts = 2^7 - 2 = 126

¡Las fórmulas funcionan perfectamente!
```

### **Ejemplo "con clase":**

```
Problema: 192.168.1.0/24 → 8 subredes

M_original = 24 (coincide con Clase C por casualidad)
B_prestados = 3
M_nueva = 24 + 3 = /27
B_host = 32 - 27 = 5
N_hosts = 2^5 - 2 = 30

¡Mismo proceso, mismas fórmulas!
```

## CONCLUSIÓN

✅ **La [[IPv4 Subnetting - Guía de cálculo]] es 100% independiente de clases** ✅ **Funciona con CUALQUIER máscara /X** ✅ **El /X define automáticamente la porción de red vs host** ✅ **Las clases solo importan si te dan IPs SIN máscara**

**La guía usa CIDR puro, el estándar moderno de networking desde hace 30+ años.**

¿Te queda claro que las fórmulas funcionan universalmente sin importar la "clase"?