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
