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

    # ── Workspaces ──────────────────────────────────────────
    def get_workspaces(self):
        return self._fetch("SELECT * FROM workspaces")

    # ── Users ────────────────────────────────────────────────
    def get_user(self, username, password_hash):
        return self._fetch_one(
            "SELECT * FROM users WHERE username = %s AND password = %s AND is_active = TRUE",
            (username, password_hash)
        )

    def get_users_by_workspace(self, workspace_id):
        return self._fetch(
            "SELECT * FROM users WHERE workspace_id = %s AND is_active = TRUE",
            (workspace_id,)
        )

    # ── Tasks ────────────────────────────────────────────────
    def get_tasks(self, workspace_id):
        return self._fetch(
            "SELECT * FROM tasks WHERE workspace_id = %s AND is_deleted = FALSE ORDER BY priority DESC",
            (workspace_id,)
        )

    def get_hot_task(self, workspace_id):
        """Горящая задача — ближайший дедлайн"""
        return self._fetch_one(
            "SELECT * FROM tasks WHERE workspace_id = %s AND deadline IS NOT NULL "
            "AND is_deleted = FALSE ORDER BY deadline ASC LIMIT 1",
            (workspace_id,)
        )

    def create_task(self, title, description, workspace_id, status_id, creator_id, priority, deadline):
        self._execute(
            "INSERT INTO tasks (title, description, workspace_id, status_id, creator_id, priority, deadline) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s)",
            (title, description, workspace_id, status_id, creator_id, priority, deadline)
        )

    def update_task_status(self, task_id, status_id):
        self._execute(
            "UPDATE tasks SET status_id = %s WHERE task_id = %s",
            (status_id, task_id)
        )

    def update_task_priority(self, task_id, priority):
        self._execute(
            "UPDATE tasks SET priority = %s WHERE task_id = %s",
            (priority, task_id)
        )

    def soft_delete_task(self, task_id):
        self._execute(
            "UPDATE tasks SET is_deleted = TRUE WHERE task_id = %s",
            (task_id,)
        )

    # ── Comments ─────────────────────────────────────────────
    def get_comments(self, task_id):
        return self._fetch(
            "SELECT * FROM comments WHERE task_id = %s ORDER BY created_at ASC",
            (task_id,)
        )

    def add_comment(self, task_id, author_id, body):
        self._execute(
            "INSERT INTO comments (task_id, author_id, body) VALUES (%s, %s, %s)",
            (task_id, author_id, body)
        )

    # ── Statuses ─────────────────────────────────────────────
    def get_statuses(self, workspace_id):
        return self._fetch(
            "SELECT * FROM statuses WHERE workspace_id = %s ORDER BY position ASC",
            (workspace_id,)
        )

    # ── Вспомогательные методы ───────────────────────────────
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


dbclient = DBClient(
    dbname="navitime",
    user="navitime",
    password="ghio#21d",
    host="85.209.135.157"
)

dbclient.get_workspaces()
