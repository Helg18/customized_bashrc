# 🚀 Terminal Pro - Personalización Avanzada de Bash

[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-orange?logo=ubuntu)](https://ubuntu.com/)
[![Bash](https://img.shields.io/badge/Bash-4.4%2B-blue?logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Una personalización completa y espectacular para tu terminal de Ubuntu/Linux, con más de 50 funciones útiles, alias divertidos y un prompt visualmente atractivo.

![Terminal Pro Demo](https://via.placeholder.com/800x400/333/fff?text=Terminal+Pro+Demo)

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Instalación Rápida](#-instalación-rápida)
- [Instalación Manual](#-instalación-manual)
- [Estructura de Archivos](#-estructura-de-archivos)
- [Funciones Disponibles](#-funciones-disponibles)
- [Alias Disponibles](#-alias-disponibles)
- [Prompt Personalizado](#-prompt-personalizado)
- [Solución de Problemas](#-solución-de-problemas)
- [Contribuciones](#-contribuciones)

## ✨ Características

- 🎨 **Prompt de dos líneas** con colores vibrantes
- 🔧 **Más de 50 funciones** personalizadas
- ⚡ **Alias útiles y divertidos**
- 📝 **Sistema de notas integrado**
- 📊 **Monitor de sistema en tiempo real**
- 🐙 **Integración con Git** (con pulpo para repositorios)
- 🎮 **Efectos visuales y juegos**
- 🛡️ **Manejo robusto de errores**
- 🐳 **Compatible con Docker**
- 🇪🇸 **Fortunes en español**

## 🚀 Instalación Rápida

### Script de Instalación Automática

```bash
# Descargar y ejecutar el script de instalación
curl -sSL https://raw.githubusercontent.com/tuusuario/terminal-pro/main/install.sh | bash
```

### Instalación Paso a Paso

```bash
# 1. Clonar el repositorio
git clone https://github.com/tuusuario/terminal-pro.git
cd terminal-pro

# 2. Ejecutar instalación
chmod +x install.sh
./install.sh

# 3. Recargar terminal
source ~/.bashrc
```

## 📥 Instalación Manual

### Paso 1: Crear los Archivos de Configuración

**Archivo 1: `~/.bash_personal`**

```bash
# Crear el archivo
nano ~/.bash_personal

# Pegar el contenido completo del archivo .bash_personal
# (El contenido debe ir aquí)
```

**Archivo 2: `~/.bash_functions`**

```bash
# Crear el archivo
nano ~/.bash_functions

# Pegar el contenido completo del archivo .bash_functions
# (El contenido debe ir aquí)
```

### Paso 2: Permisos de Ejecución

```bash
chmod +x ~/.bash_personal ~/.bash_functions
```

### Paso 3: Configurar Bashrc

Agrega al final de tu `~/.bashrc`:

```bash
# ==================================================
# CARGA DE CONFIGURACIÓN PERSONALIZADA
# ==================================================
if [ -f ~/.bash_personal ]; then
    source ~/.bash_personal
fi

if [ -f ~/.bash_functions ]; then
    source ~/.bash_functions
fi
```

### Paso 4: Instalar Dependencias

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar paquetes esenciales
sudo apt install -y \
  curl wget git tree htop nload vim \
  lolcat figlet toilet cowsay fortune-mod fortunes-es \
  bat ripgrep fd-find fzf jq \
  lm-sensors hddtemp iotop iftop nethogs \
  cmatrix nsnake bastet gnuchess sl boxes \
  net-tools nmap telnet pv ncdu ranger exa duf unrar p7zip-full
```

### Paso 5: Recargar Configuración

```bash
source ~/.bashrc
```

## 📁 Estructura de Archivos

```
~/
├── .bash_personal          # Configuración principal, prompt y aliases
├── .bash_functions         # Más de 50 funciones personalizadas
├── .bashrc                 # Archivo original (modificado)
├── .notes/                 # Directorio de notas (creado automáticamente)
└── backups/                # Backups de configuración (creado automáticamente)
```

## 🎯 Funciones Disponibles

### 🖥️ Sistema y Monitoreo

| Función | Descripción | Uso |
|---------|-------------|-----|
| `sysinfo` | Información completa del sistema | `sysinfo` |
| `live-monitor` | Monitor en tiempo real | `live-monitor` |
| `detect-sensors` | Detecta sensores de temperatura | `detect-sensors` |
| `mega-clean` | Limpieza completa del sistema | `mega-clean` |
| `disk-usage` | Análisis de uso de disco | `disk-usage` |

### 📁 Archivos y Directorios

| Función | Descripción | Uso |
|---------|-------------|-----|
| `findit` | Busca archivos con colores | `findit "*.txt"` |
| `mkcd` | Crea directorio y entra | `mkcd proyecto` |
| `cl` | Cambia directorio y lista | `cl /ruta` |
| `tarball` | Comprime directorios | `tarball backup carpeta` |
| `extract` | Extrae archivos comprimidos | `extract archivo.zip` |

### 🌐 Red y Conectividad

| Función | Descripción | Uso |
|---------|-------------|-----|
| `myip` | Información de IP | `myip` |
| `pingg` | Ping mejorado con colores | `pingg google.com` |
| `weather` | Clima en español | `weather "Madrid"` |
| `wget-progress` | Descarga con progreso | `wget-progress URL` |

### 💻 Desarrollo

| Función | Descripción | Uso |
|---------|-------------|-----|
| `new-project` | Crea estructura de proyecto | `new-project mi-app` |
| `codegrep` | Búsqueda en código | `codegrep "function" "js"` |
| `new-script` | Crea script con template | `new-script mi-script` |

### 🐳 Docker

| Función | Descripción | Uso |
|---------|-------------|-----|
| `docker-ps` | Lista contenedores | `docker-ps` |
| `docker-stats` | Estadísticas Docker | `docker-stats` |
| `docker-clean` | Limpieza completa | `docker-clean` |

### 📝 Sistema de Notas

| Función | Descripción | Uso |
|---------|-------------|-----|
| `note` | Gestión de notas | `note crear nombre` |
| `note list` | Lista notas | `note list` |
| `note search` | Busca en notas | `note search "texto"` |

### 🎮 Entretenimiento

| Función | Descripción | Uso |
|---------|-------------|-----|
| `rps` | Piedra, papel o tijera | `rps` |
| `hacker-mode` | Simulador hacker | `hacker-mode` |
| `ascii-clock` | Reloj ASCII | `ascii-clock` |
| `snake-game` | Juego Snake | `snake-game` |
| `tetris-game` | Juego Tetris | `tetris-game` |

### 🛠️ Utilidades

| Función | Descripción | Uso |
|---------|-------------|-----|
| `celebrate` | Celebra éxitos | Automático |
| `quick-backup` | Backup configuraciones | `quick-backup` |
| `terminal-upgrade` | Actualiza terminal | `terminal-upgrade` |
| `gen-pass` | Genera contraseñas | `gen-pass 20 3` |
| `check-ports` | Verifica puertos | `check-ports` |

### 🆘 Ayuda

| Función | Descripción | Uso |
|---------|-------------|-----|
| `myhelp` | Ayuda completa | `myhelp` |
| `list-aliases` | Lista aliases | `list-aliases` |
| `search-aliases` | Busca aliases | `search-aliases git` |
| `alias-info` | Info de alias | `alias-info ll` |

## 🔤 Alias Disponibles

### Navegación
```bash
..      # cd ..
...     # cd ../..
....    # cd ../../..
.....   # cd ../../../..
```

### Sistema de Archivos
```bash
ll      # ls -alFh
la      # ls -A
l       # ls -CF
lls     # ls -alFh con colores
```

### Gestión de Sistema
```bash
update  # Actualiza sistema
clean   # Limpia sistema
please  # sudo !!
ports   # Puertos abiertos
myip    # IP pública
```

### Git
```bash
gs      # git status
ga      # git add
gc      # git commit -m
gp      # git push
gl      # git log gráfico
gcm     # git checkout main
```

### Diversión
```bash
matrix      # Efecto Matrix
hacker      # Modo hacker
starwars    # Película ASCII
train       # Tren animado
quote       # Frases inspiradoras
weather     # Clima actual
moon        # Fase lunar
```

## 🎨 Prompt Personalizado

### Estructura Visual
```
┌─[usuario@hostname]-[directorio] 🐙 branch-git
└─🚀
```

### Características
- ✨ **Dos líneas** para mejor organización
- 🎨 **Colores Byobu** (azul, naranja, rojo, verde)
- 🐙 **Pulpo** para repositorios Git
- 🔄 **Emoji aleatorio** en cada línea
- 📝 **Título de ventana** automático

### Colores
- **Usuario:** Azul
- **Hostname:** Rojo  
- **Directorio:** Verde
- **Git Branch:** Rojo intenso
- **Símbolos:** Naranja

## 🐛 Solución de Problemas

### Error de Locales
```bash
# Solución permanente
echo 'export LC_ALL=C.UTF-8' >> ~/.bashrc
echo 'export LANG=C.UTF-8' >> ~/.bashrc
echo 'export LANGUAGE=C.UTF-8' >> ~/.bashrc
source ~/.bashrc
```

### Comandos No Encontrados
```bash
# Instalar paquetes faltantes
sudo apt update
sudo apt install lolcat figlet toilet cowsay fortune-mod
```

### Permisos Denegados
```bash
chmod +x ~/.bash_personal ~/.bash_functions
source ~/.bashrc
```

### Prompt No Cambia
```bash
byobu-disable-prompt
source ~/.bashrc
```

## 🔄 Comandos de Mantenimiento

```bash
# Recargar configuración
source ~/.bashrc

# Backup configuraciones
quick-backup

# Actualizar terminal
terminal-upgrade

# Ver ayuda completa
myhelp

# Listar aliases
list-aliases
```

## 🤝 Contribuciones

¡Contribuciones son bienvenidas! Puedes:

1. 🐛 Reportar bugs
2. 💡 Sugerir nuevas funciones
3. 📚 Mejorar documentación
4. 🔧 Agregar más aliases

### Estructura para Nuevas Funciones

```bash
function nueva-funcion() {
    # Descripción breve
    # Uso: nueva-funcion <args>
    # Ejemplo: nueva-funcion ejemplo
    
    # Código aquí
    echo "¡Nueva función!"
}
```

## 📞 Soporte

Si encuentras problemas:

1. 📖 Revisa la sección de solución de problemas
2. 🆘 Usa `myhelp` para ver comandos
3. 📦 Verifica paquetes instalados
4. 🔄 Recarga con `source ~/.bashrc`

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

---

**¡Disfruta de tu terminal super personalizada! 🚀🐙**

*Creado con ❤️ para desarrolladores que aman la terminal*
