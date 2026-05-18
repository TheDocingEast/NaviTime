import sys
import os
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl, QFileSystemWatcher, QTimer

# ── Пути ──────────────────────────────────────────────────────────────────────
if hasattr(sys, 'frozen') or '__compiled__' in dir():
    BASE_DIR = Path(sys.executable).parent
else:
    BASE_DIR = Path(__file__).parent

UI_DIR  = BASE_DIR / "ui"
QML_MAIN = UI_DIR / "Main.qml"

# ── Hot reload ─────────────────────────────────────────────────────────────────
class HotReloader:
    def __init__(self, engine: QQmlApplicationEngine):
        self.engine = engine
        self.watcher = QFileSystemWatcher()

        for f in UI_DIR.glob("*.qml"):
            self.watcher.addPath(str(f))
        self.watcher.fileChanged.connect(self._on_changed)

        self._timer = QTimer()
        self._timer.setSingleShot(True)
        self._timer.setInterval(200)
        self._timer.timeout.connect(self._reload)

    def _on_changed(self, path: str):
        self.watcher.addPath(path)   # vim/PyCharm пересоздают файл — переподписываемся
        print(f"[reload] {Path(path).name}")
        self._timer.start()

    def _reload(self):
        self.engine.clearComponentCache()
        for obj in self.engine.rootObjects():
            obj.deleteLater()
        self.engine.load(QUrl.fromLocalFile(str(QML_MAIN)))

# ── Приложение ─────────────────────────────────────────────────────────────────
print(f"BASE_DIR : {BASE_DIR}")
print(f"QML_MAIN : {QML_MAIN}")
print(f"QML exists: {QML_MAIN.exists()}")

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()

# Backend
try:
    from backend.backend import Backend
    backend = Backend()
    engine.rootContext().setContextProperty("backend", backend)
    print("Backend OK")
except Exception as e:
    print(f"Backend error: {e}")

# Загрузка QML — обязательно через QUrl, иначе сломаются относительные импорты
engine.load(QUrl.fromLocalFile(str(QML_MAIN)))

if not engine.rootObjects():
    print("QML failed to load")
    sys.exit(1)

# Hot reload только в dev-режиме
_reloader = HotReloader(engine) if os.getenv("DEV") else None

sys.exit(app.exec())
