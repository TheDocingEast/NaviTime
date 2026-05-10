import sys
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

print("Starting...")

from backend.backend import Backend
print("Backend imported")

app = QGuiApplication(sys.argv)
print("App created")

engine = QQmlApplicationEngine()
print("Engine created")

try:
    backend = Backend()
    print("Backend created")
except Exception as e:
    print(f"Backend error: {e}")
    backend = None

if backend:
    engine.rootContext().setContextProperty("backend", backend)

qml_path = os.path.join(os.path.dirname(__file__), "ui", "Main.qml")
print(f"Loading QML: {qml_path}")
print(f"File exists: {os.path.exists(qml_path)}")
engine.load(qml_path)

root_objects = engine.rootObjects()
print(f"Root objects: {root_objects}")

if not root_objects:
    print("QML failed to load completely")
sys.exit(app.exec())
