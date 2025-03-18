@echo off

echo creating virtual environment...
python -m venv vdll
call vdll\Scripts\activate.bat

echo installing ffmpeg...
python install_ffmpeg.py

echo installing pyinstaller...
pip install pyinstaller

echo building vdll executable...
pyinstaller --onefile vdll.py

set target_dir=C:\Program Files\Nitaki\VDLL

echo checking if target directory exists...
if not exist "%target_dir%" (
    echo creating target directory...
    mkdir "%target_dir%"
)

echo copying executable to target directory...
copy dist\vdll.exe "%target_dir%\vdll.exe"

echo applying registry settings...
call install_context.reg

echo script completed successfully.
