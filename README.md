# NEXUS Enterprise v3.0

**Sistema de Configuración, Persistencia Transaccional y Autodiagnóstico con IA Local**

> Laboratorio No. 1 — Ingeniería en Informática y Sistemas

---

## Descripción

NEXUS Enterprise es una aplicación de escritorio de grado industrial que combina:

- **Motor de Persistencia Transaccional (ACID):** Safe-Write con respaldos automáticos y commit atómico a nivel de kernel.
- **Auto-Sanación (Self-Healing):** Recuperación automática ante archivos ausentes, corruptos o inaccesibles por permisos.
- **Asistente de IA Local (Zero-Cloud):** Motor de inteligencia artificial 100% offline con soporte opcional para Ollama.
- **Interfaz Moderna PySide6 / QML:** Renderizado acelerado por hardware a 60 FPS con temas dinámicos y componentes reactivos.
- **Centro de Telemetría y Diagnóstico en Vivo:** Semáforos de integridad, visor de logs en streaming y banco de pruebas de laboratorio.

---

## Requisitos del Sistema

- **Python:** 3.10 o superior (recomendado 3.12+)
- **Sistema Operativo:** Windows 10/11, macOS 12+, Linux (Ubuntu 22.04+)
- **RAM:** Mínimo 512 MB disponibles para la UI
- **(Opcional) Ollama:** Para habilitar el asistente con LLM avanzado — [https://ollama.ai](https://ollama.ai)

---

## Instalación

```bash
# 1. Clonar el repositorio
git clone <repo-url>
cd Nexus_Enterprise_lb1

# 2. Instalar dependencias
pip install -r requirements.txt

# 3. Ejecutar la aplicación
python main.py
```

---

## Estructura de Directorios

```
Nexus_Enterprise_lb1/
├── main.py                   # Punto de entrada — Puente QML/Python
├── requirements.txt          # Dependencias: PySide6, pydantic, requests
├── README.md
├── .gitignore
│
├── app/
│   ├── __init__.py
│   ├── validators.py         # Esquema Pydantic (ConfigSchema) y validación de esquemas
│   ├── logger.py             # Sistema de logs UTF-8 con señales Qt en tiempo real
│   ├── config_manager.py     # Motor Safe-Write, Self-Healing y ViewModel MVVM
│   └── ai_agent.py           # Agente IA local (Ollama + Motor Autónomo NLP)
│
├── ui/
│   ├── main.qml              # Interfaz gráfica principal (3 vistas: Config, IA, Telemetría)
│   └── components/
│       ├── Toast.qml         # Notificaciones flotantes animadas
│       └── StatCard.qml      # Tarjetas de estado para el panel de telemetría
│
├── data/
│   ├── config.json           # Configuración activa (UTF-8)
│   ├── config.bak            # Respaldo automático (Safe-Write)
│   └── profile/
│       └── profile.png       # Avatar del usuario
│
└── logs/
    └── app.log               # Registro histórico del sistema (UTF-8)
```

---

## Ciclo Transaccional Safe-Write (Sección 2.1)

Cada operación de guardado sigue este protocolo de 5 pasos:

```
[Usuario / Interfaz QML]
         │
         ▼
[1. Validación Pydantic Estricta]   → Aborta si el esquema es inválido
         │
         ▼
[2. Respaldo Preventivo]            → config.json → config.bak
         │
         ▼
[3. Escritura Aislada (UTF-8)]      → Nuevo contenido → config.tmp
         │
         ▼
[4. Commit Atómico (os.replace)]    → config.tmp → config.json
         │
         ▼
[5. Limpieza de Residuos]           → config.tmp eliminado
```

---

## Sistema de Auto-Sanación (Sección 2.2)

| Excepción                | Comportamiento de NEXUS                                              |
|--------------------------|----------------------------------------------------------------------|
| `FileNotFoundError`      | Carga valores por defecto, genera `config.json` limpio y notifica   |
| `json.JSONDecodeError`   | Detecta corrupción, restaura desde `config.bak`, notifica al usuario |
| `ValidationError`        | Aborta transacción antes de tocar el disco                           |
| `PermissionError`        | Activa Modo Solo Lectura en memoria, nunca cierra la app abruptamente|

---

## Asistente de IA Local (Sección 3.1)

El agente de IA opera con **dos motores en paralelo**:

1. **Motor Ollama (si está instalado):** Consulta al servidor local en `http://localhost:11434` utilizando modelos como `llama3`, `mistral` o `phi3`.
2. **Motor Autónomo Local (garantizado):** Sistema NLP basado en reglas semánticas que interpreta órdenes en lenguaje natural sin dependencias externas.

### Ejemplos de comandos:
- `"Pone la interfaz oscura, haz la letra más grande y cámbialo a español"`
- `"Color de acento morado y fuente 18"`
- `"Diagnosticar logs del sistema"`
- `"Restablecer valores de fábrica"`

---

## Guía de Pruebas de Evaluación (Sección 8)

Las 4 pruebas se pueden ejecutar desde la interfaz en **Diagnóstico → Banco de Pruebas**:

| # | Prueba | Acción | Resultado Esperado |
|---|--------|--------|--------------------|
| 1 | Archivo Ausente | Elimina `config.json` y recarga | Valores por defecto cargados sin excepción |
| 2 | Archivo Corrupto | Inyecta JSON inválido y recarga | Recuperación automática desde `config.bak` |
| 3 | Caracteres UTF-8 | Guarda `"César Ñandú de España"` | Caracteres íntegros en `config.json` |
| 4 | Escritura Segura | 3 commits masivos consecutivos | Sin residuos `config.tmp` tras cada commit |

---

## Uso del Asistente de IA con Ollama (Opcional)

```bash
# Instalar Ollama desde https://ollama.ai
# Descargar un modelo ligero
ollama pull llama3

# Iniciar el servidor (ya se inicia automáticamente en instalación)
ollama serve

# Lanzar NEXUS Enterprise (detección automática)
python main.py
```

---

## Licencia

Proyecto académico desarrollado para **Laboratorio No. 1 — Ingeniería en Informática y Sistemas**.

