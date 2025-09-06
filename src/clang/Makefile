# Makefile for PostgreSQL C client programs

# 编译器设置
CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -g

# PostgreSQL 库设置
# macOS 使用 Homebrew 安装的 PostgreSQL
PG_CONFIG = pg_config
PG_CFLAGS = $(shell $(PG_CONFIG) --cflags) -I$(shell $(PG_CONFIG) --includedir)
PG_LDFLAGS = $(shell $(PG_CONFIG) --ldflags) -L$(shell $(PG_CONFIG) --libdir)
PG_LIBS = -lpq $(shell $(PG_CONFIG) --libs)

# 目标程序
TARGET = test_select_student
SOURCE = test_select_student.c

# 默认目标
all: $(TARGET)

# 编译目标程序
$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) $(PG_CFLAGS) -o $(TARGET) $(SOURCE) $(PG_LDFLAGS) $(PG_LIBS)

# 清理编译文件
clean:
	rm -f $(TARGET)

# 运行程序
run: $(TARGET)
	./$(TARGET)

# 安装依赖 (macOS)
install-deps:
	@echo "安装PostgreSQL开发库..."
	@echo "如果使用Homebrew，请运行: brew install postgresql"
	@echo "如果使用其他包管理器，请安装postgresql-dev或libpq-dev包"

# 检查PostgreSQL配置
check-pg:
	@echo "检查PostgreSQL配置..."
	@echo "pg_config路径: $(shell which pg_config)"
	@echo "PostgreSQL版本: $(shell $(PG_CONFIG) --version)"
	@echo "包含路径: $(shell $(PG_CONFIG) --includedir)"
	@echo "库路径: $(shell $(PG_CONFIG) --libdir)"

.PHONY: all clean run install-deps check-pg
