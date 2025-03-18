import os
import platform
import subprocess
import shutil
from urllib.request import urlretrieve

def find_ffmpeg_bin(directory):
    for root, dirs, files in os.walk(directory):
        if "ffmpeg.exe" in files or "ffmpeg" in files:
            return root
    return None

def add_to_path(directory):
    system = platform.system().lower()
    if system == "windows":
        import winreg as reg
        reg_key = r"Environment"
        with reg.OpenKey(reg.HKEY_CURRENT_USER, reg_key, 0, reg.KEY_ALL_ACCESS) as key:
            current_path, _ = reg.QueryValueEx(key, "Path")
            if directory not in current_path:
                new_path = f"{current_path};{directory}"
                reg.SetValueEx(key, "Path", 0, reg.REG_EXPAND_SZ, new_path)
                print("added to PATH. you may need to restart your terminal or system for the changes to take effect.")
    else:
        shell_config = os.path.expanduser("~/.bashrc")
        if system == "darwin" and os.path.exists(os.path.expanduser("~/.zshrc")):
            shell_config = os.path.expanduser("~/.zshrc")

        with open(shell_config, "a") as f:
            f.write(f"\n# added by ffmpeg installer\nexport PATH=\"{directory}:$PATH\"\n")
        print(f"added to PATH in {shell_config}. please run 'source {shell_config}' or restart your terminal.")

def install_ffmpeg():
    system = platform.system().lower()
    ffmpeg_url = ""
    ffmpeg_dir = os.path.expanduser("~/.local/bin")

    if not os.path.exists(ffmpeg_dir):
        os.makedirs(ffmpeg_dir)

    if system == "windows":
        ffmpeg_url = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
        zip_path = os.path.join(ffmpeg_dir, "ffmpeg.zip")
        urlretrieve(ffmpeg_url, zip_path)
        shutil.unpack_archive(zip_path, ffmpeg_dir)
        os.remove(zip_path)
        bin_dir = find_ffmpeg_bin(ffmpeg_dir)
        if bin_dir:
            add_to_path(bin_dir)
            print(f"ffmpeg installed and added to PATH from {bin_dir}.")
        else:
            print("ffmpeg installation failed. could not locate the executable.")
    
    elif system == "darwin":  # macos
        ffmpeg_url = "https://evermeet.cx/ffmpeg/ffmpeg"
        ffmpeg_path = os.path.join(ffmpeg_dir, "ffmpeg")
        urlretrieve(ffmpeg_url, ffmpeg_path)
        os.chmod(ffmpeg_path, 0o755)
        add_to_path(ffmpeg_dir)
        print(f"ffmpeg installed and added to PATH at {ffmpeg_path}")
    
    elif system == "linux":
        ffmpeg_url = "https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz"
        tar_path = os.path.join(ffmpeg_dir, "ffmpeg.tar.xz")
        urlretrieve(ffmpeg_url, tar_path)
        shutil.unpack_archive(tar_path, ffmpeg_dir)
        os.remove(tar_path)
        bin_dir = find_ffmpeg_bin(ffmpeg_dir)
        if bin_dir:
            add_to_path(bin_dir)
            print(f"ffmpeg installed and added to PATH from {bin_dir}.")
        else:
            print("ffmpeg installation failed. could not locate the executable.")
    
    else:
        raise OSError(f"unsupported operating system: {system}")

def check_ffmpeg_installed():
    try:
        subprocess.run(["ffmpeg", "-version"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print("ffmpeg is already installed.")
    except subprocess.CalledProcessError:
        print("ffmpeg is not installed. Installing...")
        install_ffmpeg()

if __name__ == "__main__":
    check_ffmpeg_installed()