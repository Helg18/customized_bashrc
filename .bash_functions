#!/bin/bash
# ==================================================
# ARCHIVO DE FUNCIONES PERSONALIZADAS
# Más de 50 funciones útiles para el día a día
# ==================================================

# ===== FUNCIONES AUXILIARES SEGURAS =====

# Función segura para ejecutar comandos con manejo de errores
function safe_run() {
    local cmd=$1
    local fallback=$2
    if command -v $cmd &> /dev/null; then
        $cmd
    else
        echo "$fallback"
    fi
}

# Función para formatear output con colores (si está disponible)
function color_echo() {
    local message=$1
    if command -v lolcat &> /dev/null && command -v toilet &> /dev/null; then
        echo "$message" | toilet -f term -F metal 2>/dev/null | lolcat 2>/dev/null
    elif command -v lolcat &> /dev/null; then
        echo "$message" | lolcat 2>/dev/null
    else
        echo "=== $message ==="
    fi
}

# ===== SISTEMA Y MONITOREO =====

# Información completa del sistema CORREGIDA
function sysinfo() {
    color_echo "INFORMACIÓN DETALLADA DEL SISTEMA"
    
    # Información básica del sistema
    echo "💻 HOSTNAME: $(hostname)"
    echo "👤 USUARIO: $(whoami)"
    echo "🐧 DISTRIBUCIÓN: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'No disponible')"
    echo "🖥️  KERNEL: $(uname -r)"
    echo "🎯 ARQUITECTURA: $(arch)"
    echo "💻 CPU: $(lscpu 2>/dev/null | grep 'Model name' | cut -d: -f2 | sed 's/^ *//' || echo 'No disponible')"
    echo "🔢 NÚCLEOS: $(nproc)"
    
    # Memoria - CORREGIDO: sin operaciones en unidades
    mem_info=$(free -h 2>/dev/null | grep Mem: || echo "Mem: N/A N/A N/A N/A")
    echo "💾 RAM: $(echo "$mem_info" | awk '{print $3 "/" $2 " used"}')"
    
    # SWAP - CORREGIDO
    swap_info=$(free -h 2>/dev/null | grep Swap: || echo "Swap: N/A N/A N/A N/A")
    echo "💽 SWAP: $(echo "$swap_info" | awk '{print $3 "/" $2}')"
    
    # Disco - CORREGIDO
    disk_info=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}' || echo "N/A")
    echo "💿 DISCO ROOT: $disk_info"
    
    # Uptime
    echo "⏰ UPTIME: $(uptime -p 2>/dev/null | sed 's/up //' || echo 'N/A')"
    
    # Temperatura - Múltiples métodos de detección
    echo "🌡️  TEMPERATURA:"
    
    # Método 1: Sensores LM
    if command -v sensors &> /dev/null; then
        sensors 2>/dev/null | grep -E "(Core|Package|temp)" | head -3 | while read line; do
            echo "  📊 $line"
        done
    fi
    
    # Método 2: Archivos thermal
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
        if [ -n "$temp" ] && [ "$temp" -gt 0 ]; then
            echo "  🔥 CPU: $((temp/1000))°C (thermal_zone0)"
        fi
    fi
    
    # Método 3: Archivos hwmon
    if ls /sys/class/hwmon/hwmon*/temp1_input 1> /dev/null 2>&1; then
        for sensor in /sys/class/hwmon/hwmon*/temp1_input; do
            temp=$(cat "$sensor" 2>/dev/null)
            if [ -n "$temp" ] && [ "$temp" -gt 0 ]; then
                name=$(cat "$(dirname "$sensor")/name" 2>/dev/null || echo "hwmon")
                echo "  🔥 $name: $((temp/1000))°C"
            fi
        done
    fi
    
    # Información de red
    echo "🌐 IP LOCAL: $(hostname -I 2>/dev/null | awk '{print $1}' || echo 'No disponible')"
    echo "🎨 TERMINAL: $TERM"
    echo "🐚 SHELL: $SHELL"
}

