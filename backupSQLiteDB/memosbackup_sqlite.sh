#!/bin/bash

# 查找当前脚本目录
BASEDIR=$(dirname $0)
echo "文件备份到: ${BASEDIR}/memosbak"
cd "${BASEDIR}"

# 检查备份目录，如果没有则创建
if [ ! -d "memosbak" ]; then
  mkdir memosbak
fi

# 把未写入SQLite数据库的操作写入DB文件
sqlite3 memos_prod.db "PRAGMA wal_checkpoint(PASSIVE);" >/dev/null 2>&1

# 备份数据库文件到备份目录，并添加时间后缀
cp memos_prod.db ./memosbak/"memos_prod-$(date +%Y%m%d_%H%M%S).db"

# 删除超过30天的备份，+30表示只保留30天，可以自己修改天数
find ./memosbak -type f -mtime +30 -delete
