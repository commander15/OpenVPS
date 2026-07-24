import sys

from utils.command import subCommand, showHelp

if __name__ == "__main__":
    showHelp(chapterTag=subCommand(), exit=True)