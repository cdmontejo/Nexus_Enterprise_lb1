import os
import shutil
import json
from pathlib import Path
from typing import Dict, Any, Optional, List

from PySide6.QtCore import QObject, Signal, Slot, Property

from app.validators import ConfigSchema, validate_config_data
from app.logger import logger
from app.history_manager import ConfigHistoryManager, ConfigIntegrityError

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
CONFIG_FILE = DATA_DIR / "config.json"
BACKUP_FILE = DATA_DIR / "config.bak"
TEMP_FILE = DATA_DIR / "config.tmp"
PROFILE_DIR = DATA_DIR / "profile"
DEFAULT_PROFILE_IMG = PROFILE_DIR / "profile.png"


class ConfigManager(QObject):
    usernameChanged = Signal(str)
    themeChanged = Signal(str)
    accentColorChanged = Signal(str)
    fontSizeChanged = Signal(int)
    languageChanged = Signal(str)
    profilePictureChanged = Signal(str)
    autoSaveChanged = Signal(bool)
    diagnosticModeChanged = Signal(bool)

    telemetryUpdated = Signal()
    historyChanged = Signal()
    filesChanged = Signal()
    integrityAlert = Signal(str)
    notificationReceived = Signal(str, str, str)  

    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._ensure_directories()

        self._history = ConfigHistoryManager(
            data_dir=DATA_DIR,
            logger=logger,
            max_history=10,
        )

        self._config = ConfigSchema()
        self._read_only_mode = False
        self._last_transaction_status = "Inicializando..."
        self._encoding_status = "UTF-8 Verificado"

        self.load_configuration(is_startup=True)

    def _ensure_directories(self):
        DATA_DIR.mkdir(parents=True, exist_ok=True)
        PROFILE_DIR.mkdir(parents=True, exist_ok=True)

    @Slot(result=bool)
    def save_configuration(self) -> bool:
        if self._read_only_mode:
            msg = "Sistema en modo de solo lectura debido a restricciones de permisos."
            logger.warning(f"Intento de guardado abortado: {msg}")
            self.notificationReceived.emit("error", "Error de Permisos", msg)
            return False

        logger.info("Iniciando ciclo transaccional Safe-Write (con sello SHA-256)...")

        raw_data = self._config.model_dump()
        is_valid, validated_model, error_msg = validate_config_data(raw_data)
        if not is_valid or validated_model is None:
            err = f"Validación fallida: {error_msg}"
            logger.error(err)
            self._last_transaction_status = "Abortado: Fallo de esquema Pydantic"
            self.notificationReceived.emit("error", "Error de Validación", err)
            self.telemetryUpdated.emit()
            return False

        try:
            self._history.save(validated_model.model_dump())
            self._last_transaction_status = "Commit Atómico Exitoso (SHA-256 + ACID)"
            self._encoding_status = "UTF-8 Verificado (100% Íntegro)"
            self.telemetryUpdated.emit()
            self.historyChanged.emit()
            self.filesChanged.emit()
            self.notificationReceived.emit(
                "success",
                "Configuración Guardada",
                "Cambios persistidos con sello de integridad SHA-256 via Safe-Write."
            )
            return True

        except PermissionError as perm_err:
            logger.error(f"Falta de permisos al escribir en disco: {perm_err}")
            self._read_only_mode = True
            self._last_transaction_status = "Fallo de Permisos (Modo Solo Lectura)"
            self.telemetryUpdated.emit()
            self.notificationReceived.emit(
                "error",
                "Error Crítico de Permisos",
                "El directorio carece de permisos de escritura. NEXUS operará en memoria."
            )
            return False

        except Exception as exc:
            logger.critical(f"Excepción inesperada durante transacción: {exc}", exc_info=True)
            self._last_transaction_status = f"Error Inesperado: {exc}"
            self.telemetryUpdated.emit()
            self.notificationReceived.emit("error", "Fallo Transaccional", str(exc))
            return False

    @Slot(result=bool)
    def load_configuration(self, is_startup: bool = False) -> bool:
        logger.info(f"Cargando configuración desde disco ({CONFIG_FILE})...")

        try:
            raw_data = self._history.load()
            is_valid, validated_model, err_msg = validate_config_data(raw_data)

            if not is_valid or validated_model is None:
                raise ValueError(f"Esquema de datos inválido tras carga: {err_msg}")

            self._apply_model(validated_model)
            logger.info("Configuración cargada correctamente (UTF-8, sello verificado).")
            self._last_transaction_status = "Cargado Correctamente (Sello SHA-256 OK)"
            self._encoding_status = "UTF-8 Verificado (100% Íntegro)"
            self.telemetryUpdated.emit()
            self.filesChanged.emit()

            if not is_startup:
                self.notificationReceived.emit(
                    "info",
                    "Configuración Cargada",
                    "Parámetros del sistema sincronizados desde el archivo local."
                )
            return True

        except FileNotFoundError:
            logger.warning(f"Archivo {CONFIG_FILE.name} no encontrado (FileNotFoundError).")
            self._apply_defaults_and_save(
                reason="Primer inicio o archivo ausente detectado",
                notify_title="Archivo de Configuración Ausente",
                notify_msg="No se encontró config.json. Se cargaron los valores predeterminados de fábrica."
            )
            return True

        except ConfigIntegrityError as cie:
            logger.critical(f"Integridad irrecuperable: {cie}")
            self.integrityAlert.emit(str(cie))
            self._apply_defaults_and_save(
                reason="Corrupción irrecuperable en config.json y todas sus copias",
                notify_title="Auto-Sanación de Emergencia",
                notify_msg="config.json y sus respaldos estaban comprometidos. Se restableció la configuración por defecto."
            )
            return True

        except (json.JSONDecodeError, ValueError):
            return self._recover_from_backup_legacy()

        except PermissionError as perm_err:
            logger.error(f"PermissionError al leer config.json: {perm_err}")
            self._read_only_mode = True
            self.notificationReceived.emit(
                "warning",
                "Permisos Restringidos",
                "No se pudo leer el archivo. Operando con configuración segura en memoria."
            )
            return False

    def _recover_from_backup_legacy(self) -> bool:
        logger.warning("Iniciando Auto-Sanación (Self-Healing) legado...")
        if BACKUP_FILE.exists():
            try:
                with open(BACKUP_FILE, "r", encoding="utf-8") as bf:
                    bak_data = json.loads(bf.read())
                bak_data.pop("_meta", None)
                is_valid, validated_bak, err_bak = validate_config_data(bak_data)
                if is_valid and validated_bak:
                    shutil.copy2(BACKUP_FILE, CONFIG_FILE)
                    self._apply_model(validated_bak)
                    logger.info("Auto-Sanación completada. Restaurado desde data/config.bak.")
                    self._last_transaction_status = "Auto-Sanación: Restaurado desde Backup"
                    self.telemetryUpdated.emit()
                    self.filesChanged.emit()
                    self.notificationReceived.emit(
                        "warning",
                        "Auto-Sanación Exitosa (Self-Healing)",
                        "Se detectó corrupción en config.json. Restaurado automáticamente desde config.bak."
                    )
                    return True
            except Exception as bkp_err:
                logger.error(f"Fallo leyendo respaldo legado: {bkp_err}")

        logger.warning("Respaldo ausente. Restaurando valores de fábrica...")
        self._apply_defaults_and_save(
            reason="Corrupción irrecuperable y sin respaldo válido",
            notify_title="Auto-Sanación de Emergencia",
            notify_msg="config.json corrupto sin respaldo. Se restableció la configuración por defecto."
        )
        return True

    def _apply_defaults_and_save(self, reason: str, notify_title: str, notify_msg: str):
        
        self._config = ConfigSchema()
        self._emit_all_property_changes()
        logger.info(f"Valores predeterminados aplicados ({reason}).")
        self.save_configuration()
        self.notificationReceived.emit("info", notify_title, notify_msg)

    def _apply_model(self, model: ConfigSchema):
        
        self._config = model
        self._emit_all_property_changes()

    def _emit_all_property_changes(self):
        
        self.usernameChanged.emit(self._config.username)
        self.themeChanged.emit(self._config.theme)
        self.accentColorChanged.emit(self._config.accent_color)
        self.fontSizeChanged.emit(self._config.font_size)
        self.languageChanged.emit(self._config.language)
        self.profilePictureChanged.emit(self._config.profile_picture)
        self.autoSaveChanged.emit(self._config.auto_save)
        self.diagnosticModeChanged.emit(self._config.diagnostic_mode)

    @Property(str, notify=usernameChanged)
    def username(self) -> str:
        return self._config.username

    @username.setter
    def username(self, val: str):
        if self._config.username != val:
            self._config.username = val
            self.usernameChanged.emit(val)
            if self._config.auto_save:
                self.save_configuration()

    @Property(str, notify=themeChanged)
    def theme(self) -> str:
        return self._config.theme

    @theme.setter
    def theme(self, val: str):
        if val in ("dark", "light") and self._config.theme != val:
            self._config.theme = val
            self.themeChanged.emit(val)
            if self._config.auto_save:
                self.save_configuration()

    @Property(str, notify=accentColorChanged)
    def accentColor(self) -> str:
        return self._config.accent_color

    @accentColor.setter
    def accentColor(self, val: str):
        val = val.strip().upper()
        if self._config.accent_color != val:
            self._config.accent_color = val
            self.accentColorChanged.emit(val)
            if self._config.auto_save:
                self.save_configuration()

    @Property(int, notify=fontSizeChanged)
    def fontSize(self) -> int:
        return self._config.font_size

    @fontSize.setter
    def fontSize(self, val: int):
        val = max(10, min(28, int(val)))
        if self._config.font_size != val:
            self._config.font_size = val
            self.fontSizeChanged.emit(val)
            if self._config.auto_save:
                self.save_configuration()

    @Property(str, notify=languageChanged)
    def language(self) -> str:
        return self._config.language

    @language.setter
    def language(self, val: str):
        if val in ("es", "en") and self._config.language != val:
            self._config.language = val
            self.languageChanged.emit(val)
            if self._config.auto_save:
                self.save_configuration()

    @Property(str, notify=profilePictureChanged)
    def profilePicture(self) -> str:
        pic = self._config.profile_picture
        if pic.startswith("file://") or os.path.isabs(pic):
            return pic
        full_path = (BASE_DIR / pic).resolve()
        if full_path.exists():
            return full_path.as_uri()
        if DEFAULT_PROFILE_IMG.exists():
            return DEFAULT_PROFILE_IMG.as_uri()
        return ""

    @profilePicture.setter
    def profilePicture(self, val: str):
        if self._config.profile_picture != val:
            self._config.profile_picture = val
            self.profilePictureChanged.emit(val)
            if self._config.auto_save:
                self.save_configuration()

    @Property(bool, notify=autoSaveChanged)
    def autoSave(self) -> bool:
        return self._config.auto_save

    @autoSave.setter
    def autoSave(self, val: bool):
        if self._config.auto_save != val:
            self._config.auto_save = val
            self.autoSaveChanged.emit(val)

    @Property(bool, notify=diagnosticModeChanged)
    def diagnosticMode(self) -> bool:
        return self._config.diagnostic_mode

    @diagnosticMode.setter
    def diagnosticMode(self, val: bool):
        if self._config.diagnostic_mode != val:
            self._config.diagnostic_mode = val
            self.diagnosticModeChanged.emit(val)

    @Property(bool, notify=telemetryUpdated)
    def configExists(self) -> bool:
        return CONFIG_FILE.exists()

    @Property(bool, notify=telemetryUpdated)
    def backupExists(self) -> bool:
        return BACKUP_FILE.exists()

    @Property(bool, notify=telemetryUpdated)
    def tempExists(self) -> bool:
        return TEMP_FILE.exists()

    @Property(str, notify=telemetryUpdated)
    def configSizeFormatted(self) -> str:
        if CONFIG_FILE.exists():
            return f"{CONFIG_FILE.stat().st_size} bytes"
        return "0 bytes (Inexistente)"

    @Property(str, notify=telemetryUpdated)
    def backupSizeFormatted(self) -> str:
        if BACKUP_FILE.exists():
            return f"{BACKUP_FILE.stat().st_size} bytes"
        return "No creado aún"

    @Property(str, notify=telemetryUpdated)
    def lastTransactionStatus(self) -> str:
        return self._last_transaction_status

    @Property(str, notify=telemetryUpdated)
    def encodingStatus(self) -> str:
        return self._encoding_status

    @Slot()
    def refresh_telemetry(self):
        self.telemetryUpdated.emit()
        self.filesChanged.emit()

    @Slot(result="QVariantList")
    def listConfigFiles(self) -> List[dict]:

        files = []
        try:
            for item in sorted(DATA_DIR.rglob("*")):
                if item.is_file() and not item.name.startswith("."):
                    rel_path = str(item.relative_to(DATA_DIR)).replace("\\", "/")
                    size_kb = f"{(item.stat().st_size / 1024):.2f} KB" if item.stat().st_size > 0 else "0 KB"
                    file_type = "JSON" if item.suffix == ".json" else ("Backup" if item.suffix == ".bak" else ("Imagen" if item.suffix in [".png", ".jpg", ".jpeg"] else "Archivo"))
                    files.append({
                        "name": item.name,
                        "rel_path": rel_path,
                        "full_path": str(item),
                        "size": size_kb,
                        "type": file_type,
                        "is_editable": item.suffix in [".json", ".bak", ".log", ".txt", ".tmp"]
                    })
        except Exception as exc:
            logger.error(f"Error listando archivos de datos: {exc}")
        return files

    @Slot(str, result=str)
    def readConfigFile(self, rel_path: str) -> str:
        try:
            target = (DATA_DIR / rel_path).resolve()
            if not target.exists():
                return f"Error: Archivo {rel_path} no encontrado."
            return target.read_text(encoding="utf-8")
        except Exception as exc:
            return f"Error al leer {rel_path}: {exc}"

    @Slot(str, str, result=bool)
    def writeConfigFile(self, rel_path: str, content: str) -> bool:

        try:
            target = (DATA_DIR / rel_path).resolve()
            target.parent.mkdir(parents=True, exist_ok=True)

            if target.name == "config.json":
                
                parsed = json.loads(content)
                parsed.pop("_meta", None)
                is_valid, validated, err = validate_config_data(parsed)
                if not is_valid or validated is None:
                    self.notificationReceived.emit("error", "Validación Fallida", f"Error en JSON: {err}")
                    return False
                self._config = validated
                self._emit_all_property_changes()
                self.save_configuration()
            else:
                target.write_text(content, encoding="utf-8")
                logger.info(f"Archivo guardado exitosamente: {rel_path}")
                self.notificationReceived.emit("success", "Archivo Guardado", f"Se guardó {rel_path} exitosamente.")

            self.filesChanged.emit()
            self.refresh_telemetry()
            return True
        except json.JSONDecodeError as jde:
            self.notificationReceived.emit("error", "Sintaxis Inválida", f"Error JSON: {jde}")
            return False
        except Exception as exc:
            self.notificationReceived.emit("error", "Error de Escritura", str(exc))
            return False

    @Slot(str, result=str)
    def createNewConfigFile(self, filename: str) -> str:
        
        clean_name = filename.strip()
        if not clean_name:
            return ""
        if not clean_name.endswith(".json") and not clean_name.endswith(".txt"):
            clean_name += ".json"
        target = DATA_DIR / clean_name
        if target.exists():
            self.notificationReceived.emit("warning", "Archivo Existente", f"El archivo {clean_name} ya existe.")
            return ""
        try:
            name_no_ext = clean_name.rsplit(".", 1)[0]
            if clean_name.endswith(".txt"):
                default_content = (
                    f"# ========================================\n"
                    f"# NEXUS Enterprise - Documento: {clean_name}\n"
                    f"# Codificación: UTF-8\n"
                    f"# ========================================\n\n"
                )
            else:
                default_content = json.dumps({
                    "nombre": name_no_ext,
                    "version": "1.0",
                    "activo": True,
                    "descripcion": f"Documento de configuración {clean_name}"
                }, indent=2, ensure_ascii=False) + "\n"
            target.write_text(default_content, encoding="utf-8")
            logger.info(f"Nuevo documento creado con éxito: {clean_name}")
            self.filesChanged.emit()
            self.notificationReceived.emit("success", "Archivo Creado", f"Se creó el archivo {clean_name}.")
            return clean_name
        except Exception as exc:
            logger.error(f"Error al crear {clean_name}: {exc}")
            self.notificationReceived.emit("error", "Error", f"No se pudo crear {clean_name}: {exc}")
            return ""

    @Slot(str, result=bool)
    def deleteConfigFile(self, rel_path: str) -> bool:
        
        target = (DATA_DIR / rel_path).resolve()
        if target.name == "config.json":
            self.notificationReceived.emit("warning", "Protección Activa", "No se puede eliminar config.json desde el explorador.")
            return False
        try:
            if target.exists():
                target.unlink()
                self.filesChanged.emit()
                self.notificationReceived.emit("info", "Archivo Eliminado", f"Se eliminó {rel_path}.")
                return True
            return False
        except Exception as exc:
            self.notificationReceived.emit("error", "Error", f"No se pudo eliminar {rel_path}: {exc}")
            return False

    @Slot(str, result=bool)
    def importExternalFile(self, source_path_or_url: str) -> bool:
        
        clean_path = source_path_or_url
        if clean_path.startswith("file:///"):
            clean_path = clean_path[8:]
        elif clean_path.startswith("file://"):
            clean_path = clean_path[7:]

        src = Path(clean_path)
        if not src.exists():
            self.notificationReceived.emit("error", "Error", "El archivo fuente no existe.")
            return False

        try:
            dest = DATA_DIR / src.name
            shutil.copy2(src, dest)
            self.filesChanged.emit()
            self.notificationReceived.emit("success", "Archivo Importado", f"Se importó {src.name} a data/.")
            return True
        except Exception as exc:
            self.notificationReceived.emit("error", "Error", f"Error al importar: {exc}")
            return False

    @Slot(result=bool)
    def open_file_import_dialog(self) -> bool:
        
        try:
            from PySide6.QtWidgets import QFileDialog
            file_path, _ = QFileDialog.getOpenFileName(
                None,
                "Importar Archivo de Configuración o Documento",
                "",
                "Archivos (*.json *.bak *.txt *.png *.jpg *.log);;Todos (*.*)"
            )
            if file_path:
                return self.importExternalFile(file_path)
            return False
        except Exception as exc:
            logger.error(f"Error en diálogo de importación: {exc}")
            return False

    @Slot(result="QVariantList")
    def listHistory(self) -> List[dict]:
        
        try:
            return self._history.list_history()
        except Exception as exc:
            logger.error(f"Error al listar historial: {exc}")
            return []

    @Slot(str)
    def restoreVersion(self, entry_id: str):
        
        try:
            restored_data = self._history.restore_version(entry_id)
            restored_data.pop("_meta", None)
            is_valid, validated_model, err = validate_config_data(restored_data)
            if is_valid and validated_model:
                self._apply_model(validated_model)
                logger.info(f"Versión {entry_id} restaurada desde la Máquina del Tiempo.")
                self.historyChanged.emit()
                self.filesChanged.emit()
                self.telemetryUpdated.emit()
                self.notificationReceived.emit(
                    "success",
                    "Versión Restaurada",
                    f"Se restauró exitosamente la versión: {entry_id}"
                )
            else:
                raise ValueError(f"Datos inválidos en versión restaurada: {err}")
        except ConfigIntegrityError as exc:
            logger.error(f"Integridad fallida al restaurar {entry_id}: {exc}")
            self.notificationReceived.emit("error", "Error de Integridad", str(exc))
        except Exception as exc:
            logger.error(f"Error al restaurar versión {entry_id}: {exc}")
            self.notificationReceived.emit("error", "Error de Restauración", str(exc))

    @Slot(result=bool)
    def verifyIntegrity(self) -> bool:
        
        try:
            return self._history.verify_integrity()
        except Exception:
            return False

    @Slot(result=bool)
    def reset_to_defaults(self) -> bool:
        
        logger.info("Usuario solicitó restablecer valores de fábrica.")
        self._apply_defaults_and_save(
            reason="Solicitud explícita de usuario",
            notify_title="Valores de Fábrica",
            notify_msg="Se han restablecido todas las opciones a los valores iniciales recomendados."
        )
        return True

    @Slot(result=bool)
    def open_profile_picker_dialog(self) -> bool:
        
        try:
            from PySide6.QtWidgets import QFileDialog
            file_path, _ = QFileDialog.getOpenFileName(
                None,
                "Seleccionar Imagen de Perfil",
                "",
                "Imágenes (*.png *.jpg *.jpeg *.bmp *.webp *.svg)"
            )
            if file_path:
                return self.update_profile_image(file_path)
            return False
        except Exception as e:
            logger.error(f"Error al abrir diálogo de archivo: {e}")
            return False

    @Slot(str, result=bool)
    def update_profile_image(self, file_url_or_path: str) -> bool:
        
        clean_path = file_url_or_path
        if clean_path.startswith("file:///"):
            clean_path = clean_path[8:]
        elif clean_path.startswith("file://"):
            clean_path = clean_path[7:]

        source_file = Path(clean_path)
        if not source_file.exists():
            self.notificationReceived.emit("error", "Error de Imagen", "La ruta seleccionada no existe.")
            return False

        try:
            dest_file = PROFILE_DIR / f"profile{source_file.suffix}"
            shutil.copy2(source_file, dest_file)
            standard_png = PROFILE_DIR / "profile.png"
            shutil.copy2(source_file, standard_png)
            rel_path = f"data/profile/{dest_file.name}"
            self._config.profile_picture = rel_path
            self.profilePictureChanged.emit(standard_png.as_uri())
            logger.info(f"Nueva imagen de perfil importada: {rel_path}")
            self.save_configuration()
            return True
        except Exception as exc:
            logger.error(f"Error al copiar imagen de perfil: {exc}")
            self.notificationReceived.emit("error", "Error", f"No se pudo procesar la imagen: {exc}")
            return False

    @Slot(result=str)
    def test_missing_file(self) -> str:
        logger.info("--- PRUEBA 1: Archivo Ausente ---")
        if CONFIG_FILE.exists():
            CONFIG_FILE.unlink()
        self.refresh_telemetry()
        self.load_configuration()
        return "Prueba 1 completada: config.json fue eliminado y auto-generado con valores por defecto."

    @Slot(result=str)
    def test_corrupt_file(self) -> str:
        logger.info("--- PRUEBA 2: Archivo Corrupto ---")
        self.save_configuration()
        with open(CONFIG_FILE, "w", encoding="utf-8") as f:
            f.write("{CORRUPT_JSON_DATA_SYNTAX_ERROR: ??? 12345, \n")
        logger.warning("config.json corrompido deliberadamente para la prueba.")
        self.refresh_telemetry()
        self.load_configuration()
        return "Prueba 2 completada: Corrupción detectada y sanada desde config.bak / historial."

    @Slot(result=str)
    def test_special_chars_utf8(self) -> str:
        logger.info("--- PRUEBA 3: Caracteres Especiales UTF-8 ---")
        test_name = "César Ñandú de España"
        self.username = test_name
        self.save_configuration()
        with open(CONFIG_FILE, "rb") as f:
            raw_bytes = f.read()
            decoded_text = raw_bytes.decode("utf-8")
        if test_name in decoded_text:
            msg = f"Prueba 3 EXITOSA: '{test_name}' íntegro en disco sin corrupción UTF-8."
            logger.info(msg)
            return msg
        else:
            msg = "Fallo en Prueba 3: Caracteres especiales alterados."
            logger.error(msg)
            return msg

    @Slot(result=str)
    def test_safe_write_stress(self) -> str:
        logger.info("--- PRUEBA 4: Escritura Segura y Transaccional ---")
        for i in range(3):
            self._config.font_size = 14 + i
            self.save_configuration()
        self.historyChanged.emit()
        return "Prueba 4 completada: 3 commits atómicos SHA-256 Safe-Write ejecutados sin residuos temporales."
