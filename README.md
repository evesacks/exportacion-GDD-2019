# Exportación
Trabajo practico de exportaciones.
Gestion de datos 2019.
Facultad Regional Delta.

Objetivo.
Desarrollar un sistema para exportar files, con el objetivo de establecer un proceso centralizado de exportaciones
de files.
El sistema debe contemplar al menos los siguientes módulos:
• Definiciones.
• Operaciones.
• Log de eventos.
• Respaldo de datos.

Alcance.

Administrar las definiciones para exportar files.
Gestionar las exportaciones de files, se aclara que las exportaciones se realizan en dos fases, ambas sobre demanda.
Generar registro de pesquisas para el seguimiento de las exportaciones.

Descripción del proceso.

Las definiciones para exportar files deben incluir como mínimo los siguientes datos:
• Nombre de la exportación.
• Path (destíno).
• Formato del nombre del file.
• Modalidad (única o incremental).
• Nombre de Tabla (definición estructura).
• Separador de campos.
• Definición suma de control.
• Parámetros para la depuración de datos.
• Ventana horaria para la transferencia.
• Usuario y fecha de ingreso.
• Usuario y fecha de autorización.
• Usuario y fecha de suspensión.
Todos los procesos del back-end que realizan exportaciones reemplazaran todo el código de la exportación por un
mensaje al sistema de exportaciones (primera fase y/o segunda fase según corresponda).

Gestión de Datos.
2019.

TP Exportar Files V0 – Pagina 2 de 3.
El mensaje al sistema de exportaciones, primera fase incluye los siguientes datos:
• Nombre de la exportación.
• Nombre Schema y Tabla que contiene los datos.
• Modalidad.
El sistema de exportaciones devolverá TRUe o FALSE, TRUE si está todo bien.
El mensaje al sistema de exportaciones, primera fase, valida:
• Validar que exista el Nombre de la exportación.
• Validar que exista Nombre Schema y Tabla que contiene los datos.
• Validar la Modalidad
• Si existe datos en Nombre Schema y tabla, validar que la definición de la tabla sea similar a la definición
de la tabla de la exportación.

Luego de la validación:

• Copiar los datos a una tabla transitoria.
• Registrar la solicitud de exportación
• Responder TRUE.
En caso que la modalidad sea R (reproceso), debe eliminar todas las solicitudes de exportaciónes pendientes
correspondiente al Nombre de exportación, y reemplazarla por esta nueva solicitud.
El mensaje al sistema de exportaciones, segunda fase incluye los siguientes datos:
• Nombre de la exportación.
• Modalidad.
El sistema de exportaciones devolverá TRUE o FALSE, TRUE si está todo bien.
El mensaje al sistema de exportaciones, segunda fase, valida:
• Validar que exista el Nombre de la exportación.
• Validar la Modalidad

Luego de la validación:

• Acumular todos los datos de las tablas transitorias registrados para ese Nombre de la exportación, que
estén pendientes.
• Generar header, fecha proceso – Nombre de la exportación.
• Generar tráiler, fecha proceso – cantidad de registro – suma de control.
• Preparar nombre del file destino de acuerdo formato de nombre.
• Si la hora de proceso está dentro de la ventana horario, realizar la exportación.
• Si la hora de proceso es menor a la ventana horaria, dejarla pendiente.
• Si la hora de proceso es mayor a la ventana horaria, dejarla pendiente.

Gestión de Datos.
2019.

TP Exportar Files V0 – Pagina 3 de 3.

• Responder TRUE.
Preparar y definir mensajes al sistema de exportaciones que se encarguen de exportar los files preparados, y que no
fueron exportados por estar fuera de la ventana horaria.
Definir un proceso de depuración de las tablas transitorias una vez realizadas las exportaciones.
Todos los mensajes contestaran con un boolean (TRUE o FALSE), y los parámetros de entradas será un campo
texto con la siguiente estructura:
‘I,Campo1,Valor1,Campo2,Valor2,Campo3,Valor3,F’
Donde
I y F son constantes.
Campo1 es el nombre del campo.
Valor1 es el valor de campo.
Debe generar al menos un log por cada respuestas FALSE.

Se pide.

DER para el sistema de exportaciones.
Diseñar un prototipo funcional del sistema.
