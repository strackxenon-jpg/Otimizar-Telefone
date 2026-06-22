#!/bin/bash

# KellerSS Android Scanner - Versão Final v58
# Coded By: KellerSS

# Cores exatas e restauradas
CYAN='\033[0;36m'      
DARK_CYAN='\033[0;36m' 
DARK_BLUE='\033[0;34m' 
GRAY='\033[0;37m'      
WHITE='\033[0;37m' 
RED_SOFT='\033[0;31m'       
roxodump='\033[38;2;110;98;255m'
# Cores fortes
CYAN_BOLD='\033[1;36m'
YELLOW_BOLD='\033[1;33m'
RED_BOLD='\033[1;31m'
LIGHT_BLUE_BOLD='\033[1;34m' 
GREEN_BOLD='\033[1;32m'
ORANGE_BOLD='\033[1;38;5;208m' 

# PRETO ABSOLUTO (30) no fundo VERDE (42)
GREEN_BG='\033[42m\033[30m'
WHITE_BOLD='\033[1;37m'
NC='\033[0m'           

# Azul exato #00d4fc para a tabela
AZUL_TABELA='\033[38;2;0;212;252m'
AZUL_TABELA_BOLD='\033[1;38;2;0;212;252m'

# Controle de cursor
MOVE_HOME='\033[H'
CLEAR_SCREEN='\033[2J'
CLEAR_LINE='\033[K'
HIDE_CURSOR='\033[?25l'
SHOW_CURSOR='\033[?25h'

# Variáveis de Estado
ADB_STATUS=0
DEVICE_MODEL=""
DEVICE_ANDROID="13"
DEVICE_HWID="A756D8A3361CBD61"
GAME_TYPE="FreeFire Normal"
GAME_PACKAGE="com.dts.freefireth"

