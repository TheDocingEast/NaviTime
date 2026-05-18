import psycopg2
from psycopg2.extras import RealDictCursor



class DBClient:
    def __init__(
        self,
        dbname: str,
        host: str,
        user: str = "postgres",
        password: str | None = None,
    ) -> None:
        self.dbname = dbname
        self.host = host
        self.user = user
        self.password = password

        self.connection = psycopg2.connect(f"dbname={self.dbname} user={self.user} password={self.password} host={self.host}")
        self.connection.autocommit = False

    # ── Workspaces ───────────────────────────────────────────
    def get_workspaces(self):
        return self._fetch("SELECT * FROM workspaces ORDER BY workspace_id")

    def get_workspace_by_id(self, workspace_id):
        return self._fetch_one(
            "SELECT * FROM workspaces WHERE workspace_id = %s", (workspace_id,))

    def create_workspace(self, name):
        self._execute("INSERT INTO workspaces (name) VALUES (%s)", (name,))

    def delete_workspace(self, workspace_id):
        self._execute("DELETE FROM workspaces WHERE workspace_id = %s", (workspace_id,))

    # ── Users ────────────────────────────────────────────────
    def get_user_by_username(self, username):
        return self._fetch_one(
            "SELECT * FROM users WHERE username = %s AND is_active = TRUE", (username,))

    def get_all_users(self):
        return self._fetch("""
            SELECT u.*, w.name AS workspace_name
            FROM users u
            LEFT JOIN workspaces w ON u.workspace_id = w.workspace_id
            ORDER BY u.user_id
        """)

    def get_users_by_workspace(self, workspace_id):
        return self._fetch(
            "SELECT * FROM users WHERE workspace_id = %s AND is_active = TRUE",
            (workspace_id,))

    def create_user(self, username, full_name, password, role, workspace_id=None):
        self._execute(
            "INSERT INTO users (username, full_name, password, role, workspace_id) "
            "VALUES (%s, %s, %s, %s, %s)",
            (username, full_name, password, role, workspace_id)
        )

    def set_user_active(self, user_id, is_active):
        self._execute(
            "UPDATE users SET is_active = %s WHERE user_id = %s", (is_active, user_id))

    # ── Statuses ─────────────────────────────────────────────
    def get_statuses(self, workspace_id):
        if workspace_id and workspace_id > 0:
            return self._fetch(
                "SELECT * FROM statuses WHERE workspace_id = %s ORDER BY position ASC",
                (workspace_id,))
        return self._fetch("SELECT * FROM statuses ORDER BY workspace_id, position ASC")

    def create_status(self, workspace_id, name, color):
        result = self._fetch_one(
            "SELECT COALESCE(MAX(position), 0) + 1 AS next_pos "
            "FROM statuses WHERE workspace_id = %s",
            (workspace_id,)
        )
        self._execute(
            "INSERT INTO statuses (workspace_id, name, position, color) VALUES (%s, %s, %s, %s)",
            (workspace_id, name, result["next_pos"], color)
        )

    def delete_status(self, status_id):
        self._execute("DELETE FROM statuses WHERE status_id = %s", (status_id,))

    # ── Tasks ────────────────────────────────────────────────
    def get_tasks(self, workspace_id):
        return self._fetch("""
            SELECT t.*, u.username AS assignee_name, w.name AS workspace_name
            FROM tasks t
            LEFT JOIN users u ON t.assignee_id = u.user_id
            LEFT JOIN workspaces w ON t.workspace_id = w.workspace_id
            WHERE t.workspace_id = %s AND t.is_deleted = FALSE
            ORDER BY t.priority DESC, t.created_at ASC
        """, (workspace_id,))

    def get_task_by_id(self, task_id):
        return self._fetch_one("""
            SELECT t.*, u.username AS assignee_name
            FROM tasks t
            LEFT JOIN users u ON t.assignee_id = u.user_id
            WHERE t.task_id = %s
        """, (task_id,))

    def get_hot_task_global(self):
        return self._fetch_one("""
            SELECT t.*, w.name AS workspace_name
            FROM tasks t
            LEFT JOIN workspaces w ON t.workspace_id = w.workspace_id
            WHERE t.deadline IS NOT NULL AND t.is_deleted = FALSE
            ORDER BY t.deadline ASC LIMIT 1
        """)

    def create_task(self, title, description, workspace_id, status_id, assignee_id,
                    creator_id, priority, deadline):
        self._execute("""
            INSERT INTO tasks
                (title, description, workspace_id, status_id, assignee_id, creator_id, priority, deadline)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (title, description, workspace_id, status_id, assignee_id, creator_id, priority, deadline))

    def update_task_status(self, task_id, status_id):
        self._execute(
            "UPDATE tasks SET status_id = %s WHERE task_id = %s", (status_id, task_id))

    def update_task_priority(self, task_id, priority):
        self._execute(
            "UPDATE tasks SET priority = %s WHERE task_id = %s", (priority, task_id))

    def soft_delete_task(self, task_id):
        self._execute(
            "UPDATE tasks SET is_deleted = TRUE WHERE task_id = %s", (task_id,))

    def get_all_tasks(self):
        return self._fetch("""
            SELECT t.*, u.username AS assignee_name, w.name AS workspace_name
            FROM tasks t
            LEFT JOIN users u ON t.assignee_id = u.user_id
            LEFT JOIN workspaces w ON t.workspace_id = w.workspace_id
            WHERE t.is_deleted = FALSE
            ORDER BY t.priority DESC, t.created_at ASC
        """)

    def get_tasks_by_workspace(self, workspace_id):
        """Фильтр по конкретному отделу — для менеджера"""
        return self._fetch("""
            SELECT t.*, u.username AS assignee_name, w.name AS workspace_name
            FROM tasks t
            LEFT JOIN users u ON t.assignee_id = u.user_id
            LEFT JOIN workspaces w ON t.workspace_id = w.workspace_id
            WHERE t.workspace_id = %s AND t.is_deleted = FALSE
            ORDER BY t.priority DESC, t.created_at ASC
        """, (workspace_id,))

    # ── Comments ─────────────────────────────────────────────
    def get_comments(self, task_id):
        return self._fetch("""
            SELECT c.*, u.username AS author_name
            FROM comments c
            JOIN users u ON c.author_id = u.user_id
            WHERE c.task_id = %s ORDER BY c.created_at ASC
        """, (task_id,))

    def add_comment(self, task_id, author_id, body):
        self._execute(
            "INSERT INTO comments (task_id, author_id, body) VALUES (%s, %s, %s)",
            (task_id, author_id, body)
        )

    # ── Helpers ──────────────────────────────────────────────
    def _fetch(self, query, params=None):
        with self.connection.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(query, params)
            return cur.fetchall()

    def _fetch_one(self, query, params=None):
        with self.connection.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(query, params)
            return cur.fetchone()

    def _execute(self, query, params=None):
        with self.connection.cursor() as cur:
            cur.execute(query, params)
            self.connection.commit()

    def close(self):
        self.connection.close()
