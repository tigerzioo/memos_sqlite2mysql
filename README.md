Migrate Memos database from SQLite to MySQL\
Memos\
https://github.com/usememos/memos

The bash file is only working for version 0.21.0\
Do not try it if you have other versions.\
此Bash脚本文件只对memos 0.21.0有效（0.21.0数据库和以前版本不太一样），请不要在其他版本上运行。

Instruction:
1. Please run it on the test enironment first (请先在测试环境中运行)
2. Create the MySQL database (memos_prod) and all database structures before running the bash file (运行Bash脚本前请先创建好MySQL的数据库和所有数据库结构)
3. The columns orders of the tables between SQLite and MySQL need to be the same (SQLite和MySQL数据库里table的column的顺序必需是一样的)
4. The database file of SQLite should be memos_prod.db (SQLite数据库文件必需为memos_prod.db)
5. The database name of MySQL can be typed in. The default is memos_prod (MySQL数据库名可自己输入，默认为memos_prod)

***Memos SQLite to MySQL***
1. Copy the bash file (memos_sqlite2mysql.sh) to the folder where SQLite file is located (复制Bash脚本文件到SQLite数据库文件目录下)
2. Run the below command and follow the screen instruction (运行下面的命令，按照屏幕提示操作)
```
sudo bash memos_sqlite2mysql.sh
```
3. Run the below command if you want to import the data manually with generated scripts（如果想用生成的导入脚本自己手动导入，可以运行下面这条命令）
```
mysql -u root -p memos_prod < memos_mysql.sql
```

\
The migration does not include the below tables (数据导入导出不包含以下table，导完数据后请自行设置)\
activity\
idp\
storage\
system_setting\
user_setting\
webhook



