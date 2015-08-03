#!/bin/bash
start_time=`date +%s`
./server.sh createvm
./server.sh start
sleep 30
./server.sh provision1
sleep 15
./server.sh start
sleep 30
./server.sh provision2
sleep 15
./server.sh start
end_time=`date +%s`
echo execution time was `expr $end_time - $start_time` s.