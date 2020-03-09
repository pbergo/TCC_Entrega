beeline -u jdbc:hive2://127.0.0.1:10000 -n cloudera -p cloudera -e "!run ./apaga_ods.hql"
hadoop fs -rm -r -skipTrash /tmp/upload/*
hadoop fs -expunge
