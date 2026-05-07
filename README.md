# 📦 SIO — Sistema Integral Operativo

Aplicación mobile desarrollada en **Flutter** orientada a la gestión operativa de stock en PyMEs (kioscos, ferreterías, farmacias, almacenes, etc).

---

## Concepto

SIO no reemplaza sistemas existentes de caja (POS), sino que los **complementa** mediante una solución mobile que permite:

* 📱 Operar desde cualquier lugar del local
* 📦 Registrar mercadería en tiempo real
* 🔍 Auditar stock de forma rápida
* ⚡ Reducir errores humanos

Es un **sistema distribuido de operación de depósito**

---

## Problema que resuelve

En la mayoría de los comercios:

* El sistema está centralizado en una sola PC
* El depósito trabaja desconectado
* La carga de mercadería es lenta y propensa a errores

 Resultado: desorden operativo y stock incorrecto

---

## Solución

SIO introduce una capa mobile que permite:

* Escaneo de productos con cámara
* Alta dinámica de productos
* Control de stock en tiempo real
* Auditoría mediante escaneo

---

## Roles

###  Administrador

* Visualiza estadísticas
* Gestiona alertas
* Exporta información
* Controla el sistema completo

###  Empleado

* Registra recepciones
* Escanea productos
* Consulta stock
* Realiza auditorías

---

##  Funcionalidad clave

###  Conversión de unidades (feature principal)

Permite trabajar con productos empaquetados.

Ejemplo:

* Se escanea una caja de tornillos
* La caja contiene 240 unidades

```plaintext
factor_conversion = 240
```

 El sistema transforma automáticamente cajas en unidades reales de stock.

---

##  Funcionalidades principales

* 📷 Escaneo de código de barras (cámara)
* ➕ Alta automática de productos
* 📦 Recepción de mercadería
* 🔄 Auditoría de stock
* 🔍 Búsqueda de productos
* ✏️ Ajuste manual de stock
* 📊 Estadísticas (admin)
* ⚠️ Alertas de stock
* 📁 Exportación a CSV

---

##  Modelo de datos (simplificado)

**Producto**

* id
* nombre
* codigo_barras
* factor_conversion

**Stock**

* producto_id
* cantidad

**Recepcion**

* id
* fecha
* usuario_id

---

##  Arquitectura

```plaintext
UI (Flutter)
↓
Gestión de estado (Provider)
↓
Servicios (lógica)
↓
SQLite (offline)
↓
Firebase (sincronización)
```

---

##  Stack tecnológico

* Flutter (Material 3)
* Firebase (Auth + Firestore)
* SQLite (persistencia local)
* mobile_scanner (cámara)
* provider (estado)
* csv / share_plus (exportación)

---

##  Estado del proyecto

 En desarrollo

Actualmente incluye:

* Login / Register funcional
* Base de Firebase configurada
* Scanner en desarrollo
* Módulo de recepción en progreso

---

##  Objetivo

Desarrollar una aplicación funcional, escalable y cercana a un entorno real de negocio, cumpliendo con los requisitos académicos y aplicando buenas prácticas de desarrollo mobile.

---

##  Autor

Proyecto desarrollado como trabajo práctico en ORT
Carrera: Analista de Sistemas

## Darío Villar | Analista Programador

---
