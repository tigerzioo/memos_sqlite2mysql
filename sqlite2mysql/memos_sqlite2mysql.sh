#!/bin/bash

sqlite3 memos_prod.db ".mode insert user" "select id,datetime(created_ts, 'unixepoch') as created_ts,datetime(updated_ts, 'unixepoch') as updated_ts,row_status,username,role,email,nickname,password_hash,avatar_url,description from user;" > m.sql

sqlite3 memos_prod.db ".mode insert tag" "select name,creator_id from tag;" >> m.sql

sqlite3 memos_prod.db ".mode insert memo" "SELECT id,uid,creator_id,datetime(created_ts, 'unixepoch') as created_ts,datetime(updated_ts, 'unixepoch') as updated_ts,row_status,content,visibility FROM memo;" >> m.sql

sqlite3 memos_prod.db ".mode insert resource" "SELECT id,uid,creator_id,datetime(created_ts, 'unixepoch') as created_ts,datetime(updated_ts, 'unixepoch') as updated_ts,filename,hex(blob),external_link,type,size,internal_path,memo_id FROM resource;" >> m.sql

sqlite3 memos_prod.db ".mode insert memo_organizer" "select memo_id,user_id,pinned from memo_organizer;" >> m.sql

sqlite3 memos_prod.db ".mode insert memo_relation" "select memo_id,related_memo_id,type from memo_relation;" >> m.sql

sqlite3 memos_prod.db ".mode insert reaction" "select id,datetime(created_ts, 'unixepoch') as created_ts,creator_id,content_id,reaction_type from reaction;" >> m.sql


mysql -u root memos_prod < m.sql
