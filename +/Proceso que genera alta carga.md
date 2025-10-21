---
up:
  - "[[LFCS recuperación]]"
related: []
tags:
  - repaso/estudio
  - LFCS
---

## Escenario 2: Proceso que genera alta carga y *no* está relacionado con un punto de montaje específico. 

**Enunciado aproximado:** El servidor está experimentando una carga inusualmente alta. Un proceso del sistema no relacionado con ningún punto de montaje específico parece ser el culpable. Se requiere identificar y detener este proceso para restaurar la estabilidad. 

### Cómo abordaría la incidencia:

1. **Identificar el proceso:**
	    - usar `top` o `htop` para identificar los procesos con mayor consumo de CPU/Memoria. `ps aux --sort=-%cpu | head -n 10` (para ver los 10 procesos que más CPU consumen, incluyendo la cabecera) también es muy útil.
	    - Prestaría atención al usuario que ejecuta el proceso (root, www-data, un usuario normal), al nombre del proceso y al porcentaje de CPU que consume.
	    - Obtendría el PID del proceso sospechoso. 
2. **Analizar la causa (crítico aquí):**
    - Dado que no está ligado a un montaje, la causa podría ser un script mal configurado, un software con un bug, un ataque de denegación de servicio, una base de datos descontrolada, etc.
    - Revisaría los logs del proceso si tiene (`/var/log/` o logs específicos de la aplicación).
    - Verificaría la línea de comandos completa (`ps -fp [PID]`) para entender qué está ejecutando el proceso y con qué argumentos.
    - Podría usar `strace -p [PID]` (con precaución en producción, ya que puede ralentizar el proceso) para ver las llamadas al sistema que está realizando.
    - Revisaría el uso de red (`netstat -tulnp | grep [PID]`) si sospecho de actividad de red.
3. **Detener el proceso problemático:**
    - Intentaría una terminación "graciosa" primero. 
      ```bash 
	     sudo kill [PID] 
	     ```
    - Si no responde, usaría una terminación forzada. 
      ```bash
	     sudo kill -9 [PID] 
	     ``` 
4. **Verificar que el proceso ha terminado:**
      ```bash
      ps aux | grep [nombre_proceso] 
      ```
5. **Acciones post-incidencia:**
    - **¡Muy importante aquí!** Determinar la causa raíz es esencial para evitar que vuelva a ocurrir.
    - Si fue un script, ¿por qué se descontroló? ¿Hay un bucle infinito?
    - Si fue un servicio, ¿necesita ser reconfigurado? ¿Hay una actualización de software disponible para corregir un bug?
    - Si fue un problema de seguridad, ¿necesito aislar el servidor y realizar una investigación de seguridad?
    - Monitorear el sistema de cerca después de la intervención para asegurar que la carga se ha normalizado y que el problema no reaparece.

