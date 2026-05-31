#!/bin/sh

# Check Latitude, Longitude, Elevation => https://mapcarta.com
LAT="-7.0447"
LON="110.4620"
ELEV="183"
CITY="Semarang"

case $1 in
    city)
      echo "$CITY"
        ;;
    hijri)
        langgar hijri -l $LAT -o $LON -e $ELEV -c -1
        ;;
    *)
        # Mengambil jam shalat berdasarkan argumen (subuh, dzuhur, dll)
        # capitalized $1 untuk mencocokkan output langgar (e.g., Subuh)
        label=$(echo "$1" | sed 's/./\U&/')
        langgar prayer -l $LAT -o $LON -e $ELEV | grep "$label" | awk '{print $3}'
        ;;
esac
