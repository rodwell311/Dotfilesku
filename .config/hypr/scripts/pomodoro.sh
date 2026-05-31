#!/bin/bash
# ─────────────────────────────────────────────
#  Hyprland Pomodoro Timer — TUI via dialog
#  Simpan ke: ~/.config/hypr/pomodoro.sh
#  chmod +x ~/.config/hypr/pomodoro.sh
#  Dependency: dialog, notify-send (libnotify)
# ─────────────────────────────────────────────

# ── State files ──────────────────────────────
STATE_FILE="/tmp/hypr_pomodoro_state"
PID_FILE="/tmp/hypr_pomodoro_pid"
SESSION_FILE="/tmp/hypr_pomodoro_session"

# ── Warna tput ───────────────────────────────
RED=$(tput setaf 1)
GRN=$(tput setaf 2)
YLW=$(tput setaf 3)
CYN=$(tput setaf 6)
BLD=$(tput bold)
RST=$(tput sgr0)

# ─────────────────────────────────────────────
# show_menu()
# Menampilkan menu utama pakai dialog.
# Kalau pomodoro sedang berjalan, tampilkan
# opsi Stop. Kalau tidak, tampilkan Start.
# ─────────────────────────────────────────────
show_menu() {
    if [ -f "$STATE_FILE" ]; then
        # Pomodoro sedang aktif — baca state
        local phase session pomodoros end_time
        phase=$(sed -n '1p' "$STATE_FILE")
        session=$(sed -n '2p' "$STATE_FILE")
        pomodoros=$(sed -n '3p' "$STATE_FILE")
        end_time=$(sed -n '4p' "$STATE_FILE")
        local now=$(date +%s)
        local remaining=$(( end_time - now ))
        [ $remaining -lt 0 ] && remaining=0
        local rm=$(( remaining / 60 ))
        local rs=$(( remaining % 60 ))

        dialog --backtitle "Hyprland Pomodoro" \
               --title "[ SEDANG BERJALAN ]" \
               --menu "Fase: ${phase^^}  |  Sesi: ${session}  |  Pomodoro: ${pomodoros}\nSisa waktu: $(printf '%02d:%02d' $rm $rs)" \
               12 55 3 \
               "1" "Lihat status timer" \
               "2" "Skip fase sekarang" \
               "3" "Stop & keluar" \
               2>/tmp/hypr_pomo_choice
    else
        dialog --backtitle "Hyprland Pomodoro" \
               --title "[ MENU UTAMA ]" \
               --menu "Pilih aksi:" \
               10 45 2 \
               "1" "Mulai sesi baru" \
               "2" "Keluar" \
               2>/tmp/hypr_pomo_choice
    fi
    echo $?
}

# ─────────────────────────────────────────────
# show_config_form()
# Form dialog untuk mengatur durasi sebelum
# memulai. Mengembalikan nilai ke variabel
# global: FOCUS_MIN, SHORT_MIN, LONG_MIN, CYCLE
# ─────────────────────────────────────────────
show_config_form() {
    dialog --backtitle "Hyprland Pomodoro" \
           --title "[ KONFIGURASI SESI ]" \
           --form "Atur durasi (dalam menit):" \
           14 50 4 \
           "Focus duration    :"  1 1 "25" 1 22 5 3 \
           "Short break       :"  2 1 "5"  2 22 5 3 \
           "Long break        :"  3 1 "15" 3 22 5 3 \
           "Sessions per cycle:"  4 1 "4"  4 22 5 2 \
           2>/tmp/hypr_pomo_form

    local rc=$?
    if [ $rc -eq 0 ]; then
        mapfile -t vals < /tmp/hypr_pomo_form
        FOCUS_MIN="${vals[0]:-25}"
        SHORT_MIN="${vals[1]:-5}"
        LONG_MIN="${vals[2]:-15}"
        CYCLE="${vals[3]:-4}"

        # Validasi: harus angka positif
        for v in "$FOCUS_MIN" "$SHORT_MIN" "$LONG_MIN" "$CYCLE"; do
            if ! [[ "$v" =~ ^[0-9]+$ ]] || [ "$v" -le 0 ]; then
                dialog --msgbox "Input tidak valid. Gunakan angka positif." 6 40
                return 1
            fi
        done
        return 0
    fi
    return 1
}

