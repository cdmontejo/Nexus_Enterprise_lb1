from __future__ import annotations

import hashlib
import json
import logging
import shutil
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any, Optional


META_KEY = "_meta"
INTEGRITY_FIELD = "integrity_sha256"
SAVED_AT_FIELD = "saved_at"


class ConfigIntegrityError(Exception):
    """Se lanza cuando config.json y TODAS las copias de seguridad
    (config.bak + historial/) están corruptas, alteradas, o ausentes.
    No hay nada seguro que restaurar automáticamente."""


@dataclass
class HistoryEntry:
    entry_id: str          
    saved_at: str           
    size_bytes: int

    def as_dict(self) -> dict:
        return {
            "entry_id": self.entry_id,
            "saved_at": self.saved_at,
            "size_bytes": self.size_bytes,
        }


class ConfigHistoryManager:
    def __init__(
        self,
        data_dir: Path,
        filename: str = "config.json",
        history_dirname: str = "historial",
        max_history: int = 5,
        logger: Optional[logging.Logger] = None,
    ) -> None:
        self.data_dir = Path(data_dir)
        self.config_path = self.data_dir / filename
        self.tmp_path = self.data_dir / (filename + ".tmp")
        self.bak_path = self.data_dir / (filename.rsplit(".", 1)[0] + ".bak")
        self.history_dir = self.data_dir / history_dirname
        self.max_history = max_history
        self.log = logger or logging.getLogger("nexus.history")

        self.data_dir.mkdir(parents=True, exist_ok=True)
        self.history_dir.mkdir(parents=True, exist_ok=True)

    def save(self, data: dict[str, Any]) -> Path:
        clean = self._strip_meta(data)

        if self.config_path.exists():
            self._backup_current()

        payload = dict(clean)
        payload[META_KEY] = {
            INTEGRITY_FIELD: self._checksum(clean),
            SAVED_AT_FIELD: datetime.now().isoformat(timespec="seconds"),
        }
        self._commit(payload)
        self.log.info(
            "Commit atómico completado: %s actualizado con sello de integridad.",
            self.config_path.name,
        )
        return self.config_path

    def load(self) -> dict[str, Any]:
        if not self.config_path.exists():
            raise FileNotFoundError(str(self.config_path))

        raw = self.config_path.read_text(encoding="utf-8")

        try:
            data = json.loads(raw)
        except json.JSONDecodeError:
            self.log.error(
                "config.json corrupto (JSONDecodeError). Buscando copia de seguridad válida."
            )
            return self._restore_from_backups(reason="corrupt")

        meta = data.pop(META_KEY, None)
        if meta is None:
            self.log.warning(
                "config.json no tiene sello de integridad (_meta). Se acepta tal cual."
            )
            return data

        expected = meta.get(INTEGRITY_FIELD)
        actual = self._checksum(data)
        if expected != actual:
            self.log.error(
                "Alerta de seguridad: el archivo de configuracion fue alterado "
                "externamente (hash esperado %s, obtenido %s). Restaurando copia "
                "de seguridad certificada.",
                expected,
                actual,
            )
            return self._restore_from_backups(reason="tamper")

        return data

    def list_history(self) -> list[dict]:
        entries = []
        for path in self._history_files():
            entries.append(
                HistoryEntry(
                    entry_id=path.name,
                    saved_at=self._timestamp_from_filename(path.name),
                    size_bytes=path.stat().st_size,
                ).as_dict()
            )
        return entries

    def restore_version(self, entry_id: str) -> dict[str, Any]:
        candidate = self.history_dir / entry_id
        if not candidate.exists() or candidate.parent != self.history_dir:
            raise ConfigIntegrityError(f"Version de historial no encontrada: {entry_id}")

        try:
            historical = json.loads(candidate.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            raise ConfigIntegrityError(
                f"La version de historial {entry_id} esta corrupta y no se puede restaurar."
            ) from exc

        meta = historical.pop(META_KEY, None)
        if meta is not None:
            expected = meta.get(INTEGRITY_FIELD)
            actual = self._checksum(historical)
            if expected != actual:
                raise ConfigIntegrityError(
                    f"La version de historial {entry_id} no paso la verificacion de "
                    "integridad; no se restaura para evitar reintroducir datos alterados."
                )

        if self.config_path.exists():
            self._backup_current(label="antes de restaurar")

        payload = dict(historical)
        payload[META_KEY] = {
            INTEGRITY_FIELD: self._checksum(historical),
            SAVED_AT_FIELD: datetime.now().isoformat(timespec="seconds"),
        }
        self._commit(payload)
        self.log.info("Configuracion restaurada desde historial: %s", entry_id)
        return historical

    def verify_integrity(self) -> bool:

        if not self.config_path.exists():
            return False
        try:
            data = json.loads(self.config_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            return False
        meta = data.pop(META_KEY, None)
        if meta is None:
            return True
        return meta.get(INTEGRITY_FIELD) == self._checksum(data)

    @staticmethod
    def _strip_meta(data: dict) -> dict:
        return {k: v for k, v in data.items() if k != META_KEY}

    @staticmethod
    def _checksum(data: dict) -> str:
        canonical = json.dumps(data, sort_keys=True, ensure_ascii=False, separators=(",", ":"))
        return hashlib.sha256(canonical.encode("utf-8")).hexdigest()

    def _commit(self, payload: dict) -> None:

        self.tmp_path.write_text(
            json.dumps(payload, indent=2, ensure_ascii=False, sort_keys=True),
            encoding="utf-8",
        )
        self.tmp_path.replace(self.config_path)  

    def _backup_current(self, label: str = "") -> None:
        try:
            json.loads(self.config_path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            self.log.warning("config.json actual no es válido; se omite el respaldo preventivo.")
            return

        shutil.copy2(self.config_path, self.bak_path)
        self.log.info("Backup creado exitosamente en %s.", self.bak_path.name)

        stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        dest = self.history_dir / f"config_{stamp}.bak"
        counter = 1
        while dest.exists():
            dest = self.history_dir / f"config_{stamp}_{counter}.bak"
            counter += 1
        shutil.copy2(self.config_path, dest)
        self.log.info(
            "Version %sagregada a la Maquina del Tiempo: %s",
            f"({label}) " if label else "",
            dest.name,
        )
        self._prune_history()

    def _prune_history(self) -> None:
        files = self._history_files()
        for stale in files[self.max_history:]:
            stale.unlink(missing_ok=True)
            self.log.info("Version antigua purgada del historial: %s", stale.name)

    def _history_files(self) -> list[Path]:
        return sorted(
            self.history_dir.glob("config_*.bak"),
            key=lambda p: p.stat().st_mtime,
            reverse=True,
        )

    def _timestamp_from_filename(self, filename: str) -> str:
        try:
            core = filename.removeprefix("config_").removesuffix(".bak").split("_")
            stamp = "_".join(core[:2])
            return datetime.strptime(stamp, "%Y%m%d_%H%M%S").isoformat(timespec="seconds")
        except (ValueError, IndexError):
            return ""

    def _restore_from_backups(self, reason: str) -> dict[str, Any]:
        candidates = []
        if self.bak_path.exists():
            candidates.append(self.bak_path)
        candidates.extend(self._history_files())

        for candidate in candidates:
            try:
                data = json.loads(candidate.read_text(encoding="utf-8"))
            except json.JSONDecodeError:
                continue

            meta = data.pop(META_KEY, None)
            if meta is not None:
                if meta.get(INTEGRITY_FIELD) != self._checksum(data):
                    continue  

            payload = dict(data)
            payload[META_KEY] = {
                INTEGRITY_FIELD: self._checksum(data),
                SAVED_AT_FIELD: datetime.now().isoformat(timespec="seconds"),
            }
            self._commit(payload)
            self.log.info(
                "Restauracion automatica (%s) completada usando: %s",
                reason,
                candidate.name,
            )
            return data

        self.log.critical(
            "No se encontro ninguna copia de seguridad valida (%s). "
            "Se requiere intervencion manual o valores por defecto.",
            reason,
        )
        raise ConfigIntegrityError("config.json y todas sus copias de seguridad estan corruptas o alteradas.")

