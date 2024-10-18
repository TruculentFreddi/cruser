#!/bin/bash
export BACKUP_PATH=/backup
export BACKUP_PATH;
# директория с бэкапами
BACKUP_DIR="/backup/";

#func

ID()
{
pg_probackup show --instance=$1 --format=json | jq -c '.[].backups[0].id' | awk -F '\"' '{print $2}'
}

CHECK_STATUS()
{
pg_probackup show --instance=$1 --format=json | jq -c '.[].backups[0].status'
}

for INSTANCE in $(ls /backup/backups); do
export STATUS=$(CHECK_STATUS $INSTANCE);
if [ "$STATUS" == '"OK"' -a "STATUS" != '"RUNNING"' -a "$STATUS" != '"DONE"' -a "$STATUS" != '"MERGING"' -a "$STATUS" != '"MERGED"' ]; then
echo "Все резервные копии успешны."
else
export ID=$(ID $INSTANCE);
echo "Бэкап инстанса: $INSTANCE закончился с ошибкой"
echo "Подробности: "
echo "=================================================================================================================================================="
echo " Instance  Version  ID      Recovery Time                  Mode   WAL Mode  TLI   Time   Data   WAL  Zalg  Zratio  Start LSN   Stop LSN    Status "
echo "=================================================================================================================================================="
pg_probackup show -B $BACKUP_DIR --instance $INSTANCE | grep $ID
fi
done

