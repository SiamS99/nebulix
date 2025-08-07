#!/bin/bash
waiting_time=30

# wait for MSSQL server to start
export STATUS=1
i=0

sleep $waiting_time
while [[ $STATUS -ne 0 ]] && [[ $i -lt $waiting_time/2 ]];
do
	i=$i+1
	/opt/mssql-tools18/bin/sqlcmd -t 1 -U sa -P $SA_PASSWORD -No -Q "select 1" >> /dev/null
	STATUS=$?
done

if [ $STATUS -ne 0 ]; then 
	echo "======= Error: MSSQL SERVER took more than $waiting_time seconds to start up.  ========";
	exit 1
fi

echo "======= MSSQL SERVER STARTED ========"
# Run the setup scripts by add one or more *.sql in docker-entrypoint-initdb.d
for filename in ./docker-entrypoint-initdb.d/*.sql; do
	/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -No -d master -i "$filename";
done

echo "======= MSSQL CONFIG COMPLETE ======="