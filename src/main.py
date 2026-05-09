from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from backend.backend import Backend
import sys
import os

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()

backend = Backend()
engine.rootContext().setContextProperty("backend", backend)

qml_path = os.path.join(os.path.dirname(__file__), "ui", "Main.qml")
engine.load(qml_path)

sys.exit(app.exec())