# ─────────────────────────────────────────────
# enable_focus_mode()
# Aktifkan submap Hyprland → workspace
# switching dinonaktifkan selama fokus.
# ─────────────────────────────────────────────
enable_focus_mode() {
    hyprctl dispatch submap focusmode 2>/dev/null
    notify-send -u normal "🍅 Focus Mode ON" \
        "Fokus ${FOCUS_MIN} menit — workspace switching dinonaktifkan." 2>/dev/null
}

# ─────────────────────────────────────────────
# disable_focus_mode()
# Reset submap ke normal → semua keybind
# workspace kembali aktif.
# ─────────────────────────────────────────────
disable_focus_mode() {
    hyprctl dispatch submap reset 2>/dev/null
    notify-send -u normal "☕ Break Time" "$1" 2>/dev/null
}

# ─────────────────────────────────────────────
# save_state()
# Simpan state saat ini ke STATE_FILE.
# Format: phase / session / pomodoros / end_epoch
# ─────────────────────────────────────────────
save_state() {
    local phase="$1" session="$2" pomodoros="$3" end_time="$4"
    printf '%s\n%s\n%s\n%s\n' "$phase" "$session" "$pomodoros" "$end_time" > "$STATE_FILE"
}

# ─────────────────────────────────────────────
# show_progress()
# Tampilkan progress bar dialog selama timer
# berjalan. Update setiap detik. Loop sampai
# waktu habis atau file state dihapus (stop).
# ─────────────────────────────────────────────
show_progress() {
    local phase="$1" duration_sec="$2" label="$3"
    local end_time=$(( $(date +%s) + duration_sec ))

    (
        while true; do
            local now=$(date +%s)
            local remaining=$(( end_time - now ))
            [ $remaining -le 0 ] && { echo 100; break; }
            local elapsed=$(( duration_sec - remaining ))
            local pct=$(( elapsed * 100 / duration_sec ))
            local rm=$(( remaining / 60 ))
            local rs=$(( remaining % 60 ))
            echo "$pct"
            echo "XXX"
            echo "$pct"
            echo "${label} — sisa $(printf '%02d:%02d' $rm $rs)"
            echo "XXX"
            [ ! -f "$STATE_FILE" ] && { echo 100; break; }
            sleep 1
        done
    ) | dialog --backtitle "Hyprland Pomodoro" \
               --title "[ TIMER BERJALAN ]" \
               --gauge "${label}" 8 55 0
}

# ─────────────────────────────────────────────
# run_phase()
# Jalankan satu fase (focus/short/long).
# Simpan state → tampilkan progress → setelah
# selesai putuskan fase berikutnya.
# ─────────────────────────────────────────────
run_phase() {
    local phase="$1"
    local session="${2:-1}"
    local pomodoros="${3:-0}"
    local duration_sec label

    case "$phase" in
        focus)
            duration_sec=$(( FOCUS_MIN * 60 ))
            label="🍅 FOCUS — sesi ${session}"
            enable_focus_mode
            ;;
        short)
            duration_sec=$(( SHORT_MIN * 60 ))
            label="☕ SHORT BREAK"
            ;;
        long)
            duration_sec=$(( LONG_MIN * 60 ))
            label="🛋  LONG BREAK"
            ;;
    esac

    local end_time=$(( $(date +%s) + duration_sec ))
    save_state "$phase" "$session" "$pomodoros" "$end_time"

    show_progress "$phase" "$duration_sec" "$label"

    # Cek apakah dihentikan manual
    [ ! -f "$STATE_FILE" ] && return

    # Tentukan fase berikutnya
    if [ "$phase" = "focus" ]; then
        pomodoros=$(( pomodoros + 1 ))
        session=$(( session + 1 ))
        if (( pomodoros % CYCLE == 0 )); then
            disable_focus_mode "Long break ${LONG_MIN} menit! ${pomodoros} pomodoro selesai."
            run_phase "long" "$session" "$pomodoros"
        else
            disable_focus_mode "Short break ${SHORT_MIN} menit!"
            run_phase "short" "$session" "$pomodoros"
        fi
    else
        run_phase "focus" "$session" "$pomodoros"
    fi
}

