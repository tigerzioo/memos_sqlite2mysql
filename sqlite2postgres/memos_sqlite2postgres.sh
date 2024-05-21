#!/bin/bash

echo " "
echo " "
echo "+++++++++++++++++ Memos SQLite 2 PostgreSQL ++++++++++++++++++++++"
echo "提示 (Note)："
echo "SQLite数据库文件必需为memos_prod.db，PostgreSQL数据库名可自己输入，默认为memos_prod。"
echo "此Bash脚本文件要和SQLite数据库文件放在同一目录下。"
echo "The database file of SQLite should be memos_prod.db，The database name of PostgreSQL can be typed in. The default is memos_prod。"
echo "This bash file should be in the folder where SQLite file is located。"
echo " "
columns=12
act=0
acts=""
v=0
vs=""
PS3="请选择PostgreSQL导入方式 (Please select)："
select action in "退出 (Exit)" "仅生成PostgreSQL数据库的导入脚本，稍后自己手动导入 (Generate the import scripts only)" "直接导入到PostgreSQL数据库（数据库必须在本机才可以）(Import to PostgreSQL. PostgreSQL need to be in the same host)"
do
echo "+++++++++++++++++++"
echo " "


if [[ "$REPLY" == 1 ]]
then
  echo "退出 (Exit)！"
  echo "+++++++++++++++++++"
  echo " "
  exit
fi
if [[ "$REPLY" != 2 && "$REPLY" != 3 ]]
then
  echo "无效，请重新选择 (Invalid, please select again)！"
else
  act=$REPLY
  acts=$action
  break
fi
done

# a=$(sqlite3 memos_prod.db "select count(*) from resource;")
# echo $a
# exit

echo "导入方式 (Import option)：$acts"
echo "版本 (Version)：0.22.0"

while true; do
    read -p "请确认导入方式和版本，是否继续 (Please confirm)?(y/n) " yn
    case $yn in
        [Yy]* ) break;; 
        [Nn]* ) exit;;
        * ) echo "请输入 y(yes) or n(no).";;
    esac
done

# SQLite database
litedb="memos_prod.db"

# user
sqlite3 "$litedb" ".mode insert user" "select id,created_ts,updated_ts,row_status,username,role,email,nickname,password_hash,avatar_url,description from user;" > memos_2post.sql
sed -i -e 's/INTO user/INTO "user"/g' memos_2post.sql

# memo
sqlite3 "$litedb" ".mode insert memo" "SELECT id,uid,creator_id,created_ts,updated_ts,row_status,content,visibility,tags,payload FROM memo;" >> memos_2post.sql
sed -i -e 's/char(/chr(/g' memos_2post.sql

# Create a temp table in order to convert blob column in resource table
echo 'CREATE TABLE rstemp (id integer, blobhex text);' >> memos_2post.sql

# rstemp
sqlite3 "$litedb" ".mode insert resource" "SELECT id,hex(blob) FROM resource;" >> memos_2post.sql
sed -i -e 's/INTO resource/INTO rstemp/g' memos_2post.sql


# resource
sqlite3 "$litedb" ".mode insert resource" "SELECT id,uid,creator_id,created_ts,updated_ts,filename,hex(blob),type,size,memo_id,storage_type,reference,payload FROM resource;" >> memos_2post.sql

# memo_organizer
sqlite3 "$litedb" ".mode insert memo_organizer" "select memo_id,user_id,pinned from memo_organizer;" >> memos_2post.sql

# memo_relation
sqlite3 "$litedb" ".mode insert memo_relation" "select memo_id,related_memo_id,type from memo_relation;" >> memos_2post.sql

# reaction
sqlite3 "$litedb" ".mode insert reaction" "select id,created_ts,creator_id,content_id,reaction_type from reaction;" >> memos_2post.sql

# inbox
sqlite3 "$litedb" ".mode insert inbox" "SELECT id,created_ts,sender_id,receiver_id,status,message FROM inbox;" >> memos_2post.sql

# unhex blob
echo "UPDATE resource SET blob=decode(rstemp.blobhex, 'hex') FROM rstemp WHERE resource.id = rstemp.id;" >> memos_2post.sql
echo "DROP TABLE rstemp;" >> memos_2post.sql

if [[ "$act" == 2 ]]
then

  echo "========脚本已生成，保存在当前目录，文件名为memos_2post.sql (The scripts generated. The file name is memos_2post.sql)"
  echo "+++++++++++++++++++"
  echo " "
fi

if [[ "$act" == 3 ]]
then
  read -p "请输入PostgreSQL数据库名（回车默认为memos_prod）(Please enter PostgreSQL DB name. The default is memos_prod): " mydb
  if [[ -z "$mydb" ]]; then
    mydb="memos_prod"
  fi


  read -p "请输入PostgreSQL用户名（回车默认为root）(Please enter the user for PostgreSQL. The default is root): " myname
  if [[ -z "$myname" ]]; then
    myname=root
  fi
  echo "PostgreSQL数据库 (DB): $mydb"
  echo "PostgreSQL用户名 (user): $myname"
  # psql -d memos < memos_2post.sql 
  psql -d "$mydb" -U "$myname" -W < memos_2post.sql
fi
