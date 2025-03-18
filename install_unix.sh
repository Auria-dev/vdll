#!/bin/bash

echo "Creating a virtual environment..."
python -m venv vdll

echo "Activating virtual environment..."
source vdll/bin/activate

echo "Installing ffmpeg..."
python install_ffmpeg.py

echo "Installing PyInstaller..."
pip3 install pyinstaller

echo "Creating the standalone executable..."
pyinstaller --onefile vdll.py

echo "PyInstaller packaging completed!"

echo "Moving the executable to /usr/bin..."
sudo mv dist/vdll /usr/bin/

echo "Giving executable permissions..."
sudo chmod +x /usr/bin/vdll

echo "VDLL installed successfully! Run the command 'vdll' for more information"

deactivate
