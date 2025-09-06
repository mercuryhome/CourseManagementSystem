
## Mac OSx  bash shell  brew 安装pg 17

```bash
# 以下命令在 bash shell 运行
# 安装postgres version 17
brew install postgresql@17

# 启动  postgresql
brew services start postgresql@17

# 查看安装路径
brew list postgresql@17

# mac osx /bin/bash下，添加postgres bin路径至 PATH
echo 'export PATH="/usr/local/opt/postgresql@17/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile
echo $PATH

# mac osx zsh 下
echo 'export PATH="/usr/local/opt/postgresql@17/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
echo $PATH
 
# psql登录数据库 
psql -h localhost -d postgres

# 见到以下提示符表示进入psql环境
postgres=#

# 创建postgres 角色，并赋予 superuser角色
postgres=#CREATE ROLE postgres WITH LOGIN SUPERUSER PASSWORD 'ubuntu**';

# 退出
postgres=#\q

psql -h localhost -U postgres -d postgres
# 见到以下提示符表示进入psql环境
postgres=#

# 退出
postgres=#\q
```