# Monitor en tiempo real mejorado y CORREGIDO
function live-monitor() {
    color_echo "MONITOR EN TIEMPO REAL"
    echo "🛑 Presiona Ctrl+C para salir"
    echo ""
    
    while true; do
        clear
        color_echo "MONITOR EN VIVO - $(date '+%H:%M:%S')"
        
        # CPU - método seguro
        cpu_usage=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 || echo "0")
        echo "💻 CPU: ${cpu_usage}% usado"
        
        # Memoria - método seguro sin operaciones complejas
        mem_info=$(free -h 2>/dev/null | grep Mem: || echo "Mem: 0 0 0 0")
        mem_used=$(echo $mem_info | awk '{print $3}')
        mem_total=$(echo $mem_info | awk '{print $2}')
        echo "💾 RAM: $mem_used/$mem_total"
        
        # Temperatura
        temp_detected=false
        if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
            temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
            if [ -n "$temp" ] && [ "$temp" -gt 0 ]; then
                echo "🌡️  TEMP: $((temp/1000))°C"
                temp_detected=true
            fi
        fi
        
        if command -v sensors &> /dev/null && [ "$temp_detected" = false ]; then
            temp=$(sensors 2>/dev/null | grep -oP 'Core 0:\s+\+\K\d+\.\d' | head -1)
            if [ -n "$temp" ]; then
                echo "🌡️  TEMP: ${temp}°C"
            fi
        fi
        
        # Disco - método seguro
        disk_usage=$(df -h / 2>/dev/null | awk 'NR==2 {print $5}' || echo "N/A")
        echo "💿 DISCO: $disk_usage usado"
        
        # Load average
        load=$(uptime 2>/dev/null | awk -F'load average:' '{print $2}' || echo "N/A")
        echo "📈 CARGA: $load"
        
        # Procesos
        process_count=$(ps aux 2>/dev/null | wc -l || echo "N/A")
        echo "🔄 PROCESOS: $process_count activos"
        
        sleep 2
    done
}

# Detección de sensores disponibles - CORREGIDO
function detect-sensors() {
    color_echo "DETECCIÓN DE SENSORES"
    
    echo "1. 🔥 SENSORES THERMAL_ZONE:"
    find /sys/class/thermal -name "temp*" -type f 2>/dev/null | while read file; do
        if [ -r "$file" ]; then
            temp=$(cat "$file" 2>/dev/null)
            if [ -n "$temp" ] && [ "$temp" -gt 0 ]; then
                echo "   📁 $file → $((temp/1000))°C"
            fi
        fi
    done
    
    echo ""
    echo "2. 🔥 SENSORES HWMON:"
    find /sys/class/hwmon -name "temp*" -type f 2>/dev/null | while read file; do
        if [ -r "$file" ]; then
            temp=$(cat "$file" 2>/dev/null)
            if [ -n "$temp" ] && [ "$temp" -gt 0 ]; then
                echo "   📁 $file → $((temp/1000))°C"
            fi
        fi
    done
    
    echo ""
    echo "3. 📊 COMANDO SENSORS:"
    if command -v sensors &> /dev/null; then
        sensors 2>/dev/null | head -20
    else
        echo "   ❌ lm-sensors no instalado. Instala con: sudo apt install lm-sensors"
    fi
}

# ===== GESTIÓN DE ARCHIVOS =====

# Buscar archivos con colores y preview - CORREGIDO
function findit() {
    if [ -z "$1" ]; then
        echo "🔍 USO: findit <patrón>"
        return 1
    fi
    echo "🔍 BUSCANDO: '$1'"
    find . -name "$1" -type f 2>/dev/null | while read file; do
        echo -e "\033[1;32m📁 ENCONTRADO:\033[0m \033[1;34m$file\033[0m"
        if command -v file &> /dev/null; then
            echo "   📄 Tipo: $(file -b "$file" 2>/dev/null || echo "Desconocido")"
        fi
    done
}

# Crear directorio y entrar automáticamente
function mkcd() {
    if [ -z "$1" ]; then
        echo "📁 USO: mkcd <nombre_directorio>"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
    echo "📁 DIRECTORIO CREADO Y ACCEDIDO: $1"
    ls -la
}

# Navegación mejorada con lista de contenido
function cl() {
    local target_dir="$1"
    if [ -z "$target_dir" ]; then
        target_dir="."
    fi
    cd "$target_dir" && ls -la --color=auto
}

# Comprimir con progreso visual
function tarball() {
    if [ -z "$2" ]; then
        echo "📦 USO: tarball <nombre_archivo> <directorio>"
        return 1
    fi
    echo "🗜️ COMPRIMIENDO: $2 → $1.tar.gz"
    tar -czf "$1.tar.gz" "$2"
    echo "✅ COMPRIMIDO: $1.tar.gz ($(du -h "$1.tar.gz" 2>/dev/null | cut -f1 || echo "Tamaño desconocido"))"
}

# Extraer cualquier tipo de archivo comprimido
function extract() {
    if [ -z "$1" ]; then
        echo "📤 USO: extract <archivo_comprimido>"
        return 1
    fi
    
    if [ ! -f "$1" ]; then
        echo "❌ ARCHIVO NO ENCONTRADO: $1"
        return 1
    fi
    
    case "$1" in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.rar)       unrar x "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.tar)       tar xf "$1"      ;;
        *.tbz2)      tar xjf "$1"     ;;
        *.tgz)       tar xzf "$1"     ;;
        *.zip)       unzip "$1"       ;;
        *.Z)         uncompress "$1"  ;;
        *.7z)        7z x "$1"        ;;
        *.deb)       ar x "$1"        ;;
        *)           echo "❌ NO SÉ CÓMO EXTRAER: $1" ; return 1 ;;
    esac
    
    echo "✅ EXTRAÍDO: $1"
}

# ===== RED Y CONECTIVIDAD =====

