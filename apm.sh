#!/usr/bin/env bash

echo "== APM Test Script =="

echo "Hostname:"
hostname

echo "Uptime:"
uptime

echo "Top CPU processes:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 10

echo "Memory usage:"
free -m

echo "Disk usage:"
df -h

echo "Done."