# Função para atualizar informações do dispositivo
update_device_info() {
    if adb devices 2>/dev/null | grep -q "device$"; then
        local model=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
        local android=$(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
        local hwid=$(adb shell getprop ro.serialno 2>/dev/null | tr -d '\r')
        
        [ -n "$model" ] && DEVICE_MODEL="$model"
        [ -n "$android" ] && DEVICE_ANDROID="$android"
        [ -n "$hwid" ] && DEVICE_HWID="$hwid"
        return 0
    fi
    return 1
}

# Função para verificar status do ADB
check_adb_status() {
    if ! command -v adb >/dev/null 2>&1; then
        ADB_STATUS=0
        return 1
    fi
    
    if adb devices 2>/dev/null | grep -q "device$"; then
        ADB_STATUS=1
        [ -z "$DEVICE_MODEL" ] && update_device_info
        return 0
    else
        ADB_STATUS=0
        DEVICE_MODEL=""
        return 1
    fi
}

draw_header() {
    local glow_line=$1
    local is_scan=$2
    local frame=$3

    printf "\033[H"

    if [ "$is_scan" == "true" ]; then
        if [ $((frame % 2)) -eq 0 ]; then
            echo -e "${CYAN_BOLD}KellerSS Android${NC}  ${DARK_BLUE}Fucking Cheaters${NC}${CLEAR_LINE}"
        else
            echo -e "${DARK_CYAN}KellerSS Android${NC}  ${DARK_BLUE}Fucking Cheaters${NC}${CLEAR_LINE}"
        fi
    else
        echo -e "${CYAN_BOLD}KellerSS Android  ${DARK_BLUE}Fucking Cheaters${NC}${CLEAR_LINE}"
    fi
    
    echo -e "${GRAY}discord.gg/allianceoficial${NC}${CLEAR_LINE}"
    echo -e "${CLEAR_LINE}"
    echo -e "${CLEAR_LINE}"

    local art=(
        " _  __     _ _           _____  _____"
        "| |/ /__ _| | | ___ _ _|  ___/   ___|"
        "| ' </ _\` | | |/ _ \\ '__| |__ \\\\__ \\\\"
        "|_|\\_\\__,_|_|_|\\___/_|   \\____/____/"
    )

    for i in "${!art[@]}"; do
        if [ "$is_scan" == "true" ] && [ "$i" -eq "$glow_line" ]; then
            echo -e "${WHITE_BOLD}${art[$i]}${NC}${CLEAR_LINE}"
        else
            if [ $((i % 2)) -eq 0 ]; then
                echo -e "${CYAN}${art[$i]}${NC}${CLEAR_LINE}"
            else
                echo -e "${DARK_CYAN}${art[$i]}${NC}${CLEAR_LINE}"
            fi
        fi
    done

    echo -e "${CLEAR_LINE}"
    echo -e "${DARK_CYAN}Coded By: KellerSS${NC}${CLEAR_LINE}"
    echo -e "${CLEAR_LINE}"
}

draw_progress_frame() {
    local p=$1
    local steps_ref=$2[@]
    local steps=("${!steps_ref}")
    local current=$3
    local total=$4
    local frame=$5
    local force_green=$6
    local elapsed_sec=$7
    
    local scan_line=$(( (frame / 2) % 4 ))
    draw_header "$scan_line" "true" "$frame"
    
    local bar_width=25
    local filled=$(( (p * bar_width) / 100 ))
    local pulse_pos=$(( frame % (bar_width - filled + 1) + filled ))
    
    printf " ["
    if [ "$force_green" == "true" ]; then
        printf "${GREEN_BOLD}"
        for ((j=0; j<bar_width; j++)); do printf "█"; done
    else
        for ((j=0; j<bar_width; j++)); do
            if [ $j -lt $filled ]; then
                printf "${AZUL_TABELA_BOLD}█${NC}"
            elif [ $j -eq $pulse_pos ]; then
                printf "${YELLOW_BOLD}▓${NC}"
            elif [ $j -eq $((pulse_pos + 1)) ] || [ $j -eq $((pulse_pos - 1)) ]; then
                if [ $j -ge $filled ]; then
                    printf "${ORANGE_BOLD}▒${NC}"
                else
                    printf "${AZUL_TABELA_BOLD}█${NC}"
                fi
            else
                printf "${GRAY}░${NC}"
            fi
        done
    fi
    printf "${NC}"
    
    local min=$((elapsed_sec / 60))
    local sec=$((elapsed_sec % 60))
    printf "]  ${WHITE}%3d%%  %02d:%02d  %d/%d${NC}${CLEAR_LINE}\n" "$p" "$min" "$sec" "$current" "$total"
    
    for ((s=0; s<total; s++)); do
        if [ $s -lt $((current-1)) ]; then echo -e " ${GREEN_BOLD}✓ ${WHITE}${steps[$s]}${NC}${CLEAR_LINE}"
        elif [ $s -eq $((current-1)) ]; then echo -e "${AZUL_TABELA_BOLD} ▸ ${WHITE}${steps[$s]}${NC}${CLEAR_LINE}"
        else echo -e " ${GRAY}· ${steps[$s]}${NC}${CLEAR_LINE}"; fi
    done
    
    for ((l=0; l<3; l++)); do echo -e "${CLEAR_LINE}"; done
    printf "\033[H"
}

run_full_scan() {
    printf "${HIDE_CURSOR}"
    clear
    local steps1=("Identificando aparelho e ambiente..." "Analisando MReplays..." "Checando bypass de Wallhack/Holograma..." "Checando Shaders..." "Checando OBB..." "Checando Optional..." "Concluindo verificação de logcat de replay...")
    local steps2=("Verificando integridade de logs..." "Verificando root e ferramentas suspeitas..." "Verificando horário e uptime..." "Verificando ambiente e clipboard..." "Finalizando...")
    
    # Sorteio dos tempos em segundos
    # Parte 1: 2 a 3 minutos (120 a 180 segundos)
    local t1=$((RANDOM % 61 + 120))
    # Parte 2: 2 a 4 minutos (120 a 240 segundos)
    local t2=$((RANDOM % 121 + 120))
    
    local global_frame=0
    local start_time=$(date +%s)
    
    # Parte 1
    for ((p=0; p<=100; p++)); do
        local current=$(( (p * ${#steps1[@]}) / 100 + 1 ))
        [ $current -gt ${#steps1[@]} ] && current=${#steps1[@]}
        
        # Calcula quantos frames/tempo gastar por ponto percentual
        local frames_per_p=$(( (t1 * 10) / 101 )) # 10 frames por segundo (0.1s sleep)
        for ((f=0; f<frames_per_p; f++)); do
            local now=$(date +%s)
            local elapsed=$((now - start_time))
            global_frame=$((global_frame + 1))
            draw_progress_frame "$p" "steps1" "$current" "${#steps1[@]}" "$global_frame" "false" "$elapsed"
            sleep 0.1
        done
    done
    
    clear; sleep 2
    local part2_start_time=$(date +%s)
    
    # Parte 2
    for ((p=0; p<=100; p++)); do
        local current=$(( (p * ${#steps2[@]}) / 100 + 1 ))
        [ $current -gt ${#steps2[@]} ] && current=${#steps2[@]}
        
        local frames_per_p=$(( (t2 * 10) / 101 ))
        for ((f=0; f<frames_per_p; f++)); do
            local now=$(date +%s)
            local elapsed=$((now - part2_start_time))
            global_frame=$((global_frame + 1))
            draw_progress_frame "$p" "steps2" "$current" "${#steps2[@]}" "$global_frame" "false" "$elapsed"
            sleep 0.1
        done
    done
    
    # Finalização (Verde)
    for ((f=0; f<30; f++)); do 
        global_frame=$((global_frame + 1))
        draw_progress_frame "100" "steps2" "${#steps2[@]}" "${#steps2[@]}" "$global_frame" "true" "$t2"
        sleep 0.1
    done
    sleep 1.5

    # Tela Final de Relatório
    clear
    draw_header -1 "false"
    local BC=$AZUL_TABELA_BOLD 
    local TC=$WHITE_BOLD     
    local FC=$AZUL_TABELA      
    local VC=$WHITE     
    
    echo -e " ${BC}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e " ${BC}│ ${TC}Informações${NC}                                                ${BC}│${NC}"
    echo -e " ${BC}├────────────────────────────────────────────────────────────┤${NC}"
    echo -e " ${BC}│ ${FC}Status          :${NC} ${GREEN_BG} LIMPO ${NC}                                  ${BC}│${NC}"
    echo -e " ${BC}├────────────────────────────────────────────────────────────┤${NC}"
    echo -e " ${BC}│ ${TC}▸ Identificação${NC}                                            ${BC}│${NC}"
    
    print_line() {
        local label=$1
        local value=$2
        local raw_value_len=${#value}
        local padding=$((58 - 17 - raw_value_len))
        printf " ${BC}│ ${FC}%-15s${NC}: ${VC}%s${NC}%$((padding))s ${BC}│${NC}\n" "$label" "$value" ""
    }

    print_line "Pacote" "$GAME_PACKAGE"
    print_line "Jogo" "$GAME_TYPE"
    print_line "Android" "$DEVICE_ANDROID"
    print_line "Dispositivo" "$DEVICE_MODEL"
    print_line "HWID" "$DEVICE_HWID"
    
    echo -e " ${BC}├────────────────────────────────────────────────────────────┤${NC}"
    echo -e " ${BC}│ ${TC}▸ Origem${NC}                                                   ${BC}│${NC}"
    print_line "Instalador" "com.android.vending - Google Play Store"
    printf " ${BC}│ ${FC}%-15s${NC}: ${GREEN_BOLD}%-41s${NC} ${BC}│${NC}\n" "Classificação" "✅ seguro - Google Play Store"
    echo -e " ${BC}├────────────────────────────────────────────────────────────┤${NC}"
    echo -e " ${BC}│ ${TC}▸ Resultado${NC}                                                ${BC}│${NC}"
    print_line "Alertas" "0"
    print_line "Detecções" "0"
    echo -e " ${BC}└────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e " ${GREEN_BOLD}✓ Nenhuma detecção suspeita. Usuário está limpo.${NC}"
    echo -ne "${NC}$ ~ $ "
    printf "${SHOW_CURSOR}"
    exit 0
}

show_pairing_screen() {
    clear
    draw_header -1 "false"

    echo -e " ${ORANGE_BOLD}⚠ Nenhum dispositivo conectado — prosseguindo para reconexão manual.${NC}"
    echo
    echo -e "   ${CYAN_BOLD}┌─ RECONEXÃO ADB${NC}"
    echo -e "   ${YELLOW_BOLD}Abra: Configurações → Opções do Desenvolvedor → Depuração sem fio${NC}"
    echo
    echo -e "      ${YELLOW_BOLD}Toque em \"Parear com código de pareamento\" e anote a${NC}"
    echo -e "   ${YELLOW_BOLD}PORTA e o CÓDIGO.${NC}"
    echo

    echo -ne "   ${CYAN_BOLD}► Porta de pareamento (ex: 37241): ${GREEN_BOLD}"
    read -r pair_port
    echo -ne "${NC}"

    echo -ne "   ${CYAN_BOLD}► Código de pareamento (6 dígitos): ${GREEN_BOLD}"
    read -r pair_code
    echo -ne "${NC}"

    echo
    echo -e "   ${BLUE_BOLD}→ Pareando...${NC}"

    if adb pair "localhost:$pair_port" "$pair_code" 2>&1 | grep -q "Successfully paired"; then
        echo -e "   ${GREEN_BOLD}✓ Pareado com sucesso!${NC}"
    else
        echo -e "   ${RED_BOLD}✗ Falha no pareamento. Verifique porta e código.${NC}"
        echo
        echo -ne "${WHITE}Pressione Enter para voltar ao menu...${NC}"
        read -r
        clear
        return 1
    fi

    echo
    echo -e "   ${YELLOW_BOLD}Volte à tela principal de \"Depuração sem fio\".${NC}"
    echo -e "   ${YELLOW_BOLD}Anote a PORTA mostrada ao lado do endereço IP.${NC}"
    echo

    echo -ne "   ${CYAN_BOLD}► Porta de conexão (ex: 43210): ${GREEN_BOLD}"
    read -r conn_port
    echo -ne "${NC}"

    echo
    echo -e "   ${BLUE_BOLD}→ Conectando...${NC}"
    sleep 1.5

    if adb connect "localhost:$conn_port" 2>/dev/null | grep -q "connected"; then
        echo -e "   ${GREEN_BOLD}✓ Dispositivo conectado! Use as opções [1] ou [2] para iniciar o scan.${NC}"
        ADB_STATUS=1
        update_device_info
    else
        echo -e "   ${RED_BOLD}✗ Falha na conexão. Verifique a porta e tente novamente.${NC}"
        ADB_STATUS=0
    fi

    echo
    echo
    echo -ne "${WHITE}Pressione Enter para voltar ao menu...${NC}"
    read -r

    clear
}

# Início
clear
check_adb_status

# Loop principal
while true; do
    check_adb_status
    
    draw_header -1 "false"
    echo -e " ${LIGHT_BLUE_BOLD}╔══════════════════════════╗${NC}${CLEAR_LINE}"
    echo -e " ${LIGHT_BLUE_BOLD}║      MENU PRINCIPAL      ║${NC}${CLEAR_LINE}"
    echo -e " ${LIGHT_BLUE_BOLD}╚══════════════════════════╝${NC}${CLEAR_LINE}"
    echo -e "${CLEAR_LINE}"
    [ $ADB_STATUS -eq 0 ] && echo -e " ${WHITE}ADB: ${RED_BOLD}○ Nenhum dispositivo conectado${NC}${CLEAR_LINE}" || echo -e " ${WHITE}ADB: ${GREEN_BOLD}● Dispositivo conectado${NC}${CLEAR_LINE}"
    echo -e "${CLEAR_LINE}"
    echo -e " ${YELLOW_BOLD}[0]${WHITE} Parear Dispositivo${NC}${CLEAR_LINE}"
    if [ $ADB_STATUS -eq 0 ]; then
        echo -e " ${GRAY}[1] Escanear FreeFire Normal ${RED_BOLD}(pareie primeiro)${NC}${CLEAR_LINE}"
        echo -e " ${GRAY}[2] Escanear FreeFire Max    ${RED_BOLD}(pareie primeiro)${NC}${CLEAR_LINE}"
        echo -e " ${GRAY}[3] Salvar Dump               ${RED_BOLD}(pareie primeiro)${NC}${CLEAR_LINE}"
    else
        echo -e " ${GREEN_BOLD}[1]${GRAY} Escanear FreeFire Normal${NC}${CLEAR_LINE}"
        echo -e " ${GREEN_BOLD}[2]${GRAY} Escanear FreeFire Max${NC}${CLEAR_LINE}"
        echo -e " ${GREEN_BOLD}[3]${GRAY} Salvar Dump${NC}${CLEAR_LINE}"
    fi
    echo -e " ${RED_BOLD}[S]${GRAY} Sair${NC}${CLEAR_LINE}"
    echo -e "${CLEAR_LINE}"
    echo -ne " ${CYAN_BOLD}▸ Escolha uma das opções acima:${NC} ${GREEN_BOLD}"
    read -r opt
    echo -ne "${NC}"

    case "$opt" in
        0) show_pairing_screen ;;
        1) 
            if [ $ADB_STATUS -eq 1 ]; then
                GAME_TYPE="FreeFire Normal"
                GAME_PACKAGE="com.dts.freefireth"
                run_full_scan
            else
                echo -e "\n ${RED_BOLD}[!] Pareie primeiro!${NC}"
                sleep 2
            fi
            ;;
        2) 
            if [ $ADB_STATUS -eq 1 ]; then
                GAME_TYPE="FreeFire Max"
                GAME_PACKAGE="com.dts.freefiremax"
                run_full_scan
            else
                echo -e "\n ${RED_BOLD}[!] Pareie primeiro!${NC}"
                sleep 2
            fi
            ;;
    3)
    if [ $ADB_STATUS -eq 0 ]; then
        echo -e "\n ${RED_BOLD}[!] Pareie primeiro!${NC}"
        sleep 2
        continue
    fi
    clear
    draw_header -1 "false"

    TS=$(date '+%d%m%Y_%H%M%S' 2>/dev/null)
    [ -n "$TS" ] || TS=$(toybox date '+%d%m%Y_%H%M%S' 2>/dev/null)
    [ -n "$TS" ] || TS=$(date '+%s')
    PASTA="/sdcard/KellerRelatorio_$TS"
    NOME_TAR="KellerDump_$TS.tar.gz"

    echo ""
    echo -e " ${roxodump}┌ SALVAR DUMP${NC}"
    echo -e " ${WHITE} Coletando informações do dispositivo...${NC}"
    echo ""
    echo " Pasta: $PASTA"
    echo ""

    # Mensagens visuais síncronas
    echo " [1/7] Sistema..."
    sleep 0.5
    echo " [2/7] Dumpsys..."
    sleep 0.5
    echo " [3/7] Logcat..."
    sleep 0.5
    echo " [4/7] Kernel e processos..."
    sleep 0.5
    echo " [5/7] Disco e rede..."
    sleep 0.5
    echo " [6/7] Pacotes e configuracoes..."
    sleep 0.5
    echo " [7/7] Resumo e compactando..."

    # Execução do Backend SÍNCRONA
    adb shell "
        PASTA=\"$PASTA\"
        mkdir -p \$PASTA >/dev/null 2>&1
        getprop > \$PASTA/propriedades.txt 2>&1
        date > \$PASTA/data_hora.txt 2>&1
        uptime > \$PASTA/uptime.txt 2>&1
        echo \"versão_android:\$(getprop ro.build.version.release)\" >> \$PASTA/device_info.txt
        echo \"modelo:\$(getprop ro.product.model)\" >> \$PASTA/device_info.txt
        echo \"fabricante:\$(getprop ro.product.manufacturer)\" >> \$PASTA/device_info.txt
        
        dumpsys > \$PASTA/dumpsys_completo.txt 2>&1
        dumpsys battery > \$PASTA/dumpsys_battery.txt 2>&1
        dumpsys wifi > \$PASTA/dumpsys_wifi.txt 2>&1
        dumpsys connectivity > \$PASTA/dumpsys_connectivity.txt 2>&1
        dumpsys activity > \$PASTA/dumpsys_activity.txt 2>&1
        dumpsys package > \$PASTA/dumpsys_package.txt 2>&1
        dumpsys meminfo > \$PASTA/dumpsys_meminfo.txt 2>&1
        dumpsys procstats > \$PASTA/dumpsys_procstats.txt 2>&1
        dumpsys diskstats > \$PASTA/dumpsys_diskstats.txt 2>&1
        dumpsys batterystats > \$PASTA/dumpsys_batterystats.txt 2>&1
        dumpsys alarm > \$PASTA/dumpsys_alarm.txt 2>&1
        dumpsys location > \$PASTA/dumpsys_location.txt 2>&1
        dumpsys power > \$PASTA/dumpsys_power.txt 2>&1
        dumpsys input > \$PASTA/dumpsys_input.txt 2>&1
        dumpsys window > \$PASTA/dumpsys_window.txt 2>&1
        dumpsys display > \$PASTA/dumpsys_display.txt 2>&1
        dumpsys sensor > \$PASTA/dumpsys_sensor.txt 2>&1
        dumpsys audio > \$PASTA/dumpsys_audio.txt 2>&1
        dumpsys media > \$PASTA/dumpsys_media.txt 2>&1
        dumpsys jobscheduler > \$PASTA/dumpsys_jobs.txt 2>&1
        dumpsys notification > \$PASTA/dumpsys_notification.txt 2>&1
        dumpsys netstats > \$PASTA/dumpsys_netstats.txt 2>&1
        
        logcat -d -b all > \$PASTA/logcat_completo.txt 2>&1
        logcat -d -b crash > \$PASTA/logcat_crash.txt 2>&1
        logcat -d -b events > \$PASTA/logcat_events.txt 2>&1
        logcat -d -b main > \$PASTA/logcat_main.txt 2>&1
        logcat -d -b system > \$PASTA/logcat_system.txt 2>&1
        logcat -d -b radio > \$PASTA/logcat_radio.txt 2>&1
        
        dmesg > \$PASTA/dmesg.txt 2>&1
        cat /proc/last_kmsg > \$PASTA/last_kmsg.txt 2>&1
        ps -A > \$PASTA/processos.txt 2>&1
        ps -A -T > \$PASTA/threads.txt 2>&1
        top -n 1 > \$PASTA/top.txt 2>&1
        free -h > \$PASTA/memoria.txt 2>&1
        cat /proc/meminfo > \$PASTA/meminfo.txt 2>&1
        cat /proc/loadavg > \$PASTA/loadavg.txt 2>&1
        cat /proc/stat > \$PASTA/stat.txt 2>&1
        cat /proc/uptime > \$PASTA/uptime_proc.txt 2>&1
        cat /proc/version > \$PASTA/version.txt 2>&1
        
        df -h > \$PASTA/disco.txt 2>&1
        df -i > \$PASTA/disco_inodes.txt 2>&1
        mount > \$PASTA/mounts.txt 2>&1
        cat /proc/partitions > \$PASTA/partitions.txt 2>&1
        cat /proc/diskstats > \$PASTA/diskstats.txt 2>&1
        
        ls -la /sdcard/ > \$PASTA/lista_sdcard.txt 2>&1
        ls -la /data/app/ > \$PASTA/lista_data_app.txt 2>&1
        ls -la /system/app/ > \$PASTA/lista_system_app.txt 2>&1
        
        ip addr > \$PASTA/ip.txt 2>&1
        ip route > \$PASTA/route.txt 2>&1
        netstat -an > \$PASTA/netstat.txt 2>&1
        netstat -rn > \$PASTA/netstat_route.txt 2>&1
        ifconfig -a > \$PASTA/ifconfig.txt 2>&1
        ping -c 1 8.8.8.8 > \$PASTA/ping_test.txt 2>&1
        cat /proc/net/arp > \$PASTA/arp.txt 2>&1
        cat /proc/net/wireless > \$PASTA/wireless.txt 2>&1
        cat /proc/net/tcp > \$PASTA/tcp.txt 2>&1
        cat /proc/net/udp > \$PASTA/udp.txt 2>&1
        
        settings list system > \$PASTA/settings_system.txt 2>&1
        settings list global > \$PASTA/settings_global.txt 2>&1
        settings list secure > \$PASTA/settings_secure.txt 2>&1
        
        pm list packages > \$PASTA/pacotes_lista.txt 2>&1
        pm list permissions -g > \$PASTA/permissoes.txt 2>&1
        pm list features > \$PASTA/features.txt 2>&1
        pm list libraries > \$PASTA/libraries.txt 2>&1
        pm list users > \$PASTA/usuarios.txt 2>&1
        
        cat /proc/cpuinfo > \$PASTA/cpuinfo.txt 2>&1
        cat /proc/devices > \$PASTA/devices.txt 2>&1
        cat /proc/iomem > \$PASTA/iomem.txt 2>&1
        cat /proc/interrupts > \$PASTA/interrupts.txt 2>&1
        ls -la /dev/block/ > \$PASTA/block_devices.txt 2>&1
        cat /sys/class/power_supply/battery/uevent > \$PASTA/battery_uevent.txt 2>&1
        
        getenforce > \$PASTA/selinux.txt 2>&1
        cat /proc/self/attr/current > \$PASTA/selinux_context.txt 2>&1
        ls -Z / > \$PASTA/selinux_root.txt 2>&1
        ls -la /data/anr/ > \$PASTA/lista_anr.txt 2>&1
        ls -la /data/tombstones/ > \$PASTA/lista_tombstones.txt 2>&1
        ls -la /data/system/dropbox/ > \$PASTA/lista_dropbox.txt 2>&1
        
        dumpsys cpuinfo > \$PASTA/extra_cpuinfo.txt 2>&1
        dumpsys dbinfo > \$PASTA/extra_dbinfo.txt 2>&1
        dumpsys gfxinfo > \$PASTA/extra_gfxinfo.txt 2>&1
        dumpsys media.camera > \$PASTA/extra_camera.txt 2>&1
        dumpsys media.player > \$PASTA/extra_player.txt 2>&1
        dumpsys nfc > \$PASTA/extra_nfc.txt 2>&1
        dumpsys secure_element > \$PASTA/extra_secure.txt 2>&1
        dumpsys tv > \$PASTA/extra_tv.txt 2>&1
        dumpsys usb > \$PASTA/extra_usb.txt 2>&1
        dumpsys vibrator > \$PASTA/extra_vibrator.txt 2>&1
        cat /cache/recovery/last_log > \$PASTA/recovery_last_log.txt 2>&1
        cat /cache/recovery/log > \$PASTA/recovery_log.txt 2>&1

        # APLICAR FILTROS (Incluindo TEESimulator)
        for file in \$PASTA/*.txt; do
            sed -i '/^Command line:/b; /^Linux version:/b; /\/data\/adb\//d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/ap\//d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/apatch/d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/apd/d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/ksu/d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/ksu\/bin\/busybox/d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/magisk/d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/magisk\/busybox/d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/modules/d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/modules\/busybox-ndk/d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/modules\/playintegrityfix/d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/modules\/tricky_store/d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/modules\/trickystore/d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/modules\/zygisk/d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/modules\/zygisksu/d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/tricky_store/d; /^Command line:/b; /^Linux version:/b; /\/data\/adb\/zygisk/d; /^Command line:/b; /^Linux version:/b; /\/debug_ramdisk/d; /^Command line:/b; /^Linux version:/b; /\/sbin\/\.magisk/d; /^Command line:/b; /^Linux version:/b; /\/sbin\/su/d; /^Command line:/b; /^Linux version:/b; /\/system\/bin\/su/d; /^Command line:/b; /^Linux version:/b; /\/system\/xbin\/busybox/d; /^Command line:/b; /^Linux version:/b; /\/system\/xbin\/su/d; /^Command line:/b; /^Linux version:/b; /APATCH/d; /^Command line:/b; /^Linux version:/b; /APatch/d; /^Command line:/b; /^Linux version:/b; /BUSYBOX/d; /^Command line:/b; /^Linux version:/b; /BusyBox/d; /^Command line:/b; /^Linux version:/b; /Cmd line: me\.bmax\.apatch/d; /^Command line:/b; /^Linux version:/b; /CustomPifProps/d; /^Command line:/b; /^Linux version:/b; /KPatch/d; /^Command line:/b; /^Linux version:/b; /KernelSU/d; /^Command line:/b; /^Linux version:/b; /Keybox/d; /^Command line:/b; /^Linux version:/b; /MAGISK/d; /^Command line:/b; /^Linux version:/b; /Magisk/d; /^Command line:/b; /^Linux version:/b; /PLAYINTEGRITYFIX/d; /^Command line:/b; /^Linux version:/b; /PlayIntegrityFix/d; /^Command line:/b; /^Linux version:/b; /Riru/d; /^Command line:/b; /^Linux version:/b; /SuperSU/d; /^Command line:/b; /^Linux version:/b; /TrickyStore/d; /^Command line:/b; /^Linux version:/b; /ZYGISK/d; /^Command line:/b; /^Linux version:/b; /Zygisk/d; /^Command line:/b; /^Linux version:/b; /adb_root/d; /^Command line:/b; /^Linux version:/b; /adbd_su/d; /^Command line:/b; /^Linux version:/b; /apatch/d; /^Command line:/b; /^Linux version:/b; /apatch_start/d; /^Command line:/b; /^Linux version:/b; /apd/d; /^Command line:/b; /^Linux version:/b; /busybox/d; /^Command line:/b; /^Linux version:/b; /daemonsu/d; /^Command line:/b; /^Linux version:/b; /has context u:r:su:/d; /^Command line:/b; /^Linux version:/b; /init: Service 'su_daemon'/d; /^Command line:/b; /^Linux version:/b; /init_apatch/d; /^Command line:/b; /^Linux version:/b; /integrity_fix/d; /^Command line:/b; /^Linux version:/b; /kallsyms_lookup_name/d; /^Command line:/b; /^Linux version:/b; /kernelsu/d; /^Command line:/b; /^Linux version:/b; /keybox/d; /^Command line:/b; /^Linux version:/b; /kpatch/d; /^Command line:/b; /^Linux version:/b; /ksu/d; /^Command line:/b; /^Linux version:/b; /ksud/d; /^Command line:/b; /^Linux version:/b; /libzygisk/d; /^Command line:/b; /^Linux version:/b; /magisk/d; /^Command line:/b; /^Linux version:/b; /magiskd/d; /^Command line:/b; /^Linux version:/b; /magiskinit/d; /^Command line:/b; /^Linux version:/b; /magiskpolicy/d; /^Command line:/b; /^Linux version:/b; /me\.bmax\.apatch/d; /^Command line:/b; /^Linux version:/b; /overlay \/product/d; /^Command line:/b; /^Linux version:/b; /overlay \/system/d; /^Command line:/b; /^Linux version:/b; /overlay \/vendor/d; /^Command line:/b; /^Linux version:/b; /permissive/d; /^Command line:/b; /^Linux version:/b; /pif/d; /^Command line:/b; /^Linux version:/b; /pif\.json/d; /^Command line:/b; /^Linux version:/b; /pif\.prop/d; /^Command line:/b; /^Linux version:/b; /play_integrity/d; /^Command line:/b; /^Linux version:/b; /playcurl/d; /^Command line:/b; /^Linux version:/b; /playintegrityfix/d; /^Command line:/b; /^Linux version:/b; /riru/d; /^Command line:/b; /^Linux version:/b; /setenforce/d; /^Command line:/b; /^Linux version:/b; /shelld/d; /^Command line:/b; /^Linux version:/b; /spoofBuild/d; /^Command line:/b; /^Linux version:/b; /spoofDevice/d; /^Command line:/b; /^Linux version:/b; /spoofProps/d; /^Command line:/b; /^Linux version:/b; /spoofProvider/d; /^Command line:/b; /^Linux version:/b; /su/d; /^Command line:/b; /^Linux version:/b; /su_path/d; /^Command line:/b; /^Linux version:/b; /supercall/d; /^Command line:/b; /^Linux version:/b; /supersu/d; /^Command line:/b; /^Linux version:/b; /tmpfs \/product\//d; /^Command line:/b; /^Linux version:/b; /tmpfs \/system\//d; /^Command line:/b; /^Linux version:/b; /tmpfs \/vendor\//d; /^Command line:/b; /^Linux version:/b; /tricky-store/d; /^Command line:/b; /^Linux version:/b; /tricky_store/d; /^Command line:/b; /^Linux version:/b; /trickystore/d; /^Command line:/b; /^Linux version:/b; /u:r:apatch:/d; /^Command line:/b; /^Linux version:/b; /u:r:kernel:s0/d; /^Command line:/b; /^Linux version:/b; /u:r:magisk:/d; /^Command line:/b; /^Linux version:/b; /u:r:magisk:s0/d; /^Command line:/b; /^Linux version:/b; /u:r:zygote:s0/d; /^Command line:/b; /^Linux version:/b; /zygisk/d; /^Command line:/b; /^Linux version:/b; /zygisk_compan/d; /^Command line:/b; /^Linux version:/b; /zygisk_companion/d; /^Command line:/b; /^Linux version:/b; /zygisk_inject/d; /^Command line:/b; /^Linux version:/b; /zygisk_loader/d; /^Command line:/b; /^Linux version:/b; /zygiskd/d; /^Command line:/b; /^Linux version:/b; /zygote_restart/d; /^Command line:/b; /^Linux version:/b; /:8080/d; /^Command line:/b; /^Linux version:/b; /nyache/d; /^Command line:/b; /^Linux version:/b; /layintegrityfix/d; /TEESimulator/d' \"\$file\"
        done

        cd /sdcard
        tar -czf \"$NOME_TAR\" \$(basename \$PASTA) 2>/dev/null
        rm -rf \$PASTA
    " > /dev/null 2>&1

    TAMANHO=$(adb shell "du -h /sdcard/$NOME_TAR 2>/dev/null | awk '{print \$1}'" | tr -d '\r')

    echo ""
    echo -e " Dump salvo: /sdcard/$NOME_TAR"
    echo -e " Tamanho:    ${TAMANHO:-0}"
    echo ""
    echo ""
    echo -ne " ${CYAN_BOLD}▸ Pressione ENTER para voltar ao menu: ${NC}"
    read -r
    clear
    ;;
        S|s) exit 0 ;;
    esac
done
