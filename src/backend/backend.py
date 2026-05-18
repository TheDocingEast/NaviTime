from PySide6.QtCore import QObject, Slot, Signal, Property
from sql.db_client import DBClient


class Backend(QObject):
    tasksChanged        = Signal()
    usersChanged        = Signal()
    workspacesChanged   = Signal()
    statusesChanged     = Signal()
    selectedTaskChanged = Signal()
    commentsChanged     = Signal()
    hotTaskChanged      = Signal()
    userInfoChanged     = Signal()
    workspaceUsersChanged = Signal()
    workspaceFilterChanged = Signal()

    def __init__(self):
        super().__init__()
        self.db = DBClient()
        self._tasks                  = []
        self._users                  = []
        self._workspaces             = []
        self._statuses               = []
        self._workspace_users = []
        self._workspace_filter_id = -1
        self._selected_task          = None
        self._selected_task_comments = []
        self._hot_task               = None
        self._current_user           = None
        self._current_user_id        = None
        self._current_role           = None
        self._current_workspace_id   = None
        self._current_workspace_name = None

    # ── Auth ─────────────────────────────────────────────────
    @Slot(str, str, result=str)
    def login(self, username, password):
        import bcrypt
        user = self.db.get_user_by_username(username)
        if user is None:
            return "error"
        try:
            if not bcrypt.checkpw(password.encode(), user["password"].encode()):
                return "error"
        except Exception:
            if user["password"] != password:
                return "error"

        self._current_user           = user["username"]
        self._current_user_id        = user["user_id"]
        self._current_role           = user["role"]
        self._current_workspace_id   = user.get("workspace_id")

        if user.get("workspace_id"):
            ws = self.db.get_workspace_by_id(user["workspace_id"])
            self._current_workspace_name = ws["name"] if ws else ""
        else:
            self._current_workspace_name = "All"

        self.userInfoChanged.emit()

        if user["role"] == "admin":
            return "admin"
        return "board"

    # ── Current user props ───────────────────────────────────
    @Property(str, notify=userInfoChanged)
    def currentUser(self):
        return self._current_user or ""

    @Property(int, notify=userInfoChanged)
    def currentUserId(self):
        return self._current_user_id or 0

    @Property(str, notify=userInfoChanged)
    def currentRole(self):
        return self._current_role or ""

    @Property(int, notify=userInfoChanged)
    def currentWorkspaceId(self):
        return self._current_workspace_id or 0

    @Property(str, notify=userInfoChanged)
    def currentWorkspaceName(self):
        return self._current_workspace_name or ""

    # ── Tasks ────────────────────────────────────────────────
    @Slot(int)
    def load_tasks(self, workspace_id):
        if self._current_role == "manager":
            self._reload_tasks_for_manager()
            # hot task тоже по всем — берём ближайший дедлайн глобально
            hot = self.db.get_hot_task_global()
        else:
            rows = self.db.get_tasks(workspace_id)
            self._tasks = [dict(t) for t in rows]
            for t in self._tasks:
                if t.get("deadline"):
                    t["deadline"] = str(t["deadline"])[:10]
            hot = self.db.get_hot_task(workspace_id)

        self._hot_task = dict(hot) if hot else None
        self.tasksChanged.emit()
        self.hotTaskChanged.emit()

    @Property(list, notify=tasksChanged)
    def tasks(self):
        return self._tasks

    @Property("QVariant", notify=hotTaskChanged)
    def hotTask(self):
        return self._hot_task

    @Slot(int)
    def load_workspace_users(self, workspace_id):
        self._workspace_users = [dict(u) for u in self.db.get_users_by_workspace(workspace_id)]
        self.workspaceUsersChanged.emit()

    @Property(list, notify=workspaceUsersChanged)
    def workspaceUsers(self):
        return self._workspace_users

    @Slot(str, str, int, int, int, str, int)
    def create_task(self, title, description, workspace_id, status_id, priority, deadline, assignee_id):
        self.db.create_task(
            title, description, workspace_id, status_id,
            assignee_id if assignee_id > 0 else self._current_user_id,
            self._current_user_id,
            priority,
            deadline if deadline and deadline.replace("-", "").strip() else None
        )
        self.load_tasks(workspace_id)

    @Slot(int, int)
    def update_task_status(self, task_id, status_id):
        self.db.update_task_status(task_id, status_id)
        self.load_tasks(self._current_workspace_id)

    @Slot(int, int)
    def update_task_priority(self, task_id, priority):
        self.db.update_task_priority(task_id, priority)
        self.load_tasks(self._current_workspace_id)

    @Slot(int)
    def soft_delete_task(self, task_id):
        self.db.soft_delete_task(task_id)
        self.load_tasks(self._current_workspace_id)

    # ── Selected task ────────────────────────────────────────
    @Slot(int)
    def selectTask(self, task_id):
        task = self.db.get_task_by_id(task_id)
        self._selected_task = dict(task) if task else None
        if self._selected_task and self._selected_task.get("deadline"):
            self._selected_task["deadline"] = str(self._selected_task["deadline"])[:10]
        self._selected_task_comments = [dict(c) for c in self.db.get_comments(task_id)]
        self.selectedTaskChanged.emit()
        self.commentsChanged.emit()

    @Property("QVariant", notify=selectedTaskChanged)
    def selectedTask(self):
        return self._selected_task

    @Property(list, notify=commentsChanged)
    def selectedTaskComments(self):
        return self._selected_task_comments

    # ── Comments ─────────────────────────────────────────────
    @Slot(int, str)
    def add_comment(self, task_id, body):
        self.db.add_comment(task_id, self._current_user_id, body)
        self.selectTask(task_id)

    # ── Statuses ─────────────────────────────────────────────
    @Slot(int)
    def load_statuses(self, workspace_id):
        self._statuses = [dict(s) for s in self.db.get_statuses(workspace_id)]
        self.statusesChanged.emit()

    @Property(list, notify=statusesChanged)
    def statuses(self):
        return self._statuses

    @Slot(int, str, str)
    def create_status(self, workspace_id, name, color):
        self.db.create_status(workspace_id, name, color)
        self.load_statuses(workspace_id)

    @Slot(int, int)
    def delete_status(self, status_id, workspace_id):
        self.db.delete_status(status_id)
        self.load_statuses(workspace_id)

    # ── Users ────────────────────────────────────────────────
    @Slot()
    def load_users(self):
        self._users = [dict(u) for u in self.db.get_all_users()]
        self.usersChanged.emit()

    @Property(list, notify=usersChanged)
    def users(self):
        return self._users

    @Slot(str, str, str, str, "QVariant")
    def create_user(self, username, full_name, password, role, workspace_id):
        import bcrypt
        hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
        self.db.create_user(username, full_name, hashed, role,
                            int(workspace_id) if workspace_id else None)
        self.load_users()

    @Slot(int, bool)
    def toggle_user_active(self, user_id, is_active):
        self.db.set_user_active(user_id, is_active)
        self.load_users()

    # ── Workspaces ───────────────────────────────────────────
    @Slot()
    def load_workspaces(self):
        self._workspaces = [dict(w) for w in self.db.get_workspaces()]
        for w in self._workspaces:
            if w.get("created_at"):
                w["created_at"] = str(w["created_at"])[:10]
        self.workspacesChanged.emit()

    @Property(list, notify=workspacesChanged)
    def workspaces(self):
        return self._workspaces

    @Slot(str)
    def create_workspace(self, name):
        self.db.create_workspace(name)
        self.load_workspaces()

    @Slot(int)
    def delete_workspace(self, workspace_id):
        self.db.delete_workspace(workspace_id)
        self.load_workspaces()

    @Property(int, notify=workspaceFilterChanged)
    def workspaceFilterId(self):
        return self._workspace_filter_id

    @Slot(int)
    def setWorkspaceFilter(self, workspace_id):
        self._workspace_filter_id = workspace_id
        self.workspaceFilterChanged.emit()
        self._reload_tasks_for_manager()
        # Перегружаем статусы под выбранный воркспейс
        if workspace_id != -1:
            self.load_statuses(workspace_id)

    def _reload_tasks_for_manager(self):
        if self._workspace_filter_id == -1:
            rows = self.db.get_all_tasks()
        else:
            rows = self.db.get_tasks_by_workspace(self._workspace_filter_id)
        self._tasks = [dict(t) for t in rows]
        for t in self._tasks:
            if t.get("deadline"):
                t["deadline"] = str(t["deadline"])[:10]
        self.tasksChanged.emit()

    def close(self):
        self.db.close()
