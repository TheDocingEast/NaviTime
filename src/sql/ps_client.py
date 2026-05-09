import psycopg2

conn = psycopg2.connect(
    "dbname=navitime user=navitime password=ghio#21d host=85.209.135.157"
)
#
cur = conn.cursor()
cur.execute("SELECT * FROM users")
print(cur.fetchall())


class PS_Client:
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
        self.cursor = self.connection.cursor()
