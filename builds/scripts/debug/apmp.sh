#!/bin/sh

pid=$(pidof mysqld)

while true; do
	#thrc=$(pstree -c $pid | wc -l)
	thrc=$(mysql -Be "SHOW STATUS LIKE 'Threads_running'" | grep Threads | awk '{print $2}')
	if (($thrc > 200)); then
		echo "============= DUMPING ($thrc) ==============="
		gdb -ex "set pagination 0" -ex "thread apply all bt" \
			--batch -p $(pidof mysqld) | awk 'BEGIN { s = ""; }
/Thread/ { print s; s = ""; }
/^\#/ { if (s != "" ) { s = s "," $4} else { s = $4 } }
END { print s }' | sort | uniq -c | sort -nr
		sleep 20
	fi
	sleep 0.01
done
