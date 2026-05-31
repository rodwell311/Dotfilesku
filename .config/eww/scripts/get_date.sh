#!/bin/sh

HARI=$(date +%u)
TGL=$(date +%d)
BLN=$(date +%m)
THN=$(date +%Y)

case $HARI in
    1) H="Senin" ;; 2) H="Selasa" ;; 3) H="Rabu" ;; 4) H="Kamis" ;;
    5) H="Jumat" ;; 6) H="Sabtu" ;; 7) H="Ahad" ;;
esac

case $BLN in
    01) B="Januari" ;; 02) B="Februari" ;; 03) B="Maret" ;; 04) B="April" ;;
    05) B="Mei" ;; 06) B="Juni" ;; 07) B="Juli" ;; 08) B="Agustus" ;;
    09) B="September" ;; 10) B="Oktober" ;; 11) B="November" ;; 12) B="Desember" ;;
esac

echo "$H, $TGL $B $THN"