# Información de IP mejorada
function myip() {
    color_echo "INFORMACIÓN DE RED"
    echo "🔗 IP PÚBLICA: $(curl -s ifconfig.me 2>/dev/null || echo 'No disponible')"
    echo "🏠 IP LOCAL: $(hostname -I 2>/dev/null | awk '{print $1}' || echo 'No disponible')"
    echo "🌍 HOSTNAME: $(hostname)"
}

# Ping mejorado con colores
function pingg() {
    if [ -z "$1" ]; then
        echo "🔄 USO: pingg <host_o_ip>"
        return 1
    fi
    echo "🔄 HACIENDO PING A: $1"
    ping -c 4 "$1" | while read line; do
        if echo "$line" | grep -q "time="; then
            echo -e "\033[1;32m✅ $line\033[0m"
        elif echo "$line" | grep -q "packet loss"; then
            echo -e "\033[1;33m📊 $line\033[0m"
        else
            echo "$line"
        fi
    done
}

# Descargar con barra de progreso visual
function wget-progress() {
    if [ -z "$1" ]; then
        echo "📥 USO: wget-progress <URL>"
        return 1
    fi
    echo "📥 DESCARGANDO: $1"
    wget --progress=bar:force "$1"
}

# Weather con formato mejorado en ESPAÑOL
function weather() {
    local location="${1:-}"
    color_echo "INFORMACIÓN DEL CLIMA"
    curl -s "wttr.in/${location}?lang=es" 2>/dev/null || echo "Información del clima no disponible"
}

# ===== DESARROLLO Y PROGRAMACIÓN =====

