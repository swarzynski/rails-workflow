#!/bin/bash
BACKUP_TIME=`date +%Y-%m-%d_%H%M`
pg_dump myapp1_production | gzip > ~/dbbackup/${BACKUP_TIME}_myapp1_production.gz
ln -f -s ~/dbbackup/${BACKUP_TIME}_myapp1_production.gz ~/current_db_backup_myapp1_production.gz

