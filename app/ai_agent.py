import os
import re
import json
import requests
from typing import Dict, Any, Optional, Tuple
from pathlib import Path

from PySide6.QtCore import QObject, Signal, Slot, QThreadPool, QRunnable

from app.logger import logger, LOG_FILE_PATH

OLLAMA_API_URL = "http://localhost:11434/api"
DEFAULT_MODEL = "llama3"


class AIAgentWorker(QRunnable):
    def __init__(self, fn, *args, **kwargs):
        super().__init__()
        self.fn = fn
        self.args = args
        self.kwargs = kwargs

    def run(self):
        try:
            self.fn(*self.args, **self.kwargs)
        except Exception as exc:
            logger.error(f"Error en hilo de ejecución del agente IA: {exc}")


class AIAgent(QObject):
    messageReceived = Signal(str, str, str)  
    isProcessingChanged = Signal(bool)
    ollamaStatusChanged = Signal(bool, str)

    def __init__(self, config_manager, parent: Optional[QObject] = None):
        super().__init__(parent)
        self.config_manager = config_manager
        self.thread_pool = QThreadPool.globalInstance()
        self._is_processing = False
        self._ollama_available = False
        self._active_model = "Motor Local Autónomo"

        self.check_ollama_status()

    @Slot()
    def check_ollama_status(self):
        def _check():
            try:
                resp = requests.get(f"{OLLAMA_API_URL}/tags", timeout=1.5)
                if resp.status_code == 200:
                    data = resp.json()
                    models = [m.get("name", "") for m in data.get("models", [])]
                    if models:
                        self._ollama_available = True
                        self._active_model = f"Ollama ({models[0]})"
                    else:
                        self._ollama_available = True
                        self._active_model = "Ollama (Sin modelos)"
                else:
                    self._ollama_available = False
                    self._active_model = "Motor Local Autónomo"
            except Exception:
                self._ollama_available = False
                self._active_model = "Motor Local Autónomo"

            try:
                self.ollamaStatusChanged.emit(self._ollama_available, self._active_model)
            except Exception:
                pass
            logger.info(f"Estado de IA detectado: {self._active_model} (Ollama activo: {self._ollama_available})")

        self.thread_pool.start(AIAgentWorker(_check))

    @Slot(str)
    def send_user_prompt(self, user_text: str):
        
        clean_text = user_text.strip()
        if not clean_text:
            return

        self.messageReceived.emit("user", clean_text, "")
        self._set_processing(True)

        def _process():
            response_text, action_summary = self._handle_prompt(clean_text)
            self.messageReceived.emit("ai", response_text, action_summary)
            self._set_processing(False)

        self.thread_pool.start(AIAgentWorker(_process))

    def _set_processing(self, val: bool):
        self._is_processing = val
        self.isProcessingChanged.emit(val)

    def _handle_prompt(self, text: str) -> Tuple[str, str]:
        
        low = text.lower()
        lang = self.config_manager.language

        if any(w in low for w in [
            "sello", "sellos", "seal", "seals", "sha256", "sha-256", "hash",
            "integridad", "integrity", "rompe", "romper", "romperia", "romperían",
            "romperian", "romperse", "criptografic", "criptográfic", "tamper",
            "autosanacion", "auto-sanacion", "auto-sanación", "self-healing", "acid"
        ]):
            return self._explain_seals_and_integrity(low, lang)

        file_cmd_res = self._handle_file_command(text, low, lang)
        if file_cmd_res is not None:
            return file_cmd_res

        if any(w in low for w in ["diagnost", "log", "error", "falla", "reporte", "bitacora", "bitácora", "salud", "telemetria", "telemetría"]):
            return self.diagnose_system_logs()

        if any(w in low for w in ["donde", "dónde", "como", "cómo", "que hago", "qué hago", "guia", "guía", "ayuda", "help", "manual", "explicame", "explícame", "documentos", "archivos", "guardar", "maquina del tiempo", "máquina del tiempo", "arquitectura", "funcionamiento", "que hace", "qué hace"]):
            return self._generate_guide_response(low, lang)

        if self._ollama_available:
            try:
                ai_res, actions = self._query_ollama(text)
                if ai_res:
                    return ai_res, actions
            except Exception as e:
                logger.warning(f"Consulta a Ollama falló, usando motor autónomo: {e}")

        return self._process_local_intent(text)

    def _explain_seals_and_integrity(self, text: str, lang: str) -> Tuple[str, str]:
        
        is_en = (lang == "en")

        if is_en:
            msg = (
                "###  Cryptographic Integrity & Seal Architecture in NEXUS\n\n"
                "#### 1. Which cryptographic seal do we use?\n"
                "NEXUS Enterprise implements **SHA-256 (Secure Hash Algorithm 256-bit)**, standardized by the NIST under federal standard **FIPS 180-4**.\n"
                "- **Digital Digest:** Generates an irreversible, deterministic 64-character hexadecimal fingerprint (256 bits).\n"
                "- **Metadata Stamp:** The master configuration `config.json` embeds this signature in its `_meta.integrity_hash` property. Every snapshot in the **Time Machine** (`data/historial/`) is also sealed with SHA-256.\n\n"
                "#### 2. How and under what conditions are seals broken?\n"
                "A seal is invalidated or broken under the following scenarios:\n"
                "1. **Manual external tampering:** If someone edits `data/config.json` using Notepad, VS Code, or another external text editor and changes even **a single character, comma, or space** without recomputing `_meta.integrity_hash`.\n"
                "2. **Avalanche Effect (Efecto Avalancha):** In SHA-256, changing **1 single bit** of input flips more than 50% of the resulting digest characters unpredictably. Any alteration is immediately detectable upon validation.\n"
                "3. **JSON Syntax Invalidation:** Unescaped quotes, unclosed braces, or trailing commas triggering `JSONDecodeError`.\n"
                "4. **Pydantic Schema Violation:** Modifying values to invalid types or out-of-range limits (e.g. `font_size: 999` instead of 10–28, or unsupported theme values).\n"
                "5. **Power Outage During Direct Writes:** Standard file writes leave 0-byte corrupt files if interrupted. NEXUS eliminates this risk using **Safe-Write Atomic Commits** (`.tmp` write followed by atomic `os.replace`).\n"
                "6. **Encoding Corruption:** Saving files with non-UTF-8 encodings (ANSI, Windows-1252, UTF-16).\n\n"
                "#### 3. How does NEXUS respond when a seal is broken? (Self-Healing)\n"
                "- The persistence engine immediately catches the `ConfigIntegrityError`.\n"
                "- **Autonomous Self-Healing Protocol:** It automatically recovers the verified version from `data/config.bak` or the previous snapshot in the **Time Machine** (`data/historial/`).\n"
                "- The damaged file is reconstructed atomically, audited in `logs/app.log`, and real-time telemetry notifies the user without any service interruption."
            )
            return msg, "Integrity & Seal Explanation"
        else:
            msg = (
                "###  Arquitectura de Integridad y Sellos Criptográficos en NEXUS\n\n"
                "#### 1. ¿Cuál sello criptográfico usamos?\n"
                "NEXUS Enterprise utiliza el algoritmo estándar **SHA-256 (Secure Hash Algorithm de 256 bits)**, avalado por el NIST bajo la norma federal **FIPS 180-4**.\n"
                "- **Firma Criptográfica:** Genera un resumen digital determinista, irreversible y unidireccional de **64 caracteres hexadecimales (256 bits)**.\n"
                "- **Estampado en Metadatos:** El archivo maestro `config.json` aloja su firma en el nodo `_meta.integrity_hash`. Cada snapshot en la **Máquina del Tiempo** (`data/historial/`) se encuentra igualmente certificado con este sello.\n\n"
                "#### 2. ¿Cómo o de qué maneras se romperían los sellos?\n"
                "El sello de integridad se rompe o invalida ante cualquiera de los siguientes escenarios:\n"
                "1. **Edición manual externa sin firma:** Si abres `data/config.json` con Bloc de Notas, VS Code o cualquier editor de texto y alteras aunque sea **un solo caracter, espacio, salto de línea o coma** sin actualizar la firma `_meta.integrity_hash`.\n"
                "2. **Efecto Avalancha (Avalanche Effect):** En SHA-256, cambiar **un solo bit** en el archivo original altera de forma caótica e impredecible más del **50% de los caracteres del hash resultante**. Cualquier modificación externa es inmediatamente detectada.\n"
                "3. **Inyección de sintaxis JSON inválida:** Borrar llaves, comas colgantes o caracteres de escape erróneos que disparen `JSONDecodeError`.\n"
                "4. **Violación de restricciones de esquema (Pydantic):** Colocar valores fuera de rango o de tipo erróneo (por ejemplo, `font_size: 99` o `theme: 'verde'`), ya que `ConfigSchema` valida estrictamente los datos.\n"
                "5. **Cortes de energía o fallos de E/S a mitad de escritura:** Si se interrumpe la corriente en una escritura directa tradicional, el archivo queda truncado a 0 bytes. En NEXUS esto se previene mediante **Safe-Write Atómico** (escritura en `.tmp` y reemplazo atómico `os.replace`).\n"
                "6. **Corrupción de codificación:** Guardar el archivo en ANSI, Windows-1252 o UTF-16 en lugar de UTF-8 estricto.\n\n"
                "#### 3. ¿Cómo actúa NEXUS cuando un sello se rompe? (Auto-Sanación / Self-Healing)\n"
                "- El motor de persistencia detecta inmediatamente el fallo mediante `ConfigIntegrityError`.\n"
                "- **Protocolo de Auto-Sanación:** El sistema rescata automáticamente la versión íntegra desde `data/config.bak` o el snapshot previo de la **Máquina del Tiempo** (`data/historial/`).\n"
                "- El archivo dañado es sustituido de forma transparente y atómica, registrando el incidente en `logs/app.log` y alertando al usuario en la interfaz sin interrumpir la operación."
            )
            return msg, "Explicación de Sellos e Integridad"

    def _handle_file_command(self, text: str, low: str, lang: str) -> Optional[Tuple[str, str]]:
        
        if any(w in low for w in ["elimina", "borra", "eliminar", "borrar", "suprime", "suprimir", "delete", "remove"]):
            del_res = self._execute_file_delete(text, low, lang)
            if del_res:
                return del_res

        if any(w in low for w in ["edita", "editar", "modifica", "modificar", "actualiza", "actualizar", "edit", "modify", "update"]):
            edit_res = self._execute_file_edit(text, low, lang)
            if edit_res:
                return edit_res

        if any(w in low for w in ["crea", "crear", "agrega", "agregar", "añade", "añadir", "anade", "anadir", "add", "create", "new"]):
            create_res = self._execute_file_create(text, low, lang)
            if create_res:
                return create_res

        return None

    def _execute_file_delete(self, text: str, low: str, lang: str) -> Optional[Tuple[str, str]]:
        
        is_en = (lang == "en")
        del_match = re.search(
            r"(?:elimina|borra|eliminar|borrar|suprime|suprimir|delete|remove)\s+(?:el\s+|un\s+)?(?:archivo|documento|document|file)?\s*([a-zA-Z0-9_\-\.]+)",
            text, re.IGNORECASE
        )
        if not del_match:
            return None

        raw_filename = del_match.group(1).strip()

        if raw_filename.lower() in ("config.json", "config"):
            msg = (
                "⚠️ **Acción denegada por seguridad:** `config.json` es la configuración maestra de la aplicación "
                "y cuenta con protección de integridad activa. No se puede eliminar del sistema.\n\n"
                "💡 *Si deseas volver a la configuración inicial, puedes pedirme: 'Restablecer valores de fábrica'*."
                if not is_en else
                "⚠️ **Action denied for security:** `config.json` is the system master configuration "
                "and is strictly protected. It cannot be deleted.\n\n"
                "💡 *To return to defaults, ask me: 'Restore factory settings'*."
            )
            return msg, "Protección Activa"

        data_dir = Path(__file__).resolve().parent.parent / "data"
        target_path = (data_dir / raw_filename).resolve()

        if not target_path.exists() and "." not in raw_filename:
            for ext in (".json", ".txt", ".bak", ".log"):
                candidate = data_dir / f"{raw_filename}{ext}"
                if candidate.exists():
                    target_path = candidate
                    raw_filename = candidate.name
                    break

        if not target_path.exists():
            msg = (
                f"❌ No se encontró ningún archivo llamado **{raw_filename}** en el directorio de datos (`data/`)."
                if not is_en else
                f"❌ File **{raw_filename}** was not found in the `data/` directory."
            )
            return msg, "Archivo no encontrado"

        success = self.config_manager.deleteConfigFile(target_path.name)
        if success:
            msg = (
                f"🗑️ El documento **{target_path.name}** ha sido eliminado exitosamente.\n\n"
                f"La lista de archivos del explorador se ha sincronizado automáticamente."
                if not is_en else
                f"🗑️ Document **{target_path.name}** was successfully deleted.\n\n"
                f"The file explorer list has synchronized automatically."
            )
            return msg, f"Eliminado: {target_path.name}"
        else:
            msg = (
                f"❌ Ocurrió un inconveniente al intentar eliminar **{target_path.name}**."
                if not is_en else
                f"❌ Could not delete **{target_path.name}**."
            )
            return msg, "Error al eliminar"

    def _execute_file_create(self, text: str, low: str, lang: str) -> Optional[Tuple[str, str]]:
        is_en = (lang == "en")

        m = re.search(
            r"(?:crea|crear|agrega|agregar|añade|añadir|anade|anadir|add|create|new)\s+(?:un\s+|el\s+|a\s+)?(?:archivo|documento|document|file)?\s*(?:llamado|nombrado|named|called)\s+([a-zA-Z0-9_\-\.]+)\s*(?:de\s+tipo|con\s+tipo|con\s+extensi[oó]n|of\s+type|type)\s+([a-zA-Z0-9]+)",
            text, re.IGNORECASE
        )
        raw_name = ""
        file_type = ""
        if m:
            raw_name = m.group(1).strip()
            file_type = m.group(2).strip().lower().replace(".", "")

        if not m:
            m = re.search(
                r"(?:crea|crear|agrega|agregar|añade|añadir|anade|anadir|add|create|new)\s+(?:un\s+|el\s+|a\s+)?(?:archivo|documento|document|file)\s+([a-zA-Z0-9_\-\.]+)\s*(?:de\s+tipo|con\s+tipo|con\s+extensi[oó]n|of\s+type|type)\s+([a-zA-Z0-9]+)",
                text, re.IGNORECASE
            )
            if m:
                raw_name = m.group(1).strip()
                file_type = m.group(2).strip().lower().replace(".", "")

        if not m:
            m = re.search(
                r"(?:crea|crear|agrega|agregar|añade|añadir|anade|anadir|add|create|new)\s+(?:un\s+|el\s+|a\s+)?(?:archivo|documento|document|file)?\s*(?:llamado|nombrado|named|called)\s+([a-zA-Z0-9_\-\.]+)",
                text, re.IGNORECASE
            )
            if m:
                raw_name = m.group(1).strip()

        if not m:
            m = re.search(
                r"(?:crea|crear|agrega|agregar|añade|añadir|anade|anadir|add|create|new)\s+(?:un\s+|el\s+|a\s+)?(?:archivo|documento|document|file)\s+([a-zA-Z0-9_\-\.]+)",
                text, re.IGNORECASE
            )
            if m:
                raw_name = m.group(1).strip()

        if not raw_name:
            return None

        if file_type:
            if raw_name.lower().endswith(f".{file_type}"):
                final_name = raw_name
            else:
                final_name = f"{raw_name}.{file_type}"
        else:
            if "." in raw_name:
                final_name = raw_name
                file_type = raw_name.rsplit(".", 1)[1].lower()
            else:
                final_name = f"{raw_name}.json"
                file_type = "json"

        data_dir = Path(__file__).resolve().parent.parent / "data"
        target_path = data_dir / final_name

        if target_path.exists():
            msg = (
                f"⚠️ El archivo **{final_name}** ya existe en `data/`.\n"
                f"Puedes seleccionarlo en la sección **Documentos y Archivos** para editar su contenido."
                if not is_en else
                f"⚠️ File **{final_name}** already exists in `data/`.\n"
                f"You can select it in the **Documents & Files** tab to edit its content."
            )
            return msg, "Archivo ya existente"

        base_title = final_name.rsplit(".", 1)[0]
        if file_type == "json":
            initial_content = json.dumps({
                "nombre": base_title,
                "tipo": "json",
                "version": "1.0",
                "activo": True,
                "creado_por": "NEXUS Core AI",
                "descripcion": f"Documento {final_name} gestionado por NEXUS Enterprise"
            }, indent=2, ensure_ascii=False) + "\n"
        elif file_type == "txt":
            initial_content = (
                f"# ========================================\n"
                f"# NEXUS Enterprise - Documento de Texto\n"
                f"# Archivo: {final_name}\n"
                f"# Creado por: NEXUS Core AI\n"
                f"# Codificación: UTF-8\n"
                f"# ========================================\n\n"
            )
        else:
            initial_content = (
                f"# NEXUS Enterprise - Documento {final_name}\n"
                f"# Formato: {file_type.upper()}\n"
            )

        try:
            target_path.write_text(initial_content, encoding="utf-8")
            logger.info(f"AIAgent creó nuevo documento: {final_name}")
            self.config_manager.filesChanged.emit()
            self.config_manager.notificationReceived.emit(
                "success",
                "Archivo Creado" if not is_en else "File Created",
                f"Se creó {final_name} con éxito." if not is_en else f"File {final_name} created successfully."
            )
            msg = (
                f"📄 El documento **{final_name}** (tipo: `{file_type}`) fue creado exitosamente.\n\n"
                f"✓ Codificación UTF-8 garantizada.\n"
                f"✓ Ya está disponible de inmediato en la sección **Documentos y Archivos** para ver o modificar su contenido."
                if not is_en else
                f"📄 Document **{final_name}** (type: `{file_type}`) was created successfully.\n\n"
                f"✓ Strict UTF-8 encoding.\n"
                f"✓ Available immediately in the **Documents & Files** section."
            )
            return msg, f"Creado: {final_name}"
        except Exception as exc:
            logger.error(f"Error AIAgent al crear {final_name}: {exc}")
            msg = (
                f"❌ Error al crear el archivo {final_name}: {exc}"
                if not is_en else
                f"❌ Error creating file {final_name}: {exc}"
            )
            return msg, "Error de creación"

    def _execute_file_edit(self, text: str, low: str, lang: str) -> Optional[Tuple[str, str]]:
        
        is_en = (lang == "en")
        m = re.search(
            r"(?:edita|editar|modifica|modificar|actualiza|actualizar|edit|modify|update)\s+"
            r"(?:el\s+|un\s+)?(?:archivo|documento|document|file)?\s*([a-zA-Z0-9_\-\.]+)\s*"
            r"(?:con\s+el\s+contenido|con\s+contenido|con|with\s+content|with)?\s*[:=]\s*(.+)",
            text, re.IGNORECASE | re.DOTALL
        )
        if not m:
            m = re.search(
                r"(?:edita|editar|modifica|modificar|actualiza|actualizar|edit|modify|update)\s+"
                r"(?:el\s+|un\s+)?(?:archivo|documento|document|file)?\s*([a-zA-Z0-9_\-\.]+)\s+"
                r"(?:con\s+el\s+contenido|con\s+contenido|with\s+content)\s+(.+)",
                text, re.IGNORECASE | re.DOTALL
            )

        if not m:
            return None

        raw_filename = m.group(1).strip()
        new_content = m.group(2).strip()

        data_dir = Path(__file__).resolve().parent.parent / "data"
        target_path = data_dir / raw_filename

        if not target_path.exists() and "." not in raw_filename:
            for ext in (".json", ".txt", ".bak", ".log"):
                candidate = data_dir / f"{raw_filename}{ext}"
                if candidate.exists():
                    target_path = candidate
                    raw_filename = candidate.name
                    break

        if not target_path.exists():
            if "." in raw_filename:
                try:
                    target_path.write_text(new_content, encoding="utf-8")
                    self.config_manager.filesChanged.emit()
                    msg = (
                        f"📝 El archivo **{raw_filename}** no existía, por lo que fue creado y guardado con el contenido indicado."
                        if not is_en else
                        f"📝 File **{raw_filename}** did not exist, so it was created and saved with the specified content."
                    )
                    return msg, f"Guardado: {raw_filename}"
                except Exception as exc:
                    return f"Error: {exc}", "Error de escritura"
            else:
                msg = (
                    f"❌ No se encontró ningún archivo llamado **{raw_filename}** en `data/` para editar."
                    if not is_en else
                    f"❌ File **{raw_filename}** was not found in `data/`."
                )
                return msg, "Archivo no encontrado"

        success = self.config_manager.writeConfigFile(target_path.name, new_content)
        if success:
            msg = (
                f"✏️ El documento **{target_path.name}** ha sido editado y guardado exitosamente.\n\n"
                f"Los cambios ya se encuentran persistidos en disco con codificación UTF-8."
                if not is_en else
                f"✏️ Document **{target_path.name}** was successfully edited and saved.\n\n"
                f"Changes are now persisted to disk in UTF-8."
            )
            return msg, f"Editado: {target_path.name}"
        else:
            msg = (
                f"❌ No se pudo actualizar el archivo **{target_path.name}**. "
                f"Si es un archivo `.json`, asegúrate de que el formato y la sintaxis sean válidos."
                if not is_en else
                f"❌ Could not update **{target_path.name}**. "
                f"If it's a `.json` file, ensure the syntax is valid."
            )
            return msg, "Error al editar"