# Crear estructura de proyecto automáticamente
function new-project() {
    if [ -z "$1" ]; then
        echo "🆕 USO: new-project <nombre_proyecto>"
        return 1
    fi
    
    echo "🚀 CREANDO PROYECTO: $1"
    mkdir -p "$1" && cd "$1"
    
    # Estructura de directorios estándar
    mkdir -p src docs tests config scripts assets
    
    # Archivos básicos
    touch README.md .gitignore .env.example
    
    # Contenido básico para README
    cat > README.md << EOF
# $1

## Descripción
Proyecto creado automáticamente.

## Estructura
- \`src/\` - Código fuente
- \`docs/\` - Documentación
- \`tests/\` - Tests
- \`config/\` - Configuraciones
- \`scripts/\` - Scripts de utilidad
- \`assets/\` - Recursos

## Instalación
\`\`\`bash
# Instrucciones de instalación
\`\`\`

## Uso
\`\`\`bash
# Instrucciones de uso
\`\`\`
EOF

    # .gitignore básico
    cat > .gitignore << EOF
# Entornos virtuales
venv/
.env

# Logs
*.log

# Archivos temporales
*.tmp
*.temp
EOF

    echo "✅ PROYECTO CREADO EN: $(pwd)"
    if command -v tree &> /dev/null; then
        tree .
    else
        ls -la
    fi
}

# Búsqueda en código con resultados coloreados
function codegrep() {
    if [ -z "$2" ]; then
        echo "🔍 USO: codegrep <patrón> <extensión>"
        return 1
    fi
    echo "🔍 BUSCANDO '$1' EN ARCHIVOS .$2"
    find . -name "*.$2" -type f -exec grep -Hn --color=always "$1" {} \; 2>/dev/null
}

# Crear script ejecutable con template
function new-script() {
    if [ -z "$1" ]; then
        echo "📜 USO: new-script <nombre_script>"
        return 1
    fi
    
    local script_name="$1"
    if [[ ! "$script_name" =~ \.sh$ ]]; then
        script_name="$1.sh"
    fi
    
    cat > "$script_name" << EOF
#!/bin/bash
# ==================================================
# SCRIPT: $(basename "$script_name")
# DESCRIPCIÓN: 
# AUTOR: $(whoami)
# FECHA: $(date +%Y-%m-%d)
# ==================================================

set -e  # Salir en error

# Colores para output
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
NC='\\033[0m' # No Color

# Función para mensajes de error
error() {
    echo -e "\${RED}[ERROR]\${NC} \$1" >&2
}

# Función para mensajes de éxito
success() {
    echo -e "\${GREEN}[ÉXITO]\${NC} \$1"
}

# Función para mensajes informativos
info() {
    echo -e "\${YELLOW}[INFO]\${NC} \$1"
}

# Main function
main() {
    info "Iniciando script..."
    
    # Tu código aquí
    
    success "Script completado"
}

# Manejo de argumentos
while [[ \$# -gt 0 ]]; do
    case \$1 in
        -h|--help)
            echo "Uso: \$0 [opciones]"
            echo "Opciones:"
            echo "  -h, --help    Mostrar esta ayuda"
            exit 0
            ;;
        *)
            error "Opción desconocida: \$1"
            exit 1
            ;;
    esac
    shift
done

# Ejecutar función principal
main "\$@"
EOF

    chmod +x "$script_name"
    echo "📜 SCRIPT CREADO: $script_name"
}

# ===== DOCKER Y CONTENEDORES =====

# Listar contenedores Docker con formato mejorado
function docker-ps() {
    color_echo "CONTENEDORES DOCKER"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Docker no está disponible"
}

# Estadísticas de Docker en tiempo real
function docker-stats() {
    color_echo "ESTADÍSTICAS DOCKER"
    docker stats --no-stream 2>/dev/null || echo "Docker no está disponible"
}

# Limpieza completa de Docker
function docker-clean() {
    color_echo "LIMPIANDO DOCKER"
    
    echo "🗑️  ELIMINANDO CONTENEDORES DETENIDOS..."
    docker container prune -f 2>/dev/null || echo "Docker no disponible"
    
    echo "🗑️  ELIMINANDO IMÁGENES HUÉRFANAS..."
    docker image prune -f 2>/dev/null || echo "Docker no disponible"
    
    echo "🗑️  ELIMINANDO VOLÚMENES NO USADOS..."
    docker volume prune -f 2>/dev/null || echo "Docker no disponible"
    
    echo "🗑️  ELIMINANDO REDES NO USADAS..."
    docker network prune -f 2>/dev/null || echo "Docker no disponible"
    
    echo "✅ DOCKER LIMPIO!"
}

# ===== SISTEMA DE NOTAS RÁPIDAS =====

# Sistema de notas en terminal
function note() {
    local notes_dir="$HOME/.notes"
    mkdir -p "$notes_dir"
    
    if [ -z "$1" ]; then
        # Listar notas existentes
        color_echo "MIS NOTAS"
        if [ "$(ls -A "$notes_dir")" ]; then
            ls -lt "$notes_dir" | head -10
        else
            echo "📭 No hay notas guardadas"
        fi
        return
    fi
    
    local action="$1"
    local note_name="$2"
    
    case "$action" in
        "create"|"new")
            if [ -z "$note_name" ]; then
                echo "✏️  USO: note create <nombre_nota>"
                return 1
            fi
            local note_file="$notes_dir/${note_name}.txt"
            echo "✏️  CREANDO NUEVA NOTA: $note_name"
            echo "Escribe tu nota (Ctrl+D para guardar, Ctrl+C para cancelar):"
            cat > "$note_file"
            echo "💾 NOTA GUARDADA: $note_file"
            ;;
        "show"|"view")
            if [ -z "$note_name" ]; then
                echo "📖 USO: note show <nombre_nota>"
                return 1
            fi
            local note_file="$notes_dir/${note_name}.txt"
            if [ -f "$note_file" ]; then
                color_echo "MOSTRANDO NOTA: $note_name"
                cat "$note_file"
            else
                echo "❌ NOTA NO ENCONTRADA: $note_name"
            fi
            ;;
        "delete"|"remove")
            if [ -z "$note_name" ]; then
                echo "🗑️  USO: note delete <nombre_nota>"
                return 1
            fi
            local note_file="$notes_dir/${note_name}.txt"
            if [ -f "$note_file" ]; then
                rm "$note_file"
                echo "🗑️  NOTA ELIMINADA: $note_name"
            else
                echo "❌ NOTA NO ENCONTRADA: $note_name"
            fi
            ;;
        "search")
            if [ -z "$note_name" ]; then
                echo "🔍 USO: note search <texto>"
                return 1
            fi
            color_echo "BUSCANDO EN NOTAS: '$note_name'"
            grep -r -i --color=always "$note_name" "$notes_dir" 2>/dev/null || echo "No se encontraron resultados"
            ;;
        *)
            # Si no es un comando, asumimos que es el nombre de una nota
            local note_file="$notes_dir/${action}.txt"
            if [ -f "$note_file" ]; then
                color_echo "MOSTRANDO NOTA: $action"
                cat "$note_file"
            else
                echo "❌ NOTA NO ENCONTRADA: $action"
                echo "💡 Usa 'note create $action' para crearla"
            fi
            ;;
    esac
}

# ===== JUEGOS Y ENTRETENIMIENTO =====

# Piedra, papel o tijera mejorado
function rps() {
    options=("piedra" "papel" "tijera")
    computer=${options[$RANDOM % 3]}
    
    color_echo "PIEDRA, PAPEL O TIJERA"
    echo "Elige: piedra, papel o tijera"
    read -r player
    
    player=$(echo "$player" | tr '[:upper:]' '[:lower:]')
    
    case $player in
        piedra|papel|tijera)
            echo "👤 TÚ: $player"
            echo "🤖 COMPUTADORA: $computer"
            
            if [ "$player" = "$computer" ]; then
                color_echo "¡EMPATE!"
            elif { [ "$player" = "piedra" ] && [ "$computer" = "tijera" ]; } ||
                 { [ "$player" = "papel" ] && [ "$computer" = "piedra" ]; } ||
                 { [ "$player" = "tijera" ] && [ "$computer" = "papel" ]; }; then
                echo "🎉 ¡GANASTE!"
                if command -v paplay &> /dev/null; then
                    paplay /usr/share/sounds/ubuntu/stereo/system-ready.ogg 2>/dev/null &
                fi
            else
                echo "💀 PERDISTE..."
            fi
            ;;
        *)
            echo "❌ OPCIÓN INVÁLIDA: $player"
            echo "💡 Opciones válidas: piedra, papel, tijera"
            ;;
    esac
}

# Simulador de hacker con efectos
function hacker-mode() {
    color_echo "ACTIVANDO MODO HACKER"
    echo "🛑 Presiona Ctrl+C para salir"
    sleep 2
    cmatrix -s -b -C cyan 2>/dev/null || echo "Instala cmatrix: sudo apt install cmatrix"
}

# Reloj ASCII en tiempo real
function ascii-clock() {
    color_echo "RELOJ ASCII"
    echo "🛑 Presiona Ctrl+C para salir"
    while true; do
        clear
        if command -v toilet &> /dev/null; then
            date +"%H:%M:%S" | toilet -f bigmono12 2>/dev/null
        else
            date +"%H:%M:%S"
        fi
        sleep 1
    done
}

# Juego de Snake
function snake-game() {
    if command -v nsnake &> /dev/null; then
        color_echo "JUEGO SNAKE"
        nsnake
    else
        echo "❌ nsnake no instalado. Instala con: sudo apt install nsnake"
    fi
}

# Juego de Tetris
function tetris-game() {
    if command -v bastet &> /dev/null; then
        color_echo "JUEGO TETRIS"
        bastet
    else
        echo "❌ bastet no instalado. Instala con: sudo apt install bastet"
    fi
}

# ===== MANTENIMIENTO Y SEGURIDAD =====

# Limpieza completa del sistema
function mega-clean() {
    color_echo "LIMPIEZA COMPLETA"
    
    echo "🗑️  LIMPIANDO CACHE DE APT..."
    sudo apt autoclean -y 2>/dev/null || echo "APT no disponible"
    
    echo "🗑️  ELIMINANDO PAQUETES INNECESARIOS..."
    sudo apt autoremove -y 2>/dev/null || echo "APT no disponible"
    
    echo "🗑️  LIMPIANDO CACHE DEL USUARIO..."
    rm -rf ~/.cache/* 2>/dev/null || echo "No se pudo limpiar cache"
    
    echo "🗑️  LIMPIANDO ARCHIVOS TEMPORALES..."
    sudo find /tmp -type f -atime +7 -delete 2>/dev/null || echo "No se pudieron limpiar archivos temporales"
    
    echo "✅ LIMPIEZA COMPLETADA!"
    
    # Mostrar espacio liberado
    echo "💾 ESPACIO DISPONIBLE:"
    df -h / 2>/dev/null || echo "Info de disco no disponible"
}

# Análisis de uso de disco
function disk-usage() {
    color_echo "ANÁLISIS DE DISCO"
    
    echo "📊 USO POR DISPOSITIVO:"
    df -h 2>/dev/null | grep -E '^/dev/' || echo "Info de disco no disponible"
    
    echo ""
    echo "📁 DIRECTORIOS MÁS GRANDES EN $(pwd):"
    du -sh ./* 2>/dev/null | sort -hr | head -10 | while read size path; do
        echo "📦 $size - $path"
    done
    
    echo ""
    echo "📁 DIRECTORIOS MÁS GRANDES EN HOME:"
    du -sh ~/* 2>/dev/null | sort -hr | head -10 | while read size path; do
        echo "📦 $size - $path"
    done
}

# Verificación de puertos y seguridad
function check-ports() {
    color_echo "PUERTOS ABIERTOS"
    echo "📡 ESCANEANDO PUERTOS LOCALES..."
    
    # Puertos listening
    echo "🔓 PUERTOS EN ESCUCHA:"
    netstat -tulpn 2>/dev/null | grep LISTEN | head -10
    
    # Conexiones establecidas
    echo ""
    echo "🔗 CONEXIONES ESTABLECIDAS:"
    netstat -tupn 2>/dev/null | grep ESTABLISHED | head -10
}

# Generador de contraseñas seguras
function gen-pass() {
    local length=${1:-16}
    local num_passwords=${2:-1}
    
    color_echo "GENERADOR DE CONTRASEÑAS"
    echo "📏 LONGITUD: $length caracteres"
    echo "🔢 CANTIDAD: $num_passwords contraseña(s)"
    echo ""
    
    for i in $(seq 1 $num_passwords); do
        if [ $num_passwords -gt 1 ]; then
            echo "🔑 CONTRASEÑA $i:"
        fi
        openssl rand -base64 48 2>/dev/null | cut -c1-$length || echo "No se pudo generar contraseña"
    done
}

# ===== UTILIDADES AVANZADAS =====

# Función de celebración para comandos exitosos
function celebrate() {
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "🎉 ¡ÉXITO! 🎉"
        if command -v paplay &> /dev/null; then
            paplay /usr/share/sounds/ubuntu/stereo/system-ready.ogg 2>/dev/null &
        fi
    else
        echo "💥 ALGO SALIÓ MAL (Código: $exit_code) 💥"
    fi
}

# Backup rápido de configuraciones importantes
function quick-backup() {
    local backup_dir="$HOME/backups/$(date +%Y-%m-%d_%H-%M-%S)"
    local config_files=(
        ".bashrc" ".bash_personal" ".bash_functions"
        ".vimrc" ".tmux.conf" ".gitconfig" ".install-terminal-pro.sh"
    )
    
    color_echo "CREANDO BACKUP"
    
    mkdir -p "$backup_dir"
    
    for file in "${config_files[@]}"; do
        if [ -f "$HOME/$file" ]; then
            cp "$HOME/$file" "$backup_dir/"
            echo "📄 COPIADO: $file"
        fi
    done
    
    # Backup de proyectos si existen
    if [ -d "$HOME/projects" ]; then
        echo "📦 COMPRIMIENDO PROYECTOS..."
        tar -czf "$backup_dir/projects_backup.tar.gz" -C "$HOME" projects/ 2>/dev/null
    fi
    
    echo "✅ BACKUP COMPLETADO EN: $backup_dir"
    echo "📊 TAMAÑO TOTAL: $(du -sh "$backup_dir" 2>/dev/null | cut -f1 || echo "Desconocido")"
}


# ===== GESTIÓN DE ALIASES =====

# Listar todos los aliases de forma organizada y con colores
function list-aliases() {
    color_echo "LISTA DE ALIASES DISPONIBLES"
    
    echo ""
    echo "🎯 NAVEGACIÓN:" | lolcat 2>/dev/null || echo "🎯 NAVEGACIÓN:"
    alias | grep -E "^(alias \.\.|alias \.\.\.|alias \.\.\.\.|alias \.\.\.\.\.|alias cd|alias cl|alias mkcd)" | sed 's/alias //' | sort
    
    echo ""
    echo "📁 ARCHIVOS Y DIRECTORIOS:" | lolcat 2>/dev/null || echo "📁 ARCHIVOS Y DIRECTORIOS:"
    alias | grep -E "^(alias ls|alias ll|alias la|alias l|alias lls|alias findit|alias tarball|alias extract)" | sed 's/alias //' | sort
    
    echo ""
    echo "🎮 DIVERTIDOS:" | lolcat 2>/dev/null || echo "🎮 DIVERTIDOS:"
    alias | grep -E "^(alias matrix|alias hacker|alias starwars|alias train|alias quote|alias space|alias celebrate|alias weather|alias moon)" | sed 's/alias //' | sort
    
    echo ""
    echo "⚙️  SISTEMA:" | lolcat 2>/dev/null || echo "⚙️  SISTEMA:"
    alias | grep -E "^(alias update|alias clean|alias please|alias ports|alias myip|alias sysinfo|alias live-monitor)" | sed 's/alias //' | sort
    
    echo ""
    echo "🐙 GIT:" | lolcat 2>/dev/null || echo "🐙 GIT:"
    alias | grep -E "^(alias gs|alias ga|alias gc|alias gp|alias gl|alias gcm)" | sed 's/alias //' | sort
    
    echo ""
    echo "🐳 DOCKER:" | lolcat 2>/dev/null || echo "🐳 DOCKER:"
    alias | grep -E "^(alias docker-ps|alias docker-stats|alias docker-clean)" | sed 's/alias //' | sort
    
    echo ""
    echo "📊 TOTAL: $(alias | wc -l) aliases definidos" | lolcat 2>/dev/null || echo "📊 TOTAL: $(alias | wc -l) aliases definidos"
    echo ""
    echo "💡 CONSEJOS:" | lolcat 2>/dev/null || echo "💡 CONSEJOS:"
    echo "  • Usa 'type <alias>' para ver qué hace un alias" | lolcat 2>/dev/null || echo "  • Usa 'type <alias>' para ver qué hace un alias"
    echo "  • Usa 'search-aliases <término>' para buscar aliases" | lolcat 2>/dev/null || echo "  • Usa 'search-aliases <término>' para buscar aliases"
}

# Alias corto para list-aliases
alias lalias='list-aliases'

# Buscar aliases específicos
function search-aliases() {
    if [ -z "$1" ]; then
        echo "🔍 USO: search-aliases <término>" | lolcat 2>/dev/null || echo "🔍 USO: search-aliases <término>"
        echo "💡 Ejemplos:" | lolcat 2>/dev/null || echo "💡 Ejemplos:"
        echo "  search-aliases git" | lolcat 2>/dev/null || echo "  search-aliases git"
        echo "  search-aliases docker" | lolcat 2>/dev/null || echo "  search-aliases docker"
        echo "  search-aliases ls" | lolcat 2>/dev/null || echo "  search-aliases ls"
        return 1
    fi
    
    color_echo "ALIASES QUE COINCIDEN CON: $1"
    echo ""
    alias | grep -i "$1" | sed 's/alias //' | lolcat 2>/dev/null || alias | grep -i "$1" | sed 's/alias //'
    
    local count=$(alias | grep -i "$1" | wc -l)
    echo ""
    echo "📈 Encontrados: $count aliases" | lolcat 2>/dev/null || echo "📈 Encontrados: $count aliases"
}

# Ver detalles de un alias específico
function alias-info() {
    if [ -z "$1" ]; then
        echo "🔍 USO: alias-info <nombre_alias>" | lolcat 2>/dev/null || echo "🔍 USO: alias-info <nombre_alias>"
        echo "💡 Ejemplo: alias-info ll" | lolcat 2>/dev/null || echo "💡 Ejemplo: alias-info ll"
        return 1
    fi
    
    color_echo "INFORMACIÓN DEL ALIAS: $1"
    echo ""
    type "$1" 2>/dev/null || echo "❌ El alias '$1' no existe" | lolcat 2>/dev/null || echo "❌ El alias '$1' no existe"
}


# Actualizador de la configuración de terminal
function terminal-upgrade() {
    color_echo "ACTUALIZANDO TERMINAL"
    
    echo "🔄 RECARGANDO CONFIGURACIÓN..."
    source ~/.bashrc
    
    echo "✨ TERMINAL ACTUALIZADA!"
    echo "💡 Nuevas funciones disponibles:"
    myhelp | tail -5
}

# Función para unificar recursivamente el contenido de archivos en una ruta
# Uso: unify_content_recursive <ruta_a_escanear> <archivo_de_salida>
function unify-content-recursive() {
    # 1. Verificación de argumentos y ruta
    if [ "$#" -ne 2 ]; then
        echo "Uso: unify_content_recursive <ruta_a_escanear> <archivo_de_salida>"
        return 1
    fi

    local SCAN_PATH="$1"
    local OUTPUT_FILE="$2"

    if [ ! -d "$SCAN_PATH" ]; then
        echo "Error: La ruta '$SCAN_PATH' no es un directorio válido."
        return 1
    fi

    echo "Preparando para escanear y unificar archivos..."
    
    # 2. Conteo robusto de archivos
    # Usamos 'find -type f' para contar solo archivos regulares
    local TOTAL_FILES=$(find "$SCAN_PATH" -type f -print | wc -l)
    
    if [ "$TOTAL_FILES" -eq 0 ]; then
        echo "Advertencia: No se encontraron archivos regulares en '$SCAN_PATH'."
        return 0
    fi
    
    echo "Total de archivos a procesar: $TOTAL_FILES"

    # Inicializar contadores y variables de tiempo
    local CURRENT_FILE=0
    local START_TIME=$SECONDS
    local ELAPSED_TIME=0
    local ESTIMATED_TIME=0
    local REMAINING_TIME=0

    # 3. Limpiar o crear el archivo de salida
    echo "Generando archivo unificado en: $OUTPUT_FILE"
    echo "Contenido Unificado de: $SCAN_PATH" > "$OUTPUT_FILE"
    echo "Generado el: $(date)" >> "$OUTPUT_FILE"
    echo "========================================" >> "$OUTPUT_FILE"

    # 4. Función de la barra de progreso (interna)
    _progress_bar() {
        local CURRENT=$1
        local TOTAL=$2
        local ELAPSED=$3
        # Asegurarse de que TOTAL no sea cero para evitar divisiones por cero
        if [ "$TOTAL" -eq 0 ]; then
            local PERCENT=0
        else
            local PERCENT=$(( (CURRENT * 100) / TOTAL ))
        fi

        local BAR_LENGTH=50
        local FILLED_LENGTH=$(( (PERCENT * BAR_LENGTH) / 100 ))
        local EMPTY_LENGTH=$(( BAR_LENGTH - FILLED_LENGTH ))
        
        # Calcular tiempo restante (solo si se ha procesado más de 0 archivos y TOTAL > 0)
        if [ "$CURRENT" -gt 0 ] && [ "$TOTAL" -gt 0 ]; then
            # Se calcula el tiempo estimado total y luego el restante
            ESTIMATED_TIME=$(( (ELAPSED * TOTAL) / CURRENT ))
            REMAINING_TIME=$(( ESTIMATED_TIME - ELAPSED ))
        fi
        
        # Formato de la barra: [####################-----]
        local BAR=$(printf "%${FILLED_LENGTH}s" | tr ' ' '#')
        BAR=$(printf "%s%${EMPTY_LENGTH}s" "$BAR" | tr ' ' '-')

        # Imprimir la barra y la info de tiempo (uso \r para sobrescribir la línea)
        printf "\rProgreso: [%s] %3d%% (%d/%d) | Transcurrido: %ss | Restante: %ss" \
               "$BAR" "$PERCENT" "$CURRENT" "$TOTAL" "$ELAPSED" "$REMAINING_TIME"
    }

    # 5. Procesamiento de archivos **SEGURO** con find -print0
    # Este bucle es seguro contra nombres de archivo con espacios o caracteres especiales.
    find "$SCAN_PATH" -type f -print0 | while IFS= read -r -d $'\0' file; do
        CURRENT_FILE=$((CURRENT_FILE + 1))
        
        # A. Actualizar y mostrar la barra de progreso
        ELAPSED_TIME=$((SECONDS - START_TIME))
        _progress_bar "$CURRENT_FILE" "$TOTAL_FILES" "$ELAPSED_TIME"

        # B. Escribir la estructura y el contenido
        echo "" >> "$OUTPUT_FILE"
        echo "--- ARCHIVO INICIO ---" >> "$OUTPUT_FILE"
        echo "RUTA: ${file}" >> "$OUTPUT_FILE"
        
        # El contenido del archivo va entre los delimitadores
        cat "${file}" >> "$OUTPUT_FILE"
        
        echo "--- ARCHIVO FIN ---" >> "$OUTPUT_FILE"
    done

    # 6. Mensaje de finalización
    local END_TIME=$SECONDS
    local TOTAL_ELAPSED=$((END_TIME - START_TIME))
    # Aseguramos que la barra de progreso muestre 100% al finalizar
    printf "\rProgreso: [%s] 100%% (%d/%d) | Tiempo Total: %ss\n" "$(printf "%50s" | tr ' ' '#')" "$TOTAL_FILES" "$TOTAL_FILES" "$TOTAL_ELAPSED"
    echo "✅ Proceso completado. Archivo generado correctamente en $OUTPUT_FILE."
}


# ===== SISTEMA DE AYUDA =====

# Sistema de ayuda personalizado
function myhelp() {
    color_echo "AYUDA DE COMANDOS PERSONALIZADOS"
    echo ""
    
    echo "🎯 SISTEMA Y MONITOREO:"
    echo "  sysinfo          - Información completa del sistema"
    echo "  live-monitor     - Monitor en tiempo real"
    echo "  detect-sensors   - Detectar sensores de temperatura"
    echo "  disk-usage       - Análisis de uso de disco"
    echo ""
    
    echo "📁 ARCHIVOS Y DIRECTORIOS:"
    echo "  findit <patrón>  - Buscar archivos"
    echo "  mkcd <dir>       - Crear directorio y entrar"
    echo "  cl <dir>         - Cambiar directorio y listar"
    echo "  tarball <n> <d>  - Comprimir directorio"
    echo "  extract <arch>   - Extraer archivo comprimido"
    echo ""
    
    echo "🌐 RED Y CONECTIVIDAD:"
    echo "  myip             - Información de IP"
    echo "  pingg <host>     - Ping mejorado"
    echo "  weather [ciudad] - Información del clima"
    echo "  wget-progress <u>- Descargar con progreso"
    echo ""
    
    echo "💻 DESARROLLO:"
    echo "  new-project <n>  - Crear proyecto"
    echo "  codegrep <p> <e> - Buscar en código"
    echo "  new-script <n>   - Crear script plantilla"
    echo ""
    
    echo "🐳 DOCKER:"
    echo "  docker-ps        - Listar contenedores"
    echo "  docker-stats     - Estadísticas Docker"
    echo "  docker-clean     - Limpieza completa"
    echo ""
    
    echo "📝 NOTAS RÁPIDAS:"
    echo "  note             - Listar notas"
    echo "  note <nombre>    - Ver/crear nota"
    echo "  note create <n>  - Crear nota"
    echo "  note delete <n>  - Eliminar nota"
    echo "  note search <t>  - Buscar en notas"
    echo ""
    
    echo "🎮 ENTRETENIMIENTO:"
    echo "  rps              - Piedra, papel o tijera"
    echo "  hacker-mode      - Simulador hacker"
    echo "  ascii-clock      - Reloj ASCII"
    echo "  snake-game       - Juego Snake"
    echo "  tetris-game      - Juego Tetris"
    echo ""
    
    echo "🔧 MANTENIMIENTO:"
    echo "  mega-clean       - Limpieza completa"
    echo "  check-ports      - Ver puertos abiertos"
    echo "  gen-pass [l] [n] - Generar contraseñas"
    echo "  quick-backup     - Backup rápido"
    echo ""
    
    echo "🔄 UTILIDADES:"
    echo "  celebrate               - Celebrar éxito"
    echo "  terminal-upgrade        - Actualizar terminal"
    echo "  lalias                  - Muestra la lista de alias"
    echo "  list-aliases            - Muestra la lista de alias"
    echo "  search-aliases          - Busca un alias en especifico"
    echo "  unify-content-recursive - Unifica todos los archivos en uno solo"
    echo "  alias-info              - Muestra info del alias"
    echo "  myhelp                  - Mostrar esta ayuda"
    echo ""
    
    echo "💡 CONSEJO: Usa 'type <función>' para ver el código de cualquier función"
}

# ===== INICIALIZACIÓN =====
echo "✅ ¡Funciones personalizadas cargadas! 🐙" | lolcat 2>/dev/null || echo "✅ ¡Funciones personalizadas cargadas! 🐙"
