#!/bin/bash

# create insert scripts
# USER
mysql -u root --disable-column-names -B -e "select 'INSERT INTO user (id,created_ts,updated_ts,row_status,username,role,email,nickname,password_hash,avatar_url,description) VALUES' union all SELECT concat('(',id,',',UNIX_TIMESTAMP(created_ts),',',UNIX_TIMESTAMP(updated_ts),',''',row_status,''',''',username,''',''',role,''',''',email,''',''',nickname,''',''',password_hash,''',''',avatar_url,''',''',description,'''),') as iq FROM memos_prod.user" > memos_2sqlite.sql

# remove the comma at the end of the file
sed -i '$ s/.$//' memos_2sqlite.sql

# TAG
mysqldump -u root --no-create-info --skip-triggers --compact --extended-insert=FALSE memos_prod tag >> memos_2sqlite.sql

# MEMO
mysql -u root --disable-column-names -B -e "select 'INSERT INTO memo (id,uid,creator_id,created_ts,updated_ts,row_status,content,visibility) VALUES' union all SELECT concat('(',id,',''',uid,''',',creator_id,',',UNIX_TIMESTAMP(created_ts),',',UNIX_TIMESTAMP(updated_ts),',''',row_status,''',''',content,''',''',visibility,'''),') as iq FROM memos_prod.memo" >> memos_2sqlite.sql

sed -i '$ s/.$//' memos_2sqlite.sql

# RESOURCE
mysql -u root --disable-column-names -B -e "select 'INSERT INTO resource (id, resource_name, creator_id, created_ts, updated_ts, filename, blob, external_link, type, size, internal_path, memo_id) VALUES' union all SELECT concat('(',id,',''',resource_name,''',',creator_id,',',UNIX_TIMESTAMP(created_ts),',',UNIX_TIMESTAMP(updated_ts),',''',filename,''',',concat('x''',hex(\`blob\`)),''',''',external_link,''',''',type,''',',size,',''',internal_path,''',',memo_id,'),') as iq FROM memos_prod.resource" >> memos_2sqlite.sql

sed -i '$ s/.$//' memos_2sqlite.sql




# Load data to SQLite database
sqlite3 memos_prod.db < memos_2sqlite.sql
