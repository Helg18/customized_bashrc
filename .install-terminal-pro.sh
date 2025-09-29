#!/bin/bash
# ==================================================
# SCRIPT DE INSTALACIÓN TERMINAL PRO
# Instala todas las dependencias y configura todo
# ==================================================

echo "🚀 === INSTALANDO TERMINAL PRO ===" | toilet -f term -F metal 2>/dev/null | lolcat 2>/dev/null || echo "=== INSTALANDO TERMINAL PRO ==="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para imprimir mensajes
info() { echo -e "${YELLOW}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[ÉXITO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Verificar si es Ubuntu/Debian
if ! command -v apt &> /dev/null; then
    error "Este script solo funciona en sistemas basados en Debian/Ubuntu"
    exit 1
fi

info "Actualizando lista de paquetes..."
sudo apt update

info "Instalando herramientas básicas..."
sudo apt install -y curl wget git tree htop nload vim

info "Instalando herramientas de color y estilo..."
sudo apt install -y lolcat figlet toilet cowsay fortune-mod fortunes-es

info "Instalando herramientas de desarrollo..."
sudo apt install -y bat ripgrep fd-find fzf jq

info "Instalando herramientas de monitoreo..."
sudo apt install -y lm-sensors hddtemp iotop iftop nethogs

info "Instalando juegos en terminal..."
sudo apt install -y cmatrix nsnake bastet gnuchess sl boxes

info "Instalando herramientas de red..."
sudo apt install -y net-tools nmap telnet

info "Instalando herramientas de sistema..."
sudo apt install -y pv ncdu ranger exa duf

info "Instalando herramientas de compresión..."
sudo apt install -y unrar p7zip-full

info "Configurando VIM como editor por defecto..."
sudo update-alternatives --set editor /usr/bin/vim.basic 2>/dev/null || true

info "Creando archivos de configuración..."

# Crear .bash_personal
#cat > ~/.bash_personal << 'EOF'
#<pega aquí el contenido completo del archivo .bash_personal>
#EOF

# Crear .bash_functions  
#cat > ~/.bash_functions << 'EOF'
#<pega aquí el contenido completo del archivo .bash_functions>
#EOF

info "Haciendo los archivos ejecutables..."
chmod +x ~/.bash_personal ~/.bash_functions

info "Configurando .bashrc..."
# Backup del .bashrc original
cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d)

# Agregar carga de archivos personalizados al .bashrc
cat >> ~/.bashrc << 'EOF'

# ==================================================
# CARGA DE CONFIGURACIÓN PERSONALIZADA
# ==================================================
if [ -f ~/.bash_personal ]; then
    source ~/.bash_personal
fi

if [ -f ~/.bash_functions ]; then
    source ~/.bash_functions
fi
EOF

info "Configurando detectores de sensores..."
sudo sensors-detect --auto

info "Recargando configuración..."
source ~/.bashrc

success "¡Instalación completada!"
echo ""
info "Comandos disponibles:"
echo "  myhelp          - Ver todos los comandos"
echo "  sysinfo         - Información del sistema" 
echo "  live-monitor    - Monitor en tiempo real"
echo "  terminal-upgrade- Actualizar configuración"
echo ""
info "Reinicia tu terminal o ejecuta: source ~/.bashrc"

# Mostrar mensaje final en ESPAÑOL
fortune es 2>/dev/null | cowsay -f dragon 2>/dev/null | lolcat 2>/dev/null || fortune 2>/dev/null | cowsay -f dragon 2>/dev/null || echo "¡Instalación completada! 🎉"
