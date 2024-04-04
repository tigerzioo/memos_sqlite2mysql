Migrate Memos database from SQLite to MySQL\
Memos\
https://github.com/usememos/memos

The bash file is only working for version 0.21.0\
Do not try it if you have other versions.

Instruction:\
1. The database file of SQLite should be memos_prod.db (SQLite数据库文件必需为memos_prod.db)\
2. The database name of MySQL should be memos_prod (MySQL数据库名必需为memos_prod)\
3. Copy the bash file (memos_sqlite2mysql.sh) to the folder where SQLite file is located (复制Bash脚本文件到SQLite数据库文件目录下)\
4. Run the below command and follow the menu
```
bash memos_sqlite2mysql.sh
```

The migration does not include the below tables.\
activity\
idp\
storage\
system_setting\
user_setting\
webhook\



