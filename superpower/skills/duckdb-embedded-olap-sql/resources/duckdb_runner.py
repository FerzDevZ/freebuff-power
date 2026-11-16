import duckdb
con = duckdb.connect()
print(con.execute("SELECT 42 AS answer").fetchall())