# ─────────────────────────────────────────────
# stop_pomodoro()
# Hentikan semua proses timer yang berjalan
# di background, hapus state files, reset
# submap Hyprland ke normal.
# ─────────────────────────────────────────────
stop_pomodoro() {
    rm -f "$STATE_FILE"
    hyprctl dispatch submap reset 2>/dev/null
    notify-send "Pomodoro dihentikan" "Focus mode dinonaktifkan." 2>/dev/null
    dialog --msgbox "Pomodoro dihentikan.\nFocus mode dinonaktifkan." 6 40
}

# ─────────────────────────────────────────────
# skip_phase()
# Paksa selesaikan fase sekarang dengan
# menghapus state file — run_phase akan
# mendeteksi ini dan berhenti.
# ─────────────────────────────────────────────
skip_phase() {
    rm -f "$STATE_FILE"
    dialog --msgbox "Fase di-skip.\nMulai ulang dari menu." 6 40
    hyprctl dispatch submap reset 2>/dev/null
}

# ─────────────────────────────────────────────
# show_status()
# Tampilkan infobox status timer saat ini.
# ─────────────────────────────────────────────
show_status() {
    if [ ! -f "$STATE_FILE" ]; then
        dialog --msgbox "Tidak ada sesi yang berjalan." 6 40
        return
    fi
    local phase session pomodoros end_time
    phase=$(sed -n '1p' "$STATE_FILE")
    session=$(sed -n '2p' "$STATE_FILE")
    pomodoros=$(sed -n '3p' "$STATE_FILE")
    end_time=$(sed -n '4p' "$STATE_FILE")
    local remaining=$(( end_time - $(date +%s) ))
    [ $remaining -lt 0 ] && remaining=0
    local rm=$(( remaining / 60 ))
    local rs=$(( remaining % 60 ))

    dialog --msgbox "Fase    : ${phase^^}\nSesi    : ${session}\nPomodoro: ${pomodoros}\nSisa    : $(printf '%02d:%02d' $rm $rs)" 10 40
}

# ─────────────────────────────────────────────
# MAIN — entry point
# ─────────────────────────────────────────────
main() {
    # Pastikan dialog tersedia
    if ! command -v dialog &>/dev/null; then
        echo "${RED}Error:${RST} 'dialog' tidak ditemukan."
        echo "Install: ${BLD}sudo pacman -S dialog${RST}"
        exit 1
    fi

    while true; do
        show_menu
        local choice
        choice=$(cat /tmp/hypr_pomo_choice 2>/dev/null)

        if [ -f "$STATE_FILE" ]; then
            case "$choice" in
                1) show_status ;;
                2) skip_phase; break ;;
                3) stop_pomodoro; break ;;
                *) break ;;
            esac
        else
            case "$choice" in
                1)
                    if show_config_form; then
                        clear
                        run_phase "focus" 1 0
                        if [ -f "$STATE_FILE" ]; then
                            dialog --msgbox "Sesi selesai! 🎉" 6 30
                            rm -f "$STATE_FILE"
                        fi
                    fi
                    ;;
                2) break ;;
                *) break ;;
            esac
        fi
    done

    # Cleanup temp files
    rm -f /tmp/hypr_pomo_choice /tmp/hypr_pomo_form
    clear
}

main "$@"
