from utils.command import subCommand, command, arguments
from scripts.network import up

def boot(cmd: str | None, sub: str | None, args: list[str] | None):
    if cmd == 'boot':
        print("That's not fair !")

    if sub == 'up':
        up()

if __name__ == "__main__":
    cmd = command(booting=True)

    if cmd == 'boot':
        print("That's not fair !")
    elif cmd == None:
        pass
    else:
        boot(cmd, subCommand(booting=True), arguments(booting=True))