**备份 Memos SQLite 数据库文件**

备份脚本没有Memos版本区别，支持所有版本。
功能：
1. 如果备份目录不存在，自动创建备份目录
2. 自动将未写入SQLite的操作写入DB文件
3. 备份文件自动添加时间后缀
4. 自动清除超过30天的备份文件（可以自己修改脚本更改保留天数）

手动运行：
1. 复制脚本文件（memosbackup_sqlite.sh）到SQLite数据库文件目录下
2. 运行下面命令备份到当前目录下的memosbak目录
```
sudo bash memosbackup_sqlite.sh
```
