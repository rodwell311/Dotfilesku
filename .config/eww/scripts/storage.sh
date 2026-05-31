#!/bin/sh

case $1 in
    root_avail) df -h / | awk 'NR==2 {print $4}' ;;
    root_use)   df -h / | awk 'NR==2 {print $3}' ;;
    
    home_avail) df -h /home | awk 'NR==2 {print $4}' ;;
    home_use)   df -h /home | awk 'NR==2 {print $3}' ;;
esac
