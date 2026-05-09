from PySide6.QtCore import QObject, Slot, Signal, Property
from sql.db_client import DBClient

class Backend(QObject):
    tasksChanged = Signal()

    def __init__(self):
        super().__init__()
        self.db = DBClient(
            dbname="navitime",
            user="navitime",
            password="ghio#21d",
            host="85.209.135.157"
        )
        self._tasks = []

    @Slot(str, str, result=bool)
    def login(self, username, password):
        user = self.db.get_user(username, password)
        return user is not None

    @Slot(int)
    def load_tasks(self, workspace_id):
        self._tasks = self.db.get_tasks(workspace_id)
        self.tasksChanged.emit()

    @Property(list, notify=tasksChanged)
    def tasks(self):
        return [dict(t) for t in self._tasks]
