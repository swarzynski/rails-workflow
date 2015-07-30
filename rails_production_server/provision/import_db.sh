#!/bin/bash

ssh deploy@localhost "~/backup_db.sh"
if [ ! -f ~/current_db_backup_myapp1_production  ]; then
    rm current_db_backup_myapp1_production
fi
scp deploy@localhost:current_db_backup_myapp1_production ~
pg_restore --clean -d myapp1_staging ~/current_db_backup_myapp1_production