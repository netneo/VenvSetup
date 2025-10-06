🐍 Python Project Launcher
⚡ Quick Start

Get your project running in three simple commands:

# 1️⃣ Clone or download the project to your folder
git clone <repo-url> myproject
cd myproject

# 2️⃣ Install inotify-tools (for watch mode, optional)
sudo apt install inotify-tools

# 3️⃣ Run the project
./run.sh


Optional: To rebuild the virtual environment or enable watch mode:

./run.sh rebuild
./run.sh watch

📌 Project Overview

This project provides a Python-based script with a fully automated virtual environment setup. It simplifies dependency management and ensures consistent development across systems, even on Ubuntu where system Python often restricts pip installs. Key features include automatic creation of a .venv environment, installation and synchronization of dependencies from requirements.txt, Python version validation, optional watch mode for live updates during development, and comprehensive logging. The included run.sh launcher ensures that running or updating the project is as simple as a single command, making it ideal for both developers and end users.

Features

✅ Auto-create virtual environment (.venv) if missing

✅ Rebuild option (./run.sh rebuild) to recreate the environment

✅ Dependency installation from requirements.txt

✅ Auto-sync dependencies if requirements.txt changes

✅ Python version check (default ≥ 3.11)

✅ Optional watch mode (./run.sh watch) to auto-update deps and rerun script on changes

✅ Logs all installation output to logs/setup.log

Usage
# Normal run (auto create venv, install deps, run script)
./run.sh

# Force rebuild of virtual environment
./run.sh rebuild

# Watch mode (auto-update dependencies + rerun script)
./run.sh watch

# Use a specific Python version
PYTHON_CMD=python3.12 ./run.sh

# Combine custom Python + watch mode
PYTHON_CMD=python3.12 ./run.sh watch

⚙️ Which Python Script Runs

The run.sh launcher runs the Python script specified at the top of the script:

MAIN_SCRIPT="$SCRIPT_DIR/main.py"


By default, it will run main.py located in the same folder as run.sh.

Since the virtual environment is activated before running the script, it uses the venv’s Python and installed dependencies.

To change which Python script runs, edit the MAIN_SCRIPT variable at the top of run.sh to point to your desired script:

MAIN_SCRIPT="$SCRIPT_DIR/my_script.py"

Requirements

Ubuntu (or any Linux with Bash)

Python ≥ 3.11 (or override with PYTHON_CMD)

Optional: inotify-tools for watch mode

sudo apt install inotify-tools

Logs

All pip installation output is stored in:

logs/setup.log

❓ FAQ / Troubleshooting

Q: I get “Python 3.x not found” or version too low.
A: Ensure your system has Python ≥ 3.11, or override with a newer version:

PYTHON_CMD=python3.12 ./run.sh


Q: Watch mode says inotifywait not found.
A: Install the required package:

sudo apt install inotify-tools


Q: Pip install fails due to system restrictions on Ubuntu.
A: The script uses a local virtual environment (.venv) to avoid system directories. Check logs/setup.log for detailed errors.

Q: I changed requirements.txt but dependencies aren’t updating.
A: The script tracks changes using a hash file. Ensure the .requirements.hash file exists or run:

./run.sh rebuild


to force a clean update.

Q: How can I debug installation issues?
A: All pip logs are in logs/setup.log. Review this file to see exactly what failed.