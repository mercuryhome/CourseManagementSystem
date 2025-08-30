# 命令行工具 psql 

### 核心连接命令

最基本的格式是：`psql [选项]... [数据库名] [用户名]`

---

### 1. 最常用、最简单的连接方式

| 命令 | 说明 | 示例 |
| :--- | :--- | :--- |
| `psql` | 使用当前系统用户名，连接到与当前系统用户同名的数据库。 | `$ psql` |
| `psql <数据库名>` | 使用当前系统用户名，连接到指定的数据库。 | `$ psql mydb` |
| `psql -U <用户名> <数据库名>` | 使用指定的用户名连接到指定的数据库。**系统会提示输入密码。** | `$ psql -U john mydb` |
| `psql -h <主机名> -p <端口> -U <用户名> <数据库名>` | **连接远程服务器**的完整格式。 | `$ psql -h 192.168.1.100 -p 5432 -U john mydb` |

---

### 2. 常用连接选项（参数）

这些选项可以与上述命令组合使用。

| 选项 | 全称 | 说明 | 示例 |
| :--- | :--- | :--- | :--- |
| `-U <用户名>` | `--username=<用户名>` | 指定要用于连接的数据库用户。 | `psql -U postgres` |
| `-h <主机名>` | `--host=<主机名>` | 指定数据库服务器的主机名或IP地址。默认为 `localhost`。 | `psql -h db.server.com` |
| `-p <端口>` | `--port=<端口>` | 指定数据库服务器的端口。默认为 `5432`。 | `psql -p 5433` |
| `-d <数据库名>` | `--dbname=<数据库名>` | 指定要连接的数据库名。 | `psql -d template1` |
| `-W` | `--password` | **强制提示输入密码**。即使当前用户有`.pgpass`文件，也会提示。 | `psql -U john -W mydb` |
| `-w` | `--no-password` | **永不提示输入密码**。如果服务器要求密码认证且密码无法通过其他方式（如`.pgpass`）提供，连接会失败。 | `psql -w` |

---

### 3. 非常有用的非连接选项

| 选项 | 全称 | 说明 | 示例 |
| :--- | :--- | :--- | :--- |
| `-l` 或 `--list` | | **不连接数据库，而是列出服务器上所有可用的数据库**。然后退出。 | `$ psql -l` `$ psql -h remoteserver -l` |
| `-f <文件名>` | `--file=<文件名>` | 执行指定文件中的SQL命令，然后退出。用于执行脚本。 | `$ psql -d mydb -f backup.sql` |
| `-v <变量名>=<值>` | | 为`psql`设置变量，可以在SQL中用`:变量名`引用。 | `$ psql -v tablename=users -c "SELECT * FROM :tablename;"` |
| `-c <命令>` | `--command=<命令>` | 执行单个SQL命令（或由分号分隔的多个命令），然后退出。 | `$ psql -d mydb -c "SELECT version();"` |
| `-E` | | 回显`\`命令背后实际执行的SQL查询。用于学习或调试。 | `$ psql -E` `... > \dt` *(会显示查询系统表来列出表的SQL)* |
| `-q` | `--quiet` | 以安静模式运行（不显示欢迎信息、查询结果等额外输出）。 | `$ psql -q` |
| `-?` 或 `--help` | | 显示`psql`命令行参数的帮助信息。 | `$ psql --help` |

---

### 4. 环境变量与密码文件

为了避免在命令行中暴露密码，PostgreSQL 提供了更安全的方式：

*   **`PGPASSWORD` 环境变量**（不推荐，有安全风险）：
    ```bash
    $ export PGPASSWORD='mysecretpassword'
    $ psql -U john mydb
    ```

*   **`.pgpass` 密码文件**（**推荐方式**）：
    在用户家目录（`~/.pgpass`）创建一个文件，格式为：`hostname:port:database:username:password`
    ```
    # 示例 .pgpass 内容
    localhost:5432:mydb:john:password123
    db.server.com:*:*:john:anotherpassword
    ```
    创建后务必设置权限：`chmod 600 ~/.pgpass`

---

### 常用连接示例总结

1.  **连接本地默认数据库**：
    ```bash
    psql
    ```

2.  **以 `postgres` 超级用户身份连接**：
    ```bash
    psql -U postgres
    # 或者连接到特定数据库
    psql -U postgres template1
    ```

3.  **连接远程生产数据库**：
    ```bash
    psql -h production-db.example.com -p 5432 -U app_user -W app_db
    ```

4.  **不连接，只想看看服务器上有哪些数据库**：
    ```bash
    psql -h mydbserver -l
    ```

5.  **执行一个SQL脚本文件**：
    ```bash
    psql -d target_db -f /path/to/init_script.sql
    ```

6.  **快速执行一个查询并退出**（常用于脚本）：
    ```bash
    psql -d mydb -c "SELECT count(*) FROM users;"
    ```

记住，进入 `psql` 后，你可以使用 `\?` 来获取所有内部元命令的帮助。