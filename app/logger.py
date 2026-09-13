import os
import sys
import logging
from datetime import datetime
from collections import deque
from PySide6.QtCore import QObject, Signal

# Directory setup
LOGS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "logs")
os.makedirs(LOGS_DIR, exist_ok=True)
LOG_FILE_PATH = os.path.join(LOGS_DIR, "app.log")


class LogEmitter(QObject):
    new_log = Signal(str)


log_emitter = LogEmitter()


class QtLogHandler(logging.Handler):
    def __init__(self, emitter: LogEmitter, max_history: int = 500):
        super().__init__()
        self.emitter = emitter
        self.history = deque(maxlen=max_history)

    def emit(self, record):
        try:
            msg = self.format(record)
            self.history.append(msg)
            self.emitter.new_log.emit(msg)
        except RuntimeError:
            pass
        except Exception:
            self.handleError(record)


logger = logging.getLogger("NEXUS")
logger.setLevel(logging.DEBUG)

if not logger.handlers:

    formatter = logging.Formatter(
        "[%(asctime)s] %(levelname)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )

    file_handler = logging.FileHandler(LOG_FILE_PATH, mode="a", encoding="utf-8")
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)

    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

    qt_handler = QtLogHandler(log_emitter)
    qt_handler.setLevel(logging.DEBUG)
    qt_handler.setFormatter(formatter)
    logger.addHandler(qt_handler)


def get_log_history() -> list[str]:
    for h in logger.handlers:
        if isinstance(h, QtLogHandler):
            return list(h.history)
    
    if os.path.exists(LOG_FILE_PATH):
        try:
            with open(LOG_FILE_PATH, "r", encoding="utf-8") as f:
                return f.readlines()[-200:]
        except Exception:
            return []
    return []
