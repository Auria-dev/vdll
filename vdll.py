import sys
import subprocess
import os

def convert_video(input_path, output_format):
    output_path = os.path.splitext(input_path)[0] + '.' + output_format

    if output_format == 'mp3':
        command = [
            'ffmpeg',
            '-i', input_path,
            '-q:a', '0',
            output_path
        ]
    elif output_format == 'gif':
        print('Creating gif, this may take a while...')
        command = [
            'ffmpeg',
            '-i', input_path,
            '-vf', 'fps=12,scale=640:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse',  # GIF settings
            output_path
        ]
    else:
        command = [
            'ffmpeg',
            '-i', input_path,
            '-c:v', 'libx264',
            '-preset', 'fast',
            '-crf', '23',
            '-c:a', 'aac',
            output_path
        ]

    try:
        subprocess.run(command, check=True)
        print(f"Conversion successful: {output_path}")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred during conversion: {e}")

def main():
    if len(sys.argv) != 3:
        print("Usage: python script.py <output_format> <input_path>")
        sys.exit(1)

    output_format = sys.argv[1]
    input_path = sys.argv[2]

    if not os.path.isfile(input_path):
        print(f"Error: The file {input_path} does not exist.")
        sys.exit(1)

    convert_video(input_path, output_format)

if __name__ == "__main__":
    main()