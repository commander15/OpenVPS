import subprocess
import sys

from subprocess import run, CompletedProcess, CalledProcessError

def command(booting: bool = False):
    index = 1 if booting else 0
    if len(sys.argv) > booting:
        path = sys.argv[index]
        path = path.split('/')
        path = path[len(path) - 1]
        return path.split('.')[0]
    else:
        return None

def subCommand(booting: bool = False):
    index = 2 if booting else 1
    if len(sys.argv) > index:
        return sys.argv[index]
    else:
        return None

def arguments(booting: bool = False):
    args = sys.argv

    # Removing boot entry
    if booting and len(args) > 0:
        args.pop(0)

    # Removing script path
    if len(sys.argv) > 0:
        args.pop(0)

    # Removing sub command
    if len(sys.argv) > 0:
        args.pop(0)

    return args if len(args) > 0 else None

import sys

def showHelp(chapterTag: str | None = None, exit: bool = True):
    chapters = [
        {
            "tag": "commands",
            "start": 25,
            "stop": 61
        }
    ]

    # Default: Read to end of file
    chapter = {
        "tag": 'all',
        "start": 7,
        "stop": None
    }

    if chapterTag:
        for chap in chapters:
            if chap['tag'] == chapterTag:
                chapter = chap
                break

    try:
        with open("README.md", "r", encoding="utf-8") as file:
            lines = file.readlines()

            header_lines = [ lines[0], lines[1], lines[2] ]
            
            # Map 1-based config to 0-based list slicing
            start_idx = chapter['start'] - 1
            stop_idx = chapter['stop']
            
            # Extract desired lines
            if stop_idx is None:
                content_lines = lines[start_idx:]
            else:
                content_lines = lines[start_idx:stop_idx]
                
            full_text = "".join(header_lines + [ '\n' ] + content_lines)
            process = subprocess.Popen(['less', '-RX'], stdin=subprocess.PIPE, text=True)
            process.communicate(input=full_text)

            if exit:
                sys.exit(0)
            
    except FileNotFoundError:
        print("ℹ️ README.md was not found, OpenVPS installation may be damaged.")
        if exit:
            sys.exit(1)


def run_command(cmd: str, args: list[str], printOutput: bool = True, scrollable: bool = False, exitOnError: bool = False) -> CompletedProcess[bytes] | CalledProcessError | None:
    if cmd == '':
        showHelp('commands', exit=exitOnError)
        return

    try:
        result = subprocess.run([cmd] + args, check=True, capture_output=not printOutput)

        if printOutput and result.stdout:
            if scrollable:
                full_text = str(result.stdout)
                process = subprocess.Popen(['less', '-RX'], stdin=subprocess.PIPE, text=True)
                process.communicate(input=full_text)
            else:
                print(result.stdout)

        return result
    except subprocess.CalledProcessError as e:
        if printOutput and e.output:
            print(f"{e.output}")

        if exitOnError:
            sys.exit(e.returncode)
        else:
            return e
    except KeyboardInterrupt:
        sys.exit(0)