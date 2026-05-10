-- ============================================================
--  Kanban Board — DDL скрипт (PostgreSQL)
-- ============================================================

-- Рабочие пространства / отделы
CREATE TABLE workspaces (
    workspace_id SERIAL      PRIMARY KEY,
    name         VARCHAR(100) NOT NULL UNIQUE,
    created_at   TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Пользователи
CREATE TABLE users (
    user_id      SERIAL       PRIMARY KEY,
    username     VARCHAR(50)  NOT NULL UNIQUE,
    password     VARCHAR(255) NOT NULL,               -- bcrypt hash
    full_name    VARCHAR(150) NOT NULL,
    role         VARCHAR(20)  NOT NULL
                     CHECK (role IN ('employee', 'manager', 'admin')),
    workspace_id INTEGER      REFERENCES workspaces(workspace_id)
                     ON DELETE SET NULL,              -- NULL для manager / admin
    last_active  TIMESTAMP,
    is_active    BOOLEAN      NOT NULL DEFAULT TRUE
);

-- Статусы колонок Kanban-доски
CREATE TABLE statuses (
    status_id    SERIAL       PRIMARY KEY,
    workspace_id INTEGER      NOT NULL
                     REFERENCES workspaces(workspace_id) ON DELETE CASCADE,
    name         VARCHAR(50)  NOT NULL,
    position     INTEGER      NOT NULL,               -- порядок колонок
    color        VARCHAR(7),                          -- HEX, например #4A90D9
    UNIQUE (workspace_id, position)
);

-- Задачи
CREATE TABLE tasks (
    task_id      SERIAL       PRIMARY KEY,
    title        VARCHAR(255) NOT NULL,
    description  TEXT,
    workspace_id INTEGER      NOT NULL
                     REFERENCES workspaces(workspace_id) ON DELETE CASCADE,
    status_id    INTEGER      NOT NULL
                     REFERENCES statuses(status_id) ON DELETE RESTRICT,
    assignee_id  INTEGER      REFERENCES users(user_id) ON DELETE SET NULL,
    creator_id   INTEGER      NOT NULL
                     REFERENCES users(user_id) ON DELETE RESTRICT,
    priority     SMALLINT     NOT NULL DEFAULT 2
                     CHECK (priority BETWEEN 1 AND 4), -- 1=низкий, 4=критический
    deadline     TIMESTAMP,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_deleted   BOOLEAN      NOT NULL DEFAULT FALSE
);

-- Комментарии к задачам
CREATE TABLE comments (
    comment_id   SERIAL       PRIMARY KEY,
    task_id      INTEGER      NOT NULL
                     REFERENCES tasks(task_id) ON DELETE CASCADE,
    author_id    INTEGER      NOT NULL
                     REFERENCES users(user_id) ON DELETE RESTRICT,
    body         TEXT         NOT NULL,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  Индексы
-- ============================================================

CREATE INDEX idx_users_workspace       ON users    (workspace_id);
CREATE INDEX idx_tasks_workspace       ON tasks    (workspace_id);
CREATE INDEX idx_tasks_status          ON tasks    (status_id);
CREATE INDEX idx_tasks_assignee        ON tasks    (assignee_id);
CREATE INDEX idx_tasks_deadline        ON tasks    (deadline) WHERE is_deleted = FALSE;
CREATE INDEX idx_comments_task         ON comments (task_id);
CREATE INDEX idx_statuses_workspace    ON statuses (workspace_id);

-- ============================================================
--  Триггер: автообновление updated_at у tasks
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tasks_updated_at
BEFORE UPDATE ON tasks
FOR EACH ROW EXECUTE FUNCTION update_updated_at();
