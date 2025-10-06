#!/usr/bin/env bash
# run.sh — automatic environment setup + run script
# Features: rebuild, logging, Python version check, auto dependency sync, watch mode
# By NetNeo
# https://github.com/netneo/VenvSetup
# ----------------------------------------------------------------------

set -e

# CONFIG
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"
REQUIREMENTS_FILE="$SCRIPT_DIR/requirements.txt"
MAIN_SCRIPT="$SCRIPT_DIR/main.py"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/setup.log"
HASH_FILE="$SCRIPT_DIR/.requirements.hash"
PYTHON_CMD="${PYTHON_CMD:-python3}"  # Use $PYTHON_CMD to override default Python
MIN_PYTHON_VERSION="3.11"           # Minimum Python version required
WATCH_MODE=false

# Parse arguments
for arg in "$@"; do
    if [[ "$arg" == "rebuild" ]]; then
        REBUILD=true
    elif [[ "$arg" == "watch" ]]; then
        WATCH_MODE=true
    fi
done

mkdir -p "$LOG_DIR"

# Function: compare Python versions
version_ge() {
    [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

# Check Python version
PYTHON_VERSION="$($PYTHON_CMD -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"
if ! version_ge "$PYTHON_VERSION" "$MIN_PYTHON_VERSION"; then
    echo "[!] Python $MIN_PYTHON_VERSION or higher is required. Detected: $PYTHON_VERSION"
    exit 1
else
    echo "[+] Python version $PYTHON_VERSION detected — OK."
fi

# Function: install/update requirements
install_requirements() {
    if [ -f "$REQUIREMENTS_FILE" ]; then
        echo "[+] Installing/updating dependencies..."
        "$VENV_DIR/bin/pip" install -r "$REQUIREMENTS_FILE" &>> "$LOG_FILE"
        sha256sum "$REQUIREMENTS_FILE" | awk '{print $1}' > "$HASH_FILE"
    else
        echo "[!] Warning: requirements.txt not found" &>> "$LOG_FILE"
    fi
}

# Function: check if requirements.txt changed
requirements_changed() {
    if [ ! -f "$REQUIREMENTS_FILE" ]; then
        return 1
    fi
    if [ ! -f "$HASH_FILE" ]; then
        return 0
    fi
    local current_hash
    current_hash=$(sha256sum "$REQUIREMENTS_FILE" | awk '{print $1}')
    local saved_hash
    saved_hash=$(cat "$HASH_FILE")
    [ "$current_hash" != "$saved_hash" ]
}

# Function: create virtual environment
create_venv() {
    echo "[+] Creating virtual environment..."
    "$PYTHON_CMD" -m venv "$VENV_DIR"
    "$VENV_DIR/bin/pip" install --upgrade pip wheel setuptools &> "$LOG_FILE"
    install_requirements
    echo "[+] Virtual environment setup complete."
}

# Handle rebuild
if [[ "$REBUILD" == true ]]; then
    echo "[!] Rebuild requested — deleting existing venv..."
    rm -rf "$VENV_DIR"
    create_venv
elif [ ! -d "$VENV_DIR" ]; then
    create_venv
else
    echo "[=] Virtual environment already exists."
    if requirements_changed; then
        echo "[!] requirements.txt changed — updating dependencies..."
        install_requirements
    fi
fi

# Activate venv
source "$VENV_DIR/bin/activate"

# Function to run main script
run_main() {
    echo "[+] Running $MAIN_SCRIPT ..."
    python "$MAIN_SCRIPT"
}

# Initial run
run_main

# Watch mode
if [[ "$WATCH_MODE" == true ]]; then
    # Check if inotifywait is installed
    if ! command -v inotifywait &> /dev/null; then
        echo "[!] inotifywait not found. Install it with: sudo apt install inotify-tools"
        deactivate
        exit 1
    fi
    echo "[+] Watch mode enabled — monitoring requirements.txt for changes..."
    while true; do
        inotifywait -e close_write "$REQUIREMENTS_FILE" &> /dev/null
        echo "[!] Detected change in requirements.txt — updating dependencies..."
        install_requirements
        echo "[+] Dependencies updated. Rerunning main script..."
        run_main
    done
fi

# Deactivate venv if not watching
deactivate
