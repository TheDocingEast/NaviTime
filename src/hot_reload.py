# hot_reload.py  (кладём рядом с main.py)
import sys
import os
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QFileSystemWatcher, QTimer, QUrl

UI_DIR = Path(__file__).parent / "ui"
MAIN_QML = UI_DIR / "Main.qml"


class HotReloader:
    def __init__(self, engine: QQmlApplicationEngine):
        self.engine = engine

        self.watcher = QFileSystemWatcher()
        # Добавляем все .qml файлы из папки ui/
        for qml_file in UI_DIR.glob("*.qml"):
            self.watcher.addPath(str(qml_file))

        self.watcher.fileChanged.connect(self._on_file_changed)

        # Дебаунс: некоторые редакторы делают несколько записей подряд
        self._timer = QTimer()
        self._timer.setSingleShot(True)
        self._timer.setInterval(200)
        self._timer.timeout.connect(self._reload)

    def _on_file_changed(self, path: str):
        # Редакторы вроде vim/PyCharm удаляют и создают файл заново —
        # нужно переподписаться
        self.watcher.addPath(path)
        print(f"[hot reload] изменился: {Path(path).name}")
        self._timer.start()

    def _reload(self):
        self.engine.clearComponentCache()
        # Удаляем старые окна
        for obj in self.engine.rootObjects():
            obj.deleteLater()
        # Загружаем заново
        self.engine.load(QUrl.fromLocalFile(str(MAIN_QML)))
        print("[hot reload] перезагружено")
