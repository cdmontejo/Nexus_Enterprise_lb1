"""
NEXUS Enterprise v3.1 - Main Entry Point
=========================================
Puente entre Python (ViewModel/Backend) y QML (Vista/Frontend).
v3.1 — Agrega registro del Singleton Theme y ConfigHistoryManager.
"""

import os
import sys

# Ensure working directory is project root
os.chdir(os.path.dirname(os.path.abspath(__file__)))

from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterSingletonType
from PySide6.QtCore import QUrl
from PySide6.QtWidgets import QApplication
from PySide6.QtQuickControls2 import QQuickStyle

from app.logger import logger, log_emitter
from app.config_manager import ConfigManager
from app.ai_agent import AIAgent


def main():
    QQuickStyle.setStyle("Basic")
    app = QApplication(sys.argv)
    app.setApplicationName("NEXUS Enterprise")
    app.setApplicationVersion("3.1.0")
    app.setOrganizationName("NEXUS Enterprise Lab")

    icon_path = os.path.join("ui", "assets", "logo_nexus.jpg")
    if os.path.exists(icon_path):
        app.setWindowIcon(QIcon(icon_path))

    logger.info("Aplicación NEXUS Enterprise v3.1 iniciada correctamente.")

    config_manager = ConfigManager()
    ai_agent = AIAgent(config_manager=config_manager)

    engine = QQmlApplicationEngine()

    ui_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ui")
    engine.addImportPath(ui_dir)

    ctx = engine.rootContext()
    ctx.setContextProperty("configManager", config_manager)
    ctx.setContextProperty("aiAgent", ai_agent)
    ctx.setContextProperty("logEmitter", log_emitter)

    # Load QML root file
    qml_file = QUrl.fromLocalFile(os.path.join(ui_dir, "main.qml"))
    engine.load(qml_file)

    if not engine.rootObjects():
        logger.critical("Error crítico: No se pudo cargar la interfaz QML. Abortando.")
        sys.exit(-1)

    logger.info("Interfaz QML v3.1 cargada exitosamente. Motor de renderizado activo.")

    exit_code = app.exec()
    logger.info(f"NEXUS Enterprise finalizado con código: {exit_code}")
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
