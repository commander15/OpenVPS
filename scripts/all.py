import sys

from utils.docker import run_docker_compose_up, run_docker_compose_down, run_docker_compose
from utils.command import subCommand, arguments

def up(exitOnError: bool = False):
    return run_docker_compose_up([ '*' ], exitOnError=exitOnError)

def down(exitOnError: bool = False):
    return run_docker_compose_down([ '*' ], exitOnError=exitOnError)

def restart(exitOnError: bool = False):
    return run_docker_compose(['*'], ['restart'], exitOnError=exitOnError)



# ============================= MAIN =======================================

if __name__ == "__main__":
    match subCommand():
        case 'up':
            up(exitOnError=True)

        case 'down':
            down(exitOnError=True)

        case None:
            run_docker_compose(['*'], arguments())

        case _:
            run_docker_compose(['*'], exitOnError=True)