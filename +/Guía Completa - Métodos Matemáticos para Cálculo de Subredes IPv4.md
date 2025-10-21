## 1. FUNDAMENTOS MATEMÁTICOS UNIVERSALES

### Fórmulas Maestras

```
Subredes = 2^(bits_prestados)
Hosts_por_subred = 2^(bits_host) - 2
Bits_prestados = nueva_máscara - máscara_original
Bits_host = 32 - nueva_máscara
```

### Principio de Conservación

```
Total_direcciones_original = Número_subredes × Direcciones_por_subred
```

## 2. TABLA NEMOTÉCNICA UNIVERSAL: "LA ESCALERA DE POTENCIAS"

| Bits | Valor | Nemotécnico              | Aplicación   |
| ---- | ----- | ------------------------ | ------------ |
| 1    | 2     | "2 opciones: SÍ/NO"      | 2 subredes   |
| 2    | 4     | "4 puntos cardinales"    | 4 subredes   |
| 3    | 8     | "8 bits = 1 byte"        | 8 subredes   |
| 4    | 16    | "16 años = mayoría edad" | 16 subredes  |
| 5    | 32    | "32 dientes adulto"      | 32 subredes  |
| 6    | 64    | "64 casillas ajedrez"    | 64 subredes  |
| 7    | 128   | "128 caracteres ASCII"   | 128 subredes |
| 8    | 256   | "256 valores byte"       | 256 subredes |

## 3. MÉTODO DEL "SALTO MÁGICO" GENERALIZADO

### Algoritmo Universal:

1. **Convertir CIDR a decimal:** Usar tabla de máscaras
2. **Calcular salto:** 256 - valor_último_octeto_afectado
3. **Generar rangos:** Incrementar por el salto

### Tabla de Máscaras de Referencia:

| CIDR | Máscara Decimal | Último Octeto | Salto |
| ---- | --------------- | ------------- | ----- |
| /25  | 255.255.255.128 | 128           | 128   |
| /26  | 255.255.255.192 | 192           | 64    |
| /27  | 255.255.255.224 | 224           | 32    |
| /28  | 255.255.255.240 | 240           | 16    |
| /29  | 255.255.255.248 | 248           | 8     |
| /30  | 255.255.255.252 | 252           | 4     |

## 4. PATRONES PARA REDES PRIVADAS "PURAS"

### Clase A Privada: 10.0.0.0/8

**Capacidad base:** 16,777,216 direcciones

| Subredes Deseadas | Bits Prestados | Nueva Máscara | Hosts/Subred |
| ----------------- | -------------- | ------------- | ------------ |
| 2                 | 1              | /9            | 8,388,606    |
| 4                 | 2              | /10           | 4,194,302    |
| 8                 | 3              | /11           | 2,097,150    |
| 16                | 4              | /12           | 1,048,574    |
| 256               | 8              | /16           | 65,534       |
| 65,536            | 16             | /24           | 254          |

### Clase B Privada: 172.16.0.0/12

**Capacidad base:** 1,048,576 direcciones

| Subredes Deseadas | Bits Prestados | Nueva Máscara | Hosts/Subred |
| ----------------- | -------------- | ------------- | ------------ |
| 2                 | 1              | /13           | 524,286      |
| 4                 | 2              | /14           | 262,142      |
| 8                 | 3              | /15           | 131,070      |
| 16                | 4              | /16           | 65,534       |
| 256               | 8              | /20           | 4,094        |
| 4,096             | 12             | /24           | 254          |

### Clase C Privada: 192.168.x.0/24

**Capacidad base:** 256 direcciones

| Subredes Deseadas | Bits Prestados | Nueva Máscara | Hosts/Subred |
| ----------------- | -------------- | ------------- | ------------ |
| 2                 | 1              | /25           | 126          |
| 4                 | 2              | /26           | 62           |
| 8                 | 3              | /27           | 30           |
| 16                | 4              | /28           | 14           |
| 32                | 5              | /29           | 6            |
| 64                | 6              | /30           | 2            |

## 5. ALGORITMO DE CÁLCULO PASO A PASO

### Método Sistemático:

```
1. IDENTIFICAR: ¿Cuántas subredes necesito?
2. BUSCAR: En la escalera de potencias, encontrar 2^n ≥ subredes_necesarias
3. CALCULAR: nueva_máscara = máscara_original + n
4. VERIFICAR: ¿Es factible? (nueva_máscara ≤ 30 para LANs)
5. APLICAR: Método del salto para rangos específicos
```

## 6. REGLAS DE OPTIMIZACIÓN

### Regla del "Siguiente Poder de 2":

Si necesitas N subredes, usa el menor 2^n donde 2^n ≥ N

### Regla del "Buffer de Crecimiento":

Para producción, planifica 25-50% más subredes de las requeridas inmediatamente

### Regla de "Máscara Mínima Viable":

- LANs: Nunca exceder /30 (excepto enlaces punto a punto)
- WANs: /30 es común para enlaces dedicados

## 7. VERIFICACIONES MATEMÁTICAS

### Test de Consistencia:

```
Subredes_calculadas × Hosts_por_subred = Direcciones_red_original
```

### Test de Factibilidad:

```
nueva_máscara ≤ 30 (para redes con hosts)
nueva_máscara ≤ 32 (máximo absoluto)
```

## 8. CASOS ESPECIALES Y EXCEPCIONES

### VLSM (Variable Length Subnet Masking):

Cuando necesitas subredes de diferentes tamaños, aplica las reglas por separado a cada segmento.

### Supernetting:

Para agregar redes, resta bits en lugar de sumarlos.

### Direcciones Reservadas:

Siempre restar 2 del total de hosts (red + broadcast).

---

**Nota técnica:** Este documento cubre el 95% de escenarios de subretting en redes empresariales. Para casos edge específicos, consultar RFCs 950, 1518, y 1519.